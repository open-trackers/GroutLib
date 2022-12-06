//
//  Routine.swift
//
// Copyright 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

extension Routine: UserOrdered {}

public extension Routine {
    // NOTE: does NOT save to context
    static func create(_ viewContext: NSManagedObjectContext, userOrder: Int16) -> Routine {
        let nu = Routine(context: viewContext)
        nu.userOrder = userOrder
        nu.name = "New Routine"
        return nu
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}

public extension Routine {
    var anyExerciseCompleted: Bool {
        exercises?.first(where: { ($0 as? Exercise)?.lastCompletedAt != nil }) != nil
    }

    // NOTE: does NOT save to context
    internal func clearCompletions(_ viewContext: NSManagedObjectContext) throws {
        let req = NSFetchRequest<Exercise>(entityName: "Exercise")
        req.predicate = NSPredicate(format: "routine = %@", self)

        do {
            let exercises: [Exercise] = try viewContext.fetch(req) as [Exercise]
            exercises.forEach { exercise in
                exercise.lastCompletedAt = nil
            }
        } catch {
            let nserror = error as NSError
            throw DataError.fetchError(msg: nserror.localizedDescription)
        }
    }

    // NOTE: does NOT save context
    func start(_ viewContext: NSManagedObjectContext, startDate: Date = Date.now) throws -> Date {
        try clearCompletions(viewContext)
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

    func getNextIncomplete(_ viewContext: NSManagedObjectContext, from userOrder: Int16? = nil) throws -> Exercise? {
        let req = NSFetchRequest<Exercise>(entityName: "Exercise")
        req.sortDescriptors = Routine.exerciseSort
        req.fetchLimit = 1

        do {
            if let _userOrder = userOrder {
                req.predicate = nextTrailing(from: _userOrder)
                if let next = (try viewContext.fetch(req) as [Exercise]).first {
                    return next
                }

                req.predicate = nextLeading(to: _userOrder)
                if let next = (try viewContext.fetch(req) as [Exercise]).first {
                    return next
                }
            } else {
                // start from beginning
                req.predicate = incompletePredicate
                if let next = (try viewContext.fetch(req) as [Exercise]).first {
                    return next
                }
            }
        } catch {
            let nserror = error as NSError
            throw DataError.fetchError(msg: nserror.localizedDescription)
        }

        return nil
    }
}
