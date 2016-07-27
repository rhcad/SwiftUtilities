//
//  Version.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 3/1/16.
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

public struct Version {

    enum Error: ErrorType {
        case InvalidFormatString
    }

    public let major: UInt
    public let minor: UInt
    public let patch: UInt
    public let labels: [String]

    public init(major: UInt, minor: UInt, patch: UInt, labels: [String] = []) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.labels = labels
    }

    public init(_ tuple: (UInt, UInt, UInt), labels: [String] = []) {
        self = Version(major: tuple.0, minor: tuple.1, patch: tuple.2, labels: labels)
    }

    public var majorMinorPatch: (UInt, UInt, UInt) {
        return (major, minor, patch)
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return "\(major).\(minor).\(patch)" + (labels.isEmpty ? "" : "-" + labels.joinWithSeparator("."))
    }
}

extension Version: Equatable {
}

public func == (lhs: Version, rhs: Version) -> Bool {
    return compare(lhs, rhs) == .Equal
}

extension Version: Comparable {
}

public func < (lhs: Version, rhs: Version) -> Bool {
    return compare(lhs, rhs) == .Lesser
}


public extension Version {
    init(_ string: String) throws {
        let scanner = NSScanner(string: string)
        scanner.charactersToBeSkipped = NSCharacterSet()

        var major: UInt = 0
        var minor: UInt = 0
        var patch: UInt = 0
        var labels: [String] = []

        var result = scanner.scanUnsignedInteger(&major)
        if result == false {
            throw Error.InvalidFormatString
        }
        result = scanner.scanString(".", intoString: nil)
        if result == true {
            result = scanner.scanUnsignedInteger(&minor)
            if result == false {
                throw Error.InvalidFormatString
            }
            result = scanner.scanString(".", intoString: nil)
            if result == true {
                result = scanner.scanUnsignedInteger(&patch)
                if result == false {
                    throw Error.InvalidFormatString
                }
            }
            if scanner.scanString("-", intoString: nil) {
                let set = NSCharacterSet.alphanumericCharacterSet() + NSCharacterSet(charactersInString: "-")
                while true {
                    var label: NSString? = nil
                    result = scanner.scanCharactersFromSet(set, intoString: &label)
                    if result == false {
                        throw Error.InvalidFormatString
                    }
                    labels.append(label as! String)
                    result = scanner.scanString(".", intoString: nil)
                    if result == false {
                        break
                    }
                }
            }
        }

        if scanner.atEnd == false {
            throw Error.InvalidFormatString
        }

        self = Version(major: major, minor: minor, patch: patch, labels: labels)
    }
}

private extension String {
    var isNumeric: Bool {
        return unicodeScalars.reduce(true) {
            accumulator, value in
            return accumulator && ("0" ... "9").contains(value)
        }
    }
}

private enum Label {
    case string(String)
    case numeric(Int)

    init(string: String) {
        if string.isNumeric {
            self = .numeric(Int(string)!)
        }
        else {
            self = .string(string)
        }
    }
}

extension Label: Comparable {
}

private func == (lhs: Label, rhs: Label) -> Bool {
    switch (lhs, rhs) {
    case (.string(let lhs), .string(let rhs)):
        return lhs == rhs
    case (.numeric(let lhs), .numeric(let rhs)):
        return lhs == rhs
    default:
        return false
    }
}

private func < (lhs: Label, rhs: Label) -> Bool {
    switch (lhs, rhs) {
    case (.string(let lhs), .string(let rhs)):
        return lhs < rhs
    case (.numeric(let lhs), .numeric(let rhs)):
        return lhs < rhs
    default:
        return false
    }
}


func compare(lhs: Version, _ rhs: Version) -> Comparison {
    var comparisons = [
        compare(lhs.major, rhs.major),
        compare(lhs.minor, rhs.minor),
        compare(lhs.patch, rhs.patch),
    ]
    let count = max(lhs.labels.count, rhs.labels.count)
    let lhsLabels = lhs.labels + Repeat(count: count - lhs.labels.count, repeatedValue: "")
    let rhsLabels = rhs.labels + Repeat(count: count - rhs.labels.count, repeatedValue: "")
    comparisons += zip(lhsLabels.map(Label.init), rhsLabels.map(Label.init)).map(compare)
    for comparison in comparisons {
        if comparison != .Equal {
            return comparison
        }
    }
    return .Equal
}

private extension NSScanner {
    func scanUnsignedInteger(result: UnsafeMutablePointer<UInt>) -> Bool {
        var value: UInt64 = 0
        guard scanUnsignedLongLong(&value) == true else {
            return false
        }
        if result != nil {
            result.memory = UInt(value)
        }
        return true
    }
}

private func + (lhs: NSCharacterSet, rhs: NSCharacterSet) -> NSCharacterSet {
    let working = lhs.mutableCopy() as! NSMutableCharacterSet
    working.formUnionWithCharacterSet(rhs)
    return working
}
