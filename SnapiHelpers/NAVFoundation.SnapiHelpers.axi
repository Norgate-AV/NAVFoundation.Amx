PROGRAM_NAME='NAVFoundation.SnapiHelpers'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SNAPIHELPERS__
#DEFINE __NAV_FOUNDATION_SNAPIHELPERS__ 'NAVFoundation.SnapiHelpers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.SnapiHelpers.h.axi'
#include 'NAVFoundation.StringUtils.axi'


/**
 * @function NAVSwitch
 * @public
 * @description Sends a SWITCH command to a device using SNAPI format.
 * Used to route inputs to outputs or select an input for a device.
 *
 * @param {dev} device - Target device
 * @param {integer} input - Input number to switch
 * @param {integer} output - Output number to route to (use 0 for devices with single output)
 * @param {integer} level - Switching level (NAV_SWITCH_LEVEL_VID, NAV_SWITCH_LEVEL_AUD, or NAV_SWITCH_LEVEL_ALL)
 *
 * @returns {void}
 *
 * @example
 * // For a switcher - route input 2 to output 3, video only
 * NAVSwitch(dvSwitcher, 2, 3, NAV_SWITCH_LEVEL_VID)
 *
 * // For a device with single output - select input 2, all signals
 * NAVSwitch(dvDisplay, 2, 0, NAV_SWITCH_LEVEL_ALL)
 *
 * @see NAV_SWITCH_LEVEL_VID
 * @see NAV_SWITCH_LEVEL_AUD
 * @see NAV_SWITCH_LEVEL_ALL
 */
define_function NAVSwitch(dev device, integer input, integer output, integer level) {
    if(output > 0) {
        NAVCommand(device, "'SWITCH-', itoa(input), ',', itoa(output), ',', NAV_SWITCH_LEVELS[level]")
    }
    else {
        NAVCommand(device, "'SWITCH-', itoa(input), ',', NAV_SWITCH_LEVELS[level]")
    }
}


/**
 * @function NAVInput
 * @public
 * @description Sends an INPUT command to a device using SNAPI format.
 * Used to select an input source by name or number.
 *
 * @param {dev} device - Target device
 * @param {char[]} input - Input identifier (name or number)
 *
 * @returns {void}
 *
 * @example
 * // Select input by number
 * NAVInput(dvDisplay, '2')
 *
 * // Select input by name
 * NAVInput(dvReceiver, 'HDMI1')
 */
define_function NAVInput(dev device, char input[]) {
    NAVCommand(device, "'INPUT-', input")
}


/**
 * @function NAVInputArray
 * @public
 * @description Sends an INPUT command to multiple devices using SNAPI format.
 * Used to select the same input source on multiple devices.
 *
 * @param {dev[]} device - Array of target devices
 * @param {char[]} input - Input identifier (name or number)
 *
 * @returns {void}
 *
 * @example
 * stack_var dev displays[2]
 * displays[1] = dvDisplay1
 * displays[2] = dvDisplay2
 *
 * // Select input 2 on both displays
 * NAVInputArray(displays, '2')
 */
define_function NAVInputArray(dev device[], char input[]) {
    NAVCommandArray(device, "'INPUT-', input")
}


/**
 * @function NAVGetPower
 * @public
 * @description Gets the current power state of a device from its SNAPI feedback.
 *
 * @param {dev} device - Target device
 *
 * @returns {integer} 1 if device is powered on, 0 if off
 *
 * @example
 * stack_var integer isPoweredOn
 * isPoweredOn = NAVGetPower(dvDisplay)
 *
 * @note Uses standard SNAPI POWER_FB channel
 */
define_function integer NAVGetPower(dev device) {
    return [device, POWER_FB]
}


/**
 * @function NAVGetVolumeMute
 * @public
 * @description Gets the current volume mute state of a device from its SNAPI feedback.
 *
 * @param {dev} device - Target device
 *
 * @returns {integer} 1 if volume is muted, 0 if unmuted
 *
 * @example
 * stack_var integer isMuted
 * isMuted = NAVGetVolumeMute(dvDisplay)
 *
 * @note Uses standard SNAPI VOL_MUTE_FB channel
 */
define_function integer NAVGetVolumeMute(dev device) {
    return [device, VOL_MUTE_FB]
}


