//
//  ZRoutine.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

/// Archive representation of a Routine record
public extension ZRoutine {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       routineArchiveID: UUID,
                       routineName: String? = nil,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore) -> ZRoutine
    {
        let nu = ZRoutine(context: context)
        nu.createdAt = createdAt
        nu.name = routineName
        nu.routineArchiveID = routineArchiveID
        context.assign(nu, to: toStore)
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     toStore dstStore: NSPersistentStore) throws -> ZRoutine
    {
        guard let routineArchiveID
        else { throw TrackerError.missingData(msg: "routineArchiveID; can't copy") }
        return try ZRoutine.getOrCreate(context,
                                        routineArchiveID: routineArchiveID,
                                        inStore: dstStore)
        { _, element in
            element.name = wrappedName
            element.createdAt = createdAt
        }
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}

public extension ZRoutine {
    var zRoutineRunsArray: [ZRoutineRun] {
        (zRoutineRuns?.allObjects as? [ZRoutineRun]) ?? []
    }

    var zExercisesArray: [ZExercise] {
        (zExercises?.allObjects as? [ZExercise]) ?? []
    }
}
