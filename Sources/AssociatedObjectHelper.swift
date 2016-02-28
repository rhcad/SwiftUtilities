//
//  AssociatedHelper.swift
//  Notifications
//
//  Created by Jonathan Wight on 2/12/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Foundation

import SwiftUtilities

/**
    Type-safe helper for objc Associated Objects
    ```
    // Create a _global_ helper instance. Of the type you want to store in your objact
    private let helper = AssociatedObjectHelper <Float> ()

    // Create your object.
    let object = NSObject()

    // Use the associated helper to set and get values on your objects
    helper.setAssociatedValueForObject(object, 3.14)
    helper.getAssociatedValueForObject(object) // 3.14


    let object2 = NSObject()
    helper.getAssociatedValueForObject(object) // nil
    ```

*/
public class AssociatedObjectHelper <T> {

    public let policy: objc_AssociationPolicy

    public init(atomic: Bool = true) {
        policy = atomic ? .OBJC_ASSOCIATION_RETAIN : .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    }

    deinit {
        fatalError("Associated Helpers should not deinit")
    }

    public func getAssociatedValueForObject(object: AnyObject) -> T? {
        var key = self
        guard let associatedObject = objc_getAssociatedObject(object, &key) else {
            return nil
        }
        if let associatedObject = associatedObject as? T where T.self is AnyObject {
            return associatedObject
        }
        else {
            return (associatedObject as! Box <T>).value
        }
    }

    public func setAssociatedValueForObject(object: AnyObject, value: T) {
        var key = self
        let associatedObject: AnyObject
        if T.self is AnyObject {
            associatedObject = value as! AnyObject
        }
        else {
            associatedObject = Box(value)
        }
        objc_setAssociatedObject(object, &key, associatedObject, policy)
    }

    public func deleteAssociatedValueForObject(object: AnyObject) {
        var key = self
        objc_setAssociatedObject(object, &key, nil, policy)
    }

}




