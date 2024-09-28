PROGRAM_NAME='NAVFoundation.Core'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CORE__
#DEFINE __NAV_FOUNDATION_CORE__ 'NAVFoundation.Core'


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
constant integer NAV_EOT                = 4
constant integer NAV_ENQ                = 5
constant integer NAV_ACK                = 6
constant integer NAV_BEL                = 7
constant integer NAV_BS                 = 8
constant integer NAV_TAB                = 9
constant integer NAV_LF                 = 10
constant integer NAV_VT                 = 11
constant integer NAV_FF                 = 12
constant integer NAV_CR                 = 13
constant integer NAV_SO                 = 14
constant integer NAV_SI                 = 15
constant integer NAV_DLE                = 16
constant integer NAV_DC1                = 17
constant integer NAV_DC2                = 18
constant integer NAV_DC3                = 19
constant integer NAV_DC4                = 20
constant integer NAV_NAK                = 21
constant integer NAV_SYN                = 22
constant integer NAV_ETB                = 23
constant integer NAV_CAN                = 24
constant integer NAV_EM                 = 25
constant integer NAV_SUB                = 26
constant integer NAV_ESC                = 27
constant integer NAV_FS                 = 28
constant integer NAV_GS                 = 29
constant integer NAV_RS                 = 30
constant integer NAV_US                 = 31

constant char NAV_NULL_CHAR             = $00
constant char NAV_SOH_CHAR              = $01
constant char NAV_STX_CHAR              = $02
constant char NAV_ETX_CHAR              = $03
constant char NAV_EOT_CHAR              = $04
constant char NAV_ENQ_CHAR              = $05
constant char NAV_ACK_CHAR              = $06
constant char NAV_BEL_CHAR              = $07
constant char NAV_BS_CHAR               = $08
constant char NAV_TAB_CHAR              = $09
constant char NAV_LF_CHAR               = $0A
constant char NAV_VT_CHAR               = $0B
constant char NAV_FF_CHAR               = $0C
constant char NAV_CR_CHAR               = $0D
constant char NAV_SO_CHAR               = $0E
constant char NAV_SI_CHAR               = $0F
constant char NAV_DLE_CHAR              = $10
constant char NAV_DC1_CHAR              = $11
constant char NAV_DC2_CHAR              = $12
constant char NAV_DC3_CHAR              = $13
constant char NAV_DC4_CHAR              = $14
constant char NAV_NAK_CHAR              = $15
constant char NAV_SYN_CHAR              = $16
constant char NAV_ETB_CHAR              = $17
constant char NAV_CAN_CHAR              = $18
constant char NAV_EM_CHAR               = $19
constant char NAV_SUB_CHAR              = $1A
constant char NAV_ESC_CHAR              = $1B
constant char NAV_FS_CHAR               = $1C
constant char NAV_GS_CHAR               = $1D
constant char NAV_RS_CHAR               = $1E
constant char NAV_US_CHAR               = $1F

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

constant char NAV_TELNET_COMMAND_SE     = $F0
constant char NAV_TELNET_COMMAND_NOP    = $F1
constant char NAV_TELNET_COMMAND_DM     = $F2
constant char NAV_TELNET_COMMAND_BRK    = $F3
constant char NAV_TELNET_COMMAND_IP     = $F4
constant char NAV_TELNET_COMMAND_AO     = $F5
constant char NAV_TELNET_COMMAND_AYT    = $F6
constant char NAV_TELNET_COMMAND_EC     = $F7
constant char NAV_TELNET_COMMAND_EL     = $F8
constant char NAV_TELNET_COMMAND_GA     = $F9
constant char NAV_TELNET_COMMAND_SB     = $FA
constant char NAV_TELNET_COMMAND_WILL   = $FB
constant char NAV_TELNET_COMMAND_WONT   = $FC
constant char NAV_TELNET_COMMAND_DO     = $FD
constant char NAV_TELNET_COMMAND_DONT   = $FE
constant char NAV_TELNET_COMMAND_IAC    = $FF

