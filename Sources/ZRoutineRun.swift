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
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, zRoutine: ZRoutine, startedAt: Date, duration: Double) -> ZRoutineRun {
        let nu = ZRoutineRun(context: context)
        nu.zRoutine = zRoutine
        nu.startedAt = startedAt
        nu.duration = duration
        return nu
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
