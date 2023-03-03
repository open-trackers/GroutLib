//
//  AppSetting-encodable.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

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
