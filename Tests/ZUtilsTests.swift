//
//  ZUtilsTests.swift
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

final class ZUtilsTests: TestBase {
    
//    override func setUp() {
//        super.setUp()
//
//        _ = try! MFolio.getNew(testContext, title: "My Folio", uuid: "1")
//    }
    
    func testKeepOnStartDate() throws {
        let uuid = UUID()
        let startDate = Date.now
        let r = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: uuid)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, duration: 1)
        XCTAssertFalse(rr.isDeleted)
        try cleanLogRecords(testContext, keepSince: startDate)
        XCTAssertFalse(rr.isDeleted)
    }
    
}
