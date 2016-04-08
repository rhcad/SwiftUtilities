//
//  AStarSearch.swift
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

public struct AStarSearch <Location: Hashable> {

    public typealias Cost = Int

    public var neighbors: (Location -> [Location])!
    public var cost: ((Location, Location) -> Cost)!
    public var heuristic: ((Location, Location) -> Cost)!

    public init() {
    }

    public func search(start: Location, goal: Location) -> [Location] {
        var frontier = PriorityQueue <Location, Int> ()
        frontier.put(start, priority: 0)

        var came_from: [Location: Location] = [:]
        var cost_so_far: [Location: Cost] = [:]

        came_from[start] = start
        cost_so_far[start] = 0

        while frontier.count != 0 {
            let current = frontier.get()!

            if current == goal {
                break
            }

            for next in neighbors(current) {
                let new_cost = cost_so_far[current]! + cost(current, next)
                if cost_so_far[next] == nil || new_cost < cost_so_far[next] {
                    cost_so_far[next] = new_cost
                    let priority = new_cost * heuristic(goal, next)
                    frontier.put(next, priority: priority)
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
}