constant char NAV_TELNET_OPTION_BINARY_TRANSMISSION = $00
constant char NAV_TELNET_OPTION_ECHO                = $01
constant char NAV_TELNET_OPTION_RECONNECTION        = $02
constant char NAV_TELNET_OPTION_SGA                 = $03
constant char NAV_TELNET_OPTION_AMSN                = $04
constant char NAV_TELNET_OPTION_STATUS              = $05
constant char NAV_TELNET_OPTION_TIMING_MARK         = $06
constant char NAV_TELNET_OPTION_RCTE                = $07
constant char NAV_TELNET_OPTION_OLW                 = $08
constant char NAV_TELNET_OPTION_OPS                 = $09
constant char NAV_TELNET_OPTION_OCRD                = $0A
constant char NAV_TELNET_OPTION_OHTS                = $0B
constant char NAV_TELNET_OPTION_OHTD                = $0C
constant char NAV_TELNET_OPTION_OFFD                = $0D
constant char NAV_TELNET_OPTION_OVTS                = $0E
constant char NAV_TELNET_OPTION_OVTD                = $0F
constant char NAV_TELNET_OPTION_OVTR                = $10
constant char NAV_TELNET_OPTION_EXTENDED_ASCII      = $11
constant char NAV_TELNET_OPTION_LOGOUT              = $12
constant char NAV_TELNET_OPTION_BYTE_MACRO          = $13
constant char NAV_TELNET_OPTION_DATA_ENTRY_TERMINAL = $14
constant char NAV_TELNET_OPTION_SUPDUP              = $15
constant char NAV_TELNET_OPTION_SUPDUP_OUTPUT       = $16
constant char NAV_TELNET_OPTION_SEND_LOCATION       = $17
constant char NAV_TELNET_OPTION_TERMINAL_TYPE       = $18
constant char NAV_TELNET_OPTION_END_OF_RECORD       = $19
constant char NAV_TELNET_OPTION_TACACS_USER_ID      = $1A
constant char NAV_TELNET_OPTION_OUTPUT_MARKING      = $1B
constant char NAV_TELNET_OPTION_TERMINAL_LOCATION   = $1C
constant char NAV_TELNET_OPTION_3270_REGIME         = $1D
constant char NAV_TELNET_OPTION_X3_PAD              = $1E
constant char NAV_TELNET_OPTION_NAWS                = $1F
constant char NAV_TELNET_OPTION_TSPEED              = $20
constant char NAV_TELNET_OPTION_RFLOW               = $21
constant char NAV_TELNET_OPTION_LINEMODE            = $22
constant char NAV_TELNET_OPTION_XDISPLOC            = $23
constant char NAV_TELNET_OPTION_ENVIRON             = $24
constant char NAV_TELNET_OPTION_AUTH                = $25
constant char NAV_TELNET_OPTION_ENCRYPT             = $26
constant char NAV_TELNET_OPTION_NEWENV              = $27
constant char NAV_TELNET_OPTION_EXOPL               = $FF


/////////////////////////////////////////////////////////////
// Logging
/////////////////////////////////////////////////////////////
constant integer NAV_LOG_CHUNK_SIZE             = 100


/////////////////////////////////////////////////////////////
// Timelines
/////////////////////////////////////////////////////////////
constant long TL_NAV_BLINKER	                = 255
constant long TL_NAV_FEEDBACK	                = 256

constant long TL_NAV_BLINKER_INTERVAL[]	    = { 500 }
constant long TL_NAV_FEEDBACK_INTERVAL[]	= { 200 }


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


/////////////////////////////////////////////////////////////
// Variable to Xml Errors
/////////////////////////////////////////////////////////////
constant sinteger NAV_VAR_TO_XML_ERROR_XML_DECODE_DATA_TYPE_MISMATCH        = 3
constant sinteger NAV_VAR_TO_XML_ERROR_XML_DECODE_DATA_TOO_SMALL            = 2
constant sinteger NAV_VAR_TO_XML_ERROR_STRUCTURE_TOO_SMALL                  = 1
constant sinteger NAV_VAR_TO_XML_ERROR_DECODE_VARIABLE_TYPE_MISMATCH        = -1
constant sinteger NAV_VAR_TO_XML_ERROR_DECODE_DATA_TOO_SMALL                = -2
constant sinteger NAV_VAR_TO_XML_ERROR_OUTPUT_CHARACTER_BUFFER_TOO_SMALL    = -3


