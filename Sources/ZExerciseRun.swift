//
//  ZExerciseRun.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

extension ZExerciseRun {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext, zExercise: ZExercise, completedAt: Date, intensity: Float, inStore: NSPersistentStore? = nil) -> ZExerciseRun {
        let nu = ZExerciseRun(context: context)
        nu.zExercise = zExercise
        nu.completedAt = completedAt
        nu.intensity = intensity
        if let inStore {
            context.assign(nu, to: inStore)
        }
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    func copy(_ context: NSManagedObjectContext, nuExercise: ZExercise, toStore nuStore: NSPersistentStore) throws -> ZExerciseRun {
        guard let completedAt
        else { throw DataError.copyError(msg: "missing completedAt") }
        let nu = ZExerciseRun.create(context, zExercise: nuExercise, completedAt: completedAt, intensity: intensity)
        context.assign(nu, to: nuStore)
        return nu
    }

    static func count(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil) throws -> Int {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "ZExerciseRun")
        if let predicate { req.predicate = predicate }
        return try context.count(for: req)
    }
}
