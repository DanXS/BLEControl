//
//  BLESerialPeripheral.swift
//  BLEControl
//
//  Created by Dan Shepherd on 19/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLESerialPeripheralDelegate {
    func serialIsReady(peripheral : CBPeripheral)
}

class BLESerialPeripheral : NSObject, CBPeripheralDelegate {
    
    let peripheral : CBPeripheral!
    let delegate : BLESerialPeripheralDelegate!
    var writeCharacteristic : CBCharacteristic?
    var ready : Bool

    init(peripheral : CBPeripheral, delegate: BLESerialPeripheralDelegate) {
        self.peripheral = peripheral
        self.delegate = delegate
        self.ready = false
    }
    
    func discoverServices() {
        self.peripheral.delegate = self
        self.peripheral.discoverServices([BLEUUID.serviceUUID])
    }
    
    func send(command: [UInt8]) {
        let data = Data(bytes: command)
        guard self.writeCharacteristic != nil else {
            assert(false, "The write characteristic not set - called too early?")
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            while(!self.ready) {}
            if BLEControlProtocol.needsResponse(command: command[0]) {
                self.peripheral.writeValue(data, for: self.writeCharacteristic!, type: .withResponse)
                self.ready = false
            }
            else {
                self.peripheral.writeValue(data, for: self.writeCharacteristic!, type: .withoutResponse)
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
                self.writeCharacteristic = characteristic
                delegate.serialIsReady(peripheral : peripheral)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        self.ready = true
    }
}
