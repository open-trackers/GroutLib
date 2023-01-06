//
//  MTestbase.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@testable import GroutLib
import XCTest

class TestBase: XCTestCase {
    var testContainer: NSPersistentContainer!
    var testContext: NSManagedObjectContext!

    lazy var df = ISO8601DateFormatter()

    override func setUp() {
        testContainer = PersistenceManager.preview.container
        testContext = testContainer.viewContext
    }

    override func tearDown() {
    }
}
