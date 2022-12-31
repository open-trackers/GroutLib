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
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, userOrder: Int16) -> Routine {
        let nu = Routine(context: context)
        nu.userOrder = userOrder
        nu.name = "New Routine"
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
    // NOTE: does NOT save to context
    internal func clearCompletions(_ context: NSManagedObjectContext) throws {
        let req = NSFetchRequest<Exercise>(entityName: "Exercise")
        req.predicate = NSPredicate(format: "routine = %@", self)

        do {
            let exercises: [Exercise] = try context.fetch(req) as [Exercise]
            exercises.forEach { exercise in
                exercise.lastCompletedAt = nil
            }
        } catch {
            let nserror = error as NSError
            throw DataError.fetchError(msg: nserror.localizedDescription)
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
    func stop(startedAt: Date, now: Date = Date.now) -> Bool {
        guard anyExerciseCompleted,
              startedAt < now
        else { return false }
        lastStartedAt = startedAt
        lastDuration = now.timeIntervalSince(startedAt)
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
            let nserror = error as NSError
            throw DataError.fetchError(msg: nserror.localizedDescription)
        }

        return nil
    }
}
