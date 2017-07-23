//
//  BLESerialConnection.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol BLESerialConnectionDelegate {
    // Discovery
    func didDiscover(peripheral : CBPeripheral, rssi : NSNumber)
    // Connection
    func didConnect()
    func didFailToConnect(peripheral: CBPeripheral)
    func didDisconnect(peripheral: CBPeripheral)
    // State change
    func didUpdateState(state: CBManagerState)
}

public class BLESerialConnection : NSObject, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager!
    var dispatchQueue: DispatchQueue?
    
    var delegate : BLESerialConnectionDelegate!
    
    public init(delegate : BLESerialConnectionDelegate) {
        super.init()
        self.delegate = delegate
        self.dispatchQueue = DispatchQueue(label: "com.cuffedtothekeyboard.BLESerialConnection.BLEDispatchQueue")
        guard dispatchQueue != nil else {
            return
        }
        self.centralManager = CBCentralManager(delegate: self, queue: self.dispatchQueue)
    }
    
    public func startScan() {
        guard self.centralManager.state == .poweredOn else {
            return
        }
        self.centralManager.scanForPeripherals(withServices: [BLEUUID.serviceUUID], options: nil)
    }
    
    public func stopScan() {
        self.centralManager.stopScan()
    }
    
    public func connectToPeripheral(_ peripheral: CBPeripheral) -> Bool {
        guard self.centralManager.state == .poweredOn else {
            return false
        }
        centralManager.connect(peripheral, options: nil)
        return true
    }
    
    public func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    
    // MARK: CBCentralManagerDelegate mehods
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.delegate.didUpdateState(state: central.state)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.delegate.didDiscover(peripheral: peripheral, rssi: RSSI)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.delegate.didConnect()
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.delegate.didFailToConnect(peripheral: peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.delegate.didDisconnect(peripheral: peripheral)
    }

}
