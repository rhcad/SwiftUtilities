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

    public var isSuccess: Bool {
        switch self {
            case .Success:
                return true
            default:
                return false
        }
    }

    public var isFailure: Bool {
        return !isSuccess
    }

    public var value: T? {
        switch self {
            case .Success(let value):
                return value
            default:
                return nil
        }
    }

    public var error: ErrorType? {
        switch self {
            case .Failure(let error):
                return error
            default:
                return nil
        }
    }
}

