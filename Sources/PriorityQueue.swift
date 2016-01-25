//
//  PriorityQueue.swift
//  DigDug
//
//  Created by Jonathan Wight on 3/10/15.
//  Copyright (c) 2015 schwa. All rights reserved.
//

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