/////////////////////////////////////////////////////////////
// Variable to String Errors
/////////////////////////////////////////////////////////////
constant sinteger NAV_VAR_TO_STRING_UNRECOGNIZED_TYPE   = -1
constant sinteger NAV_VAR_TO_STRING_BUFFER_TOO_SMALL    = -2


/////////////////////////////////////////////////////////////
// String to Variable Errors
/////////////////////////////////////////////////////////////
constant sinteger NAV_STRING_TO_VAR_ERROR_DECODE_DATA_TOO_SMALL_1           = 2
constant sinteger NAV_STRING_TO_VAR_ERROR_STRUCTURE_TOO_SMALL               = 1
constant sinteger NAV_STRING_TO_VAR_ERROR_DECODE_VARIABLE_TYPE_MISMATCH     = -1
constant sinteger NAV_STRING_TO_VAR_ERROR_DECODE_DATA_TOO_SMALL_2           = -2


/////////////////////////////////////////////////////////////
// Common States
/////////////////////////////////////////////////////////////
constant integer NAV_POWER_STATE_ON             = 1
constant integer NAV_POWER_STATE_OFF            = 2
constant integer NAV_POWER_STATE_LAMP_WARMING   = 3
constant integer NAV_POWER_STATE_LAMP_COOLING   = 4
constant integer NAV_POWER_STATE_UNKNOWN        = 5

constant integer NAV_MUTE_STATE_ON          = 1
constant integer NAV_MUTE_STATE_OFF         = 2
constant integer NAV_MUTE_STATE_UNKNOWN     = 3


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

////////////////////////////////////////////////////////////
// Key Value Pairs
////////////////////////////////////////////////////////////
struct _NAVKeyValuePair {
    char Key[NAV_MAX_CHARS];
    char Value[NAV_MAX_BUFFER];
}


struct _NAVKeyStringValuePair {
    char Key[256];
    char Value[256];
}


struct _NAVKeyIntegerValuePair {
    char Key[256];
    integer Value;
}


struct _NAVKeyLongValuePair {
    long Value;
    char Key[256];
}


struct _NAVKeyDoubleValuePair {
    double Value;
    char Key[256];
}


struct _NAVKeyFloatValuePair {
    float Value;
    char Key[256];
}


