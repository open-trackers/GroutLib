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

    override func setUpWithError() throws {
        // NOTE: not using inMemory stores, for two reasons:
        // (1) We're using two stores, where /dev/null may not be usable for both
        // (2) Batch delete may not be supported for inMemory

        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
        let defaultURL = defaultDirectoryURL.appendingPathComponent("TestGrout.sqlite")
        let archiveURL = defaultDirectoryURL.appendingPathComponent("TestGroutArchive.sqlite")

        let modelName = PersistenceManager.modelName
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: modelName, withExtension: ".momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!

        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)

        let defaultDescription = NSPersistentStoreDescription()
        defaultDescription.url = defaultURL

        let archiveDescription = NSPersistentStoreDescription()
        archiveDescription.url = archiveURL
        archiveDescription.configuration = "Archive"

        container.persistentStoreDescriptions = [defaultDescription, archiveDescription]

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // clear all earlier data
        try container.viewContext.deleter(entityName: "Exercise")
        try container.viewContext.deleter(entityName: "Routine")
        try container.viewContext.deleter(entityName: "ZExercise")
        try container.viewContext.deleter(entityName: "ZRoutine")
        try container.viewContext.deleter(entityName: "ZExerciseRun")
        try container.viewContext.deleter(entityName: "ZRoutineRun")

        testContainer = container
        testContext = testContainer.viewContext
    }
}
