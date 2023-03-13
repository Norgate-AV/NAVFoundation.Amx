PROGRAM_NAME='NAVFoundation.CommandConsole'

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


#IF_NOT_DEFINED __NAV_FOUNDATION_COMMANDCONSOLE__
#DEFINE __NAV_FOUNDATION_COMMANDCONSOLE__ 'NAVFoundation.CommandConsole'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ArrayUtils.axi'
#include 'NAVFoundation.SocketUtils.axi'
#include 'NAVFoundation.ConsoleUtils.axi'


(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvNAVCommandConsole     =       0:260:0


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

#IF_NOT_DEFINED NAV_COMMAND_CONSOLE_PORT
constant integer NAV_COMMAND_CONSOLE_PORT	                            = 6000
#END_IF

#IF_NOT_DEFINED MAX_NAV_COMMAND_CONSOLE_CONNECTIONS
constant integer MAX_NAV_COMMAND_CONSOLE_CONNECTIONS                    = 5
#END_IF

#IF_NOT_DEFINED MAX_NAV_COMMAND_CONSOLE_COMMANDS
constant integer MAX_NAV_COMMAND_CONSOLE_COMMANDS                       = 30
#END_IF

#IF_NOT_DEFINED MAX_NAV_COMMAND_CONSOLE_COMMAND_OPTIONS
constant integer MAX_NAV_COMMAND_CONSOLE_COMMAND_OPTIONS                = 5
#END_IF

#IF_NOT_DEFINED MAX_NAV_COMMAND_CONSOLE_COMMAND_ALIASES
constant integer MAX_NAV_COMMAND_CONSOLE_COMMAND_ALIASES                = 3
#END_IF

#IF_NOT_DEFINED MAX_NAV_COMMAND_CONSOLE_COMMAND_HISTORY
constant integer MAX_NAV_COMMAND_CONSOLE_COMMAND_HISTORY                = 100
#END_IF

constant integer NAV_COMMAND_CONSOLE_COMMAND_OPTION_TYPE_STRING         = 1
constant integer NAV_COMMAND_CONSOLE_COMMAND_OPTION_TYPE_NUMBER         = 2
constant integer NAV_COMMAND_CONSOLE_COMMAND_OPTION_TYPE_BOOLEAN        = 3
constant char NAV_COMMAND_CONSOLE_COMMAND_OPTION_TYPE[][NAV_MAX_CHARS]  =   {
                                                                                'string',
                                                                                'number',
                                                                                'boolean'
                                                                            }


DEFINE_TYPE

struct _NAVCommandConsoleCommandOptionFlag {
    char ShortValue[5]
    char LongValue[NAV_MAX_CHARS]
}


struct _NAVCommandConsoleCommandOption {
    char Name[NAV_MAX_CHARS]
    char Description[NAV_MAX_BUFFER]
    char Type[NAV_MAX_CHARS]
    _NAVCommandConsoleCommandOptionFlag Flag
    char DefaultValue[NAV_MAX_CHARS]
}


struct _NAVCommandConsoleCommand {
    char Name[NAV_MAX_CHARS]
    char Alias[MAX_NAV_COMMAND_CONSOLE_COMMAND_ALIASES][NAV_MAX_CHARS]
    char Description[NAV_MAX_BUFFER]
    _NAVCommandConsoleCommandOption Options[MAX_NAV_COMMAND_CONSOLE_COMMAND_OPTIONS]
}


struct _NAVCommandConsole {
    dev Socket[MAX_NAV_COMMAND_CONSOLE_CONNECTIONS]
    _NAVConsole Console[MAX_NAV_COMMAND_CONSOLE_CONNECTIONS]
    _NAVConsoleCommand Commands[MAX_NAV_COMMAND_CONSOLE_COMMANDS]
    char History[MAX_NAV_COMMAND_CONSOLE_COMMAND_HISTORY][NAV_MAX_BUFFER]
}


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile _NAVCommandConsole navCommandConsole

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function char[NAV_MAX_BUFFER] NAVFormatCommandConsoleResponse(char response[]) {
    return "response, NAV_CR, NAV_LF"
}


define_function NAVCommandConsoleSendResponse(_NAVConsole console, char response[]) {
    if (!console.SocketConnection.IsConnected) {
        return
    }

    if (!length_array(response)) {
        return
    }

    send_string console.Socket, "NAVFormatCommandConsoleResponse(response)"
}


define_function NAVCommandConsoleSendPrompt(_NAVConsole console, slong error) {
    if (!console.SocketConnection.IsConnected) {
        return
    }

    console.ErrorCode = error

    send_string console.Socket, "NAVCommandConsoleGetPrompt(console)"
}


define_function slong NAVCommandConsoleServerOpen(_NAVConsole console, integer server) {
    stack_var integer socket
    stack_var integer port
    stack_var slong result

    socket = console.Socket.Port
    port = console.SocketConnection.Port

    result = NAVServerSocketOpen(socket, port, IP_TCP)

    if (result < 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                    "'NAVCommandConsole: Server', format('%02d', server), ': Failed to start server'")

        return result
    }

    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'NAVCommandConsole: Server', format('%02d', server), ': Listening on port ', itoa(port)")

    return result
}


