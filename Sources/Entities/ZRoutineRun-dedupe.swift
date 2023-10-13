
//
//  ZRoutineRun-dedupe.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZRoutineRun {
    static func dedupe(_ context: NSManagedObjectContext,
                       routineArchiveID: UUID,
                       startedAt: Date,
                       inStore: NSPersistentStore) throws
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, startedAt: startedAt)
        let sort = byCreatedAt()
        var first: ZRoutineRun?
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZRoutineRun) in

            if let _first = first {
                for exerciseRun in element.zExerciseRunsArray {
                    element.removeFromZExerciseRuns(exerciseRun)
                    _first.addToZExerciseRuns(exerciseRun)
                }
                context.delete(element)
            } else {
                first = element
            }
            return true
        }
    }

    // NOTE: does NOT save context
    // NOTE: does NOT dedupe zExerciseRuns
    // Consolidates zExerciseRuns under the earliest ZRoutineRun dupe.
    public static func dedupe(_ context: NSManagedObjectContext, _ object: NSManagedObject, inStore: NSPersistentStore) throws {
        guard let element: ZRoutineRun = object as? ZRoutineRun,
              let routineArchiveID = element.zRoutine?.routineArchiveID,
              let startedAt = element.startedAt
        else { throw TrackerError.missingData(msg: "Could not resolve ZRoutineRun for de-duplication.") }

        try ZRoutineRun.dedupe(context, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: inStore)
    }
}
