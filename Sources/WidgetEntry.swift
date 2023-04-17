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
    public let date: Date
    public let name: String
    public let imageName: String?
    public let timeInterval: TimeInterval
    public let color: Color?

    public init(date: Date = Date.now,
                name: String,
                imageName: String?,
                timeInterval: TimeInterval,
                color: Color?)
    {
        self.date = date
        self.name = name
        self.imageName = imageName
        self.timeInterval = timeInterval
        self.color = color
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
                        now: Date = Date.now,
                        reload: Bool,
                        defaultColor: Color = .clear) throws
    {
        let sort = Routine.byLastStartedAt(ascending: false)

        // obtain most recent routine
        guard let routine = try Routine.getFirst(context, sort: sort),
              let name = routine.name,
              let lastStartedAt = routine.lastStartedAt
        else { return }

        let lastEnded = lastStartedAt.addingTimeInterval(routine.lastDuration)

        let timeInterval = now.timeIntervalSince(lastEnded)

        let color = routine.getColor() ?? defaultColor

        refresh(name: name,
                imageName: routine.imageName,
                timeInterval: timeInterval,
                color: color,
                reload: reload)
    }

    internal static func refresh(name: String,
                                 imageName: String?,
                                 timeInterval: TimeInterval,
                                 color: Color,
                                 now: Date = Date.now,
                                 reload: Bool)
    {
        print("REFRESH target \(timeInterval)")
        let entry = WidgetEntry(date: now,
                                name: name,
                                imageName: imageName,
                                timeInterval: timeInterval,
                                color: color)
        UserDefaults.appGroup.set(entry)

        if reload {
            print("RELOADING ALL TIMELINES ##############################################")
            UserDefaults.appGroup.synchronize() // ensure new values written to disk
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
