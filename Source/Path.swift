//
//  Path.swift
//  Dterm 2
//
//  Created by Jonathan Wight on 8/6/15.
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

public struct Path {

    public let path: String

    public init(_ path: String) {
        self.path = path
    }

    public init(_ url: URL) throws {
        guard url.scheme == "file" || url.scheme == "" && url.path.isEmpty == false else {
            throw Error.generic("Not a file url")
        }
        self.path = url.path
    }

    public var url: URL {
        return URL(fileURLWithPath: path)
    }

    public var normalized: Path {
        return Path((path as NSString).expandingTildeInPath)
    }
}

extension Path: Equatable, Comparable {
}

public func == (lhs: Path, rhs: Path) -> Bool {
    return lhs.normalized.path == rhs.normalized.path
}

public func < (lhs: Path, rhs: Path) -> Bool {
    return lhs.normalized.path < rhs.normalized.path
}



// MARK: CustomStringConvertible

extension Path: CustomStringConvertible {
    public var description: String {
        return path
    }
}

// MARK: Path/name manipulation

public extension Path {

    var components: [String] {
        return (path as NSString).pathComponents
    }

//    var parents: [Path] {
//    }

    var parent: Path? {
        return Path((path as NSString).deletingLastPathComponent)
    }

    var name: String {
        return (path as NSString).lastPathComponent
    }

    var pathExtension: String {
        return (path as NSString).pathExtension
    }

    var pathExtensions: [String] {
        return Array(name.components(separatedBy: ".").suffix(from: 1))
    }


    /// The "stem" of the path is the filename without path extensions
    var stem: String {
        return (( path as NSString).lastPathComponent as NSString).deletingPathExtension
    }

    /// Replace the file name portion of a path with name
    func withName(_ name: String) -> Path {
        return parent! + name
    }

    /// Replace the path extension portion of a path. Note path extensions in iOS seem to refer just to last path extension e.g. "z" of "foo.x.y.z".
    func withPathExtension(_ pathExtension: String) -> Path {
        if pathExtension.isEmpty {
            return self
        }
        return withName(stem + "." + pathExtension)
    }

    func withPathExtensions(_ pathExtensions: [String]) -> Path {
        let pathExtension = pathExtensions.joined(separator: ".")
        return withPathExtension(pathExtension)
    }

    /// Replace the stem portion of a path: e.g. calling withStem("bar") on /tmp/foo.txt returns /tmp/bar.txt
    func withStem(_ stem: String) -> Path {
        return (parent! + stem).withPathExtension(pathExtension)
    }

    func pathByExpandingTilde() -> Path {
        return Path((path as NSString).expandingTildeInPath)
    }

    func pathByDeletingLastComponent() -> Path {
        return Path((path as NSString).deletingLastPathComponent)
    }

    var normalizedComponents: [String] {
        var components = self.components
        if components.last == "/" {
            components = Array(components[0..<components.count - 1])
        }
        return components
    }

    func hasPrefix(_ other: Path) -> Bool {
        let lhs = normalizedComponents
        let rhs = other.normalizedComponents

        if rhs.count > lhs.count {
            return false
        }
        return Array(lhs[0..<(rhs.count)]) == rhs
    }

    func hasSuffix(_ other: Path) -> Bool {
        let lhs = normalizedComponents
        let rhs = other.normalizedComponents
        if rhs.count > lhs.count {
            return false
        }
        return Array(lhs[(lhs.count - rhs.count)..<lhs.count]) == rhs
    }

}

// MARK: Operators

public func + (lhs: Path, rhs: Path) -> Path {
    let url = (lhs.path as NSString).appendingPathComponent(rhs.path)
    return Path(url)
}

public func / (lhs: Path, rhs: Path) -> Path {
    let url = (lhs.path as NSString).appendingPathComponent(rhs.path)
    return Path(url)
}

public func + (lhs: Path, rhs: String) -> Path {
    let url = (lhs.path as NSString).appendingPathComponent(rhs)
    return Path(url)
}

public func / (lhs: Path, rhs: String) -> Path {
    let url = (lhs.path as NSString).appendingPathComponent(rhs)
    return Path(url)
}

// MARK: Working Directory

public extension Path {

    static var currentDirectory: Path {
        get {
            return Path(FileManager().currentDirectoryPath)
        }
        set {
            FileManager().changeCurrentDirectoryPath(newValue.path)
        }
    }

}

// MARK: File Types

