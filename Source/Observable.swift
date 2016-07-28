//
//  Observable.swift
//  ObservablePattern
//
//  Created by Jonathan Wight on 10/23/15.
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

public protocol ObservableType {
    associatedtype ElementType
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
                return internalValue
            }
        }
        set {
            let oldValue = lock.with() {
                () -> Element in
                let oldValue = internalValue
                internalValue = newValue
                return oldValue
            }
            if oldValue != newValue {
                notifyObservers(oldValue: oldValue, newValue: newValue)
            }
        }
    }

    internal var internalValue: Element

    public init(_ value: Element) {
        internalValue = value
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
                return internalValue
            }
        }
        set {
            let oldValue = lock.with() {
                () -> Element? in
                let oldValue = internalValue
                internalValue = newValue
                return oldValue
            }
            if oldValue != newValue {
                notifyObservers(oldValue: oldValue, newValue: newValue)
            }
        }
    }

    internal var internalValue: Element?

    public init(_ value: Element?) {
        internalValue = value
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
