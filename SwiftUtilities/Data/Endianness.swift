//
//  Endianness.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 6/26/15.
//
//  Copyright (c) 2014, Jonathan Wight
//  All rights reserved.
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

public enum Endianess {
    case Big
    case Little
    public static var Native: Endianess = {
        return UInt16(littleEndian: 1234) == 1234 ? .Little : .Big
    }()
    public static var Network: Endianess = .Big
}

// MARK: -

protocol EndianConvertable {
    func fromEndianess(endianess: Endianess) -> Self
    func toEndianess(endianess: Endianess) -> Self
}

// MARK: -

extension UInt8: EndianConvertable {
    func fromEndianess(endianess: Endianess) -> UInt8 {
        return self
    }

    func toEndianess(endianess: Endianess) -> UInt8 {
        return self
    }
}

extension UInt16: EndianConvertable {
    func fromEndianess(endianess: Endianess) -> UInt16 {
        switch endianess {
            case .Big:
                return UInt16(bigEndian: self)
            case .Little:
                return UInt16(littleEndian: self)
        }
    }

    func toEndianess(endianess: Endianess) -> UInt16 {
        switch endianess {
            case .Big:
                return bigEndian
            case .Little:
                return littleEndian
        }
    }
}

extension UInt32: EndianConvertable {
    func fromEndianess(endianess: Endianess) -> UInt32 {
        switch endianess {
            case .Big:
                return UInt32(bigEndian: self)
            case .Little:
                return UInt32(littleEndian: self)
        }
    }

    func toEndianess(endianess: Endianess) -> UInt32 {
        switch endianess {
            case .Big:
                return bigEndian
            case .Little:
                return littleEndian
        }
    }
}

extension UInt64: EndianConvertable {
    func fromEndianess(endianess: Endianess) -> UInt64 {
        switch endianess {
            case .Big:
                return UInt64(bigEndian: self)
            case .Little:
                return UInt64(littleEndian: self)
        }
    }

    func toEndianess(endianess: Endianess) -> UInt64 {
        switch endianess {
            case .Big:
                return bigEndian
            case .Little:
                return littleEndian
        }
    }
}

// MARK: -

extension Int8: EndianConvertable {
    func fromEndianess(endianess: Endianess) -> Int8 {
        return self
    }

    func toEndianess(endianess: Endianess) -> Int8 {
        return self
    }
}

extension Int16: EndianConvertable {
    func fromEndianess(endianess: Endianess) -> Int16 {
        switch endianess {
            case .Big:
                return Int16(bigEndian: self)
            case .Little:
                return Int16(littleEndian: self)
        }
    }

    func toEndianess(endianess: Endianess) -> Int16 {
        switch endianess {
            case .Big:
                return bigEndian
            case .Little:
                return littleEndian
        }
    }
}

extension Int32: EndianConvertable {
    func fromEndianess(endianess: Endianess) -> Int32 {
        switch endianess {
            case .Big:
                return Int32(bigEndian: self)
            case .Little:
                return Int32(littleEndian: self)
        }
    }

    func toEndianess(endianess: Endianess) -> Int32 {
        switch endianess {
            case .Big:
                return bigEndian
            case .Little:
                return littleEndian
        }
    }
}

extension Int64: EndianConvertable {
    func fromEndianess(endianess: Endianess) -> Int64 {
        switch endianess {
            case .Big:
                return Int64(bigEndian: self)
            case .Little:
                return Int64(littleEndian: self)
        }
    }

    func toEndianess(endianess: Endianess) -> Int64 {
        switch endianess {
            case .Big:
                return bigEndian
            case .Little:
                return littleEndian
        }
    }
}
