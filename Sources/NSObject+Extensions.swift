//
//  NSObject+Extensions.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 1/27/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Foundation

// Internal for now make public later.
internal extension NSObject {

    func copy <T> () -> T {
        guard let copy = copy() as? T else {
            fatalError("Could not create copy of \(self) as type \(T.self)")
        }
        return copy
    }

    func mutableCopy <T> () -> T {
        guard let copy = mutableCopy() as? T else {
            fatalError("Could not create mutable copy of \(self) as type \(T.self)")
        }
        return copy
    }

}
