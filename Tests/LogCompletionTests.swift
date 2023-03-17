//
//  LogCompletionTests.swift
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

final class LogCompletionTests: TestBase {
    let routineArchiveID = UUID()
    let exercise1ArchiveID = UUID()
    let exercise2ArchiveID = UUID()

    let startedAtStr = "2023-01-13T20:42:50Z"
    var startedAt: Date!
    let completedAt1Str = "2023-01-13T21:00:00Z"
    var completedAt1: Date!
    let completedAt2Str = "2023-01-13T21:10:00Z"
    var completedAt2: Date!

    let durationStr = "1332.0"
    var duration: TimeInterval!
    let intensity1Str = "105.5"
    var intensity1: Float!
    let intensity2Str = "55.5"
    var intensity2: Float!
    let intensityStepStr = "3.3"
    var intensityStep: Float!
    let userOrder1Str = "18"
    var userOrder1: Int16!
    let userOrder2Str = "20"
    var userOrder2: Int16!

    let thresholdSecs: TimeInterval = 86400

    override func setUpWithError() throws {
        try super.setUpWithError()

        startedAt = df.date(from: startedAtStr)
        completedAt1 = df.date(from: completedAt1Str)
        completedAt2 = df.date(from: completedAt2Str)
        duration = Double(durationStr)
        intensity1 = Float(intensity1Str)
        intensity2 = Float(intensity2Str)
        intensityStep = Float(intensityStepStr)
        userOrder1 = Int16(userOrder1Str)
        userOrder2 = Int16(userOrder2Str)
    }

