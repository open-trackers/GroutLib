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

extension ZExerciseRun {
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, zExercise: ZExercise, completedAt: Date, intensity: Float) -> ZExerciseRun {
        let nu = ZExerciseRun(context: context)
        nu.zExercise = zExercise
        nu.completedAt = completedAt
        nu.intensity = intensity
        return nu
    }
}
