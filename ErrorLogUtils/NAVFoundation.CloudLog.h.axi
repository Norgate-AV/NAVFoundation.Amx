PROGRAM_NAME='NAVFoundation.CloudLog.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CLOUDLOG_H__
#DEFINE __NAV_FOUNDATION_CLOUDLOG_H__ 'NAVFoundation.CloudLog.h'


DEFINE_CONSTANT

// System type identifier
constant char NAV_CLOUDLOG_SYSTEM_TYPE_NETLINX[] = 'NetLinx'

// Command prefix for log commands sent to cloud logger modules
constant char NAV_CLOUDLOG_COMMAND_PREFIX[] = 'LOG'

// Maximum buffer size for serialized JSON log data
constant integer NAV_CLOUDLOG_JSON_BUFFER_SIZE = 2048

// Struct field size constants (matching _NAVCloudLog struct)
constant integer NAV_CLOUDLOG_SIZE_ID = 40
constant integer NAV_CLOUDLOG_SIZE_TIMESTAMP = 32
constant integer NAV_CLOUDLOG_SIZE_CLIENT_ID = 128
constant integer NAV_CLOUDLOG_SIZE_HOST_NAME = 128
constant integer NAV_CLOUDLOG_SIZE_FIRMWARE_VERSION = 64
constant integer NAV_CLOUDLOG_SIZE_SYSTEM_TYPE = 64
constant integer NAV_CLOUDLOG_SIZE_IP_ADDRESS = 45
constant integer NAV_CLOUDLOG_SIZE_ROOM_NAME = 128
constant integer NAV_CLOUDLOG_SIZE_LEVEL = 8
constant integer NAV_CLOUDLOG_SIZE_MESSAGE = 512

// JSON field names
constant char NAV_CLOUDLOG_FIELD_ID[] = 'id'
constant char NAV_CLOUDLOG_FIELD_TIMESTAMP[] = 'timestamp'
constant char NAV_CLOUDLOG_FIELD_CLIENT_ID[] = 'clientId'
constant char NAV_CLOUDLOG_FIELD_HOST_NAME[] = 'hostName'
constant char NAV_CLOUDLOG_FIELD_SYSTEM_TYPE[] = 'systemType'
constant char NAV_CLOUDLOG_FIELD_FIRMWARE_VERSION[] = 'firmwareVersion'
constant char NAV_CLOUDLOG_FIELD_IP_ADDRESS[] = 'ipAddress'
constant char NAV_CLOUDLOG_FIELD_ROOM_NAME[] = 'roomName'
constant char NAV_CLOUDLOG_FIELD_LEVEL[] = 'level'
constant char NAV_CLOUDLOG_FIELD_MESSAGE[] = 'message'


DEFINE_TYPE

/**
 * @struct _NAVCloudLog
 * @description Structure representing a cloud log entry with comprehensive system metadata.
 *              Contains all necessary information for remote logging including unique ID,
 *              timestamp, system information, and the log message itself.
 *
 * @property {char[40]} id - Unique identifier for the log entry (UUID v4 format, 36 chars)
 * @property {char[32]} timestamp - ISO 8601 formatted timestamp of when the log was created (~24 chars)
 * @property {char[128]} clientId - Client identifier for grouping logs by application or service
 * @property {char[128]} hostName - Hostname of the controller generating the log
 * @property {char[64]} firmwareVersion - Firmware version of the controller
 * @property {char[64]} systemType - System type identifier (e.g., 'NetLinx')
 * @property {char[45]} ipAddress - IP address of the controller (supports IPv4 and IPv6)
 * @property {char[128]} roomName - Name of the room or location where the log was generated
 * @property {char[8]} level - Log level (error, warning, info, debug)
 * @property {char[512]} message - The actual log message content
 */
struct _NAVCloudLog {
    char id[40]
    char timestamp[32]
    char clientId[128]
    char hostName[128]
    char firmwareVersion[64]
    char systemType[64]
    char ipAddress[45]
    char roomName[128]
    char level[8]
    char message[512]
}


#END_IF // __NAV_FOUNDATION_CLOUDLOG_H__
