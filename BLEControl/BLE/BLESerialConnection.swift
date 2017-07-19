//
//  BLESerialConnection.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLESerialConnectionDelegate {
    // Discovery
    func didDiscover(peripheral : CBPeripheral, rssi : NSNumber)
    // Connection
    func didConnect()
    func didFailToConnect(peripheral: CBPeripheral)
    func didDisconnect(peripheral: CBPeripheral)
}

class BLESerialConnection : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var dispatchQueue: DispatchQueue?
    
    var serviceUUID = CBUUID(string: "FFE0")
    var characteristicUUID = CBUUID(string: "FFE1")
    var delegate : BLESerialConnectionDelegate!
    
    init(delegate : BLESerialConnectionDelegate) {
        super.init()
        self.delegate = delegate
        self.dispatchQueue = DispatchQueue(label: "BLEDispatchQueue")
        guard dispatchQueue != nil else {
            return
        }
        self.centralManager = CBCentralManager(delegate: self, queue: self.dispatchQueue)
    }
    
    func startScan() {
        guard self.centralManager.state == .poweredOn else {
            return
        }
        self.centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func stopScan() {
        self.centralManager.stopScan()
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    
    // MARK: CBCentralManagerDelegate mehods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.delegate.didDiscover(peripheral: peripheral, rssi: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.delegate.didConnect()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.delegate.didFailToConnect(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.delegate.didDisconnect(peripheral: peripheral)
    }
    
    // MARK: CBPeripheralDelegate methods
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        
    }
    

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
    }
    

    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        
    }
    

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
    }
    

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
}
