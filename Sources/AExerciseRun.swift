//
//  File.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

extension AExerciseRun {
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, aexercise: AExercise, completedAt: Date, intensity: Float) -> AExerciseRun {
        let nu = AExerciseRun(context: context)
        nu.aExercise = aexercise
        nu.completedAt = completedAt
        nu.intensity = intensity
        return nu
    }
}
