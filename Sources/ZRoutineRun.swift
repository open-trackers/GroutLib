//
//  ZRoutineRun.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

public extension ZRoutineRun {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext, zRoutine: ZRoutine, startedAt: Date, duration: Double, inStore: NSPersistentStore? = nil) -> ZRoutineRun {
        let nu = ZRoutineRun(context: context)
        nu.zRoutine = zRoutine
        nu.startedAt = startedAt
        nu.duration = duration
        if let inStore {
            context.assign(nu, to: inStore)
        }
        return nu
    }

    /// Shallow copy of self to specified store.
    /// Does not delete self.
    /// Does NOT save context.
    func copy(_ context: NSManagedObjectContext, nuRoutine: ZRoutine, toStore nuStore: NSPersistentStore) throws {
        guard let startedAt
        else { throw DataError.copyError(msg: "missing startedAt") }
        let nu = ZRoutineRun.create(context, zRoutine: nuRoutine, startedAt: startedAt, duration: duration)
        context.assign(nu, to: nuStore)
    }

    static func count(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil) throws -> Int {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "ZRoutineRun")
        if let predicate { req.predicate = predicate }
        return try context.count(for: req)
    }

//    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> ZRoutineRun? {
//        NSManagedObject.get(context, forURIRepresentation: url) as? ZRoutineRun
//    }

//    var wrappedName: String {
//        get { name ?? "unknown" }
//        set { name = newValue }
//    }
}
