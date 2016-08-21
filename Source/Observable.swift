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
    func addObserver(_ observer: AnyObject, closure: @escaping () -> Void)
    func addObserver(_ observer: AnyObject, closure: @escaping (ElementType) -> Void)
    func addObserver(_ observer: AnyObject, closure: @escaping (ElementType, ElementType) -> Void)
    func removeObserver(_ observer: AnyObject)
}

// MARK: -

extension ObservableType {

    public func addObserver(_ observer: AnyObject, queue: DispatchQueue, closure: @escaping () -> Void) {
        addObserver(observer) {
            queue.async {
                closure()
            }
        }
    }

    public func addObserver(_ observer: AnyObject, queue: DispatchQueue, closure: @escaping (ElementType) -> Void) {
        addObserver(observer) {
            (newValue: ElementType) in

            queue.async {
                closure(newValue)
            }
        }
    }

    public func addObserver(_ observer: AnyObject, queue: DispatchQueue, closure: @escaping (ElementType, ElementType) -> Void) {
        addObserver(observer) {
            (oldValue: ElementType, newValue: ElementType) in

            queue.async {
                closure(oldValue, newValue)
            }
        }
    }

}

// MARK: -

open class ObservableProperty <Element: Equatable>: ObservableType {

    public typealias ElementType = Element

    open var value: Element {
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

    open func addObserver(_ observer: AnyObject, closure: @escaping () -> Void) {
        lock.with() {
            observers.setObject(Box(Callback.noValue(closure)), forKey: observer)
            closure()
        }
    }

    open func addObserver(_ observer: AnyObject, closure: @escaping (Element) -> Void) {
        lock.with() {
            observers.setObject(Box(Callback.newValue(closure)), forKey: observer)
            closure(value)
        }
    }

    open func addObserver(_ observer: AnyObject, closure: @escaping (Element, Element) -> Void) {
        lock.with() {
            observers.setObject(Box(Callback.newAndOldValue(closure)), forKey: observer)
        }
    }

    open func removeObserver(_ observer: AnyObject) {
        lock.with() {
            observers.removeObject(forKey: observer)
        }
    }

    fileprivate var lock = NSRecursiveLock()

    fileprivate typealias Callback = ValueChangeCallback <Element>
    fileprivate var observers = NSMapTable <AnyObject, Box <Callback>> (keyOptions: .weakMemory, valueOptions: .strongMemory)

    fileprivate func notifyObservers(oldValue: Element, newValue: Element) {
        let callbacks = lock.with() {
            return observers.objectEnumerator()!.allObjects.map() {
                object -> Callback in
                let box = object as! Box <Callback>
                return box.value
            }
        }
        callbacks.forEach() {
            (callback) in

            switch callback {
                case .noValue(let closure):
                    closure()
                case .newValue(let closure):
                    closure(newValue)
                case .newAndOldValue(let closure):
                    closure(oldValue, newValue)
            }
        }
    }
}

// MARK: -

open class ObservableOptionalProperty <Element: Equatable>: ObservableType, ExpressibleByNilLiteral {

    public typealias ElementType = Element?

    open var value: Element? {
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

    open func addObserver(_ observer: AnyObject, closure: @escaping () -> Void) {
        lock.with() {
            observers.setObject(Box(Callback.noValue(closure)), forKey: observer)
            closure()
        }
    }

    open func addObserver(_ observer: AnyObject, closure: @escaping (Element?) -> Void) {
        lock.with() {
            observers.setObject(Box(Callback.newValue(closure)), forKey: observer)
            closure(value)
        }
    }

    open func addObserver(_ observer: AnyObject, closure: @escaping (Element?, Element?) -> Void) {
        lock.with() {
            observers.setObject(Box(Callback.newAndOldValue(closure)), forKey: observer)
        }
    }

    open func removeObserver(_ observer: AnyObject) {
        lock.with() {
            observers.removeObject(forKey: observer)
        }
    }

    fileprivate var lock = NSRecursiveLock()

    fileprivate typealias Callback = ValueChangeCallback <Element?>
    fileprivate var observers = NSMapTable <AnyObject, Box <Callback>> (keyOptions: .weakMemory, valueOptions: .strongMemory)

    fileprivate func notifyObservers(oldValue: Element?, newValue: Element?) {
        let callbacks = lock.with() {
            return observers.objectEnumerator()!.allObjects.map() {
                object -> Callback in
                let box = object as! Box <Callback>
                return box.value
            }
        }
        callbacks.forEach() {
            (callback) in

            switch callback {
                case .noValue(let closure):
                    closure()
                case .newValue(let closure):
                    closure(newValue)
                case .newAndOldValue(let closure):
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
    case noValue(() -> Void)
    case newValue((T) -> Void)
    case newAndOldValue((T, T) -> Void)
}
