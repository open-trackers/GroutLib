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
    static func create(_ context: NSManagedObjectContext, routineName: String, routineArchiveID: UUID) -> ZRoutine {
        let nu = ZRoutine(context: context)
        nu.name = routineName
        nu.routineArchiveID = routineArchiveID
        return nu
    }
    
    /// Shallow copy of self to specified store.
    /// Does not delete self.
    /// Does NOT save context.
    func copy(_ context: NSManagedObjectContext, toStore nuStore: NSPersistentStore) throws {
        guard let routineArchiveID
        else { throw DataError.copyError(msg: "missing routineArchiveID") }
        let nu = ZRoutine.create(context, routineName: wrappedName, routineArchiveID: routineArchiveID)
        context.assign(nu, to: nuStore)
    }

    /// Copy each ZRoutine to archive, where one doesn't already exist.
    /// Does not delete self.
    /// Does NOT save context.
    static func copyAll(_ context: NSManagedObjectContext, fromStore mainStore: NSPersistentStore, toStore nuStore: NSPersistentStore) throws -> [NSManagedObjectID] {
        var copiedObjects = [NSManagedObjectID]()
        let req = NSFetchRequest<ZRoutine>(entityName: "ZRoutine")
        req.affectedStores = [mainStore]
        do {
            let results: [ZRoutine] = try context.fetch(req) as [ZRoutine]
            try results.forEach {
                try $0.copy(context, toStore: nuStore)
                copiedObjects.append($0.objectID)
            }
        } catch {
            throw DataError.fetchError(msg: error.localizedDescription)
        }
        return copiedObjects
    }
    
    static func get(_ context: NSManagedObjectContext, forArchiveID routineArchiveID: UUID) throws -> ZRoutine? {
        let req = NSFetchRequest<ZRoutine>(entityName: "ZRoutine")
        req.predicate = NSPredicate(format: "routineArchiveID = %@", routineArchiveID.uuidString)
        req.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(req) as [ZRoutine]
            return results.first
        } catch {
            throw DataError.fetchError(msg: error.localizedDescription)
        }
    }

    // NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext, routineArchiveID: UUID, routineName: String) throws -> ZRoutine {
        if let zRoutine = try ZRoutine.get(context, forArchiveID: routineArchiveID) {
            // found existing routine
            return zRoutine
        } else {
            return ZRoutine.create(context, routineName: routineName, routineArchiveID: routineArchiveID)
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
