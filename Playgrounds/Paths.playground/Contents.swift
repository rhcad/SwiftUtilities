//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities

let path = Path("/tmp/foo.txt")

extension Path {
    func write(string: String, encoding: UInt = NSUTF8StringEncoding) throws {
        try string.writeToFile(String(self), atomically: true, encoding: encoding)
    }
}


try! path.rotate()
try path.write("Hello")

