//: Playground - noun: a place where people can play

import Cocoa

import SwiftUtilities

var queue = PriorityQueue <String, Int> ()

for N in random.shuffled(Array(0..<20)) {
    queue.put("\(N)", priority: N)
}


print(queue.binaryHeap.array)
for F in queue {
    print(F)
}

//while queue.isEmpty == false {
//    print(queue.get())
//}