public enum FileType {
    case regular
    case directory
    case symbolicLink
    case socket
    case characterSpecial
    case blockSpecial
    case unknown
}

// MARK: File Attributes

public extension Path {

    var exists: Bool {
        return attributes != nil ? true : false
    }

    var fileType: FileType {
        guard let attributes = attributes else {
            fatalError()
        }
        return attributes.fileType
    }

    var isDirectory: Bool {
        return fileType == .directory
    }

    func chmod(_ permissions: Int) throws {
        try FileManager().setAttributes([FileAttributeKey.posixPermissions: permissions], ofItemAtPath: path)
    }

}

public extension Path {
    var attributes: FileAttributes? {
        guard (url as NSURL).checkResourceIsReachableAndReturnError(nil) == true else {
            return nil
        }
        return try? FileAttributes(path)
    }
}

public struct FileAttributes {

    fileprivate let path: String

    fileprivate init(_ path: String) throws {
        self.path = path
    }

    fileprivate var url: URL {
        return URL(fileURLWithPath: path)
    }

    public func getAttributes() throws -> [FileAttributeKey : Any] {
        let attributes = try FileManager().attributesOfItem(atPath: path)
        return attributes
    }

    public func getAttribute <T> (key: FileAttributeKey) throws -> T {
        let attributes = try getAttributes()
        guard let attribute = attributes[key] as? T else {
            throw Error.generic("Could not convert value")
        }
        return attribute
    }

    public var fileType: FileType {
        do {
            let type: FileAttributeType = try getAttribute(key: FileAttributeKey.type)
            switch type {
                case FileAttributeType.typeDirectory:
                    return .directory
                case FileAttributeType.typeRegular:
                    return .regular
                case FileAttributeType.typeSymbolicLink:
                    return .symbolicLink
                case FileAttributeType.typeSocket:
                    return .socket
                case FileAttributeType.typeCharacterSpecial:
                    return .characterSpecial
                case FileAttributeType.typeBlockSpecial:
                    return .blockSpecial
                default:
                    return .unknown
            }
        }
        catch {
            return .unknown
        }
    }

    public var isDirectory: Bool {
        return fileType == .directory
    }

    public var length: Int {
        return tryElseFatalError() {
            return try getAttribute(key: FileAttributeKey.size)
        }
    }

    var permissions: Int {
        return tryElseFatalError() {
            return try getAttribute(key: FileAttributeKey.posixPermissions)
        }
    }

}

// Iterating directories

public extension Path {

    var children: [Path] {
        return Array(self)
    }

    func walk(_ closure: (Path) -> Void) throws {
        guard let enumerator = FileManager().enumerator(at: url, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions(), errorHandler: nil) else {
            throw Error.generic("Could not create enumerator")
        }

        for url in enumerator {
            guard let url = url as? URL else {
                throw Error.generic("HMM")
            }
            let path = try Path(url)
            closure(path)
        }
    }


}

// MARK: Creating, moving, removing etc.

public extension Path {

    func createDirectory(withIntermediateDirectories: Bool = false, attributes: [String: AnyObject]? = nil) throws {
        try FileManager().createDirectory(atPath: path, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
    }

    func move(_ destination: Path) throws {
        try FileManager().moveItem(at: url, to: destination.url)
    }

    func remove() throws {
        try FileManager().removeItem(atPath: path)
    }
}


// MARK: Glob

public extension Path {

    func glob() throws -> [Path] {
        let error = {
            (path: UnsafePointer<Int8>?, errno: Int32) -> Int32 in
            return 0
        }
        var globStorage = glob_t()
        let result = glob_b(path, 0, error, &globStorage)
        guard result == 0 else {
            throw (Errno(rawValue: result) ?? Error.unknown)
        }
        let paths = (0..<globStorage.gl_pathc).map() {
            (index) -> Path in
            let pathPtr = globStorage.gl_pathv[index]
            guard let pathString = String(validatingUTF8: pathPtr!) else {
                fatalError("Could not convert path to utf8 string")
            }
            return Path(pathString)
        }
        globfree(&globStorage)
        return paths
    }
}

// MARK: File Rotation

public extension Path {
    func rotate(limit: Int? = nil) throws {
        guard exists else {
            return
        }
        guard let parent = parent else {
            throw Error.generic("No parent")
        }
        let destination: Path
        if let index = Int(pathExtension) {
            destination = parent + (stem + ".\(index + 1)")
            if let limit = limit {
                if index >= limit && exists {
                    try remove()
                    return
                }
            }
        }
        else {
            destination = parent + (name + ".1")
        }
        try destination.rotate(limit: limit)
        try move(destination)
    }
}

// MARK: Temporary Directories

public extension Path {
    static var temporaryDirectory: Path {
        return Path(NSTemporaryDirectory())
    }

