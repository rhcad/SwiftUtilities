//: Playground - noun: a place where people can play

import SwiftUtilities

do {
    let a = try! Version("1.0-a")
    let b = try! Version("1.0-b")
    a < b
}

do {
    let a = try! Version("1.0-13")
    let b = try! Version("1.0-100")
    a < b
}

do {
    let a = try! Version("1.0-X13")
    let b = try! Version("1.0-X100")
    a > b
}
