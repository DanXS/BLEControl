# BLEControl
Swift classes to connect to IoT devices via custom protocol to drive motors, simple lcd screens, general GPIO, etc

This project aims to be a start at least into controlling devices via swift over BLE. I wanted to create a library where the swift developer didn't have to care about how the device worked or have to program anything low level themselves.  This is an early version - which I intend to grow over time.  So far the functionaliy is rather limited, but it should be easy to expand as new devices are added.

So far the protocol has just these commands:

INIT - Initialise the device (reset any pointers/buffers etc)
ANALOG_OUT_EN - Enable analog out channels - here we have 8 of them, but that really depends on the device
SERVO_VAL - Send a PWM value a signal pin for a servo or brushless motor signal via an ESC
PWM_VAL - Send a PwM value to an analog output pin, e.g for led intensity or to drive a standard DC motor
LCD_TEXT - Write a line of text to an LCD screen
LCD_CLEAR - Clear the text

Unfortunately for streaming applications Bluetooth Low Energy is not as fast as it could be I suppose because it is designed to send small commands in bursts to save power rather than continous streams of data through typical UART interfaces such as USB.  However it is nice to be able to control things remotely via your iPhone - think remote controlled robots, drones etc.

In order to make it as responsive as possible I have made some of the commands not require a reponse which seems to massively improve the speed when sending live interactive signals to the servo or pwm devices - however not all messages are garanteed to get through. Others however whould wait for a response to ensure they get read and completed at the device end.

The BLEControlProtocol class has a static needsResponse method which can be changed to specify which commands you want to be fast and which must be completed when sending to the BLE device.

static func needsResponse(command: UInt8) -> Bool {
    let fastCommands = [Command.SERVO_VAL.rawValue, Command.PWM_VAL.rawValue]
    return !(fastCommands.contains(command))
}

The files in the BLE folder are the libray which implements the protocol and used CoreBluetooth to connect to the bluetooth device, send commands to the bluetooth device etc.

The files in the ViewControllers folder are for the UI and really just there to demonstraite the use of the protocol - if you want to build your own projects using this protocol then you just need the files in the BLE folder.

To accompany this project, on the device side I've a project that runs on the Nucleo STM32F401RE controller board from which interprets the protocol to control things.  You can find out more about the board here:

http://www.st.com/content/st_com/en/products/ecosystems/stm32-open-development-environment/stm32-nucleo.html?querycriteria=productId=SC2003

There is no restriction that this protocol has to run on this device though, anything can implement the protocol, perhaps you prefer arduino?  However this is what I have at home, so this is all I've implemented it for so far.

The commands are send to the device as a stream of bytes with the following general layout:

Command | Length | Data

The BLEControlProtocol class has some static methods to build the various commands into an array of bytes what can then be sent to the device.

For example:

static func buildServoCmd(index : UInt8, value: UInt16) -> [UInt8] {
    var msg : [UInt8] = []
    msg.append(Command.SERVO_VAL.rawValue) // The command
    msg.append(UInt8(3)) // The length of the data
    // The data to follow
    msg.append(index) // The index of the motor to control
    msg.append(UInt8(value >> 8 & 0xFF)) // The most significant byte for the control value
    msg.append(UInt8(value & 0xFF)) // The least significant byte for the control value
    return msg
}

You do not need to call this directly however as it is called for you when you change the value of the servo property in the BLEControl class.  Essentially every time you change a value of a servo it will loop through all servo's with a non-null value in the array and create the command and send it to the device.  So in the example, changing a slider can automatically update the motor in a single line of code:

@IBAction func onServo1SliderChanged(_ sender: UISlider) {
    self.control?.servo[0] = sender.value
}

The accompanying project for the STM32F401RE can be found here:

https://github.com/DanXS/BLE_LCD_PWM


