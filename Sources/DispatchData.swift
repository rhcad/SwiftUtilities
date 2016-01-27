//
//  DispatchData.swift
//  RTP Test
//
//  Created by Jonathan Wight on 6/30/15.
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


import Foundation

// MARK: DispatchData

public struct DispatchData <Element> {

    public let data: dispatch_data_t

    public var count: Int {
        return length / elementSize
    }

    public static var elementSize: Int {
        return max(sizeof(Element), 1)
    }

    public var elementSize: Int {
        return DispatchData <Element>.elementSize
    }

    public var length: Int {
        return dispatch_data_get_size(data)
    }

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return count
    }

    // MARK: -

    public init(data: dispatch_data_t) {
        self.data = data
        assert(count * elementSize == length)
    }

    public init() {
        self.init(data: dispatch_data_create(nil, 0, nil, nil))
    }

    public init(buffer: UnsafeBufferPointer <Element>) {
        self.init(data: dispatch_data_create(buffer.baseAddress, buffer.length, nil, nil))
    }

    public init(start: UnsafePointer <Element>, count: Int) {
        self.init(data: dispatch_data_create(start, count * DispatchData <Element>.elementSize, nil, nil))
    }

    // MARK: Mapping data.

    // TODO: Rename to "with", "withUnsafeBufferPointer", "withDataAndUnsafeBufferPointer"

    // IMPORTANT: If you need to keep the buffer beyond the scope of block you must hold on to data DispatchData instance too. The DispatchData and the buffer share the same life time.
    public func createMap <R> (@noescape block: (DispatchData <Element>, UnsafeBufferPointer <Element>) throws -> R) rethrows -> R {
        var pointer: UnsafePointer <Void> = nil
        var size: Int = 0
        let mappedData = dispatch_data_create_map(data, &pointer, &size)
        let buffer = UnsafeBufferPointer <Element> (start: UnsafePointer <Element> (pointer), count: size)
        return try block(DispatchData <Element> (data: mappedData), buffer)
    }

    // MARK: -

    /// Non-throwing version of apply
    public func apply(applier: (Range<Int>, UnsafeBufferPointer <Element>) -> Bool) {
        dispatch_data_apply(data) {
            (region: dispatch_data_t!, offset: Int, buffer: UnsafePointer <Void>, size: Int) -> Bool in
            let buffer = UnsafeBufferPointer <Element> (start: UnsafePointer <Element> (buffer), count: size / self.elementSize)
            return applier(offset..<offset + size, buffer)
        }
    }

    /// Throwing version of apply
    public func apply(applier: (Range<Int>, UnsafeBufferPointer <Element>) throws -> Bool) throws {
        var savedError: ErrorType? = nil
        dispatch_data_apply(data) {
            (region: dispatch_data_t!, offset: Int, buffer: UnsafePointer <Void>, size: Int) -> Bool in
            let buffer = UnsafeBufferPointer <Element> (start: UnsafePointer <Element> (buffer), count: size / self.elementSize)
            do {
                return try applier(offset..<offset + size, buffer)
            }
            catch let error {
                savedError = error
                return false
            }
        }
        if let savedError = savedError {
            throw savedError
        }
    }

    public func convert <U> () -> DispatchData <U> {
        return DispatchData <U> (data: data)
    }
}

// MARK: Equatable

extension DispatchData: Equatable {
}

/**
    Equality operator.

    Warning. This can copy zero, one or both Data buffers. This can be extremely slow.
*/
public func == <Element> (lhs: DispatchData <Element>, rhs: DispatchData <Element>) -> Bool {

    // If we're backed by the same dispatch_data then yes, we're equal.
    if lhs.data === rhs.data {
        return true
    }

    // If counts are different then no, we're not equal.
    guard lhs.count == rhs.count else {
        return false
    }

    // Otherwise let's map both the data and memcmp. This can alloc _and_ copy _both_ functions and can therefore be extremely slow.
    return lhs.createMap() {
        (lhsData, lhsBuffer) -> Bool in

        return rhs.createMap() {
            (rhsData, rhsBuffer) -> Bool in

            let result = memcmp(lhsBuffer.baseAddress, rhsBuffer.baseAddress, lhsBuffer.length)
            return result == 0
        }
    }
}

