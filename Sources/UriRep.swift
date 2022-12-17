//
//  UriRep.swift
//
// Copyright 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

/// Strongly-typed wrapper for an NSManagedObject uri representation.
///
/// Struct providing archivable reference to the managed object (Routine or Exercise).
/// Codable for use in NavigationStack, State, and UserActivity.
/// Identifiable for use in .sheet and .fullScreenCover.
/// RawRepresentable so that it can be stored in SceneStorage or AppStorage.
/// Typed for use as a navigationDestination.
public struct UriRep<T: NSManagedObject>: Hashable, Codable, Identifiable, RawRepresentable {
    public let value: URL

    public init(value: URL) {
        self.value = value
    }

    public var id: Int { value.hashValue }

    enum CodingKeys: String, CodingKey {
        case value
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        value = try values.decode(URL.self, forKey: .value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(UriRep.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }
}
