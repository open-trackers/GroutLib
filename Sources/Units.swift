//
//  Units.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
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
            ""
        case .pounds:
            "lb"
        case .kilograms:
            "kg"
        case .minutes:
            "m"
        case .seconds:
            "s"
        }
    }

    public var description: String {
        switch self {
        case .none:
            "none"
        case .pounds:
            "pounds"
        case .kilograms:
            "kilograms"
        case .minutes:
            "minutes"
        case .seconds:
            "seconds"
        }
    }

    public var formattedDescription: String {
        if abbreviation.count == 0 {
            description.capitalized
        } else {
            "\(description.capitalized) (\(abbreviation))"
        }
    }

    public static func from(_ rawValue: Int16) -> Units {
        Units(rawValue: rawValue) ?? .none
    }
}
