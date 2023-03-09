PROGRAM_NAME='NAVFoundation.SnapiHelpers.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SNAPIHELPERS_H__
#DEFINE __NAV_FOUNDATION_SNAPIHELPERS_H__ 'NAVFoundation.SnapiHelpers.h'

#include 'NAVFoundation.Core.axi'


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
/////////////////////////////////////////////////////////////
// SNAPI Overrides
/////////////////////////////////////////////////////////////
constant integer DUET_MAX_PARAM_LEN     = 1024

#IF_NOT_DEFINED NAV_MAX_SNAPI_MESSAGE_PARAMETERS
constant integer NAV_MAX_SNAPI_MESSAGE_PARAMETERS    = 20
#END_IF


/////////////////////////////////////////////////////////////
// Extended SNAPI Channels
/////////////////////////////////////////////////////////////
constant integer NAV_IP_CONNECTED       = 301

constant integer NAV_INPUT_1_SIGNAL     = 401
constant integer NAV_INPUT_2_SIGNAL     = 402
constant integer NAV_INPUT_3_SIGNAL     = 403
constant integer NAV_INPUT_4_SIGNAL     = 404
constant integer NAV_INPUT_5_SIGNAL     = 405
constant integer NAV_INPUT_6_SIGNAL     = 406
constant integer NAV_INPUT_SIGNAL[]     =   {
                                                NAV_INPUT_1_SIGNAL,
                                                NAV_INPUT_2_SIGNAL,
                                                NAV_INPUT_3_SIGNAL,
                                                NAV_INPUT_4_SIGNAL,
                                                NAV_INPUT_5_SIGNAL,
                                                NAV_INPUT_6_SIGNAL
                                            }

constant integer NAV_PRESET_1           = 501
constant integer NAV_PRESET_2           = 502
constant integer NAV_PRESET_3           = 503
constant integer NAV_PRESET_4           = 504
constant integer NAV_PRESET_5           = 505
constant integer NAV_PRESET_6           = 506
constant integer NAV_PRESET_7           = 507
constant integer NAV_PRESET_8           = 508
constant integer NAV_PRESET_9           = 509
constant integer NAV_PRESET_10          = 510
constant integer NAV_PRESET_11          = 511
constant integer NAV_PRESET_12          = 512
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


/////////////////////////////////////////////////////////////
// Switching
/////////////////////////////////////////////////////////////
constant integer NAV_SWITCH_LEVEL_VID    = 1
constant integer NAV_SWITCH_LEVEL_AUD    = 2
constant integer NAV_SWITCH_LEVEL_ALL    = 3
constant char NAV_SWITCH_LEVELS[][NAV_MAX_CHARS]    = { 'VID', 'AUD', 'ALL' }


DEFINE_TYPE

struct _NAVSnapiMessage {
    char Header[NAV_MAX_BUFFER]
    char Parameter[NAV_MAX_SNAPI_MESSAGE_PARAMETERS][255]
}


/////////////////////////////////////////////////////////////
// Includes
/////////////////////////////////////////////////////////////
#include 'SNAPI.axi'
#include 'G4API.axi'


#END_IF // __NAV_FOUNDATION_SNAPIHELPERS_H__
