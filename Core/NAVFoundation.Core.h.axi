PROGRAM_NAME='NAVFoundation.Core.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CORE_H__
#DEFINE __NAV_FOUNDATION_CORE_H__ 'NAVFoundation.Core.h'


DEFINE_CONSTANT

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


DEFINE_TYPE

/**
 * @struct _NAVKeyValuePair
 * @description Generic key-value pair structure for storing string data.
 * @property {char[]} Key - The identifier key for the pair (limited to NAV_MAX_CHARS size)
 * @property {char[]} Value - The value associated with the key (limited to NAV_MAX_BUFFER size)
 */
struct _NAVKeyValuePair {
    char Key[NAV_MAX_CHARS];
    char Value[NAV_MAX_BUFFER];
}


/**
 * @struct _NAVKeyStringValuePair
 * @description Key-value pair structure specifically for string values.
 * @property {char[]} Key - The identifier key for the pair
 * @property {char[]} Value - The string value associated with the key
 */
struct _NAVKeyStringValuePair {
    char Key[256];
    char Value[256];
}


/**
 * @struct _NAVKeyIntegerValuePair
 * @description Key-value pair structure for integer values.
 * @property {char[]} Key - The identifier key for the pair
 * @property {integer} Value - The integer value associated with the key
 */
struct _NAVKeyIntegerValuePair {
    char Key[256];
    integer Value;
}


/**
 * @struct _NAVKeyLongValuePair
 * @description Key-value pair structure for long integer values.
 * @property {long} Value - The long integer value associated with the key
 * @property {char[]} Key - The identifier key for the pair
 */
struct _NAVKeyLongValuePair {
    long Value;
    char Key[256];
}


/**
 * @struct _NAVKeyDoubleValuePair
 * @description Key-value pair structure for double-precision floating-point values.
 * @property {double} Value - The double value associated with the key
 * @property {char[]} Key - The identifier key for the pair
 */
struct _NAVKeyDoubleValuePair {
    double Value;
    char Key[256];
}


/**
 * @struct _NAVKeyFloatValuePair
 * @description Key-value pair structure for single-precision floating-point values.
 * @property {float} Value - The float value associated with the key
 * @property {char[]} Key - The identifier key for the pair
 */
struct _NAVKeyFloatValuePair {
    float Value;
    char Key[256];
}


/**
 * @struct _NAVKeyBooleanValuePair
 * @description Key-value pair structure for boolean values.
 * @property {char[]} Key - The identifier key for the pair
 * @property {char} Value - The boolean value associated with the key (0=false, non-zero=true)
 */
struct _NAVKeyBooleanValuePair {
    char Key[256];
    char Value;
}


/**
 * @struct _NAVRange
 * @description Represents a range of integer values from Start to End (inclusive).
 * @property {integer} Start - The beginning value of the range
 * @property {integer} End - The ending value of the range
 */
struct _NAVRange {
    integer Start
    integer End
}


/**
 * @struct _NAVPoint
 * @description Represents a coordinate point in 2D space.
 * @property {float} x - The horizontal position coordinate
 * @property {float} y - The vertical position coordinate
 */
struct _NAVPoint {
    float x
    float y
}


/**
 * @struct _NAVSize
 * @description Represents dimensions with width and height.
 * @property {float} Width - The horizontal measurement
 * @property {float} Height - The vertical measurement
 */
struct _NAVSize {
    float Width
    float Height
}


/**
 * @struct _NAVRect
 * @description Represents a rectangle defined by origin point and size.
 * @property {_NAVPoint} Origin - The top-left corner coordinate of the rectangle
 * @property {_NAVSize} Size - The width and height dimensions of the rectangle
 */
struct _NAVRect {
    _NAVPoint Origin
    _NAVSize Size
}


/**
 * @struct _NAVContact
 * @description Represents contact information with name and phone number.
 * @property {char[]} Name - The contact's name
 * @property {char[]} Number - The contact's phone number
 */
struct _NAVContact {
    char Name[NAV_MAX_CHARS]
    char Number[NAV_MAX_CHARS]
}


/**
 * @struct _NAVStateBoolean
 * @description Tracks boolean state with required and actual values plus initialization status.
 * @property {integer} Initialized - Flag indicating if the state has been initialized (0=no, non-zero=yes)
 * @property {char} Required - The desired boolean state (0=false, non-zero=true)
 * @property {char} Actual - The current boolean state (0=false, non-zero=true)
 */
