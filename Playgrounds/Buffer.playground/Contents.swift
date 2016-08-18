//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities

let data1 = GenericDispatchData <Void> (value: UInt16(0xDEAD).bigEndian)
let data2 = GenericDispatchData <Void> (value: UInt16(0xBEEF).bigEndian)
let result = data1 + data2
let expectedResult = GenericDispatchData <Void> (value: UInt32(0x