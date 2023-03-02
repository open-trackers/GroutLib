//
//  AppSetting.swift
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
    static func create(_ context: NSManagedObjectContext,
//                       targetCalories: Int16 = defaultTargetCalories,
//                       startOfDay: StartOfDay = StartOfDay.defaultValue,
                       createdAt: Date = Date.now) -> AppSetting
    {
        let nu = AppSetting(context: context)
        nu.createdAt = createdAt
//        nu.targetCalories = targetCalories
//        nu.startOfDay = Int32(startOfDay.rawValue)
        return nu
    }

    // NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            onUpdate: (Bool, AppSetting) -> Void = { _, _ in }) throws -> AppSetting
    {
        // obtain the earliest appSetting in case dupes exist
        if let existing: AppSetting = try context.firstFetcher(sortDescriptors: earliestSort) {
            onUpdate(true, existing)
            return existing
        } else {
            let nu = AppSetting.create(context) // w/defaults
            onUpdate(false, nu)
            return nu
        }
    }
}

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

extension AppSetting: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
//        case startOfDay
//        case targetCalories
        case createdAt
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
//        try c.encode(startOfDay, forKey: .startOfDay)
//        try c.encode(targetCalories, forKey: .targetCalories)
        try c.encode(createdAt, forKey: .createdAt)
    }
}

extension AppSetting: MAttributable {
    public static var fileNamePrefix: String {
        "app-settings"
    }

    public static var attributes: [MAttribute] = [
        //        MAttribute(CodingKeys.startOfDay, .int),
//        MAttribute(CodingKeys.targetCalories, .int),
        MAttribute(CodingKeys.createdAt, .date),
    ]
}
