//
//  Version.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 3/1/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

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
        }

        if scanner.atEnd == false {
            throw Error.InvalidFormatString
        }

        self = Version(major: major, minor: minor, patch: patch, labels: labels)
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
    comparisons += zip(lhsLabels, rhsLabels).map(compare)
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
