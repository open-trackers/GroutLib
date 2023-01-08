//
//  DeepCopyTests.swift
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

final class DeepCopyTests: TestBase {
    var mainStore: NSPersistentStore!
    var archiveStore: NSPersistentStore!

    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let mainURL = PersistenceManager.stores[.main]?.url,
              let archiveURL = PersistenceManager.stores[.archive]?.url,
              let psc = testContext.persistentStoreCoordinator,
              let mainStore = psc.persistentStore(for: mainURL),
              let archiveStore = psc.persistentStore(for: archiveURL)
        else {
            throw DataError.fetchError(msg: "Archive store not found")
        }

        self.mainStore = mainStore
        self.archiveStore = archiveStore
    }

    func testRoutine() throws {
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID, inStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))

        let objectIDs = try ZRoutine.deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([sr.objectID], objectIDs)

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
    }

    func testRoutineWithRoutineRun() throws {}

    func testRoutineWithExercise() throws {}

    func testRoutineWithExerciseAndExerciseRun() throws {}
}
