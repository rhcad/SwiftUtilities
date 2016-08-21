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

/**
Implementation of the Publish-Subscribe pattern for  https://en.wikipedia.org/wiki/Publish–subscribe_pattern
 - parameter MessageKey: A hashable type for messages. This is used as a unique key for each message. Ints or Hashable enums would make suitable MessageKeys.
 - parameter type:       The message type. `MessageKey` must conform to the `Hashable` protocol.
*/
open class Publisher <MessageKey: Hashable, Message> {
    public typealias Handler = (Message) -> Void

    public init() {
    }

    /**
    Register a Subscriber with the Publisher to receive messages of a specific type.

     - parameter subscriber:  The subscriber. Can be any type of object. The subscriber is weakly retained by the publisher.
     - parameter messageKey:  The message type. `MessageKey` must conform to the `Hashable` protocol.
     - parameter handler:     Closure to be called when a Message is published. Be careful about not capturing the subscriber object in this closure.
     */
    open func subscribe(_ subscriber: AnyObject, messageKey: MessageKey, handler: Handler) {
        subscribe(subscriber, messageKeys: [messageKey], handler: handler)
    }

    /**
     Registers a subscriber for multiple message types.
     */
    open func subscribe(_ subscriber: AnyObject, messageKeys: [MessageKey], handler: Handler) {
        lock.with() {
            let newEntry = Entry(subscriber: subscriber, handler: handler)
            for messageKey in messageKeys {
                var entries = entriesForType.get(messageKey, defaultValue: Entries())
                entries.append(newEntry)
                entriesForType[messageKey] = entries
            }
        }
    }

    /**
     Unregister a subscriber for all messages types.

     Note this is optional - a subscriber is automatically unregistered after it is deallocated.
     */
    open func unsubscribe(_ subscriber: AnyObject) {
        rewrite() {
            (entry) in
            return entry.subscriber != nil && entry.subscriber !== subscriber
        }
    }

    /**
     Unsubscribe a subscribe for some message types.
     */
    open func unsubscribe(_ subscriber: AnyObject, messageKey: MessageKey) {
        unsubscribe(subscriber, messageKeys: [messageKey])
    }

    /**
     Unsubscribe a subscribe for a single message type.
     */
    open func unsubscribe(_ subscriber: AnyObject, messageKeys: [MessageKey]) {
        lock.with() {
            for messageKey in messageKeys {
                guard let entries = entriesForType[messageKey] else {
                    continue
                }
                entriesForType[messageKey] = entries.filter() {
                    (entry) in
                    return entry.subscriber != nil && entry.subscriber !== subscriber
                }
            }
        }
    }

    /**
     Publish a message to all subscribers registerd a handler for `messageKey`
     */
    open func publish(_ messageKey: MessageKey, message: Message) -> Bool {

        let (needsPurging, handled): (Bool, Bool) = lock.with() {
            guard let entries = entriesForType[messageKey] else {
                return (false, false)
            }
            var needsPurging = false
            var handled = false
            for entry in entries {
                if entry.subscriber == nil {
                    needsPurging = true
                    continue
                }
                entry.handler(message)
                handled = true
            }
            return (needsPurging, handled)
        }

        if needsPurging == true {
            purge()
        }

        return handled
    }

    fileprivate typealias Entries = [Entry <Message>]
    fileprivate var entriesForType: [MessageKey: Entries] = [:]

    /// This is a recursive lock because it is expected that observers _could_ remove themselves while handling messages.
    fileprivate var lock = NSRecursiveLock()

    fileprivate var queue = DispatchQueue(label: "io.schwa.SwiftIO.Publisher", attributes: [])
}

extension Publisher: CustomDebugStringConvertible {
    // Quick and crude debugDescription
    public var debugDescription: String {
        return lock.with() {
            var s = ""
            for (key, value) in entriesForType {
                s += "\(key): \(value)\n"
            }
            return s
        }
    }
}

// MARK: -

private extension Publisher {

    /**
     Enumerate through all entries for all types and remove entries for Observers that have been deallocated.
     */
    func purge() {
        rewrite() {
            (entry) in
            entry.subscriber != nil
        }
    }

    /**
     Enumerate through all entries for all types and remove entries that pass `test`.
     */
    func rewrite(_ test: @escaping (Entry<Message>) -> Bool) {
        lock.with() {
            func filteredEntries(_ entries: [Entry<Message>]) -> [Entry<Message>] {
                return entries.filter() {
                    (entry) in
                    return test(entry)
                }
            }
            let items = entriesForType.map() {
                (messageKey, entries) in
                return (messageKey, filteredEntries(entries))
            }
            entriesForType = Dictionary(items: items)
        }
    }
}

// MARK: -

private struct Entry <Message> {
    typealias Handler = (Message) -> Void
    weak var subscriber: AnyObject?
    let handler: Handler
}
