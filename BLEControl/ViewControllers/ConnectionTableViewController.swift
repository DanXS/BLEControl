//
//  ConnectionTableViewController.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConnectionTableViewController: UITableViewController, BLESerialConnectionDelegate {

    var serial : BLESerialConnection?
    var peripherals : [(CBPeripheral, NSNumber)] = []
    var selectedPeripheral : CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.serial = BLESerialConnection(delegate: self)
        guard self.serial != nil else {
            assert(false, "could not instantiate BLSerial class")
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
            serial?.connectToPeripheral(self.selectedPeripheral!)
        }
    }

    @IBAction func onScan(_ sender: UIBarButtonItem) {
        if (self.selectedPeripheral != nil) {
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
            let alert = UIAlertController(title: "Connection failed", message: "Failed to connect to \(String(describing: peripheral.name))", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didDisconnect(peripheral: CBPeripheral) {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "gotoControls" {
            guard segue.destination is ControlsViewController else {
                assert(false, "Error retrieving destination vc")
                return
            }
            
        }
    }


}
