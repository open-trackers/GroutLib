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
public extension ZRoutine {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       routineName: String,
                       routineArchiveID: UUID,
                       toStore: NSPersistentStore? = nil) -> ZRoutine
    {
        let nu = ZRoutine(context: context)
        nu.name = routineName
        nu.routineArchiveID = routineArchiveID
        if let toStore {
            context.assign(nu, to: toStore)
        }
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     toStore dstStore: NSPersistentStore) throws -> ZRoutine
    {
        guard let routineArchiveID
        else { throw DataError.missingData(msg: "routineArchiveID; can't copy") }
        return try ZRoutine.getOrCreate(context, routineArchiveID: routineArchiveID, routineName: wrappedName, inStore: dstStore)
    }

    static func get(_ context: NSManagedObjectContext,
                    forArchiveID routineArchiveID: UUID,
                    inStore: NSPersistentStore? = nil) throws -> ZRoutine?
    {
        let pred = NSPredicate(format: "routineArchiveID = %@", routineArchiveID.uuidString)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    // NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            routineArchiveID: UUID,
                            routineName: String,
                            inStore: NSPersistentStore? = nil) throws -> ZRoutine
    {
        if let nu = try ZRoutine.get(context, forArchiveID: routineArchiveID, inStore: inStore) {
            return nu
        } else {
            return ZRoutine.create(context, routineName: routineName, routineArchiveID: routineArchiveID, toStore: inStore)
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
