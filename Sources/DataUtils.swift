//
//  DataUtils.swift
//
// Copyright 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

public enum DataError: Error, Equatable {
    // data layer errors
    case fetchError(msg: String)

    var description: String {
        switch self {
        case let .fetchError(msg): return "Data fetch error: \(msg)"
        }
    }
}

public func clearRecords<T>(_: T.Type, context: NSManagedObjectContext) throws where T: NSFetchRequestResult {
    let req = NSFetchRequest<T>(entityName: String(describing: T.self))
    do {
        let mobjects = try context.fetch(req)
        mobjects.forEach { context.delete($0 as! NSManagedObject) }
    } catch {
        let nserror = error as NSError
        throw DataError.fetchError(msg: nserror.localizedDescription)
    }
}
