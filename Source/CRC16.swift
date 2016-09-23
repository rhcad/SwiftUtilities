//
//  MAVLink.swift
//  MavlinkTest
//
//  Created by Jonathan Wight on 3/29/15.
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

// CRC-16-CCITT	X.25

public struct CRC16 {
    public typealias CRCType = UInt16
    public internal(set) var crc: CRCType!

    public init() {
    }

    public static func accumulate(_ buffer: UnsafeBufferPointer <UInt8>, crc: CRCType = 0xFFFF) -> CRCType {
        var accum = crc
        for b in buffer {
            var tmp = CRCType(b) ^ (accum & 0xFF)
            tmp = (tmp ^ (tmp << 4)) & 0xFF
            accum = (accum >> 8) ^ (tmp << 8) ^ (tmp << 3) ^ (tmp >> 4)
        }
        return accum
    }

    public mutating func accumulate(_ buffer: UnsafeBufferPointer <UInt8>) {
        if crc == nil {
            crc = 0xFFFF
        }
        crc = CRC16.accumulate(buffer, crc: crc)
    }
}

public extension CRC16 {

    mutating func accumulate(_ bytes: [UInt8]) {
        bytes.withUnsafeBufferPointer() {
            (body: UnsafeBufferPointer <UInt8>) -> Void in
            accumulate(body)
        }
    }


    mutating func accumulate(_ string: String) {
        string.withCString() {
            (ptr: UnsafePointer<Int8>) -> Void in

            let count = Int(strlen(ptr))
            ptr.withMemoryRebound(to: UInt8.self, capacity: count) {
                ptr in
                let buffer = UnsafeBufferPointer <UInt8> (start: ptr, count: count)
                accumulate(buffer)
            }
        }
    }
}

