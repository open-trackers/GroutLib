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

public extension NSManagedObjectContext {
    // via avanderlee
    /// Executes the given `NSBatchDeleteRequest` and directly merges the changes to bring the given managed object context up to date.
    func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [
            NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? [],
        ]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }

    func deleter(entityName: String, predicate: NSPredicate? = nil) throws {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let predicate { req.predicate = predicate }
        let breq = NSBatchDeleteRequest(fetchRequest: req)
        try executeAndMergeChanges(using: breq)
    }
}

public extension NSManagedObjectContext {
    /// Convenient wrapper for iterating over results from simple fetch request.
    /// Will continue iterating so long as callback returns true
    func fetcher<T: NSFetchRequestResult>(_: T.Type,
                                          predicate: NSPredicate? = nil,
                                          sortDescriptors: [NSSortDescriptor] = [],
                                          inStore: NSPersistentStore? = nil,
                                          _ each: @escaping (T) throws -> Bool) throws
    {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.sortDescriptors = sortDescriptors
        if let predicate {
            request.predicate = predicate
        }
        if let inStore {
            request.affectedStores = [inStore]
        }
        for result in try fetch(request) as [T] {
            guard try each(result) else { break }
        }
    }

    /// Convenient wrapper for retrieving one record
    func firstFetcher<T: NSFetchRequestResult>(predicate: NSPredicate? = nil,
                                               sortDescriptors: [NSSortDescriptor] = [],
                                               inStore: NSPersistentStore? = nil) throws -> T?
    {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.sortDescriptors = sortDescriptors
        request.fetchLimit = 1
        // req.returnsObjectsAsFaults = false   //TODO does this matter?
        if let predicate {
            request.predicate = predicate
        }
        if let inStore {
            request.affectedStores = [inStore]
        }
        let results: [T] = try fetch(request) as [T]
        return results.first
    }
}
