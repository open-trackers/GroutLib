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
