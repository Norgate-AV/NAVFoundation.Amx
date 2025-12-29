PROGRAM_NAME='NAVFoundation.McpBase'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_MCPBASE__
#DEFINE __NAV_FOUNDATION_MCPBASE__ 'NAVFoundation.McpBase'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


DEFINE_CONSTANT

constant integer BUTTON_1 = 1
constant integer BUTTON_2 = 2
constant integer BUTTON_3 = 3
constant integer BUTTON_4 = 4
constant integer BUTTON_5 = 5
constant integer BUTTON_6 = 6
constant integer BUTTON_7 = 7
constant integer BUTTON_8 = 8
constant integer BUTTON_9 = 9
constant integer BUTTON_10 = 10
constant integer BUTTON_11 = 11
constant integer BUTTON_12 = 12
constant integer BUTTON_13 = 13
constant integer BUTTON_14 = 14


// #DEFINE USING_NAV_MCP_KEYPAD_BUTTON_PUSH_EVENT_CALLBACK
// define_function NAVMcpKeypadButtonPushEventCallback(tbutton args) {}

// #DEFINE USING_NAV_MCP_KEYPAD_BUTTON_RELEASE_EVENT_CALLBACK
// define_function NAVMcpKeypadButtonReleaseEventCallback(tbutton args) {}

// #DEFINE USING_NAV_MCP_KEYPAD_LEVEL_EVENT_CALLBACK
// define_function NAVMcpKeypadLevelEventCallback(tlevel args) {}


DEFINE_EVENT

data_event[5001:28:0] {
    online: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'MCP Keypad Device [', NAVDeviceToString(data.device), '] Online'")
    }
    offline: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'MCP Keypad Device [', NAVDeviceToString(data.device), '] Offline'")
    }
}


button_event[5001:28:0, 0] {
    push: {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'MCP Keypad Device [', NAVDeviceToString(button.input.device), '] Button ', itoa(button.input.channel), ': Push'")

        #IF_DEFINED USING_NAV_MCP_KEYPAD_BUTTON_PUSH_EVENT_CALLBACK
        NAVMcpKeypadButtonPushEventCallback(button)
        #END_IF
    }
    release: {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'MCP Keypad Device [', NAVDeviceToString(button.input.device), '] Button ', itoa(button.input.channel), ': Release'")

        #IF_DEFINED USING_NAV_MCP_KEYPAD_BUTTON_RELEASE_EVENT_CALLBACK
        NAVMcpKeypadButtonReleaseEventCallback(button)
        #END_IF
    }
}


level_event[5001:28:0, 0] {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'MCP Keypad Device [', NAVDeviceToString(level.input.device), '] Level ', itoa(level.input.level), ': ', itoa(level.value)")

    #IF_DEFINED USING_NAV_MCP_KEYPAD_LEVEL_EVENT_CALLBACK
    NAVMcpKeypadLevelEventCallback(level)
    #END_IF
}


#END_IF  // __NAV_FOUNDATION_MCPBASE__
