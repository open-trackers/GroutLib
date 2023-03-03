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

extension AppSetting {
    internal static var earliestSort: [NSSortDescriptor] =
        [NSSortDescriptor(keyPath: \AppSetting.createdAt, ascending: true)]

    // NOTE: does NOT save context
    public static func dedupe(_ context: NSManagedObjectContext) throws {
        var first: AppSetting?
        try context.fetcher(sortDescriptors: earliestSort) { (element: AppSetting) in
            if first == nil {
                first = element
            } else {
                context.delete(element)
            }
            return true
        }
    }
}
