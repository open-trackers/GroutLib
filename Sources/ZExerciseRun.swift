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
    static func create(_ context: NSManagedObjectContext, zExercise: ZExercise, completedAt: Date, intensity: Float) -> ZExerciseRun {
        let nu = ZExerciseRun(context: context)
        nu.zExercise = zExercise
        nu.completedAt = completedAt
        nu.intensity = intensity
        return nu
    }

    /// Shallow copy of self to specified store.
    /// Does not delete self.
    /// Does NOT save context.
    func copy(_ context: NSManagedObjectContext, nuExercise: ZExercise, toStore nuStore: NSPersistentStore) throws {
        guard let completedAt
        else { throw DataError.moveError(msg: "missing completedAt") }
        let nu = ZExerciseRun.create(context, zExercise: nuExercise, completedAt: completedAt, intensity: intensity)
        context.assign(nu, to: nuStore)
    }

    static func count(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil) throws -> Int {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "ZExerciseRun")
        if let predicate { req.predicate = predicate }
        return try context.count(for: req)
    }
}
