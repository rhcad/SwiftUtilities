//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities

var queue = PriorityQueue <String, Int> ()

queue.put("8", priority: 8)
queue.put("6", priority: 6)
queue.put("7", priority: 7)
queue.put("5", priority: 5)
queue.put("3", priority: 3)
queue.put("0", priority: 0)
queue.put("9", priority: 9)

print(queue.binaryHeap.array)
for F in queue {
    print(F)
}

//while queue.isEmpty == false {
//    print(queue.get())
//}
