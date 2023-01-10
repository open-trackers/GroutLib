//
//  RequestUtils.swift
//  
//
//  Created by Reed Esau on 1/9/23.
//

import CoreData

public func getRequest<T: NSFetchRequestResult>(_: T.Type,
                                         predicate: NSPredicate? = nil,
                                         sortDescriptors: [NSSortDescriptor] = [],
                                         inStore: NSPersistentStore? = nil) throws -> NSFetchRequest<T>
{
    let request = NSFetchRequest<T>(entityName: String(describing: T.self))
    request.sortDescriptors = sortDescriptors
    if let predicate {
        request.predicate = predicate
    }
    if let inStore {
        request.affectedStores = [inStore]
    }
    return request
}

