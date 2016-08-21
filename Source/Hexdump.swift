//
//  Hexdump.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 5/10/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Foundation

public func hexdump <Target: TextOutputStream>(_ buffer: UnsafeBufferPointer <UInt8>, width: Int = 16, zeroBased: Bool = false, separator: String = "\n", terminator: String = "", stream: inout Target) {

    for index in stride(from: 0, through: buffer.count, by: width) {
        let address = zeroBased == false ? String(describing: buffer.baseAddress! + index) : try! UInt(index).encodeToString(base: 16, prefix: true, width: 16)
        let chunk = buffer[index..<(index + min(width, buffer.byteCount - index))]
        if chunk.count == 0 {
            break
        }
        let hex = chunk.map() {
            try! $0.encodeToString(base: 16, prefix: false, width: 2)
        }.joined(separator: " ")
        let paddedHex = hex.padding(toLength: width * 3 - 1, withPad: " ", startingAt: 0)

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
        }.joined(separator: "")

        stream.write("\(address)  \(paddedHex)  \(string)")
        stream.write(separator)
    }
    stream.write(terminator)
}

public func hexdump(_ buffer: UnsafeBufferPointer <UInt8>, width: Int = 16, zeroBased: Bool = false) {
    var string = String()
    hexdump(buffer, width: width, zeroBased: zeroBased, stream: &string)
    print(string)
}
