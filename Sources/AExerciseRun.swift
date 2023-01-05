//
//  File.swift
//
//
//  Created by Reed Esau on 1/4/23.
//

import CoreData

extension AExerciseRun {
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, aexercise _: AExercise, completedAt: Date, intensity: Float) -> AExerciseRun {
        let nu = AExerciseRun(context: context)
        nu.completedAt = completedAt
        nu.intensity = intensity
        return nu
    }
}
