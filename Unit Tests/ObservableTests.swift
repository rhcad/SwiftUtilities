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
        var o = ObservableProperty(100)
        o.addObserver(self) {
            XCTAssertEqual(o.value, 101)
        }
        o.value = 101
    }

    func testSimple1() {
        var o = ObservableProperty(100)
        o.addObserver(self) {
            (newValue) in
            XCTAssertEqual(newValue, 101)
        }
        o.value = 101
    }

    func testSimple3() {
        var o = ObservableProperty(100)
        o.addObserver(self) {
            (oldValue, newValue) in
            XCTAssertEqual(oldValue, 100)
            XCTAssertEqual(newValue, 101)
        }
        o.value = 101
    }

//    func testOptional1() {
//        var o = Observable <Int?> (nil)
//    }

}
