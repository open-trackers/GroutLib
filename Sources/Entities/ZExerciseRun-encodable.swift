//
//  ZExerciseRun.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZExerciseRun: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case completedAt
        case intensity
        case createdAt
        case exerciseArchiveID // FK
        case routineRunStartedAt // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(completedAt, forKey: .completedAt)
        try c.encode(intensity, forKey: .intensity)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(zExercise?.exerciseArchiveID, forKey: .exerciseArchiveID)
        try c.encode(zRoutineRun?.startedAt, forKey: .routineRunStartedAt)
    }
}

extension ZExerciseRun: MAttributable {
    public static var fileNamePrefix: String {
        "zexerciseruns"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.completedAt, .date),
        MAttribute(CodingKeys.intensity, .double),
        MAttribute(CodingKeys.createdAt, .date),
        MAttribute(CodingKeys.exerciseArchiveID, .string),
        MAttribute(CodingKeys.routineRunStartedAt, .date),
    ]
}
