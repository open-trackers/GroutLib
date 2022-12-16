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
public class Exercise: NSManagedObject {}

extension Exercise: UserOrdered {}

/// Struct providing archivable reference to the managed object.
/// Codable for use in NavigationStack, State, and UserActivity.
/// Typed to Exercise for use as a navigationDestination.
public extension Exercise {
    struct UriRep: Hashable, Codable {
        public var value: URL
    }

    var uriRep: UriRep {
        UriRep(value: uriRepresentation)
    }
}

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
