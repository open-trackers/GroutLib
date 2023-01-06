//
//  File.swift
//
//
//  Created by Reed Esau on 1/3/23.
//

import CoreData

/// Archive representation of a Routine record
public extension ARoutine {
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, name: String, archiveID: UUID) -> ARoutine {
        let nu = ARoutine(context: context)
        nu.name = name
        nu.routineArchiveID = archiveID
        return nu
    }

    static func get(_ context: NSManagedObjectContext, forArchiveID archiveID: UUID) throws -> ARoutine? {
        let req = NSFetchRequest<ARoutine>(entityName: "ARoutine")
        req.predicate = NSPredicate(format: "routineArchiveID = %@", archiveID.uuidString)
        req.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(req) as [ARoutine]
            return results.first
        } catch {
            let nserror = error as NSError
            throw DataError.fetchError(msg: nserror.localizedDescription)
        }
    }

    static func getOrCreate(_ context: NSManagedObjectContext, archiveID: UUID, name: String) throws -> ARoutine {
        if let aroutine = try ARoutine.get(context, forArchiveID: archiveID) {
            print(">>>> FOUND EXISTING AROUTINE")
            // found existing routine
            return aroutine
        } else {
            print(">>>> CREATING NEW AROUTINE")
            return ARoutine.create(context, name: name, archiveID: archiveID)
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
