//
//  NSRange.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 9/13/14.
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

public extension NSRange {

    init(range: Range <Int>) {
        self.location = range.lowerBound
        self.length = range.upperBound - range.lowerBound
    }

    var startIndex: Int { return location }
    var endIndex: Int { return location + length }
    var asRange: CountableRange<Int> { return location..<location + length }
    var isEmpty: Bool { return length == 0 }

    func contains(_ index: Int) -> Bool {
        return index >= location && index < endIndex
    }


    func clamp(_ index: Int) -> Int {
        return max(self.startIndex, min(self.endIndex, index))
    }

    func clamp(_ range: NSRange) -> NSRange {

        let startIndex = clamp(range.startIndex)
        let endIndex = clamp(range.endIndex)
        return NSRange(range: startIndex..<endIndex)
    }

    func intersects(_ range: NSRange) -> Bool {
        return NSIntersectionRange(self, range).isEmpty == false
    }

    func intersection(_ range: NSRange) -> NSRange? {
        let intersection = NSIntersectionRange(self, range)
        if intersection.isEmpty {
            return nil
        }
        else {
            return intersection
        }
    }

    func contiguous(_ range: NSRange) -> Bool {
        let (lhs, rhs) = ordered((self, range))
        return lhs.endIndex == rhs.startIndex
    }

    func union(_ range: NSRange) -> NSRange {
        return NSUnionRange(self, range)
    }
}

//extension NSRange: CustomStringConvertible {
//    public var description: String {
//        return "\(startIndex)..<\(endIndex)"
//    }
//}

//extension NSRange: Equatable {
//}

public func == (lhs: NSRange, rhs: NSRange) -> Bool {
    return NSEqualRanges(lhs, rhs)
}

extension NSRange: Comparable {
}

public func < (lhs: NSRange, rhs: NSRange) -> Bool {
    if lhs.location < rhs.location {
        return true
    }
    else if lhs.location == rhs.location {
        return lhs.length < rhs.length
    }
    else {
        return false
    }
}
