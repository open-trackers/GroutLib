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
                                            inStore: dstStore)
        { _, element in
            element.userRemoved = userRemoved
            element.intensity = intensity
            element.createdAt = createdAt
        }
    }
}

public extension ZExerciseRun {
    /// Like a delete, but allows the mirroring to archive and iCloud to properly
    /// reflect that the user 'deleted' the record(s) from the store(s).
    static func userRemove(_ context: NSManagedObjectContext,
                           exerciseArchiveID: UUID,
                           completedAt: Date,
                           inStore: NSPersistentStore? = nil) throws
    {
        let pred = getPredicate(exerciseArchiveID: exerciseArchiveID, completedAt: completedAt)
        let sort = byCreatedAt()
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZExerciseRun) in
            element.userRemoved = true
            return true
        }
    }
}
