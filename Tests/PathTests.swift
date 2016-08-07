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

//    override func setUp() {
//        super.setUp()
//    }

//    override func tearDown() {
//        super.tearDown()
//    }

    func testExample() {


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


