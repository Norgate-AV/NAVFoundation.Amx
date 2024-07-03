PROGRAM_NAME='NAVFoundation.ModuleBase.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_MODULEBASE_H__
#DEFINE __NAV_FOUNDATION_MODULEBASE_H__ 'NAVFoundation.ModuleBase.h'

#DEFINE NAV_MODULE
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ArrayUtils.axi'


DEFINE_CONSTANT

constant char NAV_MODULE_PROPERTY_EVENT[]         = 'PROPERTY'
constant char NAV_MODULE_PASSTHRU_EVENT[]         = 'PASSTHRU'
constant char NAV_MODULE_EVENT_SWITCH[]           = 'SWITCH'
constant char NAV_MODULE_EVENT_VOLUME[]           = 'VOLUME'
constant char NAV_MODULE_EVENT_MUTE[]             = 'MUTE'
constant char NAV_MODULE_EVENT_POWER[]            = 'POWER'
constant char NAV_MODULE_EVENT_INPUT[]            = 'INPUT'

constant char NAV_MODULE_PROPERTY_EVENT_IP_ADDRESS[]    = 'IP_ADDRESS'
constant char NAV_MODULE_PROPERTY_EVENT_PORT[]          = 'PORT'
constant char NAV_MODULE_PROPERTY_EVENT_ID[]            = 'ID'
constant char NAV_MODULE_PROPERTY_EVENT_BAUDRATE[]      = 'BAUDRATE'
constant char NAV_MODULE_PROPERTY_EVENT_USERNAME[]      = 'USERNAME'
constant char NAV_MODULE_PROPERTY_EVENT_PASSWORD[]      = 'PASSWORD'


DEFINE_TYPE

struct _NAVModulePropertyEvent {
    dev Device
    _NAVSnapiMessage FullMessage
    char Name[255]
    char Args[NAV_MAX_SNAPI_MESSAGE_PARAMETERS - 1][255]
}

struct _NAVModulePassthruEvent {
    dev Device
    _NAVSnapiMessage FullMessage
    char Payload[255]
}



#END_IF // __NAV_FOUNDATION_MODULEBASE_H__
