import UIKit
/*let concurrent = DispatchQueue.global(qos: .utility)

print(1, Thread.current)

concurrent.async {
    Thread.sleep(forTimeInterval: 2)
    print(2,Thread.current)
    
}
concurrent.sync {
    print(3,Thread.current)
}

// Output:
1 <_NSMainThread: 0x60000170c000>{number = 1, name = main}
3 <_NSMainThread: 0x60000170c000>{number = 1, name = main}
2 <NSThread: 0x6000017249c0>{number = 7, name = (null)}

// sync blocks main thread until task completes
// async runs on background thread without blocking
*/

//------------------------------------------------------------

/*let serial = DispatchQueue(label: "serail", qos: .userInteractive)

print(1) // Executes immediately on current thread

serial.async {
    Thread.sleep(forTimeInterval: 2) // Blocks serial queue for 2 seconds
    print(2)
}

serial.async {
    print(3) // Waits for first task to complete (serial queue = FIFO)
}

// Output: 1, 2, 3
// Serial queue executes tasks one by one in order
*/

//------------------------------------------------------------

/* DEADLOCK
let main = DispatchQueue.main

print(1)
main.sync {
    print(2) // ❌ Deadlock - main thread waits for itself
}
print(3)
*/

//------------------------------------------------------------

/*let serial = DispatchQueue(label: "serial", qos: .userInteractive)

serial.async{
    print(1, Thread.current)
}
serial.async{
    print(2, Thread.current) // Same thread as task 1 (serial)
}

DispatchQueue.global(qos: .background).async{
    serial.sync {
        print(3, Thread.current) // Different thread (background)
    }
}

// Output:
1 <NSThread: 0x600001700000>{number = 5, name = (null)}
2 <NSThread: 0x600001700000>{number = 5, name = (null)}
3 <NSThread: 0x600001700880>{number = 9, name = (null)}
*/

//------------------------------------------------------------

/*let concurrent = DispatchQueue(label: "concurrent", attributes: .concurrent)

concurrent.async{
    print(1, Thread.current)
    concurrent.async{
        print(2, Thread.current) // Can run on different thread
        concurrent.async{
            print(4, Thread.current)
        }
    }
    concurrent.sync{
        print(3, Thread.current) // Blocks until task 3 completes
    }
}
// Concurrent queue can use multiple threads simultaneously
*/

//------------------------------------------------------------

/*let concurrent = DispatchQueue(label: "concurrent", attributes: .concurrent)

concurrent.async { print("Read 1") }
concurrent.async { print("Read 2") } // Reads can run in parallel

concurrent.async(flags: .barrier) {
    print("WRITE - exclusive access") // Waits for all reads, blocks new tasks
}

concurrent.async { print("Read 3") }
concurrent.async { print("Read 4") }

// Output:
Read 1
Read 2
WRITE - exclusive access
Read 3
Read 4

// Barrier ensures safe write access in concurrent queue
*/

//------------------------------------------------------------

/*let workItem = DispatchWorkItem {
    print(1)
}

let q1 = DispatchQueue.global(qos: .userInteractive)

q1.sync(execute: workItem) // Executes immediately, blocks current thread

print(2)

// Output:
1
2
*/

//------------------------------------------------------------
// DispatchGroup - coordinate multiple async tasks

/*let group = DispatchGroup()
let q = DispatchQueue(label:"q1")

q.async(group: group) {
    print("1")
}

group.notify(queue: .main){
    print("all done") // Called when all group tasks complete
}

// Output:
1
all done
*/

/*let group = DispatchGroup()
let q = DispatchQueue(label: "q1")

let wi1 = DispatchWorkItem {
    print("1")
}

wi1.cancel() // Marks as cancelled but doesn't prevent execution

q.async(group: group, execute: wi1)

group.notify(queue: .main) {
    print("all done")  // ✅ Still triggers even if workItem is cancelled
}

// Output: all done
*/

/*let group = DispatchGroup()
let q = DispatchQueue(label: "q1")

group.enter() // Manual enter
let wi1 = DispatchWorkItem {
    print("1")
    group.leave() // Must call leave manually
}
wi1.cancel()

q.async(execute: wi1)
group.notify(queue: .main) {
    print("all done")
}
*/

/*let group = DispatchGroup()
let q = DispatchQueue(label: "q1")
let q2 = DispatchQueue(label: "q2")

group.enter()
let wi1 = DispatchWorkItem {
    print("1")
    group.leave()
}
q.async(execute: wi1)

q2.async(group: group){
    print("2") // Automatically added to group
}

group.notify(queue: .main) {
    print("all done") // Waits for both tasks
}
*/

//------------------------------------------------------------

// Semaphore - control access to shared resource

/*let semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue(label: "queue", qos: .background)

print(someMethod())

func someMethod()->Bool{
    queue.async {
        Thread.sleep(forTimeInterval: 2)
        print("done")
        semaphore.signal() // Increments semaphore
    }
    semaphore.wait() // Blocks until signal() is called
    return true
}

// Without semaphore:
// true
// done

// With semaphore:
// done
// true
*/

/*let semaphore = DispatchSemaphore(value: 5) // Max 5 concurrent tasks
let group = DispatchGroup()
let queue = DispatchQueue(label: "queue", qos: .background, attributes: .concurrent)
let arrs = 1...10
let startTime = CFAbsoluteTimeGetCurrent()

for number in arrs{
    semaphore.wait() // Blocks if 5 tasks are running
    queue.async(group: group) {
        uploadNumber(number)
        semaphore.signal() // Releases semaphore
    }
}

func uploadNumber(_ number: Int){
    Thread.sleep(forTimeInterval: 0.5)
    print(number)
}

group.notify(queue: .main) {
    let endTime = CFAbsoluteTimeGetCurrent()
    print("⏱: \(endTime - startTime) sec")
}

// Output (order may vary):
5, 1, 3, 2, 4
6, 10, 9, 7, 8
⏱: 1.18 sec

// Limits to 5 concurrent uploads
*/

//------------------------------------------------------------
// async/await - modern concurrency

/*Task{
    await myMethod()
}

func someAsyncMethod() async throws {
    print(2)
    try await Task.sleep(nanoseconds: 3_000_000_000) // Non-blocking sleep
}

func someAsyncMethod2() async {
    print(3)
}

func myMethod() async {
    print(1)
    do {
        async let b: () = someAsyncMethod2() // Starts concurrently
        async let a: () = someAsyncMethod()  // Starts concurrently

        try await a // Waits for completion
        await b

        print(4)
    } catch {
        print("Error:", error)
    }
}

// Output:
1
2 (or 3)
3 (or 2)
4

// async let runs tasks concurrently
// await suspends without blocking thread
*/
