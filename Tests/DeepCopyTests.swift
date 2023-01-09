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

        guard let mainStore = PersistenceManager.getStore(testContext, .main),
              let archiveStore = PersistenceManager.getStore(testContext, .archive)
        else {
            throw DataError.invalidStoreConfiguration(msg: "setup")
        }

        self.mainStore = mainStore
        self.archiveStore = archiveStore
    }

    func testRoutine() throws {
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))

        let objectIDs = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([.zroutine: [sr.objectID]], objectIDs)

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
    }

    func testRoutineWithRoutineRun() throws {
        let startedAt = Date()
        let duration: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        let su = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, duration: duration)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))

        let objectIDs = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([.zroutinerun: [su.objectID], .zroutine: [sr.objectID]], objectIDs)

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
    }

    func testRoutineWithExercise() throws {
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        let se = ZExercise.create(testContext, zRoutine: sr, exerciseName: "bleh", exerciseArchiveID: exerciseArchiveID)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: archiveStore))

        let objectIDs = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([.zexercise: [se.objectID], .zroutine: [sr.objectID]], objectIDs)

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: archiveStore))
    }

    func testRoutineWithExerciseAndExerciseRun() throws {
        let completedAt = Date()
        let intensity: Float = 30.0
        let startedAt = Date()
        let duration: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        let se = ZExercise.create(testContext, zRoutine: sr, exerciseName: "bleh", exerciseArchiveID: exerciseArchiveID)
        let srr = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, duration: duration)
        let ser = ZExerciseRun.create(testContext, zRoutineRun: srr, zExercise: se, completedAt: completedAt, intensity: intensity)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, forArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        let objectIDs = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([.zexerciserun: [ser.objectID],
                        .zexercise: [se.objectID],
                        .zroutine: [sr.objectID],
                        .zroutinerun: [srr.objectID]], objectIDs)

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, forArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, forArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: exerciseArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, forArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: archiveStore))
    }
}
