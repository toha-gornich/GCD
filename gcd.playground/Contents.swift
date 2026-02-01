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

/* DEADLOCK
let main = DispatchQueue.main

print(1)
main.sync {
    print(2)
}
print(3)
*/




let serial = DispatchQueue(label: "serial", qos: .userInteractive)


