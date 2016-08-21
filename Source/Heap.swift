//
//  main.swift
//  Heap
//
//  Created by Jonathan Wight on 3/9/15.
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

// https://en.wikipedia.org/wiki/Binary_heap
public struct BinaryHeap <Element> {

    public typealias Comparator = (Element, Element) -> Bool
    public let comparator: Comparator

    public typealias Storage = Array <Element>
    public var array: Storage = []

    public init(comparator: Comparator) {
        self.comparator = comparator
    }

    public init(values: [Element], comparator: Comparator) {
        self.array = values
        self.comparator = comparator
        build(&self.array)
    }

    public var count: Int {
        return array.count
    }

    public mutating func push(_ element: Element) {
        assert(valid(array))
        var index = array.count
        array.append(element)
        while let parentIndex = parentIndexOfElementAtIndex(index) {
            if comparator(array[index], array[parentIndex]) {
                swap(&array[index], &array[parentIndex])
                index = parentIndex
            }
            else {
                break
            }
        }
        assert(valid(array))
    }

    public mutating func pop() -> Element? {
        assert(valid(array))
        guard let root = array.first else {
            return nil
        }
        array[0] = array.last!
        array.removeLast()
        heapify(0)
        assert(valid(array))
        return root
    }

    public var isEmpty: Bool {
        return array.isEmpty
    }

}

private extension BinaryHeap {

    func parentIndexOfElementAtIndex(_ index: Int) -> Int? {
        return index < array.count ? (index - 1) / 2 : nil
    }

    func childIndicesOfElementAtIndex(_ index: Int) -> (Int?, Int?) {
        let lhsIndex = 2 * index + 1
        let rhsIndex = 2 * index + 2
        return (lhsIndex < array.count ? lhsIndex : nil, rhsIndex < array.count ? rhsIndex : nil)
    }

    mutating func heapify(_ index: Int) {
        heapify(&array, index)
    }

    func heapify(_ elements: inout [Element], _ index: Int) {
        let left = 2 * index + 1
        let right = 2 * index + 2
        var largest = index
        if left < elements.count && comparator(elements[left], elements[largest]) {
            largest = left
        }
        if right < elements.count && comparator(elements[right], elements[largest]) {
            largest = right
        }
        if largest != index {
            swap(&elements[index], &elements[largest])
            heapify(&elements, largest)
        }
    }

    // TODO: Not working yet.
    func build(_ elements: inout [Element]) {
        assert(false)

        for i in stride(from: (elements.count - 1), through: 0, by: -1) {
            self.heapify(&elements, i)
        }
    }

    func valid(_ elements: [Element], index: Int = 0) -> Bool {
        guard elements.count > 0 else {
            return true
        }
        let (lhs, rhs) = childIndicesOfElementAtIndex(index)
        if let lhs = lhs {
            if comparator(elements[lhs], elements[index]) {
                return false
            }
            if !valid(elements, index: lhs) {
                return false
            }
        }
        if let rhs = rhs {
            if comparator(elements[rhs], elements[index]) {
                return false
            }
            if !valid(elements, index: rhs) {
                return false
            }
        }
        return true
    }
}
