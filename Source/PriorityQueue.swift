//
//  PriorityQueue.swift
//  DigDug
//
//  Created by Jonathan Wight on 3/10/15.
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

public struct PriorityQueue <Element, Priority: Comparable> {

    public var binaryHeap: BinaryHeap <(Element, Priority)>

    public init() {
        binaryHeap = BinaryHeap <(Element, Priority)> () {
            return $0.1 < $1.1
        }
    }

    public var count: Int {
        return binaryHeap.count
    }

    public var isEmpty: Bool {
        return binaryHeap.isEmpty
    }

    public mutating func get() -> Element? {
        guard let (element, _) = binaryHeap.pop() else {
            return nil
        }
        return element
    }

    public mutating func put(element: Element, priority: Priority) {
        binaryHeap.push((element, priority))
    }

}

extension PriorityQueue: SequenceType {
    public typealias Generator = PriorityQueueGenerator <Element, Priority>
    public func generate() -> Generator {
        return Generator(queue: self)
    }
}

public struct PriorityQueueGenerator <Value, Priority: Comparable>: GeneratorType {
    public typealias Element = Value
    private var queue: PriorityQueue <Value, Priority>
    public init(queue: PriorityQueue <Value, Priority>) {
        self.queue = queue
    }
    public mutating func next() -> Element? {
        return queue.get()
    }
}
