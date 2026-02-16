PROGRAM_NAME='NAVFoundation.ComSpec'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_COMSPEC__
#DEFINE __NAV_FOUNDATION_COMSPEC__ 'NAVFoundation.ComSpec'

#include 'NAVFoundation.ComSpec.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


/**
 * @function NAVComSpecInit
 * @public
 * @description Initializes a _NAVComSpec structure with common default values.
 * Default settings: 9600 baud, 8 data bits, 1 stop bit, no parity, RS-232 mode,
 * no character delay, hardware/software handshaking disabled, 9-bit mode disabled.
 *
 * @param {_NAVComSpec} spec - Reference to the _NAVComSpec structure to initialize
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVComSpec comSpec
 * NAVComSpecInit(comSpec)
 * comSpec.Baud = 115200
 * NAVComSpecApply(dvDevice, comSpec)
 */
define_function NAVComSpecInit(_NAVComSpec spec) {
    spec.Baud = 9600
    spec.DataBits = 8
    spec.StopBits = 1
    spec.Parity = 'N'
    spec.Rs485 = false
    spec.Rs422 = false
    spec.CharDelay = 0
    spec.CharDelayMs = 0
    spec.HardFlowControl = false
    spec.SoftFlowControl = false
    spec.B9Mode = false
}


/**
 * @function NAVComSpecApply
 * @public
 * @description Applies serial port communication settings to a device based on a _NAVComSpec structure.
 * Sends appropriate commands to configure baud rate, data bits, parity, stop bits, RS-422/485 mode,
 * character delay, hardware/software handshaking, and 9-bit mode.
 *
 * @param {dev} device - Target device to configure
 * @param {_NAVComSpec} spec - Structure containing the serial port settings to apply
 *
 * @returns {char} true if settings were applied successfully, false if validation failed
 *
 * @example
 * stack_var _NAVComSpec comSpec
 * NAVComSpecInit(comSpec)
 * comSpec.Baud = 115200
 * comSpec.HardFlowControl = true
 * if (NAVComSpecApply(dvSerialPort, comSpec)) {
 *     // Settings applied successfully
 * }
 */
define_function char NAVComSpecApply(dev device, _NAVComSpec spec) {
    stack_var char mode[15]

    // Can't apply serial setting to a socket
    if (device.number == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_COMSPEC__,
                                    'NAVComSpecApply',
                                    "'Cannot apply serial settings to socket device: ', NAVDeviceToString(device)")
        return false
    }

    // Ensure device is online before attempting to send commands
    if (!NAVDeviceIsOnline(device)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_COMSPEC__,
                                    'NAVComSpecApply',
                                    "'Attempt to apply serial settings to offline device: ', NAVDeviceToString(device)")
        return false
    }

    // Validate baud rate
    switch (spec.Baud) {
        case 150:
        case 300:
        case 600:
        case 1200:
        case 2400:
        case 4800:
        case 9600:
        case 19200:
        case 38400:
        case 57600:
        case 76800:
        case 115200: {
            break
            // Valid baud rates
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_COMSPEC__,
                                        'NAVComSpecApply',
                                        "'Invalid baud rate: ', itoa(spec.Baud)")
            return false
        }
    }

    // Validate 9-bit mode constraints
    // When B9Mode is enabled, force to the ONLY valid combination: N,9,1
    if (spec.B9Mode) {
        spec.Parity = 'N'
        spec.DataBits = 9
        spec.StopBits = 1
    }

    // Validate parity
    switch (spec.Parity) {
        case 'N':       // None
        case 'E':       // Even
        case 'O':       // Odd
        case 'M':       // Mark
        case 'S': {     // Space
            break
            // Valid parity options
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_COMSPEC__,
                                        'NAVComSpecApply',
                                        "'Invalid parity: ', spec.Parity")
            return false
        }
    }

    // Validate data bits (8 is standard, 9 only valid with B9Mode)
    switch (spec.Databits) {
        case 8: {
            break
            // Valid data bits
        }
        case 9: {
            if (!spec.B9Mode) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_COMSPEC__,
                                            'NAVComSpecApply',
                                            '9 data bits requires B9Mode to be enabled')
                return false
            }

            break
            // Only valid if B9Mode enabled
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_COMSPEC__,
                                        'NAVComSpecApply',
                                        "'Invalid data bits: ', itoa(spec.DataBits)")
            return false
        }
    }

    // Validate stop bits
    switch (spec.StopBits) {
        case 1:
        case 2: {
            break
            // Valid stop bits
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_COMSPEC__,
                                        'NAVComSpecApply',
                                        "'Invalid stop bits: ', itoa(spec.StopBits)")
            return false
        }
    }

    // Validate RS485 and RS422 are NOT both set
    if (spec.Rs485 && spec.Rs422) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_COMSPEC__,
                                    'NAVComSpecApply',
                                    'Both Rs485 and Rs422 cannot be enabled simultaneously')
        return false
    }

    // Validate character delay settings - cannot use both CHARD and CHARDM simultaneously
    if (spec.CharDelay > 0 && spec.CharDelayMs > 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_COMSPEC__,
                                    'NAVComSpecApply',
                                    'Cannot set both CharDelay and CharDelayMs')
        return false
    }

    // Set port mode
    // This will be ignored for regular RS232 ports,
    // but is required for IR ports when using one-way RS232 mode
    NAVCommand(device, 'SET MODE DATA')

    // Ensure RX mode is on
    NAVCommand(device, 'RXON')

    // Configure 9-bit mode BEFORE setting baud parameters
    // B9MON overrides the port to 9-bit mode
    if (spec.B9Mode) {
        NAVCommand(device, 'B9MON')
    }
    else {
        NAVCommand(device, 'B9MOFF')
    }

    // Build RS-422/485 mode string
    select {
        active (spec.Rs485): {
            mode = '485 ENABLE'
        }
        active (spec.Rs422): {
            mode = '422 ENABLE'
        }
        active (true): {
            // Neither 422 nor 485 enabled = RS-232 mode
            mode = '422/485 DISABLE'
        }
    }

    // Send SET BAUD command
    NAVCommand(device, "
        'SET BAUD ', itoa(spec.Baud), ',',
                     spec.Parity, ',',
                     itoa(spec.DataBits), ',',
                     itoa(spec.StopBits), ' ',
                     mode")

    // Configure character delay
    // If both are zero, send both commands to ensure zero delay
    // Otherwise, send only the non-zero command
    select {
        active (spec.CharDelay == 0 && spec.CharDelayMs == 0): {
            NAVCommand(device, 'CHARD-0')
            NAVCommand(device, 'CHARDM-0')
        }
        active (spec.CharDelayMs > 0): {
            NAVCommand(device, "'CHARDM-', itoa(spec.CharDelayMs)")
        }
        active (spec.CharDelay > 0): {
            NAVCommand(device, "'CHARD-', itoa(spec.CharDelay)")
        }
    }

    // Configure hardware handshaking
    if (spec.HardFlowControl) {
        NAVCommand(device, 'HSON')
    }
    else {
        NAVCommand(device, 'HSOFF')
    }

    // Configure software handshaking
    if (spec.SoftFlowControl) {
        NAVCommand(device, 'XON')
    }
    else {
        NAVCommand(device, 'XOFF')
    }

    return true
}


#END_IF // __NAV_FOUNDATION_COMSPEC__
