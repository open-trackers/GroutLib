//
//  ZTransferUtils.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "ZTransfer"
)

internal enum ZType {
    case zroutine
    case zroutinerun
    case zexercise
    case zexerciserun
}

internal typealias ZTypeObjectIDs = [ZType: [NSManagedObjectID]]

/// Transfers all 'Z' records in .main store to .archive store.
/// NOTE Does save context
public func transferToArchive(_ context: NSManagedObjectContext) throws {
    logger.debug("\(#function)")
    guard let mainURL = PersistenceManager.stores[.main]?.url,
          let archiveURL = PersistenceManager.stores[.archive]?.url,
          let psc = context.persistentStoreCoordinator,
          let mainStore = psc.persistentStore(for: mainURL),
          let archiveStore = psc.persistentStore(for: archiveURL)
    else {
        throw DataError.transferError(msg: "Unexpected store configuration.")
    }

    do {
        let dict = try deepCopy(context, fromStore: mainStore, toStore: archiveStore)
        try dict.values.forEach { objectIDs in
            if objectIDs.count > 0 {
                try context.deleter(objectIDs: objectIDs)
            }
        }
    } catch {
        throw DataError.transferError(msg: error.localizedDescription)
    }
}

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
            logger.debug("Copied zRoutineRun \(sRoutine.wrappedName) startedAt=\(String(describing: sRoutineRun.startedAt))")
            return true
        }

        try context.fetcher(ZExercise.self, predicate: routinePred, inStore: srcStore) { sExercise in

            let dExercise = try sExercise.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

            let exercisePred = NSPredicate(format: "zExercise = %@", sExercise)

            try context.fetcher(ZExerciseRun.self, predicate: exercisePred, inStore: srcStore) { sExerciseRun in

                _ = try sExerciseRun.shallowCopy(context, dstExercise: dExercise, toStore: dstStore)

                append(.zexerciserun, sExerciseRun.objectID)
                logger.debug("Copied zExerciseRun \(sExercise.wrappedName) completedAt=\(String(describing: sExerciseRun.completedAt))")
                return true
            }

            append(.zexercise, sExercise.objectID)
            logger.debug("Copied zExercise \(sExercise.wrappedName)")

            return true
        }

        append(.zroutine, sRoutine.objectID)
        logger.debug("Copied zRoutine \(sRoutine.wrappedName)")

        return true
    }

    return copiedObjects
}
