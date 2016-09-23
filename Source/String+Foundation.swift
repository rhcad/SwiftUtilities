//
//  String+Extensions.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 3/23/15.
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

/**
 *  Set of helper methods to convert String ranges to/from NSString ranges
 *
 *  NSString indices are UTF16 based
 *  String "indices" are Grapheme Cluster based
 *  This allows you convert between the two
 *  Converting is useful when using Cocoa APIs that use NSRanges (for example
 *  text view selection ranges or regular expression result ranges).
 */
public extension String {

    func convert(_ index: NSInteger) -> String.Index? {
        let utf16Index = utf16.index(utf16.startIndex, offsetBy: index)
        return utf16Index.samePosition(in: self)
    }

    func convert(_ range: NSRange) -> Range <String.Index>? {
        let swiftRange = range.asRange
        if let startIndex = convert(swiftRange.lowerBound), let endIndex = convert(swiftRange.upperBound) {
            return startIndex..<endIndex
        }
        else {
            return nil
        }
    }

    func convert(_ index: String.Index) -> NSInteger {
        let utf16Index = index.samePosition(in: utf16)
        return utf16.distance(from: utf16.startIndex, to: utf16Index)
    }

    func convert(_ range: Range <String.Index>) -> NSRange {
        let startIndex = convert(range.lowerBound)
        let endIndex = convert(range.upperBound)
        return NSRange(location: startIndex, length: endIndex - startIndex)
    }

}
