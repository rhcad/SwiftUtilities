//
//  PathTests.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 1/24/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import XCTest

import SwiftUtilities

class PathTests: XCTestCase {

    func testInit() {
        do {
            let path = Path("/tmp")
            XCTAssertEqual(path.path, "/tmp")
        }
        do {
            let path = try! Path(URL(fileURLWithPath: "/tmp"))
            XCTAssertEqual(path.path, "/tmp")
        }
        do {
            let path = try? Path(URL(string: "http://google.com")!)
            XCTAssertNil(path)
        }
        do {
            let path = try! Path(URL(fileURLWithPath: "/tmp"))
            XCTAssertEqual(path.path, "/tmp")
        }
        do {
            let path = Path("~")
            XCTAssertEqual(path.normalized.path, ("~" as NSString).expandingTildeInPath)
        }
        do {
            let path = Path("/tmp")
            XCTAssertEqual(path.components.count, 2)
            XCTAssertEqual(path.components[0], "/")
            XCTAssertEqual(path.components[1], "tmp")
            XCTAssertEqual(path.parent!, Path("/"))
        }
        do {
            XCTAssertTrue(Path("/") < Path("/tmp"))
        }
        do {
            let path = Path("foo.bar.zip")
            XCTAssertEqual(path.pathExtensions.count, 2)
            XCTAssertEqual(path.pathExtensions[0], "bar")
            XCTAssertEqual(path.pathExtensions[1], "zip")
        }
//        do {
//            let path = Path("/tmp/foo.bar.zip")
//            XCTAssertEqual(path.stem, "foo")
//        }
        do {
            let path = Path("/tmp/foo.bar.zip").withName("xyzzy")
            XCTAssertEqual(path.path, "/tmp/xyzzy")
        }
//        do {
//            let path = Path("/tmp/foo.bar.zip").withPathExtension(".bz2")
//            XCTAssertEqual(String(path), "/tmp/foo.bar.bz2")
//        }
        do {
            let path = Path("/tmp/foo.bar.zip").withStem("xyzzy")
            XCTAssertEqual(path.path, "/tmp/xyzzy.zip")
        }

    }

    func test1() {
        try! Path.withTemporaryDirectory() {
            directory in

            let file = directory + "test.txt"
            XCTAssertFalse(file.exists)

            XCTAssertEqual(file.name, "test.txt")
            XCTAssertEqual(file.pathExtension, "txt")

            try file.createFile()
            XCTAssertTrue(file.exists)
        }
    }

}


