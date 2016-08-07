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

    public init(_ url: NSURL) throws {
        guard let path = url.path else {
            throw Error.Generic("Not a file url")
        }
        self.path = path
    }

    public var url: NSURL {
        return NSURL(fileURLWithPath: path)
    }

    public var normalizedPath: String {
        return (path as NSString).stringByExpandingTildeInPath
    }
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
        return Path((path as NSString).stringByDeletingLastPathComponent)
    }

    var name: String {
        return (path as NSString).lastPathComponent
    }

    var pathExtension: String {
        return (path as NSString).pathExtension
    }

    var pathExtensions: [String] {
        return Array(name.componentsSeparatedByString(".").suffixFrom(1))
    }


    /// The "stem" of the path is the filename without path extensions
    var stem: String {
        return (( path as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
    }

    /// Replace the file name portion of a path with name
    func withName(name: String) -> Path {
        return parent! + name
    }

    /// Replace the path extension portion of a path. Note path extensions in iOS seem to refer just to last path extension e.g. "z" of "foo.x.y.z".
    func withPathExtension(pathExtension: String) -> Path {
        if pathExtension.isEmpty {
            return self
        }
        return withName(stem + "." + pathExtension)
    }

    func withPathExtensions(pathExtensions: [String]) -> Path {
        let pathExtension = pathExtensions.joinWithSeparator(".")
        return withPathExtension(pathExtension)
    }

    /// Replace the stem portion of a path: e.g. calling withStem("bar") on /tmp/foo.txt returns /tmp/bar.txt
    func withStem(stem: String) -> Path {
        return (parent! + stem).withPathExtension(pathExtension)
    }

    func pathByExpandingTilde() -> Path {
        return Path((path as NSString).stringByExpandingTildeInPath)
    }

    func pathByDeletingLastComponent() -> Path {
        return Path((path as NSString).stringByDeletingLastPathComponent)
    }

    var normalizedComponents: [String] {
        var components = self.components
        if components.last == "/" {
            components = Array(components[0..<components.count - 1])
        }
        return components
    }

    func hasPrefix(other: Path) -> Bool {
        let lhs = normalizedComponents
        let rhs = other.normalizedComponents

        if rhs.count > lhs.count {
            return false
        }
        return Array(lhs[0..<(rhs.count)]) == rhs
    }

    func hasSuffix(other: Path) -> Bool {
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
    let url = (lhs.path as NSString).stringByAppendingPathComponent(rhs.path)
    return Path(url)
}

public func / (lhs: Path, rhs: Path) -> Path {
    let url = (lhs.path as NSString).stringByAppendingPathComponent(rhs.path)
    return Path(url)
}

public func + (lhs: Path, rhs: String) -> Path {
    let url = (lhs.path as NSString).stringByAppendingPathComponent(rhs)
    return Path(url)
}

public func / (lhs: Path, rhs: String) -> Path {
    let url = (lhs.path as NSString).stringByAppendingPathComponent(rhs)
    return Path(url)
}

// MARK: Working Directory

public extension Path {

    static var currentDirectory: Path {
        get {
            return Path(NSFileManager().currentDirectoryPath)
        }
        set {
            NSFileManager().changeCurrentDirectoryPath(newValue.path)
        }
    }
}

// MARK: File Types

public enum FileType {
    case Regular
    case Directory
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
        return fileType == .Directory
    }

    func chmod(permissions: Int) throws {
        try NSFileManager().setAttributes([NSFilePosixPermissions: permissions], ofItemAtPath: path)
    }

}

public extension Path {
    var attributes: FileAttributes? {
        guard url.checkResourceIsReachableAndReturnError(nil) == true else {
            return nil
        }
        return try? FileAttributes(path)
    }
}

public struct FileAttributes {

    private let path: String

    private init(_ path: String) throws {
        self.path = path
    }

    private var url: NSURL {
        return NSURL(fileURLWithPath: path)
    }

    public func getAttributes() throws -> [String : AnyObject] {
        let attributes = try NSFileManager().attributesOfItemAtPath(path)
        return attributes
    }

    public func getAttribute <T> (name: String) throws -> T {
        let attributes = try getAttributes()
        guard let attribute = attributes[name] as? T else {
            throw Error.Generic("Could not convert value")
        }
        return attribute
    }

    public var fileType: FileType! {
        do {
            let type: String = try getAttribute(NSFileType)
            switch type {
                case NSFileTypeDirectory:
                    return .Directory
                case NSFileTypeRegular:
                    return .Regular
                default:
                    return nil
            }
        }
        catch {
            return nil
        }
    }

    public var isDirectory: Bool {
        return fileType == .Directory
    }

    public var length: Int {
        return tryElseFatalError() {
            return try getAttribute(NSFileSize)
        }
    }

    var permissions: Int {
        return tryElseFatalError() {
            return try getAttribute(NSFilePosixPermissions)
        }
    }

}

// Iterating directories

public extension Path {

    var children: [Path] {
        return Array(self)
    }

    func walk(closure: (Path) -> Void) throws {
        guard let enumerator = NSFileManager().enumeratorAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions(), errorHandler: nil) else {
            throw Error.Generic("Could not create enumerator")
        }

        for url in enumerator {
            guard let url = url as? NSURL else {
                throw Error.Generic("HMM")
            }
            let path = try Path(url)
            closure(path)
        }
    }


}

