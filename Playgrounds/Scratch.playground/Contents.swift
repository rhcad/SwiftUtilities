//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities

let success = Result <Int>.Success(100)
let failure = Result <Int>.Failure(Error.Generic("Oops"))

success ?? 100

if case .Success(let value) = success {
    print(value)
}

if case .Success = success {
    print("Success")
}

//    /// If `self == nil`, returns `nil`.  Otherwise, returns `f(self!)`.
//-> U?
//    /// Returns `nil` if `self` is nil, `f(self!)` otherwise.


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
            case .Success(let y):
                return try f(y)
            case .Failure:
                return nil
        }
    }
}

let foo: String? = nil

foo.map() {
    return $0
}

