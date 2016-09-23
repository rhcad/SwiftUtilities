//
//  InternalUtilities.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 1/24/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Foundation

internal extension Dictionary {

    init(items: [(Key, Value)]) {
        var d = Dictionary()
        for (key, value) in items {
            d[key] = value
        }
        self = d
    }

    func get(_ key: Key, defaultValue: Value) -> Value {
        var value = self[key]
        if value == nil {
            value = defaultValue
        }
        return value!
    }
}

internal extension Array {

    /** Finds the location newElement belongs within the already sorted array, and inserts it there.
        - Complexity: O(n) but see documentation for `Array.append`.
    */
    mutating func insert(_ newElement: Element, comparator: (Element, Element) -> Bool) {
        append(newElement)
        let count = self.count
        if count == 1 {
            return
        }
        for N in stride(from: (count - 2), through: 0, by: -1) {
            if comparator(self[N + 1], self[N]) {
                swap(&self[N], &self[N + 1])
            }
        }
    }
}


internal func cast <T, R> (_ value: Optional <T>) throws -> R {
    guard let castValue = value as? R else {
        throw Error.generic("Could not cast value (\(value)) of type \(T.self) to \(R.self)")
    }
    return castValue
}

internal func cast <T, R> (_ value: T) throws -> R {
    guard let castValue = value as? R else {
        throw Error.generic("Could not cast value (\(value)) of type \(T.self) to \(R.self)")
    }
    return castValue
}
