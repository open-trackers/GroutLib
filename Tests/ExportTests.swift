//
//  ExportTests.swift
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

final class ExportTests: TestBase {
    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    let startedAtStr = "2023-01-13T20:42:50Z"
    var startedAt: Date!
    let completedAtStr = "2023-01-13T21:00:00Z"
    var completedAt: Date!
    let createdAtStr = "2023-01-01T01:00:00Z"
    var createdAt: Date!

    let durationStr = "1332.0"
    var duration: TimeInterval!
    let intensityStr = "105.5"
    var intensity: Float!
    let intensityStepStr = "3.3"
    var intensityStep: Float!
    let userOrderStr = "18"
    var userOrder: Int16!

    override func setUpWithError() throws {
        try super.setUpWithError()

        startedAt = df.date(from: startedAtStr)
        completedAt = df.date(from: completedAtStr)
        createdAt = df.date(from: createdAtStr)
        duration = Double(durationStr)
        intensity = Float(intensityStr)
        intensityStep = Float(intensityStepStr)
        userOrder = Int16(userOrderStr)
    }

    func testZRoutine() throws {
        _ = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt, toStore: mainStore)
        try testContext.save()

        let request = makeRequest(ZRoutine.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        name,routineArchiveID,createdAt
        blah,\(routineArchiveID.uuidString),\(createdAtStr)

        """

        XCTAssertEqual(expected, actual)
    }

    func testZRoutineRun() throws {
        let zr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        _ = ZRoutineRun.create(testContext, zRoutine: zr, startedAt: startedAt, duration: duration, createdAt: createdAt, toStore: mainStore)
        try testContext.save()

        let request = makeRequest(ZRoutineRun.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        startedAt,duration,createdAt,routineArchiveID
        \(startedAtStr),\(durationStr),\(createdAtStr),\(routineArchiveID.uuidString)

        """

        XCTAssertEqual(expected, actual)
    }

    func testZExercise() throws {
        let zr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        _ = ZExercise.create(testContext, zRoutine: zr, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", exerciseUnits: .kilograms, createdAt: createdAt, toStore: mainStore)
        try testContext.save()

        let request = makeRequest(ZExercise.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        name,units,exerciseArchiveID,createdAt,routineArchiveID
        bleh,\(Units.kilograms.rawValue),\(exerciseArchiveID.uuidString),\(createdAtStr),\(routineArchiveID.uuidString)

        """

        XCTAssertEqual(expected, actual)
    }

    func testZExerciseRun() throws {
        let zr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let ze = ZExercise.create(testContext, zRoutine: zr, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", exerciseUnits: .kilograms, toStore: mainStore)
        let zrr = ZRoutineRun.create(testContext, zRoutine: zr, startedAt: startedAt, duration: duration, toStore: mainStore)
        let zer = ZExerciseRun.create(testContext, zRoutineRun: zrr, zExercise: ze, completedAt: completedAt, intensity: intensity, createdAt: createdAt, toStore: mainStore)
        zer.userRemoved = true
        try testContext.save()

        let request = makeRequest(ZExerciseRun.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        completedAt,intensity,userRemoved,createdAt,exerciseArchiveID,routineRunStartedAt
        \(completedAtStr),\(intensityStr),true,\(createdAtStr),\(exerciseArchiveID.uuidString),\(startedAtStr)

        """

        XCTAssertEqual(expected, actual)
    }

    func testRoutine() throws {
        let r = Routine.create(testContext, userOrder: userOrder, name: "bleh", archiveID: routineArchiveID, createdAt: createdAt)
        r.lastDuration = duration
        r.lastStartedAt = startedAt
        r.imageName = "bloop"
        try testContext.save()

        let request = makeRequest(Routine.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        archiveID,imageName,lastDuration,lastStartedAt,name,userOrder,createdAt
        \(routineArchiveID.uuidString),bloop,\(durationStr),\(startedAtStr),bleh,\(userOrderStr),\(createdAtStr)

        """

        XCTAssertEqual(expected, actual)
    }

    func testExercise() throws {
        let r = Routine.create(testContext, userOrder: 77, name: "bleh", archiveID: routineArchiveID)
        let e = Exercise.create(testContext, routine: r, userOrder: userOrder, name: "bleep", archiveID: exerciseArchiveID, createdAt: createdAt)
        e.routine = r
        e.intensityStep = intensityStep
        e.invertedIntensity = true
        e.lastCompletedAt = completedAt
        e.lastIntensity = intensity
        e.primarySetting = 10
        e.repetitions = 11
        e.secondarySetting = 12
        e.sets = 3
        e.units = 2
        try testContext.save()

        let request = makeRequest(Exercise.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        archiveID,intensityStep,invertedIntensity,lastCompletedAt,lastIntensity,name,primarySetting,repetitions,secondarySetting,sets,units,userOrder,createdAt,routineArchiveID
        \(exerciseArchiveID.uuidString),\(intensityStepStr),true,\(completedAtStr),\(intensityStr),bleep,10,11,12,3,2,\(userOrderStr),\(createdAtStr),\(routineArchiveID)

        """

        XCTAssertEqual(expected, actual)
    }

    func testRoutineJSON() throws {
        let r = Routine.create(testContext, userOrder: userOrder, name: "bleh", archiveID: routineArchiveID, createdAt: createdAt)
        r.lastDuration = duration
        r.lastStartedAt = startedAt
        r.imageName = "bloop"
        try testContext.save()

        let request = makeRequest(Routine.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .JSON)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let durationStr2 = "1332" // JSON doesn't include the ".0"

        let expected = """
        [{"lastStartedAt":"\(startedAtStr)","userOrder":\(userOrderStr),"lastDuration":\(durationStr2),"createdAt":"\(createdAtStr)","imageName":"bloop","archiveID":"\(routineArchiveID.uuidString)","name":"bleh"}]
        """

        XCTAssertEqual(expected, actual)
    }

    // TODO: JSON export for the other types
}
