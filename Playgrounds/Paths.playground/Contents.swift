//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities

let path = Path("/tmp/foo.txt")

try! path.rotate()
try path.write("Hello")

