//
//  File.swift
//
//
//  Created by Reed Esau on 1/3/23.
//

import CoreData

public extension ARoutineRun {
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, aroutine: ARoutine, startedAt: Date, duration: Double) -> ARoutineRun {
        let nu = ARoutineRun(context: context)
        nu.aRoutine = aroutine
        nu.startedAt = startedAt
        nu.duration = duration
        return nu
    }

//    static func get(_ context: NSManagedObjectContext, forArchiveID archiveID: UUID) throws -> ARoutineRun? {
//        let req = NSFetchRequest<ARoutineRun>(entityName: "ARoutineRun")
//        req.predicate = NSPredicate(format: "routineArchiveID = %@", archiveID.uuidString)
//        req.returnsObjectsAsFaults = false
//
//        do {
//            let ARoutineRuns = try context.fetch(req) as [ARoutineRun]
//            return ARoutineRuns.first
//        } catch {
//            let nserror = error as NSError
//            throw DataError.fetchError(msg: nserror.localizedDescription)
//        }
//    }

//    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> ARoutineRun? {
//        NSManagedObject.get(context, forURIRepresentation: url) as? ARoutineRun
//    }

//    var wrappedName: String {
//        get { name ?? "unknown" }
//        set { name = newValue }
//    }
}
