//
//  Graph+DotFile.swift
//  GraphTest
//
//  Created by Jonathan Wight on 2/26/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

public extension GraphType {

    func graphViz() -> String {

        func quote(a: Any) -> String {
            return "\"\(a)\""
        }

        var dot = "digraph {\n"
        dot += "\tnode [shape=circle, height=1, width=1]\n"

        for vertex in vertices {
            dot += "\t\"\(vertex)\" [label=\"\(vertex)\"]\n"
        }

        for vertex in vertices {
            let edges = edgesForVertex(vertex)
            for edge in edges {
                let attributes = [
//                    "label": quote(edge.1),
                    "len": String(edge.1),
                ]
                let attributesString = attributes.map() {
                    return "\($0)=\($1)"
                }.joinWithSeparator(",")
                dot += "\t\(quote(vertex)) -> \(quote(edge.0)) [\(attributesString)]\n"
            }
        }

        dot += "}\n"
        return dot
    }


}

