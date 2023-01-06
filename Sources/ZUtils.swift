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

/// Delete all `Z` records prior to a specified date.
public func cleanLogRecords(_ context: NSManagedObjectContext, keepSince: Date) throws {
    try context.deleter(entityName: "ZExerciseRun",
                        predicate: NSPredicate(format: "completedAt < %@", keepSince as NSDate))

    try context.deleter(entityName: "ZExercise",
                        predicate: NSPredicate(format: "zExerciseRuns.@count == 0"))

    try context.deleter(entityName: "ZRoutineRun",
                        predicate: NSPredicate(format: "startedAt < %@", keepSince as NSDate))

    try context.deleter(entityName: "ZRoutine",
                        predicate: NSPredicate(format: "zRoutineRuns.@count == 0"))
}
