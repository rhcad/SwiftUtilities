//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities


public func cast <T, R> (value: T?) throws -> R {
    guard let castValue = value as? R else {
        throw Error.Generic("Could not cast value (\(value)) of type \(T.self) to \(R.self)")
    }
    return castValue
}

public func cast <T, R> (value: T) throws -> R {
    guard let castValue = value as? R else {
        throw Error.Generic("Could not cast value (\(value)) of type \(T.self) to \(R.self)")
    }
    return castValue
}



func encode(format: String, payload: [Any]) throws -> GenericDispatchData <Void> {

    var data = GenericDispatchData <Void> ()
    var payloadIndex = 0

    for c in format.characters {
        switch c {
            case "@", "=", "<", ">", "!":
                break
            case "x": // Padding
                data = data + GenericDispatchData(value: UInt8(0))
            case "c", "B": // String of length 1, Unsigned Char
                let value: UInt8 = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: value)
            case "b": // signed char
                let value: Int8 = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: value)
            case "?": // bool
                let value: Bool = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: Int8(value ? -1 : 0))
            case "h": // signed char
                let value: Int16 = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: value)
            case "H": // unsigned char
                let value: UInt16 = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: value)
            case "i", "l": // signed int, signed long
                let value: Int32 = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: value)
            case "I", "L": // unsigned int, unsigned long
                let value: UInt32 = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: value)
            case "q": // signed long long
                let value: Int64 = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: value)
            case "Q": // unsigned long long
                let value: UInt64 = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: value)
            case "f": // float
                let value: Float = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: value)
            case "d": // double
                let value: Double = try cast(payload[payloadIndex++])
                data = data + GenericDispatchData(value: value)
            default:
                throw Error.Generic("Unknown format character: \(c)")
        }
    }

    return data
}

let result = try! encod