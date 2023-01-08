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

internal enum ZType {
    case zroutine
    case zroutinerun
    case zexercise
    case zexerciserun
}

internal typealias ZTypeObjectIDs = [ZType: [NSManagedObjectID]]

/// Deep copy of all routines and their children from the source store to specified destination store
/// Returning list of the objectIDs of the records copied FROM the SOURCE store.
/// Does not delete any records.
/// Does NOT save context.
internal func deepCopy(_ context: NSManagedObjectContext,
                       fromStore srcStore: NSPersistentStore,
                       toStore dstStore: NSPersistentStore) throws -> ZTypeObjectIDs
{
    var copiedObjects = ZTypeObjectIDs()

    func append(_ ztype: ZType, _ objectID: NSManagedObjectID) {
        copiedObjects[ztype, default: [NSManagedObjectID]()]
            .append(objectID)
    }

    try context.fetcher(ZRoutine.self, inStore: srcStore) { sRoutine in

        let dRoutine = try sRoutine.shallowCopy(context, toStore: dstStore)

        let routinePred = NSPredicate(format: "zRoutine = %@", sRoutine)

        try context.fetcher(ZRoutineRun.self, predicate: routinePred, inStore: srcStore) { sRoutineRun in

            _ = try sRoutineRun.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

            append(.zroutinerun, sRoutineRun.objectID)
            print("Copied zRoutineRun \(sRoutine.wrappedName) startedAt=\(String(describing: sRoutineRun.startedAt))")
            return true
        }

        try context.fetcher(ZExercise.self, predicate: routinePred, inStore: srcStore) { sExercise in

            let dExercise = try sExercise.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

            let exercisePred = NSPredicate(format: "zExercise = %@", sExercise)

            try context.fetcher(ZExerciseRun.self, predicate: exercisePred, inStore: srcStore) { sExerciseRun in

                _ = try sExerciseRun.shallowCopy(context, dstExercise: dExercise, toStore: dstStore)

                append(.zexerciserun, sExerciseRun.objectID)
                print("Copied zExerciseRun \(sExercise.wrappedName) completedAt=\(String(describing: sExerciseRun.completedAt))")
                return true
            }

            append(.zexercise, sExercise.objectID)
            print("Copied zExercise \(sExercise.wrappedName)")

            return true
        }

        append(.zroutine, sRoutine.objectID)
        print("Copied zRoutine \(sRoutine.wrappedName)")

        return true
    }

    return copiedObjects
}

/// Transfers all 'Z' records in .main store to .archive store.
/// NOTE Does save context
public func transferToArchive(_ context: NSManagedObjectContext) throws {
    print("\(#function)")
    guard let mainURL = PersistenceManager.stores[.main]?.url,
          let archiveURL = PersistenceManager.stores[.archive]?.url,
          let psc = context.persistentStoreCoordinator,
          let mainStore = psc.persistentStore(for: mainURL),
          let archiveStore = psc.persistentStore(for: archiveURL)
    else {
        throw DataError.transferError(msg: "Unexpected store configuration.")
    }

    do {
        let srcObjectIdDict = try deepCopy(context, fromStore: mainStore, toStore: archiveStore)
        if srcObjectIdDict.count > 0 {
            try srcObjectIdDict.values.forEach {
                try context.deleter(objectIDs: $0)
            }
        }
    } catch {
        throw DataError.transferError(msg: error.localizedDescription)
    }
}
