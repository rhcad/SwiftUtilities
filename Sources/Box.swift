//
//  Box.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 10/27/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

public class Box <Element> {
    public let value: Element
    public init(_ value: Element) {
        self.value = value
    }
}

extension Box {
    // Stolen from https://github.com/robrix/Box/blob/master/Box/Box.swift
    public func map<U> (@noescape f: Element -> U) -> Box<U> {
		return Box<U> (f(value))
	}
}

extension Box: CustomStringConvertible {
    public var description: String {
		return String(value)
	}
}
