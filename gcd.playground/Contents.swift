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

1 <_NSMainThread: 0x60000170c000>{number = 1, name = main}
3 <_NSMainThread: 0x60000170c000>{number = 1, name = main}
2 <NSThread: 0x6000017249c0>{number = 7, name = (null)}*/

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
// Serial queue executes tasks one by one in order*/

//------------------------------------------------------------

/* DEADLOCK
let main = DispatchQueue.main

print(1)
main.sync {
    print(2)
}
print(3)
*/

//------------------------------------------------------------

/*let serial = DispatchQueue(label: "serial", qos: .userInteractive)

serial.async{
    print(1, Thread.current)
}
serial.async{
    print(2, Thread.current)
}

DispatchQueue.global(qos: .background).async{
    serial.sync {
        print(3, Thread.current)
    }
}
1 <NSThread: 0x600001700000>{number = 5, name = (null)}
2 <NSThread: 0x600001700000>{number = 5, name = (null)}
3 <NSThread: 0x600001700880>{number = 9, name = (null)}*/

//------------------------------------------------------------
    /*
let concurrent = DispatchQueue(label: "concurrent", attributes: .concurrent)

concurrent.async{
    print(1, Thread.current)
    concurrent.async{
        print(2, Thread.current)
        concurrent.async{
            print(4, Thread.current)
        }
    }
    concurrent.sync{
        print(3, Thread.current)
    }
    
}*/

//------------------------------------------------------------

/*let concurrent = DispatchQueue(label: "concurrent", attributes: .concurrent)

concurrent.async { print("Read 1") }
concurrent.async { print("Read 2") }

concurrent.async(flags: .barrier) {
    print("WRITE - exclusive access")
}

concurrent.async { print("Read 3") }
concurrent.async { print("Read 4") }


Read 1
Read 2
WRITE - exclusive access
Read 3
Read 4*/

//------------------------------------------------------------

    /*let workItem = DispatchWorkItem {
    print(1)
}

let q1 = DispatchQueue.global(qos: .userInteractive)

q1.sync(execute: workItem)

print(2)

1
2
*/

//------------------------------------------------------------
//DispatchGroup

/*let group = DispatchGroup()
let q = DispatchQueue(label:"q1")

q.async(group: group) {
    print("1")
}

group.notify(queue: .main){
    print("all done")
}

1
all done*/


/*let group = DispatchGroup()
let q = DispatchQueue(label: "q1")

let wi1 = DispatchWorkItem {
    print("1")
}

wi1.cancel()

q.async(group: group, execute: wi1)

group.notify(queue: .main) {
    print("all done")  // ✅ notify will still trigger even if workItem is cancelled
    // cancel() only marks workItem as cancelled, it doesn't prevent execution
    // the block still runs (just exits early if checks isCancelled)
}

all done


let group = DispatchGroup()
let q = DispatchQueue(label: "q1")

group.enter()
let wi1 = DispatchWorkItem {
    print("1")
    group.leave()
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
    print("2")
}
 group.notify(queue: .main) {
     print("all done")
 }

*/


//------------------------------------------------------------

    //semaphore
/*
let semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue(label: "queue", qos: .background)

print(someMethod())

func someMethod()->Bool{
    queue.async {
        Thread.sleep(forTimeInterval: 2)
        print("done")
        semaphore.signal()
    }
    semaphore.wait()
    return true
}

// without semahore
//true
//done

// with semaphore
//done
//true

let semaphore = DispatchSemaphore(value: 5)
let group = DispatchGroup()
let queue = DispatchQueue(label: "queue", qos: .background, attributes: .concurrent)
let arrs = 1...10
let startTime = CFAbsoluteTimeGetCurrent()


for number in arrs{
    semaphore.wait()
    queue.async(group: group) {
        uploadNumber(number)
        semaphore.signal()
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

5
1
3
2
4
6
10
9
7
8
⏱: 1.1835449934005737 sec*/
