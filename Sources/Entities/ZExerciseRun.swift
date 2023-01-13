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

public extension ZExerciseRun {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       zRoutineRun: ZRoutineRun,
                       zExercise: ZExercise,
                       completedAt: Date,
                       intensity: Float,
                       toStore: NSPersistentStore? = nil) -> ZExerciseRun
    {
        let nu = ZExerciseRun(context: context)
        nu.zRoutineRun = zRoutineRun
        nu.zExercise = zExercise
        nu.completedAt = completedAt
        nu.intensity = intensity
        if let toStore {
            context.assign(nu, to: toStore)
        }
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     dstRoutineRun: ZRoutineRun,
                     dstExercise: ZExercise,
                     toStore dstStore: NSPersistentStore) throws -> ZExerciseRun
    {
        guard let completedAt
        else { throw DataError.missingData(msg: "completedAt not present; can't copy") }
        return try ZExerciseRun.getOrCreate(context, zRoutineRun: dstRoutineRun, zExercise: dstExercise, completedAt: completedAt, intensity: intensity, inStore: dstStore)
    }

    static func get(_ context: NSManagedObjectContext,
                    forArchiveID archiveID: UUID,
                    completedAt: Date,
                    inStore: NSPersistentStore? = nil) throws -> ZExerciseRun?
    {
        let pred = NSPredicate(format: "zExercise.exerciseArchiveID = %@ AND completedAt == %@",
                               archiveID.uuidString,
                               completedAt as NSDate)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    /// Fetch a ZExerciseRun record in the specified store, creating if necessary.
    /// Will update intensity on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutineRun: ZRoutineRun,
                            zExercise: ZExercise,
                            completedAt: Date,
                            intensity: Float,
                            inStore: NSPersistentStore) throws -> ZExerciseRun
    {
        guard let archiveID = zExercise.exerciseArchiveID
        else { throw DataError.missingData(msg: "ZExercise.archiveID; can't get or create") }

        if let nu = try ZExerciseRun.get(context, forArchiveID: archiveID, completedAt: completedAt, inStore: inStore) {
            nu.intensity = intensity
            return nu
        } else {
            return ZExerciseRun.create(context, zRoutineRun: zRoutineRun, zExercise: zExercise, completedAt: completedAt, intensity: intensity, toStore: inStore)
        }
    }

    static func count(_ context: NSManagedObjectContext,
                      predicate: NSPredicate? = nil,
                      inStore: NSPersistentStore? = nil) throws -> Int
    {
        try context.counter(ZExerciseRun.self, predicate: predicate, inStore: inStore)
    }
}

extension ZExerciseRun: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case completedAt
        case intensity
        case exerciseArchiveID // FK
        case routineRunStartedAt // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(completedAt, forKey: .completedAt)
        try c.encode(intensity, forKey: .intensity)
        try c.encode(zExercise?.exerciseArchiveID, forKey: .exerciseArchiveID)
        try c.encode(zRoutineRun?.startedAt, forKey: .routineRunStartedAt)
    }
}

extension ZExerciseRun: MAttributable {
    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.completedAt, .date),
        MAttribute(CodingKeys.intensity, .double),
        MAttribute(CodingKeys.exerciseArchiveID, .string),
        MAttribute(CodingKeys.routineRunStartedAt, .date),
    ]
}