struct _NAVKeyBooleanValuePair {
    char Key[256];
    char Value;
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


////////////////////////////////////////////////////////////
// Boolean State
////////////////////////////////////////////////////////////
struct _NAVStateBoolean {
    integer Initialized
    char Required
    char Actual
}


////////////////////////////////////////////////////////////
// Integer State
////////////////////////////////////////////////////////////
struct _NAVStateInteger {
    integer Initialized
    integer Required
    integer Actual
}


////////////////////////////////////////////////////////////
// Signed Integer State
////////////////////////////////////////////////////////////
struct _NAVStateSignedInteger {
    integer Initialized
    sinteger Required
    sinteger Actual
}


////////////////////////////////////////////////////////////
// Long State
////////////////////////////////////////////////////////////
struct _NAVStateLong {
    long Required
    long Actual
    integer Initialized
}


////////////////////////////////////////////////////////////
// Signed Long State
////////////////////////////////////////////////////////////
struct _NAVStateSignedLong {
    slong Required
    slong Actual
    integer Initialized
}


////////////////////////////////////////////////////////////
// Double State
////////////////////////////////////////////////////////////
struct _NAVStateDouble {
    double Required
    double Actual
    integer Initialized
}


////////////////////////////////////////////////////////////
// Float State
////////////////////////////////////////////////////////////
struct _NAVStateFloat {
    float Required
    float Actual
    integer Initialized
}


////////////////////////////////////////////////////////////
// String State
////////////////////////////////////////////////////////////
struct _NAVStateString {
    integer Initialized
    char Required[NAV_MAX_BUFFER]
    char Actual[NAV_MAX_BUFFER]
}


////////////////////////////////////////////////////////////
// Volume
////////////////////////////////////////////////////////////
struct _NAVVolume {
    _NAVStateSignedInteger Level
    _NAVStateInteger Mute
}


////////////////////////////////////////////////////////////
// Display
////////////////////////////////////////////////////////////
struct _NAVDisplay {
    _NAVDevice Device
    _NAVStateInteger PowerState
    _NAVStateInteger Input
    _NAVStateInteger VideoMute
    _NAVStateInteger Aspect
    _NAVVolume Volume
    char AutoAdjustRequired
}


////////////////////////////////////////////////////////////
// Projector
////////////////////////////////////////////////////////////
struct _NAVProjector {
    _NAVDisplay Display
    _NAVStateInteger LampHours[2]
    _NAVStateInteger LampStatus[2]
    _NAVStateInteger FilterHours[2]
    _NAVStateInteger FilterStatus[2]
    _NAVStateFloat Temperature
    _NAVStateInteger Freeze
}


////////////////////////////////////////////////////////////
// Switcher
////////////////////////////////////////////////////////////
struct _NAVSwitcher {
    _NAVDevice Device
    _NAVVolume Volume
    // integer OutputRequired[3][128]
    // integer OutputActual[3][128]
    _NAVStateInteger Output[3][128]
    integer PendingRequired[3][128]
    integer NumberOfInputs
    char InputHasSignal[128]
    char Pending
}


////////////////////////////////////////////////////////////
// RxBuffer
////////////////////////////////////////////////////////////
struct _NAVRxBuffer {
    char Data[NAV_MAX_BUFFER]
    char Semaphore
}


/////////////////////////////////////////////////////////////
// Disc Device
/////////////////////////////////////////////////////////////
struct NAVDiscDevice {
    _NAVDevice Device
    _NAVStateInteger PowerState
    _NAVStateInteger TransportState
    _NAVStateInteger DiscType
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
    integer Socket
    integer Port
    integer IsConnected
    integer IsAuthenticated
    char Address[NAV_MAX_CHARS]
}


////////////////////////////////////////////////////////////
// Device
////////////////////////////////////////////////////////////
struct _NAVDevice {
    _NAVSocketConnection SocketConnection
    integer IsOnline
    integer IsCommunicating
    integer IsInitialized
}


////////////////////////////////////////////////////////////
// Module
////////////////////////////////////////////////////////////
struct _NAVModule {
    _NAVDevice Device
    _NAVRxBuffer RxBuffer
    integer Enabled
    integer CommandBusy
    dev VirtualDevice[10]
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
    dev_info_struct Information
    dev_info_struct Device
    _NAVProgram Program
    char SerialNumber[NAV_MAX_CHARS]
    char UniqueId[6]
    char MacAddress[NAV_MAX_CHARS]
}


/////////////////////////////////////////////////////////////
// Console
/////////////////////////////////////////////////////////////
struct _NAVConsole {
    _NAVSocketConnection SocketConnection
    slong ErrorCode
    dev Socket
    char Semaphore
    char RxBuffer[NAV_MAX_BUFFER]
}


/////////////////////////////////////////////////////////////
// System
/////////////////////////////////////////////////////////////
struct _NAVSystem {
    _NAVController Controller
    long Feedback[1]
    long Blinker[1]
}


/////////////////////////////////////////////////////////////
// Serial Port Settings
/////////////////////////////////////////////////////////////
struct _NAVSerialPortSettings {
    char Speed[6]
    char DataBits[1]
    char StopBits[1]
    char Parity[1]
    char Rs485[15]
}


/////////////////////////////////////////////////////////////
// Data Event Args
/////////////////////////////////////////////////////////////
struct _NAVDataEventArgs {
    tdata Data
}


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile integer NAVBlinker = false


/////////////////////////////////////////////////////////////
// Includes
/////////////////////////////////////////////////////////////
#include 'NAVFoundation.ErrorLogUtils.h.axi'
#include 'NAVFoundation.SnapiHelpers.h.axi'
#include 'NAVFoundation.StringUtils.h.axi'

#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.SnapiHelpers.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.TimelineUtils.axi'

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

