//
//  Endianness.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 6/26/15.
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

public enum Endianness {
    case big
    case little
    public static var Native: Endianness = {
//        return UInt16(littleEndian: 1234) == 1234 ? .Little : .Big
#if arch(x86_64) || arch(arm) || arch(arm64) || arch(i386)
    return .little
#else
    fatalError("Unknown Endianness")
#endif
    }()
    public static var Network: Endianness = .big
}

// MARK: -

public protocol EndianConvertable {
    func fromEndianness(_ endianness: Endianness) -> Self
    func toEndianness(_ endianness: Endianness) -> Self
}

// MARK: -

extension UInt: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> UInt {
        switch endianness {
            case .big:
                return UInt(bigEndian: self)
            case .little:
                return UInt(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> UInt {
        switch endianness {
            case .big:
                return bigEndian
            case .little:
                return littleEndian
        }
    }
}

extension UInt8: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> UInt8 {
        return self
    }

    public func toEndianness(_ endianness: Endianness) -> UInt8 {
        return self
    }
}

extension UInt16: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> UInt16 {
        switch endianness {
            case .big:
                return UInt16(bigEndian: self)
            case .little:
                return UInt16(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> UInt16 {
        switch endianness {
            case .big:
                return bigEndian
            case .little:
                return littleEndian
        }
    }
}

extension UInt32: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> UInt32 {
        switch endianness {
            case .big:
                return UInt32(bigEndian: self)
            case .little:
                return UInt32(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> UInt32 {
        switch endianness {
            case .big:
                return bigEndian
            case .little:
                return littleEndian
        }
    }
}

extension UInt64: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> UInt64 {
        switch endianness {
            case .big:
                return UInt64(bigEndian: self)
            case .little:
                return UInt64(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> UInt64 {
        switch endianness {
            case .big:
                return bigEndian
            case .little:
                return littleEndian
        }
    }
}

// MARK: -

extension Int: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> Int {
        switch endianness {
            case .big:
                return Int(bigEndian: self)
            case .little:
                return Int(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> Int {
        switch endianness {
            case .big:
                return bigEndian
            case .little:
                return littleEndian
        }
    }
}

extension Int8: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> Int8 {
        return self
    }

    public func toEndianness(_ endianness: Endianness) -> Int8 {
        return self
    }
}

extension Int16: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> Int16 {
        switch endianness {
            case .big:
                return Int16(bigEndian: self)
            case .little:
                return Int16(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> Int16 {
        switch endianness {
            case .big:
                return bigEndian
            case .little:
                return littleEndian
        }
    }
}

extension Int32: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> Int32 {
        switch endianness {
            case .big:
                return Int32(bigEndian: self)
            case .little:
                return Int32(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> Int32 {
        switch endianness {
            case .big:
                return bigEndian
            case .little:
                return littleEndian
        }
    }
}

extension Int64: EndianConvertable {
    public func fromEndianness(_ endianness: Endianness) -> Int64 {
        switch endianness {
            case .big:
                return Int64(bigEndian: self)
            case .little:
                return Int64(littleEndian: self)
        }
    }

    public func toEndianness(_ endianness: Endianness) -> Int64 {
        switch endianness {
            case .big:
                return bigEndian
            case .little:
                return littleEndian
        }
    }
}
