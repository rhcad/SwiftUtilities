//
//  Errors.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 6/27/15.
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

struct AnnotatedError: Swift.Error {

    let error: Swift.Error
    let message: String

    init(error: Swift.Error, message: String) {
        self.error = error
        self.message = message
    }

}

// TODO: This is kinda crap.
public enum Error: Swift.Error {
    case generic(String)
    case dispatchIO(Int32, String)
    case unimplemented
    case unknown
}

extension Error: CustomStringConvertible {
    public var description: String {
        switch self {
            case .generic(let string):
                return string
            case .dispatchIO(let code, let string):
                return "\(code) \(string)"
            case .unimplemented:
                return "todo"
            case .unknown:
                return "unknown"
        }
    }
}

public func tryElseFatalError <T> (_ message: String? = nil, closure: () throws -> T) -> T {
    do {
        let result = try closure()
        return result
    }
    catch let error {
        fatalError("\(message ?? "try failed"): \(String(describing: error))")
    }
}

public func makeOSStatusError <T: Integer>(_ status: T, description: String? = nil) -> Swift.Error {

    var userInfo: [String: String]? = nil

    if let description = description {
        userInfo = [NSLocalizedDescriptionKey: description]
    }


    let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status.toIntMax()), userInfo: userInfo)
    return error
}


public func unimplementedFailure( _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never  {
    preconditionFailure(message, file: file, line: line)
}

public func withNoOutput <R>( _ block: () throws -> R) throws -> R {

    fflush(stderr)
    let savedStdOut = dup(fileno(stdout))
    let savedStdErr = dup(fileno(stderr))

    var fd: [Int32] = [ 0, 0 ]
    var err = pipe(&fd)
    guard err >= 0 else {
        throw NSError(domain: NSPOSIXErrorDomain, code: Int(err), userInfo: nil)
    }

    err = dup2(fd[1], fileno(stdout))
    guard err >= 0 else {
        fatalError()
    }

    err = dup2(fd[1], fileno(stderr))
    guard err >= 0 else {
        fatalError()
    }

    defer {
        fflush(stderr)
        var err = dup2(savedStdErr, fileno(stderr))
        guard err >= 0 else {
            fatalError()
        }
        err = dup2(savedStdOut, fileno(stdout))
        guard err >= 0 else {
            fatalError()
        }

        assert(err >= 0)
    }

    let result = try block()

    return result
}
