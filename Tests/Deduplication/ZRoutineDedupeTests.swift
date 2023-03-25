//
//  ZRoutineDedupeTests.swift
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

final class ZRoutineDedupeTests: TestBase {
    let routineArchiveID1 = UUID()
    let routineArchiveID2 = UUID()
    let exerciseArchiveID1 = UUID()
    let exerciseArchiveID2 = UUID()
    let name1 = "blah1"
    let name2 = "blah2"

    let date1Str = "2023-01-02T21:00:01Z"
    var date1: Date!
    let date2Str = "2023-01-02T21:00:02Z"
    var date2: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        date1 = df.date(from: date1Str)
        date2 = df.date(from: date2Str)
    }

    func testDifferentArchiveID() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: name1, createdAt: date1, toStore: mainStore)
        let c2 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID2, routineName: name2, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZRoutine.dedupe(testContext, routineArchiveID: routineArchiveID1, inStore: mainStore)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(c2.isDeleted)
    }

    func testSameArchiveID() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: name1, createdAt: date1, toStore: mainStore)
        let c2 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: name2, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZRoutine.dedupe(testContext, routineArchiveID: routineArchiveID1, inStore: mainStore)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertTrue(c2.isDeleted)
    }

    func testDupeConsolidateExercises() throws {
        // same routineArchiveID
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: name1, createdAt: date1, toStore: mainStore)
        let c2 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: name1, createdAt: date2, toStore: mainStore)

        let s1 = ZExercise.create(testContext, zRoutine: c1, exerciseArchiveID: exerciseArchiveID1, exerciseName: name1, toStore: mainStore)
        let s2 = ZExercise.create(testContext, zRoutine: c2, exerciseArchiveID: exerciseArchiveID2, exerciseName: name2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZRoutine.dedupe(testContext, routineArchiveID: routineArchiveID1, inStore: mainStore)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertTrue(c2.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)

        XCTAssertEqual(2, c1.zExercises?.count) // consolidated
        XCTAssertEqual(0, c2.zExercises?.count)
    }
}
