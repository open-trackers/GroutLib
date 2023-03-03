//
//  ZRoutine.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

/// Archive representation of a Routine record
public extension ZRoutine {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       routineName: String,
                       routineArchiveID: UUID,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore) -> ZRoutine
    {
        let nu = ZRoutine(context: context)
        nu.createdAt = createdAt
        nu.name = routineName
        nu.routineArchiveID = routineArchiveID
        context.assign(nu, to: toStore)
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     toStore dstStore: NSPersistentStore) throws -> ZRoutine
    {
        guard let routineArchiveID
        else { throw TrackerError.missingData(msg: "routineArchiveID; can't copy") }
        return try ZRoutine.getOrCreate(context, routineArchiveID: routineArchiveID, routineName: wrappedName, inStore: dstStore)
    }

    static func get(_ context: NSManagedObjectContext,
                    routineArchiveID: UUID,
                    inStore: NSPersistentStore? = nil) throws -> ZRoutine?
    {
        let pred = NSPredicate(format: "routineArchiveID = %@", routineArchiveID.uuidString)
        return try context.firstFetcher(predicate: pred, inStore: inStore)
    }

    /// Fetch a ZRoutine record in the specified store, creating if necessary.
    /// Will update name on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            routineArchiveID: UUID,
                            routineName: String,
                            inStore: NSPersistentStore) throws -> ZRoutine
    {
        if let nu = try ZRoutine.get(context, routineArchiveID: routineArchiveID, inStore: inStore) {
            nu.name = routineName
            return nu
        } else {
            return ZRoutine.create(context, routineName: routineName, routineArchiveID: routineArchiveID, toStore: inStore)
        }
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}

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

extension ZRoutine {
    /// Avoid deleting 'z' records from main store where routine may still be active.
    /// If within the time threshold (default of one day), it's fresh; if outside, it's stale.
    /// NOTE: routine.lastStartedAt should have been initialized on first Exercise.markDone.
    func isFresh(_ context: NSManagedObjectContext,
                 now: Date = Date.now,
                 thresholdSecs: TimeInterval = 86400) -> Bool
    {
        if let archiveID = routineArchiveID,
           let routine = try? Routine.get(context, archiveID: archiveID),
           let startedAt = routine.lastStartedAt,
           now <= startedAt.addingTimeInterval(thresholdSecs)
        {
            return true
        }
        return false
    }
}
