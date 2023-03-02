//
//  ZRoutineFreshTests.swift
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

final class ZRoutineFreshTests: TestBase {
    var mainStore: NSPersistentStore!
    var archiveStore: NSPersistentStore!

    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()
    let secondsPerDay: TimeInterval = 86400

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let mainStore = PersistenceManager.getStore(testContext, .main),
              let archiveStore = PersistenceManager.getStore(testContext, .archive)
        else {
            throw TrackerError.invalidStoreConfiguration(msg: "setup")
        }

        self.mainStore = mainStore
        self.archiveStore = archiveStore
    }

    func testMissingRoutineIsStale() throws {
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        try testContext.save()

        XCTAssertFalse(sr.isFresh(testContext))
    }

    func testMissingLastStartedAtIsStale() throws {
        let r = Routine.create(testContext, userOrder: 1, archiveID: routineArchiveID)

        XCTAssertNil(r.lastStartedAt)

        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        try testContext.save()

        XCTAssertFalse(sr.isFresh(testContext))
    }

    func testThresholdSecond() throws {
        let base = Date.now
        let lastStartedAt = base.addingTimeInterval(-1) // one second prior

        let r = Routine.create(testContext, userOrder: 1, archiveID: routineArchiveID)
        r.lastStartedAt = lastStartedAt

        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        try testContext.save()

        // if within the threshold, it's fresh
        XCTAssertTrue(sr.isFresh(testContext, now: base, thresholdSecs: 2))
        XCTAssertTrue(sr.isFresh(testContext, now: base, thresholdSecs: 1))

        // if outside the threshold, it's stale
        XCTAssertFalse(sr.isFresh(testContext, now: base, thresholdSecs: 0))
    }

    func testThresholdHour() throws {
        let base = Date.now
        let lastStartedAt = base.addingTimeInterval(-3600) // one hour prior

        let r = Routine.create(testContext, userOrder: 1, archiveID: routineArchiveID)
        r.lastStartedAt = lastStartedAt

        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        try testContext.save()

        // if within the threshold, it's fresh
        XCTAssertTrue(sr.isFresh(testContext, now: base, thresholdSecs: secondsPerDay))
        XCTAssertTrue(sr.isFresh(testContext, now: base, thresholdSecs: 3601))
        XCTAssertTrue(sr.isFresh(testContext, now: base, thresholdSecs: 3600))

        // if outside the threshold, it's stale
        XCTAssertFalse(sr.isFresh(testContext, now: base, thresholdSecs: 3599))
        XCTAssertFalse(sr.isFresh(testContext, now: base, thresholdSecs: 0))
    }

    func testTransferPreservesFreshRoutine() throws {
        let base = Date.now
        let lastStartedAt = base.addingTimeInterval(-secondsPerDay) // less than or equal to a day prior (fresh, so preserve)

        let r = Routine.create(testContext, userOrder: 1, archiveID: routineArchiveID)
        r.lastStartedAt = lastStartedAt
        _ = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))

        try transferToArchive(testContext, now: base, thresholdSecs: secondsPerDay)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore)) // preserved!
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
    }

    func testTransferPurgesStaleRoutine() throws {
        let base = Date.now
        let lastStartedAt = base.addingTimeInterval(-secondsPerDay - 1) // more than one day prior (stale, so purge)

        let r = Routine.create(testContext, userOrder: 1, archiveID: routineArchiveID)
        r.lastStartedAt = lastStartedAt
        _ = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))

        try transferToArchive(testContext, now: base, thresholdSecs: secondsPerDay)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore)) // purged!
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
    }
}