        #IF_DEFINED __NAV_FOUNDATION_DEBUGCONSOLE__
        NAVDebugConsoleLog(logChunk)
        #END_IF
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


define_function char[NAV_MAX_CHARS] NAVBooleanToOnOffString(char value) {
    if (value) {
        return 'on'
    }

    return 'off'
}


// Deprecated
define_function char[NAV_MAX_CHARS] NAVSITOA(sinteger value) {
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_CORE__,
                                'NAVSITOA()',
                                'Use of deprecated function NAVSITOA')

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_CORE__,
                                'NAVSITOA()',
                                'Use NAVSignedIntegerToAscii instead')

    return "itoa(value)"
}


define_function char[NAV_MAX_CHARS] NAVSignedIntegerToAscii(sinteger value) {
    return "itoa(value)"
}


// Deprecated
define_function char[NAV_MAX_CHARS] NAVLTOA(long value) {
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_CORE__,
                                'NAVLTOA()',
                                'Use of deprecated function NAVLTOA')

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_CORE__,
                                'NAVLTOA()',
                                'Use NAVLongToAscii instead')

    return "itoa(value)"
}


define_function char[NAV_MAX_CHARS] NAVLongToAscii(long value) {
    return "itoa(value)"
}


// Deprecated
define_function char[NAV_MAX_CHARS] NAVDTOA(double value) {
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_CORE__,
                                'NAVDTOA()',
                                'Use of deprecated function NAVDTOA')

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_CORE__,
                                'NAVDTOA()',
                                'Use NAVDoubleToAscii instead')

    return "itoa(value)"
}


define_function char[NAV_MAX_CHARS] NAVDoubleToAscii(double value) {
    return "itoa(value)"
}


define_function char[NAV_MAX_CHARS] NAVGetUniqueId(_NAVController controller) {
    return controller.UniqueId
}


define_function char[NAV_MAX_CHARS] NAVGetMacAddressFromUniqueId(char uniqueId[]) {
    stack_var integer x
    stack_var char macAddress[6][2]
    stack_var char result[NAV_MAX_CHARS]

    result = ""

    if (!length_array(uniqueId)) {
        return result
    }

    set_length_array(macAddress, max_length_array(macAddress))

    for (x = 1; x <= length_array(uniqueId); x++) {
        macAddress[x] = format('%02X', uniqueId[x])
    }

    result = NAVArrayJoinString(macAddress, ':')

    return upper_string(result)
}


