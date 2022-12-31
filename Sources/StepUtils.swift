//
//  StepUtils.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public func isFractional(value: Float, accuracy: Float = 0.1) -> Bool {
    let v = abs(value)
    let f = floor(v)
    let remainder = v - f // 0.0 ... 1.0
    let adjrem = remainder > 0.5 ? 1.0 - remainder : remainder // 0.0 ... 0.5

    if adjrem >= accuracy { return true }

    // it may be close, so see if it's within +/- 1% of accuracy
    let diff2 = abs(adjrem - accuracy)
    return diff2 < (accuracy / 100)
}
