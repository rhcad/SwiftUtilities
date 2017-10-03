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
       let queue = DispatchQueue.main
        o.addObserver(self, queue: queue) {
            print("\(o.value)  \(expected)")
            XCTAssertEqual(o.value, expected)
            expected = 103
            o.value = 103
        }
        
        queue.async {
            expected = 101
            o.value = 101
        }
    }
}
