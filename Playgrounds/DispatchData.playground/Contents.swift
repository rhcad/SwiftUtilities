//: Playground - noun: a place where people can play

import Foundation

import SwiftUtilities

extension GenericDispatchData: SequenceType {

    public typealias Generator = GenericDispatchDataGenerator <Element>

    public func generate() -> Generator {
        return GenericDispatchDataGenerator <Element> (self)
    }

}

public struct GenericDispatchDataGenerator <Element>: GeneratorType {

    var remaining: GenericDispatchData <Element>

<<<<<<< Updated upstream
    public init(_ dispatchData: DispatchData <Element>) {
=======
    @warn_unused_result
    public init(_ dispatchData: GenericDispatchData <Element>) {
>>>>>>> Stashed changes
        remaining = dispatchData
    }

    public mutating func next() -> Element? {
        if remaining.length == 0 {
            return nil
        }
        let (current, newRemaining) = remaining.split(1)
        remaining = newRemaining
        return current.createMap() {
            (data, buffer)  in
            return buffer[0]
        }
    }
}

let array = [1, 2, 3, 4, 5, 6]

// Copy array into a GenericDispatchData
let data = array.withUnsafeBufferPointer() {
    (buffer) in
    return GenericDispatchData <Int> (buffer: buffer)
}

for value in data {
    print(value)
}


extension GenericDispatchData {

    public func map(transform: (Element) throws -> Element) rethrows -> [Element] {
        var result: [Element] = []
        apply() {
            (range, buffer) in
            for value in buffer {
                let value = try! transform(value)
                result.append(value)
            }
            return true
        }
        return result
    