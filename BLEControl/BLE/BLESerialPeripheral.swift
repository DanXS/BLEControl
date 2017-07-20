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

    init(peripheral : CBPeripheral, delegate: BLESerialPeripheralDelegate) {
        self.peripheral = peripheral
        self.delegate = delegate
    }
    
    func discoverServices() {
        self.peripheral.delegate = self
        self.peripheral.discoverServices([BLEUUID.serviceUUID])
    }
    
    func send(command: [UInt8]) {
        let data = Data(bytes: command)
        guard self.writeCharacteristic != nil else {
            assert(false, "The writeCharacteristic not set - called too early?")
            return
        }
        // using write type without response - (much faster)
        peripheral.writeValue(data, for: self.writeCharacteristic!, type: .withoutResponse)
    }
    
    // MARK: CBPeripheralDelegate methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([BLEUUID.characteristicUUID], for: service)
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
}
