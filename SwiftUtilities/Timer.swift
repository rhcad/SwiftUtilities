//
//  main.swift
//  Time
//
//  Created by Jonathan Wight on 12/1/15.
//  Copyright © 2015 3dr.com. All rights reserved.
//

import Foundation

// MARK: -

public class Timer {

    public static let defaultQueue = dispatch_get_main_queue()

    public let source: dispatch_source_t
    public private (set) var eventHandler: (() -> Void)! {
        didSet {
            dispatch_source_set_event_handler(source, eventHandler)
        }
    }

    public init(source: dispatch_source_t) {
        self.source = source
    }

    public convenience init(queue: dispatch_queue_t, time: dispatch_time_t, strict: Bool = false, interval: UInt64 = 0, leeway: UInt64 = 0) {
        let source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, strict ? DISPATCH_TIMER_STRICT : 0, queue)
        dispatch_source_set_timer(source, time, interval, leeway)
        self.init(source: source)
    }

    public func resume() {
        dispatch_resume(source)
    }

    public func cancel() {
        if dispatch_source_testcancel(source) == 0 {
            dispatch_source_cancel(source)
        }
    }
}

// MARK: -

extension Timer {

    static func after(delay: NSTimeInterval, queue: dispatch_queue_t! = Timer.defaultQueue, handler: () -> Void) -> Timer {
        let time = dispatch_time(DISPATCH_TIME_NOW, delay.nanoseconds)
        let timer = Timer(queue: queue, time: time)
        timer.eventHandler = {
            timer.cancel()
            handler()
        }
        timer.resume()
        return timer
    }

    static func at(when: NSDate, queue: dispatch_queue_t! = Timer.defaultQueue, handler: () -> Void) -> Timer {
        let time = when.toDispatchWalltime()
        let timer = Timer(queue: queue, time: time)
        timer.eventHandler = {
            timer.cancel()
            handler()
        }
        timer.resume()
        return timer
    }

    static func every(interval: NSTimeInterval, queue: dispatch_queue_t! = Timer.defaultQueue, handler: () -> Void) -> Timer {
        let time = dispatch_time(DISPATCH_TIME_NOW, 0)
        let timer = Timer(queue: queue, time: time, interval: UInt64(interval.nanoseconds))
        timer.eventHandler = handler
        timer.resume()
        return timer
    }

}


private extension NSDate {

    func toTimespec() -> timespec {
        var ts = timespec()
        ts.tv_sec = Int(timeIntervalSince1970)
        ts.tv_nsec = Int((timeIntervalSince1970 - floor(timeIntervalSince1970)) * Double(NSEC_PER_SEC))
        return ts
    }

    func toDispatchWalltime() -> dispatch_time_t {
        var ts = toTimespec()
        return dispatch_walltime(&ts, 0)
    }

}

private extension NSTimeInterval {
    var nanoseconds: Int64 {
        return Int64(self * Double(NSEC_PER_SEC))
    }
}
