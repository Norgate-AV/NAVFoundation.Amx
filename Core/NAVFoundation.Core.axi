PROGRAM_NAME='NAVFoundation.Core'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CORE__
#DEFINE __NAV_FOUNDATION_CORE__ 'NAVFoundation.Core'

#include 'NAVFoundation.Core.h.axi'


/**
 * @function NAVGetTimeStamp
 * @public
 * @description Gets a formatted timestamp string of the current date and time.
 *
 * @returns {char[]} Formatted timestamp string in "YYYY-MM-DD (HH:MM:SS)" format
 *
 * @example
 * stack_var char timestamp[NAV_MAX_CHARS]
 * timestamp = NAVGetTimeStamp()  // Returns something like "2023-11-23 (14:35:42)"
 */
define_function char[NAV_MAX_CHARS] NAVGetTimeStamp() {
    stack_var char thisYear[4]
    stack_var char thisMonth[2]
    stack_var char thisDay[2]

    stack_var char thisHour[2]
    stack_var char thisMinute[2]
    stack_var char thisSecond[2]

    thisYear = format('%04d', date_to_year(ldate))
    thisMonth = format('%02d', date_to_month(ldate))
    thisDay = format('%02d', date_to_day(ldate))

    thisHour = format('%02d', time_to_hour(time))
    thisMinute = format('%02d', time_to_minute(time))
    thisSecond = format('%02d', time_to_second(time))

    return "thisYear, '-', thisMonth, '-', thisDay, ' (', thisHour, ':', thisMinute, ':', thisSecond, ')'"
}


/**
 * @function NAVLog
 * @public
 * @description Logs a message to the master device and debug console (if enabled).
 * Automatically chunks large messages to ensure reliable transmission.
 *
 * @param {char[]} log - The message to log
 *
 * @returns {void}
 *
 * @example
 * NAVLog('System initialization complete')
 *
 * @note If log is empty, sends a carriage return
 * @note Messages longer than NAV_LOG_CHUNK_SIZE will be split into chunks
 */
define_function NAVLog(char log[]) {
    stack_var char buffer[NAV_MAX_BUFFER]

    buffer = log

    if (!length_array(buffer)) {
        send_string 0:1:0, ' '
        return
    }

    while (length_array(buffer)) {
        stack_var char chunk[NAV_LOG_CHUNK_SIZE]

        chunk = get_buffer_string(buffer, NAV_LOG_CHUNK_SIZE)

        send_string 0:1:0, "chunk"
    }
}


/**
 * @function NAVConvertDPSToAscii
 * @public
 * @description Converts a device specification to a human-readable string surrounded by brackets.
 *
 * @param {dev} device - The device to convert
 *
 * @returns {char[]} Device string in format "[D:P:S]"
 *
 * @example
 * stack_var char deviceStr[NAV_MAX_BUFFER]
 * deviceStr = NAVConvertDPSToAscii(dvTP)  // Returns something like "[10001:1:0]"
 */
define_function char[NAV_MAX_BUFFER] NAVConvertDPSToAscii(dev device) {
    return "'[', NAVDeviceToString(device), ']'"
}


/**
 * @function NAVDeviceToString
 * @public
 * @description Converts a device specification to a string in D:P:S format.
 *
 * @param {dev} device - The device to convert
 *
 * @returns {char[]} Device string in format "D:P:S"
 *
 * @example
 * stack_var char deviceStr[NAV_MAX_BUFFER]
 * deviceStr = NAVDeviceToString(dvTP)  // Returns something like "10001:1:0"
 */
define_function char[NAV_MAX_BUFFER] NAVDeviceToString(dev device) {
    return "itoa(device.number), ':', itoa(device.port), ':', itoa(device.system)"
}


/**
 * @function NAVStringToDevice
 * @public
 * @description Parses a device string and populates a device structure.
 *
 * @param {char[]} value - String in D:P:S format to parse
 * @param {dev} device - Device variable to populate (modified in-place)
 *
 * @returns {void}
 *
 * @example
 * stack_var dev newDevice
 * NAVStringToDevice('10001:1:0', newDevice)  // newDevice will be set to 10001:1:0
 *
 * @note If the string doesn't contain colons, only the device number will be set
 */