define_function char[NAV_MAX_CHARS] NAVGetMacAddress(_NAVController controller) {
    return controller.MacAddress
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


define_function NAVSendLevel(dev device, integer level, integer value) {
    send_level device, level, value
}


define_function NAVSendLevelArray(dev device[], integer level, integer value) {
    stack_var integer x

    for (x = 1; x <= length_array(device); x++) {
        send_level device[x], level, value
    }
}


define_function NAVGetControllerProgramInformation(_NAVProgram program) {
    program.Name = __NAME__
    program.File = __FILE__
    program.CompileDate = __LDATE__
    program.CompileTime = __TIME__
}


define_function NAVGetControllerInformation(_NAVController controller) {
    device_info(0:1:0, controller.Information)
    device_info(5001:1:0, controller.Device)
    NAVGetDeviceIPAddressInformation(0:1:0, controller.IP)

    controller.SerialNumber = NAVGetDeviceSerialNumber(0:1:0)

    controller.UniqueId = get_unique_id()
    controller.MacAddress = NAVGetMacAddressFromUniqueId(controller.UniqueId)

    NAVGetControllerProgramInformation(controller.Program)
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
        'Copyright (c) 2010-2024, Norgate AV Services Limited', NAV_CR, NAV_LF,
        'https://github.com/Norgate-AV/NAVFoundation.Amx', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '=============================================================',
        NAV_CR, NAV_LF
    "
}


define_function NAVPrintBanner(_NAVController controller) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "' _   _                       _          ___     __'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'|  \| |/ _ \| ''__/ _` |/ _` | __/ _ \ / _ \ \ / /'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'                 |___/'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'MIT License'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Copyright (c) 2010-2024, Norgate AV Services Limited'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'https://github.com/Norgate-AV/NAVFoundation.Amx'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'============================================================='")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Program Info:'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Name: ', controller.Program.Name")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'File: ', controller.Program.File")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Compiled On: ', controller.Program.CompileDate, ' at ', controller.Program.CompileTime")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'============================================================='")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Master Info:'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Device Id: 0'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Manufacturer: ', controller.Information.Manufacturer_String")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Model: ', controller.Information.Device_Id_String")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Version: ', controller.Information.Version")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Firmware Id: ', itoa(controller.Information.Firmware_Id)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Serial Number: ', NAVTrimString(controller.SerialNumber)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Unique Id: ', NAVFormatHex(controller.UniqueId)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'============================================================='")

    if (controller.Device.Device_Id) {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "")
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Device Info:'")
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Device Id: 5001'")
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Manufacturer: ', controller.Device.Manufacturer_String")
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Model: ', controller.Device.Device_Id_String")
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Version: ', controller.Device.Version")
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Firmware Id: ', itoa(controller.Device.Firmware_Id)")
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "")
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'============================================================='")
    }

    NAVErrorLog(NAV_LOG_LEVEL_INFO, "")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Network Info:'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Mac Address: ', controller.MacAddress")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'IP Address: ', controller.IP.IPAddress")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Subnet Mask: ', controller.IP.SubnetMask")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Gateway: ', controller.IP.Gateway")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Hostname: ', controller.IP.Hostname")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'DHCP Enabled: ', NAVBooleanToString(controller.IP.Flags)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'============================================================='")
}


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


define_function char NAVDeviceIsOnline(dev device) {
    return device_id(device) != 0
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START {
    #IF_DEFINED __MAIN__
    stack_var _NAVController controller

    set_log_level(NAV_LOG_LEVEL_DEBUG)

    NAVGetControllerInformation(controller)
    NAVPrintBanner(controller)

    NAVErrorLog(NAV_LOG_LEVEL_INFO, "__FILE__, ' : ', 'Program Started'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'============================================================='")
    #END_IF

    NAVTimelineStart(TL_NAV_BLINKER, TL_NAV_BLINKER_INTERVAL, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
    NAVTimelineStart(TL_NAV_FEEDBACK, TL_NAV_FEEDBACK_INTERVAL, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
}


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

#IF_DEFINED __MAIN__
data_event[dvNAVMaster] {
    online: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'Master Device ', NAVStringSurroundWith(NAVDeviceToString(data.device), '[', ']'), ' Online'")
    }
    offline: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'Master Device ', NAVStringSurroundWith(NAVDeviceToString(data.device), '[', ']'), ' Offline'")
    }
    awake: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'Master Device ', NAVStringSurroundWith(NAVDeviceToString(data.device), '[', ']'), ' Awake'")
    }
    standby: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'Master Device ', NAVStringSurroundWith(NAVDeviceToString(data.device), '[', ']'), ' Standby'")
    }
    string: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'String from Master Device ', NAVStringSurroundWith(NAVDeviceToString(data.device), '[', ']'), '-', NAVStringSurroundWith(data.text, '[', ']')")
    }
    command: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'Command from Master Device ', NAVStringSurroundWith(NAVDeviceToString(data.device), '[', ']'), '-', NAVStringSurroundWith(data.text, '[', ']')")
    }
    onerror: {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                    "'Master Device ', NAVStringSurroundWith(NAVDeviceToString(data.device), '[', ']'), ' OnError: ', data.text")
    }
}
#END_IF


timeline_event[TL_NAV_BLINKER] {
    NAVBlinker = !NAVBlinker
}


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

#END_IF // __NAV_FOUNDATION_CORE__
