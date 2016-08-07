//
//  ViewController.swift
//  Testing
//
//  Created by Jonathan Wight on 8/6/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Cocoa

import SwiftUtilities

class ViewController: NSViewController {

    @IBAction func test(sender: AnyObject) {
        super.viewDidLoad()

        let parent = Path("/tmp/testing")


        let path = parent / "test.txt"
        print(path)
        try! path.rotate(limit: 5)
        try! path.write("Hello world")
    }

}

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
