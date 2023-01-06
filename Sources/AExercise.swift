//
//  File.swift
//
//
//  Created by Reed Esau on 1/4/23.
//

import CoreData

/// Archive representation of a Exercise record
extension AExercise {
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, aroutine: ARoutine, name: String, archiveID: UUID) -> AExercise {
        let nu = AExercise(context: context)
        nu.name = name
        nu.exerciseArchiveID = archiveID
        nu.aRoutine = aroutine
        return nu
    }

    static func get(_ context: NSManagedObjectContext, forArchiveID exerciseArchiveID: UUID) throws -> AExercise? {
        let req = NSFetchRequest<AExercise>(entityName: "AExercise")
        req.predicate = NSPredicate(format: "exerciseArchiveID = %@", exerciseArchiveID.uuidString)
        req.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(req) as [AExercise]
            return results.first
        } catch {
            let nserror = error as NSError
            throw DataError.fetchError(msg: nserror.localizedDescription)
        }
    }

    // NOTE: does NOT save to context
    static func getOrCreate(_ context: NSManagedObjectContext, aroutine: ARoutine, exerciseArchiveID: UUID, exerciseName: String) throws -> AExercise {
        if let aexercise = try AExercise.get(context, forArchiveID: exerciseArchiveID) {
            print(">>>> FOUND EXISTING AEXERCISE")
            // found existing aexercise
            return aexercise
        } else {
            print(">>>> CREATING NEW AEXERCISE")
            return AExercise.create(context, aroutine: aroutine, name: exerciseName, archiveID: exerciseArchiveID)
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
