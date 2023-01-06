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

//    static func get(_ context: NSManagedObjectContext, forArchiveID archiveID: UUID) throws -> ZRoutineRun? {
//        let req = NSFetchRequest<ZRoutineRun>(entityName: "ZRoutineRun")
//        req.predicate = NSPredicate(format: "routineArchiveID = %@", archiveID.uuidString)
//        req.returnsObjectsAsFaults = false
//
//        do {
//            let ZRoutineRuns = try context.fetch(req) as [ZRoutineRun]
//            return ZRoutineRuns.first
//        } catch {
//            let nserror = error as NSError
//            throw DataError.fetchError(msg: nserror.localizedDescription)
//        }
//    }

//    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> ZRoutineRun? {
//        NSManagedObject.get(context, forURIRepresentation: url) as? ZRoutineRun
//    }

//    var wrappedName: String {
//        get { name ?? "unknown" }
//        set { name = newValue }
//    }
}
