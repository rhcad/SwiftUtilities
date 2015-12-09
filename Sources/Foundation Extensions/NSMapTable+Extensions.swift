//
//  NSMapTable+Extensions.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 12/9/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

extension NSMapTable: SequenceType {

    public typealias Generator = NSMapTableGenerator

    public func generate() -> NSMapTableGenerator {
        return NSMapTableGenerator(mapTable: self)
    }
}

public struct NSMapTableGenerator: GeneratorType {
    public typealias Element =  (AnyObject, AnyObject)

    let keyEnumerator: NSEnumerator
    let objectEnumerator: NSEnumerator

    init(mapTable: NSMapTable) {
        keyEnumerator = mapTable.keyEnumerator()
        objectEnumerator = mapTable.objectEnumerator()!
    }

    public mutating func next() -> Element? {
        guard let nextKey = keyEnumerator.nextObject(), let nextObject = objectEnumerator.nextObject() else {
            return nil
        }
        return (nextKey, nextObject)
    }
}
