//
//  Exercise-markDone.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension Exercise {
    var advancedIntensity: Float {
        if invertedIntensity {
            // advance downwards
            return max(0, lastIntensity - intensityStep)
        } else {
            // advance upwards
            return min(Exercise.intensityRange.upperBound, lastIntensity + intensityStep)
        }
    }

    // NOTE: does NOT save context
    func markDone(_ context: NSManagedObjectContext,
                  mainStore: NSPersistentStore,
                  completedAt: Date = Date.now,
                  withAdvance: Bool,
                  routineStartedAt: Date,
                  logToHistory: Bool) throws
    {
        guard let routine else {
            throw TrackerError.missingData(msg: "Unexpectedly no routine. Cannot mark exercise done.")
        }

        // extend the routine run's duration, in case app crashes or is killed
        let nuDuration = completedAt.timeIntervalSince(routineStartedAt)

        // The ZRoutineRun has at least one completed exercise, so update the
        // Routine with the latest data, even if we're not logging to history.
        // NOTE: in transferToArchive, this timestamp will also determine if
        //       corresponding ZRoutine is purged from main store.
        routine.lastStartedAt = routineStartedAt
        routine.lastDuration = nuDuration

        // Log the completion of the exercise for the historical record.
        // NOTE: can update Routine and create/update ZRoutine, ZRoutineRun, and ZExerciseRun.
        if logToHistory {
            try logCompletion(context,
                              mainStore: mainStore,
                              routineStartedAt: routineStartedAt,
                              nuDuration: nuDuration,
                              exerciseCompletedAt: completedAt,
                              exerciseIntensity: lastIntensity)
        }

        // update the attributes with fresh data
        if withAdvance {
            lastIntensity = advancedIntensity
        }
        lastCompletedAt = completedAt
    }
}
