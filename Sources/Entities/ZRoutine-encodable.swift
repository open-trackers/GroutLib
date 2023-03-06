//
//  ZRoutine-encodable.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZRoutine: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case name
        case routineArchiveID
        case createdAt
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(routineArchiveID, forKey: .routineArchiveID)
        try c.encode(createdAt, forKey: .createdAt)
    }
}

extension ZRoutine: MAttributable {
    public static var fileNamePrefix: String {
        "zroutines"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.name, .string),
        MAttribute(CodingKeys.routineArchiveID, .string),
        MAttribute(CodingKeys.createdAt, .date),
    ]
}