define_function NAVStringToDevice(char value[], dev device) {
    stack_var integer colon1
    stack_var integer colon2

    // 5001:1:0
    device.number = atoi(value)
    device.port = 1
    device.system = 0

    colon1 = find_string(value, ':', 1)
    if (!colon1) {
        return
    }

    device.number = atoi(mid_string(value, 1, colon1 - 1))

    colon2 = find_string(value, ':', colon1 + 1)
    if (!colon2) {
        return
    }

    device.port = atoi(mid_string(value, colon1 + 1, colon2 - colon1 - 1))
    device.system = atoi(mid_string(value, colon2 + 1, length_array(value) - colon2))
}


/**
 * @function NAVStringToBoolean
 * @public
 * @description Converts a string to a boolean value.
 *
 * @param {char[]} value - String to convert ("true", "1", "on" = true, anything else = false)
 *
 * @returns {char} Boolean result (true or false)
 *
 * @example
 * stack_var char result
 * result = NAVStringToBoolean('true')  // Returns true
 * result = NAVStringToBoolean('on')    // Returns true
 * result = NAVStringToBoolean('1')     // Returns true
 * result = NAVStringToBoolean('false') // Returns false
 *
 * @note Case-insensitive comparison
 */
define_function char NAVStringToBoolean(char value[]) {
    stack_var char copy[NAV_MAX_CHARS]

    copy = lower_string(value)

    if (copy == 'true' || copy == '1' || copy == 'on' || copy == 'yes') {
        return true
    }

    return false
}


/**
 * @function NAVBooleanToString
 * @public
 * @description Converts a boolean value to string representation ("true" or "false").
 *
 * @param {char} value - Boolean value to convert
 *
 * @returns {char[]} "true" if value is non-zero, "false" otherwise
 *
 * @example
 * stack_var char boolStr[NAV_MAX_CHARS]
 * boolStr = NAVBooleanToString(true)   // Returns "true"
 * boolStr = NAVBooleanToString(false)  // Returns "false"
 */
define_function char[NAV_MAX_CHARS] NAVBooleanToString(char value) {
    if (value) {
        return 'true'
    }

    return 'false'
}


/**
 * @function NAVBooleanToOnOffString
 * @public
 * @description Converts a boolean value to "on" or "off" string.
 *
 * @param {char} value - Boolean value to convert
 *
 * @returns {char[]} "on" if value is non-zero, "off" otherwise
 *
 * @example
 * stack_var char state[NAV_MAX_CHARS]
 * state = NAVBooleanToOnOffString(true)   // Returns "on"
 * state = NAVBooleanToOnOffString(false)  // Returns "off"
 */
define_function char[NAV_MAX_CHARS] NAVBooleanToOnOffString(char value) {
    if (value) {
        return 'on'
    }

    return 'off'
}


/**
 * @function NAVSignedIntegerToAscii
 * @public
 * @description Converts a signed integer to a string.
 *
 * @param {sinteger} value - Signed integer to convert
 *
 * @returns {char[]} String representation of the signed integer
 *
 * @example
 * stack_var char result[NAV_MAX_CHARS]
 * result = NAVSignedIntegerToAscii(-123)  // Returns "-123"
 */
define_function char[NAV_MAX_CHARS] NAVSignedIntegerToAscii(sinteger value) {
    return "itoa(value)"
}


/**
 * @function NAVLongToAscii
 * @public
 * @description Converts a long value to a string.
 *
 * @param {long} value - Long value to convert
 *
 * @returns {char[]} String representation of the long value
 *
 * @example
 * stack_var char result[NAV_MAX_CHARS]
 * result = NAVLongToAscii(123456)  // Returns "123456"
 */
define_function char[NAV_MAX_CHARS] NAVLongToAscii(long value) {
    return "itoa(value)"
}


/**
 * @function NAVDoubleToAscii
 * @public
 * @description Converts a double value to a string.
 *
 * @param {double} value - Double value to convert
 *
 * @returns {char[]} String representation of the double value
 *
 * @example
 * stack_var char result[NAV_MAX_CHARS]
 * result = NAVDoubleToAscii(123.456)  // Returns "123.456"
 */
define_function char[NAV_MAX_CHARS] NAVDoubleToAscii(double value) {
    return "itoa(value)"
}


