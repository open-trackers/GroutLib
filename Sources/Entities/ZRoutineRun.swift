//
//  ZRoutineRun.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension ZRoutineRun {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       zRoutine: ZRoutine,
                       startedAt: Date,
                       duration: Double,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore? = nil) -> ZRoutineRun
    {
        let nu = ZRoutineRun(context: context)
        zRoutine.addToZRoutineRuns(nu)
        nu.createdAt = createdAt
        nu.startedAt = startedAt
        nu.duration = duration
        if let toStore {
            context.assign(nu, to: toStore)
        }
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    internal func shallowCopy(_ context: NSManagedObjectContext,
                              dstRoutine: ZRoutine,
                              toStore dstStore: NSPersistentStore) throws -> ZRoutineRun
    {
        guard let startedAt
        else { throw TrackerError.missingData(msg: "startedAt; can't copy") }
        return try ZRoutineRun.getOrCreate(context, zRoutine: dstRoutine, startedAt: startedAt, duration: duration, inStore: dstStore)
    }

    static func get(_ context: NSManagedObjectContext,
                    routineArchiveID: UUID,
                    startedAt: Date,
                    inStore: NSPersistentStore? = nil) throws -> ZRoutineRun?
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, startedAt: startedAt)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> ZRoutineRun? {
        NSManagedObject.get(context, forURIRepresentation: url) as? ZRoutineRun
    }

    /// Fetch a ZRoutineRun record in the specified store, creating if necessary.
    /// Will update duration on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutine: ZRoutine,
                            startedAt: Date,
                            duration: TimeInterval,
                            inStore: NSPersistentStore) throws -> ZRoutineRun
    {
        guard let archiveID = zRoutine.routineArchiveID
        else { throw TrackerError.missingData(msg: "ZRoutine.archiveID; can't get or create") }

        if let nu = try ZRoutineRun.get(context, routineArchiveID: archiveID, startedAt: startedAt, inStore: inStore) {
            nu.duration = duration
            return nu
        } else {
            return ZRoutineRun.create(context, zRoutine: zRoutine, startedAt: startedAt, duration: duration, toStore: inStore)
        }
    }

    static func count(_ context: NSManagedObjectContext,
                      predicate: NSPredicate? = nil,
                      inStore: NSPersistentStore? = nil) throws -> Int
    {
        try context.counter(ZRoutineRun.self, predicate: predicate, inStore: inStore)
    }

    // for use in user delete of individual routine runs in UI, from both stores
    static func delete(_ context: NSManagedObjectContext,
                       routineArchiveID: UUID,
                       startedAt: Date,
                       inStore: NSPersistentStore? = nil) throws
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, startedAt: startedAt)

        try context.fetcher(predicate: pred, inStore: inStore) { (element: ZRoutineRun) in
            context.delete(element)
            return true
        }

        // NOTE: wasn't working due to conflict errors, possibly due to to cascading delete?
        // try context.deleter(ZRoutineRun.self, predicate: pred, inStore: inStore)
    }

    internal static func getPredicate(routineArchiveID: UUID,
                                      startedAt: Date) -> NSPredicate
    {
        NSPredicate(format: "zRoutine.routineArchiveID = %@ AND startedAt == %@",
                    routineArchiveID.uuidString,
                    startedAt as NSDate)
    }
//    var wrappedName: String {
//        get { name ?? "unknown" }
//        set { name = newValue }
//    }
}

extension ZRoutineRun: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case startedAt
        case duration
        case createdAt
        case routineArchiveID // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(startedAt, forKey: .startedAt)
        try c.encode(duration, forKey: .duration)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(zRoutine?.routineArchiveID, forKey: .routineArchiveID)
    }
}

extension ZRoutineRun: MAttributable {
    public static var fileNamePrefix: String {
        "zroutineruns"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.startedAt, .date),
        MAttribute(CodingKeys.duration, .double),
        MAttribute(CodingKeys.createdAt, .date),
        MAttribute(CodingKeys.routineArchiveID, .string),
    ]
}