define_function char[NAV_MAX_BUFFER] NAVCommandConsoleGetBanner() {
    return "
        NAVGetNAVBanner(),
        NAV_CR, NAV_LF,
        'Welcome to the NAV Command Console',
        NAV_CR, NAV_LF
    "
}


define_function char[NAV_MAX_BUFFER] NAVCommandConsoleGetPrompt(_NAVConsole console) {
    stack_var slong error

    error = console.ErrorCode

    if (error != 0) {
        return "'X', itoa(error), ' > '"
    }

    return "'> '"
}


define_function char[NAV_MAX_BUFFER] NAVCommandConsoleGetHelp() {
    return "
        'Usage: [command] [arg1] [arg2] [options] ...', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        'Options:', NAV_CR, NAV_LF,
        '  -h, --help       display help for command', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        'Commands:', NAV_CR, NAV_LF,
        '  set              set a configuration value', NAV_CR, NAV_LF,
        '  get              get a configuration value', NAV_CR, NAV_LF,
        '  run              run a command', NAV_CR, NAV_LF,
        '  reboot           reboot the device', NAV_CR, NAV_LF,
        '  clear            clear the console', NAV_CR, NAV_LF,
        '  exit             exit the command console', NAV_CR, NAV_LF,
        '  help             display this help message', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '=============================================================',
        NAV_CR, NAV_LF
    "
}


