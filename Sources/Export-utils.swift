//
//  Export-utils.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

public enum ExportFormat: String, CaseIterable, CustomStringConvertible {
    case CSV = "text/csv"
    case TSV = "text/tab-separated-values"
    case JSON = "application/json"

    public var description: String {
        switch self {
        case .CSV:
            return "Comma-delimited"
        case .TSV:
            return "Tab-delimited"
        case .JSON:
            return "JSON"
        }
    }

    public var delimiter: Character? {
        switch self {
        case .CSV:
            return ","
        case .TSV:
            return "\t"
        default:
            return nil
        }
    }

    public var defaultFileExtension: String {
        switch self {
        case .CSV:
            return "csv"
        case .TSV:
            return "tsv"
        case .JSON:
            return "json"
        }
    }
}

public func exportData<T>(_ records: [T],
                          format: ExportFormat) throws -> Data
    where T: MAttributable & Encodable
{
    if format == .JSON {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(records)
    }

    guard let delimiter = format.delimiter
    else { throw DataError.encodingError(msg: "Format \(format.rawValue) not supported for export.") }
    let encoder = DelimitedEncoder(delimiter: String(delimiter))
    let headers = MAttribute.getHeaders(T.attributes)
    _ = try encoder.encode(headers: headers)
    return try encoder.encode(rows: records)
}
