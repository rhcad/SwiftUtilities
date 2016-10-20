//
//  Pointers+Extensions.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 6/23/15.
//
//  Copyright © 2016, Jonathan Wight
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


import Foundation

public extension UnsafeBufferPointer {

    init() {
        self.init(start: nil, count: 0)
    }

    init(start: UnsafePointer<Element>, byteCount: Int) {
        precondition(byteCount % UnsafeBufferPointer <Element>.elementSize == 0)
        self.init(start: start, count: byteCount / UnsafeBufferPointer <Element>.elementSize)
    }

    func withMemoryRebound<T, Result>(to: T.Type, capacity count: Int, _ body: (UnsafeBufferPointer<T>) throws -> Result) rethrows -> Result {
        guard let baseAddress = baseAddress else {
            // If base address is nil just return an empty buffer
            let buffer = UnsafeBufferPointer <T> ()
            return try body(buffer)
        }

        precondition((self.count * UnsafeBufferPointer <Element>.elementSize) % count == 0)

        return try baseAddress.withMemoryRebound(to: T.self, capacity: count) {
            (pointer: UnsafePointer<T>) -> Result in

            let buffer = UnsafeBufferPointer <T> (start: pointer, count: count)
            return try body(buffer)
        }
    }

    func withMemoryRebound<T, Result>(_ body: (UnsafeBufferPointer<T>) throws -> Result) rethrows -> Result {
        let count = (self.count * UnsafeBufferPointer <Element>.elementSize) / UnsafeBufferPointer <T>.elementSize
        return try withMemoryRebound(to: T.self, capacity: count, body)

    }

}

public extension UnsafeMutableBufferPointer {
    func toUnsafeBufferPointer() -> UnsafeBufferPointer <Element> {
        return UnsafeBufferPointer <Element> (start: baseAddress, count: count)
    }
}
