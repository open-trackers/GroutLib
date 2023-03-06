//
//  AppSettingDedupeTests.swift
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

final class AppSettingDedupeTests: TestBase {
    let date1Str = "2023-01-02T21:00:01Z"
    var date1: Date!
    let date2Str = "2023-01-02T21:00:02Z"
    var date2: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        date1 = df.date(from: date1Str)
        date2 = df.date(from: date2Str)
    }

    func testSimple() throws {
        let s1 = AppSetting.create(testContext, createdAt: date1)
        let s2 = AppSetting.create(testContext, createdAt: date2)

        try AppSetting.dedupe(testContext)

        XCTAssertFalse(s1.isDeleted)
        XCTAssertTrue(s2.isDeleted)
    }
}
