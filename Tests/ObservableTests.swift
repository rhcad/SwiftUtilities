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
        o.addObserver(self, queue: queue) { (value: Int) in
            print("value in observer=\(o.value) callbackValue=\(value)")
//            o.removeObserver(self)
        }
//        o.removeObserver(self)
//        DispatchQueue.global().sync {
//            o.value = 99
//             o.removeObserver(self)
//        }
//
//        DispatchQueue.global().async {
//            o.value = 199
             //o.removeObserver(self)
//        }
//
//        queue.async {
//            o.value = 101
//        }
        
        expected = 90
        o.value = 90
        
        XCTAssertEqual(o.value, expected)
    }
    
    func testPublisher() {
        
        let p = Publisher<String, String>()
        p.subscribe(self, messageKey: "Q") { (str) in
            print("got new message=\(str)")
        }
        _ = p.publish("Q", message: "first")
        
        p.unsubscribe(self)
        
        p.subscribe(self, messageKey: "Q") { (str) in
            print("got new message2=\(str)")
        }

        _ = p.publish("Q", message: "second")

        DispatchQueue.global().async {
            _ = p.publish("Q", message: "third")
            p.unsubscribe(self)
            _ = p.publish("Q", message: "no message")
        }
    }
}
