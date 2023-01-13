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
    case missingData(msg: String)
    case invalidStoreConfiguration(msg: String)
    case encodingError(msg: String)
    case archiveCreationFailure

    var description: String {
        switch self {
        case let .fetchError(msg): return "Data fetch error: \(msg)"
        case let .missingData(msg): return "Missing data: \(msg)"
        case let .invalidStoreConfiguration(msg): return "Invalid store configuration: \(msg)"
        case let .encodingError(msg): return "Encoding error: \(msg)"
        case .archiveCreationFailure: return "Archive creation failure."
        }
    }
}
