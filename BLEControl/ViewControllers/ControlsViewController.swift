//
//  ControlsViewController.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import UIKit
import BLEControlFramework

class ControlsViewController: UIViewController, UITextFieldDelegate, BLEControlDelegate {
    
    var peripheral: CBPeripheral?
    var control : BLEControl?
    
    @IBOutlet weak var lcdLine1TextField: UITextField!
    @IBOutlet weak var lcdLine2TextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = BLEDeviceConfig(maxAnalogOut: 8, maxLCDLines: 2)
        guard self.peripheral != nil else {
            assert(false, "Peripheral property must set on this view controller")
            return
        }
        self.control = BLEControl(config: config, peripheral : self.peripheral!, delegate: self)
        self.control?.initDevice()
        self.servoEnable(enable: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(connectionLost(_:)), name: Notification.Name(rawValue: "ConnectionLost"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.servoEnable(enable: false)
        self.control?.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connectionLost(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func servoEnable(enable: Bool) {
        self.control?.analogOutEnable(index: 0, enable: enable)
        self.control?.analogOutEnable(index: 1, enable: enable)
        self.control?.analogOutEnable(index: 2, enable: enable)
        self.control?.analogOutEnable(index: 3, enable: enable)
        self.control?.analogOutEnable(index: 4, enable: enable)
        self.control?.analogOutEnable(index: 5, enable: enable)
        self.control?.analogOutEnable(index: 6, enable: enable)
        self.control?.analogOutEnable(index: 7, enable: enable)
    }

    @IBAction func onServo1SliderChanged(_ sender: UISlider) {
        self.control?.servo[0] = sender.value
    }

    @IBAction func onServo2SliderChanged(_ sender: UISlider) {
        self.control?.servo[1] = sender.value
    }
    
    @IBAction func onServo3SliderChanged(_ sender: UISlider) {
        self.control?.servo[2] = sender.value
    }
    
    @IBAction func onServo4SliderChanged(_ sender: UISlider) {
        self.control?.servo[3] = sender.value
    }
    
    @IBAction func onAnalog1SliderChanged(_ sender: UISlider) {
        self.control?.pwm[4] = sender.value
    }
    
    @IBAction func onAnalog2SliderChanged(_ sender: UISlider) {
        self.control?.pwm[5] = sender.value
    }
    
    @IBAction func onAnalog3SliderChanged(_ sender: UISlider) {
        self.control?.pwm[6] = sender.value
    }
    
    @IBAction func onAnalog4SliderChanged(_ sender: UISlider) {
        self.control?.pwm[7] = sender.value
    }
    
    @IBAction func onClearButton(_ sender: UIButton) {
        self.lcdLine1TextField.text = nil
        self.lcdLine2TextField.text = nil
        self.control?.lcdClear()
    }
    
    @IBAction func onLCDLine1EditingDidEnd(_ sender: UITextField) {
        self.control?.lcdLine[0] = sender.text
    }
    
    @IBAction func onLCDLine2EditingDidEnd(_ sender: UITextField) {
        self.control?.lcdLine[1] = sender.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: BLEControlDelegate method
    
    func deviceError(message : String) {
        print(message)
    }
    
}

