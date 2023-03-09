//
//  Exercise-fetch.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension Exercise {
    static func getPredicate(routine: Routine) -> NSPredicate {
        NSPredicate(format: "routine == %@", routine)
    }

    static func getPredicate(routineArchiveID: UUID, exerciseArchiveID: UUID) -> NSPredicate {
        NSPredicate(format: "routine.archiveID == %@ AND archiveID == %@", routineArchiveID.uuidString, exerciseArchiveID.uuidString)
    }
}

public extension Exercise {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \Exercise.createdAt, ascending: ascending),
        ]
    }

    /// sort by userOrder(ascending/descending), createdAt(ascending)
    static func byUserOrder(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \Exercise.userOrder, ascending: ascending),
            NSSortDescriptor(keyPath: \Exercise.createdAt, ascending: true),
        ]
    }
}
