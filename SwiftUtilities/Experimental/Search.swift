//
//  Search.swift
//  DigDug
//
//  Created by Jonathan Wight on 3/9/15.
//  Copyright (c) 2015 schwa. All rights reserved.
//

import Foundation

// http: //www.redblobgames.com/pathfinding/a-star/introduction.html
// http: //www.redblobgames.com/pathfinding/a-star/implementation.html#sec-1-3

public func breadth_first_search <Location: Hashable> (start: Location, goal: Location, neighbors: Location -> [Location]) -> [Location] {
    var frontier = Array <Location> ()
    frontier.put(start)
//    var came_from: [Location: Location!] = [start: nil]
    var came_from: [Location: Location] = [:]

    while frontier.isEmpty == false {
        let current = frontier.get()!
        if current == goal {
            break
        }
        for next in neighbors(current) {
            if came_from[next] == nil {
                frontier.put(next)
                came_from[next] = current
            }
        }
    }

    if came_from[goal] == nil {
        return []
    }

    var path: [Location] = []
    var current = goal
    while current != start {
        if let from = came_from[current] {
            path.append(from)
            current = from
        }
    }
    return Array(path.reverse())
}

// MARK: -

private extension Array {
    mutating func put(newElement: Element) {
        append(newElement)
    }

    // Complexity O(count)
    mutating func get() -> Element? {
        guard let element = first else {
            return nil
        }
        removeAtIndex(0)
        return element
    }
}
