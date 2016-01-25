//
//  AStarSearch.swift
//  DigDug
//
//  Created by Jonathan Wight on 3/10/15.
//  Copyright (c) 2015 schwa. All rights reserved.
//

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
