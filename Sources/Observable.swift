//
//  Observable.swift
//  ObservablePattern
//
//  Created by Jonathan Wight on 10/23/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

public protocol ObservableType {
    typealias ElementType
    func addObserver(observer: AnyObject, closure: () -> Void)
    func addObserver(observer: AnyObject, closure: (ElementType) -> Void)
    func addObserver(observer: AnyObject, closure: (ElementType, ElementType) -> Void)
    func removeObserver(observer: AnyObject)
}

// MARK: -

extension ObservableType {

    public func addObserver(observer: AnyObject, queue: dispatch_queue_t, closure: () -> Void) {
        addObserver(observer) {
            dispatch_async(queue) {
                closure()
            }
        }
    }

    public func addObserver(observer: AnyObject, queue: dispatch_queue_t, closure: (ElementType) -> Void) {
        addObserver(observer) {
            (newValue: ElementType) in

            dispatch_async(queue) {
                closure(newValue)
            }
        }
    }

    public func addObserver(observer: AnyObject, queue: dispatch_queue_t, closure: (ElementType, ElementType) -> Void) {
        addObserver(observer) {
            (oldValue: ElementType, newValue: ElementType) in

            dispatch_async(queue) {
                closure(oldValue, newValue)
            }
        }
    }

}

// MARK: -

public class ObservableProperty <Element: Equatable>: ObservableType {

    public typealias ElementType = Element

    public var value: Element {
        get {
            return lock.with() {
                return _value
            }
        }
        set {
            let oldValue = lock.with() {
                () -> Element in
                let oldValue = _value
                _value = newValue
                return oldValue
            }
            notifyObservers(oldValue: oldValue, newValue: newValue)
        }
    }

    public var _value: Element

    public init(_ value: Element) {
        _value = value
    }

    public func addObserver(observer: AnyObject, closure: () -> Void) {
        lock.with() {
            observers[observer] = Box(Callback.NoValue(closure))
            closure()
        }
    }

    public func addObserver(observer: AnyObject, closure: (Element) -> Void) {
        lock.with() {
            observers[observer] = Box(Callback.NewValue(closure))
            closure(value)
        }
    }

    public func addObserver(observer: AnyObject, closure: (Element, Element) -> Void) {
        lock.with() {
            observers[observer] = Box(Callback.NewAndOldValue(closure))
        }
    }

    public func removeObserver(observer: AnyObject) {
        lock.with() {
            observers[observer] = nil
        }
    }

    private var lock = NSRecursiveLock()

    private typealias Callback = ValueChangeCallback <Element>
    private var observers = MapTable <AnyObject, Box <Callback>> (keyReference: .Weak, valueReference: .Strong)

    private func notifyObservers(oldValue oldValue: Element, newValue: Element) {
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

// MARK: -

public class ObservableOptionalProperty <Element: Equatable>: ObservableType, NilLiteralConvertible {

    public typealias ElementType = Element?

    public var value: Element? {
        get {
            return lock.with() {
                return _value
            }
        }
        set {
            let oldValue = lock.with() {
                () -> Element? in
                let oldValue = _value
                _value = newValue
                return oldValue
            }
            notifyObservers(oldValue: oldValue, newValue: newValue)
        }
    }

    public var _value: Element?

    public init(_ value: Element?) {
        _value = value
    }

    public func addObserver(observer: AnyObject, closure: () -> Void) {
        lock.with() {
            observers[observer] = Box(Callback.NoValue(closure))
            closure()
        }
    }

    public func addObserver(observer: AnyObject, closure: (Element?) -> Void) {
        lock.with() {
            observers[observer] = Box(Callback.NewValue(closure))
            closure(value)
        }
    }

    public func addObserver(observer: AnyObject, closure: (Element?, Element?) -> Void) {
        lock.with() {
            observers[observer] = Box(Callback.NewAndOldValue(closure))
        }
    }

    public func removeObserver(observer: AnyObject) {
        lock.with() {
            observers[observer] = nil
        }
    }

    private var lock = NSRecursiveLock()

    private typealias Callback = ValueChangeCallback <Element?>
    private var observers = MapTable <AnyObject, Box <Callback>> (keyReference: .Weak, valueReference: .Strong)

    private func notifyObservers(oldValue oldValue: Element?, newValue: Element?) {
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

    public required init(nilLiteral: ()) {
        value = nil
    }
}

// MARK: -

private enum ValueChangeCallback <T> {
    case NoValue(() -> Void)
    case NewValue(T -> Void)
    case NewAndOldValue((T, T) -> Void)
}

