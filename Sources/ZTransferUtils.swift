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

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                            category: "ZTransfer")

internal enum ZType {
    case zroutine
    case zroutinerun
    case zexercise
    case zexerciserun
}

internal typealias ZTypeObjectIDs = [ZType: [NSManagedObjectID]]

/// Transfers all 'Z' records in .main store to .archive store.
/// NOTE Does NOT save context
public func transferToArchive(_ context: NSManagedObjectContext) throws {
    logger.debug("\(#function)")
    guard let mainStore = PersistenceManager.getStore(context, .main),
          let archiveStore = PersistenceManager.getStore(context, .archive)
    else {
        throw DataError.invalidStoreConfiguration(msg: "transfer to archive")
    }

    let dict = try deepCopy(context, fromStore: mainStore, toStore: archiveStore)
    try dict.values.forEach { objectIDs in
        if objectIDs.count > 0 {
            try context.deleter(objectIDs: objectIDs)
        }
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

    try context.fetcher(inStore: srcStore) { (sRoutine: ZRoutine) in

        let dRoutine = try sRoutine.shallowCopy(context, toStore: dstStore)

        let routinePred = NSPredicate(format: "zRoutine = %@", sRoutine)

        // will need dExercise for creating dExerciseRun
        var dExerciseDict: [UUID: ZExercise] = [:]

        try context.fetcher(predicate: routinePred, inStore: srcStore) { (sExercise: ZExercise) in

            let dExercise = try sExercise.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

            if let uuid = dExercise.exerciseArchiveID {
                dExerciseDict[uuid] = dExercise
            } else {
                logger.error("Missing archiveID for zExercise \(sExercise.wrappedName)")
            }

            append(.zexercise, sExercise.objectID)
            logger.debug("Copied zExercise \(sExercise.wrappedName)")

            return true
        }

        try context.fetcher(predicate: routinePred, inStore: srcStore) { (sRoutineRun: ZRoutineRun) in

            let dRoutineRun = try sRoutineRun.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

            let routineRunPred = NSPredicate(format: "zRoutineRun = %@", sRoutineRun)

            try context.fetcher(predicate: routineRunPred, inStore: srcStore) { (sExerciseRun: ZExerciseRun) in

                guard let exerciseArchiveID = sExerciseRun.zExercise?.exerciseArchiveID,
                      let dExercise = dExerciseDict[exerciseArchiveID]
                else {
                    logger.error("Could not determine exerciseArchiveID to obtain destination exercise")
                    return true
                }

                _ = try sExerciseRun.shallowCopy(context, dstRoutineRun: dRoutineRun, dstExercise: dExercise, toStore: dstStore)

                append(.zexerciserun, sExerciseRun.objectID)
                logger.debug("Copied zExerciseRun \(sExerciseRun.zExercise?.name ?? "") completedAt=\(String(describing: sExerciseRun.completedAt))")
                return true
            }

            append(.zroutinerun, sRoutineRun.objectID)
            logger.debug("Copied zRoutineRun \(sRoutine.wrappedName) startedAt=\(String(describing: sRoutineRun.startedAt))")
            return true
        }

        append(.zroutine, sRoutine.objectID)
        logger.debug("Copied zRoutine \(sRoutine.wrappedName)")

        return true
    }

    return copiedObjects
}
