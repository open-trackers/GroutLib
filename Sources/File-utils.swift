//
//  File-utils.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public func generateTimestampFileName(prefix: String, suffix: String, timestamp: Date = Date.now) -> String {
    let df = ISO8601DateFormatter()

    // unable to get this implementation working yet
//    let dateStr = df.string(from: timestamp)
//    let regex = /[^0-9]/
//    let cleanStr = dateStr.replacing(regex, with: "")
//    return "\(prefix)\(cleanStr)\(suffix)"

    // primitive implementation
    return prefix +
        df.string(from: timestamp)
        .replacingOccurrences(of: ":", with: "")
        .replacingOccurrences(of: "T", with: "")
        .replacingOccurrences(of: "Z", with: "")
        .replacingOccurrences(of: "-", with: "") + suffix
}
