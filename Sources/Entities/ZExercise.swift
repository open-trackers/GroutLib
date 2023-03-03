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
//                                           exerciseName: wrappedName,
//                                           exerciseUnits: Units(rawValue: units) ?? Units.none,
                                           inStore: dstStore) { _, element in
            element.name = wrappedName
            element.units = units
        }
        return nu
    }

    static func get(_ context: NSManagedObjectContext,
                    exerciseArchiveID: UUID,
                    inStore: NSPersistentStore? = nil) throws -> ZExercise?
    {
        let pred = NSPredicate(format: "exerciseArchiveID = %@", exerciseArchiveID.uuidString)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    /// Fetch a ZExercise record in the specified store, creating if necessary.
    /// Will update name and units on existing record.
    /// Will NOT update ZRoutine on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutine: ZRoutine,
                            exerciseArchiveID: UUID,
                            // exerciseName: String,
                            // exerciseUnits: Units,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZExercise) -> Void = { _, _ in }) throws -> ZExercise
    {
        if let existing = try ZExercise.get(context, exerciseArchiveID: exerciseArchiveID, inStore: inStore) {
//            nu.name = exerciseName
//            nu.units = exerciseUnits.rawValue
            onUpdate(true, existing)
            return existing
        } else {
            let nu = ZExercise.create(context,
                                      zRoutine: zRoutine,
//                                    exerciseName: exerciseName,
//                                    exerciseUnits: exerciseUnits,
                                      exerciseArchiveID: exerciseArchiveID,
                                      toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }

    var exerciseRunsArray: [ZExerciseRun] {
        (zExerciseRuns?.allObjects as? [ZExerciseRun]) ?? []
    }
}

internal extension ZExercise {
    /// NOTE does NOT filter for the userRemoved attribute!
    static func getPredicate(routineArchiveID: UUID,
                             exerciseArchiveID: UUID) -> NSPredicate
    {
        NSPredicate(format: "zRoutine.routineArchiveID == %@ AND exerciseArchiveID == %@",
                    routineArchiveID.uuidString,
                    exerciseArchiveID.uuidString)
    }
}
