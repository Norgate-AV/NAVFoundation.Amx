PROGRAM_NAME='NAVFoundation.CloudLog'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CLOUDLOG__
#DEFINE __NAV_FOUNDATION_CLOUDLOG__ 'NAVFoundation.CloudLog'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.DateTimeUtils.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.Json.axi'
#include 'NAVFoundation.CloudLog.h.axi'


/**
 * @function NAVCloudLogInit
 * @public
 * @description Initializes a _NAVCloudLog structure with empty values.
 *              Useful for creating a clean log structure before populating fields.
 *
 * @param {_NAVCloudLog} log - The log structure to initialize
 *
 * @example
 * stack_var _NAVCloudLog log
 * NAVCloudLogInit(log)
 */
define_function NAVCloudLogInit(_NAVCloudLog log) {
    log.id = ''
    log.timestamp = ''
    log.clientId = ''
    log.hostName = ''
    log.firmwareVersion = ''
    log.systemType = ''
    log.ipAddress = ''
    log.roomName = ''
    log.level = ''
    log.message = ''
}


/**
 * @function NAVCloudLogValidate
 * @public
 * @description Validates that the provided strings will fit in the _NAVCloudLog structure.
 *              Checks clientId, roomName, and message against their maximum field sizes.
 *
 * @param {char[]} clientId - Client identifier to validate
 * @param {char[]} roomName - Room name to validate
 * @param {char[]} message - Message to validate
 *
 * @returns {char} True if all fields are within size limits, false otherwise
 *
 * @example
 * if (NAVCloudLogValidate(clientId, roomName, message)) {
 *     // Safe to create log
 * }
 */
define_function char NAVCloudLogValidate(char clientId[], char roomName[], char message[]) {
    if (length_array(clientId) >= NAV_CLOUDLOG_SIZE_CLIENT_ID) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_CLOUDLOG__,
                                'NAVCloudLogValidate',
                                'clientId exceeds maximum size')
        return false
    }

    if (length_array(roomName) >= NAV_CLOUDLOG_SIZE_ROOM_NAME) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_CLOUDLOG__,
                                'NAVCloudLogValidate',
                                'roomName exceeds maximum size')
        return false
    }

    if (length_array(message) >= NAV_CLOUDLOG_SIZE_MESSAGE) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_CLOUDLOG__,
                                'NAVCloudLogValidate',
                                'message exceeds maximum size')
        return false
    }

    return true
}


/**
 * @function NAVCloudLogBuild
 * @public
 * @description Builds a comprehensive cloud log entry with system metadata and serializes it to JSON.
 *              Automatically collects system information including hostname, firmware version,
 *              IP address, and generates a unique UUID and timestamp for the log entry.
 *
 * @param {char[]} clientId - Client identifier for the application or service
 * @param {char[]} roomName - Name of the room or location generating the log
 * @param {long} level - Log level constant (NAV_LOG_LEVEL_ERROR, NAV_LOG_LEVEL_WARNING, etc.)
 * @param {char[]} message - The log message content
 *
 * @returns {char[NAV_CLOUDLOG_JSON_BUFFER_SIZE]} JSON string representation of the complete log entry
 *
 * @example
 * stack_var char logJson[NAV_CLOUDLOG_JSON_BUFFER_SIZE]
 * logJson = NAVCloudLogBuild('MyApp', 'Conference Room A', NAV_LOG_LEVEL_INFO, 'System started')
 * // Returns: {"id":"...","timestamp":"...","clientId":"MyApp",...}
 */
define_function char[NAV_CLOUDLOG_JSON_BUFFER_SIZE] NAVCloudLogBuild(char clientId[],
                                            char roomName[],
                                            long level,
                                            char message[]) {
    stack_var _NAVController controller
    stack_var _NAVCloudLog log

    log.id = NAVGetNewGuid()
    log.timestamp = NAVDateTimeGetTimestampNow()
    log.clientId = NAVTrimString(clientId)

    NAVGetControllerInformation(controller)
    log.hostName = controller.IP.Hostname

    log.systemType = NAV_CLOUDLOG_SYSTEM_TYPE_NETLINX
    log.firmwareVersion = controller.Information.Version
    log.ipAddress = controller.IP.IPAddress

    log.roomName = NAVTrimString(roomName)
    log.level = NAVGetLogLevel(level)
    log.message = message

    return NAVCloudLogJsonSerialize(log)
}


