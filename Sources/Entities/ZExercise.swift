//
//  ZExercise.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

/// Archive representation of a Exercise record
public extension ZExercise {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       zRoutine: ZRoutine,
                       exerciseArchiveID: UUID,
                       exerciseName: String? = nil,
                       exerciseUnits: Units = Units.none,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore) -> ZExercise
    {
        let nu = ZExercise(context: context)
        zRoutine.addToZExercises(nu)
        nu.createdAt = createdAt
        nu.name = exerciseName
        nu.units = exerciseUnits.rawValue
        nu.exerciseArchiveID = exerciseArchiveID
        context.assign(nu, to: toStore)
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// NOTE assumes that routine is in dstStore.
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     dstRoutine: ZRoutine,
                     toStore dstStore: NSPersistentStore) throws -> ZExercise
    {
        guard let exerciseArchiveID
        else { throw TrackerError.missingData(msg: "exerciseArchiveID; can't copy") }
        let nu = try ZExercise.getOrCreate(context,
                                           zRoutine: dstRoutine,
                                           exerciseArchiveID: exerciseArchiveID,
                                           inStore: dstStore)
        { _, element in
            element.name = wrappedName
            element.units = units
            element.createdAt = createdAt
        }
        return nu
    }
}

public extension ZExercise {
    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }

    var exerciseRunsArray: [ZExerciseRun] {
        (zExerciseRuns?.allObjects as? [ZExerciseRun]) ?? []
    }
}
