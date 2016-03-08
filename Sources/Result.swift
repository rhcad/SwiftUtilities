//
//  Result.swift
//  SwiftIO
//
//  Created by Jonathan Wight on 9/29/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

public enum Result <T> {
    case Success(T)
    case Failure(ErrorType)
}

public extension Result {
    @warn_unused_result
    func map<U>(@noescape f: T throws -> U) rethrows -> Result<U> {
        switch self {
            case .Success(let value):
                return .Success(try f(value))
            case .Failure(let error):
                return .Failure(error)
        }
    }

    @warn_unused_result
    func flatMap<U>(@noescape f: T throws -> U?) rethrows -> U? {
        switch self {
            case .Success(let value):
                return try f(value)
            case .Failure:
                return nil
        }
    }
}

public func ?? <T> (lhs: Result<T>, @autoclosure rhs: () -> T) -> T {
	if case .Success(let value) = lhs {
        return value
    }
    else {
        return rhs()
    }
}

