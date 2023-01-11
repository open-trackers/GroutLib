//
//  RequestUtils.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

public func makeRequest<T: NSFetchRequestResult>(_: T.Type,
                                                 predicate: NSPredicate? = nil,
                                                 sortDescriptors: [NSSortDescriptor] = [],
                                                 inStore: NSPersistentStore? = nil) -> NSFetchRequest<T>
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
