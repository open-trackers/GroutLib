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

import TrackerLib

@objc(Exercise)
public class Exercise: NSManagedObject {}

extension Exercise: UserOrdered {}

public extension Exercise {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       routine: Routine,
                       userOrder: Int16,
                       name: String = "New Exercise",
                       archiveID: UUID = UUID(),
                       createdAt: Date = Date.now) -> Exercise
    {
        let nu = Exercise(context: context)
        routine.addToExercises(nu)
        nu.createdAt = createdAt
        nu.userOrder = userOrder
        nu.name = name
        nu.archiveID = archiveID
        return nu
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}

public extension Exercise {
    static func maxUserOrder(_ context: NSManagedObjectContext, routine: Routine) throws -> Int16? {
        var sort: [NSSortDescriptor] {
            [NSSortDescriptor(keyPath: \Exercise.userOrder, ascending: false)]
        }
        let pred = NSPredicate(format: "routine == %@", routine)
        let exercise: Exercise? = try context.firstFetcher(predicate: pred, sortDescriptors: sort)
        return exercise?.userOrder
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
    func formattedIntensity(_ intensityValue: Float, withUnits: Bool = false) -> String {
        let units = Units(rawValue: units) ?? .none
        return formatIntensity(intensityValue,
                               units: units,
                               withUnits: withUnits,
                               isFractional: isIntensityFractional)
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

extension Exercise {
    /// log the run of the exercise to the main store
    /// (These will later be transferred to the archive store on iOS devices)
    /// NOTE: does NOT save context
    func logCompletion(_ context: NSManagedObjectContext,
                       mainStore: NSPersistentStore,
                       routineStartedAt: Date,
                       nuDuration: TimeInterval,
                       exerciseCompletedAt: Date,
                       exerciseIntensity: Float) throws
    {
        guard let routine else {
            throw TrackerError.missingData(msg: "Unexpectedly no routine. Cannot log exercise run.")
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
                                                // routineName: routine.wrappedName,
                                                inStore: mainStore) { _, element in
            element.name = routine.wrappedName
        }

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
                                                  // exerciseName: wrappedName,
                                                  // exerciseUnits: Units(rawValue: units) ?? .none,
                                                  inStore: mainStore) { _, element in
            element.name = wrappedName
            element.units = units
        }

        let zRoutineRun = try ZRoutineRun.getOrCreate(context,
                                                      zRoutine: zRoutine,
                                                      startedAt: routineStartedAt,
                                                      // duration: nuDuration,
                                                      inStore: mainStore) { _, element in
            element.duration = nuDuration
        }

        _ = try ZExerciseRun.getOrCreate(context,
                                         zRoutineRun: zRoutineRun,
                                         zExercise: zExercise,
                                         completedAt: exerciseCompletedAt,
                                         // intensity: exerciseIntensity,
                                         inStore: mainStore) { _, element in
            element.intensity = exerciseIntensity
        }
    }
}

extension Exercise: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case archiveID
        case intensityStep
        case invertedIntensity
        case lastCompletedAt
        case lastIntensity
        case name
        case primarySetting
        case repetitions
        case secondarySetting
        case sets
        case units
        case userOrder
        case createdAt
        case routineArchiveID // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(archiveID, forKey: .archiveID)
        try c.encode(intensityStep, forKey: .intensityStep)
        try c.encode(invertedIntensity, forKey: .invertedIntensity)
        try c.encode(lastCompletedAt, forKey: .lastCompletedAt)
        try c.encode(lastIntensity, forKey: .lastIntensity)
        try c.encode(name, forKey: .name)
        try c.encode(primarySetting, forKey: .primarySetting)
        try c.encode(repetitions, forKey: .repetitions)
        try c.encode(secondarySetting, forKey: .secondarySetting)
        try c.encode(sets, forKey: .sets)
        try c.encode(units, forKey: .units)
        try c.encode(userOrder, forKey: .userOrder)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(routine?.archiveID, forKey: .routineArchiveID)
    }
}

extension Exercise: MAttributable {
    public static var fileNamePrefix: String {
        "exercises"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.archiveID, .string),
        MAttribute(CodingKeys.intensityStep, .double),
        MAttribute(CodingKeys.invertedIntensity, .bool),
        MAttribute(CodingKeys.lastCompletedAt, .date),
        MAttribute(CodingKeys.lastIntensity, .double),
        MAttribute(CodingKeys.name, .string),
        MAttribute(CodingKeys.primarySetting, .int),
        MAttribute(CodingKeys.repetitions, .int),
        MAttribute(CodingKeys.secondarySetting, .int),
        MAttribute(CodingKeys.sets, .int),
        MAttribute(CodingKeys.units, .int),
        MAttribute(CodingKeys.userOrder, .int),
        MAttribute(CodingKeys.createdAt, .date),
        MAttribute(CodingKeys.routineArchiveID, .string),
    ]
}
