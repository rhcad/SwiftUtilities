//
//  Observable.swift
//  ObservablePattern
//
//  Created by Jonathan Wight on 10/23/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

public class ObservableProperty <ValueType> {

    public var value: ValueType {
        didSet {
            observable.notifyObservers()
        }
    }
    public var observable = Observable()

    public init(_ value: ValueType) {
        self.value = value
    }
}

// MARK: -

public class Observable {

    public typealias Callback = Void -> Void

    public let observers: NSMapTable = NSMapTable.weakToStrongObjectsMapTable()

    public func registerObserver(observer: AnyObject, closure: Callback) {
        observers.setObject(Box(closure), forKey: observer)
    }

    public func unregisterObserver(observer: AnyObject) {
        observers.removeObjectForKey(observer)
    }

    public func notifyObservers() {
        let boxes = observers.map() {
            (key, value) in
            return value as! Box <Callback>
        }
        boxes.forEach() {
            $0.value()
        }
    }
}


// MARK: -

extension NSMapTable: SequenceType {

    public typealias Generator = _Generator

    public struct _Generator: GeneratorType {
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

    public func generate() -> _Generator {
        return _Generator(mapTable: self)
    }
}
