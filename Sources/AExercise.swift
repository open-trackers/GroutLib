//
//  File.swift
//
//
//  Created by Reed Esau on 1/4/23.
//

import CoreData

/// Archive representation of a Exercise record
public extension AExercise {
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, aroutine: ARoutine, name: String, archiveID: UUID) -> AExercise {
        let nu = AExercise(context: context)
        nu.name = name
        nu.exerciseArchiveID = archiveID
        nu.aRoutine = aroutine
        return nu
    }

    static func get(_ context: NSManagedObjectContext, forArchiveID archiveID: UUID) throws -> AExercise? {
        let req = NSFetchRequest<AExercise>(entityName: "AExercise")
        req.predicate = NSPredicate(format: "exerciseArchiveID = %@", archiveID.uuidString)
        req.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(req) as [AExercise]
            return results.first
        } catch {
            let nserror = error as NSError
            throw DataError.fetchError(msg: nserror.localizedDescription)
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