    func testSimple() throws {
        let r = Routine.create(testContext, userOrder: 77, name: "bleh", archiveID: routineArchiveID)
        let e = Exercise.create(testContext, routine: r, userOrder: userOrder1, name: "bleep", archiveID: exercise1ArchiveID)
        e.routine = r
        e.lastIntensity = intensity1
        e.units = Units.kilograms.rawValue
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNil(try ZExercise.get(testContext, routineArchiveID: routineArchiveID, exerciseArchiveID: exercise1ArchiveID, inStore: mainStore))
        XCTAssertNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exercise1ArchiveID, completedAt: completedAt1, inStore: mainStore))

        try e.logCompletion(testContext, mainStore: mainStore, routineStartedAt: startedAt, nuDuration: duration, exerciseCompletedAt: completedAt1, exerciseIntensity: intensity1)
        try testContext.save()

        let zr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore)
        XCTAssertNotNil(zr)
        XCTAssertEqual(r.name, zr?.name)
        let zrr = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore)
        XCTAssertNotNil(zrr)
        XCTAssertEqual(duration, zrr?.duration)
        XCTAssertEqual(startedAt, zrr?.startedAt)
        let ze = try ZExercise.get(testContext, routineArchiveID: routineArchiveID, exerciseArchiveID: exercise1ArchiveID, inStore: mainStore)
        XCTAssertNotNil(ze)
        XCTAssertEqual(e.name, ze?.name)
        XCTAssertEqual(e.units, ze?.units)
        let zer = try ZExerciseRun.get(testContext, exerciseArchiveID: exercise1ArchiveID, completedAt: completedAt1, inStore: mainStore)
        XCTAssertNotNil(zer)
        XCTAssertEqual(completedAt1, zer?.completedAt)
        XCTAssertEqual(intensity1, zer?.intensity)
    }

    func testExerciseRunAfterTransfer() throws {
        /// ensure that a transfer doesn't interfere with an actively running routine

        let r = Routine.create(testContext, userOrder: 77, name: "bleh", archiveID: routineArchiveID)
        let e1 = Exercise.create(testContext, routine: r, userOrder: userOrder1, name: "bleep", archiveID: exercise1ArchiveID)
        e1.routine = r
        e1.lastIntensity = intensity1
        e1.units = Units.kilograms.rawValue

        let e2 = Exercise.create(testContext, routine: r, userOrder: userOrder2, name: "blort", archiveID: exercise2ArchiveID)
        e2.routine = r
        e2.lastIntensity = intensity2
        e2.units = Units.pounds.rawValue
        try testContext.save()

        try e1.logCompletion(testContext, mainStore: mainStore, routineStartedAt: startedAt, nuDuration: duration, exerciseCompletedAt: completedAt1, exerciseIntensity: intensity1)
        try testContext.save()

        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exercise1ArchiveID, completedAt: completedAt1, inStore: mainStore))
        XCTAssertNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exercise1ArchiveID, completedAt: completedAt1, inStore: archiveStore))

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore, thresholdSecs: thresholdSecs)
        try testContext.save()

        XCTAssertNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exercise1ArchiveID, completedAt: completedAt1, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exercise1ArchiveID, completedAt: completedAt1, inStore: archiveStore))

        try e2.logCompletion(testContext, mainStore: mainStore, routineStartedAt: startedAt, nuDuration: duration, exerciseCompletedAt: completedAt2, exerciseIntensity: intensity2)
        try testContext.save()

        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exercise2ArchiveID, completedAt: completedAt2, inStore: mainStore))
        XCTAssertNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exercise2ArchiveID, completedAt: completedAt2, inStore: archiveStore))

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore, thresholdSecs: thresholdSecs)
        try testContext.save()

        XCTAssertNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exercise2ArchiveID, completedAt: completedAt2, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exercise2ArchiveID, completedAt: completedAt2, inStore: archiveStore))

        let zr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        XCTAssertNotNil(zr)
        XCTAssertEqual(r.name, zr?.name)
        let zrr = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        XCTAssertNotNil(zrr)
        XCTAssertEqual(duration, zrr?.duration)
        XCTAssertEqual(startedAt, zrr?.startedAt)

        let ze1 = try ZExercise.get(testContext, routineArchiveID: routineArchiveID, exerciseArchiveID: exercise1ArchiveID, inStore: archiveStore)
        XCTAssertNotNil(ze1)
        XCTAssertEqual(e1.name, ze1?.name)
        XCTAssertEqual(e1.units, ze1?.units)
        let zer1 = try ZExerciseRun.get(testContext, exerciseArchiveID: exercise1ArchiveID, completedAt: completedAt1, inStore: archiveStore)
        XCTAssertNotNil(zer1)
        XCTAssertEqual(completedAt1, zer1?.completedAt)
        XCTAssertEqual(intensity1, zer1?.intensity)

        let ze2 = try ZExercise.get(testContext, routineArchiveID: routineArchiveID, exerciseArchiveID: exercise2ArchiveID, inStore: archiveStore)
        XCTAssertNotNil(ze2)
        XCTAssertEqual(e2.name, ze2?.name)
        XCTAssertEqual(e2.units, ze2?.units)
        let zer2 = try ZExerciseRun.get(testContext, exerciseArchiveID: exercise2ArchiveID, completedAt: completedAt2, inStore: archiveStore)
        XCTAssertNotNil(zer2)
        XCTAssertEqual(completedAt2, zer2?.completedAt)
        XCTAssertEqual(intensity2, zer2?.intensity)
    }

    func testRestoreRoutineRunAfterUserCompletesExercise() throws {
        let r = Routine.create(testContext, userOrder: 77, name: "bleh", archiveID: routineArchiveID)
        let e1 = Exercise.create(testContext, routine: r, userOrder: userOrder1, name: "bleep", archiveID: exercise1ArchiveID)
        e1.lastIntensity = intensity1
        let e2 = Exercise.create(testContext, routine: r, userOrder: userOrder2, name: "blort", archiveID: exercise1ArchiveID)
        e2.lastIntensity = intensity2
        try testContext.save()

        try e1.logCompletion(testContext, mainStore: mainStore, routineStartedAt: startedAt, nuDuration: duration, exerciseCompletedAt: completedAt1, exerciseIntensity: intensity1)
        try testContext.save()

        guard let zrr1 = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore)
        else { XCTFail(); return }
        XCTAssertEqual(duration, zrr1.duration)
        XCTAssertEqual(startedAt, zrr1.startedAt)

        // user removes ZRoutineRun (possibly from different device)

        zrr1.userRemoved = true
        try testContext.save()

        // user completes exercise (possibly from different device)

        try e2.logCompletion(testContext, mainStore: mainStore, routineStartedAt: startedAt, nuDuration: duration, exerciseCompletedAt: completedAt2, exerciseIntensity: intensity2)
        try testContext.save()

        guard let zrr2 = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore)
        else { XCTFail(); return }

        // ensure that ZRoutineRun has been restored from the userRemove (possibly on another device)
        XCTAssertFalse(zrr2.userRemoved)
    }
}
