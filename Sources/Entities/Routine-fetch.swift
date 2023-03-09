//
//  Routine-fetch.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension Routine {
    static func get(_ context: NSManagedObjectContext,
                    archiveID: UUID) throws -> Routine?
    {
        let pred = getPredicate(archiveID: archiveID)
        let sort = Routine.byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort)
    }

    static func getFirst(_ context: NSManagedObjectContext) throws -> Routine? {
        try context.firstFetcher(sortDescriptors: byUserOrder())
    }
}

public extension Routine {
    static func getPredicate(archiveID: UUID) -> NSPredicate {
        NSPredicate(format: "archiveID == %@", archiveID.uuidString)
    }
}

public extension Routine {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \Routine.createdAt, ascending: ascending),
        ]
    }

    /// sort by userOrder(ascending/descending), createdAt(ascending)
    static func byUserOrder(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \Routine.userOrder, ascending: ascending),
            NSSortDescriptor(keyPath: \Routine.createdAt, ascending: ascending),
        ]
    }
}
