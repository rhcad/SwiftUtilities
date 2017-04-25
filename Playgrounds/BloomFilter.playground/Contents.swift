//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities

enum Contains {
    case False
    case Maybe
}

struct BloomFilter <Element: Hashable> {

    private(set) var data: Array <UInt8>
    let count: Int

    init(count: Int) {
        self.count = count
        self.data = Array <UInt8> (repeating: 0, count: Int(ceil(Double(count) / 8)))
    }

    mutating func add(value: Element) {
        let hash = value.hashValue
        let position = Int(unsafeBitCast(hash, to: UInt.self) % UInt(count))
        data.withUnsafeMutableBufferPointer() {
            (buffer) in
            bitSet(buffer: buffer, start: position, count: 1, newValue: 1)
            return
        }
    }

    func contains(value: Element) -> Contains {
        let hash = value.hashValue
        let position = Int(unsafeBitCast(hash, to: UInt.self) % UInt(count))
        return data.withUnsafeBufferPointer() {
            (buffer) in
            return bitRange(buffer: buffer, start: position, count: 1) == 0 ? Contains.False : Contains.Maybe
        }
    }

}

var filter = BloomFilter <String>(count: 100)
filter.data
filter.add(value: "hello world")
filter.data
filter.add(value: "girafe")
filter.data
filter.contains(value: "hello world")
filter.contains(value: "donkey")