// MARK: Creating, moving, removing etc.

public extension Path {

    func createDirectory(withIntermediateDirectories withIntermediateDirectories: Bool = false, attributes: [String: AnyObject]? = nil) throws {
        try NSFileManager().createDirectoryAtPath(path, withIntermediateDirectories: withIntermediateDirectories, attributes: attributes)
    }

    func move(destination: Path) throws {
        try NSFileManager().moveItemAtURL(url, toURL: destination.url)
    }

    func remove() throws {
        try NSFileManager().removeItemAtPath(path)
    }
}


// MARK: Glob

public extension Path {

    func glob() throws -> [Path] {
        let error = {
            (path: UnsafePointer<Int8>, errno: Int32) -> Int32 in
            return 0
        }
        var globStorage = glob_t()
        let result = glob_b(path, 0, error, &globStorage)
        guard result == 0 else {
            throw (Errno(rawValue: result) ?? Error.Unknown)
        }
        let paths = (0..<globStorage.gl_pathc).map() {
            (index) -> Path in
            let pathPtr = globStorage.gl_pathv[index]
            guard let pathString = String(CString: pathPtr, encoding: NSUTF8StringEncoding) else {
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
    func rotate(limit limit: Int? = nil) throws {
        guard exists else {
            return
        }
        guard let parent = parent else {
            throw Error.Generic("No parent")
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

    static func makeTemporaryDirectory(temporaryDirectory: Path? = nil) throws -> Path {

        let temporaryDirectory = (temporaryDirectory ?? self.temporaryDirectory)
        if temporaryDirectory.exists == false {
            try temporaryDirectory.createDirectory(withIntermediateDirectories: true)
        }

        let templateDirectory = temporaryDirectory + "XXXXXXXX"
        var template = templateDirectory.path.cStringUsingEncoding(NSUTF8StringEncoding)!
        return template.withUnsafeMutableBufferPointer() {
            (inout buffer: UnsafeMutableBufferPointer <Int8>) -> Path in
            let pointer = mkdtemp(buffer.baseAddress)
            let pathString = String(CString: pointer, encoding: NSUTF8StringEncoding)!
            let path = Path(pathString)
            return path
        }
    }

    static func withTemporaryDirectory <R> (temporaryDirectory: Path? = nil, @noescape closure: Path throws -> R) throws -> R {

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
        let bundle = NSBundle.mainBundle()
        let bundleIdentifier = bundle.bundleIdentifier!
        let path = applicationSupportDirectory! + bundleIdentifier
        if path.exists == false {
            tryElseFatalError() {
                try path.createDirectory(withIntermediateDirectories: true)
            }
        }
        return path
    }

    static func specialDirectory(directory: NSSearchPathDirectory, inDomain domain: NSSearchPathDomainMask = .UserDomainMask, appropriateForURL url: NSURL? = nil, create shouldCreate: Bool = true) throws -> Path {

        let url = tryElseFatalError() {
            return try NSFileManager().URLForDirectory(directory, inDomain: domain, appropriateForURL: url, create: shouldCreate)
        }

        return try Path(url)
    }
    
    static var libraryDirectory: Path? {
        return try? Path.specialDirectory(.LibraryDirectory)
    }

    static var applicationSupportDirectory: Path? {
        return try? Path.specialDirectory(.ApplicationSupportDirectory)
    }

    static var documentDirectory: Path? {
        return try? Path.specialDirectory(.DocumentDirectory)
    }
}


public extension Path {

    func createFile() throws {
        if NSFileManager.defaultManager().createFileAtPath(path, contents: nil, attributes: nil) == false {
            throw Error.Generic("Could not create file")
        }
    }

    func read() throws -> String {
        let data = try NSData(contentsOfURL: url, options: NSDataReadingOptions())
        var string: NSString?
        var usedLossyConversion = ObjCBool(false)
        let encodingOptions = [
            NSStringEncodingDetectionSuggestedEncodingsKey: [NSUTF8StringEncoding],
            NSStringEncodingDetectionUseOnlySuggestedEncodingsKey: false,
            NSStringEncodingDetectionAllowLossyKey: true,
        ]
        let encoding = NSString.stringEncodingForData(data, encodingOptions: encodingOptions, convertedString: &string, usedLossyConversion: &usedLossyConversion)
        if let string = string as? String where encoding != 0 {
            return string
        }
        throw Error.Generic("Could not decode data.")
    }

    func write(string: String, encoding: UInt = NSUTF8StringEncoding) throws {
        try string.writeToFile(String(self), atomically: true, encoding: encoding)
    }

}

// MARK: -

extension Path: SequenceType {

    public class Generator: GeneratorType {
        let enumerator: NSEnumerator

        init(path: Path) {
            enumerator = NSFileManager().enumeratorAtURL(path.url, includingPropertiesForKeys: nil, options: [.SkipsSubdirectoryDescendants, .SkipsPackageDescendants], errorHandler: nil)!
        }

        public func next() -> Path? {
            guard let url = enumerator.nextObject() as? NSURL else {
                return nil
            }
            return try? Path(url)
        }
    }

    public func generate() -> Generator {
        return Generator(path: self)
    }

}

// MARK: -

extension Path: StringLiteralConvertible {

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
