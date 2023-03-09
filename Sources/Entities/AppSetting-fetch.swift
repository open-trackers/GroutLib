//
//  AppSetting-fetch.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension AppSetting {
    internal static var byCreatedAt: [NSSortDescriptor] =
        [NSSortDescriptor(keyPath: \AppSetting.createdAt, ascending: true)]

    // NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            onUpdate: (Bool, AppSetting) -> Void = { _, _ in }) throws -> AppSetting
    {
        // obtain the earliest appSetting in case dupes exist
        if let existing: AppSetting = try context.firstFetcher(sortDescriptors: byCreatedAt) {
            onUpdate(true, existing)
            return existing
        } else {
            let nu = AppSetting.create(context) // w/defaults
            onUpdate(false, nu)
            return nu
        }
    }
}
