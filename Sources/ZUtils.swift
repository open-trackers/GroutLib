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

/// NOTE Does NOT save context
public func transferToArchive(_ context: NSManagedObjectContext) throws {
    // search through each Z record on MAIN store
    // clone to ARCHIVE, using object create and context.assign

    // identifier "568DF589-04FE-4B1B-A5AE-61BEE2EFB2EB"
    // URL  "file:///Users/reede/Library/Application%20Support/xctest/TestGroutArchive.sqlite"

    guard let mainURL = PersistenceManager.stores[.main]?.url,
          let archiveURL = PersistenceManager.stores[.archive]?.url,
          let psc = context.persistentStoreCoordinator,
          let mainStore = psc.persistentStore(for: mainURL),
          let archiveStore = psc.persistentStore(for: archiveURL)
    else {
        throw DataError.fetchError(msg: "Archive store not found")
    }

//    var recordsToDelete = [NSManagedObjectID]()

    do {
        _ = try ZRoutine.deepCopy(context, fromStore: mainStore, toStore: archiveStore)
    } catch {
        throw DataError.transferError(msg: error.localizedDescription)
    }

    // copy each ZExercise to archive, where one doesn't already exist
//    let req2 = NSFetchRequest<ZExercise>(entityName: "ZExercise")
//    req2.affectedStores = [mainStore]
//    do {
//        let results: [ZExercise] = try context.fetch(req2) as [ZExercise]
//        try results.forEach {
//
//            let nuRoutine = ZRoutine(context: context)  //TODO search for existing, and abort if missing
//
//            try $0.copy(context, nuRoutine: nuRoutine, toStore: archiveStore)
//        }
//    } catch {
//        throw DataError.fetchError(msg: error.localizedDescription)
//    }

    // TODO: batch delete of recordsToDelete
}
