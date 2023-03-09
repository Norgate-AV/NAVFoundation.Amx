PROGRAM_NAME='NAVFoundation.DebugConsole'

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


#IF_NOT_DEFINED __NAV_FOUNDATION_DEBUGCONSOLE__
#DEFINE __NAV_FOUNDATION_DEBUGCONSOLE__ 'NAVFoundation.DebugConsole'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.SocketUtils.axi'
#include 'NAVFoundation.ConsoleUtils.axi'


(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvNAVDebugConsole       =       0:250:0


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

#IF_NOT_DEFINED NAV_DEBUG_CONSOLE_PORT
constant integer NAV_DEBUG_CONSOLE_PORT	                = 5000
#END_IF

#IF_NOT_DEFINED MAX_NAV_DEBUG_CONSOLE_CONNECTIONS
constant integer MAX_NAV_DEBUG_CONSOLE_CONNECTIONS      = 5
#END_IF


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile dev dvaNAVDebugConsole[MAX_NAV_DEBUG_CONSOLE_CONNECTIONS]
volatile _NAVConsole NAVDebugConsole[MAX_NAV_DEBUG_CONSOLE_CONNECTIONS]


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function char[NAV_MAX_BUFFER] NAVFormatDebugConsoleLog(char log[]) {
    return "NAVGetTimeStamp(), ':: ', log, NAV_CR, NAV_LF"
}


define_function NAVDebugConsoleLog(char log[]) {
    stack_var integer x

    for (x = 1; x <= MAX_NAV_DEBUG_CONSOLE_CONNECTIONS; x++) {
        if (!NAVDebugConsole[x].SocketConnection.IsConnected) {
            continue
        }

        send_string NAVDebugConsole[x].Socket, "NAVFormatDebugConsoleLog(log)"
    }
}


define_function slong NAVDebugConsoleServerOpen(integer server, integer port) {
    stack_var integer socket
    stack_var integer serverIndex
    stack_var slong result

    socket = dvNAVDebugConsole.PORT + server
    serverIndex = server + 1

    result = NAVServerSocketOpen(socket, port, IP_TCP)

    if (result < 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                    "'NAVDebugConsole: Server', format('%02d', serverIndex), ': Failed to start server'")

        return result
    }

    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'NAVDebugConsole: Server', format('%02d', serverIndex), ': Listening on port ', itoa(port)")

    return result
}


define_function NAVDebugConsoleHandleDataEvent(char event[], tdata args) {
    stack_var integer serverIndex

    serverIndex = get_last(dvaNAVDebugConsole)

    switch (lower_string(event)) {
        case NAV_EVENT_ONLINE: {
            NAVDebugConsole[serverIndex].SocketConnection.IsConnected = true

            NAVErrorLog(NAV_LOG_LEVEL_INFO,
                        "'NAVDebugConsole: Server', format('%02d', serverIndex), ': Client Connected: ', args.sourceip, ':', args.sourceport")
        }
        case NAV_EVENT_OFFLINE: {
            NAVDebugConsole[serverIndex].SocketConnection.IsConnected = false

            NAVErrorLog(NAV_LOG_LEVEL_INFO,
                        "'NAVDebugConsole: Server', format('%02d', serverIndex), ': Client Disconnected'")

            NAVDebugConsoleServerOpen(NAVZeroBase(serverIndex), NAV_DEBUG_CONSOLE_PORT)
        }
        case NAV_EVENT_ONERROR: {
            NAVDebugConsole[serverIndex].SocketConnection.IsConnected = false

            NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                        "'NAVDebugConsole: Server', format('%02d', serverIndex), ': Socket OnError'")
        }
        case NAV_EVENT_STRING: {
            NAVErrorLog(NAV_LOG_LEVEL_INFO,
                        "'NAVDebugConsole: Server', format('%02d', serverIndex), ': Data Received: ', args.text")

            NAVDebugConsole[serverIndex].RxBuffer = ""
        }
    }
}


DEFINE_START {
    stack_var integer x

    for (x = 0; x < MAX_NAV_DEBUG_CONSOLE_CONNECTIONS; x++) {
        stack_var integer socket
        stack_var integer serverIndex

        socket = dvNAVDebugConsole.PORT + x
        serverIndex = x + 1

        set_length_array(NAVDebugConsole, MAX_NAV_DEBUG_CONSOLE_CONNECTIONS)
        set_length_array(dvaNAVDebugConsole, MAX_NAV_DEBUG_CONSOLE_CONNECTIONS)

        NAVDebugConsole[serverIndex].Socket = 0:socket:0
        dvaNAVDebugConsole[serverIndex] = NAVDebugConsole[serverIndex].Socket
        rebuild_event()

        create_buffer NAVDebugConsole[serverIndex].Socket, NAVDebugConsole[serverIndex].RxBuffer

        NAVDebugConsoleServerOpen(x, NAV_DEBUG_CONSOLE_PORT)
    }
}


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvaNAVDebugConsole] {
    online: {
        NAVDebugConsoleHandleDataEvent(NAV_EVENT_ONLINE, data)
    }
    offline: {
        NAVDebugConsoleHandleDataEvent(NAV_EVENT_OFFLINE, data)
    }
    onerror: {
        NAVDebugConsoleHandleDataEvent(NAV_EVENT_ONERROR, data)
    }
    string: {
        NAVDebugConsoleHandleDataEvent(NAV_EVENT_STRING, data)
    }
}


#END_IF // __NAV_FOUNDATION_DEBUGCONSOLE__
