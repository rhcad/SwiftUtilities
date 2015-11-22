//
//  Observable.swift
//  ObservablePattern
//
//  Created by Jonathan Wight on 10/23/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

public struct Observable <Element: Equatable> {

    public var value: Element {
        didSet {
            if value != oldValue {
                notifyObservers(oldValue: oldValue, newValue: value)
            }
        }
    }

    public init(_ value: Element) {
        self.value = value
    }

    public mutating func addObserver(observer: AnyObject, closure: () -> Void) {
        lock.with() {
            observers.setObject(Box(Callback.NoValue(closure)), forKey: observer)
        }
    }

    public mutating func addObserver(observer: AnyObject, closure: (Element) -> Void) {
        lock.with() {
            observers.setObject(Box(Callback.NewValue(closure)), forKey: observer)
        }
    }

    public mutating func addObserver(observer: AnyObject, closure: (Element, Element) -> Void) {
        lock.with() {
            observers.setObject(Box(Callback.NewAndOldValue(closure)), forKey: observer)
        }
    }

    public mutating func removeObserver(observer: AnyObject) {
        lock.with() {
            observers.removeObjectForKey(observer)
        }
    }

    private var lock = Spinlock()

    private typealias Callback = ValueChangeCallback <Element>
    private let observers: NSMapTable = NSMapTable.weakToStrongObjectsMapTable()

    private mutating func notifyObservers(oldValue oldValue: Element, newValue: Element) {
        let callbacks = lock.with() {
            return observers.map() {
                (key, value) -> Callback in
                let box = value as! Box <Callback>
                return box.value
            }
        }
        callbacks.forEach() {
            (callback) in

            switch callback {
                case .NoValue(let closure):
                    closure()
                case .NewValue(let closure):
                    closure(newValue)
                case .NewAndOldValue(let closure):
                    closure(oldValue, newValue)
            }
        }
    }
}

private enum ValueChangeCallback <T> {
    case NoValue(() -> Void)
    case NewValue(T -> Void)
    case NewAndOldValue((T, T) -> Void)
}


// MARK: -

extension Observable: Equatable {
}

public func == <Element> (lhs: Observable <Element>, rhs: Observable <Element>) -> Bool {
    return lhs.value == rhs.value
}

// MARK: -

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
