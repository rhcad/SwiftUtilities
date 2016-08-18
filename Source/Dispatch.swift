//
//  Utilities.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 1/23/16.
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

public class MyDispatchQueue {

    public let queue: dispatch_queue_t

    public init(queue: dispatch_queue_t) {
        self.queue = queue
    }

    public static let main: MyDispatchQueue = MyDispatchQueue(queue: dispatch_get_main_queue())

    public static func serial(label: String, qos: qos_class_t = QOS_CLASS_DEFAULT, relativePriority: Int32 = 0) -> MyDispatchQueue {
        let attribute = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qos, relativePriority)
        return MyDispatchQueue(queue: dispatch_queue_create(label, attribute))
    }

    public static func concurrent(label: String, qos: qos_class_t = QOS_CLASS_DEFAULT, relativePriority: Int32 = 0) -> MyDispatchQueue {
        let attribute = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, qos, relativePriority)
        return MyDispatchQueue(queue: dispatch_queue_create(label, attribute))
    }

    public func sync(block: () -> Void) {
        dispatch_sync(queue, block)
    }

    public func sync <R> (block: () throws -> R) throws -> R {
        var result: R?
        var outError: ErrorType?

        dispatch_sync(queue) {
            do {
                result = try block()
            }
            catch let error {
                outError = error
            }
        }
        if let outError = outError {
            throw outError
        }
        return result!
    }

    public func async(block: dispatch_block_t) {
        dispatch_async(queue, block)
    }

    public func timer(start start: NSTimeInterval, handler: Void -> Void) -> MyDispatchSource {
        let source = MyDispatchSource(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)

        let startTime = dispatch_time(DISPATCH_TIME_NOW, timeIntervalToNSEC(start))
        dispatch_source_set_timer(source.source, startTime, 0, 0)
        source.eventHandler = handler
        source.cancelHandler = {
            [weak source] in
            if let source = source {
                MyDispatchQueue.timers.value.remove(source)
            }
        }
        MyDispatchQueue.timers.value.insert(source)
        source.resume()
        return source
    }

    public func timer(interval interval: NSTimeInterval, handler: Void -> Void) -> MyDispatchSource {
        let source = MyDispatchSource(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(source.source, DISPATCH_TIME_NOW, timeIntervalToNSEC(interval), 0)
        source.eventHandler = handler
        source.cancelHandler = {
            [weak source] in
            if let source = source {
                MyDispatchQueue.timers.value.remove(source)
            }
        }
        MyDispatchQueue.timers.value.insert(source)
        source.resume()
        return source
    }

    private static var timers = Atomic(Set <MyDispatchSource> ())

}

// MARK: -

public class MyDispatchSource {
    public let source: dispatch_source_t

    public init(source: dispatch_source_t) {
        self.source = source
    }

    public convenience init(_ type: dispatch_source_type_t, _ handle: UInt, _ mask: UInt, _ queue: dispatch_queue_t) {
        let source = dispatch_source_create(type, handle, mask, queue)
        self.init(source: source)
    }

    public var eventHandler: (Void -> Void)? {
        didSet {
            dispatch_source_set_event_handler(source, eventHandler)
        }
    }

    public var cancelHandler: (Void -> Void)? {
        didSet {
            dispatch_source_set_cancel_handler(source, cancelHandler)
        }
    }

    public func resume() {
        dispatch_resume(source)
    }

    public func cancel() {
        dispatch_source_cancel(source)
    }

}

// MARK: -

extension MyDispatchSource: Equatable {
}

public func == (lhs: MyDispatchSource, rhs: MyDispatchSource) -> Bool {
    return lhs.source === rhs.source
}

extension MyDispatchSource: Hashable {
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

// MARK: -

public func timeIntervalToNSEC(interval: NSTimeInterval) -> Int64 {
    return Int64(interval * NSTimeInterval(NSEC_PER_SEC))
}

public func timeIntervalToNSEC(interval: NSTimeInterval) -> UInt64 {
    return UInt64(interval * NSTimeInterval(NSEC_PER_SEC))
}
