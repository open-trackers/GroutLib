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
    public var testCoreDataStack: CoreDataStack!
    public var testContainer: NSPersistentContainer!
    public var testContext: NSManagedObjectContext!
    public var mainStore: NSPersistentStore!
    public var archiveStore: NSPersistentStore!

    lazy var df = ISO8601DateFormatter()

    override open func setUpWithError() throws {
        try super.setUpWithError()
        testCoreDataStack = CoreDataStack.getPreviewStack()
        testContainer = testCoreDataStack.container
        testContext = testContainer.viewContext

        mainStore = testCoreDataStack.getMainStore(testContext)
        archiveStore = testCoreDataStack.getArchiveStore(testContext)
    }
}
