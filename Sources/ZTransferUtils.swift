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

import TrackerLib

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                            category: "ZTransfer")

/// Transfers all 'Z' records in .main store to .archive store.
/// Preserves 'fresh' zRoutines in .main store no older than thresholdSecs. Deletes those 'stale' ones earlier.
/// Safe to run on a background context.
/// NOTE: does NOT save context
public func transferToArchive(_ context: NSManagedObjectContext,
                              mainStore: NSPersistentStore,
                              archiveStore: NSPersistentStore,
                              thresholdSecs: TimeInterval,
                              now: Date = Date.now) throws
{
    logger.debug("\(#function)")

    let zRoutines = try deepCopy(context, fromStore: mainStore, toStore: archiveStore)

    let staleRecords = zRoutines.filter { !$0.isFresh(context, thresholdSecs: thresholdSecs, now: now) }

    // rely on cascading delete to remove children
    staleRecords.forEach { context.delete($0) }
}

/// Deep copy of all routines and their children from the source store to specified destination store
/// Returns list of ZRoutines in fromStore that have been copied.
/// Does not delete any records.
/// Safe to run on a background context.
/// Does NOT save context.
internal func deepCopy(_ context: NSManagedObjectContext,
                       fromStore srcStore: NSPersistentStore,
                       toStore dstStore: NSPersistentStore) throws -> [ZRoutine]
{
    logger.debug("\(#function)")
    var copiedZRoutines = [ZRoutine]()

    try context.fetcher(inStore: srcStore) { (sRoutine: ZRoutine) in

        let dRoutine = try sRoutine.shallowCopy(context, toStore: dstStore)

        let routinePred = ZExercise.getPredicate(zRoutine: sRoutine)

        // will need dExercise for creating dExerciseRun
        var dExerciseDict: [UUID: ZExercise] = [:]

        try context.fetcher(predicate: routinePred, inStore: srcStore) { (sExercise: ZExercise) in
            let dExercise = try sExercise.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

            if let uuid = dExercise.exerciseArchiveID {
                dExerciseDict[uuid] = dExercise
            } else {
                logger.error("Missing archiveID for zExercise \(sExercise.wrappedName)")
            }

            logger.debug("Copied zExercise \(sExercise.wrappedName)")

            return true
        }

        // NOTE: including even those ZRoutineRun records with userRemoved==1, as we need to reflect
        // removed records in the archive (which may have been previously copied as userRemoved=0)
        try context.fetcher(predicate: routinePred, inStore: srcStore) { (sRoutineRun: ZRoutineRun) in

            let dRoutineRun = try sRoutineRun.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

            let routineRunPred = ZExerciseRun.getPredicate(zRoutineRun: sRoutineRun)

            // NOTE: including even those ZExerciseRun records with userRemoved==1, as we need to reflect
            // removed records in the archive (which may have been previously copied as userRemoved=0)
            try context.fetcher(predicate: routineRunPred, inStore: srcStore) { (sExerciseRun: ZExerciseRun) in

                guard let exerciseArchiveID = sExerciseRun.zExercise?.exerciseArchiveID,
                      let dExercise = dExerciseDict[exerciseArchiveID]
                else {
                    logger.error("Could not determine exerciseArchiveID to obtain destination exercise")
                    return true
                }

                _ = try sExerciseRun.shallowCopy(context, dstRoutineRun: dRoutineRun, dstExercise: dExercise, toStore: dstStore)

                logger.debug("Copied zExerciseRun \(sExerciseRun.zExercise?.name ?? "") completedAt=\(String(describing: sExerciseRun.completedAt))")
                return true
            }

            logger.debug("Copied zRoutineRun \(sRoutine.wrappedName) startedAt=\(String(describing: sRoutineRun.startedAt))")
            return true
        }

        copiedZRoutines.append(sRoutine)
        logger.debug("Copied zRoutine \(sRoutine.wrappedName)")

        return true
    }

    return copiedZRoutines
}
