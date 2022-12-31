//
//  StepUtils.swift
//
// Copyright 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public func isFractional(value: Float, accuracy: Float = 0.1) -> Bool {
    let remainder = abs(value.truncatingRemainder(dividingBy: 1))
    let multiplier = 1 / accuracy
    let rounded = (multiplier * remainder).rounded(.toNearestOrEven)
    let result = (1 <= rounded && rounded <= (multiplier - 1))
    //print("\(result) value=\(value) remainder=\(remainder) rounded=\(rounded)")
    return result
}
