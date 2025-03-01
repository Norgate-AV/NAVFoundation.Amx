PROGRAM_NAME='NAVFoundation.SnapiHelpers.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SNAPIHELPERS_H__
#DEFINE __NAV_FOUNDATION_SNAPIHELPERS_H__ 'NAVFoundation.SnapiHelpers.h'

#include 'NAVFoundation.Core.axi'


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

/**
 * @section SNAPI Overrides
 * @description Constants that override standard SNAPI limitations
 */

/**
 * @constant DUET_MAX_PARAM_LEN
 * @description Maximum length of a parameter in a SNAPI message
 */
constant integer DUET_MAX_PARAM_LEN     = 1024

/**
 * @constant NAV_MAX_SNAPI_MESSAGE_PARAMETERS
 * @description Maximum number of parameters in a SNAPI message
 */
#IF_NOT_DEFINED NAV_MAX_SNAPI_MESSAGE_PARAMETERS
constant integer NAV_MAX_SNAPI_MESSAGE_PARAMETERS    = 20
#END_IF


/**
 * @section Extended SNAPI Channels
 * @description Additional channel codes beyond standard SNAPI channels
 */

/**
 * @constant NAV_IP_CONNECTED
 * @description Channel feedback for IP connection status
 */
constant integer NAV_IP_CONNECTED       = 301

/**
 * @constant NAV_INPUT_1_SIGNAL
 * @description Channel feedback for signal presence on input 1
 */
constant integer NAV_INPUT_1_SIGNAL     = 401

/**
 * @constant NAV_INPUT_2_SIGNAL
 * @description Channel feedback for signal presence on input 2
 */
constant integer NAV_INPUT_2_SIGNAL     = 402

/**
 * @constant NAV_INPUT_3_SIGNAL
 * @description Channel feedback for signal presence on input 3
 */
constant integer NAV_INPUT_3_SIGNAL     = 403

/**
 * @constant NAV_INPUT_4_SIGNAL
 * @description Channel feedback for signal presence on input 4
 */
constant integer NAV_INPUT_4_SIGNAL     = 404

/**
 * @constant NAV_INPUT_5_SIGNAL
 * @description Channel feedback for signal presence on input 5
 */
constant integer NAV_INPUT_5_SIGNAL     = 405

/**
 * @constant NAV_INPUT_6_SIGNAL
 * @description Channel feedback for signal presence on input 6
 */
constant integer NAV_INPUT_6_SIGNAL     = 406

/**
 * @constant NAV_INPUT_SIGNAL
 * @description Array of all input signal presence channels
 */
constant integer NAV_INPUT_SIGNAL[]     =   {
                                                NAV_INPUT_1_SIGNAL,
                                                NAV_INPUT_2_SIGNAL,
                                                NAV_INPUT_3_SIGNAL,
                                                NAV_INPUT_4_SIGNAL,
                                                NAV_INPUT_5_SIGNAL,
                                                NAV_INPUT_6_SIGNAL
                                            }

/**
 * @constant NAV_PRESET_1
 * @description Channel for preset 1 selection
 */
constant integer NAV_PRESET_1           = 501

/**
 * @constant NAV_PRESET_2
 * @description Channel for preset 2 selection
 */
constant integer NAV_PRESET_2           = 502

/**
 * @constant NAV_PRESET_3
 * @description Channel for preset 3 selection
 */
constant integer NAV_PRESET_3           = 503

/**
 * @constant NAV_PRESET_4
 * @description Channel for preset 4 selection
 */
constant integer NAV_PRESET_4           = 504

/**
 * @constant NAV_PRESET_5
 * @description Channel for preset 5 selection
 */
constant integer NAV_PRESET_5           = 505

/**
 * @constant NAV_PRESET_6
 * @description Channel for preset 6 selection
 */
constant integer NAV_PRESET_6           = 506

/**
 * @constant NAV_PRESET_7
 * @description Channel for preset 7 selection
 */
constant integer NAV_PRESET_7           = 507

/**
 * @constant NAV_PRESET_8
 * @description Channel for preset 8 selection
 */
constant integer NAV_PRESET_8           = 508

/**
 * @constant NAV_PRESET_9
 * @description Channel for preset 9 selection
 */
constant integer NAV_PRESET_9           = 509

/**
 * @constant NAV_PRESET_10
 * @description Channel for preset 10 selection
 */
constant integer NAV_PRESET_10          = 510

/**
 * @constant NAV_PRESET_11
 * @description Channel for preset 11 selection
 */
constant integer NAV_PRESET_11          = 511

/**
 * @constant NAV_PRESET_12
 * @description Channel for preset 12 selection
 */
constant integer NAV_PRESET_12          = 512

/**
 * @constant NAV_PRESET
 * @description Array of all preset selection channels
 */
constant integer NAV_PRESET[]           =   {
                                                NAV_PRESET_1,
                                                NAV_PRESET_2,
                                                NAV_PRESET_3,
                                                NAV_PRESET_4,
                                                NAV_PRESET_5,
                                                NAV_PRESET_6,
                                                NAV_PRESET_7,
                                                NAV_PRESET_8,
                                                NAV_PRESET_9,
                                                NAV_PRESET_10,
                                                NAV_PRESET_11,
                                                NAV_PRESET_12
                                            }


/**
 * @section Switching Constants
 * @description Constants for different signal routing levels
 */

/**
 * @constant NAV_SWITCH_LEVEL_COUNT
 * @description Number of different switching levels available
 */
constant integer NAV_SWITCH_LEVEL_COUNT     = 3

/**
 * @constant NAV_SWITCH_LEVEL_VID
 * @description Index for video-only switching level
 */
constant integer NAV_SWITCH_LEVEL_VID       = 1

/**
 * @constant NAV_SWITCH_LEVEL_AUD
 * @description Index for audio-only switching level
 */
constant integer NAV_SWITCH_LEVEL_AUD       = 2

/**
 * @constant NAV_SWITCH_LEVEL_ALL
 * @description Index for switching all signal types
 */
constant integer NAV_SWITCH_LEVEL_ALL       = 3

/**
 * @constant NAV_SWITCH_LEVELS
 * @description String representations of switching levels
 */
constant char NAV_SWITCH_LEVELS[][NAV_MAX_CHARS]    = { 'VID', 'AUD', 'ALL' }


DEFINE_TYPE

/**
 * @struct _NAVSnapiMessage
 * @description Represents a parsed SNAPI protocol message with header and parameters
 *
 * @property {char[NAV_MAX_BUFFER]} Header - Command name or message type
 * @property {char[][]} Parameter - Array of message parameters (up to NAV_MAX_SNAPI_MESSAGE_PARAMETERS)
 * @property {integer} ParameterCount - Number of parameters in the message
 *
 * @note Use NAVParseSnapiMessage to populate this structure from a raw SNAPI message
 * @see NAVParseSnapiMessage
 */
struct _NAVSnapiMessage {
    char Header[NAV_MAX_BUFFER]
    char Parameter[NAV_MAX_SNAPI_MESSAGE_PARAMETERS][255]
    integer ParameterCount
}


/**
 * @section Included Libraries
 * @description Inlcudes the standard SNAPI and G4 API libraries
 */
#include 'SNAPI.axi'
#include 'G4API.axi'


#END_IF // __NAV_FOUNDATION_SNAPIHELPERS_H__
