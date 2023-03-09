
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

extension ZExerciseRun {
    internal static func dedupe(_ context: NSManagedObjectContext,
                                exerciseArchiveID: UUID,
                                completedAt: Date,
                                inStore: NSPersistentStore) throws
    {
        let pred = getPredicate(exerciseArchiveID: exerciseArchiveID,
                                completedAt: completedAt)
        let sort = byCreatedAt()
        var first: ZExerciseRun?
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZExerciseRun) in
            if first == nil {
                first = element
            } else {
                context.delete(element)
            }
            return true
        }
    }

    // NOTE: does NOT save context
    public static func dedupe(_ context: NSManagedObjectContext,
                              _ object: NSManagedObject,
                              inStore: NSPersistentStore) throws
    {
        guard let element = object as? ZExerciseRun
        else {
            throw TrackerError.missingData(msg: "Could not resolve ZExerciseRun for de-duplication.")
        }

        guard let exerciseArchiveID = element.zExercise?.exerciseArchiveID
        else {
            throw TrackerError.missingData(msg: "Could not resolve ZExerciseRun.exerciseArchiveID for de-duplication.")
        }

        guard let completedAt = element.completedAt
        else {
            throw TrackerError.missingData(msg: "Could not resolve ZExerciseRun.completedAt for de-duplication.")
        }

        try ZExerciseRun.dedupe(context,
                                exerciseArchiveID: exerciseArchiveID,
                                completedAt: completedAt,
                                inStore: inStore)
    }
}
