//
//  UpdateRecordsTests.swift
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

final class UpdateRecordsTests: TestBase {
    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testUpdateRoutineArchiveID() throws {
        let r = Routine.create(testContext, userOrder: 0, name: "blah", archiveID: routineArchiveID)
        r.archiveID = nil
        try testContext.save()
        let r1: Routine? = Routine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNil(r1?.archiveID)
        try updateArchiveIDs(testContext)
        let r2: Routine? = Routine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNotNil(r2?.archiveID)
    }

    func testUpdateExerciseArchiveID() throws {
        let r = Routine.create(testContext, userOrder: 0, name: "blah", archiveID: routineArchiveID)
        let e = Exercise.create(testContext, routine: r, userOrder: 0, name: "blah", archiveID: exerciseArchiveID)
        e.archiveID = nil
        try testContext.save()
        let e1: Exercise? = Exercise.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNil(e1?.archiveID)
        try updateArchiveIDs(testContext)
        let e2: Exercise? = Exercise.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNotNil(e2?.archiveID)
    }

    func testUpdateRoutineCreatedAt() throws {
        let r = Routine.create(testContext, userOrder: 0, name: "blah", archiveID: routineArchiveID)
        r.createdAt = nil
        try testContext.save()
        let r1: Routine? = Routine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNil(r1?.createdAt)
        try updateCreatedAts(testContext)
        let r2: Routine? = Routine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNotNil(r2?.createdAt)
    }

    func testUpdateExerciseCreatedAt() throws {
        let r = Routine.create(testContext, userOrder: 0, name: "blah", archiveID: routineArchiveID)
        let e = Exercise.create(testContext, routine: r, userOrder: 0, name: "blah", archiveID: exerciseArchiveID)
        e.createdAt = nil
        try testContext.save()
        let e1: Exercise? = Exercise.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNil(e1?.createdAt)
        try updateCreatedAts(testContext)
        let e2: Exercise? = Exercise.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNotNil(e2?.createdAt)
    }

    func testUpdateZRoutineCreatedAt() throws {
        let r = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        r.createdAt = nil
        try testContext.save()
        let e1: ZRoutine? = ZRoutine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNil(e1?.createdAt)
        try updateCreatedAts(testContext)
        let e2: ZRoutine? = ZRoutine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNotNil(e2?.createdAt)
    }

    func testUpdateZExerciseCreatedAt() throws {
        let r = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let e = ZExercise.create(testContext, zRoutine: r, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", toStore: mainStore)
        e.createdAt = nil
        try testContext.save()
        let e1: ZExercise? = ZExercise.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNil(e1?.createdAt)
        try updateCreatedAts(testContext)
        let e2: ZExercise? = ZExercise.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNotNil(e2?.createdAt)
    }

    func testUpdateZRoutineRunCreatedAt() throws {
        let r = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: Date.now, duration: 10, toStore: mainStore)
        rr.createdAt = nil
        try testContext.save()
        let e1: ZRoutineRun? = ZRoutineRun.get(testContext, forURIRepresentation: rr.uriRepresentation)
        XCTAssertNil(e1?.createdAt)
        try updateCreatedAts(testContext)
        let e2: ZRoutineRun? = ZRoutineRun.get(testContext, forURIRepresentation: rr.uriRepresentation)
        XCTAssertNotNil(e2?.createdAt)
    }

    func testUpdateZExerciseRunCreatedAt() throws {
        let r = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let e = ZExercise.create(testContext, zRoutine: r, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: Date.now, duration: 10, toStore: mainStore)
        let er = ZExerciseRun.create(testContext, zRoutineRun: rr, zExercise: e, completedAt: Date.now, intensity: 1, toStore: mainStore)
        er.createdAt = nil
        try testContext.save()
        let e1: ZExerciseRun? = ZExerciseRun.get(testContext, forURIRepresentation: er.uriRepresentation)
        XCTAssertNil(e1?.createdAt)
        try updateCreatedAts(testContext)
        let e2: ZExerciseRun? = ZExerciseRun.get(testContext, forURIRepresentation: er.uriRepresentation)
        XCTAssertNotNil(e2?.createdAt)
    }
}
