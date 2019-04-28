//
//  ConnectionTableViewController.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import UIKit
import BLEControlFramework

class ConnectionTableViewController: UITableViewController, BLESerialConnectionDelegate {

    var serial : BLESerialConnection?
    var peripherals : [(CBPeripheral, NSNumber)] = []
    var selectedPeripheral : CBPeripheral?
    var showDisconnectionWarning: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.serial = BLESerialConnection(delegate: self)
        guard self.serial != nil else {
            assert(false, "Could not instantiate BLSerial class")
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return peripherals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeripheralCell", for: indexPath)
        cell.textLabel?.text = self.peripherals[indexPath.row].0.name
        cell.detailTextLabel?.text = "rssi: \(self.peripherals[indexPath.row].1)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        serial?.stopScan()
        if indexPath.row < self.peripherals.count {
            self.selectedPeripheral = self.peripherals[indexPath.row].0
            if serial != nil && !serial!.connectToPeripheral(self.selectedPeripheral!) {
                let alert = UIAlertController(title: "Bluetooth is off", message: "Please enable it in settings", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func onScan(_ sender: UIBarButtonItem) {
        if (self.selectedPeripheral != nil) {
            self.showDisconnectionWarning = false
            serial?.cancelPeripheralConnection(self.selectedPeripheral!)
            self.selectedPeripheral = nil
        }
        self.peripherals = []
        self.tableView.reloadData()
        self.serial?.startScan()
    }
    
    // MARK: BLESerialDelegate methods
    
    func didDiscover(peripheral: CBPeripheral, rssi:NSNumber) {
        DispatchQueue.main.async {
            for existing in self.peripherals {
                // don't add the same peripheral twice
                if peripheral.identifier == existing.0.identifier {
                    return
                }
            }
            self.peripherals.append((peripheral, rssi))
            self.tableView.reloadData()
        }
    }
    
    func didConnect() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "gotoControls", sender: self)
        }
    }

    func didFailToConnect(peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Connection failed", message: "Failed to connect to \(String(describing: peripheral.name!))", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didDisconnect(peripheral: CBPeripheral) {
        if self.showDisconnectionWarning {
            let alert = UIAlertController(title: "Disconnected", message: "The peripheral \(String(describing: peripheral.name!)) has been disconnected", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                self.notifyConnectionLost()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        self.showDisconnectionWarning = true
    }
    
    func didUpdateState(state: CBManagerState) {
        DispatchQueue.main.async {
            if state != .poweredOn {
                self.tableView.isUserInteractionEnabled = false
                
            }
            else {
                self.tableView.isUserInteractionEnabled = true
            }
        }
    }
    
    func notifyConnectionLost() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ConnectionLost")))
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoControls" {
            guard segue.destination is ControlsViewController else {
                assert(false, "Error retrieving destination vc")
                return
            }
            let vc = segue.destination as! ControlsViewController
            vc.peripheral = self.selectedPeripheral
        }
    }


}
