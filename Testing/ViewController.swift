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

        for f in parent {
            print(f)
        }

    }

}

