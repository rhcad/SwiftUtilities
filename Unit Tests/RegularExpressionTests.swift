//
//  RegularExpressionTests.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 10/13/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import XCTest

import SwiftUtilities

class RegularExpressionTests: XCTestCase {

    func testExample1() {
        let regex = try! RegularExpression("[a-z]+")
        let match = regex.search("00000 world")
        XCTAssertEqual(match?.strings[0], "world")
    }

    func testExample2() {
        let regex = try! RegularExpression("[a-z]+")
        let match = regex.match("00000 world")
        XCTAssertNil(match)
    }
}
