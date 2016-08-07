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

        let path = Path("/tmp/test.txt")
        try! path.rotate()
        try! path.write("Hello world")
    }

}


extension Path {
    func write(string: String, encoding: UInt = NSUTF8StringEncoding) throws {
        try string.writeToFile(String(self), atomically: true, encoding: encoding)
    }
}
