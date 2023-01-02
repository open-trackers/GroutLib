//
//  SystemImageUtils.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// system image for 0...50 in a shape, where .circle or .square is appended
public func systemImagePrefix(_ value: Int, defaultName: String = "questionmark") -> String {
    let val: String = {
        switch value {
        case 4, 6, 9:
            return "\(value).alt"
        case 0 ... 50:
            return "\(value)"
        default:
            return defaultName
        }
    }()
    return val
}
