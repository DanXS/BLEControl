//
//  BLEUUID.swift
//  BLEControl
//
//  Created by Dan Shepherd on 19/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEUUID {
    static let serviceUUID = CBUUID(string: "FFE0")
    static let characteristicUUID = CBUUID(string: "FFE1")
}
