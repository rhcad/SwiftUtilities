//
//  Result.swift
//  SwiftIO
//
//  Created by Jonathan Wight on 9/29/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

import Foundation

public enum Result <T> {
    case success(T)
    case failure(ErrorType)

    public var isSuccess: Bool {
        switch self {
            case .success:
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
            case .success(let value):
                return value
            default:
                return nil
        }
    }

    public var error: ErrorType? {
        switch self {
            case .failure(let error):
                return error
            default:
                return nil
        }
    }
}

