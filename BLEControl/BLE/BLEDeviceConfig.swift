//
//  BLEDeviceConfig.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import Foundation

class BLEDeviceConfig {
    
    let maxAnalogOut : Int
    let maxLCDLines : Int
    
    init(maxAnalogOut: Int, maxLCDLines : Int) {
        self.maxAnalogOut = maxAnalogOut
        self.maxLCDLines = maxLCDLines
    }
}