/**
 * @function NAVGetUniqueId
 * @public
 * @description Gets the unique ID string from a controller structure.
 *
 * @param {_NAVController} controller - Controller structure
 *
 * @returns {char[]} Unique ID string
 *
 * @example
 * stack_var _NAVController controller
 * stack_var char uid[NAV_MAX_CHARS]
 *
 * NAVGetControllerInformation(controller)
 * uid = NAVGetUniqueId(controller)
 */
define_function char[NAV_MAX_CHARS] NAVGetUniqueId(_NAVController controller) {
    return controller.UniqueId
}


/**
 * @function NAVGetMacAddressFromUniqueId
 * @public
 * @description Converts a controller unique ID to a MAC address string.
 *
 * @param {char[]} id - Unique ID byte array
 *
 * @returns {char[]} MAC address in XX:XX:XX:XX:XX:XX format (uppercase)
 *
 * @example
 * stack_var char uid[6]
 * stack_var char mac[NAV_MAX_CHARS]
 *
 * // Assuming uid contains a valid unique ID
 * mac = NAVGetMacAddressFromUniqueId(uid)  // Returns something like "00:60:9F:A0:12:34"
 *
 * @note Returns empty string if uniqueId is empty
 */
define_function char[NAV_MAX_CHARS] NAVGetMacAddressFromUniqueId(char id[]) {
    stack_var integer x
    stack_var char mac[6][2]
    stack_var char result[NAV_MAX_CHARS]
    stack_var integer length

    result = ''

    length = length_array(id)

    if (!length) {
        return result
    }

    set_length_array(mac, 6)

    for (x = 1; x <= length; x++) {
        mac[x] = format('%02X', id[x])
    }

    for (x = 1; x <= 6; x++) {
        if (x < 6) {
            result = "result, mac[x], ':'"
            continue
        }

        result = "result, mac[x]"
    }

    return result
}


/**
 * @function NAVGetMacAddress
 * @public
 * @description Gets the MAC address string from a controller structure.
 *
 * @param {_NAVController} controller - Controller structure
 *
 * @returns {char[]} MAC address string
 *
 * @example
 * stack_var _NAVController controller
 * stack_var char mac[NAV_MAX_CHARS]
 *
 * NAVGetControllerInformation(controller)
 * mac = NAVGetMacAddress(controller)
 */
define_function char[NAV_MAX_CHARS] NAVGetMacAddress(_NAVController controller) {
    return controller.MacAddress
}


/**
 * @function NAVGetDeviceSerialNumber
 * @public
 * @description Gets the serial number of an AMX device.
 *
 * @param {dev} device - Target device
 *
 * @returns {char[]} Serial number string, or empty string on error
 *
 * @example
 * stack_var char serial[NAV_MAX_CHARS]
 * serial = NAVGetDeviceSerialNumber(dvMaster)
 */
define_function char[NAV_MAX_CHARS] NAVGetDeviceSerialNumber(dev device) {
    stack_var char serialNumber[NAV_MAX_CHARS]
    stack_var slong result

    result = get_serial_number(device, serialNumber)

    if (result < 0) {
        NAVLog("'Error getting serial number for device: ', NAVDeviceToString(device)")
        return ""
    }

    return serialNumber
}


/**
 * @function NAVGetDeviceIPAddressInformation
 * @public
 * @description Gets IP address information for a device and stores it in the provided structure.
 *
 * @param {dev} device - Target device
 * @param {ip_address_struct} ip - Output structure to store IP information (modified in-place)
 *
 * @returns {void}
 *
 * @example
 * stack_var ip_address_struct ipInfo
 * NAVGetDeviceIPAddressInformation(dvMaster, ipInfo)
 * // Now ipInfo contains IP address, subnet mask, gateway, etc.
 */
define_function NAVGetDeviceIPAddressInformation(dev device, ip_address_struct ip) {
    stack_var slong result

    result = get_ip_address(device, ip)

    if (result < 0) {
        NAVLog("'Error getting IP address information for device: ', NAVDeviceToString(device)")
    }
}


