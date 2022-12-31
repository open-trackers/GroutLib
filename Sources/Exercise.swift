//
//  Exercise.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@objc(Exercise)
public class Exercise: NSManagedObject {}

extension Exercise: UserOrdered {}

public extension Exercise {
    // NOTE: does NOT save to context
    static func create(_ context: NSManagedObjectContext, userOrder: Int16) -> Exercise {
        let nu = Exercise(context: context)
        nu.userOrder = userOrder
        nu.name = "New Exercise"
        nu.archiveID = UUID()
        return nu
    }

    static func get(_ context: NSManagedObjectContext, forURIRepresentation url: URL) -> Exercise? {
        NSManagedObject.get(context, forURIRepresentation: url) as? Exercise
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }
}

public extension Exercise {
    var isStepFractional: Bool {
        isFractional(value: intensityStep, accuracy: 0.1)
    }

    var isDone: Bool {
        lastCompletedAt != nil
    }

    /// Format an intensity value, such as lastIntensity and intensityStep.
    func formatIntensity(_ intensityValue: Float, withUnits: Bool = false) -> String {
        let suffix: String = {
            let abbrev = Units(rawValue: self.units)?.abbreviation ?? ""
            return withUnits ? " \(abbrev)" : ""
        }()
        let specifier = "%0.\(isStepFractional ? 1 : 0)f\(suffix)"
        return String(format: specifier, intensityValue)
    }
}