struct _NAVStateBoolean {
    integer Initialized
    char Required
    char Actual
}


/**
 * @struct _NAVStateInteger
 * @description Tracks integer state with required and actual values plus initialization status.
 * @property {integer} Initialized - Flag indicating if the state has been initialized (0=no, non-zero=yes)
 * @property {integer} Required - The desired integer state value
 * @property {integer} Actual - The current integer state value
 */
struct _NAVStateInteger {
    integer Initialized
    integer Required
    integer Actual
}


/**
 * @struct _NAVStateSignedInteger
 * @description Tracks signed integer state with required and actual values plus initialization status.
 * @property {integer} Initialized - Flag indicating if the state has been initialized (0=no, non-zero=yes)
 * @property {sinteger} Required - The desired signed integer state value
 * @property {sinteger} Actual - The current signed integer state value
 */
struct _NAVStateSignedInteger {
    integer Initialized
    sinteger Required
    sinteger Actual
}


/**
 * @struct _NAVStateLong
 * @description Tracks long integer state with required and actual values plus initialization status.
 * @property {long} Required - The desired long integer state value
 * @property {long} Actual - The current long integer state value
 * @property {integer} Initialized - Flag indicating if the state has been initialized (0=no, non-zero=yes)
 */
struct _NAVStateLong {
    long Required
    long Actual
    integer Initialized
}


/**
 * @struct _NAVStateSignedLong
 * @description Tracks signed long integer state with required and actual values plus initialization status.
 * @property {slong} Required - The desired signed long integer state value
 * @property {slong} Actual - The current signed long integer state value
 * @property {integer} Initialized - Flag indicating if the state has been initialized (0=no, non-zero=yes)
 */
struct _NAVStateSignedLong {
    slong Required
    slong Actual
    integer Initialized
}


/**
 * @struct _NAVStateDouble
 * @description Tracks double precision floating-point state with required and actual values plus initialization status.
 * @property {double} Required - The desired double state value
 * @property {double} Actual - The current double state value
 * @property {integer} Initialized - Flag indicating if the state has been initialized (0=no, non-zero=yes)
 */
struct _NAVStateDouble {
    double Required
    double Actual
    integer Initialized
}


/**
 * @struct _NAVStateFloat
 * @description Tracks single precision floating-point state with required and actual values plus initialization status.
 * @property {float} Required - The desired float state value
 * @property {float} Actual - The current float state value
 * @property {integer} Initialized - Flag indicating if the state has been initialized (0=no, non-zero=yes)
 */
struct _NAVStateFloat {
    float Required
    float Actual
    integer Initialized
}


/**
 * @struct _NAVStateString
 * @description Tracks string state with required and actual values plus initialization status.
 * @property {integer} Initialized - Flag indicating if the state has been initialized (0=no, non-zero=yes)
 * @property {char[]} Required - The desired string state value
 * @property {char[]} Actual - The current string state value
 */
struct _NAVStateString {
    integer Initialized
    char Required[NAV_MAX_BUFFER]
    char Actual[NAV_MAX_BUFFER]
}


/**
 * @struct _NAVVolume
 * @description Represents volume control with level and mute states.
 * @property {_NAVStateSignedInteger} Level - The volume level state (-100 to 100 typically)
 * @property {_NAVStateInteger} Mute - The mute state (typically using NAV_MUTE_STATE_* constants)
 */
struct _NAVVolume {
    _NAVStateSignedInteger Level
    _NAVStateInteger Mute
}


/**
 * @struct _NAVDisplay
 * @description Represents a display device with its various states and properties.
 * @property {_NAVDevice} Device - The base device information and connection details
 * @property {_NAVStateInteger} PowerState - The power state (typically using NAV_POWER_STATE_* constants)
 * @property {_NAVStateInteger} Input - The selected input source
 * @property {_NAVStateInteger} VideoMute - The video mute state
 * @property {_NAVStateInteger} Aspect - The aspect ratio setting
 * @property {_NAVVolume} Volume - The audio volume and mute settings
 * @property {char} AutoAdjustRequired - Flag indicating if auto-adjustment is needed
 */
