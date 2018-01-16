//
//  BitRange.swift
//  BinaryTest
//
//  Created by Jonathan Wight on 6/24/15.
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

private extension MemoryLayout {
    static var bitSize: Int {
        return size * 8
    }
}

// MARK: UnsignedIntegerTypes bitRanges

public func bitRange <T: UnsignedInteger> (value: T, start: Int, count: Int, flipped: Bool = false) -> T {
    assert(MemoryLayout<T>.size <= MemoryLayout<UIntMax>.size)
    let bitSize = UIntMax(MemoryLayout<T>.size * 8)
    assert(start + count <= Int(bitSize))
    if flipped {
        let shift = bitSize - UIntMax(start) - UIntMax(count)
        let mask = (1 << UIntMax(count)) - 1
        let intermediate = value.toUIntMax() >> shift & mask
        let result = intermediate
        return T.init(result)
    }
    else {
        let shift = UIntMax(start)
        let mask = (1 << UIntMax(count)) - 1
        let result = value.toUIntMax() >> shift & mask
        return T.init(result)
    }
}

public func bitRange <T: UnsignedInteger> (value: T, range: Range <Int>, flipped: Bool = false) -> T {
    return bitRange(value: value, start: range.lowerBound, count: range.upperBound - range.lowerBound, flipped: flipped)
}

// MARK: UnsafeBufferPointer bitRanges

public func bitRange <Element> (buffer: UnsafeBufferPointer <Element>, start: Int, count: Int) -> UIntMax {

    let pointer = UnsafeRawPointer(buffer.baseAddress)!

    // TODO: Swift3 - clean this up in the same manner (or better) we did bitSet (below)
    // Fast path; we want whole integers and the range is aligned to integer size.
    if count == 64 && start % 64 == 0 {
        return pointer.assumingMemoryBound(to: UInt64.self)[start / MemoryLayout <UInt64>.bitSize]
    }
    else if count == 32 && start % 32 == 0 {
        return UIntMax(pointer.assumingMemoryBound(to: UInt32.self)[start / MemoryLayout <UInt32>.bitSize])
    }
    else if count == 16 && start % 16 == 0 {
        return UIntMax(pointer.assumingMemoryBound(to: UInt16.self)[start / MemoryLayout <UInt16>.bitSize])
    }
    else if count == 8 && start % 8 == 0 {
        return UIntMax(pointer.assumingMemoryBound(to: UInt8.self)[start / MemoryLayout <UInt8>.bitSize])
    }
    else {
        // Slow(er) path. Range is not aligned.
        let pointer = pointer.assumingMemoryBound(to: UIntMax.self)
        let wordSize = MemoryLayout<UIntMax>.size * 8

        let end = start + count

        if start / wordSize == (end - 1) / wordSize {
            // Bit range does not cross two words
            let offset = start / wordSize
            let result = bitRange(value: pointer[offset].bigEndian, start: start % wordSize, count: count, flipped: true)
            return result
        }
        else {
            // Bit range spans two words, get bit ranges for both words and then combine them.
            let offset = start / wordSize
            let offsettedStart = start % wordSize
            let msw = bitRange(value: pointer[offset].bigEndian, range: offsettedStart ..< wordSize, flipped: true)
            let bits = (end - offset * wordSize) % wordSize
            let lsw = bitRange(value: pointer[offset + 1].bigEndian, range: 0 ..< bits, flipped: true)
            return msw << UIntMax(bits) | lsw
        }
    }
}

public func bitRange <Element> (buffer: UnsafeBufferPointer <Element>, range: Range <Int>) -> UIntMax {
    return bitRange(buffer: buffer, start: range.lowerBound, count: range.upperBound - range.lowerBound)
}

// MARK: UnsignedIntegerType bitSets

public func bitSet <T: UnsignedInteger> (value: T, start: Int, count: Int, flipped: Bool = false, newValue: T) -> T {
    assert(start + count <= MemoryLayout<T>.size * 8)
    let mask: T = onesMask(start: start, count: count, flipped: flipped)
    let shift = UIntMax(flipped == false ? start: (MemoryLayout<T>.size * 8 - start - count))
    let shiftedNewValue = newValue.toUIntMax() << UIntMax(shift)
    let result = (value.toUIntMax() & ~mask.toUIntMax()) | (shiftedNewValue & mask.toUIntMax())
    return T(result)
}

public func bitSet <T: UnsignedInteger> (value: T, range: Range <Int>, flipped: Bool = false, newValue: T) -> T {
    return bitSet(value: value, start: range.lowerBound, count: range.upperBound - range.lowerBound, flipped: flipped, newValue: newValue)
}

// MARK: UnsafeMutableBufferPointer bitSets

public func bitSet <Element>(buffer: UnsafeMutableBufferPointer <Element>, start: Int, count: Int, newValue: UIntMax) {
    // TODO: Swift3 - why does return an optional?
    let pointer = UnsafeMutableRawPointer(buffer.baseAddress)!

    func set <T: UnsignedInteger> (pointer: UnsafeMutableRawPointer, type: T.Type, newValue: UIntMax) {
        pointer.assumingMemoryBound(to: T.self)[start / (MemoryLayout <T>.bitSize)] = T(newValue)
    }

    // Fast path; we want whole integers and the range is aligned to integer size.
    if count == 64 && start % 64 == 0 {
        set(pointer: pointer, type: UInt64.self, newValue: newValue)
    }
    else if count == 32 && start % 32 == 0 {
        set(pointer: pointer, type: UInt32.self, newValue: newValue)
    }
    else if count == 16 && start % 16 == 0 {
        set(pointer: pointer, type: UInt16.self, newValue: newValue)
    }
    else if count == 8 && start % 8 == 0 {
        set(pointer: pointer, type: UInt8.self, newValue: newValue)
    }
    else {
        // Slow(er) path. Range is not aligned.
        let pointer = pointer.assumingMemoryBound(to: UIntMax.self)
        let wordSize = MemoryLayout<UIntMax>.size * 8

        let end = start + count

        if start / wordSize == (end - 1) / wordSize {
            // Bit range does not cross two words

            let offset = start / wordSize
            let value = pointer[offset].bigEndian
            let result = UIntMax(bigEndian: bitSet(value: value, start: start % wordSize, count: count, flipped: true, newValue: newValue))
            pointer[offset] = result
        }
        else {
            // Bit range spans two words, get bit ranges for both words and then combine them.
            unimplementedFailure()
        }
    }
}

public func bitSet <Element>(buffer: UnsafeMutableBufferPointer <Element>, range: Range <Int>, newValue: UIntMax) {
    bitSet(buffer: buffer, start: range.lowerBound, count: range.upperBound - range.lowerBound, newValue: newValue)
}

// MARK: -

private func onesMask <T: UnsignedInteger> (start: Int, count: Int, flipped: Bool = false) -> T {
    let size = UIntMax(MemoryLayout<T>.size * 8)
    let start = UIntMax(start)
    let count = UIntMax(count)
    let shift = flipped == false ? start: (size - start - count)
    let mask = ((1 << count) - 1) << shift
    return T(mask)
}
