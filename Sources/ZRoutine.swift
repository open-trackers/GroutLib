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

/// Archive representation of a Routine record
extension ZRoutine {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext, routineName: String, routineArchiveID: UUID, inStore: NSPersistentStore? = nil) -> ZRoutine {
        let nu = ZRoutine(context: context)
        nu.name = routineName
        nu.routineArchiveID = routineArchiveID
        if let inStore {
            context.assign(nu, to: inStore)
        }
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext, toStore dstStore: NSPersistentStore) throws -> ZRoutine {
        guard let routineArchiveID
        else { throw DataError.copyError(msg: "missing routineArchiveID") }
        let nu = ZRoutine.create(context, routineName: wrappedName, routineArchiveID: routineArchiveID)
        context.assign(nu, to: dstStore)
        return nu
    }

    /// Copy each ZRoutine to alternative store, where one doesn't already exist in that store.
    /// Does not delete records.
    /// Does NOT save context.
    /// Returns list of ids of objects copied from source store.
    static func copyAll(_ context: NSManagedObjectContext,
                        fromStore srcStore: NSPersistentStore,
                        toStore dstStore: NSPersistentStore) throws -> [NSManagedObjectID]
    {
        var copiedObjects = [NSManagedObjectID]()
        try context.fetcher(ZRoutine.self, inStore: srcStore) { zRoutine in
            guard let routineArchiveID = zRoutine.routineArchiveID
            else { throw DataError.missingArchiveID(msg: "For zRoutine \(zRoutine.wrappedName)'") }

            if try get(context, forArchiveID: routineArchiveID, inStore: dstStore) != nil {
                print("Found existing zRoutine \(zRoutine.wrappedName)")
                return true
            }

            _ = try zRoutine.shallowCopy(context, toStore: dstStore)

            copiedObjects.append(zRoutine.objectID)
            print("Copied routine \(zRoutine.wrappedName)")

            return true
        }
        return copiedObjects
    }

    static func get(_ context: NSManagedObjectContext, forArchiveID routineArchiveID: UUID, inStore: NSPersistentStore? = nil) throws -> ZRoutine? {
        let pred = NSPredicate(format: "routineArchiveID = %@", routineArchiveID.uuidString)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    // NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext, routineArchiveID: UUID, routineName: String, inStore: NSPersistentStore? = nil) throws -> ZRoutine {
        if let zRoutine = try ZRoutine.get(context, forArchiveID: routineArchiveID, inStore: inStore) {
            // found existing routine
            return zRoutine
        } else {
            return ZRoutine.create(context, routineName: routineName, routineArchiveID: routineArchiveID, inStore: inStore)
        }
    }

//    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> ZRoutine? {
//        NSManagedObject.get(context, forURIRepresentation: url) as? ZRoutine
//    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}
