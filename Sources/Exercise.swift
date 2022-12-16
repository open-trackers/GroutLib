//
//  Exercise.swift
//
// Copyright 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@objc(Exercise)
public class Exercise: NSManagedObject, Codable {
    private enum CodingKeys: String, CodingKey { case urlRep }

    // Encode to URL representation
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uriRepresentationString, forKey: .urlRep)
    }

    // Decode from URL representation
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext
        else { throw DecoderConfigurationError.missingManagedObjectContext }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urlRep = try container.decode(URL.self, forKey: .urlRep)

        guard let exercise = NSManagedObject.get(context, forURIRepresentation: urlRep) as? Exercise
        else { throw DecodingError.valueNotFound(Routine.Type.self,
                                                 DecodingError.Context(codingPath: [CodingKeys.urlRep],
                                                                       debugDescription: "Record not found")) }

        self.init(entity: exercise.entity, insertInto: context)

        //        self.init(context: context)

//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let urlRep = try container.decode(URL.self, forKey: .urlRep)
//
//        guard let routine = NSManagedObject.get(context, forURIRepresentation: urlRep) as? Routine
//        else { print("Error: unable to get Routine!"); return }
//        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext
//        else { throw DecoderConfigurationError.missingManagedObjectContext }
//
//        //let entity = NSEntityDescription.entity(forEntityName: "Routine", in: context)
//        //self.init(entity: entity, insertInto: managedObjectContext)
//
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        let urlRepStr = try values.decode(String.self, forKey: .urlRepStr)
//
//        guard let urlRep = URL(string: urlRepStr),
//              let exercise = NSManagedObject.get(context, forURIRepresentation: urlRep) as? Exercise
//        else { print("Error: unable to get Routine!") }
//
//        self.init(entity: exercise, insertInto: context)
    }
}

extension Exercise: UserOrdered {}

public extension Exercise {
    // NOTE: does NOT save to context
    static func create(_ viewContext: NSManagedObjectContext, userOrder: Int16) -> Exercise {
        let nu = Exercise(context: viewContext)
        nu.userOrder = userOrder
        nu.name = "New Exercise"
        return nu
    }

    // @NSManaged public var name: String?
    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}
