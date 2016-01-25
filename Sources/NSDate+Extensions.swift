//
//  NSDate+Extensions.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 12/2/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

public func + (lhs: NSDate, rhs: NSTimeInterval) -> NSDate {
    return lhs.dateByAddingTimeInterval(rhs)
}

public func - (lhs: NSDate, rhs: NSTimeInterval) -> NSDate {
    return lhs.dateByAddingTimeInterval(-rhs)
}
