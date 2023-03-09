//
//  Exercise-userOrdered.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension Exercise: UserOrdered {}

public extension Exercise {
    static func maxUserOrder(_ context: NSManagedObjectContext, routine: Routine) throws -> Int16? {
        let sort = Exercise.byUserOrder(ascending: false)
        let pred = Exercise.getPredicate(routine: routine)
        let exercise: Exercise? = try context.firstFetcher(predicate: pred, sortDescriptors: sort)
        return exercise?.userOrder
    }
}
