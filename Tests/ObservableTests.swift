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
        
        class C {
            let o = ObservableProperty(100)
            
            init() {
                
                let queue = DispatchQueue.global()
                o.addObserver(self, queue: queue) { (value: Int) in
                    print("value in observer=\(self.o.value) callbackValue=\(value)")
                    self.o.removeObserver(self)
                    self.o.value = 103
                }
                //o.removeObserver(self)
//                DispatchQueue.global().sync {
//                    o.value = 99
//                    print(o.value)
//                    //o.removeObserver(self)
//                }
                
//                DispatchQueue.global().async {
//                    self.o.value = 199
//                    print(self.o.value)
//                    //             o.removeObserver(self)
//                }
                
//                queue.async {
//                    self.o.value = 101
//                    print(self.o.value)
//                }
//                o.removeObserver(self)

                o.value = 92
            }
            deinit {
                print("deinit")
                o.removeObserver(self)
            }
        }
        
        var c = C()
//        DispatchQueue.main.async {
            c = C()
//        }
        
        
        //XCTAssertEqual(o.value, expected)
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
