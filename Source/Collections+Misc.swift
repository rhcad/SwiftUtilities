//
//  Collections+Misc.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 5/13/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

/// [1,2,3,4,5].slidingWindow(3) -> [1,2,3], [2,3,4], [3,4,5]
public extension Sequence {
    func slidingWindow(_ windowCount: Int, closure: (Array<Iterator.Element>) -> Void) {
        var generator = makeIterator()
        var window = Array <Iterator.Element> ()
        while window.count < windowCount {
            guard let next = generator.next() else {
                return
            }
            window.append(next)
        }
        closure(window)
        while true {
            window.removeFirst()
            guard let next = generator.next() else {
                return
            }
            window.append(next)
            closure(window)
        }
    }
}

/// [1,2,3,4,5,6,7,8,9,0].chunks(3) -> [1,2,3], [4,5,6], [7,8,9]
public extension Sequence {
    func chunks(_ chunkCount: Int, includeIncomplete: Bool = false, closure: (Array<Iterator.Element>) -> Void) {
        var generator = makeIterator()
        while true {
            var window = Array <Iterator.Element> ()
            while window.count < chunkCount {
                guard let next = generator.next() else {
                    if includeIncomplete == true {
                        closure(window)
                    }
                    return
                }
                window.append(next)
            }
            closure(window)
        }
    }
}
