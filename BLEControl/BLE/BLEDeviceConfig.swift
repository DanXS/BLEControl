//
//  BLEDeviceConfig.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import Foundation

class BLEDeviceConfig {
    
    let maxServos : Int
    let maxLCDLines : Int
    
    init(maxServos: Int, maxLCDLines : Int) {
        self.maxServos = maxServos
        self.maxLCDLines = maxLCDLines
    }
}
