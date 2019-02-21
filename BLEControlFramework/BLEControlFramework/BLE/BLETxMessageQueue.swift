//
//  BLEMessageQueue.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import UIKit

protocol BLETxMessageQueueDelegate {
    func send(command : [UInt8])
}

class BLETxMessageQueue {
    
    let delegate : BLETxMessageQueueDelegate!
    let semaphore : DispatchSemaphore!
    let serialQueue : DispatchQueue!
    var queue : [[UInt8]]!
    var done : Bool!
    
    public init(delegate : BLETxMessageQueueDelegate) {
        self.queue = []
        self.done = false
        self.delegate = delegate
        self.semaphore = DispatchSemaphore(value: 0)
        self.serialQueue = DispatchQueue(label: "com.cuffedtothekeyboard.BLETxMessageQueue.SerialQueue")
    }
    
    func enqueueCommand(command : [UInt8]) {
        self.serialQueue.sync {
            self.queue.append(command)
        }
        self.semaphore.signal()
    }
    
    func startSending() {
        DispatchQueue.global(qos: .userInitiated).async {
            var exit = false
            while (!exit) {
                self.semaphore.wait()
                self.serialQueue.sync {
                    if self.queue.count != 0 {
                        let command = self.queue.remove(at: 0)
                        self.delegate.send(command: command)
                        // sleep the thread a bit to give reciever time to handle message
                        usleep(20000)
                    }
                    else if (self.done) {
                        exit = true
                    }
                }
            }
        }
    }
    
    func stopSending() {
        self.serialQueue.sync {
            self.done = true
        }
        self.semaphore.signal()
    }
}
