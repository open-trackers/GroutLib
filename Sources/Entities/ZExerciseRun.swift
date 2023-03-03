//
//  ZExerciseRun.swift
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
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       zRoutineRun: ZRoutineRun,
                       zExercise: ZExercise,
                       completedAt: Date,
                       intensity: Float = 0,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore) -> ZExerciseRun
    {
        let nu = ZExerciseRun(context: context)
        zRoutineRun.addToZExerciseRuns(nu)
        zExercise.addToZExerciseRuns(nu)
        nu.createdAt = createdAt
        nu.completedAt = completedAt
        nu.intensity = intensity
        context.assign(nu, to: toStore)
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     dstRoutineRun: ZRoutineRun,
                     dstExercise: ZExercise,
                     toStore dstStore: NSPersistentStore) throws -> ZExerciseRun
    {
        guard let completedAt
        else { throw TrackerError.missingData(msg: "completedAt not present; can't copy") }
        return try ZExerciseRun.getOrCreate(context,
                                            zRoutineRun: dstRoutineRun,
                                            zExercise: dstExercise,
                                            completedAt: completedAt,
                                            // intensity: intensity,
                                            inStore: dstStore) { _, element in
            element.userRemoved = userRemoved
            element.intensity = intensity
            element.createdAt = createdAt
        }
    }

    static func get(_ context: NSManagedObjectContext,
                    exerciseArchiveID: UUID,
                    completedAt: Date,
                    inStore: NSPersistentStore? = nil) throws -> ZExerciseRun?
    {
        let pred = getPredicate(exerciseArchiveID: exerciseArchiveID, completedAt: completedAt)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    /// Fetch a ZExerciseRun record in the specified store, creating if necessary.
    /// Will update intensity on existing record.
    /// Will NOT update ZRoutineRun on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutineRun: ZRoutineRun,
                            zExercise: ZExercise,
                            completedAt: Date,
                            // intensity: Float,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZExerciseRun) -> Void = { _, _ in }) throws -> ZExerciseRun
    {
        guard let exerciseArchiveID = zExercise.exerciseArchiveID
        else { throw TrackerError.missingData(msg: "ZExercise.archiveID; can't get or create") }

        if let existing = try ZExerciseRun.get(context, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: inStore) {
            // nu.intensity = intensity
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

    // for use in user delete of individual exercise runs in UI, from both stores
    static func delete(_ context: NSManagedObjectContext,
                       exerciseArchiveID: UUID,
                       completedAt: Date,
                       inStore: NSPersistentStore? = nil) throws
    {
        let pred = getPredicate(exerciseArchiveID: exerciseArchiveID, completedAt: completedAt)

        try context.fetcher(predicate: pred, inStore: inStore) { (element: ZExerciseRun) in
            context.delete(element)
            return true
        }

        // NOTE: wasn't working due to conflict errors, possibly due to to cascading delete?
        // try context.deleter(ZExerciseRun.self, predicate: pred, inStore: inStore)
    }
}

internal extension ZExerciseRun {
    static func getPredicate(exerciseArchiveID: UUID,
                             completedAt: Date) -> NSPredicate
    {
        NSPredicate(format: "zExercise.exerciseArchiveID = %@ AND completedAt == %@",
                    exerciseArchiveID.uuidString,
                    completedAt as NSDate)
    }
}
