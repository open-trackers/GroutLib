//
//  ExerciseDedupeTests.swift
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

final class ExerciseDedupeTests: TestBase {
    let routineArchiveID1 = UUID()
    let routineArchiveID2 = UUID()
    let exerciseArchiveID1 = UUID()
    let exerciseArchiveID2 = UUID()

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
        let c1 = Routine.create(testContext, userOrder: 10, archiveID: routineArchiveID1, createdAt: date1)
        let s1 = Exercise.create(testContext, routine: c1, userOrder: 4, archiveID: exerciseArchiveID1, createdAt: date1)
        let s2 = Exercise.create(testContext, routine: c1, userOrder: 8, archiveID: exerciseArchiveID2, createdAt: date2)
        try testContext.save() // needed for fetch request to work properly

        try Exercise.dedupe(testContext, routineArchiveID: routineArchiveID1, exerciseArchiveID: exerciseArchiveID1)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
    }

    func testSameArchiveIdWithinRoutine() throws {
        let c1 = Routine.create(testContext, userOrder: 10, archiveID: routineArchiveID1, createdAt: date1)
        let s1 = Exercise.create(testContext, routine: c1, userOrder: 4, archiveID: exerciseArchiveID1, createdAt: date1)
        let s2 = Exercise.create(testContext, routine: c1, userOrder: 8, archiveID: exerciseArchiveID1, createdAt: date2)
        try testContext.save() // needed for fetch request to work properly

        try Exercise.dedupe(testContext, routineArchiveID: routineArchiveID1, exerciseArchiveID: exerciseArchiveID1)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertTrue(s2.isDeleted)
    }

    func testSameArchiveIdOutsideRoutine() throws {
        let c1 = Routine.create(testContext, userOrder: 10, archiveID: routineArchiveID1, createdAt: date1)
        let c2 = Routine.create(testContext, userOrder: 11, archiveID: routineArchiveID2, createdAt: date2)
        let s1 = Exercise.create(testContext, routine: c1, userOrder: 4, archiveID: exerciseArchiveID1, createdAt: date1)
        let s2 = Exercise.create(testContext, routine: c2, userOrder: 8, archiveID: exerciseArchiveID1, createdAt: date2)
        try testContext.save() // needed for fetch request to work properly

        try Exercise.dedupe(testContext, routineArchiveID: routineArchiveID1, exerciseArchiveID: exerciseArchiveID1)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(c2.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
    }
}
