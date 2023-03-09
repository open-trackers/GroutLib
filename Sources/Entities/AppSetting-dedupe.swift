//
//  AppSetting-dedupe.swift
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
    // NOTE: does NOT save context
    static func dedupe(_ context: NSManagedObjectContext) throws {
        var first: AppSetting?
        try context.fetcher(sortDescriptors: byCreatedAt) { (element: AppSetting) in
            if first == nil {
                first = element
            } else {
                context.delete(element)
            }
            return true
        }
    }
}
