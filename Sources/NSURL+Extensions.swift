//
//  NSURL+Extensions.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 1/24/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Foundation

public extension NSURL {
    func URLByResolvingURL() throws -> NSURL {
        let bookmarkData = try self.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.MinimalBookmark, includingResourceValuesForKeys: nil, relativeToURL: nil)
        return try NSURL(byResolvingBookmarkData: bookmarkData, options: .WithoutUI, relativeToURL: nil, bookmarkDataIsStale: nil)
    }
}

public func + (lhs: NSURL, rhs: String) -> NSURL {
    return lhs.URLByAppendingPathComponent(rhs)
}

public func += (inout left: NSURL, right: String) {
    left = left + right
}
