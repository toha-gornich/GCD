iOS Concurrency Examples
A comprehensive collection of concurrency patterns in iOS, covering both legacy GCD (Grand Central Dispatch) and modern async/await approaches.
📋 Table of Contents

Overview
GCD Basics
Serial vs Concurrent Queues
Common Pitfalls
Synchronization Patterns
Modern Concurrency
Best Practices

🎯 Overview
This repository contains practical examples demonstrating various concurrency patterns in iOS development. Each example includes detailed comments and expected output to help you understand threading behavior.
🚀 GCD Basics
Concurrent Queue with async/sync
Demonstrates the difference between synchronous and asynchronous execution:
swiftlet concurrent = DispatchQueue.global(qos: .utility)

print(1, Thread.current)  // Main thread

concurrent.async {
    Thread.sleep(forTimeInterval: 2)
    print(2, Thread.current)  // Background thread
}

concurrent.sync {
    print(3, Thread.current)  // Main thread (blocks until completion)
}
```

**Output:**
```
1 <_NSMainThread>
3 <_NSMainThread>
2 <NSThread: number = 7>

💡 Key takeaway: sync blocks the current thread, async doesn't.

🔄 Serial vs Concurrent Queues
Serial Queue
Executes tasks one at a time in FIFO order:
swiftlet serial = DispatchQueue(label: "serial", qos: .userInteractive)

print(1)
serial.async {
    Thread.sleep(forTimeInterval: 2)
    print(2)
}
serial.async {
    print(3)  // Waits for previous task
}
Output: 1, 2, 3
Concurrent Queue
Allows parallel execution of tasks:
swiftlet concurrent = DispatchQueue(label: "concurrent", attributes: .concurrent)

concurrent.async { print("Task 1") }
concurrent.async { print("Task 2") }  // Can run simultaneously

📊 Key difference: Serial executes one task at a time, concurrent allows parallel execution.

⚠️ Common Pitfalls
Deadlock Example
swiftlet main = DispatchQueue.main

print(1)
main.sync {
    print(2)  // ❌ DEADLOCK - main waits for itself
}
print(3)  // Never executes
Why it happens: Main thread tries to synchronously execute on itself = infinite wait.
Thread Reuse in Serial Queue
swiftlet serial = DispatchQueue(label: "serial")

serial.async { print(1, Thread.current) }  // Thread A
serial.async { print(2, Thread.current) }  // Same Thread A

DispatchQueue.global().async {
    serial.sync { print(3, Thread.current) }  // Different thread
}
🔐 Synchronization Patterns
Dispatch Barrier
Thread-safe read/write operations:
swiftlet concurrent = DispatchQueue(label: "concurrent", attributes: .concurrent)

concurrent.async { print("Read 1") }
concurrent.async { print("Read 2") }

concurrent.async(flags: .barrier) {
    print("WRITE")  // Exclusive access
}

concurrent.async { print("Read 3") }
Use case: Reads can happen concurrently, writes get exclusive access.
DispatchGroup
Coordinate multiple async tasks:
swiftlet group = DispatchGroup()
let queue = DispatchQueue(label: "queue")

queue.async(group: group) {
    print("Task 1")
}

group.notify(queue: .main) {
    print("All done")  // Called when all tasks complete
}
Manual enter/leave:
swiftgroup.enter()
someAsyncOperation {
    print("Completed")
    group.leave()
}
DispatchSemaphore
Limit concurrent operations:
swiftlet semaphore = DispatchSemaphore(value: 5)  // Max 5 concurrent tasks

for number in 1...10 {
    semaphore.wait()  // Blocks if limit reached
    queue.async {
        uploadNumber(number)
        semaphore.signal()  // Releases slot
    }
}
```

**Use case:** Limiting concurrent network requests, downloads, or resource-intensive operations.

**Example output:**
```
⏱: 1.18 sec (vs 5+ sec without semaphore)
✨ Modern Concurrency
async/await with Concurrent Execution
swiftfunc myMethod() async {
    print(1)
    
    do {
        async let task1: () = someAsyncMethod()   // Starts immediately
        async let task2: () = someAsyncMethod2()  // Starts immediately
        
        try await task1  // Wait for completion
        await task2
        
        print(4)
    } catch {
        print("Error:", error)
    }
}
Key features:

✅ async let starts tasks concurrently
✅ await suspends without blocking threads
✅ Structured concurrency prevents leaks
✅ Better error handling than GCD

Comparison: GCD vs async/await
FeatureGCDasync/awaitReadability❌ Callback hell✅ Linear codeThread safety⚠️ Manual✅ ActorsCancellation❌ Complex✅ Built-inError handling❌ Scattered✅ try/catchMemory leaks⚠️ [weak self]✅ Automatic
📚 Best Practices

Use async/await for new code - cleaner and safer
Avoid main.sync - causes deadlocks
Use barriers for read/write - thread-safe data access
Limit concurrent tasks - use semaphores to prevent thread explosion
Always dispatch UI updates to main thread

swift   DispatchQueue.main.async {
       label.text = "Updated"
   }

Prefer actors over locks - automatic thread safety
Use @MainActor - ensures UI updates on main thread

🛠 Requirements

iOS 13.0+
Swift 5.5+ (for async/await: iOS 15.0+)
Xcode 13.0+

📖 Resources

Apple's Concurrency Documentation
WWDC 2021: Meet async/await
Swift Concurrency Roadmap

🤝 Contributing
Pull requests are welcome! Feel free to add more examples or improve existing ones.
📄 License
MIT License - feel free to use this code in your projects.

⭐️ If you found this helpful, please star the repository!
