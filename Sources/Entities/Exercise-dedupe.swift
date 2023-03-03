
//
//  Exercise.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension Exercise {
    internal static func getPredicate(routineArchiveID: UUID, exerciseArchiveID: UUID) -> NSPredicate {
        NSPredicate(format: "routine.archiveID == %@ AND archiveID == %@", routineArchiveID.uuidString, exerciseArchiveID.uuidString)
    }

    internal static func dedupe(_ context: NSManagedObjectContext, routineArchiveID: UUID, exerciseArchiveID: UUID) throws {
        let pred = getPredicate(routineArchiveID: routineArchiveID, exerciseArchiveID: exerciseArchiveID)
        let sort = [NSSortDescriptor(keyPath: \Exercise.createdAt, ascending: true)]
        var first: Exercise?
        try context.fetcher(predicate: pred, sortDescriptors: sort) { (element: Exercise) in
            if first == nil {
                first = element
            } else {
                context.delete(element)
            }
            return true
        }
    }

    // NOTE: does NOT save context
    // NOTE: does NOT dedupe routines
    public static func dedupe(_ context: NSManagedObjectContext, _ object: NSManagedObject) throws {
        guard let element = object as? Exercise,
              let routineArchiveID = element.routine?.archiveID,
              let exerciseArchiveID = element.archiveID
        else { throw TrackerError.missingData(msg: "Could not resolve Exercise for de-duplication.") }

        try Exercise.dedupe(context,
                            routineArchiveID: routineArchiveID,
                            exerciseArchiveID: exerciseArchiveID)
    }
}
