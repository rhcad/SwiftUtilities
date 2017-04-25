//
//  Bases.swift
//  BinaryTest
//
//  Created by Jonathan Wight on 6/24/15.
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


// MARK: Base Protocols

import Foundation

public protocol BaseDecodable {
    static func decodeFromString(_ string: String, base: Int?) throws -> Self
}

public protocol BaseEncodable {
    func encodeToString(base: Int, prefix: Bool, width: Int?) throws -> String
}

public extension BaseDecodable {
    init(decode string: String, base: Int? = nil) throws {
        self = try Self.decodeFromString(string, base: base)
    }
}

// MARK: UInt types + BaseDecodable

extension UIntMax: BaseDecodable {
}

extension UInt: BaseDecodable {
}

extension UInt32: BaseDecodable {
}

extension UInt16: BaseDecodable {
}

extension UInt8: BaseDecodable {
}

extension UnsignedInteger {
    public static func decodeFromString(_ string: String, base: Int?) throws -> Self {
        var string = string

        // TODO: Base guessing/expectation is broken

        var finalRadix: NamedRadix
        if let base = base {
            guard let radix = NamedRadix(rawValue: base) else {
                throw Error.generic("No standard prefix for base \(base).")
            }
            finalRadix = radix
        }
        else {
            finalRadix = NamedRadix.fromString(string)
        }

        let prefix = finalRadix.constantPrefix
        string = try string.substringFromPrefix(prefix)

        var result: Self = 0

        let base = finalRadix.rawValue

        for c in string.utf8 {
            if let value = try decodeCodeUnit(c, base: base) {
                result *= Self.init(UIntMax(base))
                result += Self.init(UIntMax(value))
            }
        }

        return result
    }
}

// MARK: UInt types + BaseEncodable

extension UIntMax: BaseEncodable {
}

extension UInt: BaseEncodable {
}

extension UInt32: BaseEncodable {
}

extension UInt16: BaseEncodable {
}

extension UInt8: BaseEncodable {
}

extension UnsignedInteger {

    public func encodeToString(base: Int, prefix: Bool = false, width: Int? = nil) throws -> String {
        let value = toUIntMax()

        var s: String = "0"
        if value != 0 {
            let digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
            s = ""
            let count = UIntMax(log(Double(value), base: Double(base))) + 1
            var value = value

            for _ in 0..<count {
                let digit = value % UIntMax(base)
                let char = digits[Int(digit)]
                s = String(char) + s
                value /= UIntMax(base)
            }
        }

       if let width = width {
            let count = s.utf8.count
            let pad = "".padding(toLength: max(width - count, 0), withPad: "0", startingAt: 0)
            s = pad + s
        }


        if let radix = NamedRadix(rawValue: base) , prefix == true {
            s = radix.constantPrefix + s
        }

        return s
    }
}

// MARK: GenericDispatchData + BaseDecodable

// TODO: Swift3
//extension GenericDispatchData: BaseDecodable {
//    public static func decodeFromString(_ string: String, base: Int?) throws -> GenericDispatchData {
//        let data = try Data.decodeFromString(string, base: base)
//        return GenericDispatchData(data)
//    }
//}

// MARK: GenericDispatchData + BaseDecodable(ish)

extension Data: BaseDecodable {

    static public func decodeFromString(_ string: String, base: Int?) throws -> Data {
        precondition(base == 16)

        var octets: [UInt8] = []
        var hiNibble = true
        var octet: UInt8 = 0
        for hexNibble in string.utf8 {
            if hexNibble == 0x20 {
                continue
            }

            if let nibble = try decodeCodeUnit(hexNibble, base: base!) {
                if hiNibble {
                    octet = nibble << 4
                    hiNibble = false
                }
                else {
                    hiNibble = true
                    octets.append(octet | nibble)
                    octet = 0
                }
            }
        }
        if hiNibble == false {
            octets.append(octet)
        }
        return octets.withUnsafeBufferPointer() {
            return Data($0)
        }
    }
}

// MARK: UnsafeBufferPointer + BaseEncodable


extension UnsafeBufferPointer: BaseEncodable {

    public func encodeToString(base: Int, prefix: Bool = false, width: Int? = nil) throws -> String {
        precondition(base == 16)
        precondition(prefix == false)
        precondition(width == nil)
        return withMemoryRebound() {
            (buffer: UnsafeBufferPointer <UInt8>) -> String in

            let hex = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
            return buffer.map({
                let hiNibble = Int($0) >> 4
                let loNibble = Int($0) & 0b1111
                return hex[hiNibble] + hex[loNibble]
            }).joined(separator: "")
        }
    }
}

// MARK: Internal helpers.

enum NamedRadix: Int {
    case binary = 2
    case octal = 8
    case decimal = 10
    case hexadecimal = 16
}

extension NamedRadix {
    var constantPrefix: String {
        switch self {
            case .binary:
                return "0b"
            case .octal:
                return "0o"
            case .decimal:
                return ""
            case .hexadecimal:
                return "0x"
        }
    }

    static func fromString(_ string: String) -> NamedRadix {
        if string.hasPrefix(self.binary.constantPrefix) {
            return .binary
        }
        else if string.hasPrefix(self.octal.constantPrefix) {
            return .octal
        }
        else if string.hasPrefix(self.hexadecimal.constantPrefix) {
            return .hexadecimal
        }
        else {
            return .decimal
        }
    }
}

func decodeCodeUnit(_ codeUnit: UTF8.CodeUnit, base: Int) throws -> UInt8? {
    let value: UInt8
    switch codeUnit {
        // "0" ... "9"
        case 0x30 ... 0x39:
            value = codeUnit - 0x30
        // "A" ... "F"
        case 0x41 ... 0x46 where base >= 16:
            value = codeUnit - 0x41 + 0x0A
        // "a" ... "f"
        case 0x61 ... 0x66 where base >= 16:
            value = codeUnit - 0x61 + 0x0A
        default:
            throw Error.generic("Not a digit of base \(base)")
    }

    if value >= UInt8(base) {
        throw Error.generic("Not a digit of base \(base)")
    }

    return value
}

// MARK: Convenience methods that will probably be deprecated or at least renamed in future

extension Data: BaseEncodable {
    public func encodeToString(base: Int, prefix: Bool = false, width: Int? = nil) throws -> String {
        return try withUnsafeBytes() {
            (bytes: UnsafePointer <UInt8>) -> String in

            let buffer = UnsafeBufferPointer <Void> (start: bytes, count: count)
            return try buffer.encodeToString(base: base, prefix: prefix, width: width)
        }
    }
}

// TODO: Swift3
//extension GenericDispatchData: BaseEncodable {
//    public func encodeToString(base: Int, prefix: Bool = false, width: Int? = nil) throws -> String {
//        return try createMap() {
//            (data, buffer) in
//            return try buffer.encodeToString(base: base, prefix: prefix, width: width)
//        }
//    }
//}

// MARK: Convenience methods that will probably be deprecated or at least renamed in future

@available(*, deprecated, message: "Will be deprecated")
public func binary <T: BaseEncodable> (_ value: T, prefix: Bool = false, width: Int? = nil) throws -> String {
    return try value.encodeToString(base: 2, prefix: prefix, width: width)
}

public extension BaseDecodable {
    @available(*, deprecated, message: "Will be deprecated")
    static func fromHex(_ hex: String) throws -> Self {
        return try Self.decodeFromString(hex, base: 16)
    }
}

public extension BaseEncodable {
    @available(*, deprecated, message: "Will be deprecated")
    func toHex() throws -> String {
        return try encodeToString(base: 16, prefix: false, width: nil)
    }
}
