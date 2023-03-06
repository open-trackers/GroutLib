//
//  Export-utils.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

#if !os(watchOS)
    public func groutCreateZipArchive(_ context: NSManagedObjectContext,
                                      mainStore: NSPersistentStore,
                                      archiveStore: NSPersistentStore,
                                      format: ExportFormat = .CSV) throws -> Data?
    {
        let entries: [(String, Data)] = [
            try makeDelimFile(AppSetting.self, context, format: format, inStore: mainStore),
            try makeDelimFile(Routine.self, context, format: format, inStore: mainStore),
            try makeDelimFile(Exercise.self, context, format: format, inStore: mainStore),

            try makeDelimFile(ZRoutine.self, context, format: format, inStore: archiveStore),
            try makeDelimFile(ZRoutineRun.self, context, format: format, inStore: archiveStore),
            try makeDelimFile(ZExercise.self, context, format: format, inStore: archiveStore),
            try makeDelimFile(ZExerciseRun.self, context, format: format, inStore: archiveStore),
        ]

        return try createZipArchive(context, entries: entries)
    }
#endif
