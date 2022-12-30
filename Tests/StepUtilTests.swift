//
//  StepUtilTests.swift
//
// Copyright 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@testable import GroutLib
import XCTest

final class StepUtilTests: XCTestCase {
    func testIsNotFractional() throws {
        let values: [Float] = [0, 1, 2, 3, 4, 5]
        
        values.forEach {
            XCTAssertFalse(isFractional(value: $0), "Testing \($0)")
        }
    }
}
