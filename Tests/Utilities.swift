//
//  Utilities.swift
//  BinaryTest
//
//  Created by Jonathan Wight on 6/25/15.
//
//  Copyright (c) 2014, Jonathan Wight
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


import XCTest

//func XCTAssertEqual<T: Equatable>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, @autoclosure _ expression3: () -> T, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
//    XCTAssertEqual(expression1, expression2, message, file: file, line: line)
//    XCTAssertEqual(expression2, expression3, message, file: file, line: line)
//    XCTAssertEqual(expression3, expression1, message, file: file, line: line)
//}
import SwiftUtilities

func XCTAssertThrows(_ closure: () throws -> Void) {
    do {
        try closure()
        XCTAssert(false)
    }
    catch {
        return
    }
}

func bits(_ bits: Int) -> Int {
    return bits * 8
}

func buildBinary(_ count: Int, closure: (UnsafeMutableBufferPointer <UInt8>) -> Void) -> [UInt8] {
    var data = [UInt8](repeating: 0, count: Int(ceil(Double(count) / 8)))
    data.withUnsafeMutableBufferPointer() {
        (buffer: inout UnsafeMutableBufferPointer <UInt8>) -> Void in
        closure(buffer)
    }
    return data
}

func byteArrayToBinary(_ bytes: Array <UInt8>) throws -> String {
    return try bytes.map({ try binary($0, prefix: false, width: 8) }).joined(separator: "")
}

struct BitString {
    var string: String

    init(count: Int) {
        string = String(repeating: "0", count: count)
    }

//    mutating func bitSet(_ start: Int, length: Int, newValue: UIntMax) throws {
//
//        let newValue = try binary(newValue, width: length, prefix: false)
//
//        let start = string.index(string.startIndex, offsetBy: start)
//        let end = <#T##String.CharacterView corresponding to `start`##String.CharacterView#>.index(start, offsetBy: length)
//        string.replaceRange(start..<end, with: newValue)
//    }
}
