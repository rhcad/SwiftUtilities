//
//  MapTable.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 1/27/16.
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
