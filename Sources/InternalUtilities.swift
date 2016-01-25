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

    func get(key: Key, defaultValue: Value) -> Value {
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
    mutating func insert(newElement: Element, @noescape comparator: (Element, Element) -> Bool) {
        append(newElement)
        let count = self.count
        if count == 1 {
            return
        }
        for N in (count - 2).stride(through: 0, by: -1) {
            if comparator(self[N + 1], self[N]) {
                swap(&self[N], &self[N + 1])
            }
        }
    }
}
