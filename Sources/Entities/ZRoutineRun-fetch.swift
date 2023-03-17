//
//  ZRoutineRun-fetch.swift
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
    static func getPredicate(userRemoved: Bool) -> NSPredicate {
        NSPredicate(format: "userRemoved == %@", NSNumber(value: userRemoved))
    }

    static func getPredicate(routineArchiveID: UUID,
                             startedAt: Date) -> NSPredicate
    {
        NSPredicate(format: "zRoutine.routineArchiveID = %@ AND startedAt == %@",
                    routineArchiveID.uuidString,
                    startedAt as NSDate)
    }
}

public extension ZRoutineRun {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZRoutineRun.createdAt, ascending: ascending),
        ]
    }

    static func byStartedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZRoutineRun.startedAt, ascending: ascending),
            NSSortDescriptor(keyPath: \ZRoutineRun.createdAt, ascending: true),
        ]
    }
}

public extension ZRoutineRun {
    static func get(_ context: NSManagedObjectContext,
                    routineArchiveID: UUID,
                    startedAt: Date,
                    inStore: NSPersistentStore? = nil) throws -> ZRoutineRun?
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, startedAt: startedAt)
        let sort = byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort, inStore: inStore)
    }

    /// Fetch a ZRoutineRun record in the specified store, creating if necessary.
    /// Will update duration on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutine: ZRoutine,
                            startedAt: Date,
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
            onUpdate(true, existing)
            return existing
        } else {
            let nu = ZRoutineRun.create(context,
                                        zRoutine: zRoutine,
                                        startedAt: startedAt,
                                        toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }

    static func getMostRecent(_ context: NSManagedObjectContext,
                              mainStore: NSPersistentStore) throws -> ZRoutineRun?
    {
        try context.firstFetcher(sortDescriptors: byStartedAt(ascending: false),
                                 inStore: mainStore)
    }

    static func count(_ context: NSManagedObjectContext,
                      predicate: NSPredicate? = nil,
                      inStore: NSPersistentStore? = nil) throws -> Int
    {
        try context.counter(ZRoutineRun.self, predicate: predicate, inStore: inStore)
    }
}
