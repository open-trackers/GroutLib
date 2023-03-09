//
//  ZExercise-fetch.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension ZExercise {
    static func getPredicate(zRoutine: ZRoutine) -> NSPredicate {
        NSPredicate(format: "zRoutine == %@", zRoutine)
    }

    static func getPredicate(routineArchiveID: UUID,
                             exerciseArchiveID: UUID) -> NSPredicate
    {
        NSPredicate(format: "zRoutine.routineArchiveID == %@ AND exerciseArchiveID == %@",
                    routineArchiveID.uuidString,
                    exerciseArchiveID.uuidString)
    }
}

public extension ZExercise {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZExercise.createdAt, ascending: ascending),
        ]
    }
}

public extension ZExercise {
    static func get(_ context: NSManagedObjectContext,
                    routineArchiveID: UUID,
                    exerciseArchiveID: UUID,
                    inStore: NSPersistentStore? = nil) throws -> ZExercise?
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, exerciseArchiveID: exerciseArchiveID)
        let sort = byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort, inStore: inStore)
    }

    /// Fetch a ZExercise record in the specified store, creating if necessary.
    /// Will update name and units on existing record.
    /// Will NOT update ZRoutine on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutine: ZRoutine,
                            exerciseArchiveID: UUID,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZExercise) -> Void = { _, _ in }) throws -> ZExercise
    {
        if let routineArchiveID = zRoutine.routineArchiveID,
           let existing = try ZExercise.get(context,
                                            routineArchiveID: routineArchiveID,
                                            exerciseArchiveID: exerciseArchiveID,
                                            inStore: inStore)
        {
            onUpdate(true, existing)
            return existing
        } else {
            let nu = ZExercise.create(context,
                                      zRoutine: zRoutine,
                                      exerciseArchiveID: exerciseArchiveID,
                                      toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }
}
