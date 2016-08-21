//
//  Synchronized.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 11/21/15.
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

public protocol Locking {
    mutating func lock()
    mutating func unlock()
}

// MARK: -

public extension Locking {
    mutating func with <R> (closure: () throws -> R) rethrows -> R {
        lock()
        defer {
            unlock()
        }
        return try closure()
    }
}

// MARK: -

extension NSLock: Locking {
}

extension NSRecursiveLock: Locking {
}

// MARK: -

@available(*, deprecated)
public struct Spinlock: Locking {

    var spinlock = OS_SPINLOCK_INIT

    public mutating func lock() {
        OSSpinLockLock(&spinlock)
    }

    public mutating func unlock() {
        OSSpinLockUnlock(&spinlock)
    }
}

// MARK: -

public func synchronized <R> (object: AnyObject, closure: () throws -> R) rethrows -> R {
    objc_sync_enter(object)
    defer {
        let result = objc_sync_exit(object)
        guard Int(result) == OBJC_SYNC_SUCCESS else {
            fatalError()
        }
    }
    return try closure()
}
