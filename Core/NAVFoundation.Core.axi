PROGRAM_NAME='NAVFoundation.Core'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Solutions Ltd

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
#DEFINE __NAV_FOUNDATION_CORE__


(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvNAVMaster	            =	    0:1:0


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

/////////////////////////////////////////////////////////////
// General Constants
/////////////////////////////////////////////////////////////
constant integer NAV_NULL               = 0
constant integer NAV_SOH                = 1
constant integer NAV_STX                = 2
constant integer NAV_ETX                = 3
constant integer NAV_NAK                = 5
constant integer NAV_ACK                = 6
constant integer NAV_TAB                = 9
constant integer NAV_LF                 = 10
constant integer NAV_CR                 = 13
constant integer NAV_ESC                = 27

constant char NAV_NULL_CHAR             = $00
constant char NAV_SOH_CHAR              = $01
constant char NAV_STX_CHAR              = $02
constant char NAV_ETX_CHAR              = $03
constant char NAV_NAK_CHAR              = $05
constant char NAV_ACK_CHAR              = $06
constant char NAV_TAB_CHAR              = $09
constant char NAV_LF_CHAR               = $0A
constant char NAV_CR_CHAR               = $0D
constant char NAV_ESC_CHAR              = $1B

#IF_NOT_DEFINED NAV_MAX_BUFFER
constant integer NAV_MAX_BUFFER         = 1024
#END_IF

#IF_NOT_DEFINED NAV_MAX_CHARS
constant integer NAV_MAX_CHARS          = 50
#END_IF

constant integer CHR_SIZE	        = 8


/////////////////////////////////////////////////////////////
// Networking
/////////////////////////////////////////////////////////////
constant char NAV_BROADCAST_ADDRESS[]   = '255.255.255.255'
constant char NAV_LOOPBACK_ADDRESS[]    = '127.0.0.1'
constant integer NAV_FTP_PORT           = 21
constant integer NAV_SSH_PORT           = 22
constant integer NAV_TELNET_PORT        = 23
constant integer NAV_HTTP_PORT          = 80
constant integer NAV_HTTPS_PORT         = 443
constant integer NAV_ICSP_PORT          = 1319
constant integer NAV_ICSPS_PORT         = 1320


/////////////////////////////////////////////////////////////
// Logging
/////////////////////////////////////////////////////////////
constant integer NAV_LOG_CHUNK_SIZE             = 100


/////////////////////////////////////////////////////////////
// Timelines
/////////////////////////////////////////////////////////////
constant long TL_NAV_BLINKER	                = 255
constant long TL_NAV_FEEDBACK	                = 256


/////////////////////////////////////////////////////////////
// Events
/////////////////////////////////////////////////////////////
constant char NAV_EVENT_ONLINE[NAV_MAX_CHARS]       = 'online'
constant char NAV_EVENT_OFFLINE[NAV_MAX_CHARS]      = 'offline'
constant char NAV_EVENT_ONERROR[NAV_MAX_CHARS]      = 'onerror'
constant char NAV_EVENT_STRING[NAV_MAX_CHARS]       = 'string'
constant char NAV_EVENT_COMMAND[NAV_MAX_CHARS]      = 'command'
constant char NAV_EVENT_STANDBY[NAV_MAX_CHARS]      = 'standby'
constant char NAV_EVENT_AWAKE[NAV_MAX_CHARS]        = 'awake'


/////////////////////////////////////////////////////////////
// Guid
/////////////////////////////////////////////////////////////
constant char    NAV_GUID[NAV_MAX_CHARS] = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
constant char    NAV_GUID_HEX[NAV_MAX_CHARS] = '0123456789abcdef-'


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

////////////////////////////////////////////////////////////
// Key Value Pair
////////////////////////////////////////////////////////////
struct _NAVKeyValuePair {
    char Key[NAV_MAX_CHARS];
    char Value[NAV_MAX_BUFFER];
}

////////////////////////////////////////////////////////////
// Range
////////////////////////////////////////////////////////////
struct _NAVRange {
    integer Start
    integer End
}


////////////////////////////////////////////////////////////
// Point
////////////////////////////////////////////////////////////
struct _NAVPoint {
    float x
    float y
}


////////////////////////////////////////////////////////////
// Size
////////////////////////////////////////////////////////////
struct _NAVSize {
    float Width
    float Height
}


////////////////////////////////////////////////////////////
// Rect
////////////////////////////////////////////////////////////
struct _NAVRect {
    _NAVPoint Origin
    _NAVSize Size
}


////////////////////////////////////////////////////////////
// Contact
////////////////////////////////////////////////////////////
struct _NAVContact {
    char Name[NAV_MAX_CHARS]
    char Number[NAV_MAX_CHARS]
}


/////////////////////////////////////////////////////////////
// Credential
/////////////////////////////////////////////////////////////
struct _NAVCredential {
    char Username[NAV_MAX_CHARS]
    char Password[NAV_MAX_CHARS]
}


////////////////////////////////////////////////////////////
// Socket Connection
////////////////////////////////////////////////////////////
struct _NAVSocketConnection {
    char Address[NAV_MAX_CHARS]
    integer Port
    integer IsConnected
}


////////////////////////////////////////////////////////////
// Program
////////////////////////////////////////////////////////////
struct _NAVProgram {
    char Name[NAV_MAX_BUFFER]
    char File[NAV_MAX_BUFFER]
    char CompileDate[NAV_MAX_CHARS]
    char CompileTime[NAV_MAX_CHARS]
}


////////////////////////////////////////////////////////////
// Controller
////////////////////////////////////////////////////////////
struct _NAVController {
    ip_address_struct IP
    char SerialNumber[NAV_MAX_CHARS]
    char UniqueId[NAV_MAX_CHARS]
    char MacAddress[NAV_MAX_CHARS]
    _NAVProgram Program
}


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile _NAVController NAVController

volatile integer NAVBlinker = FALSE

volatile long NAVBlinkerTLArray[]	= { 500 }
volatile long NAVFeedbackTLArray[]	= { 200 }


/////////////////////////////////////////////////////////////
// Includes
/////////////////////////////////////////////////////////////
#include 'NAVFoundation.SnapiHelpers.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.SocketUtils.axi'

#IF_DEFINED USING_RMS
#include 'NAVFoundation.RmsUtils.axi'
#END_IF


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

/////////////////////////////////////////////////////////////
// NAVGetTimeStamp
/////////////////////////////////////////////////////////////
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


/////////////////////////////////////////////////////////////
// NAVLog
/////////////////////////////////////////////////////////////
define_function NAVLog(char log[]) {
    stack_var char buffer[NAV_MAX_BUFFER]

    buffer = log

    if (!length_array(buffer)) {
        buffer = "NAV_CR"
    }

    while (length_array(buffer)) {
        stack_var char logChunk[NAV_LOG_CHUNK_SIZE]

        logChunk = get_buffer_string(buffer, NAV_LOG_CHUNK_SIZE)

        send_string dvNAVMaster, "logChunk"
    }
}


define_function char[NAV_MAX_BUFFER] NAVConvertDPSToAscii(dev device) {
    return NAVStringSurroundWith(NAVDeviceToString(device), '[', ']')
}


define_function char[NAV_MAX_BUFFER] NAVDeviceToString(dev device) {
    return "itoa(device.number), ':', itoa(device.port), ':', itoa(device.system)"
}


define_function NAVStringToDevice(char value[], dev device) {
    stack_var char valueCopy[NAV_MAX_CHARS]

    device.number = atoi(value)
    device.port = 1
    device.system = 0

    if (!NAVContains(value, ':')) {
        return
    }

    valueCopy = value

    device.number = atoi(NAVStripRight(remove_string(valueCopy, ':', 1), 1))
    device.port = atoi(NAVStripRight(remove_string(valueCopy, ':', 1), 1))
    device.system = atoi(valueCopy)
}


define_function char NAVStringToBoolean(char value[]) {
    stack_var char valueCopy[NAV_MAX_CHARS]

    valueCopy = lower_string(value)

    if (valueCopy == 'true' || valueCopy == '1' || valueCopy == 'on') {
        return true
    }

    return false
}


define_function char[NAV_MAX_CHARS] NAVBooleanToString(char value) {
    if (value) {
        return 'true'
    }

    return 'false'
}


define_function char[NAV_MAX_CHARS] NAVGetUniqueId() {
    return NAVController.UniqueId
}


define_function char[NAV_MAX_CHARS] NAVGetMacAddressFromUniqueId(char uniqueId[]) {
    stack_var integer x
    stack_var char macAddress[6][2]
    stack_var char result[NAV_MAX_CHARS]

    result = ""

    if (!length_array(uniqueId)) {
        return result
    }

    for (x = 1; x <= length_array(uniqueId); x++) {
        macAddress[x] = format('%02X', uniqueId[x])
    }

    result = NAVArrayJoinString(macAddress, ':')

    return upper_string(result)
}


define_function char[NAV_MAX_CHARS] NAVGetMacAddress() {
    return NAVController.MacAddress
}


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


define_function NAVGetDeviceIPAddressInformation(dev device, ip_address_struct ip) {
    stack_var slong result

    result = get_ip_address(device, ip)

    if (result < 0) {
        NAVLog("'Error getting IP address information for device: ', NAVDeviceToString(device)")
    }
}


define_function NAVPrintProgramInformation(_NAVProgram program) {
    NAVLog("'**********************************************************'")
    NAVLog("'Program Info'")
    NAVLog("'**********************************************************'")
    NAVLog("'Program Name: ', program.Name")
    NAVLog("'Program File: ', program.File")
    NAVLog("'Compiled On: ', program.CompileDate, ' at ', program.CompileTime")
    NAVLog("'**********************************************************'")
}


define_function NAVFeedback(dev device, integer channels[], integer value) {
    stack_var integer x

    for(x = 1; x <= length_array(channels); x++) {
        [device, channels[x]] = (value == x)
    }
}


define_function NAVFeedbackWithDevArray(dev device[], integer channels[], integer value) {
    stack_var integer x

    for(x = 1; x <= length_array(channels); x++) {
        [device, channels[x]] = (value == x)
    }
}


define_function NAVFeedbackWithValueArray(dev device, integer channels[], integer value[]) {
    stack_var integer x

    for(x = 1; x <= length_array(channels); x++) {
        [device, channels[x]] = (value[x])
    }
}


define_function NAVCommand(dev device, char value[]) {
    send_command device, value
}


define_function NAVCommandArray(dev device[], char value[]) {
    send_command device, value
}


define_function NAVTimelineStart(long id, long times[], long relative, long mode) {
    if (timeline_active(id)) {
        return
    }

    timeline_create(id, times, length_array(times), relative, mode)
}


define_function NAVTimelineReload(long id, long times[]) {
    if (!timeline_active(id)) {
        return
    }

    timeline_reload(id, times, length_array(times))
}


define_function NAVTimelineStop(long id) {
    if (!timeline_active(id)) {
        return
    }

    timeline_kill(id)
}


define_function NAVSetControllerProgramInformation(_NAVProgram program) {
    program.Name = __NAME__
    program.File = __FILE__
    program.CompileDate = __LDATE__
    program.CompileTime = __TIME__
}


define_function NAVSetControllerInformation(_NAVController controller) {
    NAVGetDeviceIPAddressInformation(dvNAVMaster, controller.IP)

    controller.SerialNumber = NAVGetDeviceSerialNumber(dvNAVMaster)

    controller.UniqueId = get_unique_id()
    controller.MacAddress = NAVGetMacAddressFromUniqueId(controller.UniqueId)

    NAVSetControllerProgramInformation(controller.Program)
}


define_function char NAVByteIsHumanReadable(char byte) {
    return (byte > $1F && byte < $7F);
}


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

        if(NAVByteIsHumanReadable(byte)) {
            result = "result, byte"
        }
        else {
            hex = "'$', format('%02X', byte)"
            result = "result, hex"
        }
    }

    return result
}


