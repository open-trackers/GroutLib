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
                  withAdvance: Bool,
                  routineStartedAt: Date,
                  now: Date = Date.now) throws
    {
        let intensity = lastIntensity
        let completedAt = now

        guard let routineArchiveID = routine?.archiveID,
              let routineName = routine?.name
//              case let zRoutine = try ZRoutine.getOrCreate(context,
//                                                  routineArchiveID: routineArchiveID,
//                                                  routineName: routineName),
//              let zRoutineRun = try ZRoutineRun.getOrCreate(context,
//                                                        zRoutine: zRoutine,
//                                                        startedAt: routineStartedAt,
//                                                        duration: duration)
        else {
            throw DataError.missingData(msg: "routine details; can't mark done")
        }

        if archiveID == nil { archiveID = UUID() }

        // log the run for charting
        _ = try Exercise.logRun(context,
                                routineArchiveID: routineArchiveID,
                                routineName: routineName,
                                routineStartedAt: routineStartedAt,
                                exerciseArchiveID: archiveID!,
                                exerciseName: wrappedName,
                                completedAt: completedAt,
                                intensity: intensity)

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
    /// NOTE: does not save context
    static func logRun(_ context: NSManagedObjectContext,
                       routineArchiveID: UUID,
                       routineName: String,
                       routineStartedAt: Date,
                       exerciseArchiveID: UUID,
                       exerciseName: String,
                       completedAt: Date,
                       intensity: Float) throws -> ZExerciseRun
    {
        guard let mainStore = PersistenceManager.getStore(context, .main)
        else {
            throw DataError.invalidStoreConfiguration(msg: "Cannot log exercise run.")
        }

        let zRoutine = try ZRoutine.getOrCreate(context, routineArchiveID: routineArchiveID, routineName: routineName, inStore: mainStore)

        // if not created, create a ZRoutineRun record, now that exercises are being marked as complete. (No need to create a ZRoutineRun record if no exercises completed.)
        let zRoutineRun = try ZRoutineRun.getOrCreate(context, zRoutine: zRoutine, startedAt: routineStartedAt, duration: 0)

        // extend the routine run's duration, in case app crashes or is killed
        zRoutineRun.duration = Date.now.timeIntervalSince(routineStartedAt)

        let zExercise = try ZExercise.getOrCreate(context, zRoutine: zRoutine, exerciseArchiveID: exerciseArchiveID, exerciseName: exerciseName, inStore: mainStore)

        return try ZExerciseRun.getOrCreate(context,
                                            zRoutineRun: zRoutineRun,
                                            zExercise: zExercise,
                                            completedAt: completedAt,
                                            intensity: intensity,
                                            inStore: mainStore)
    }
}
