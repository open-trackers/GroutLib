//
// NSManagedObject-ext.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

public extension NSManagedObject {
    var uriRepresentation: URL {
        objectID.uriRepresentation()
    }

    /// Return last path component as a string, if any.
    /// e.g., p1 from uri://blah/a/b/c/p1
    var uriRepresentationSuffix: String? {
        uriRepresentation.suffix
    }

    static func getObjectID(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> NSManagedObjectID? {
        if let psc = context.persistentStoreCoordinator,
           let mobjectID = psc.managedObjectID(forURIRepresentation: url)
        {
            return mobjectID
        }

        return nil
    }

    static func get<T: NSManagedObject>(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> T? {
        if let mobjectID = getObjectID(context, forURIRepresentation: url),
           let mobject = context.object(with: mobjectID) as? T
        {
            return mobject
        }

        return nil
    }
}
