//
//  Exercise-encodable.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension Exercise: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case archiveID
        case intensityStep
        case invertedIntensity
        case lastCompletedAt
        case lastIntensity
        case name
        case primarySetting
        case repetitions
        case secondarySetting
        case sets
        case units
        case userOrder
        case createdAt
        case routineArchiveID // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(archiveID, forKey: .archiveID)
        try c.encode(intensityStep, forKey: .intensityStep)
        try c.encode(invertedIntensity, forKey: .invertedIntensity)
        try c.encode(lastCompletedAt, forKey: .lastCompletedAt)
        try c.encode(lastIntensity, forKey: .lastIntensity)
        try c.encode(name, forKey: .name)
        try c.encode(primarySetting, forKey: .primarySetting)
        try c.encode(repetitions, forKey: .repetitions)
        try c.encode(secondarySetting, forKey: .secondarySetting)
        try c.encode(sets, forKey: .sets)
        try c.encode(units, forKey: .units)
        try c.encode(userOrder, forKey: .userOrder)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(routine?.archiveID, forKey: .routineArchiveID)
    }
}

extension Exercise: MAttributable {
    public static var fileNamePrefix: String {
        "exercises"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.archiveID, .string),
        MAttribute(CodingKeys.intensityStep, .double),
        MAttribute(CodingKeys.invertedIntensity, .bool),
        MAttribute(CodingKeys.lastCompletedAt, .date),
        MAttribute(CodingKeys.lastIntensity, .double),
        MAttribute(CodingKeys.name, .string),
        MAttribute(CodingKeys.primarySetting, .int),
        MAttribute(CodingKeys.repetitions, .int),
        MAttribute(CodingKeys.secondarySetting, .int),
        MAttribute(CodingKeys.sets, .int),
        MAttribute(CodingKeys.units, .int),
        MAttribute(CodingKeys.userOrder, .int),
        MAttribute(CodingKeys.createdAt, .date),
        MAttribute(CodingKeys.routineArchiveID, .string),
    ]
}
