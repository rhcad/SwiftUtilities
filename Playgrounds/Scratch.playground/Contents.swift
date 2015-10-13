//: Playground - noun: a place where people can play

import Cocoa


import SwiftUtilities


let string = "name"


let regularExpression = try! RegularExpression("[A-Za-z_]+")

let match = regularExpression.match(string)
match?.strings
