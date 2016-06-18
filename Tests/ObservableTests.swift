//
//  ObservableTests.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 11/21/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import XCTest

import SwiftUtilities

class ObservableTests: XCTestCase {

    func testSimple() {
        let o = ObservableProperty(100)
        var expected = 100
        o.addObserver(self) {
            XCTAssertEqual(o.value, expected)
        }
        expected = 101
        o.value = 101
    }


}
