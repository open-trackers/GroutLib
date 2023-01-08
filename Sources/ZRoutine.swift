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

    /// Deep copy of all routines and their children from the source store to specified destination store
    /// Returning list of the objectIDs of the records copied FROM the SOURCE store.
    /// Does not delete any records.
    /// Does NOT save context.
    static func deepCopy(_ context: NSManagedObjectContext,
                         fromStore srcStore: NSPersistentStore,
                         toStore dstStore: NSPersistentStore) throws -> [NSManagedObjectID]
    {
        var copiedObjects = [NSManagedObjectID]()

        // recursively copy the routine and its children to the archive
        try context.fetcher(ZRoutine.self, inStore: srcStore) { zRoutine in

            let dRoutine = try zRoutine.shallowCopy(context, toStore: dstStore)

            let routinePred = NSPredicate(format: "zRoutine = %@", zRoutine)

            try context.fetcher(ZRoutineRun.self, predicate: routinePred, inStore: srcStore) { zRoutineRun in

                _ = try zRoutineRun.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

                copiedObjects.append(zRoutineRun.objectID)
                print("Copied zRoutineRun \(zRoutine.wrappedName) startedAt=\(String(describing: zRoutineRun.startedAt))")
                return true
            }

            try context.fetcher(ZExercise.self, predicate: routinePred, inStore: srcStore) { zExercise in

                let dExercise = try zExercise.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

                let exercisePred = NSPredicate(format: "zExercise = %@", zExercise)

                try context.fetcher(ZExerciseRun.self, predicate: exercisePred, inStore: srcStore) { zExerciseRun in

                    _ = try zExerciseRun.shallowCopy(context, dstExercise: dExercise, toStore: dstStore)

                    copiedObjects.append(zExerciseRun.objectID)
                    print("Copied zExerciseRun \(zExercise.wrappedName) completedAt=\(String(describing: zExerciseRun.completedAt))")
                    return true
                }

                copiedObjects.append(zExercise.objectID)
                print("Copied zExercise \(zExercise.wrappedName)")

                return true
            }

            copiedObjects.append(zRoutine.objectID)
            print("Copied zRoutine \(zRoutine.wrappedName)")

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
