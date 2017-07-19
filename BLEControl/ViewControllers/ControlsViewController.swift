//
//  ControlsViewController.swift
//  BLEControl
//
//  Created by Dan Shepherd on 18/07/2017.
//  Copyright © 2017 Dan Shepherd. All rights reserved.
//

import UIKit

class ControlsViewController: UIViewController, UITextFieldDelegate {

    var control : BLEControl?
    
    @IBOutlet weak var lcdLine1TextField: UITextField!
    @IBOutlet weak var lcdLine2TextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = BLEDeviceConfig(maxServos: 4, maxLCDLines: 2)
        self.control = BLEControl(config: config)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.control?.start()
        self.servoEnable(enable: true)
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
        self.control?.servoEnable(index: 0, enable: enable)
        self.control?.servoEnable(index: 1, enable: enable)
        self.control?.servoEnable(index: 2, enable: enable)
        self.control?.servoEnable(index: 3, enable: enable)
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
    
    
}

