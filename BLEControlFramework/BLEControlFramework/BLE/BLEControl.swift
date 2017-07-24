//
//  BLEControlProperties.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import Foundation

import CoreBluetooth

public protocol BLEControlDelegate {
    func deviceError(message : String)
}

public class BLEControl : BLETxMessageQueueDelegate, BLESerialPeripheralDelegate {
    
    var txQueue : BLETxMessageQueue?
    let config : BLEDeviceConfig!
    var serial : BLESerialPeripheral?
    var delegate : BLEControlDelegate!
    var isReady : Bool
    
    // MARK: properties - note that setting these causes commands to be sent to the peripheral
    
    public var servo : [Float?] {
        didSet {
            self.postServoProperties()
        }
    }
    
    public var pwm : [Float?] {
        didSet {
            self.postPWMProperties()
        }
    }
    
    public var lcdLine : [String?] {
        didSet {
            self.postLCDProperties()
        }
    }
    
    // MARK: init with device config and peripheral
    
    public init(config: BLEDeviceConfig, peripheral: CBPeripheral, delegate: BLEControlDelegate) {
        self.isReady = false
        self.config = config
        self.delegate = delegate
        self.servo = Array<Float?>(repeating: nil, count: config.maxAnalogOut)
        self.pwm = Array<Float?>(repeating: nil, count: config.maxAnalogOut)
        self.lcdLine = Array<String?>(repeating: nil, count: config.maxLCDLines)
        self.txQueue = BLETxMessageQueue(delegate: self)
        self.serial = BLESerialPeripheral(peripheral: peripheral, delegate: self)
        self.serial?.discoverServices()
    }
    
    // MARK: methods
    
    private func start() {
        self.txQueue?.startSending()
    }
    
    public func stop() {
        self.txQueue?.stopSending()
        self.serial?.stopRecieving();
    }
    
    public func initDevice() {
        let command = BLEControlProtocol.buildInitCmd()
        self.txQueue?.enqueueCommand(command: command)
    }
    
    public func analogOutEnable(index: Int, enable: Bool) {
        let command = BLEControlProtocol.buildAnalogOutEnCmd(index: UInt8(index), enable: enable)
        self.txQueue?.enqueueCommand(command: command)
    }
    
    public func lcdClear() {
        self.lcdLine = Array<String?>(repeating: nil, count: config.maxLCDLines)
        let command = BLEControlProtocol.buildLCDClearCmd()
        self.txQueue?.enqueueCommand(command: command)
    }
    
    private func postServoProperties() {
        for i in 0..<self.config.maxAnalogOut {
            if self.servo[i] != nil {
                let command = BLEControlProtocol.buildServoCmd(index: UInt8(i), value: UInt16(self.servo[i]!*1000))
                self.txQueue?.enqueueCommand(command: command)
            }
        }
    }
    
    private func postPWMProperties() {
        for i in 0..<self.config.maxAnalogOut {
            if self.pwm[i] != nil {
                let command = BLEControlProtocol.buildPWMCmd(index: UInt8(i), value: UInt16(self.pwm[i]!*1000))
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
    
    // MARK: BLETxMessageQueueDelegate methods
    
    public func send(command : [UInt8]) {
        print("Sending \(command)")
        serial?.send(command: command)
    }
    
    // MARK: BLESerialPeripheralDelegate methods
    
    public func serialIsReady(peripheral : CBPeripheral) {
        self.isReady = true
        self.start()
    }
    
    public func errorOccured(message: String) {
        self.delegate.deviceError(message : message)
    }
    
    public func received(data : [UInt8]) {
        // todo: parse the received message and pass it on via delegates
    }
    
}
