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
        let entries: [(String, Data)] = try [
            makeDelimFile(AppSetting.self, context, format: format, inStore: mainStore),
            makeDelimFile(Routine.self, context, format: format, inStore: mainStore),
            makeDelimFile(Exercise.self, context, format: format, inStore: mainStore),

            makeDelimFile(ZRoutine.self, context, format: format, inStore: archiveStore),
            makeDelimFile(ZRoutineRun.self, context, format: format, inStore: archiveStore),
            makeDelimFile(ZExercise.self, context, format: format, inStore: archiveStore),
            makeDelimFile(ZExerciseRun.self, context, format: format, inStore: archiveStore),
        ]

        return try createZipArchive(context, entries: entries)
    }
#endif
