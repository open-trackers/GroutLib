//
//  CleanLogRecordTests.swift
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

final class CleanLogRecordTests: TestBase {
    func testRoutineKeepAt() throws {
        let uuid = UUID()
        let startDate = Date.now
        let r = ZRoutine.create(testContext, routineArchiveID: uuid, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, duration: 1, toStore: mainStore)
        try testContext.save()

        XCTAssertFalse(r.isDeleted)
        XCTAssertFalse(rr.isDeleted)
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: uuid))
        XCTAssertEqual(1, try ZRoutineRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: startDate)
        try testContext.save()

        XCTAssertFalse(r.isDeleted)
        XCTAssertFalse(rr.isDeleted)
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: uuid))
        XCTAssertEqual(1, try ZRoutineRun.count(testContext))
    }

    func testRoutineDumpEarlierThan() throws {
        let uuid = UUID()
        let startDate = Date.now
        let r = ZRoutine.create(testContext, routineArchiveID: uuid, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, duration: 1, toStore: mainStore)
        try testContext.save()

        XCTAssertFalse(r.isDeleted)
        XCTAssertFalse(rr.isDeleted)
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: uuid))
        XCTAssertEqual(1, try ZRoutineRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: startDate.addingTimeInterval(1))
        try testContext.save()

        XCTAssertEqual(0, try ZRoutineRun.count(testContext))

        // TODO: need to purge orphaned ZRoutines
        // XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: uuid))
    }

    func testExerciseKeepAt() throws {
        let rUUID = UUID()
        let eUUID = UUID()
        let startDate = Date.now
        let completeDate = startDate
        let r = ZRoutine.create(testContext, routineArchiveID: rUUID, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, duration: 1, toStore: mainStore)
        let e = ZExercise.create(testContext, zRoutine: r, exerciseArchiveID: eUUID, exerciseName: "blah", exerciseUnits: .kilograms, toStore: mainStore)
        let ee = ZExerciseRun.create(testContext, zRoutineRun: rr, zExercise: e, completedAt: completeDate, intensity: 1, toStore: mainStore)
        try testContext.save()

        XCTAssertFalse(e.isDeleted)
        XCTAssertFalse(ee.isDeleted)
        XCTAssertNotNil(try ZExercise.get(testContext, routineArchiveID: rUUID, exerciseArchiveID: eUUID))
        XCTAssertEqual(1, try ZExerciseRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: completeDate)
        try testContext.save()

        XCTAssertFalse(e.isDeleted)
        XCTAssertFalse(ee.isDeleted)
        XCTAssertNotNil(try ZExercise.get(testContext, routineArchiveID: rUUID, exerciseArchiveID: eUUID))
        XCTAssertEqual(1, try ZExerciseRun.count(testContext))
    }

    func testExerciseDumpEarlierThan() throws {
        let rUUID = UUID()
        let eUUID = UUID()
        let startDate = Date.now
        let completeDate = startDate
        let r = ZRoutine.create(testContext, routineArchiveID: rUUID, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, duration: 1, toStore: mainStore)
        let e = ZExercise.create(testContext, zRoutine: r, exerciseArchiveID: eUUID, exerciseName: "blah", exerciseUnits: .kilograms, toStore: mainStore)
        let ee = ZExerciseRun.create(testContext, zRoutineRun: rr, zExercise: e, completedAt: completeDate, intensity: 1, toStore: mainStore)
        try testContext.save()

        XCTAssertFalse(e.isDeleted)
        XCTAssertFalse(ee.isDeleted)
        XCTAssertNotNil(try ZExercise.get(testContext, routineArchiveID: rUUID, exerciseArchiveID: eUUID))
        XCTAssertEqual(1, try ZExerciseRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: completeDate.addingTimeInterval(1))
        try testContext.save()

        XCTAssertEqual(0, try ZExerciseRun.count(testContext))

        // TODO: need to purge orphaned ZExercises
        // XCTAssertNil(try ZExercise.get(testContext, exerciseArchiveID: eUUID))
    }
}
