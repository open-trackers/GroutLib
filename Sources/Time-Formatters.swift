//
//  Time-Formatters.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public enum TimeElapsedFormat {
    case hh_mm
    case hh_mm_ss
    case mm_ss
}

/// Format elapsed seconds from 00:00:00 up to 23:59:59 (HH:MM:SS), or up to (but not including) what the format will accommodate.
public func formatElapsed(seconds: UInt, timeElapsedFormat: TimeElapsedFormat = .hh_mm_ss) -> String? {
    let secondsPerHour: UInt = 3600
    let secondsPerDay: UInt = 24 * secondsPerHour

    let upperBound: UInt = {
        switch timeElapsedFormat {
        case .hh_mm:
            return secondsPerDay
        case .hh_mm_ss:
            return secondsPerDay
        case .mm_ss:
            return secondsPerHour
        }
    }()
    guard (0 ..< upperBound).contains(seconds) else { return nil }

    let hours = seconds / 60 / 60
    let mins = seconds / 60 % 60
    let secs = seconds % 60

    switch timeElapsedFormat {
    case .hh_mm:
        return String(format: "%02i:%02i", hours, mins)
    case .hh_mm_ss:
        return String(format: "%02i:%02i:%02i", hours, mins, secs)
    case .mm_ss:
        return String(format: "%02i:%02i", mins, secs)
    }
}

/// Format elapsed TimeInterval from 00:00:00 up to 23:59:59 (HH:MM:SS), or up to (but not including) one day.
/// Fractions of a second are ignored.
public func formatElapsed(timeInterval: TimeInterval, timeElapsedFormat: TimeElapsedFormat = .hh_mm_ss) -> String? {
    guard timeInterval >= 0 else { return nil }
    return formatElapsed(seconds: UInt(timeInterval), timeElapsedFormat: timeElapsedFormat)
}
