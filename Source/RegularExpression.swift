//
//  RegularExpression.swift
//  Sketch
//
//  Created by Jonathan Wight on 8/31/14.
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

public struct RegularExpression {

    public let pattern: String
    public let expression: NSRegularExpression

    public init(_ pattern: String, options: NSRegularExpression.Options = NSRegularExpression.Options()) throws {
        self.pattern = pattern
        self.expression = try NSRegularExpression(pattern: pattern, options: options)
    }

    public func search(_ string: String, options: NSRegularExpression.MatchingOptions = NSRegularExpression.MatchingOptions()) -> Match? {
        let length = (string as NSString).length
        guard let result = expression.firstMatch(in: string, options: options, range: NSRange(location: 0, length: length)) else {
            return nil
        }
        return Match(string: string, result: result)
    }

    public func searchAll(_ string: String, options: NSRegularExpression.MatchingOptions = NSRegularExpression.MatchingOptions()) -> [Match] {
        let length = (string as NSString).length
        let result = expression.matches(in: string, options: options, range: NSRange(location: 0, length: length))

        return result.map() {
            return Match(string: string, result: $0)
        }
    }

    public func match(_ string: String, options: NSRegularExpression.MatchingOptions = NSRegularExpression.MatchingOptions()) -> Match? {
        guard let match = search(string, options: options) else {
            return nil
        }
        let firstRange = match.ranges[0]
        if firstRange.lowerBound != string.startIndex {
            return nil
        }
        return match
    }

    // Other ideas from https://docs.python.org/2/library/re.html
    // split, findall, finditer, sub

    public struct Match: CustomStringConvertible {
        public let string: String
        public let result: NSTextCheckingResult

        init(string: String, result: NSTextCheckingResult) {
            self.string = string
            self.result = result
        }

        public var description: String {
            return "Match(\(result.numberOfRanges))"
        }

        public var ranges: [Range <String.Index>] {
            let count = result.numberOfRanges
            let ranges: [Range <String.Index>] = (0..<count).map() {
                let nsRange = self.result.rangeAt($0)
                let range = self.string.convert(nsRange)
                return range!
                }
            return ranges
        }

        public var strings: [String?] {
            let count = result.numberOfRanges
            let groups: [String?] = (0..<count).map() {
                let range = self.result.rangeAt($0)
                if range.location == NSNotFound {
                    return nil
                }
                return (self.string as NSString).substring(with: range)
                }
            return groups
        }
    }
}

public func ~= (pattern: RegularExpression, value: String) -> Bool {
    let match = pattern.search(value)
    return match != nil
}
