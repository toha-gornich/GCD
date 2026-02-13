# iOS Concurrency Examples

A comprehensive collection of concurrency patterns in iOS, covering both legacy GCD (Grand Central Dispatch) and modern async/await approaches.

## Table of Contents
- [Overview](#overview)
- [GCD Basics](#gcd-basics)
- [Serial vs Concurrent Queues](#serial-vs-concurrent-queues)
- [Common Pitfalls](#common-pitfalls)
- [Synchronization Patterns](#synchronization-patterns)
- [Modern Concurrency](#modern-concurrency)
- [Best Practices](#best-practices)

## Overview

This repository contains practical examples demonstrating various concurrency patterns in iOS development. Each example includes detailed comments and expected output to help you understand threading behavior.

## GCD Basics

### Concurrent Queue with async/sync
```swift
let concurrent = DispatchQueue.global(qos: .utility)

print(1, Thread.current)

concurrent.async {
    Thread.sleep(forTimeInterval: 2)
    print(2, Thread.current)
}

concurrent.sync {
    print(3, Thread.current)
}
```

**Output:**
```
1 <_NSMainThread>
3 <_NSMainThread>
2 <NSThread: number = 7>
```

**Key takeaway:** `sync` blocks the current thread, `async` doesn't.

## Serial vs Concurrent Queues

### Serial Queue
```swift
let serial = DispatchQueue(label: "serial", qos: .userInteractive)

print(1)
serial.async {
    Thread.sleep(forTimeInterval: 2)
    print(2)
}
serial.async {
    print(3)
}
```

**Output:** `1, 2, 3`

### Concurrent Queue
```swift
let concurrent = DispatchQueue(label: "concurrent", attributes: .concurrent)

concurrent.async { print("Task 1") }
concurrent.async { print("Task 2") }
```

## Common Pitfalls

### Deadlock
```swift
let main = DispatchQueue.main

print(1)
main.sync {
    print(2)  // DEADLOCK
}
print(3)
```

**Why:** Main thread waits for itself.

## Synchronization Patterns

### Dispatch Barrier
```swift
let concurrent = DispatchQueue(label: "concurrent", attributes: .concurrent)

concurrent.async { print("Read 1") }
concurrent.async { print("Read 2") }

concurrent.async(flags: .barrier) {
    print("WRITE")
}

concurrent.async { print("Read 3") }
```

### DispatchGroup
```swift
let group = DispatchGroup()
let queue = DispatchQueue(label: "queue")

queue.async(group: group) {
    print("Task 1")
}

group.notify(queue: .main) {
    print("All done")
}
```

### DispatchSemaphore
```swift
let semaphore = DispatchSemaphore(value: 5)

for number in 1...10 {
    semaphore.wait()
    queue.async {
        uploadNumber(number)
        semaphore.signal()
    }
}
```

## Modern Concurrency

### async/await
```swift
func myMethod() async {
    print(1)
    
    do {
        async let task1: () = someAsyncMethod()
        async let task2: () = someAsyncMethod2()
        
        try await task1
        await task2
        
        print(4)
    } catch {
        print("Error:", error)
    }
}
```

## Best Practices

1. Use async/await for new code
2. Avoid `main.sync` - causes deadlocks
3. Use barriers for thread-safe read/write
4. Limit concurrent tasks with semaphores
5. Always dispatch UI updates to main thread

## Requirements

- iOS 13.0+
- Swift 5.5+
- Xcode 13.0+

## Resources

- [Apple's Concurrency Documentation](https://developer.apple.com/documentation/swift/concurrency)
- [WWDC 2021: Meet async/await](https://developer.apple.com/videos/play/wwdc2021/10132/)

## License

MIT License
