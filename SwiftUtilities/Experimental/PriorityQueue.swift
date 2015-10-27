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