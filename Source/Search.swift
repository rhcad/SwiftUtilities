//
//  Search.swift
//  DigDug
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
