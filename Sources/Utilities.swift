//
//  Utilities.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 8/10/15.
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

public func unsafeBitwiseEquality <T> (lhs: T, _ rhs: T) -> Bool {
    var lhs = lhs
    var rhs = rhs
    return withUnsafePointers(&lhs, &rhs) {
        return memcmp($0, $1, sizeof(T))  == 0
    }
}


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
