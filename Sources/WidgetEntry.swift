//
//  WidgetEntry.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import SwiftUI
import WidgetKit

import Collections

public struct WidgetEntry: TimelineEntry, Codable {
    public struct Pair: Codable {
        public let color: Color
        public let value: Float

        public init(_ color: Color, _ value: Float) {
            self.color = color
            self.value = value
        }
    }

    public let date: Date
    public let timeInterval: Int
    public let pairs: [Pair]

    public init(date: Date = Date.now,
                timeInterval: Int,
                pairs: [Pair] = [])
    {
        self.date = date
        self.timeInterval = timeInterval
        self.pairs = pairs
    }
}

public extension UserDefaults {
    internal static let appGroupSuiteName = "group.org.openalloc.grout"
    internal static let widgetEntryKey = "widgetEntry"

    static let appGroup = UserDefaults(suiteName: appGroupSuiteName)!

    func get() -> WidgetEntry? {
        guard let data = data(forKey: Self.widgetEntryKey) else { return nil }
        return try? JSONDecoder().decode(WidgetEntry.self, from: data)
    }

    func set(_ entry: WidgetEntry) {
        let data = try? JSONEncoder().encode(entry)
        set(data, forKey: Self.widgetEntryKey)
    }
}

public extension WidgetEntry {
    // Refresh widget with the latest data.
    // NOTE: does NOT save context (if AppSetting is created)
    static func refresh(_ context: NSManagedObjectContext,
                        inStore _: NSPersistentStore,
                        now _: Date = Date.now,
                        reload _: Bool,
                        defaultColor _: Color = .clear)
    {
        guard let appSetting = try? AppSetting.getOrCreate(context) else { return }

//        guard let consumedDay = appSetting.subjectiveToday,
//              let zdr = try? ZDayRun.get(context, consumedDay: consumedDay, inStore: inStore) else { return }
//
//        let calories: Int16 = zdr.refreshCalorieSum()
//
//        // NOTE: to ensure consistent ordering between runs
//        typealias Dict = OrderedDictionary<UUID, Float>
//
//        // as there might be more than one serving run per category, roll them up via a dictionary
//        let categoryAmounts: Dict = zdr.servingRunsArray.reduce(into: [:]) { dict, element in
//            guard calories > 0,
//                  let categoryArchiveID = element.zServing?.zCategory?.categoryArchiveID
//            else { return }
//            let fractionValue = Float(element.calories) / Float(calories)
//            dict[categoryArchiveID, default: 0] += fractionValue
//        }
//
//        let pairs: [WidgetEntry.Pair] = categoryAmounts.reduce(into: []) { array, keyValue in
//            let categoryArchiveID = keyValue.key
//            let amount = keyValue.value
//
//            let color: Color = {
//                guard let category = try? MCategory.get(context, archiveID: categoryArchiveID)
//                else {
//                    // category was deleted
//                    return defaultColor
//                }
//                return category.getColor() ?? defaultColor
//            }()
//
//            array.append(WidgetEntry.Pair(color, amount))
//        }
//
//        refresh(timeInterval: appSetting.timeInterval,
//                currentCalories: calories,
//                pairs: pairs,
//                now: now,
//                reload: reload)
    }

    internal static func refresh(timeInterval: Int16,
                                 pairs: [WidgetEntry.Pair],
                                 now: Date = Date.now,
                                 reload: Bool)
    {
        print("REFRESH target \(timeInterval)")
        let entry = WidgetEntry(date: now,
                                timeInterval: Int(timeInterval),
                                pairs: pairs)
        UserDefaults.appGroup.set(entry)

        if reload {
            print("RELOADING ALL TIMELINES ##############################################")
            UserDefaults.appGroup.synchronize() // ensure new values written to disk
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
