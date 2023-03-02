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

import TrackerLib

@objc(Routine)
public class Routine: NSManagedObject {}

extension Routine: UserOrdered {}

public extension Routine {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       userOrder: Int16,
                       name: String = "New Routine",
                       archiveID: UUID = UUID()) -> Routine
    {
        let nu = Routine(context: context)
        nu.userOrder = userOrder
        nu.name = name
        nu.archiveID = archiveID
        return nu
    }

    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> Routine? {
        NSManagedObject.get(context, forURIRepresentation: url) as? Routine
    }

    static func get(_ context: NSManagedObjectContext,
                    archiveID: UUID) throws -> Routine?
    {
        let pred = NSPredicate(format: "archiveID = %@", archiveID.uuidString)
        return try context.firstFetcher(predicate: pred)
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
            throw TrackerError.fetchError(msg: error.localizedDescription)
        }

        return nil
    }
}

extension Routine: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case archiveID
        case imageName
        case lastDuration
        case lastStartedAt
        case name
        case userOrder
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(archiveID, forKey: .archiveID)
        try c.encode(imageName, forKey: .imageName)
        try c.encode(lastDuration, forKey: .lastDuration)
        try c.encode(lastStartedAt, forKey: .lastStartedAt)
        try c.encode(name, forKey: .name)
        try c.encode(userOrder, forKey: .userOrder)
    }
}

extension Routine: MAttributable {
    public static var fileNamePrefix: String {
        "routines"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.archiveID, .string),
        MAttribute(CodingKeys.imageName, .string),
        MAttribute(CodingKeys.lastDuration, .double),
        MAttribute(CodingKeys.lastStartedAt, .date),
        MAttribute(CodingKeys.name, .string),
        MAttribute(CodingKeys.userOrder, .int),
    ]
}
