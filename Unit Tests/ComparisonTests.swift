//
//  ComparisonTests.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 3/1/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import XCTest

import SwiftUtilities

class ComparisonTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(compare(1, 1), Comparison.Equal)
        XCTAssertEqual(compare(1, 2), Comparison.Lesser)
        XCTAssertEqual(compare(2, 1), Comparison.Greater)
    }
}
