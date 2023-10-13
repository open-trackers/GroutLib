
//
//  ZRoutine-dedupe.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZRoutine {
    static func dedupe(_ context: NSManagedObjectContext, routineArchiveID: UUID, inStore: NSPersistentStore) throws {
        let pred = getPredicate(routineArchiveID: routineArchiveID)
        let sort = byCreatedAt()
        var first: ZRoutine?
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZRoutine) in
            if let _first = first {
                for exercise in element.zExercisesArray {
                    element.removeFromZExercises(exercise)
                    _first.addToZExercises(exercise)
                }
                context.delete(element)
            } else {
                first = element
            }
            return true
        }
    }

    // NOTE: does NOT save context
    // NOTE: does NOT dedupe zExercises
    // Consolidates zExercises under the earliest ZRoutine dupe.
    public static func dedupe(_ context: NSManagedObjectContext, _ object: NSManagedObject, inStore: NSPersistentStore) throws {
        guard let element = object as? ZRoutine,
              let routineArchiveID = element.routineArchiveID
        else { throw TrackerError.missingData(msg: "Could not resolve ZRoutine for de-duplication.") }

        try ZRoutine.dedupe(context, routineArchiveID: routineArchiveID, inStore: inStore)
    }
}
