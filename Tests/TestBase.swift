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

class TestCoreDataStack: NSObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let modelName = "Grout"
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: modelName, withExtension: ".momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}

class TestBase: XCTestCase {
    var testContainer: NSPersistentContainer!
    var testContext: NSManagedObjectContext!

    lazy var df = ISO8601DateFormatter()

    override func setUp() {
        testContainer = TestCoreDataStack().persistentContainer
        testContext = testContainer.viewContext
    }

    override func tearDown() {}
}
