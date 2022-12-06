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
