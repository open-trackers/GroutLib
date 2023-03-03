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

import TrackerLib

@testable import GroutLib
import XCTest

final class DeepCopyTests: TestBase {
    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testRoutine() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))

        let sZRoutines = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([sr], sZRoutines)

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
    }

    func testRoutineWithRoutineRun() throws {
        let startedAt = Date()
        let duration: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        _ = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, duration: duration, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))

        let sZRoutines = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([sr], sZRoutines)

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
    }

    func testRoutineWithExercise() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        _ = ZExercise.create(testContext, zRoutine: sr, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", exerciseUnits: .kilograms, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))

        let sZRoutines = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([sr], sZRoutines)

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))
    }

    func testRoutineWithExerciseAndExerciseRun() throws {
        let completedAt = Date()
        let intensity: Float = 30.0
        let startedAt = Date()
        let duration: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let se = ZExercise.create(testContext, zRoutine: sr, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", exerciseUnits: .kilograms, toStore: mainStore)
        let srr = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, duration: duration, toStore: mainStore)
        _ = ZExerciseRun.create(testContext, zRoutineRun: srr, zExercise: se, completedAt: completedAt, intensity: intensity, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        let sZRoutines = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([sr], sZRoutines)

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: archiveStore))
    }
}
