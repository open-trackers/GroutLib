//
//  ZRoutineRunDedupeTests.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

@testable import GroutLib
import XCTest

final class ZRoutineRunDedupeTests: TestBase {
    let catArchiveID1 = UUID()
    let catArchiveID2 = UUID()
    let servArchiveID1 = UUID()
    let servArchiveID2 = UUID()

    let date1Str = "2023-01-02T21:00:00Z"
    var date1: Date!
    let date2Str = "2023-01-03T21:00:00Z"
    var date2: Date!
    let name1 = "blah1"
    let name2 = "blah2"
    let startedAt1Str = "2023-01-02T21:00:00Z"
    var startedAt1: Date!
    let startedAt2Str = "2023-01-03T21:00:00Z"
    var startedAt2: Date!
    let completedAt1Str = "2023-01-04T04:00:01Z"
    var completedAt1: Date!
    let completedAt2Str = "2023-01-04T04:00:02Z"
    var completedAt2: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        date1 = df.date(from: date1Str)
        date2 = df.date(from: date2Str)
        startedAt1 = df.date(from: startedAt1Str)
        startedAt2 = df.date(from: startedAt2Str)
        completedAt1 = df.date(from: completedAt1Str)
        completedAt2 = df.date(from: completedAt2Str)
    }

    func testDifferentConsumedDay() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: catArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        let dr1 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, duration: 10, createdAt: date1, toStore: mainStore)
        let dr2 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt2, duration: 10, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZRoutineRun.dedupe(testContext, routineArchiveID: catArchiveID1, startedAt: startedAt1, inStore: mainStore)

        XCTAssertFalse(dr1.isDeleted)
        XCTAssertFalse(dr2.isDeleted)
    }

    func testSameConsumedDay() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: catArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        let dr1 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, duration: 10, createdAt: date1, toStore: mainStore)
        let dr2 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, duration: 10, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZRoutineRun.dedupe(testContext, routineArchiveID: catArchiveID1, startedAt: startedAt1, inStore: mainStore)

        XCTAssertFalse(dr1.isDeleted)
        XCTAssertTrue(dr2.isDeleted)
    }

    func testDupeConsolidateExerciseRuns() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: catArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        // same startedAt
        let dr1 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, duration: 10, createdAt: date1, toStore: mainStore)
        let dr2 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, duration: 10, createdAt: date2, toStore: mainStore)

//        let c1 = ZRoutine.create(testContext, routineArchiveID: catArchiveID1, routineName: name1, createdAt: date1, toStore: mainStore)
        let s1 = ZExercise.create(testContext, zRoutine: c1, exerciseArchiveID: servArchiveID1, exerciseName: name1, createdAt: date1, toStore: mainStore)
        let s2 = ZExercise.create(testContext, zRoutine: c1, exerciseArchiveID: servArchiveID2, exerciseName: name1, createdAt: date2, toStore: mainStore)

        // note: does not dedupe exercise runs; it only consolidates them
        let r1 = ZExerciseRun.create(testContext, zRoutineRun: dr1, zExercise: s1, completedAt: completedAt1, toStore: mainStore)
        let r2 = ZExerciseRun.create(testContext, zRoutineRun: dr2, zExercise: s2, completedAt: completedAt2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZRoutineRun.dedupe(testContext, routineArchiveID: catArchiveID1, startedAt: startedAt1, inStore: mainStore)

        XCTAssertFalse(dr1.isDeleted)
        XCTAssertTrue(dr2.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
        XCTAssertFalse(r1.isDeleted)
        XCTAssertFalse(r2.isDeleted)

        XCTAssertEqual(1, s1.zExerciseRuns?.count) // not touched
        XCTAssertEqual(1, s2.zExerciseRuns?.count)

        XCTAssertEqual(2, dr1.zExerciseRuns?.count) // consolidated
        XCTAssertEqual(0, dr2.zExerciseRuns?.count)
    }
}
