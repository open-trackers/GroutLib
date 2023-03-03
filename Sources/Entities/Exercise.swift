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
        return nu
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}

internal extension Exercise {
    static func getPredicate(routineArchiveID: UUID, exerciseArchiveID: UUID) -> NSPredicate {
        NSPredicate(format: "routine.archiveID == %@ AND archiveID == %@", routineArchiveID.uuidString, exerciseArchiveID.uuidString)
    }
}
