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
public extension ZExercise {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext, zRoutine: ZRoutine, exerciseName: String, exerciseArchiveID: UUID, toStore: NSPersistentStore? = nil) -> ZExercise {
        let nu = ZExercise(context: context)
        nu.name = exerciseName
        nu.exerciseArchiveID = exerciseArchiveID
        nu.zRoutine = zRoutine
        if let toStore {
            context.assign(nu, to: toStore)
        }
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// NOTE assumes that routine is in dstStore.
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext, dstRoutine: ZRoutine, toStore dstStore: NSPersistentStore) throws -> ZExercise {
        guard let exerciseArchiveID
        else { throw DataError.missingData(msg: "exerciseArchiveID; can't copy") }
        let nu = try ZExercise.getOrCreate(context, zRoutine: dstRoutine, exerciseArchiveID: exerciseArchiveID, exerciseName: wrappedName, inStore: dstStore)
        return nu
    }

    static func get(_ context: NSManagedObjectContext, forArchiveID exerciseArchiveID: UUID, inStore: NSPersistentStore? = nil) throws -> ZExercise? {
        let pred = NSPredicate(format: "exerciseArchiveID = %@", exerciseArchiveID.uuidString)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    // NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext, zRoutine: ZRoutine, exerciseArchiveID: UUID, exerciseName: String, inStore: NSPersistentStore? = nil) throws -> ZExercise {
        if let nu = try ZExercise.get(context, forArchiveID: exerciseArchiveID, inStore: inStore) {
            return nu
        } else {
            return ZExercise.create(context, zRoutine: zRoutine, exerciseName: exerciseName, exerciseArchiveID: exerciseArchiveID, toStore: inStore)
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
