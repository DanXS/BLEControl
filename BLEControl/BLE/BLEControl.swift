//
//  BLEControlProperties.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import Foundation


class BLEControl : BLETxMessageQueueDelegate {
    
    var txQueue : BLETxMessageQueue?
    let config : BLEDeviceConfig!
    
    var servo : [Float?] {
        didSet {
            self.postServoProperties()
        }
    }
    
    var lcdLine : [String?] {
        didSet {
            self.postLCDProperties()
        }
    }
    
    init(config: BLEDeviceConfig) {
        self.config = config
        self.servo = Array<Float?>(repeating: nil, count: config.maxServos)
        self.lcdLine = Array<String?>(repeating: nil, count: config.maxLCDLines)
    }
    
    func start() {
        self.txQueue = BLETxMessageQueue(delegate: self)
        self.txQueue?.startSending()
    }
    
    func stop() {
        self.txQueue?.stopSending()
    }
    
    func servoEnable(index: Int, enable: Bool) {
        let command = BLEControlProtocol.buildServoEnCmd(index: UInt8(index), enable: enable)
        self.txQueue?.enqueueCommand(command: command)
    }
    
    func lcdClear() {
        let command = BLEControlProtocol.buildLCDClearCmd()
        self.txQueue?.enqueueCommand(command: command)
    }
    
    private func postServoProperties() {
        for i in 0..<self.config.maxServos {
            if self.servo[i] != nil {
                let command = BLEControlProtocol.buildServoCmd(index: UInt8(i), value: UInt16(self.servo[i]!*1000))
                self.txQueue?.enqueueCommand(command: command)
            }
        }
    }
    
    private func postLCDProperties() {
        for i in 0..<self.config.maxLCDLines {
            if self.lcdLine[i] != nil {
                let command = BLEControlProtocol.buildLCDCmd(index: UInt8(i), value: self.lcdLine[i]!)
                self.txQueue?.enqueueCommand(command: command)
            }
        }
    }
    
    // BLETxMessageQueueDelegate methods
    func sendCommand(command : [UInt8]) {
        print("Sending \(command)")
    }
    
}