    static func makeTemporaryDirectory(_ temporaryDirectory: Path? = nil) throws -> Path {

        let temporaryDirectory = (temporaryDirectory ?? self.temporaryDirectory)
        if temporaryDirectory.exists == false {
            try temporaryDirectory.createDirectory(withIntermediateDirectories: true)
        }

        let templateDirectory = temporaryDirectory + "XXXXXXXX"
        var template = templateDirectory.path.cString(using: String.Encoding.utf8)!
        return template.withUnsafeMutableBufferPointer() {
            (buffer: inout UnsafeMutableBufferPointer <Int8>) -> Path in
            let pointer = mkdtemp(buffer.baseAddress)
            let pathString = String(validatingUTF8: pointer!)!
            let path = Path(pathString)
            return path
        }
    }

    static func withTemporaryDirectory <R> (_ temporaryDirectory: Path? = nil, closure: (Path) throws -> R) throws -> R {

        let path = try makeTemporaryDirectory(temporaryDirectory)
        defer {
            tryElseFatalError() {
                try path.remove()
            }
        }
        return try closure(path)
    }
}

// MARK: Well-Known/Special Directories

public extension Path {

    static var applicationSpecificSupportDirectory: Path {
        let bundle = Bundle.main
        let bundleIdentifier = bundle.bundleIdentifier!
        let path = applicationSupportDirectory! + bundleIdentifier
        if path.exists == false {
            tryElseFatalError() {
                try path.createDirectory(withIntermediateDirectories: true)
            }
        }
        return path
    }

    static func specialDirectory(_ directory: FileManager.SearchPathDirectory, inDomain domain: FileManager.SearchPathDomainMask = .userDomainMask, appropriateForURL url: URL? = nil, create shouldCreate: Bool = true) throws -> Path {

        let url = tryElseFatalError() {
            return try FileManager().url(for: directory, in: domain, appropriateFor: url, create: shouldCreate)
        }

        return try Path(url)
    }
    
    static var libraryDirectory: Path? {
        return try? Path.specialDirectory(.libraryDirectory)
    }

    static var applicationSupportDirectory: Path? {
        return try? Path.specialDirectory(.applicationSupportDirectory)
    }

    static var documentDirectory: Path? {
        return try? Path.specialDirectory(.documentDirectory)
    }
}


public extension Path {

    func createFile() throws {
        if FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) == false {
            throw Error.generic("Could not create file")
        }
    }

    func read() throws -> String {
        let data = try Data(contentsOf: url, options: NSData.ReadingOptions())
        var string: NSString?
        var usedLossyConversion = ObjCBool(false)
        let encodingOptions = [
            StringEncodingDetectionOptionsKey.suggestedEncodingsKey: [String.Encoding.utf8],
            StringEncodingDetectionOptionsKey.useOnlySuggestedEncodingsKey: false,
            StringEncodingDetectionOptionsKey.allowLossyKey: true,
        ] as [StringEncodingDetectionOptionsKey : Any]
        let encoding = NSString.stringEncoding(for: data, encodingOptions: encodingOptions, convertedString: &string, usedLossyConversion: &usedLossyConversion)
        if let string = string as String? , encoding != 0 {
            return string
        }
        throw Error.generic("Could not decode data.")
    }

    func write(_ string: String, encoding: String.Encoding = .utf8) throws {
        try string.write(toFile: path, atomically: true, encoding: encoding)
    }

}

// MARK: -

extension Path: Sequence {

    public class Iterator: IteratorProtocol {
        let enumerator: NSEnumerator

        init(path: Path) {
            enumerator = FileManager().enumerator(at: path.url, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants], errorHandler: nil)!
        }

        public func next() -> Path? {
            guard let url = enumerator.nextObject() as? URL else {
                return nil
            }
            return try? Path(url)
        }
    }

    public func makeIterator() -> Iterator {
        return Iterator(path: self)
    }

}

// MARK: -

extension Path: ExpressibleByUnicodeScalarLiteral, ExpressibleByStringLiteral, ExpressibleByExtendedGraphemeClusterLiteral {

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }

}