/**
 * @function NAVCloudLogJsonSerialize
 * @public
 * @description Serializes a _NAVCloudLog structure to a JSON string format.
 *              Properly escapes special characters in string fields to ensure
 *              valid JSON output. Fields escaped: clientId, hostName, firmwareVersion,
 *              roomName, and message.
 *
 * @param {_NAVCloudLog} log - The cloud log structure to serialize
 *
 * @returns {char[NAV_CLOUDLOG_JSON_BUFFER_SIZE]} JSON string representation of the log entry
 *
 * @example
 * stack_var _NAVCloudLog log
 * stack_var char json[NAV_CLOUDLOG_JSON_BUFFER_SIZE]
 * log.id = NAVGetNewGuid()
 * log.message = 'Test message'
 * json = NAVCloudLogJsonSerialize(log)
 */
define_function char[NAV_CLOUDLOG_JSON_BUFFER_SIZE] NAVCloudLogJsonSerialize(_NAVCloudLog log) {
    stack_var char data[NAV_CLOUDLOG_JSON_BUFFER_SIZE]

    // Build JSON object with proper escaping for all string fields
    data = '{'
    data = "data, '"', NAV_CLOUDLOG_FIELD_ID, '":"', log.id, '"'"
    data = "data, ',"', NAV_CLOUDLOG_FIELD_TIMESTAMP, '":"', log.timestamp, '"'"
    data = "data, ',"', NAV_CLOUDLOG_FIELD_CLIENT_ID, '":"', NAVJsonEscapeString(log.clientId), '"'"
    data = "data, ',"', NAV_CLOUDLOG_FIELD_HOST_NAME, '":"', NAVJsonEscapeString(log.hostName), '"'"
    data = "data, ',"', NAV_CLOUDLOG_FIELD_SYSTEM_TYPE, '":"', log.systemType, '"'"
    data = "data, ',"', NAV_CLOUDLOG_FIELD_FIRMWARE_VERSION, '":"', NAVJsonEscapeString(log.firmwareVersion), '"'"
    data = "data, ',"', NAV_CLOUDLOG_FIELD_IP_ADDRESS, '":"', log.ipAddress, '"'"
    data = "data, ',"', NAV_CLOUDLOG_FIELD_ROOM_NAME, '":"', NAVJsonEscapeString(log.roomName), '"'"
    data = "data, ',"', NAV_CLOUDLOG_FIELD_LEVEL, '":"', log.level, '"'"
    data = "data, ',"', NAV_CLOUDLOG_FIELD_MESSAGE, '":"', NAVJsonEscapeString(log.message), '"'"
    data = "data, '}'"

    return data
}


/**
 * @function NAVCloudLog
 * @public
 * @description Sends a log command to a device for processing by a cloud logger module.
 *              Formats the command as 'LOG-<level>,<message>' where level is the string
 *              representation of the log level (error, warning, info, debug).
 *
 * @param {dev} device - The device to send the log command to (typically a cloud logger module)
 * @param {long} level - Log level constant (NAV_LOG_LEVEL_ERROR, NAV_LOG_LEVEL_WARNING, etc.)
 * @param {char[]} message - The log message to send
 *
 * @example
 * // Send an error log to the cloud logger module
 * NAVCloudLog(vdvCloudLogger, NAV_LOG_LEVEL_ERROR, 'Connection failed')
 * // Sends command: "LOG-error,Connection failed"
 */
define_function NAVCloudLog(dev device, long level, char message[]) {
    NAVCommand(device, "NAV_CLOUDLOG_COMMAND_PREFIX, '-', NAVGetLogLevel(level), ',', message")
}


#END_IF // __NAV_FOUNDATION_CLOUDLOG__
