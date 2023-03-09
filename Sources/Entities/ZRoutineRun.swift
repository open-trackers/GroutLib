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

public extension ZRoutineRun {
    var zExerciseRunsArray: [ZExerciseRun] {
        (zExerciseRuns?.allObjects as? [ZExerciseRun]) ?? []
    }
}
