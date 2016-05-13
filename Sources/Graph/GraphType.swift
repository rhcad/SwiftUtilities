//
//  Graph.swift
//  GraphTest
//
//  Created by Jonathan Wight on 2/26/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Foundation

public protocol GraphType {
    associatedtype Vertex: Hashable
    associatedtype Weight: Comparable

    var vertices: [Vertex] { get }

    func edgesForVertex(vertex: Vertex) -> [(Vertex, Weight)]
}

public extension GraphType {

    func weightForEdge(vertices: (Vertex, Vertex)) -> Weight? {
        let edges = edgesForVertex(vertices.0)
        guard let weight = edges.filter({ $0.0 == vertices.1 }).first?.1 else {
            return nil
        }
        return weight
    }

}

public extension GraphType {

    func dump() {
        for (index, vertex) in vertices.enumerate() {
            print("\(index), \(vertex), \(edgesForVertex(vertex).count)")
        }
    }

}