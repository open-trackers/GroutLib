//
//  ZExercise.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

/// Archive representation of a Exercise record
extension ZExercise {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext, zRoutine: ZRoutine, exerciseName: String, exerciseArchiveID: UUID, inStore: NSPersistentStore? = nil) -> ZExercise {
        let nu = ZExercise(context: context)
        nu.name = exerciseName
        nu.exerciseArchiveID = exerciseArchiveID
        nu.zRoutine = zRoutine
        if let inStore {
            context.assign(nu, to: inStore)
        }
        return nu
    }

    /// Shallow copy of self to specified store.
    /// NOTE assumes that routine is in dstStore.
    /// Does not delete self.
    /// Does NOT save context.
    func copy(_ context: NSManagedObjectContext, dstRoutine: ZRoutine, toStore dstStore: NSPersistentStore) throws {
        guard let exerciseArchiveID
        else { throw DataError.copyError(msg: "missing exerciseArchiveID") }
        let nu = ZExercise.create(context, zRoutine: dstRoutine, exerciseName: wrappedName, exerciseArchiveID: exerciseArchiveID)
        context.assign(nu, to: dstStore)
    }

    /// Copy each ZExercise to alternative store, where one doesn't already exist in that store.
    /// Does not delete records.
    /// Does NOT save context.
    /// May create ZRoutine record in destination store if doesn't already exist.
    /// Returns list of ids of objects copied from source store.
    static func copyAll(_ context: NSManagedObjectContext,
                        fromStore srcStore: NSPersistentStore,
                        toStore dstStore: NSPersistentStore) throws -> [NSManagedObjectID]
    {
        var copiedObjects = [NSManagedObjectID]()
        try context.fetcher(ZExercise.self, inStore: srcStore) { zExercise in
            guard let exerciseArchiveID = zExercise.exerciseArchiveID,
                  let routine = zExercise.zRoutine,
                  let routineArchiveID = routine.routineArchiveID
            else { throw DataError.missingArchiveID(msg: "For zExercise \(zExercise.wrappedName)'") }

            if try get(context, forArchiveID: exerciseArchiveID, inStore: dstStore) != nil {
                print("Found existing zExercise \(zExercise.wrappedName)")
                return true
            }

            // create ZRoutine record in destination store if doesn't already exist
            let nuRoutine = try ZRoutine.getOrCreate(context, routineArchiveID: routineArchiveID, routineName: routine.wrappedName, inStore: dstStore)

            try zExercise.copy(context, dstRoutine: nuRoutine, toStore: dstStore)

            copiedObjects.append(zExercise.objectID)
            print("Copied exercise \(zExercise.wrappedName)")

            return true
        }
        return copiedObjects
    }

    static func get(_ context: NSManagedObjectContext, forArchiveID exerciseArchiveID: UUID, inStore: NSPersistentStore? = nil) throws -> ZExercise? {
        let req = NSFetchRequest<ZExercise>(entityName: "ZExercise")
        req.predicate = NSPredicate(format: "exerciseArchiveID = %@", exerciseArchiveID.uuidString)
        req.returnsObjectsAsFaults = false
        if let inStore {
            req.affectedStores = [inStore]
        }

        do {
            let results = try context.fetch(req) as [ZExercise]
            return results.first
        } catch {
            throw DataError.fetchError(msg: error.localizedDescription)
        }
    }

    // NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext, zRoutine: ZRoutine, exerciseArchiveID: UUID, exerciseName: String, inStore: NSPersistentStore? = nil) throws -> ZExercise {
        if let zExercise = try ZExercise.get(context, forArchiveID: exerciseArchiveID, inStore: inStore) {
            // found existing zExercise
            return zExercise
        } else {
            return ZExercise.create(context, zRoutine: zRoutine, exerciseName: exerciseName, exerciseArchiveID: exerciseArchiveID, inStore: inStore)
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
