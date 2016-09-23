//: Playground - noun: a place where people can play

import Cocoa


import SwiftUtilities

switch "hello world" {
    case try! RegularExpression("^hello.+"):
        print("Match!")
    default:
        print("No match")
}

let expression = try! RegularExpression("😀")
let haystack = "xxxxxx😀yyyy"
// TODO: Swift3 fails
guard let match = expression.match(haystack) else {
    fatalError()
}

let range = match.ranges[0]
haystack[range]

