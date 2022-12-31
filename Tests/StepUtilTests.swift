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
    
    func testIsNotFractional1() throws {
        let accuracy: Float = 0.1
        let values: [Float] = [-1, 0, 1, 2, 3, 4, 4.951, 4.9999976, 5, 0.050, 1.050, 0.009, 1.009, 8.049]

        values.forEach {
            XCTAssertFalse(isFractional(value: $0, accuracy: accuracy), "Testing \($0)")
        }
    }

    func testIsFractional1() throws {
        let accuracy: Float = 0.1
        let values: [Float] = [-1.1, -0.1, 0.1, 0.9, 1.1, 1.9, 2.1, 2.9, 0.09, 1.09, 0.06, 1.06, 0.051, 1.051, 8.05]

        values.forEach {
            XCTAssertTrue(isFractional(value: $0, accuracy: accuracy), "Testing \($0)")
        }
    }
    
    func testIsNotFractional2() throws {
        let accuracy: Float = 0.01
        let values: [Float] = [-1, 0, 1, 2, 3, 4, 5, 0.0050, 1.0050, 0.0009, 1.0009, 8.0049]

        values.forEach {
            XCTAssertFalse(isFractional(value: $0, accuracy: accuracy), "Testing \($0)")
        }
    }
    
    func testIsFractional2() throws {
        let accuracy: Float = 0.01
        let values: [Float] = [-1.01, -0.01, 0.01, 0.09, 1.01, 1.09, 2.01, 2.09, 0.009, 1.009, 0.006, 1.006, 0.0051, 1.0051, 8.005]

        values.forEach {
            XCTAssertTrue(isFractional(value: $0, accuracy: accuracy), "Testing \($0)")
        }
    }
}
