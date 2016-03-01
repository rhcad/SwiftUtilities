//
//  Comparison.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 3/1/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

public enum Comparison {
    case Lesser
    case Equal
    case Greater
}

public func compare <T: Comparable> (lhs: T, _ rhs: T) -> Comparison {
    if lhs == rhs {
        return .Equal
    }
    else if lhs < rhs {
        return .Lesser
    }
    else {
        return .Greater
    }
}

