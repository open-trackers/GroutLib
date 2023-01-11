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

@objc(Exercise)
public class Exercise: NSManagedObject {}

extension Exercise: UserOrdered {}

public extension Exercise {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext, userOrder: Int16) -> Exercise {
        let nu = Exercise(context: context)
        nu.userOrder = userOrder
        nu.name = "New Exercise"
        nu.archiveID = UUID()
        return nu
    }

    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> Exercise? {
        NSManagedObject.get(context, forURIRepresentation: url) as? Exercise
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}

public extension Exercise {
    /// true if both intensity and its step are whole numbers (or close to it)
    private var isIntensityFractional: Bool {
        let accuracy: Float = 0.1
        return
            isFractional(value: intensityStep, accuracy: accuracy) ||
            isFractional(value: lastIntensity, accuracy: accuracy)
    }

    var isDone: Bool {
        lastCompletedAt != nil
    }

    /// Format an intensity value, such as lastIntensity and intensityStep, with optional units
    func formatIntensity(_ intensityValue: Float, withUnits: Bool = false) -> String {
        let suffix: String = {
            guard withUnits,
                  let units = Units(rawValue: self.units),
                  units != .none
            else { return "" }
            let abbrev = units.abbreviation
            return " \(abbrev)"
        }()
        let specifier = "%0.\(isIntensityFractional ? 1 : 0)f\(suffix)"
        return String(format: specifier, intensityValue)
    }
}

public extension Exercise {
    static var intensityMaxValue: Float = 500.0

    var advancedIntensity: Float {
        if invertedIntensity {
            // advance downwards
            return max(0, lastIntensity - intensityStep)
        } else {
            // advance upwards
            return min(Exercise.intensityMaxValue, lastIntensity + intensityStep)
        }
    }

    // NOTE: does NOT save context
    func markDone(_ context: NSManagedObjectContext,
                  completedAt: Date,
                  withAdvance: Bool,
                  routineStartedAt: Date,
                  logToHistory: Bool) throws
    {
        // extend the routine run's duration, in case app crashes or is killed
        let nuDuration = completedAt.timeIntervalSince(routineStartedAt)

        // The ZRoutineRun has at least one completed exercise, so update the
        // Routine with the latest data, even if we're not logging to history
        routine?.lastStartedAt = routineStartedAt
        routine?.lastDuration = nuDuration

        // Log the completion of the exercise for the historical record.
        // NOTE: can update Routine and create/update ZRoutine, ZRoutineRun, and ZExerciseRun.
        if logToHistory {
            try logCompletion(context,
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

extension Exercise {
    /// log the run of the exercise to the main store
    /// (These will later be transferred to the archive store on iOS devices)
    /// NOTE: does NOT save context
    func logCompletion(_ context: NSManagedObjectContext,
                       routineStartedAt: Date,
                       nuDuration: TimeInterval,
                       exerciseCompletedAt: Date,
                       exerciseIntensity: Float) throws
    {
        guard let mainStore = PersistenceManager.getStore(context, .main)
        else {
            throw DataError.invalidStoreConfiguration(msg: "Cannot log exercise run.")
        }

        guard let routine else {
            throw DataError.missingData(msg: "Unexpectedly no routine. Cannot log exercise run.")
        }

        // Get corresponding ZRoutine for log, creating if necessary.
        let routineArchiveID: UUID = {
            if routine.archiveID == nil {
                routine.archiveID = UUID()
            }
            return routine.archiveID!
        }()
        let zRoutine = try ZRoutine.getOrCreate(context,
                                                routineArchiveID: routineArchiveID,
                                                routineName: routine.wrappedName,
                                                inStore: mainStore)

        // Get corresponding ZExercise for log, creating if necessary.
        let exerciseArchiveID: UUID = {
            if self.archiveID == nil {
                self.archiveID = UUID()
            }
            return self.archiveID!
        }()
        let zExercise = try ZExercise.getOrCreate(context,
                                                  zRoutine: zRoutine,
                                                  exerciseArchiveID: exerciseArchiveID,
                                                  exerciseName: wrappedName,
                                                  inStore: mainStore)

        let zRoutineRun = try ZRoutineRun.getOrCreate(context,
                                                      zRoutine: zRoutine,
                                                      startedAt: routineStartedAt,
                                                      duration: nuDuration,
                                                      inStore: mainStore)

        _ = try ZExerciseRun.getOrCreate(context,
                                         zRoutineRun: zRoutineRun,
                                         zExercise: zExercise,
                                         completedAt: exerciseCompletedAt,
                                         intensity: exerciseIntensity,
                                         inStore: mainStore)
    }
}
