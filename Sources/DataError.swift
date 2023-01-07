//
//  DataError.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

/// Data layer errors
public enum DataError: Error, Equatable {
    case fetchError(msg: String)
    case missingArchiveID(msg: String)
    case moveError(msg: String)

    var description: String {
        switch self {
        case let .fetchError(msg): return "Data fetch error: \(msg)"
        case let .missingArchiveID(msg): return "Missing archiveID: \(msg)"
        case let .moveError(msg): return "Move error: \(msg)"
        }
    }
}
