//
//  Publisher.swift
//  SwiftIO
//
//  Created by Jonathan Wight on 1/12/16.
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

public class TestingPublisher <MessageType> {

    public typealias Test = MessageType -> Bool
    public typealias Handler = MessageType -> Void

    public init() {
    }

    public func subscribe(subscriber: AnyObject, test: Test, handler: Handler) {
        lock.with() {
            let newEntry = Entry(subscriber: subscriber, test: test, handler: handler)
            entries.append(newEntry)
        }
    }

    public func unsubscribe(subscriber: AnyObject) {
        rewrite() {
            entry in
            return entry.subscriber != nil && entry.subscriber !== subscriber
        }
    }

    public func publish(message: MessageType) -> Bool {
        let (needsPurging, handled): (Bool, Bool) = lock.with() {
            var needsPurging = false
            var handled = false
            for entry in entries {
                if entry.subscriber == nil {
                    needsPurging = true
                    continue
                }
                if entry.test(message) == true {
                    entry.handler(message)
                    handled = true
                }
            }
            return (needsPurging, handled)
        }

        if needsPurging == true {
            purge()
        }

        return handled
    }

    /// This is a recursive lock because it is expected that observers _could_ remove themselves while handling messages.
    private var lock = NSRecursiveLock()

    private var entries: [Entry <MessageType>] = []

    private var queue = dispatch_queue_create("io.schwa.SwiftIO.TestingPublisher", DISPATCH_QUEUE_SERIAL)
}

// MARK: -

private extension TestingPublisher {

    func purge() {
        rewrite() {
            (entry) in
            entry.subscriber != nil
        }
    }

    func rewrite(test: Entry<MessageType> -> Bool) {
        lock.with() {
            entries = entries.filter() {
                (entry) in
                return test(entry)
            }
        }
    }
}

// MARK: -

private struct Entry <Message> {
    typealias Test = Message -> Bool
    typealias Handler = Message -> Void
    weak var subscriber: AnyObject?
    let test: Test
    let handler: Handler
}
