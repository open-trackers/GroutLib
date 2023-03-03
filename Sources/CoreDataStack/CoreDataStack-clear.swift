//
//  CoreDataStack-clear.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension CoreDataStack {
    /// Clear Categories and Servings from the main store. (Should not be present in Archive store.)
    /// NOTE: does NOT save context
    func clearPrimaryEntities(_ context: NSManagedObjectContext) throws {
        try context.deleter(AppSetting.self)
        try context.deleter(Exercise.self)
        try context.deleter(Routine.self)
    }

    /// Clear the log entities from the specified store.
    /// If no store specified, it will clear from all stores.
    /// NOTE: does NOT save context
    public func clearZEntities(_ context: NSManagedObjectContext, inStore: NSPersistentStore? = nil) throws {
        try context.deleter(ZExerciseRun.self, inStore: inStore)
        try context.deleter(ZExercise.self, inStore: inStore)
        try context.deleter(ZRoutineRun.self, inStore: inStore)
        try context.deleter(ZRoutine.self, inStore: inStore)
    }
}
