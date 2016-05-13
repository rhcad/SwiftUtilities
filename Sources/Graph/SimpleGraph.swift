//
//  Graph.swift
//  GraphTest
//
//  Created by Jonathan Wight on 2/26/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

public class SimpleGraph <Vertex: Hashable, Weight: Comparable>: GraphType {
    public let vertices: [Vertex]
    public let edges: [(Vertex, Vertex, Weight)]

    public init(edges: [(Vertex, Vertex, Weight)]) {
        self.vertices = Array(Set(edges.map() { return $0.0 }))
        self.edges = edges
    }

    var _edgesForVertex: [Vertex: [(Vertex, Weight)]] = [:]
    var _hits = 0
    var _misses = 0

    public func edgesForVertex(vertex: Vertex) -> [(Vertex, Weight)] {
        if let vertexEdges = _edgesForVertex[vertex] {
            _hits += 1
            return vertexEdges
        }
        else {
            _misses += 1
            let vertexEdges = edges.filter() {
                return $0.0 == vertex
            }
            .map() {
                return ($0.1, $0.2)
            }
            .sort() {
                return $0.1 < $1.1
            }
            _edgesForVertex[vertex] = vertexEdges
            return vertexEdges
        }
    }

}

