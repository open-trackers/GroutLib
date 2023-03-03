//
//  Routine-encodable.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension Routine: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case archiveID
        case imageName
        case lastDuration
        case lastStartedAt
        case name
        case userOrder
        case createdAt
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(archiveID, forKey: .archiveID)
        try c.encode(imageName, forKey: .imageName)
        try c.encode(lastDuration, forKey: .lastDuration)
        try c.encode(lastStartedAt, forKey: .lastStartedAt)
        try c.encode(name, forKey: .name)
        try c.encode(userOrder, forKey: .userOrder)
        try c.encode(createdAt, forKey: .createdAt)
    }
}

extension Routine: MAttributable {
    public static var fileNamePrefix: String {
        "routines"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.archiveID, .string),
        MAttribute(CodingKeys.imageName, .string),
        MAttribute(CodingKeys.lastDuration, .double),
        MAttribute(CodingKeys.lastStartedAt, .date),
        MAttribute(CodingKeys.name, .string),
        MAttribute(CodingKeys.userOrder, .int),
        MAttribute(CodingKeys.createdAt, .date),
    ]
}
