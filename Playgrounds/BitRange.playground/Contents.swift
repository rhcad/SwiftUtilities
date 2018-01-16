//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities

func test(length: Int, closure: (UnsafeMutableBufferPointer <UInt8>) -> Void) -> [UInt8] {
    var data = [UInt8](repeating: 0, count: Int(ceil(Double(length) / 8)))
    data.withUnsafeMutableBufferPointer() {
        (buffer: inout UnsafeMutableBufferPointer <UInt8>) -> Void in
        closure(buffer)
    }
    return data
}

struct BitString {
    var string: String

    init(count: Int) {
        string = String(repeating: "0", count: count)
    }

    mutating func bitSet(start: Int, length: Int, newValue: UIntMax) {

        let newValue = try! binary(newValue, prefix: false, width: length)

        let start = string.index(string.startIndex, offsetBy: start)
        let end = string.index(start, offsetBy: length)
        string.replaceSubrange(start..<end, with: newValue)
    }
}


let result = test(length: 128) {
    (buffer) in
    bitSet(buffer, start: 0, length: 1, newValue: 0x01)
}
print(result.map({ try! binary($0, prefix: false, width: 8) }).joined(separator: ""))


var bitString = BitString(count: 128)
bitString.bitSet(start: 0, length: 1, newValue: 0x01)
print(bitString.string)