define_function NAVCommandConsoleProcessCommand(_NAVConsole console) {
    stack_var char temp[NAV_MAX_BUFFER]
    stack_var char args[10][NAV_MAX_CHARS]

    if (console.Semaphore) {
        return
    }

    console.Semaphore = true

    while (length_array(console.RxBuffer) && NAVContains(console.RxBuffer, "NAV_CR, NAV_LF")) {
        temp = remove_string(console.RxBuffer, "NAV_CR, NAV_LF", 1)

        if (!length_array(temp)) {
            continue
        }

        temp = NAVStripRight(temp, 2)

        if (!length_array(temp)) {
            NAVCommandConsoleSendPrompt(console, console.ErrorCode)
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'NAVCommandConsole: Command: ', temp")

        NAVSplitString(temp, ' ', args)
        NAVArrayToLowerString(args)

        switch (args[1]) {
            case 'help': {
                NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, NAVCommandConsoleGetHelp()")
                NAVCommandConsoleSendPrompt(console, 0)
            }
            case 'run': {
                switch (args[2]) {
                    case 'tests': {
                        #IF_DEFINED USING_NAV_COMMAND_CONSOLE_RUN_TESTS_EVENT_CALLBACK
                        stack_var char result

                        NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Running tests...'")

                        result = NAVCommandConsoleRunTestsEventCallback(console)

                        if (result) {
                            NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Tests Passed'")
                        }
                        else {
                            NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Tests Failed'")
                        }

                        NAVCommandConsoleSendPrompt(console, 0)
                        #ELSE
                        NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Tests not available'")
                        NAVCommandConsoleSendPrompt(console, 0)
                        #END_IF
                    }

                    default: {
                        NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Invalid run argument: ', args[2]")
                        NAVCommandConsoleSendPrompt(console, 1)
                    }
                }
            }
            case 'set': {
                switch (args[2]) {
                    case 'loglevel': {
                        switch (args[3]) {
                            case 'error': {
                                set_log_level(NAV_LOG_LEVEL_ERROR)
                                NAVCommandConsoleSendPrompt(console, 0)
                            }
                            case 'warning': {
                                set_log_level(NAV_LOG_LEVEL_WARNING)
                                NAVCommandConsoleSendPrompt(console, 0)
                            }
                            case 'info': {
                                set_log_level(NAV_LOG_LEVEL_INFO)
                                NAVCommandConsoleSendPrompt(console, 0)
                            }
                            case 'debug': {
                                set_log_level(NAV_LOG_LEVEL_DEBUG)
                                NAVCommandConsoleSendPrompt(console, 0)
                            }
                            default: {
                                NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Invalid log level: ', args[4]")
                                NAVCommandConsoleSendPrompt(console, 1)
                            }
                        }
                    }
                    default: {
                        NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Invalid set argument: ', args[2]")
                        NAVCommandConsoleSendPrompt(console, 1)
                    }
                }
            }
            case 'get': {
                switch (args[2]) {
                    case 'loglevel': {
                        NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Log level is ', NAVGetLogLevel(get_log_level())")
                        NAVCommandConsoleSendPrompt(console, 0)
                    }
                    case 'info': {
                        NAVCommandConsoleSendPrompt(console, 0)
                    }
                    default: {
                        NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Invalid get argument: ', args[2]")
                        NAVCommandConsoleSendPrompt(console, 1)
                    }
                }
            }
            case 'exit':
            case 'quit': {
                NAVServerSocketClose(console.Socket.Port)
            }
            case 'clear':
            case 'cls': {
                NAVCommandConsoleSendResponse(console, "$1B, '[2J', $1B, '[H'")
                NAVCommandConsoleSendPrompt(console, 0)
            }
            case 'reboot': {
                NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Rebooting...'")
                reboot(0)
            }
            default: {
                NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Unknown Command: ', temp")
                NAVCommandConsoleSendResponse(console, "NAV_CR, NAV_LF, 'Run "help" for a list of available commands'")
                NAVCommandConsoleSendPrompt(console, 1)
            }
        }
    }

    console.Semaphore = false
}


define_function NAVCommandConsoleHandleDataEvent(char event[], tdata args) {
    stack_var integer serverIndex

    serverIndex = get_last(navCommandConsole.Socket)

    switch (lower_string(event)) {
        case NAV_EVENT_ONLINE: {
            navCommandConsole.Console[serverIndex].SocketConnection.IsConnected = true

            NAVErrorLog(NAV_LOG_LEVEL_INFO,
                        "'NAVCommandConsole: Server', format('%02d', serverIndex), ': Client Connected: ', args.sourceip, ':', args.sourceport")

            NAVCommandConsoleSendResponse(navCommandConsole.Console[serverIndex], NAVCommandConsoleGetBanner())
            NAVCommandConsoleSendPrompt(navCommandConsole.Console[serverIndex], 0)
        }
        case NAV_EVENT_OFFLINE: {
            navCommandConsole.Console[serverIndex].SocketConnection.IsConnected = false

            NAVErrorLog(NAV_LOG_LEVEL_INFO,
                        "'NAVCommandConsole: Server', format('%02d', serverIndex), ': Client Disconnected'")

            NAVCommandConsoleServerOpen(navCommandConsole.Console[serverIndex], serverIndex)
            navCommandConsole.Console[serverIndex].RxBuffer  = ""
        }
        case NAV_EVENT_ONERROR: {
            navCommandConsole.Console[serverIndex].SocketConnection.IsConnected = false

            NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                        "'NAVCommandConsole: Server', format('%02d', serverIndex), ': Socket OnError'")
        }
        case NAV_EVENT_STRING: {
            NAVErrorLog(NAV_LOG_LEVEL_INFO,
                        "'NAVCommandConsole: Server', format('%02d', serverIndex), ': Data Received: ', args.text")

            select {
                active (navCommandConsole.Console[serverIndex].RxBuffer == "NAV_FF"): {
                    NAVCommandConsoleSendResponse(navCommandConsole.Console[serverIndex], "NAV_ESC, '[2J', NAV_ESC, '[H'")
                    NAVCommandConsoleSendPrompt(navCommandConsole.Console[serverIndex], 0)
                    navCommandConsole.Console[serverIndex].RxBuffer = ""
                }
                active (1): {
                    NAVCommandConsoleProcessCommand(navCommandConsole.Console[serverIndex])
                }
            }
        }
    }
}


DEFINE_START {
    stack_var integer x

    set_length_array(navCommandConsole.Socket, MAX_NAV_COMMAND_CONSOLE_CONNECTIONS)
    set_length_array(navCommandConsole.Console.Socket, MAX_NAV_COMMAND_CONSOLE_CONNECTIONS)

    for(x = 0; x < MAX_NAV_COMMAND_CONSOLE_CONNECTIONS; x++) {
        stack_var integer socket
        stack_var integer server

        socket = dvNAVCommandConsole.PORT + x
        server = x + 1

        navCommandConsole.Socket[server] = 0:socket:0
        navCommandConsole.Console[server].Socket = navCommandConsole.Socket[server]
        rebuild_event()

        create_buffer navCommandConsole.Console[server].Socket, navCommandConsole.Console[server].RxBuffer

        navCommandConsole.Console[server].SocketConnection.Port = NAV_COMMAND_CONSOLE_PORT
        NAVCommandConsoleServerOpen(navCommandConsole.Console[server], server)
    }
}


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[navCommandConsole.Socket] {
    online: {
        NAVCommandConsoleHandleDataEvent(NAV_EVENT_ONLINE, data)
    }
    offline: {
        NAVCommandConsoleHandleDataEvent(NAV_EVENT_OFFLINE, data)
    }
    onerror: {
        NAVCommandConsoleHandleDataEvent(NAV_EVENT_ONERROR, data)
    }
    string: {
        NAVCommandConsoleHandleDataEvent(NAV_EVENT_STRING, data)
    }
}


#END_IF // __NAV_FOUNDATION_COMMANDCONSOLE__
