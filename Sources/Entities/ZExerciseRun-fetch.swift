//
//  ZExerciseRun-fetch.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension ZExerciseRun {
    static func getPredicate(zRoutineRun: ZRoutineRun) -> NSPredicate {
        NSPredicate(format: "zRoutineRun == %@", zRoutineRun)
    }

    static func getPredicate(zRoutineRun: ZRoutineRun,
                             userRemoved: Bool) -> NSPredicate
    {
        NSPredicate(format: "zRoutineRun == %@ AND userRemoved == %@", zRoutineRun, NSNumber(value: userRemoved))
    }

    static func getPredicate(exerciseArchiveID: UUID,
                             completedAt: Date) -> NSPredicate
    {
        NSPredicate(format: "zExercise.exerciseArchiveID = %@ AND completedAt == %@",
                    exerciseArchiveID as NSUUID,
                    completedAt as NSDate)
    }
}

public extension ZExerciseRun {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZExerciseRun.createdAt, ascending: ascending),
        ]
    }

    static func byCompletedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZExerciseRun.completedAt, ascending: ascending),
            NSSortDescriptor(keyPath: \ZExerciseRun.createdAt, ascending: true),
        ]
    }
}

extension ZExerciseRun {
    static func get(_ context: NSManagedObjectContext,
                    exerciseArchiveID: UUID,
                    completedAt: Date,
                    inStore: NSPersistentStore? = nil) throws -> ZExerciseRun?
    {
        let pred = getPredicate(exerciseArchiveID: exerciseArchiveID, completedAt: completedAt)
        let sort = byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort, inStore: inStore)
    }

    /// Fetch a ZExerciseRun record in the specified store, creating if necessary.
    /// Will update intensity on existing record.
    /// Will NOT update ZRoutineRun on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutineRun: ZRoutineRun,
                            zExercise: ZExercise,
                            completedAt: Date,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZExerciseRun) -> Void = { _, _ in }) throws -> ZExerciseRun
    {
        guard let exerciseArchiveID = zExercise.exerciseArchiveID
        else { throw TrackerError.missingData(msg: "ZExercise.archiveID; can't get or create") }

        if let existing = try ZExerciseRun.get(context, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: inStore) {
            onUpdate(true, existing)
            return existing
        } else {
            let nu = ZExerciseRun.create(context, zRoutineRun: zRoutineRun, zExercise: zExercise, completedAt: completedAt, toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }

    static func count(_ context: NSManagedObjectContext,
                      predicate: NSPredicate? = nil,
                      inStore: NSPersistentStore? = nil) throws -> Int
    {
        try context.counter(ZExerciseRun.self, predicate: predicate, inStore: inStore)
    }
}