// MARK: CustomStringConvertible

extension DispatchData: CustomStringConvertible {
    public var description: String {
        var chunkCount = 0
        apply() {
            (range, pointer) in
            chunkCount += 1
            return true
        }
        return "DispatchData(count: \(count), length: \(length), chunk count: \(chunkCount), data: \(data))"
    }
}

// MARK: subscript

public extension DispatchData {
    public subscript (range: Range <Int>) -> DispatchData <Element> {
        do {
            return try subBuffer(range)
        }
        catch let error {
            fatalError(String(error))
        }
    }
}

// MARK: Concot.

public func + <Element> (lhs: DispatchData <Element>, rhs: DispatchData <Element>) -> DispatchData <Element> {
    let data = dispatch_data_create_concat(lhs.data, rhs.data)
    return DispatchData <Element> (data: data)
}


// MARK: Manipulation

/// Do not really like these function names but they're very useful.
public extension DispatchData {

    public func subBuffer(range: Range <Int>) throws -> DispatchData <Element> {
        guard range.startIndex >= startIndex && range.startIndex <= endIndex else {
            throw Error.Generic("Index out of range")
        }
        guard range.endIndex >= startIndex && range.endIndex <= endIndex else {
            throw Error.Generic("Index out of range")
        }
        guard range.startIndex <= range.endIndex else {
            throw Error.Generic("Index out of range")
        }
        return DispatchData <Element> (data: dispatch_data_create_subrange(data, range.startIndex * elementSize, (range.endIndex - range.startIndex) * elementSize))
    }

    public func subBuffer(startIndex startIndex: Int, count: Int) throws -> DispatchData <Element> {
        return try subBuffer(startIndex..<startIndex + count)
    }

    public func inset(startInset startInset: Int = 0, endInset: Int = 0) throws -> DispatchData <Element> {
        return try subBuffer(startIndex: startInset, count: count - (startInset + endInset))
    }

    public func split(startIndex: Int) throws -> (DispatchData <Element>, DispatchData <Element>) {
        let lhs = try subBuffer(startIndex: 0, count: startIndex)
        let rhs = try subBuffer(startIndex: startIndex, count: count - startIndex)
        return (lhs, rhs)
    }

    func split <T> () throws -> (T, DispatchData) {
        let (left, right) = try split(sizeof(T))
        let value = left.createMap() {
            (data, buffer) in
            return (buffer.toUnsafeBufferPointer() as UnsafeBufferPointer <T>)[0]
        }
        return (value, right)
    }

}

// MARK: -

public extension DispatchData {
    init <U: IntegerType> (value: U) {
        var copy = value
        self = withUnsafePointer(&copy) {
            let buffer = UnsafeBufferPointer <U> (start: $0, count: 1)
            return DispatchData <U> (buffer: buffer).convert()
        }
    }
}

// MARK: -

public extension DispatchData {

    // TODO: This is a bit dangerous (not anything can/should be convertable to a DispatchData). Investigate deprecating? No more dangerous than & operator though?
    init <U> (value: U) {
        var copy = value
        let data: dispatch_data_t = withUnsafePointer(&copy) {
            let buffer = UnsafeBufferPointer <U> (start: $0, count: 1)
            return dispatch_data_create(buffer.baseAddress, buffer.length, nil, nil)
        }
        self.init(data: data)
    }
}

// MARK: -

public extension DispatchData {

    init(_ data: NSData) {
        self = DispatchData(buffer: data.toUnsafeBufferPointer())
    }

    func toNSData() -> NSData {
        guard let data = data as? NSData else {
            fatalError("dispatch_data_t not convertable to NSData")
        }
        return data
    }
}

// MARK: -

public extension DispatchData {

    init(_ string: String, encoding: NSStringEncoding = NSUTF8StringEncoding) throws {
        guard let data = string.dataUsingEncoding(encoding) else {
            throw Error.Generic("Could not encoding string.")
        }
        self = DispatchData(buffer: data.toUnsafeBufferPointer())
    }

}
