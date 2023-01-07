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
/// NOTE Does NOT save to context
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
/// NOTE Does NOT save to context
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

/// NOTE Does NOT save to context
public func transferToArchive(_ context: NSManagedObjectContext) throws {
    guard let archiveStore = // context.persistentStoreCoordinator?.persistentStore(for: <#T##URL#>)
        context.persistentStoreCoordinator?.persistentStores.first(where: { $0.configurationName == "Archive" })
    else {
        throw DataError.fetchError(msg: "Archive store not found")
    }

    let req = NSFetchRequest<ZExercise>(entityName: "ZExercise")
    // req.predicate = NSPredicate(format: "routine = %@", self)

    do {
        let results: [ZExercise] = try context.fetch(req) as [ZExercise]
        results.forEach {
            // TODO: deletion before?
            context.assign($0, to: archiveStore) // Specifies the store in which a newly inserted object will be saved.
            // TODO: is deletion needed here too?
            // TODO: do the Z.create methods need to explicitly assign to the correct store?
        }
    } catch {
        throw DataError.fetchError(msg: error.localizedDescription)
    }
}
