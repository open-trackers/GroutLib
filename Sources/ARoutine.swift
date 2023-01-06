//
//  File.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

/// Archive representation of a Routine record
extension ARoutine {
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, routineName: String, routineArchiveID: UUID) -> ARoutine {
        let nu = ARoutine(context: context)
        nu.name = routineName
        nu.routineArchiveID = routineArchiveID
        return nu
    }

    static func get(_ context: NSManagedObjectContext, forArchiveID routineArchiveID: UUID) throws -> ARoutine? {
        let req = NSFetchRequest<ARoutine>(entityName: "ARoutine")
        req.predicate = NSPredicate(format: "routineArchiveID = %@", routineArchiveID.uuidString)
        req.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(req) as [ARoutine]
            return results.first
        } catch {
            let nserror = error as NSError
            throw DataError.fetchError(msg: nserror.localizedDescription)
        }
    }

    // NOTE: does NOT save to context
    static func getOrCreate(_ context: NSManagedObjectContext, routineArchiveID: UUID, routineName: String) throws -> ARoutine {
        if let aroutine = try ARoutine.get(context, forArchiveID: routineArchiveID) {
            print(">>>> FOUND EXISTING AROUTINE")
            // found existing routine
            return aroutine
        } else {
            print(">>>> CREATING NEW AROUTINE")
            return ARoutine.create(context, routineName: routineName, routineArchiveID: routineArchiveID)
        }
    }

//    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> ARoutine? {
//        NSManagedObject.get(context, forURIRepresentation: url) as? ARoutine
//    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}
