//
//  Routine.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@objc(Routine)
public class Routine: NSManagedObject {}

extension Routine: UserOrdered {}

public extension Routine {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext, userOrder: Int16) -> Routine {
        let nu = Routine(context: context)
        nu.userOrder = userOrder
        nu.name = "New Routine"
        nu.archiveID = UUID()
        return nu
    }

    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> Routine? {
        NSManagedObject.get(context, forURIRepresentation: url) as? Routine
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}

public extension Routine {
    // NOTE: does NOT save context
    internal func clearCompletions(_ context: NSManagedObjectContext) throws {
        let predicate = NSPredicate(format: "routine = %@", self)
        try context.fetcher(predicate: predicate) { (exercise: Exercise) in
            exercise.lastCompletedAt = nil
            return true
        }
    }

    // NOTE: does NOT save context
    func start(_ context: NSManagedObjectContext, clearData: Bool, startDate: Date = Date.now) throws -> Date {
        if clearData {
            try clearCompletions(context)
        }
        return startDate
    }

    // Returns true if routine is updated.
    // NOTE: does NOT save context
    func stop(_ context: NSManagedObjectContext,
              startedAt: Date,
              now: Date = Date.now) throws -> Bool
    {
        guard anyExerciseCompleted,
              startedAt < now
        else { return false }

        let duration = now.timeIntervalSince(startedAt)

        if archiveID == nil { archiveID = UUID() }

        // log the run for charting
        _ = try Routine.logRun(context,
                               archiveID: archiveID!,
                               name: wrappedName,
                               startedAt: startedAt,
                               duration: duration)

        // update the attributes with fresh data
        lastStartedAt = startedAt
        lastDuration = duration

        return true
    }

    internal var anyExerciseCompleted: Bool {
        exercises?.first(where: { ($0 as? Exercise)?.lastCompletedAt != nil }) != nil
    }
}

public extension Routine {
    static var exerciseSort: [NSSortDescriptor] {
        [NSSortDescriptor(keyPath: \Exercise.userOrder, ascending: true)]
    }

    var exercisePredicate: NSPredicate {
        NSPredicate(format: "routine = %@", self)
    }

    var incompletePredicate: NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [
            exercisePredicate,
            NSPredicate(format: "lastCompletedAt = Nil"),
        ])
    }

    internal func nextTrailing(from userOrder: Int16) -> NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [
            incompletePredicate,
            NSPredicate(format: "userOrder > %d", userOrder),
        ])
    }

    internal func nextLeading(to userOrder: Int16) -> NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [
            incompletePredicate,
            NSPredicate(format: "userOrder < %d", userOrder),
        ])
    }

    func getNextIncomplete(_ context: NSManagedObjectContext, from userOrder: Int16? = nil) throws -> NSManagedObjectID? {
        // print("\(#function) userOrder=\(userOrder ?? -2000)")

        // let req = try context.getRequest(Exercise.self, sortDescriptors: Routine.exerciseSort)

        let req = NSFetchRequest<Exercise>(entityName: "Exercise")
        req.sortDescriptors = Routine.exerciseSort
        req.returnsObjectsAsFaults = false
        req.fetchLimit = 1

        do {
            if let _userOrder = userOrder {
                // print("\(#function) next trailing")
                req.predicate = nextTrailing(from: _userOrder)
                if let next = (try context.fetch(req) as [Exercise]).first {
                    // print("\(#function) next trailing found \(next.uriRepresentationSuffix ?? "")")
                    return next.objectID
                }

                // print("\(#function) next leading")
                req.predicate = nextLeading(to: _userOrder)
                if let next = (try context.fetch(req) as [Exercise]).first {
                    // print("\(#function) next leading found \(next.uriRepresentationSuffix ?? "")")
                    return next.objectID
                }
            } else {
                // print("\(#function) start from beginning")
                // start from beginning
                req.predicate = incompletePredicate
                if let next = (try context.fetch(req) as [Exercise]).first {
                    // print("\(#function) from beginning found \(next.uriRepresentationSuffix ?? "")")
                    return next.objectID
                }
            }
        } catch {
            throw DataError.fetchError(msg: error.localizedDescription)
        }

        return nil
    }
}

extension Routine {
    /// log the run of the routine to the main store
    /// (These will later be transferred to the archive store on iOS devices)
    /// NOTE: does NOT save context
    static func logRun(_ context: NSManagedObjectContext,
                       archiveID: UUID,
                       name: String,
                       startedAt: Date,
                       duration: TimeInterval) throws -> ZRoutineRun
    {
        guard let mainStore = PersistenceManager.getStore(context, .main)
        else {
            throw DataError.invalidStoreConfiguration(msg: "Cannot log routine run.")
        }

        let zRoutine = try ZRoutine.getOrCreate(context, routineArchiveID: archiveID, routineName: name, inStore: mainStore)

        return try ZRoutineRun.getOrCreate(context,
                                           zRoutine: zRoutine,
                                           startedAt: startedAt,
                                           duration: duration,
                                           inStore: mainStore)
    }
}
