//
//  ShallowCopyTests.swift
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

final class ShallowCopyTests: TestBase {
    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    let createdAt1Str = "2023-01-01T05:00:00Z"
    var createdAt1: Date!
    let createdAt2Str = "2023-01-02T05:00:00Z"
    var createdAt2: Date!
    let createdAt3Str = "2023-01-03T05:00:00Z"
    var createdAt3: Date!
    let createdAt4Str = "2023-01-04T05:00:00Z"
    var createdAt4: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        createdAt1 = df.date(from: createdAt1Str)
        createdAt2 = df.date(from: createdAt2Str)
        createdAt3 = df.date(from: createdAt3Str)
        createdAt4 = df.date(from: createdAt4Str)
    }

    func testReadOnly() throws {
        XCTAssertFalse(mainStore.isReadOnly)
        XCTAssertFalse(archiveStore.isReadOnly)
    }

    func testRoutine() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt1, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))

        _ = try sr.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        let dr: ZRoutine? = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        XCTAssertNotNil(dr)
        XCTAssertEqual(createdAt1, dr?.createdAt)
    }

    func testRoutineWithExercise() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt1, toStore: mainStore)
        let se = ZExercise.create(testContext, zRoutine: sr, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", exerciseUnits: .kilograms, createdAt: createdAt2, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))

        // routine needs to get to archive first
        _ = try sr.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        // now the exercise copy
        let de = try se.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual(Units.kilograms.rawValue, de.units)

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))

        let dc: ZRoutine? = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        XCTAssertNotNil(dc)
        XCTAssertEqual(createdAt1, dc?.createdAt)
        let ds: ZExercise? = try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore)
        XCTAssertNotNil(ds)
        XCTAssertEqual(createdAt2, ds?.createdAt)
    }

    func testRoutineWithRoutineRun() throws {
        let startedAt = Date()
        let duration: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let su = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, duration: duration, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))

        // routine needs to get to archive first
        _ = try sr.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        // now the routineRun copy
        _ = try su.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
    }

    func testRoutineWithExerciseAndExerciseRun() throws {
        let completedAt = Date()
        let intensity: Float = 30.0
        let startedAt = Date()
        let duration: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt1, toStore: mainStore)
        let se = ZExercise.create(testContext, zRoutine: sr, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", exerciseUnits: .kilograms, createdAt: createdAt2, toStore: mainStore)
        let srr = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, duration: duration, createdAt: createdAt3, toStore: mainStore)
        let ser = ZExerciseRun.create(testContext, zRoutineRun: srr, zExercise: se, completedAt: completedAt, intensity: intensity, createdAt: createdAt4, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        // routine needs to get to archive first
        _ = try sr.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        // and routineRun too
        _ = try srr.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let drr = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        else { XCTFail(); return }

        // and exercise too
        _ = try se.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let de = try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        XCTAssertEqual(Units.kilograms.rawValue, de.units)

        // and finally copy the exercise run
        _ = try ser.shallowCopy(testContext, dstRoutineRun: drr, dstExercise: de, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: archiveStore))

        let dc: ZRoutine? = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        XCTAssertNotNil(dc)
        XCTAssertEqual(createdAt1, dc?.createdAt)
        let ds: ZExercise? = try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore)
        XCTAssertNotNil(ds)
        XCTAssertEqual(createdAt2, ds?.createdAt)
        let ddr2: ZRoutineRun? = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        XCTAssertNotNil(ddr2)
        XCTAssertEqual(createdAt3, ddr2?.createdAt)
        let dsr: ZExerciseRun? = try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: archiveStore)
        XCTAssertNotNil(dsr)
        XCTAssertEqual(createdAt4, dsr?.createdAt)
    }

    func testExerciseRunIncludesUserRemoved() throws {
        let startedAt = Date()
        let completedAt = startedAt.addingTimeInterval(1000)
        let sc = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt1, toStore: mainStore)
        let ss = ZExercise.create(testContext, zRoutine: sc, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", createdAt: createdAt2, toStore: mainStore)
        let sdr = ZRoutineRun.create(testContext, zRoutine: sc, startedAt: startedAt, createdAt: createdAt3, toStore: mainStore)
        let ssr = ZExerciseRun.create(testContext, zRoutineRun: sdr, zExercise: ss, completedAt: completedAt, createdAt: createdAt4, toStore: mainStore)
        ssr.userRemoved = true
        try testContext.save()

        _ = try sc.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        _ = try sdr.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let ddr = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        else { XCTFail(); return }

        _ = try ss.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let de = try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        _ = try ssr.shallowCopy(testContext, dstRoutineRun: ddr, dstExercise: de, toStore: archiveStore)
        try testContext.save()

        let dsr: ZExerciseRun? = try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: archiveStore)
        XCTAssertNotNil(dsr)
        XCTAssertTrue(dsr!.userRemoved)
    }
    
    func testRoutineRunIncludesUserRemoved() throws {
        let startedAt = Date()
        let completedAt = startedAt.addingTimeInterval(1000)
        let sc = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt1, toStore: mainStore)
        let ss = ZExercise.create(testContext, zRoutine: sc, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", createdAt: createdAt2, toStore: mainStore)
        let sdr = ZRoutineRun.create(testContext, zRoutine: sc, startedAt: startedAt, createdAt: createdAt3, toStore: mainStore)
        let ssr = ZExerciseRun.create(testContext, zRoutineRun: sdr, zExercise: ss, completedAt: completedAt, createdAt: createdAt4, toStore: mainStore)
        
        sdr.userRemoved = true  // remove the routineRun
        try testContext.save()

        _ = try sc.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        _ = try sdr.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let ddr = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        else { XCTFail(); return }
        XCTAssertTrue(ddr.userRemoved)

        _ = try ss.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let de = try ZExercise.get(testContext, exerciseArchiveID: exerciseArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        _ = try ssr.shallowCopy(testContext, dstRoutineRun: ddr, dstExercise: de, toStore: archiveStore)
        try testContext.save()

        let dsr: ZExerciseRun? = try ZExerciseRun.get(testContext, exerciseArchiveID: exerciseArchiveID, completedAt: completedAt, inStore: archiveStore)
        XCTAssertNotNil(dsr)
        XCTAssertFalse(dsr!.userRemoved)  // because only the parent routineRun has been removed
    }
}
