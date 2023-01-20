//
//  Misc-Formatters.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation


public func formatIntensity(_ intensityValue: Float,
                            units: Units = .none,
                            withUnits: Bool = false,
                            isFractional: Bool = false) -> String {
    let suffix: String = {
        guard withUnits,
              units != .none
        else { return "" }
        let abbrev = units.abbreviation
        return " \(abbrev)"
    }()
    let specifier = "%0.\(isFractional ? 1 : 0)f\(suffix)"
    return String(format: specifier, intensityValue)
}
