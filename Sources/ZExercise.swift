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
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, zRoutine: ZRoutine, exerciseName: String, exerciseArchiveID: UUID) -> ZExercise {
        let nu = ZExercise(context: context)
        nu.name = exerciseName
        nu.exerciseArchiveID = exerciseArchiveID
        nu.zRoutine = zRoutine
        return nu
    }

    static func get(_ context: NSManagedObjectContext, forArchiveID exerciseArchiveID: UUID) throws -> ZExercise? {
        let req = NSFetchRequest<ZExercise>(entityName: "ZExercise")
        req.predicate = NSPredicate(format: "exerciseArchiveID = %@", exerciseArchiveID.uuidString)
        req.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(req) as [ZExercise]
            return results.first
        } catch let error as NSError {
            throw DataError.fetchError(msg: error.localizedDescription)
        }
    }

    // NOTE: does NOT save to context
    static func getOrCreate(_ context: NSManagedObjectContext, zRoutine: ZRoutine, exerciseArchiveID: UUID, exerciseName: String) throws -> ZExercise {
        if let zExercise = try ZExercise.get(context, forArchiveID: exerciseArchiveID) {
            // found existing zExercise
            return zExercise
        } else {
            return ZExercise.create(context, zRoutine: zRoutine, exerciseName: exerciseName, exerciseArchiveID: exerciseArchiveID)
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
