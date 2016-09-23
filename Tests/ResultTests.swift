//
//  ResultTests.swift
//  SwiftUtilities
//
//  Created by Jonathan Wight on 3/1/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import XCTest

import SwiftUtilities

class ResultTests: XCTestCase {

    func testExample() {

        let success = Result <Int>.success(100)
        let failure = Result <Int>.failure(Error.unknown)

        //

        if case .success(let value) = success {
            XCTAssertEqual(value, 100)
        }
        else {
            // Nothing to do here
        }

        if case .failure = success {
            XCTFail()
        }
        else {
            // Nothing to do here
        }

        //

        if case .success = failure {
            XCTFail()
        }
        else {
            // Nothing to do here
        }

        //

        XCTAssertEqual(success ?? 200, 100)
        XCTAssertEqual(failure ?? 200, 200)

        XCTAssertEqual(success.flatMap({ return $0 * 2 }), 200)
        XCTAssertNil(failure.flatMap({ return $0 * 2 }))

        if case .success(let value) = success.map({ return $0 * 2 }) {
            XCTAssertEqual(value, 200)
        }
        else {
            XCTFail()
        }

        if case .success(let value) = failure.map({ return $0 * 2 }) {
            XCTAssertEqual(value, 100)
        }
        else {
            // Nothing to do here
        }

        if case .failure = failure.map({ return $0 * 2 }) {
            // Nothing to do here
        } else {
            XCTFail()
        }
    }

}
