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

final class CopyTests: TestBase {
    
    var mainStore: NSPersistentStore!
    var archiveStore: NSPersistentStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        guard let mainURL = PersistenceManager.stores[.main]?.url,
              let archiveURL = PersistenceManager.stores[.archive]?.url,
              let psc = testContext.persistentStoreCoordinator,
              let mainStore = psc.persistentStore(for: mainURL),
              let archiveStore = psc.persistentStore(for: archiveURL)
        else {
            throw DataError.fetchError(msg: "Archive store not found")
        }
        
        self.mainStore = mainStore
        self.archiveStore = archiveStore
    }
    
    func testReadOnly() throws {
        XCTAssertFalse(mainStore.isReadOnly)
        XCTAssertFalse(archiveStore.isReadOnly)
    }
    
    func testCopyRoutine() throws {
        let uuid = UUID()
        let r = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: uuid, inStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: uuid, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, forArchiveID: uuid, inStore: archiveStore))

        try r.copy(testContext, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: uuid, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, forArchiveID: uuid, inStore: archiveStore))
    }
}
