//
//  Atomic.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 2/12/16.
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

public class Atomic <T> {
    public var value: T {
        get {
            lock.lock()
            let oldValue = _value
            lock.unlock()
            return oldValue
        }
        set {
            lock.lock()
            let oldValue = _value
            _value = newValue
            if let valueChanged = _valueChanged {
                valueChanged(oldValue, newValue)
            }
            lock.unlock()
        }
    }

    /// Called whenever value changes. NOT called during init.
    public var valueChanged: ((T, T) -> Void)? {
        get {
            lock.lock()
            let oldValue = _valueChanged
            lock.unlock()
            return oldValue
        }
        set {
            lock.lock()
            _valueChanged = newValue
            lock.unlock()
        }
    }

    fileprivate var lock: Locking

    fileprivate var _value: T
    fileprivate var _valueChanged: ((T, T) -> Void)?

    /** - Parameters:
            - Parameter value: Initial value.
            - Parameter lock: Instance conforming to `Locking`. Used to protect access to `value`. The same lock can be shared between multiple Atomic instances.
            - Parameter valueChanged: Closure called whenever value is changed
    */
    public init(_ value: T, lock: Locking = NSLock(), valueChanged: ((T, T) -> Void)? = nil) {
        self._value = value
        self.lock = lock
        self._valueChanged = valueChanged
    }

}


public extension Atomic {

    /// Perform a locking transaction on the instance. This version allows you to modify the value.
    func with <R> (_ closure: (inout T) -> R) -> R {
        lock.lock()
        let result = closure(&_value)
        lock.unlock()
        return result
    }
}
