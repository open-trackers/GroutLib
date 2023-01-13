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

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let mainStore = PersistenceManager.getStore(testContext, .main),
              let archiveStore = PersistenceManager.getStore(testContext, .archive)
        else {
            throw DataError.invalidStoreConfiguration(msg: "setup")
        }

        self.mainStore = mainStore
        self.archiveStore = archiveStore
    }

    func testZRoutine() throws {
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        try testContext.save()

        let request = makeRequest(ZRoutine.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let sdata = String(data: data, encoding: .utf8) else { XCTFail(); return }
        print(sdata)
    }
}
