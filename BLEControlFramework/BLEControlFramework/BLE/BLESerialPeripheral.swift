//
//  BLESerialPeripheral.swift
//  BLEControl
//
//  Created by Dan Shepherd on 19/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol BLESerialPeripheralDelegate {
    func serialIsReady(peripheral : CBPeripheral)
    func errorOccured(message: String)
    func received(data : [UInt8])
}

class BLESerialPeripheral : NSObject, CBPeripheralDelegate, BLERxMessageQueueDelegate {
    
    let peripheral : CBPeripheral!
    let delegate : BLESerialPeripheralDelegate!
    var characteristic : CBCharacteristic?
    var ready : Bool
    var rxQueue : BLERxMessageQueue?

    init(peripheral : CBPeripheral, delegate: BLESerialPeripheralDelegate) {
        self.peripheral = peripheral
        self.delegate = delegate
        self.ready = false
    }
    
    func discoverServices() {
        self.peripheral.delegate = self
        self.peripheral.discoverServices([BLEUUID.serviceUUID])
    }
    
    func stopRecieving() {
        self.rxQueue?.stopReceiving()
    }
    
    func send(command: [UInt8]) {
        let data = Data(bytes: command)
        guard self.characteristic != nil else {
            assert(false, "The write characteristic not set - called too early?")
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            while(!self.ready) {}
            if BLEControlProtocol.needsResponse(command: command[0]) {
                self.peripheral.writeValue(data, for: self.characteristic!, type: .withResponse)
                self.ready = false
            }
            else {
                self.peripheral.writeValue(data, for: self.characteristic!, type: .withoutResponse)
            }
        }
    }
    
    // MARK: CBPeripheralDelegate methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([BLEUUID.characteristicUUID], for: service)
            self.ready = true
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            if characteristic.uuid == BLEUUID.characteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                self.characteristic = characteristic
                self.rxQueue = BLERxMessageQueue(delegate: self)
                self.rxQueue?.startReceiving()
                delegate.serialIsReady(peripheral : peripheral)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        self.ready = true
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let data = characteristic.value
        guard data != nil else {
            return
        }
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: data!.count)
        data!.copyBytes(to: bytes, count: data!.count)
        var byteArray : [UInt8] = []
        for i in 0..<data!.count {
            byteArray.append(bytes[i])
        }
        self.rxQueue?.recieved(bytes: byteArray)
    }
    
    // MARK: BLERxMessageQueueDelegate methods
    
    func recieved(data: [UInt8]) {
        if (data[0] == BLEControlProtocol.Command.UNKNOWN.rawValue) {
            let error = BLEControlProtocol.errorMessageForUnknown(command: data[2])
            self.delegate.errorOccured(message: error)
        }
        else {
            self.delegate.received(data: data)
        }
    }
}
