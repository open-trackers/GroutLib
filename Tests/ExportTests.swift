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

@testable import GroutLib
import XCTest

final class ExportTests: TestBase {
    var mainStore: NSPersistentStore!
    var archiveStore: NSPersistentStore!

    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    let startedAtStr = "2023-01-13T20:42:50Z"
    var startedAt: Date!
    let completedAtStr = "2023-01-13T21:00:00Z"
    var completedAt: Date!

    let durationStr = "1332.0"
    var duration: TimeInterval!
    let intensityStr = "105.5"
    var intensity: Float!

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let mainStore = PersistenceManager.getStore(testContext, .main),
              let archiveStore = PersistenceManager.getStore(testContext, .archive)
        else {
            throw DataError.invalidStoreConfiguration(msg: "setup")
        }

        self.mainStore = mainStore
        self.archiveStore = archiveStore

        startedAt = df.date(from: startedAtStr)
        completedAt = df.date(from: completedAtStr)
        duration = Double(durationStr)
        intensity = Float(intensityStr)
    }

    func testZRoutine() throws {
        _ = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        try testContext.save()

        let request = makeRequest(ZRoutine.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        name,routineArchiveID
        blah,\(routineArchiveID.uuidString)

        """

        XCTAssertEqual(expected, actual)
    }

    func testZRoutineRun() throws {
        let zr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        _ = ZRoutineRun.create(testContext, zRoutine: zr, startedAt: startedAt, duration: duration)
        try testContext.save()

        let request = makeRequest(ZRoutineRun.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        startedAt,duration,routineArchiveID
        \(startedAtStr),\(durationStr),\(routineArchiveID.uuidString)

        """

        XCTAssertEqual(expected, actual)
    }

    func testZExercise() throws {
        let zr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        _ = ZExercise.create(testContext, zRoutine: zr, exerciseName: "bleh", exerciseArchiveID: exerciseArchiveID)
        try testContext.save()

        let request = makeRequest(ZExercise.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        name,exerciseArchiveID,routineArchiveID
        bleh,\(exerciseArchiveID.uuidString),\(routineArchiveID.uuidString)

        """

        XCTAssertEqual(expected, actual)
    }

    func testZExerciseRun() throws {
        let zr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        let ze = ZExercise.create(testContext, zRoutine: zr, exerciseName: "bleh", exerciseArchiveID: exerciseArchiveID)
        let zrr = ZRoutineRun.create(testContext, zRoutine: zr, startedAt: startedAt, duration: duration)
        _ = ZExerciseRun.create(testContext, zRoutineRun: zrr, zExercise: ze, completedAt: completedAt, intensity: intensity)
        try testContext.save()

        let request = makeRequest(ZExerciseRun.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        completedAt,intensity,exerciseArchiveID,routineRunStartedAt
        \(completedAtStr),\(intensityStr),\(exerciseArchiveID.uuidString),\(startedAtStr)

        """

        XCTAssertEqual(expected, actual)
    }
}