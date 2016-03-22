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

public extension Comparison {
    static func comparisonSummary(comparisons: [Comparison]) -> Comparison {
        for comparison in comparisons {
            switch comparison {
                case .Lesser:
                    return .Lesser
                case .Greater:
                    return .Lesser
                case .Equal:
                    continue
            }
        }
        return .Equal
    }

    init<Sequence1 : SequenceType , Sequence2 : SequenceType where Sequence1.Generator.Element: Comparable> (sequence1: Sequence1, _ sequence2: Sequence2) {
        self = .Equal
    }

}