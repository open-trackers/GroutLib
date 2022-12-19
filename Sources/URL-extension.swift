//
//  URL-extension.swift
//
// Copyright 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Extension to support selection of URL in .sheet/.fullScreenCover
extension URL: Identifiable {
    public var id: Int {
        hashValue
    }
}
