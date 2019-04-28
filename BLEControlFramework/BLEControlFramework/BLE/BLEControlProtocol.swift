//
//  BLEControlProtocol.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import Foundation
public class BLEControlProtocol {
    
    enum Command : UInt8 {
        case INIT = 0
        case ANALOG_OUT_EN
        case SERVO_VAL
        case PWM_VAL
        case LCD_TEXT
        case LCD_CLEAR
        case SWITCH_VAL
        //...more to come
        case UNKNOWN = 255
    }
    
    static let commandNames : [String] = [
        "Init",
        "Analog Out Enable",
        "Servo Value",
        "PWM Value",
        "LCD Text",
        "LCD Clear",
        "Switch Value"
    ]
    
    static func buildInitCmd() -> [UInt8] {
        var msg : [UInt8] = []
        msg.append(Command.INIT.rawValue)
        msg.append(UInt8(0))
        return msg
    }
    
    static func buildAnalogOutEnCmd(index : UInt8, enable: Bool) -> [UInt8] {
        var msg : [UInt8] = []
        msg.append(Command.ANALOG_OUT_EN.rawValue)
        msg.append(UInt8(2))
        msg.append(index)
        msg.append(enable ? UInt8(1) : UInt8(0))
        return msg
    }
    
    static func buildServoCmd(index : UInt8, value: UInt16) -> [UInt8] {
        var msg : [UInt8] = []
        msg.append(Command.SERVO_VAL.rawValue)
        msg.append(UInt8(3))
        msg.append(index)
        msg.append(UInt8(value >> 8 & 0xFF))
        msg.append(UInt8(value & 0xFF))
        return msg
    }
    
    static func buildPWMCmd(index : UInt8, value: Int16) -> [UInt8] {
        var msg : [UInt8] = []
        msg.append(Command.PWM_VAL.rawValue)
        msg.append(UInt8(3))
        msg.append(index)
        msg.append(UInt8(value >> 8 & 0xFF))
        msg.append(UInt8(value & 0xFF))
        return msg
    }
    
    static func buildSwitchCmd(index : UInt8, value: Bool) -> [UInt8] {
        var msg : [UInt8] = []
        msg.append(Command.SWITCH_VAL.rawValue)
        msg.append(UInt8(2))
        msg.append(index)
        msg.append(UInt8(value ? 1 : 0))
        return msg
    }
    
    static func buildLCDCmd(index : UInt8, value: String) -> [UInt8] {
        assert(value.count <= 200, "Cannot send strings longer than 200 characters")
        var msg : [UInt8] = []
        msg.append(Command.LCD_TEXT.rawValue)
        msg.append(UInt8(value.count+2))
        msg.append(index)
        msg.append(contentsOf: value.utf8CString.map({ (char) -> UInt8 in
            return UInt8(char)
        }))
        return msg
    }
    
    static func buildLCDClearCmd() -> [UInt8] {
        var msg : [UInt8] = []
        msg.append(Command.LCD_CLEAR.rawValue)
        msg.append(UInt8(0))
        return msg
    }
    
    static func needsResponse(command: UInt8) -> Bool {
        let fastCommands = [Command.SERVO_VAL.rawValue, Command.PWM_VAL.rawValue, Command.SWITCH_VAL.rawValue]
        return !(fastCommands.contains(command))
    }
    
    static func errorMessageForUnknown(command: UInt8) -> String {
        if (Int(command) < commandNames.count) {
            return "Error: device does not understand command \(BLEControlProtocol.commandNames[Int(command)])"
        }
        else {
            return "Error: command of value \(command) does not exist in protocol"
        }
    }
    
}
