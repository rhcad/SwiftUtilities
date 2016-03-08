//
//  Observable.swift
//  ObservablePattern
//
//  Created by Jonathan Wight on 10/23/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

public struct Observable {

    private typealias Callback = () -> Void

    public mutating func addObserver(observer: AnyObject, closure: () -> Void) {
        lock.with() {
            observers[observer] = Box(closure)
        }
    }

    public mutating func removeObserver(observer: AnyObject) {
        lock.with() {
            observers[observer] = nil
        }
    }

    private var lock = NSRecursiveLock()

    private var observers: MapTable <AnyObject, Box <Callback>> = MapTable(keyReference: .Weak, valueReference: .Strong)

    public mutating func notifyObservers() {
        let callbacks = lock.with() {
            return observers.map() {
                (key, box) -> Callback in
                return box.value
            }
        }
        callbacks.forEach() {
            (callback) in

            callback()
        }
    }
}


public struct ObservableProperty <Element: Equatable> {

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
            observers[observer] = Box(Callback.NoValue(closure))
        }
    }

    public mutating func addObserver(observer: AnyObject, closure: (Element) -> Void) {
        lock.with() {
            observers[observer] = Box(Callback.NewValue(closure))
        }
    }

    public mutating func addObserver(observer: AnyObject, closure: (Element, Element) -> Void) {
        lock.with() {
            observers[observer] = Box(Callback.NewAndOldValue(closure))
        }
    }

    public mutating func removeObserver(observer: AnyObject) {
        lock.with() {
            observers[observer] = nil
        }
    }

    private var lock = NSRecursiveLock()

    private typealias Callback = ValueChangeCallback <Element>
    private var observers = MapTable <AnyObject, Box <Callback>> (keyReference: .Weak, valueReference: .Strong)

    private mutating func notifyObservers(oldValue oldValue: Element, newValue: Element) {
        let callbacks = lock.with() {
            return observers.map() {
                (key, box) -> Callback in
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

extension ObservableProperty: Equatable {
}

public func == <Element> (lhs: ObservableProperty <Element>, rhs: ObservableProperty <Element>) -> Bool {
    return lhs.value == rhs.value
}

// MARK: -
