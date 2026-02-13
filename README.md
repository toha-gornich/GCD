iOS Concurrency Examples
A comprehensive collection of concurrency patterns in iOS, covering both legacy GCD (Grand Central Dispatch) and modern async/await approaches.
Table of Contents

GCD Basics
Serial vs Concurrent Queues
Common Pitfalls
Synchronization
Modern Concurrency

GCD Basics
Concurrent Queue with async/sync
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
Key takeaway: sync blocks the current thread, async doesn't.
Serial vs Concurrent Queues
Serial Queue
swiftlet serial = DispatchQueue(label: "serial", qos: .userInteractive)

print(1)
serial.async {
    Thread.sleep(forTimeInterval: 2)
    print(2)
}
serial.async {
    print(3)  // Waits for previous task
}
Output: 1, 2, 3 (FIFO order)
Concurrent Queue
swiftlet concurrent = DispatchQueue(label: "concurrent", attributes: .concurrent)

concurrent.async { print("Task 1") }
concurrent.async { print("Task 2") }  // Can run simultaneously
Key difference: Serial executes one task at a time, concurrent allows parallel execution.
Common Pitfalls
⚠️ Deadlock
swiftlet main = DispatchQueue.main

print(1)
main.sync {
    print(2)  // ❌ DEADLOCK - main waits for itself
}
print(3)  // Never executes
Why: Main thread tries to synchronously execute on itself = infinite wait.
Thread Usage in Serial Queue
swiftlet serial = DispatchQueue(label: "serial")

serial.async { print(1, Thread.current) }  // Thread A
serial.async { print(2, Thread.current) }  // Same Thread A

DispatchQueue.global().async {
    serial.sync { print(3, Thread.current) }  // Different thread
}
Serial queue uses the same thread for sequential tasks, but can use different threads when called from different contexts.
Synchronization
Dispatch Barrier
swiftlet concurrent = DispatchQueue(label: "concurrent", attributes: .concurrent)

concurrent.async { print("Read 1") }
concurrent.async { print("Read 2") }

concurrent.async(flags: .barrier) {
    print("WRITE")  // Exclusive access
}

concurrent.async { print("Read 3") }
Use case: Thread-safe read/write operations. Reads can happen concurrently, writes get exclusive access.
DispatchGroup
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
Semaphore
swiftlet semaphore = DispatchSemaphore(value: 5)  // Max 5 concurrent tasks

for number in 1...10 {
    semaphore.wait()  // Blocks if limit reached
    queue.async {
        uploadNumber(number)
        semaphore.signal()  // Releases slot
    }
}
Use case: Limiting concurrent network requests, downloads, or resource-intensive operations.
Modern Concurrency
async/await
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

async let starts tasks concurrently
await suspends without blocking threads
Structured concurrency prevents leaks
Better than GCD for most use cases

Comparison: GCD vs async/await
FeatureGCDasync/awaitReadabilityCallback hellLinear codeThread safetyManualActorsCancellationComplexBuilt-inError handlingScatteredtry/catchMemory leaks[weak self]Automatic
Best Practices

Use async/await for new code - cleaner and safer
Avoid main.sync - causes deadlocks
Use barriers for read/write - thread-safe data access
Limit concurrent tasks - use semaphores to prevent thread explosion
Always dispatch UI updates to main thread

swift   DispatchQueue.main.async {
       label.text = "Updated"
   }
Requirements

iOS 13.0+ (for async/await: iOS 15.0+)
Swift 5.5+
