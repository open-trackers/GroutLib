//
//  ZRoutine.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

/// Archive representation of a Routine record
public extension ZRoutine {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       routineName: String? = nil,
                       routineArchiveID: UUID,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore) -> ZRoutine
    {
        let nu = ZRoutine(context: context)
        nu.createdAt = createdAt
        nu.name = routineName
        nu.routineArchiveID = routineArchiveID
        context.assign(nu, to: toStore)
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     toStore dstStore: NSPersistentStore) throws -> ZRoutine
    {
        guard let routineArchiveID
        else { throw TrackerError.missingData(msg: "routineArchiveID; can't copy") }
        return try ZRoutine.getOrCreate(context,
                                        routineArchiveID: routineArchiveID,
                                        // routineName: wrappedName,
                                        inStore: dstStore) { _, element in
            element.name = wrappedName
        }
    }

    static func get(_ context: NSManagedObjectContext,
                    routineArchiveID: UUID,
                    inStore: NSPersistentStore? = nil) throws -> ZRoutine?
    {
        let pred = NSPredicate(format: "routineArchiveID = %@", routineArchiveID.uuidString)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    /// Fetch a ZRoutine record in the specified store, creating if necessary.
    /// Will update name on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            routineArchiveID: UUID,
                            // routineName: String,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZRoutine) -> Void = { _, _ in }) throws -> ZRoutine
    {
        if let existing = try ZRoutine.get(context, routineArchiveID: routineArchiveID, inStore: inStore) {
            onUpdate(true, existing)
            // nu.name = routineName
            return existing
        } else {
            let nu = ZRoutine.create(context,
                                     // routineName: routineName,
                                     routineArchiveID: routineArchiveID,
                                     toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}
