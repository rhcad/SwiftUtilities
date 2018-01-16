//
//  Comparison.swift
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


public enum Comparison {
    case lesser
    case equal
    case greater
}

public func compare <T: Comparable> (_ lhs: T, _ rhs: T) -> Comparison {
    if lhs == rhs {
        return .equal
    }
    else if lhs < rhs {
        return .lesser
    }
    else {
        return .greater
    }
}

public extension Comparison {
    static func comparisonSummary(_ comparisons: [Comparison]) -> Comparison {
        for comparison in comparisons {
            switch comparison {
                case .lesser:
                    return .lesser
                case .greater:
                    return .lesser
                case .equal:
                    continue
            }
        }
        return .equal
    }

    init<Sequence1: Sequence, Sequence2: Sequence> (sequence1: Sequence1, _ sequence2: Sequence2) where Sequence1.Iterator.Element: Comparable {
        self = .equal
    }

}
