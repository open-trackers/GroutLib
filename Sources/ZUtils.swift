//
//  ZUtils.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData


public func cleanLogRecords(_ context: NSManagedObjectContext, keepSince: Date) throws {
    
    let req = NSFetchRequest<ZRoutineRun>(entityName: "ZRoutineRun")
    req.predicate = NSPredicate(format: "startedAt < %@", keepSince as NSDate)

    do {
        let rr: [ZRoutineRun] = try context.fetch(req) as [ZRoutineRun]
        rr.forEach { context.delete($0) }
    } catch {
        let nserror = error as NSError
        throw DataError.fetchError(msg: nserror.localizedDescription)
    }
}
