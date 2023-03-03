//
//  ZExercise.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

/// Archive representation of a Exercise record
public extension ZExercise {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       zRoutine: ZRoutine,
                       exerciseName: String,
                       exerciseUnits: Units = Units.none,
                       exerciseArchiveID: UUID,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore? = nil) -> ZExercise
    {
        let nu = ZExercise(context: context)
        zRoutine.addToZExercises(nu)
        nu.createdAt = createdAt
        nu.name = exerciseName
        nu.units = exerciseUnits.rawValue
        nu.exerciseArchiveID = exerciseArchiveID
        if let toStore {
            context.assign(nu, to: toStore)
        }
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// NOTE assumes that routine is in dstStore.
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     dstRoutine: ZRoutine,
                     toStore dstStore: NSPersistentStore) throws -> ZExercise
    {
        guard let exerciseArchiveID
        else { throw TrackerError.missingData(msg: "exerciseArchiveID; can't copy") }
        let nu = try ZExercise.getOrCreate(context,
                                           zRoutine: dstRoutine,
                                           exerciseArchiveID: exerciseArchiveID,
                                           exerciseName: wrappedName,
                                           exerciseUnits: Units(rawValue: units) ?? Units.none,
                                           inStore: dstStore)
        return nu
    }

    static func get(_ context: NSManagedObjectContext,
                    exerciseArchiveID: UUID,
                    inStore: NSPersistentStore? = nil) throws -> ZExercise?
    {
        let pred = NSPredicate(format: "exerciseArchiveID = %@", exerciseArchiveID.uuidString)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    /// Fetch a ZExercise record in the specified store, creating if necessary.
    /// Will update name and units on existing record.
    /// Will NOT update ZRoutine on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutine: ZRoutine,
                            exerciseArchiveID: UUID,
                            exerciseName: String,
                            exerciseUnits: Units,
                            inStore: NSPersistentStore) throws -> ZExercise
    {
        if let nu = try ZExercise.get(context, exerciseArchiveID: exerciseArchiveID, inStore: inStore) {
            nu.name = exerciseName
            nu.units = exerciseUnits.rawValue
            return nu
        } else {
            return ZExercise.create(context,
                                    zRoutine: zRoutine,
                                    exerciseName: exerciseName,
                                    exerciseUnits: exerciseUnits,
                                    exerciseArchiveID: exerciseArchiveID,
                                    toStore: inStore)
        }
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}

extension ZExercise: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case name
        case units
        case exerciseArchiveID
        case createdAt
        case routineArchiveID // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(units, forKey: .units)
        try c.encode(exerciseArchiveID, forKey: .exerciseArchiveID)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(zRoutine?.routineArchiveID, forKey: .routineArchiveID)
    }
}

extension ZExercise: MAttributable {
    public static var fileNamePrefix: String {
        "zexercises"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.name, .string),
        MAttribute(CodingKeys.units, .int),
        MAttribute(CodingKeys.exerciseArchiveID, .string),
        MAttribute(CodingKeys.createdAt, .date),
        MAttribute(CodingKeys.routineArchiveID, .string),
    ]
}
