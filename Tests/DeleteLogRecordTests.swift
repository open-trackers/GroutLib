//
//  DeleteLogRecordTests.swift
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

final class DeleteLogRecordTests: TestBase {
    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testZRoutineRunFromBothStores() throws {
        let startedAt = Date.now
        let r = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID, toStore: mainStore)
        _ = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startedAt, duration: 1, toStore: mainStore)
        // try testContext.save()
        _ = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))

        try ZRoutineRun.delete(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: nil)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
    }

    func testZExerciseRunFromBothStores() throws {
        let startedAt = Date.now
        let completedAt = startedAt + 1000
        let r = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID, toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startedAt, duration: 1, toStore: mainStore)
        let e = ZExercise.create(testContext, zRoutine: r, exerciseName: "bleh", exerciseUnits: .kilograms, exerciseArchiveID: exerciseArchiveID, toStore: mainStore)
        _ = ZExerciseRun.create(testContext, zRoutineRun: rr, zExercise: e, completedAt: completedAt, intensity: 1, toStore: mainStore)
        // try testContext.save()
        _ = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: archiveStore))

        try ZExerciseRun.delete(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: nil)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))
        XCTAssertNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: archiveStore))
    }
}
