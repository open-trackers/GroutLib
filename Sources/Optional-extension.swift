//
//  Optional-extension.swift
//
// Copyright 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation


//extension RawRepresentable {
//    public init?(rawValue optionalRawValue: RawValue?) {
//        guard let rawValue = optionalRawValue,
//              let value = Self(rawValue: rawValue)
//        else { return nil }
//        self = value
//    }
//}

// via markiv on StackOverflow
extension Optional: RawRepresentable where Wrapped: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        //value.absoluteString
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }
}

