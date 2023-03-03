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
    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    let completedAt1Str = "2023-01-01T05:00:00Z"
    var completedAt1: Date!
    let completedAt2Str = "2023-01-02T05:00:00Z"
    var completedAt2: Date!
    let completedAt3Str = "2023-01-03T05:00:00Z"
    var completedAt3: Date!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        completedAt1 = df.date(from: completedAt1Str)
        completedAt2 = df.date(from: completedAt2Str)
        completedAt3 = df.date(from: completedAt3Str)

    }

    func testRoutine() throws {
        _ = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
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

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

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

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore)
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
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let se = ZExercise.create(testContext, zRoutine: sr, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", exerciseUnits: .kilograms, toStore: mainStore)
        let srr = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, duration: duration, toStore: mainStore)
        _ = ZExerciseRun.create(testContext, zRoutineRun: srr, zExercise: se, completedAt: completedAt, intensity: intensity, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore)
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
    
    func testIncludesCopyOfExerciseRunWhereUserRemoved() throws {
//        let startedAt = "2022-12-20"
//        let completedAt3 = "16:03"
//        let completedAt5 = "16:05"
//        let completedAt7 = "16:07"
        let startedAt = Date()
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let se = ZExercise.create(testContext, zRoutine: sr, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", toStore: mainStore)
        let dr = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, toStore: mainStore)
        _ = ZExerciseRun.create(testContext, zRoutineRun: dr, zExercise: se, completedAt: completedAt1, toStore: mainStore)
        let sr5 = ZExerciseRun.create(testContext, zRoutineRun: dr, zExercise: se, completedAt: completedAt2, toStore: mainStore)
        _ = ZExerciseRun.create(testContext, zRoutineRun: dr, zExercise: se, completedAt: completedAt3, toStore: mainStore)
        sr5.userRemoved = true
        try testContext.save()

        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt1, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt2, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt3, inStore: mainStore))

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore) //, startOfDay: startOfDay, now: now, tz: tz)
        try testContext.save()

        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt1, inStore: archiveStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt2, inStore: archiveStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt3, inStore: archiveStore))
    }
}