/**
 * @function NAVPrintProgramInformation
 * @public
 * @description Logs program information to the console.
 *
 * @param {_NAVProgram} program - Program information structure
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVProgram progInfo
 * NAVGetControllerProgramInformation(progInfo)
 * NAVPrintProgramInformation(progInfo)
 */
define_function NAVPrintProgramInformation(_NAVProgram program) {
    NAVLog("'**********************************************************'")
    NAVLog("'Program Info'")
    NAVLog("'**********************************************************'")
    NAVLog("'Program Name: ', program.Name")
    NAVLog("'Program File: ', program.File")
    NAVLog("'Compiled On: ', program.CompileDate, ' at ', program.CompileTime")
    NAVLog("'**********************************************************'")
}


/**
 * @function NAVFeedback
 * @public
 * @description Updates channel feedback on a device where only one channel should be on at a time.
 * Turns on the selected channel and turns off all others in the array.
 *
 * @param {dev} device - Target device
 * @param {integer[]} channels - Array of channel codes
 * @param {integer} value - Selected channel index (1-based)
 *
 * @returns {void}
 *
 * @example
 * // Turn on channel 2 in a group of 4 radio button channels
 * stack_var integer channels[4] = {1, 2, 3, 4}
 * NAVFeedback(dvTP, channels, 2)  // Channel 2 on, others off
 */
define_function NAVFeedback(dev device, integer channels[], integer value) {
    stack_var integer x
    stack_var integer length

    length = length_array(channels)

    for(x = 1; x <= length; x++) {
        [device, channels[x]] = (value == x)
    }
}


/**
 * @function NAVFeedbackWithDevArray
 * @public
 * @description Updates channel feedback across multiple devices where only one channel should be on.
 * Similar to NAVFeedback but works with an array of devices.
 *
 * @param {dev[]} device - Array of target devices
 * @param {integer[]} channels - Array of channel codes
 * @param {integer} value - Selected channel index (1-based)
 *
 * @returns {void}
 *
 * @example
 * // Turn on channel 3 across multiple touch panels
 * stack_var dev panels[2] = {dvTP1, dvTP2}
 * stack_var integer channels[5] = {11, 12, 13, 14, 15}
 * NAVFeedbackWithDevArray(panels, channels, 3)  // Channel 13 on, others off
 */
define_function NAVFeedbackWithDevArray(dev device[], integer channels[], integer value) {
    stack_var integer x
    stack_var integer length

    length = length_array(channels)

    for(x = 1; x <= length; x++) {
        [device, channels[x]] = (value == x)
    }
}


/**
 * @function NAVFeedbackWithValueArray
 * @public
 * @description Sets multiple channel states according to a value array.
 * Each channel is set to the corresponding value in the value array.
 *
 * @param {dev} device - Target device
 * @param {integer[]} channels - Array of channel codes
 * @param {integer[]} value - Array of boolean states (0=off, non-zero=on)
 *
 * @returns {void}
 *
 * @example
 * stack_var integer channels[3] = {11, 12, 13}
 * stack_var integer values[3] = {1, 0, 1}  // On, Off, On
 * NAVFeedbackWithValueArray(dvTP, channels, values)
 */
