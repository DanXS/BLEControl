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
    // State change
    func didUpdateState(state: CBManagerState)
}

class BLESerialConnection : NSObject, CBCentralManagerDelegate {
    
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
    
    func connectToPeripheral(_ peripheral: CBPeripheral) -> Bool {
        guard self.centralManager.state == .poweredOn else {
            return false
        }
        centralManager.connect(peripheral, options: nil)
        return true
    }
    
    func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    
    // MARK: CBCentralManagerDelegate mehods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.delegate.didUpdateState(state: central.state)
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

}
