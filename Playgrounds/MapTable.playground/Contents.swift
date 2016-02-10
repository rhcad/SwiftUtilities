//: Playground - noun: a place where people can play

import SwiftUtilities

var str = "Hello, playground"

var table = MapTable <Box <String>, Box <String>> (keyReference: .Strong, valueReference: .Weak)

table[Box("hello")] = Box("world")

var copy = table

table[Box("hello")] = Box("world")

var copy2 = table

table[Box("hello")] = Box("world")

