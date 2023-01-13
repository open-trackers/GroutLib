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

public enum ExportFormat: String, CaseIterable {
    case JSON = "application/json"
    case CSV = "text/csv"
    case TSV = "text/tab-separated-values"

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

    public var defaultFileExtension: String? {
        switch self {
        case .JSON:
            return "json"
        case .CSV:
            return "csv"
        case .TSV:
            return "tsv"
        }
    }
}

public func exportData<T>(_ records: [T],
                          format: ExportFormat) throws -> Data
    where T: MAttributable & Encodable
{
    guard let delimiter = format.delimiter
    else { throw DataError.encodingError(msg: "Format \(format.rawValue) not supported for export.") }
    let encoder = DelimitedEncoder(delimiter: String(delimiter))
    let headers = MAttribute.getHeaders(T.attributes)
    _ = try encoder.encode(headers: headers)
    return try encoder.encode(rows: records)
}

/*
  private func exportAction() {
      let finFormat = AllocFormat.CSV
      if let data = try? exportData(model.valuationSnapshots, format: finFormat),
         let ext = finFormat.defaultFileExtension
      {
          let name = MValuationSnapshot.entityName.plural.replacingOccurrences(of: " ", with: "-")
 #if os(macOS)
          NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
 #endif
      }
  }

  */
