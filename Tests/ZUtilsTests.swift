//
//  ZUtilsTests.swift
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

final class ZUtilsTests: TestBase {
    func testRoutineKeepAt() throws {
        let uuid = UUID()
        let startDate = Date.now
        let r = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: uuid)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, duration: 1)
        try testContext.save()

        XCTAssertFalse(r.isDeleted)
        XCTAssertFalse(rr.isDeleted)
        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: uuid))
        XCTAssertEqual(1, try ZRoutineRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: startDate)
        try testContext.save()

        XCTAssertFalse(r.isDeleted)
        XCTAssertFalse(rr.isDeleted)
        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: uuid))
        XCTAssertEqual(1, try ZRoutineRun.count(testContext))
    }

    func testRoutineDumpEarlierThan() throws {
        let uuid = UUID()
        let startDate = Date.now
        let r = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: uuid)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, duration: 1)
        try testContext.save()

        XCTAssertFalse(r.isDeleted)
        XCTAssertFalse(rr.isDeleted)
        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: uuid))
        XCTAssertEqual(1, try ZRoutineRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: startDate.addingTimeInterval(1))
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: uuid))
        XCTAssertEqual(0, try ZRoutineRun.count(testContext))
    }

    func testExerciseKeepAt() throws {
        let rUUID = UUID()
        let eUUID = UUID()
        let startDate = Date.now
        let completeDate = startDate
        let r = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: rUUID)
        let _ = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, duration: 1)
        let e = ZExercise.create(testContext, zRoutine: r, exerciseName: "blah", exerciseArchiveID: eUUID)
        let ee = ZExerciseRun.create(testContext, zExercise: e, completedAt: completeDate, intensity: 1)
        try testContext.save()

        XCTAssertFalse(e.isDeleted)
        XCTAssertFalse(ee.isDeleted)
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: eUUID))
        XCTAssertEqual(1, try ZExerciseRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: completeDate)
        try testContext.save()

        XCTAssertFalse(e.isDeleted)
        XCTAssertFalse(ee.isDeleted)
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: eUUID))
        XCTAssertEqual(1, try ZExerciseRun.count(testContext))
    }

    func testExerciseDumpEarlierThan() throws {
        let rUUID = UUID()
        let eUUID = UUID()
        let startDate = Date.now
        let completeDate = startDate
        let r = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: rUUID)
        let _ = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, duration: 1)
        let e = ZExercise.create(testContext, zRoutine: r, exerciseName: "blah", exerciseArchiveID: eUUID)
        let ee = ZExerciseRun.create(testContext, zExercise: e, completedAt: completeDate, intensity: 1)
        try testContext.save()

        XCTAssertFalse(e.isDeleted)
        XCTAssertFalse(ee.isDeleted)
        XCTAssertNotNil(try ZExercise.get(testContext, forArchiveID: eUUID))
        XCTAssertEqual(1, try ZExerciseRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: completeDate.addingTimeInterval(1))
        try testContext.save()

        XCTAssertNil(try ZExercise.get(testContext, forArchiveID: eUUID))
        XCTAssertEqual(0, try ZExerciseRun.count(testContext))
    }

    func testTransferToArchive() throws {}
}
