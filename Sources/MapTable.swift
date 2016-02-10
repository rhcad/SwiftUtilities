//
//  MapTable.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 1/27/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Foundation

public enum Reference {
    case Strong
    case Weak
}

public struct MapTable <Key: AnyObject, Value: AnyObject> {

    internal private(set) var storage: Box <NSMapTable>

    public init(keyReference: Reference, valueReference: Reference) {

        var initializer: Void -> NSMapTable
        switch (keyReference, valueReference) {
            case (.Strong, .Strong):
                initializer = NSMapTable.strongToStrongObjectsMapTable
            case (.Strong, .Weak):
                initializer = NSMapTable.strongToWeakObjectsMapTable
            case (.Weak, .Strong):
                initializer = NSMapTable.weakToStrongObjectsMapTable
            case (.Weak, .Weak):
                initializer = NSMapTable.weakToWeakObjectsMapTable
        }
        storage = Box(initializer())
    }

    public subscript (key: Key) -> Value? {
        get {
            let value: Value? = storage.value.objectForKey(key) as? Value
            return value
        }
        set {
            if isUniquelyReferencedNonObjC(&storage) == false {
                storage = Box(storage.value.copy())
            }

            if newValue == nil {
                storage.value.removeObjectForKey(key)
            }
            else {
                storage.value.setObject(newValue, forKey: key)
            }
        }
    }
}

extension MapTable: SequenceType {

    public typealias Generator = MapTableGenerator <Key, Value>

    public func generate() -> MapTableGenerator <Key, Value> {
        return MapTableGenerator <Key, Value> (mapTable: self)
    }
}

//extension MapTable: CollectionType {
//}

public struct MapTableGenerator <Key: AnyObject, Value: AnyObject>: GeneratorType {
    public typealias Element =  (Key, Value)

    let keyEnumerator: NSEnumerator
    let valueEnumerator: NSEnumerator

    init(mapTable: MapTable <Key, Value>) {
        keyEnumerator = mapTable.storage.value.keyEnumerator()
        valueEnumerator = mapTable.storage.value.objectEnumerator()!
    }

    public mutating func next() -> Element? {
        guard let nextKey = keyEnumerator.nextObject(), let nextValue = valueEnumerator.nextObject() else {
            return nil
        }

        guard let nextKey2 = nextKey as? Key, let nextValue2 = nextValue as? Value else {
            fatalError()
        }

        return (nextKey2, nextValue2)
    }
}
