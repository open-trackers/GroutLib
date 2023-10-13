
//
//  ZExercise-dedupe.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZExercise {
    static func dedupe(_ context: NSManagedObjectContext,
                       routineArchiveID: UUID,
                       exerciseArchiveID: UUID,
                       inStore: NSPersistentStore) throws
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, exerciseArchiveID: exerciseArchiveID)
        let sort = ZExercise.byCreatedAt()
        var first: ZExercise?
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZExercise) in

            if let _first = first {
                for exerciseRun in element.exerciseRunsArray {
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
    // Consolidates zExerciseRuns under the earliest ZExercise dupe.
    public static func dedupe(_ context: NSManagedObjectContext, _ object: NSManagedObject, inStore: NSPersistentStore) throws {
        guard let element = object as? ZExercise,
              let routineArchiveID = element.zRoutine?.routineArchiveID,
              let exerciseArchiveID = element.exerciseArchiveID
        else { throw TrackerError.missingData(msg: "Could not resolve ZExercise for de-duplication.") }

        try ZExercise.dedupe(context, routineArchiveID: routineArchiveID, exerciseArchiveID: exerciseArchiveID, inStore: inStore)
    }
}
