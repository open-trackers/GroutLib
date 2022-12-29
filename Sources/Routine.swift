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

@objc(Routine)
public class Routine: NSManagedObject {}

extension Routine: UserOrdered {}

/// Struct providing archivable reference to the managed object.
/// Codable for use in NavigationStack, State, and UserActivity.
/// Identifiable for use in .sheet and .fullScreenCover.
/// RawRepresentable so that it can be stored in SceneStorage or AppStorage.
/// Typed to Routine for use as a navigationDestination.
// public typealias RoutineUriRep = UriRep<Routine>
// public extension Routine {
//    var uriRep: RoutineUriRep {
//        UriRep(value: uriRepresentation)
//    }
// }

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
    var anyExerciseCompleted: Bool {
        exercises?.first(where: { ($0 as? Exercise)?.lastCompletedAt != nil }) != nil
    }

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
        print("\(#function) userOrder=\(userOrder ?? -2000)")

        let req = NSFetchRequest<Exercise>(entityName: "Exercise")
        req.sortDescriptors = Routine.exerciseSort
        req.returnsObjectsAsFaults = false
        req.fetchLimit = 1

        do {
            if let _userOrder = userOrder {
                print("\(#function) next trailing")
                req.predicate = nextTrailing(from: _userOrder)
                if let next = (try context.fetch(req) as [Exercise]).first {
                    print("\(#function) next trailing found \(next.uriRepresentationString.suffix(4))")
                    return next.objectID
                }

                print("\(#function) next leading")
                req.predicate = nextLeading(to: _userOrder)
                if let next = (try context.fetch(req) as [Exercise]).first {
                    print("\(#function) next leading found \(next.uriRepresentationString.suffix(4))")
                    return next.objectID
                }
            } else {
                print("\(#function) start from beginning")
                // start from beginning
                req.predicate = incompletePredicate
                if let next = (try context.fetch(req) as [Exercise]).first {
                    print("\(#function) from beginning found \(next.uriRepresentationString.suffix(4))")
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

// extension Routine: Codable {
//    private enum CodingKeys: String, CodingKey { case urlRepStr }
//
//    // Encode to URL representation
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.uriRepresentationString, forKey: .urlRepStr)
//    }
//
//    // Decode from URL representation
//    public required convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext
//        else { fatalError("Error: NSManagedObject not specified!") }
//
//        //let entity = NSEntityDescription.entity(forEntityName: "Routine", in: context)
//        //self.init(entity: entity, insertInto: managedObjectContext)
//
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        let urlRepStr = try values.decode(String.self, forKey: .urlRepStr)
//
//        guard let urlRep = URL(string: urlRepStr),
//              let routine = NSManagedObject.get(context, forURIRepresentation: urlRep) as? Routine
//        else { print("Error: unable to get Routine!"); return }
//
////        self.init(entity: routine, insertInto: context)
//
////        let container = try decoder.container(keyedBy: CodingKeys.self)
////                self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
////                self.username = try container.decodeIfPresent(String.self, forKey: .username)
////                self.role = try container.decodeIfPresent(String.self, forKey: .role)
//
//        //        let entity = NSEntityDescription.entity(forEntityName: "DataClass", in: context)!
//        //                self.init(entity: entity, insertInto: context)
//        //                let values = try decoder.container(keyedBy: CodingKeys.self)
//        //                name = try values.decode(String.self, forKey: .name)
//    }

// if using decoder
//    let context = // get the managed object context
//    let decoder = JSONDecoder(context: context)

/*
  https://www.hackingwithswift.com/forums/100-days-of-swiftui/day-61-my-solution-to-make-core-data-conform-to-codable/2434
 func loadData() {
         // I'm omitting all the code to load data and focus on just how to encode it into Core Data
         // before doing anything here I recommend checking if there's already data (users.isEmpty)
         let decoder = JSONDecoder()

         // add context to the decoder so the data can decode itself into Core Data
         // since we added the 'CodingUserInfoKey.context' property we know it's not nil, so force-unwrapping is fine
         decoder.userInfo[CodingUserInfoKey.context!] = self.moc

         // in case anyone struggled with the dates, didn't want to leave this out here
         decoder.dateDecodingStrategy = .iso8601

         // we don't actually need to save the result anywhere since we use a @FetchRequest to display the data
         // that gets decoded right into the Core Data entities
         // though I suppose it would be possible to skip the fetchrequest and just use a @State variable, but that
         // would kind of defeat the purpose of using Core Data
         _ = try? decoder.decode([User].self, from: data)
     }
  */
// }
