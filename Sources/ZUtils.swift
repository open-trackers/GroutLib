//
//  ZUtils.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

/// Ensure all the records have archiveIDs
/// NOTE Does NOT save context
public func updateArchiveIDs(routines: [Routine]) {
    for routine in routines {
        if let _ = routine.archiveID { continue }
        routine.archiveID = UUID()
        // logger.notice("\(#function): added archiveID to \(routine.wrappedName)")
        guard let exercises = routine.exercises?.allObjects as? [Exercise] else { continue }
        for exercise in exercises {
            if let _ = exercise.archiveID { continue }
            exercise.archiveID = UUID()
            // logger.notice("\(#function): added archiveID to \(exercise.wrappedName)")
        }
    }
}

/// Delete all `Z` records prior to a specified date.
/// NOTE Does NOT save context
public func cleanLogRecords(_ context: NSManagedObjectContext, keepSince: Date) throws {
    try context.deleter(entityName: "ZExerciseRun",
                        predicate: NSPredicate(format: "completedAt < %@", keepSince as NSDate))

    try context.deleter(entityName: "ZExercise",
                        predicate: NSPredicate(format: "zExerciseRuns.@count == 0"))

    try context.deleter(entityName: "ZRoutineRun",
                        predicate: NSPredicate(format: "startedAt < %@", keepSince as NSDate))

    try context.deleter(entityName: "ZRoutine",
                        predicate: NSPredicate(format: "zRoutineRuns.@count == 0"))
}