struct _NAVDisplay {
    _NAVDevice Device
    _NAVStateInteger PowerState
    _NAVStateInteger Input
    _NAVStateInteger VideoMute
    _NAVStateInteger Aspect
    _NAVVolume Volume
    char AutoAdjustRequired
}


/**
 * @struct _NAVProjector
 * @description Extends display with projector-specific properties like lamp and filter status.
 * @property {_NAVDisplay} Display - The base display properties
 * @property {_NAVStateInteger[]} LampHours - Array of lamp hour counters
 * @property {_NAVStateInteger[]} LampStatus - Array of lamp status indicators
 * @property {_NAVStateInteger[]} FilterHours - Array of filter hour counters
 * @property {_NAVStateInteger[]} FilterStatus - Array of filter status indicators
 * @property {_NAVStateFloat} Temperature - The projector temperature
 * @property {_NAVStateInteger} Freeze - The image freeze state
 */
struct _NAVProjector {
    _NAVDisplay Display
    _NAVStateInteger LampHours[2]
    _NAVStateInteger LampStatus[2]
    _NAVStateInteger FilterHours[2]
    _NAVStateInteger FilterStatus[2]
    _NAVStateFloat Temperature
    _NAVStateInteger Freeze
}


/**
 * @struct _NAVSwitcher
 * @description Represents an audio/video switcher with input/output management.
 * @property {_NAVDevice} Device - The base device information and connection details
 * @property {_NAVVolume} Volume - The audio volume and mute settings
 * @property {_NAVStateInteger[][][]} Output - 3D array of output states [type][output number]
 * @property {integer[][]} PendingRequired - Array tracking pending output changes
 * @property {integer} NumberOfInputs - The number of available inputs on the switcher
 * @property {char[]} InputHasSignal - Array indicating which inputs have active signals
 * @property {char} Pending - Flag indicating if there are pending changes
 */
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


/**
 * @struct _NAVRxBuffer
 * @description Buffer for receiving data with thread protection.
 * @property {char[]} Data - The buffer holding received data
 * @property {char} Semaphore - Thread protection flag to prevent concurrent access
 */
struct _NAVRxBuffer {
    char Data[NAV_MAX_BUFFER]
    char Semaphore
}


/**
 * @struct NAVDiscDevice
 * @description Represents a disc player (DVD, Blu-ray, etc.) with its states.
 * @property {_NAVDevice} Device - The base device information and connection details
 * @property {_NAVStateInteger} PowerState - The power state (typically using NAV_POWER_STATE_* constants)
 * @property {_NAVStateInteger} TransportState - The playback transport state (play, pause, etc.)
 * @property {_NAVStateInteger} DiscType - The type of disc that is loaded
 */
struct NAVDiscDevice {
    _NAVDevice Device
    _NAVStateInteger PowerState
    _NAVStateInteger TransportState
    _NAVStateInteger DiscType
}


/**
 * @struct _NAVCredential
 * @description Authentication credentials with username and password.
 * @property {char[]} Username - The username for authentication
 * @property {char[]} Password - The password for authentication
 */
struct _NAVCredential {
    char Username[NAV_MAX_CHARS]
    char Password[NAV_MAX_CHARS]
}


/**
 * @struct _NAVSocketConnection
 * @description Manages a network socket connection.
 * @property {integer} Socket - The socket identifier
 * @property {integer} Port - The TCP/IP port number
 * @property {integer} IsConnected - Flag indicating connection status (0=disconnected, non-zero=connected)
 * @property {integer} IsAuthenticated - Flag indicating authentication status (0=not authenticated, non-zero=authenticated)
 * @property {char[]} Address - The IP address or hostname for the connection
 */
struct _NAVSocketConnection {
    integer Socket
    integer Port
    integer IsConnected
    integer IsAuthenticated
    char Address[NAV_MAX_CHARS]
}


/**
 * @struct _NAVDevice
 * @description Represents a networked device with connection and status information.
 * @property {_NAVSocketConnection} SocketConnection - The network connection details
 * @property {integer} IsOnline - Flag indicating online status (0=offline, non-zero=online)
 * @property {integer} IsCommunicating - Flag indicating active communication (0=no, non-zero=yes)
 * @property {integer} IsInitialized - Flag indicating if the device is initialized (0=no, non-zero=yes)
 */