define_function NAVFeedbackWithValueArray(dev device, integer channels[], integer value[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(channels)

    for(x = 1; x <= length; x++) {
        [device, channels[x]] = (value[x])
    }
}


/**
 * @function NAVCommand
 * @public
 * @description Sends a command to a device.
 *
 * @param {dev} device - Target device
 * @param {char[]} value - Command string to send
 *
 * @returns {void}
 *
 * @example
 * NAVCommand(dvTP, 'PAGE-Main')
 */
define_function NAVCommand(dev device, char value[]) {
    send_command device, value
}


/**
 * @function NAVCommandArray
 * @public
 * @description Sends the same command to multiple devices.
 *
 * @param {dev[]} device - Array of target devices
 * @param {char[]} value - Command string to send
 *
 * @returns {void}
 *
 * @example
 * stack_var dev panels[2] = {dvTP1, dvTP2}
 * NAVCommandArray(panels, 'PAGE-Main')
 */
define_function NAVCommandArray(dev device[], char value[]) {
    send_command device, value
}


/**
 * @function NAVSendLevel
 * @public
 * @description Sends a level value to a device.
 *
 * @param {dev} device - Target device
 * @param {integer} level - Level code
 * @param {integer} value - Level value to send
 *
 * @returns {void}
 *
 * @example
 * NAVSendLevel(dvTP, 1, 50)  // Set level 1 to value 50
 */
define_function NAVSendLevel(dev device, integer level, integer value) {
    send_level device, level, value
}


/**
 * @function NAVSendLevelArray
 * @public
 * @description Sends the same level value to multiple devices.
 *
 * @param {dev[]} device - Array of target devices
 * @param {integer} level - Level code
 * @param {integer} value - Level value to send
 *
 * @returns {void}
 *
 * @example
 * stack_var dev panels[2] = {dvTP1, dvTP2}
 * NAVSendLevelArray(panels, 1, 75)  // Set level 1 to value 75 on all panels
 */
define_function NAVSendLevelArray(dev device[], integer level, integer value) {
    stack_var integer x
    stack_var integer length

    length = length_array(device)

    for (x = 1; x <= length; x++) {
        send_level device[x], level, value
    }
}


/**
 * @function NAVGetControllerProgramInformation
 * @public
 * @description Populates a program information structure with compiler constants.
 *
 * @param {_NAVProgram} program - Program structure to populate (modified in-place)
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVProgram progInfo
 * NAVGetControllerProgramInformation(progInfo)
 * // Now progInfo contains program name, file, compile date, etc.
 */
define_function NAVGetControllerProgramInformation(_NAVProgram program) {
    program.Name = __NAME__
    program.File = __FILE__
    program.CompileDate = __LDATE__
    program.CompileTime = __TIME__
}


/**
 * @function NAVGetControllerInformation
 * @public
 * @description Populates a controller structure with device and network information.
 *
 * @param {_NAVController} controller - Controller structure to populate (modified in-place)
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVController controller
 * NAVGetControllerInformation(controller)
 * // Now controller contains IP address, MAC, serial number, etc.
 */
define_function NAVGetControllerInformation(_NAVController controller) {
    device_info(0:1:0, controller.Information)
    device_info(5001:1:0, controller.Device)
    device_info(5002:1:0, controller.Switcher)
    NAVGetDeviceIPAddressInformation(0:1:0, controller.IP)

    controller.SerialNumber = NAVGetDeviceSerialNumber(0:1:0)

    controller.UniqueId = get_unique_id()
    controller.MacAddress = NAVGetMacAddressFromUniqueId(controller.UniqueId)

    NAVGetControllerProgramInformation(controller.Program)
}


/**
 * @function NAVCharIsPrintable
 * @public
 * @description Determines if a character represents a printable ASCII character.
 *
 * @param {char} c - Character to check
 *
 * @returns {char} true if the character is a printable ASCII character, false otherwise
 *
 * @example
 * stack_var char result
 * result = NAVCharIsPrintable($41)  // 'A', Returns true
 * result = NAVCharIsPrintable($0D)  // CR, Returns false
 *
 * @note Printable characters are in the range 32-126 (0x20-0x7E)
 */
define_function char NAVCharIsPrintable(char c) {
    return (c > $1F && c < $7F)
}


/**
 * @function NAVByteIsHumanReadable
 * @public
 * @deprecated Use NAVCharIsPrintable instead
 * @description Determines if a byte represents a human-readable ASCII character.
 * This is an alias for NAVCharIsPrintable.
 *
 * @param {char} byte - Byte to check
 *
 * @returns {char} true if the byte is a printable ASCII character, false otherwise
 *
 * @example
 * stack_var char result
 * result = NAVByteIsHumanReadable($41)  // 'A', Returns true
 * result = NAVByteIsHumanReadable($0D)  // CR, Returns false
 *
 * @note Human-readable bytes are in the range 32-126 (0x20-0x7E)
 */
define_function char NAVByteIsHumanReadable(char byte) {
    return NAVCharIsPrintable(byte)
}


/**
 * @function NAVFormatHex
 * @public
 * @description Formats a byte array as a readable string, showing hexadecimal for non-printable characters.
 *
 * @param {char[]} value - Byte array to format
 *
 * @returns {char[]} Formatted string with readable characters as-is and hex for non-printable characters
 *
 * @example
 * stack_var char data[5] = "ABC$0D$0A"
 * stack_var char formatted[NAV_MAX_BUFFER]
 * formatted = NAVFormatHex(data)  // Returns "ABC$0D$0A"
 *
 * @note Non-printable bytes are shown as "$XX" where XX is the hex value
 */
define_function char[NAV_MAX_BUFFER] NAVFormatHex(char value[]) {
    integer x
    char result[NAV_MAX_BUFFER]
    char hex[NAV_MAX_CHARS]
    char byte

    result = ""

    if(!length_array(value)) {
        return result
    }

    for(x = 1; x <= length_array(value); x++) {
        byte = value[x];

        if(NAVCharIsPrintable(byte)) {
            result = "result, byte"
        }
        else {
            hex = "'$', format('%02X', byte)"
            result = "result, hex"
        }
    }

    return result
}


/**
 * @function NAVGetNewGuid
 * @public
 * @description Generates a new random GUID in standard UUID format.
 *
 * @returns {char[]} Generated GUID string in the format "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
 *
 * @example
 * stack_var char guid[NAV_MAX_CHARS]
 * guid = NAVGetNewGuid()  // Returns something like "b4e12e58-c720-4b9d-a7f3-21a8a6490c14"
 *
 * @note Follows UUID v4 format with fixed version (4) and variant (8-B)
 */
define_function char[NAV_GUID_LENGTH] NAVGetNewGuid() {
    stack_var integer x
    stack_var char result[NAV_GUID_LENGTH]

    for (x = 1; x <= NAV_GUID_LENGTH; x++) {
        stack_var integer random
        stack_var char byte

        random = (random_number(65535) % 16) + 1

        switch (NAV_GUID[x]) {
            case 'x': { byte = NAV_GUID_HEX[random] }
            case 'y': { byte = NAV_GUID_HEX[((random & $03) | $08) + 1] }
            case '-': { byte = '-' }
            case '4': { byte = '4' }
        }

        if (byte > 0) {
            result = "result, byte"
        }
    }

    return result
}


/**
 * @function NAVGetNewUuid
 * @public
 * @description Generates a new random UUID (GUID) in standard format.
 *
 * @returns {char[]} Generated UUID string in the format "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
 *
 * @example
 * stack_var char uuid[NAV_MAX_CHARS]
 * uuid = NAVGetNewUuid()  // Returns something like "b4e12e58-c720-4b9d-a7f3-21a8a6490c14"
 */
define_function char[NAV_GUID_LENGTH] NAVGetNewUuid() {
    return NAVGetNewGuid()
}


/**
 * @function NAVZeroBase
 * @public
 * @description Converts a 1-based index to a 0-based index.
 *
 * @param {integer} value - 1-based index value
 *
 * @returns {integer} Equivalent 0-based index (value-1)
 *
 * @example
 * stack_var integer zeroBasedIndex
 * zeroBasedIndex = NAVZeroBase(1)  // Returns 0
 */
define_function integer NAVZeroBase(integer value) {
    return value - 1
}


/**
 * @function NAVGetNAVBanner
 * @public
 * @description Gets the Norgate AV Foundation ASCII art banner with license information.
 *
 * @returns {char[]} Formatted banner string
 *
 * @example
 * send_string 0, NAVGetNAVBanner()  // Outputs banner to console
 */
define_function char[NAV_MAX_BUFFER] NAVGetNAVBanner() {
    return "
        ' _   _                       _          ___     __', NAV_CR, NAV_LF,
        '| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /', NAV_CR, NAV_LF,
        '|  \| |/ _ \| ''__/ _` |/ _` | __/ _ \ / _ \ \ / /', NAV_CR, NAV_LF,
        '| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /', NAV_CR, NAV_LF,
        '|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/', NAV_CR, NAV_LF,
        '                 |___/', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        'MIT License', NAV_CR, NAV_LF,
        'Copyright (c) 2010-2025, Norgate AV', NAV_CR, NAV_LF,
        'https://github.com/Norgate-AV/NAVFoundation.Amx', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '=============================================================',
        NAV_CR, NAV_LF
    "
}


/**
 * @function NAVPrintBanner
 * @public
 * @description Logs a formatted banner with controller and program information.
 *
 * @param {_NAVController} controller - Controller structure containing system information
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVController controller
 * NAVGetControllerInformation(controller)
 * NAVPrintBanner(controller)  // Outputs detailed information banner
 */
define_function NAVPrintBanner(_NAVController controller) {
    NAVLog("' _   _                       _          ___     __'")
    NAVLog("'| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /'")
    NAVLog("'|  \| |/ _ \| ''__/ _` |/ _` | __/ _ \ / _ \ \ / /'")
    NAVLog("'| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /'")
    NAVLog("'|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/'")
    NAVLog("'                 |___/'")
    NAVLog("")
    NAVLog("'MIT License'")
    NAVLog("'Copyright (c) 2010-2026, Norgate AV'")
    NAVLog("'https://github.com/Norgate-AV/NAVFoundation.Amx'")
    NAVLog("")
    NAVLog("'============================================================='")
    NAVLog("")
    NAVLog("'Program Info:'")
    NAVLog("'Name: ', controller.Program.Name")
    NAVLog("'File: ', controller.Program.File")
    NAVLog("'Compiled On: ', controller.Program.CompileDate, ' at ', controller.Program.CompileTime")
    NAVLog("")
    NAVLog("'============================================================='")
    NAVLog("")
    NAVLog("'Master Info:'")
    NAVLog("'Device Id: 0'")
    NAVLog("'Manufacturer: ', controller.Information.Manufacturer_String")
    NAVLog("'Model: ', controller.Information.Device_Id_String")
    NAVLog("'Version: ', controller.Information.Version")
    NAVLog("'Firmware Id: ', itoa(controller.Information.Firmware_Id)")
    NAVLog("'Serial Number: ', controller.SerialNumber")
    NAVLog("'Unique Id: ', NAVFormatHex(controller.UniqueId)")
    NAVLog("")
    NAVLog("'============================================================='")

    if (controller.Device.Device_Id) {
        NAVLog("")
        NAVLog("'Device Info:'")
        NAVLog("'Device Id: 5001'")
        NAVLog("'Manufacturer: ', controller.Device.Manufacturer_String")
        NAVLog("'Model: ', controller.Device.Device_Id_String")
        NAVLog("'Version: ', controller.Device.Version")
        NAVLog("'Firmware Id: ', itoa(controller.Device.Firmware_Id)")
        NAVLog("")
        NAVLog("'============================================================='")
    }

    if (controller.Switcher.Device_Id) {
        NAVLog("")
        NAVLog("'Switcher Info:'")
        NAVLog("'Device Id: 5002'")
        NAVLog("'Manufacturer: ', controller.Switcher.Manufacturer_String")
        NAVLog("'Model: ', controller.Switcher.Device_Id_String")
        NAVLog("'Version: ', controller.Switcher.Version")
        NAVLog("'Firmware Id: ', itoa(controller.Switcher.Firmware_Id)")
        NAVLog("")
        NAVLog("'============================================================='")
    }

    NAVLog("")
    NAVLog("'Network Info:'")
    NAVLog("'Mac Address: ', controller.MacAddress")
    NAVLog("'IP Address: ', controller.IP.IPAddress")
    NAVLog("'Subnet Mask: ', controller.IP.SubnetMask")
    NAVLog("'Gateway: ', controller.IP.Gateway")
    NAVLog("'Hostname: ', controller.IP.Hostname")
    NAVLog("'DHCP Enabled: ', NAVBooleanToString(controller.IP.Flags)")
    NAVLog("")
    NAVLog("'============================================================='")
}


/**
 * @function NAVGetVariableToXmlError
 * @public
 * @description Gets a human-readable error message for variable-to-XML conversion errors.
 *
 * @param {sinteger} error - Error code from variable_to_xml function
 *
 * @returns {char[]} Human-readable error description
 *
 * @example
 * stack_var sinteger result
 * stack_var char errorMsg[NAV_MAX_BUFFER]
 *
 * // Assume result contains an error code
 * errorMsg = NAVGetVariableToXmlError(result)
 */
define_function char[NAV_MAX_BUFFER] NAVGetVariableToXmlError(sinteger error) {
    switch (error) {
        case NAV_VAR_TO_XML_ERROR_XML_DECODE_DATA_TYPE_MISMATCH: {
            return "'XML decode data type mismatch'"
        }
        case NAV_VAR_TO_XML_ERROR_XML_DECODE_DATA_TOO_SMALL: {
            return "'XML decode data too small, more members in structure'"
        }
        case NAV_VAR_TO_XML_ERROR_STRUCTURE_TOO_SMALL: {
            return "'Structure too small, more members in XML decode string'"
        }
        case NAV_VAR_TO_XML_ERROR_DECODE_VARIABLE_TYPE_MISMATCH: {
            return "'Decode variable type mismatch'"
        }
        case NAV_VAR_TO_XML_ERROR_DECODE_DATA_TOO_SMALL: {
            return "'Decode data too small, decoder ran out of data. Most likely poorly formed XML'"
        }
        case NAV_VAR_TO_XML_ERROR_OUTPUT_CHARACTER_BUFFER_TOO_SMALL: {
            return "'Output character buffer was too small'"
        }
        default: {
            return "'Unknown error: ', itoa(error)"
        }
    }
}


/**
 * @function NAVGetVariableToStringError
 * @public
 * @description Gets a human-readable error message for variable-to-string conversion errors.
 *
 * @param {sinteger} error - Error code from variable_to_string function
 *
 * @returns {char[]} Human-readable error description
 *
 * @example
 * stack_var sinteger result
 * stack_var char errorMsg[NAV_MAX_BUFFER]
 *
 * // Assume result contains an error code
 * errorMsg = NAVGetVariableToStringError(result)
 */
define_function char[NAV_MAX_BUFFER] NAVGetVariableToStringError(sinteger error) {
    switch (error) {
        case NAV_VAR_TO_STRING_UNRECOGNIZED_TYPE: {
            return "'Encoded variable unrecognized type'"
        }
        case NAV_VAR_TO_STRING_BUFFER_TOO_SMALL: {
            return "'Encoded data would not fit into buffer, buffer too small'"
        }
        default: {
            return "'Unknown error: ', itoa(error)"
        }
    }
}


/**
 * @function NAVGetStringToVariableError
 * @public
 * @description Gets a human-readable error message for string-to-variable conversion errors.
 *
 * @param {sinteger} error - Error code from string_to_variable function
 *
 * @returns {char[]} Human-readable error description
 *
 * @example
 * stack_var sinteger result
 * stack_var char errorMsg[NAV_MAX_BUFFER]
 *
 * // Assume result contains an error code
 * errorMsg = NAVGetStringToVariableError(result)
 */
define_function char[NAV_MAX_BUFFER] NAVGetStringToVariableError(sinteger error) {
    switch (error) {
        case NAV_STRING_TO_VAR_ERROR_DECODE_DATA_TOO_SMALL_1: {
            return "'Decode data too small, more members in structure'"
        }
        case NAV_STRING_TO_VAR_ERROR_STRUCTURE_TOO_SMALL: {
            return "'Structure too small, more members in decode string'"
        }
        case NAV_STRING_TO_VAR_ERROR_DECODE_VARIABLE_TYPE_MISMATCH: {
            return "'Decode variable type mismatch'"
        }
        case NAV_STRING_TO_VAR_ERROR_DECODE_DATA_TOO_SMALL_2: {
            return "'Decode data too small, decoder ran out of data'"
        }
        default: {
            return "'Unknown error: ', itoa(error)"
        }
    }
}


/**
 * @function NAVDeviceIsOnline
 * @public
 * @description Checks if a device is currently online.
 *
 * @param {dev} device - Device to check
 *
 * @returns {char} true if device is online, false otherwise
 *
 * @example
 * stack_var char isOnline
 * isOnline = NAVDeviceIsOnline(dvTP)  // Returns true if touch panel is connected
 */
define_function char NAVDeviceIsOnline(dev device) {
    return device_id(device) != 0
}


DEFINE_START {
    #IF_DEFINED __MAIN__
    stack_var _NAVController controller

    NAVGetControllerInformation(controller)
    NAVPrintBanner(controller)

    NAVLog("__FILE__, ' : ', 'Program Started'")
    NAVLog("'============================================================='")
    #END_IF
}


#END_IF // __NAV_FOUNDATION_CORE__
