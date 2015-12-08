//
//  Synchronized.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 11/21/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

protocol Locking {
    mutating func lock()
    mutating func unlock()
}

// MARK: -

extension Locking {
    mutating func with <R> (@noescape closure: () throws -> R) rethrows -> R {
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

struct Spinlock: Locking {

    var spinlock = OS_SPINLOCK_INIT

    mutating func lock() {
        OSSpinLockLock(&spinlock)
    }

    mutating func unlock() {
        OSSpinLockUnlock(&spinlock)
    }
}

// MARK: -

public func synchronized <R> (object: AnyObject, @noescape closure: () throws -> R) rethrows -> R {
    objc_sync_enter(object)
    defer {
        let result = objc_sync_exit(object)
        guard Int(result) == OBJC_SYNC_SUCCESS else {
            fatalError()
        }
    }
    return try closure()
}
