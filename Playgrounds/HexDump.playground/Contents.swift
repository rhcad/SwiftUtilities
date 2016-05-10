//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities

func hexdump <Target : OutputStreamType>(buffer: UnsafeBufferPointer <Void>, width: Int = 16, zeroBased: Bool = false, separator: String = "\n", terminator: String = "", inout stream: Target) {

    let buffer = UnsafeBufferPointer <UInt8> (start: UnsafePointer <UInt8> (buffer.baseAddress), count: buffer.count)

    for index in 0.stride(through: buffer.count, by: width) {
        let address = zeroBased == false ? String(buffer.baseAddress + index) : try! UInt(index).encodeToString(base: 16, prefix: true, width: 16)
        let chunk = buffer.subBuffer(index, count: min(width, buffer.length - index))
        if chunk.count == 0 {
            break
        }
        let hex = chunk.map() {
            try! $0.encodeToString(base: 16, prefix: false, width: 2)
        }.joinWithSeparator(" ")
        let paddedHex = hex.stringByPaddingToLength(width * 3 - 1, withString: " ", startingAtIndex: 0)

        let string = chunk.map() {
            (c: UInt8) -> String in

            let scalar = UnicodeScalar(c)

            let character = Character(scalar)
            if isprint(Int32(c)) != 0 {
                return String(character)
            }
            else {
                return "?"
            }
        }.joinWithSeparator("")

        stream.write("\(address)  \(paddedHex)  \(string)")
        stream.write(separator)
    }
    stream.write(terminator)
}

func hexdump(buffer: UnsafeBufferPointer <Void>, width: Int = 16, zeroBased: Bool = false) {
    var string = ""
    hexdump(buffer, width: width, zeroBased: zeroBased, stream: &string)
    print(string)
}


let s = "The quick brown fox jumped over the lazy\n dog"
let d = s.dataUsingEncoding(NSUTF8StringEncoding)

let b: UnsafeBufferPointer <Void> = d!.toUnsafeBufferPointer()

hexdump(b, width: 20, zeroBased: true)
