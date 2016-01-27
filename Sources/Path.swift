//
//  Path.swift
//  Dterm 2
//
//  Created by Jonathan Wight on 8/6/15.
//  Copyright © 2015 schwa.io. All rights reserved.
//

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

    var stem: String {
        return ((path as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
    }

    func withName(name: String) -> Path {
        return parent! + name
    }

    func withPathExtension(pathExtension: String) -> Path {
        if pathExtension.isEmpty {
            return self
        }
        return withName(stem + "." + pathExtension)
    }

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

public func + (lhs: Path, rhs: String) -> Path {
    let URL = (lhs.path as NSString).stringByAppendingPathComponent(rhs)
    return Path(URL)
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

    func iter(@noescape closure: Path -> Void) {
        let enumerator = NSFileManager().enumeratorAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, errorHandler: nil)
        for url in enumerator! {
            guard let url = url as? NSURL else {
                fatalError()
            }
            tryElseFatalError() {
                let path = try Path(url)
                closure(path)
            }
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
    func rotate() throws {
        if exists == false {
            return
        }
        var index = 1
        var newPath = self
        while true {
            if newPath.exists == false {
                try move(newPath)
                return
            }
            newPath = withStem(stem + " \(index)")
            index += 1
        }
    }
}

// MARK: Temporary Directories

public extension Path {
    static var temporaryDirectory: Path {
        return Path(NSTemporaryDirectory())
    }

    static func withTemporaryDirectory <R> (@noescape closure: Path throws -> R) throws -> R {

        var template = String(temporaryDirectory + "XXXXXXXX").cStringUsingEncoding(NSUTF8StringEncoding)!

        let foo = template.withUnsafeMutableBufferPointer() {
            (inout buffer: UnsafeMutableBufferPointer <Int8>) -> UnsafeMutablePointer <Int8> in
            return mkdtemp(buffer.baseAddress)
        }
        let path = Path(String(CString: foo, encoding: NSUTF8StringEncoding)!)
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
    static var applicationSupportDirectory: Path {
        return tryElseFatalError() {
            let url = try NSFileManager().URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            return try Path(url)
        }
    }

    static var applicationSpecificSupportDirectory: Path {
        let bundle = NSBundle.mainBundle()
        let bundleIdentifier = bundle.bundleIdentifier!
        let path = applicationSupportDirectory + bundleIdentifier
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
}
