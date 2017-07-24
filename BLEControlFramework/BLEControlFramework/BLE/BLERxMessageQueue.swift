//
//  BLERxMessageQueue.swift
//  BLEControlFramework
//
//  Created by Dan Shepherd on 23/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

protocol BLERxMessageQueueDelegate {
    func recieved(data : [UInt8])
}

class BLERxMessageQueue {
    
    let delegate : BLERxMessageQueueDelegate!
    let semaphore : DispatchSemaphore!
    let serialQueue : DispatchQueue!
    var buffer : [UInt8]
    var done : Bool!
    
    public init(delegate : BLERxMessageQueueDelegate) {
        self.buffer = []
        self.done = false
        self.delegate = delegate
        self.semaphore = DispatchSemaphore(value: 0)
        self.serialQueue = DispatchQueue(label: "com.cuffedtothekeyboard.BLERxMessageQueue.SerialQueue")
    }
    
    func recieved(bytes : [UInt8]) {
        for i in 0..<bytes.count {
            self.serialQueue.sync {
                self.buffer.append(bytes[i])
            }
            self.semaphore.signal()
        }
    }
    
    func startReceiving() {
        DispatchQueue.global(qos: .userInitiated).async {
            var exit = false
            while (!exit) {
                self.semaphore.wait()
                if self.buffer.count >= 2 {
                    var command : UInt8 = 0
                    self.serialQueue.sync {
                        command = self.buffer.remove(at: 0)
                    }
                    self.semaphore.wait()
                    var length : UInt8 = 0
                    self.serialQueue.sync {
                        length = self.buffer.remove(at: 0)
                    }
                    var data = [command, length]
                    while length > 0 {
                        self.semaphore.wait()
                        self.serialQueue.sync {
                            if self.buffer.count > 0 {
                                data.append(self.buffer.remove(at: 0))
                                length -= 1
                            }
                        }
                    }
                    self.delegate.recieved(data: data)
                }
                else if (self.done) {
                    exit = true
                }
            }
        }
    }
    
    func stopReceiving() {
        self.serialQueue.sync {
            self.done = true
        }
        self.semaphore.signal()
    }
}
