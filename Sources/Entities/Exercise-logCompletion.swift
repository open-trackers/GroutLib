//
//  Exercise-logCompletion.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension Exercise {
    /// log the run of the exercise to the main store
    /// (These will later be transferred to the archive store on iOS devices)
    ///
    /// If ZRoutineRun for the exercise has been deleted, possibly on another device,
    /// it's userRemoved flag will be set back to 'false'.
    ///
    /// NOTE: does NOT save context
    func logCompletion(_ context: NSManagedObjectContext,
                       mainStore: NSPersistentStore,
                       routineStartedAt: Date,
                       nuDuration: TimeInterval,
                       exerciseCompletedAt: Date,
                       exerciseIntensity: Float) throws
    {
        guard let routine else {
            throw TrackerError.missingData(msg: "Unexpectedly no routine. Cannot log exercise run.")
        }

        // Get corresponding ZRoutine for log, creating if necessary.
        let routineArchiveID: UUID = {
            if routine.archiveID == nil {
                routine.archiveID = UUID()
            }
            return routine.archiveID!
        }()
        let zRoutine = try ZRoutine.getOrCreate(context,
                                                routineArchiveID: routineArchiveID,
                                                // routineName: routine.wrappedName,
                                                inStore: mainStore)
        { _, element in
            element.name = routine.wrappedName
        }

        // Get corresponding ZExercise for log, creating if necessary.
        let exerciseArchiveID: UUID = {
            if self.archiveID == nil {
                self.archiveID = UUID()
            }
            return self.archiveID!
        }()
        let zExercise = try ZExercise.getOrCreate(context,
                                                  zRoutine: zRoutine,
                                                  exerciseArchiveID: exerciseArchiveID,
                                                  // exerciseName: wrappedName,
                                                  // exerciseUnits: Units(rawValue: units) ?? .none,
                                                  inStore: mainStore)
        { _, element in
            element.name = wrappedName
            element.units = units
        }

        let zRoutineRun = try ZRoutineRun.getOrCreate(context,
                                                      zRoutine: zRoutine,
                                                      startedAt: routineStartedAt,
                                                      // duration: nuDuration,
                                                      inStore: mainStore)
        { _, element in
            element.duration = nuDuration
            element.userRemoved = false // removal may have happened on another device; we're reversing it
        }

        _ = try ZExerciseRun.getOrCreate(context,
                                         zRoutineRun: zRoutineRun,
                                         zExercise: zExercise,
                                         completedAt: exerciseCompletedAt,
                                         // intensity: exerciseIntensity,
                                         inStore: mainStore)
        { _, element in
            element.intensity = exerciseIntensity
        }

        // update the widget(s), if any
        try WidgetEntry.refresh(context,
                                reload: true,
                                defaultColor: .accentColor)
    }
}
