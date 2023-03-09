//
//  Routine-startComplete.swift
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
    // NOTE: does NOT save context
    func start(_ context: NSManagedObjectContext, startDate: Date = Date.now) throws -> Date {
        let pred = Exercise.getPredicate(routine: self)
        let sort = Exercise.byCreatedAt()
        try context.fetcher(predicate: pred, sortDescriptors: sort) { (exercise: Exercise) in
            exercise.lastCompletedAt = nil
            return true
        }
        return startDate
    }
}
