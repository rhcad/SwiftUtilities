//
//  TravellingSalesman.swift
//  GraphTest
//
//  Created by Jonathan Wight on 2/26/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Foundation

public enum GraphError: ErrorType {
    case NoUnvisitedEdge
}

public extension GraphType {

    public func nearestNeighbourRandom() throws -> [Vertex] {
        if vertices.count == 0 {
            return []
        }
        let index = Int(arc4random_uniform(UInt32(vertices.count)))
        let start = vertices[index]
        return try nearestNeighbour(start)
    }

    public func nearestNeighbour(start: Vertex) throws -> [Vertex] {
        var visited = Set <Vertex> ()
        var vertex = start
        var route: [Vertex] = [ vertex ]
        while true {
            visited.insert(vertex)
            let edges = edgesForVertex(vertex).filter() {
                return visited.contains($0.0) == false
            }

            var closestEdge = edges.first!
            for edge in edges.dropFirst() {
                if edge.1 <= closestEdge.1 {
                    closestEdge = edge
                }
            }

            let next = closestEdge.0

            route.append(next)
            if route.count == vertices.count {
                break
            }
            vertex = next
        }
        return route + [start]
    }
}
