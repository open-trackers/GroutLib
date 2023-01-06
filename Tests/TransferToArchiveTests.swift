//
//  TransferToArchiveTests.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@testable import GroutLib
import XCTest

final class TransferToArchiveTests: TestBase {
    func testTransferRoutineRun() throws {
        let uuid = UUID()
        let startDate = Date.now
        let r = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: uuid)
        let _ = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, duration: 1)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: uuid))
        XCTAssertEqual(1, try ZRoutineRun.count(testContext))

        try transferToArchive(testContext)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: uuid))
        XCTAssertEqual(0, try ZRoutineRun.count(testContext))

        // TODO: verify in archive
    }
}
