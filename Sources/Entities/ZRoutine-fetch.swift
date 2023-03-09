//
//  ZRoutine-fetch.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

internal extension ZRoutine {
    static func getPredicate(routineArchiveID: UUID) -> NSPredicate {
        NSPredicate(format: "routineArchiveID == %@", routineArchiveID.uuidString)
    }
}

public extension ZRoutine {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZRoutine.createdAt, ascending: ascending),
        ]
    }
}

public extension ZRoutine {
    static func get(_ context: NSManagedObjectContext,
                    routineArchiveID: UUID,
                    inStore: NSPersistentStore? = nil) throws -> ZRoutine?
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID)
        let sort = byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort, inStore: inStore)
    }

    /// Fetch a ZRoutine record in the specified store, creating if necessary.
    /// Will update name on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            routineArchiveID: UUID,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZRoutine) -> Void = { _, _ in }) throws -> ZRoutine
    {
        if let existing = try ZRoutine.get(context, routineArchiveID: routineArchiveID, inStore: inStore) {
            onUpdate(true, existing)
            return existing
        } else {
            let nu = ZRoutine.create(context,
                                     routineArchiveID: routineArchiveID,
                                     toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }
}
