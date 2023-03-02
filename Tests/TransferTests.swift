//
//  TransferTests.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

@testable import GroutLib
import XCTest

final class TransferTests: TestBase {
    var mainStore: NSPersistentStore!
    var archiveStore: NSPersistentStore!

    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let mainStore = PersistenceManager.getStore(testContext, .main),
              let archiveStore = PersistenceManager.getStore(testContext, .archive)
        else {
            throw TrackerError.invalidStoreConfiguration(msg: "setup")
        }

        self.mainStore = mainStore
        self.archiveStore = archiveStore
    }

    func testRoutine() throws {
        _ = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))

        try transferToArchive(testContext)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
    }

    func testRoutineWithRoutineRun() throws {
        let startedAt = Date()
        let duration: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        _ = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, duration: duration)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))

        try transferToArchive(testContext)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
    }

    func testRoutineWithExercise() throws {
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        _ = ZExercise.create(testContext, zRoutine: sr, exerciseName: "bleh", exerciseUnits: .kilograms, exerciseArchiveID: exerciseArchiveID)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))

        try transferToArchive(testContext)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))
    }

    func testRoutineWithExerciseAndExerciseRun() throws {
        let completedAt = Date()
        let intensity: Float = 30.0
        let startedAt = Date()
        let duration: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        let se = ZExercise.create(testContext, zRoutine: sr, exerciseName: "bleh", exerciseUnits: .kilograms, exerciseArchiveID: exerciseArchiveID)
        let srr = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, duration: duration)
        _ = ZExerciseRun.create(testContext, zRoutineRun: srr, zExercise: se, completedAt: completedAt, intensity: intensity)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        try transferToArchive(testContext)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: archiveStore))
    }
}
