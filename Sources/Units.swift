//
//  Units.swift
//
// Copyright 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public enum Units: Int16, CaseIterable {
    case none = 0
    case pounds = 1
    case kilograms = 2
    case minutes = 3
    case seconds = 4

    public var abbreviation: String {
        switch self {
        case .none:
            return ""
        case .pounds:
            return "lb"
        case .kilograms:
            return "kg"
        case .minutes:
            return "m"
        case .seconds:
            return "s"
        }
    }

    public var description: String {
        switch self {
        case .none:
            return "none"
        case .pounds:
            return "pounds"
        case .kilograms:
            return "kilograms"
        case .minutes:
            return "minutes"
        case .seconds:
            return "seconds"
        }
    }

    public var formattedDescription: String {
        if abbreviation.count == 0 {
            return description.capitalized
        } else {
            return "\(description.capitalized) (\(abbreviation))"
        }
    }

    public static func from(_ rawValue: Int16) -> Units {
        Units(rawValue: rawValue) ?? .none
    }
}
