//
//  TransferToArchiveTests.swift
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

final class CopyTests: TestBase {
    
    var mainStore: NSPersistentStore!
    var archiveStore: NSPersistentStore!

    var routineArchiveID = UUID()
    var exerciseArchiveID = UUID()

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
    
    func testReadOnly() throws {
        XCTAssertFalse(mainStore.isReadOnly)
        XCTAssertFalse(archiveStore.isReadOnly)
    }
    
    func testShallowCopyRoutine() throws {
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID, inStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))

        try sr.copy(testContext, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
    }
    
    func testShallowCopyExerciseWithRoutine() throws {
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID, inStore: mainStore)
        let se = ZExercise.create(testContext, zRoutine: sr, exerciseName: "bleh", exerciseArchiveID: exerciseArchiveID)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: archiveStore))

        // routine needs to get to archive first
        try sr.copy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }
        
        // now the exercise
        try se.copy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: archiveStore))
    }
}
