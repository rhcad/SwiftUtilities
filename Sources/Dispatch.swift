//
//  Utilities.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 1/23/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import Foundation

public class DispatchQueue {

    public let queue: dispatch_queue_t

    public init(queue: dispatch_queue_t) {
        self.queue = queue
    }

    public static let main: DispatchQueue = DispatchQueue(queue: dispatch_get_main_queue())

    public static func serial(label: String, qos: qos_class_t = QOS_CLASS_DEFAULT, relativePriority: Int32 = 0) -> DispatchQueue {
        let attribute = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qos, relativePriority)
        return DispatchQueue(queue: dispatch_queue_create(label, attribute))
    }

    public static func concurrent(label: String, qos: qos_class_t = QOS_CLASS_DEFAULT, relativePriority: Int32 = 0) -> DispatchQueue {
        let attribute = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, qos, relativePriority)
        return DispatchQueue(queue: dispatch_queue_create(label, attribute))
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

    public func timer(start start: NSTimeInterval, handler: Void -> Void) -> DispatchSource {
        let source = DispatchSource(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)

        let startTime = dispatch_time(DISPATCH_TIME_NOW, timeIntervalToNSEC(start))
        dispatch_source_set_timer(source.source, startTime, 0, 0)
        source.eventHandler = handler
        source.cancelHandler = {
            [weak source] in
            if let source = source {
                DispatchQueue.timers.value.remove(source)
            }
        }
        DispatchQueue.timers.value.insert(source)
        source.resume()
        return source
    }

    public func timer(interval interval: NSTimeInterval, handler: Void -> Void) -> DispatchSource {
        let source = DispatchSource(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(source.source, DISPATCH_TIME_NOW, timeIntervalToNSEC(interval), 0)
        source.eventHandler = handler
        source.cancelHandler = {
            [weak source] in
            if let source = source {
                DispatchQueue.timers.value.remove(source)
            }
        }
        DispatchQueue.timers.value.insert(source)
        source.resume()
        return source
    }

    private static var timers = Atomic(Set <DispatchSource> ())

}

// MARK: -

public class DispatchSource {
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

extension DispatchSource: Equatable {
}

public func == (lhs: DispatchSource, rhs: DispatchSource) -> Bool {
    return lhs.source === rhs.source
}

extension DispatchSource: Hashable {
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