struct _NAVDevice {
    _NAVSocketConnection SocketConnection
    integer IsOnline
    integer IsCommunicating
    integer IsInitialized
}


/**
 * @struct _NAVModule
 * @description Represents a NetLinx module with device and communication properties.
 * @property {_NAVDevice} Device - The base device information and connection details
 * @property {_NAVRxBuffer} RxBuffer - Buffer for receiving data
 * @property {integer} Enabled - Flag indicating if the module is enabled (0=disabled, non-zero=enabled)
 * @property {integer} CommandBusy - Flag indicating if the module is processing commands (0=not busy, non-zero=busy)
 * @property {dev[]} VirtualDevice - Array of virtual devices associated with the module
 */
struct _NAVModule {
    _NAVDevice Device
    _NAVRxBuffer RxBuffer
    integer Enabled
    integer CommandBusy
    dev VirtualDevice[10]
}


/**
 * @struct _NAVProgram
 * @description Information about a NetLinx program.
 * @property {char[]} Name - The program name
 * @property {char[]} File - The source file path
 * @property {char[]} CompileDate - The date when the program was compiled
 * @property {char[]} CompileTime - The time when the program was compiled
 */
struct _NAVProgram {
    char Name[NAV_MAX_BUFFER]
    char File[NAV_MAX_BUFFER]
    char CompileDate[NAV_MAX_CHARS]
    char CompileTime[NAV_MAX_CHARS]
}


/**
 * @struct _NAVController
 * @description Represents an AMX/NetLinx controller with detailed system information.
 * @property {ip_address_struct} IP - The controller's IP configuration
 * @property {dev_info_struct} Information - General device information
 * @property {dev_info_struct} Device - Information about the device node (5001)
 * @property {dev_info_struct} Switcher - Information about the switcher node (5002)
 * @property {_NAVProgram} Program - Information about the running program
 * @property {char[]} SerialNumber - The controller's serial number
 * @property {char[]} UniqueId - The controller's unique ID (6-byte identifier)
 * @property {char[]} MacAddress - The controller's MAC address in formatted string form
 */
struct _NAVController {
    ip_address_struct IP
    dev_info_struct Information
    dev_info_struct Device
    dev_info_struct Switcher
    _NAVProgram Program
    char SerialNumber[NAV_MAX_CHARS]
    char UniqueId[6]
    char MacAddress[NAV_MAX_CHARS]
}


/**
 * @struct _NAVConsole
 * @description Manages a console connection for diagnostic and control purposes.
 * @property {_NAVSocketConnection} SocketConnection - The network connection details
 * @property {slong} ErrorCode - Error status code for the console connection
 * @property {dev} Socket - Device reference for the console socket
 * @property {char} Semaphore - Thread protection flag to prevent concurrent access
 * @property {char[]} RxBuffer - Buffer for receiving data from the console
 */
struct _NAVConsole {
    _NAVSocketConnection SocketConnection
    slong ErrorCode
    dev Socket
    char Semaphore
    char RxBuffer[NAV_MAX_BUFFER]
}


/**
 * @struct _NAVSystem
 * @description Represents the overall system with controller and timing facilities.
 * @property {_NAVController} Controller - The system controller information
 * @property {long[]} Feedback - Timeline for feedback operations
 * @property {long[]} Blinker - Timeline for blinking operations
 */
struct _NAVSystem {
    _NAVController Controller
    long Feedback[1]
    long Blinker[1]
}


/**
 * @struct _NAVSerialPortSettings
 * @description Configuration settings for a serial (RS-232/RS-485) port.
 * @property {char[]} Speed - Baud rate (e.g., "9600", "115200")
 * @property {char[]} DataBits - Number of data bits (typically "8")
 * @property {char[]} StopBits - Number of stop bits (typically "1")
 * @property {char[]} Parity - Parity setting (typically "N", "E", or "O")
 * @property {char[]} Rs485 - RS-485 mode settings
 */
struct _NAVSerialPortSettings {
    char Speed[6]
    char DataBits[1]
    char StopBits[1]
    char Parity[1]
    char Rs485[15]
}


/**
 * @struct _NAVDataEventArgs
 * @description Arguments for data events containing transmitted/received data.
 * @property {tdata} Data - The data associated with the event
 */
struct _NAVDataEventArgs {
    tdata Data
}


#END_IF // __NAV_FOUNDATION_CORE_H__
