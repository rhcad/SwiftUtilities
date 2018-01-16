//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities

let publisher = TestingPublisher <String> ()

class Test {
}

let test: Test! = Test()

// TODO: Swift3 - crashin ghere
publisher.subscribe(test, test: { return $0 == "Hello" }, handler: { print($0) } )

publisher.publish("Hello")
publisher.publish("Goodbye")
