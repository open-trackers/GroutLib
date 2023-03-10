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

        // NOTE that these may be replaced with defaults from AppSetting
        nu.units = defaultUnits
        nu.repetitions = defaultReps
        nu.lastIntensity = defaultIntensity
        nu.intensityStep = defaultIntensityStep
        nu.sets = defaultSets

        return nu
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}

public extension Exercise {
    static let intensityRange: ClosedRange<Float> = 0 ... 500
    static let intensityStepRange: ClosedRange<Float> = 0.1 ... 25
    static let settingRange: ClosedRange<Int16> = 0 ... 50

    static let defaultUnits: Int16 = 0
    static let defaultReps: Int16 = 12
    static let defaultIntensity: Float = 30
    static let defaultIntensityStep: Float = 5
    static let defaultSets: Int16 = 3
}

public extension Exercise {
    func updateFromAppSettings(_ context: NSManagedObjectContext) throws {
        let appSetting = try AppSetting.getOrCreate(context)
        lastIntensity = appSetting.defExIntensity
        intensityStep = appSetting.defExIntensityStep
        units = appSetting.defExUnits
        repetitions = appSetting.defExReps
        sets = appSetting.defExSets
    }
}
