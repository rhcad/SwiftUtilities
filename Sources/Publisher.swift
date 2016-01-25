//
//  Publisher.swift
//  SwiftIO
//
//  Created by Jonathan Wight on 1/12/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

/**
Implementation of the Publish-Subscribe pattern for  https://en.wikipedia.org/wiki/Publish–subscribe_pattern
 - parameter MessageKey: A hashable type for messages. This is used as a unique key for each message. Ints or Hashable enums would make suitable MessageKeys.
 - parameter type:       The message type. `MessageKey` must conform to the `Hashable` protocol.
*/
public class Publisher <MessageKey: Hashable, Message> {
    public typealias Handler = Message -> Void

    public init() {
    }

    /**
    Register a Subscriber with the Publisher to receive messages of a specific type.

     - parameter subscriber:  The subscriber. Can be any type of object. The subscriber is weakly retained by the publisher.
     - parameter messageKey:  The message type. `MessageKey` must conform to the `Hashable` protocol.
     - parameter handler:     Closure to be called when a Message is published. Be careful about not capturing the subscriber object in this closure.
     */
    public func subscribe(subscriber: AnyObject, messageKey: MessageKey, handler: Handler) {
        subscribe(subscriber, messageKeys: [messageKey], handler: handler)
    }

    /**
     Registers a subscriber for multiple message types.
     */
    public func subscribe(subscriber: AnyObject, messageKeys: [MessageKey], handler: Handler) {
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
    public func unsubscribe(subscriber: AnyObject) {
        rewrite() {
            (entry) in
            return entry.subscriber != nil && entry.subscriber !== subscriber
        }
    }

    /**
     Unsubscribe a subscribe for some message types.
     */
    public func unsubscribe(subscriber: AnyObject, messageKey: MessageKey) {
        unsubscribe(subscriber, messageKeys: [messageKey])
    }

    /**
     Unsubscribe a subscribe for a single message type.
     */
    public func unsubscribe(subscriber: AnyObject, messageKeys: [MessageKey]) {
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
    public func publish(messageKey: MessageKey, message: Message) {
        let needsPurging: Bool = lock.with() {
            guard let entries = entriesForType[messageKey] else {
                return false
            }
            var needsPurging = false
            for entry in entries {
                if entry.subscriber == nil {
                    needsPurging = true
                    continue
                }
                entry.handler(message)
            }
            return needsPurging
        }

        if needsPurging == true {
            purge()
        }

    }

    private typealias Entries = [Entry <Message>]
    private var entriesForType: [MessageKey: Entries] = [:]

    /// This is a recursive lock because it is expected that observers _could_ remove themselves while handling messages.
    private var lock = NSRecursiveLock()

    private var queue = dispatch_queue_create("io.schwa.SwiftIO.Publisher", DISPATCH_QUEUE_SERIAL)
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
    func rewrite(test: Entry<Message> -> Bool) {
        lock.with() {
            func filteredEntries(entries: [Entry<Message>]) -> [Entry<Message>] {
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
    typealias Handler = Message -> Void
    weak var subscriber: AnyObject?
    let handler: Handler
}
