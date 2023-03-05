//
//  ZRoutineRun.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension ZRoutineRun {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       zRoutine: ZRoutine,
                       startedAt: Date,
                       duration: Double = 0,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore) -> ZRoutineRun
    {
        let nu = ZRoutineRun(context: context)
        zRoutine.addToZRoutineRuns(nu)
        nu.createdAt = createdAt
        nu.startedAt = startedAt
        nu.duration = duration
        context.assign(nu, to: toStore)
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    internal func shallowCopy(_ context: NSManagedObjectContext,
                              dstRoutine: ZRoutine,
                              toStore dstStore: NSPersistentStore) throws -> ZRoutineRun
    {
        guard let startedAt
        else { throw TrackerError.missingData(msg: "startedAt; can't copy") }
        return try ZRoutineRun.getOrCreate(context,
                                           zRoutine: dstRoutine,
                                           startedAt: startedAt,
                                           // duration: duration,
                                           inStore: dstStore)
        { _, element in
            element.duration = duration
            element.createdAt = createdAt
            element.userRemoved = userRemoved
        }
    }

    static func get(_ context: NSManagedObjectContext,
                    routineArchiveID: UUID,
                    startedAt: Date,
                    inStore: NSPersistentStore? = nil) throws -> ZRoutineRun?
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, startedAt: startedAt)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    /// Fetch a ZRoutineRun record in the specified store, creating if necessary.
    /// Will update duration on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutine: ZRoutine,
                            startedAt: Date,
                            //                            duration: TimeInterval,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZRoutineRun) -> Void = { _, _ in }) throws -> ZRoutineRun
    {
        guard let archiveID = zRoutine.routineArchiveID
        else { throw TrackerError.missingData(msg: "ZRoutine.archiveID; can't get or create") }

        if let existing = try ZRoutineRun.get(context,
                                              routineArchiveID: archiveID,
                                              startedAt: startedAt,
                                              inStore: inStore)
        {
            //            nu.duration = duration
            onUpdate(true, existing)
            return existing
        } else {
            let nu = ZRoutineRun.create(context,
                                        zRoutine: zRoutine,
                                        startedAt: startedAt,
                                        // duration: duration,
                                        toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }

    static func count(_ context: NSManagedObjectContext,
                      predicate: NSPredicate? = nil,
                      inStore: NSPersistentStore? = nil) throws -> Int
    {
        try context.counter(ZRoutineRun.self, predicate: predicate, inStore: inStore)
    }

    // for use in user delete of individual routine runs in UI, from both stores
    static func delete(_ context: NSManagedObjectContext,
                       routineArchiveID: UUID,
                       startedAt: Date,
                       inStore: NSPersistentStore? = nil) throws
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, startedAt: startedAt)

        try context.fetcher(predicate: pred, inStore: inStore) { (element: ZRoutineRun) in
            context.delete(element)
            return true
        }

        // NOTE: wasn't working due to conflict errors, possibly due to to cascading delete?
        // try context.deleter(ZRoutineRun.self, predicate: pred, inStore: inStore)
    }

    /// Like a delete, but allows the mirroring to archive and iCloud to properly
    /// reflect that the user 'deleted' the record(s) from the store(s).
    static func userRemove(_ context: NSManagedObjectContext,
                           routineArchiveID: UUID,
                           startedAt: Date,
                           inStore: NSPersistentStore? = nil) throws
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, startedAt: startedAt)

        try context.fetcher(predicate: pred, inStore: inStore) { (element: ZRoutineRun) in
            element.userRemoved = true
            return true
        }
    }
}

internal extension ZRoutineRun {
    static func getPredicate(routineArchiveID: UUID,
                             startedAt: Date) -> NSPredicate
    {
        NSPredicate(format: "zRoutine.routineArchiveID = %@ AND startedAt == %@",
                    routineArchiveID.uuidString,
                    startedAt as NSDate)
    }
}

public extension ZRoutineRun {
    var zExerciseRunsArray: [ZExerciseRun] {
        (zExerciseRuns?.allObjects as? [ZExerciseRun]) ?? []
    }
}