/**
 * @function NAVParseSnapiMessage
 * @public
 * @description Parses a SNAPI format message into a structured message object.
 * Extracts the header and all parameters for easier processing.
 *
 * @param {char[]} data - Raw SNAPI message string
 * @param {_NAVSnapiMessage} message - Message structure to populate (modified in-place)
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVSnapiMessage msg
 * NAVParseSnapiMessage('PASSTHRU-"Some data",123', msg)
 * // Result: msg.Header = "PASSTHRU", msg.Parameter[1] = "Some data", msg.Parameter[2] = "123", msg.ParameterCount = 2
 *
 * @see _NAVSnapiMessage
 * @see NAVSnapiMessageLog
 */
define_function integer NAVParseSnapiMessage(char data[], _NAVSnapiMessage message) {
    stack_var char dataCopy[NAV_MAX_BUFFER]
    stack_var integer count

    if (!length_array(data)) {
        return 1    // Invald argument
    }

    dataCopy = data

    if (!NAVContains(dataCopy, '-')) {
        message.Header = dataCopy
        return 0
    }

    message.Header = NAVStripRight(remove_string(dataCopy, '-', 1), 1)

    if (!length_array(dataCopy)) {
        return 0
    }

    count = 0
    while (length_array(dataCopy)) {
        stack_var char byte
        stack_var char parameter[255]

        byte = get_buffer_char(dataCopy)

        switch (byte) {
            case '"': {
                parameter = NAVParseEscapedSnapiMessageParameter(dataCopy)
            }
            case ',': {
                parameter = ''
            }
            default: {
                dataCopy = "byte, dataCopy"
                parameter = NAVParseSnapiMessageParamter(dataCopy)
            }
        }

        count++
        message.Parameter[count] = parameter
        message.ParameterCount = count
    }

    set_length_array(message.Parameter, count)
    return 0
}


/**
 * @function NAVParseSnapiMessageParamter
 * @internal
 * @description Parses a standard (non-quoted) parameter from a SNAPI message.
 *
 * @param {char[]} data - Remaining message data to parse (modified in-place)
 *
 * @returns {char[255]} Extracted parameter value
 *
 * @note This is an internal helper function used by NAVParseSnapiMessage
 * @see NAVParseSnapiMessage
 */
define_function char[255] NAVParseSnapiMessageParamter(char data[]) {
    if (NAVContains(data, ',')) {
        return NAVStripRight(remove_string(data, ',', 1), 1)
    }

    return get_buffer_string(data, length_array(data))
}


/**
 * @function NAVParseEscapedSnapiMessageParameter
 * @internal
 * @description Parses a quoted parameter from a SNAPI message.
 * Handles escaped quotes and commas within quoted strings.
 *
 * @param {char[]} data - Remaining message data to parse (modified in-place)
 *
 * @returns {char[255]} Extracted parameter value without quotes
 *
 * @note This is an internal helper function used by NAVParseSnapiMessage
 * @see NAVParseSnapiMessage
 */
define_function char[255] NAVParseEscapedSnapiMessageParameter(char data[]) {
    stack_var integer x
    stack_var char endings[2][3]

    endings[1] = '"",'
    endings[2] = '",'

    for (x = 1; x <= max_length_array(endings); x++) {
        stack_var integer index

        index = NAVIndexOf(data, endings[x], 1)

        if (index) {
            stack_var integer end

            end = index + length_array(endings[x])

            return NAVStripRight(get_buffer_string(data, end), 2)
        }
    }

    return NAVStripRight(get_buffer_string(data, length_array(data)), 1)
}


/**
 * @function NAVSnapiMessageLog
 * @public
 * @description Logs the contents of a parsed SNAPI message to the debug log.
 * Useful for debugging and message inspection.
 *
 * @param {_NAVSnapiMessage} message - Parsed SNAPI message structure to log
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVSnapiMessage msg
 * NAVParseSnapiMessage('PASSTHRU-"Some data",123', msg)
 * NAVSnapiMessageLog(msg)
 *
 * @see NAVParseSnapiMessage
 * @see _NAVSnapiMessage
 */
define_function NAVSnapiMessageLog(_NAVSnapiMessage message) {
    stack_var integer count

    NAVLog("'Parsed SNAPI Message:'")

    NAVLog("'  Header: ', message.Header")

    count = length_array(message.Parameter)
    NAVLog("'  Parameter Count: ', itoa(count)")

    if (count) {
        stack_var integer x

        for (x = 1; x <= count; x++) {
            NAVLog("'    Parameter ', itoa(x), ': ', message.Parameter[x]")
        }
    }
}


#END_IF // __NAV_FOUNDATION_SNAPIHELPERS__
