//
//  AssociatedHelper.swift
//  Notifications
//
//  Created by Jonathan Wight on 2/12/16.
//
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

    public func getAssociatedValueForObject(_ object: AnyObject) -> T? {
        guard let associatedObject = objc_getAssociatedObject(object, key) else {
            return nil
        }
        if T.self == AnyObject.self {
            return associatedObject as? T
        }
        else if let box = associatedObject as? Box <T> {
            return box.value
        }
        else {
            fatalError("How did we get here?")
        }
    }

    public func setAssociatedValueForObject(_ object: AnyObject, value: T?) {
        let associatedObject: AnyObject?
        if let value = value {
            if T.self == AnyObject.self {
                associatedObject = value as AnyObject
            }
            else {
                associatedObject = Box(value)
            }
        }
        else {
            associatedObject = nil
        }
        objc_setAssociatedObject(object, key, associatedObject, policy)
    }

    public func deleteAssociatedValueForObject(_ object: AnyObject) {
        var key = self
        objc_setAssociatedObject(object, &key, nil, policy)
    }

    fileprivate var key: UnsafeRawPointer {
        return UnsafeRawPointer (Unmanaged.passUnretained(self).toOpaque())
    }

}
