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

import TrackerLib

@testable import GroutLib
import XCTest

final class ZExerciseTests: TestBase {
    let routineArchiveID = UUID()
    let exerciseArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testGetOrCreateUpdatesNameAndUnits() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        _ = ZExercise.create(testContext, zRoutine: sr, exerciseArchiveID: exerciseArchiveID, exerciseName: "bleh", exerciseUnits: .kilograms, toStore: mainStore)
        try testContext.save()

        let se2 = try ZExercise.getOrCreate(testContext,
                                            zRoutine: sr,
                                            exerciseArchiveID: exerciseArchiveID,
//                                            exerciseName: "bleh2",
//                                            exerciseUnits: .pounds,
                                            inStore: mainStore) { _, element in
            element.name = "bleh2"
            element.units = Units.pounds.rawValue
        }
        try testContext.save()

        XCTAssertEqual("bleh2", se2.name)
        XCTAssertEqual(Units.pounds.rawValue, se2.units)
    }
}
