//
//  ZExerciseTests.swift
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

final class ZExerciseTests: TestBase {
    
    var mainStore: NSPersistentStore!
    var archiveStore: NSPersistentStore!

    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()

        guard let mainStore = PersistenceManager.getStore(testContext, .main)
        else {
            throw DataError.invalidStoreConfiguration(msg: "setup")
        }

        self.mainStore = mainStore
    }
    
    func testGetOrCreateUpdatesNameAndUnits() throws {
        let sr = ZRoutine.create(testContext, routineName: "blah", routineArchiveID: routineArchiveID)
        _ = ZExercise.create(testContext, zRoutine: sr, exerciseName: "bleh", exerciseUnits: .kilograms, exerciseArchiveID: exerciseArchiveID)
        try testContext.save()

        let se2 = try ZExercise.getOrCreate(testContext, zRoutine: sr, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh2", exerciseUnits: .pounds, inStore: mainStore)
        try testContext.save()

        XCTAssertEqual("bleh2", se2.name)
        XCTAssertEqual(Units.pounds.rawValue, se2.units)
    }
}