define_function char[NAV_MAX_CHARS] NAVGetNewGuid() {
    stack_var integer x
    stack_var integer length
    stack_var integer random
    stack_var char byte
    stack_var char result[NAV_MAX_CHARS]

    length = length_array(NAV_GUID)

    for (x = 1; x <= length; x++) {
        random = (random_number(65535) % 16) + 1

        switch (NAV_GUID[x]) {
            case 'x': { byte = NAV_GUID_HEX[random] }
            case 'y': { byte = NAV_GUID_HEX[random] & $03 | $08 }
            case '-': { byte = '-' }
            case '4': { byte = '4' }
        }

        result = "result, byte"
    }

    return result
}


define_function integer NAVZeroBase(integer value) {
    return value - 1
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START {
    NAVSetControllerInformation(NAVController)

    NAVTimelineStart(TL_NAV_BLINKER, NAVBlinkerTLArray, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
    NAVTimelineStart(TL_NAV_FEEDBACK, NAVFeedbackTLArray, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)

    NAVLog("__NAME__, ' : ', 'Program Started'")
    amx_log(AMX_INFO, "__NAME__, ' : ', 'Program Started'")
}


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

timeline_event[TL_NAV_BLINKER] {
    NAVBlinker = !NAVBlinker
}


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
#END_IF // __NAV_FOUNDATION_CORE__
