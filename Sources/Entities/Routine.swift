//
//  Routine.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

@objc(Routine)
public class Routine: NSManagedObject {}

public extension Routine {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       userOrder: Int16,
                       name: String = "New Routine",
                       archiveID: UUID = UUID(),
                       createdAt: Date = Date.now) -> Routine
    {
        let nu = Routine(context: context)
        nu.createdAt = createdAt
        nu.userOrder = userOrder
        nu.name = name
        nu.archiveID = archiveID
        return nu
    }
}

public extension Routine {
    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }

    var exercisesArray: [Exercise] {
        (exercises?.allObjects as? [Exercise]) ?? []
    }
}

// public extension Routine {
//    var filteredPresets: ExercisePresetDict? {
//        exercisePresets
//    }
// }
