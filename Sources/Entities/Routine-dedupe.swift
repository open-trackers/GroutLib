
//
//  Routine.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension Routine {
    internal static func dedupe(_ context: NSManagedObjectContext, archiveID: UUID) throws {
        let pred = getPredicate(archiveID: archiveID)
        let sort = byCreatedAt()
        var first: Routine?
        try context.fetcher(predicate: pred, sortDescriptors: sort) { (element: Routine) in
            if let _first = first {
                for exercise in element.exercisesArray {
                    element.removeFromExercises(exercise)
                    _first.addToExercises(exercise)
                }
                context.delete(element)
            } else {
                first = element
            }
            return true
        }
    }

    // NOTE: does NOT save context
    // NOTE: does NOT dedupe exercises or foodGroups
    // Consolidates exercises and foodGroups under the earliest dupe.
    public static func dedupe(_ context: NSManagedObjectContext, _ object: NSManagedObject) throws {
        guard let element = object as? Routine,
              let archiveID = element.archiveID
        else { throw TrackerError.missingData(msg: "Could not resolve Routine for de-duplication.") }

        try Routine.dedupe(context, archiveID: archiveID)
    }
}
