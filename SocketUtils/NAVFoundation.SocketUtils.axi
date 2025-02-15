PROGRAM_NAME='NAVFoundation.SocketUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SOCKETUTILS__
#DEFINE __NAV_FOUNDATION_SOCKETUTILS__ 'NAVFoundation.SocketUtils'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

constant slong NAV_SOCKET_ERROR_INVALID_SERVER_PORT             = -1
constant slong NAV_SOCKET_ERROR_INVALID_PROTOCOL_VALUE          = -2
constant slong NAV_SOCKET_ERROR_UNABLE_TO_OPEN_PORT             = -3
constant slong NAV_SOCKET_ERROR_INVALID_HOST_ADDRESS            = -10
constant slong NAV_SOCKET_ERROR_INVALID_PORT                    = -11
constant slong NAV_SOCKET_ERROR_GENERAL_FAILURE                 = 2
constant slong NAV_SOCKET_ERROR_UNKNOWN_HOST                    = 4
constant slong NAV_SOCKET_ERROR_CONNECTION_REFUSED              = 6
constant slong NAV_SOCKET_ERROR_CONNECTION_TIMED_OUT            = 7
constant slong NAV_SOCKET_ERROR_UNKNOWN_CONNECTION_ERROR        = 8
constant slong NAV_SOCKET_ERROR_ALREADY_CLOSED                  = 9
constant slong NAV_SOCKET_ERROR_BINDING_ERROR                   = 10
constant slong NAV_SOCKET_ERROR_LISTENING_ERROR                 = 11
constant slong NAV_SOCKET_ERROR_LOCAL_PORT_ALREADY_USED         = 14
constant slong NAV_SOCKET_ERROR_UDP_SOCKET_ALREADY_LISTENING    = 15
constant slong NAV_SOCKET_ERROR_TOO_MANY_OPEN_SOCKETS           = 16
constant slong NAV_SOCKET_ERROR_LOCAL_PORT_NOT_OPEN             = 17


define_function char[NAV_MAX_BUFFER] NAVGetSocketError(slong error) {
    switch (error) {
        case NAV_SOCKET_ERROR_INVALID_SERVER_PORT:          { return 'Invalid server port' }
        case NAV_SOCKET_ERROR_INVALID_PROTOCOL_VALUE:       { return 'Invalid value for protocol' }
        case NAV_SOCKET_ERROR_UNABLE_TO_OPEN_PORT:          { return 'Unable to open communication port' }
        case NAV_SOCKET_ERROR_INVALID_HOST_ADDRESS:         { return 'Invalid host address' }
        case NAV_SOCKET_ERROR_INVALID_PORT:                 { return 'Invalid port' }
        case NAV_SOCKET_ERROR_GENERAL_FAILURE:              { return 'General failure (out of memory)' }
        case NAV_SOCKET_ERROR_UNKNOWN_HOST:                 { return 'Unknown host' }
        case NAV_SOCKET_ERROR_CONNECTION_REFUSED:           { return 'Connection refused' }
        case NAV_SOCKET_ERROR_CONNECTION_TIMED_OUT:         { return 'Connection timed out' }
        case NAV_SOCKET_ERROR_UNKNOWN_CONNECTION_ERROR:     { return 'Unknown connection error' }
        case NAV_SOCKET_ERROR_ALREADY_CLOSED:               { return 'Already closed' }
        case NAV_SOCKET_ERROR_BINDING_ERROR:                { return 'Binding error' }
        case NAV_SOCKET_ERROR_LISTENING_ERROR:              { return 'Listening error' }
        case NAV_SOCKET_ERROR_LOCAL_PORT_ALREADY_USED:      { return 'Local port already used' }
        case NAV_SOCKET_ERROR_UDP_SOCKET_ALREADY_LISTENING: { return 'UDP socket already listening' }
        case NAV_SOCKET_ERROR_TOO_MANY_OPEN_SOCKETS:        { return 'Too many open sockets' }
        case NAV_SOCKET_ERROR_LOCAL_PORT_NOT_OPEN:          { return 'Local port not open' }
        default:                                            { return "'Unknown error (', itoa(error), ')'" }
    }
}


define_function char[NAV_MAX_BUFFER] NAVGetSocketProtocol(integer protocol) {
    switch (protocol) {
        case IP_TCP:        { return 'TCP' }
        case IP_UDP:        { return 'UDP' }
        case IP_UDP_2WAY:   { return 'UDP 2-Way' }
        default:            { return "'Unknown protocol (', itoa(protocol), ')'" }
    }
}


define_function slong NAVServerSocketOpen(integer socket, integer port, integer protocol) {
    stack_var slong result

    result = ip_server_open(socket, port, protocol)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVServerSocketOpen',
                                    "'Failed to open socket. ', NAVGetSocketError(result)")
    }

    return result
}


define_function slong NAVServerSocketClose(integer socket) {
    return ip_server_close(socket)
}


define_function slong NAVClientSocketOpen(integer socket, char address[], integer port, integer protocol) {
    stack_var slong result

    address = NAVTrimString(address)

    if (!length_array(address)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientSocketOpen',
                                    "'The host address is an empty string.'")
        return NAV_SOCKET_ERROR_INVALID_HOST_ADDRESS
    }

    if (port <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientSocketOpen',
                                    "NAVGetSocketError(NAV_SOCKET_ERROR_INVALID_PORT)")
        return NAV_SOCKET_ERROR_INVALID_PORT
    }

    result = ip_client_open(socket, address, port, protocol)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientSocketOpen',
                                    "'Failed to open socket to ', address, ':', itoa(port), ' (', NAVGetSocketProtocol(protocol), ')'")
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientSocketOpen',
                                    "'Socket error: ', NAVGetSocketError(result)")
    }

    return result
}


define_function slong NAVClientSocketClose(integer socket) {
    stack_var slong result

    result = ip_client_close(socket)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientSocketClose',
                                    "'Failed to close socket. ', NAVGetSocketError(result)")
    }

    return result
}


define_function slong NAVClientSecureSocketOpen(integer socket,
                                                char address[],
                                                integer port,
                                                char username[],
                                                char password[],
                                                char privateKey[],
                                                char privateKeyPassphrase[]) {

    address = NAVTrimString(address)

    if (!length_array(address)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientSecureSocketOpen',
                                    "'The host address is an empty string.'")
        return NAV_SOCKET_ERROR_INVALID_HOST_ADDRESS
    }

    if (!length_array(username)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientSecureSocketOpen',
                                    "'The username is an empty string.'")
        return NAV_SOCKET_ERROR_INVALID_PROTOCOL_VALUE
    }

    if (!length_array(password) && !length_array(privateKey)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientSecureSocketOpen',
                                    "'Both the password and private key are empty strings.'")
        return NAV_SOCKET_ERROR_INVALID_PROTOCOL_VALUE
    }

    if (port <= 0) {
        port = NAV_SSH_PORT
    }

    return ssh_client_open(socket, address, port, username, password, privateKey, privateKeyPassphrase)
}


define_function slong NAVClientSecureSocketClose(integer socket) {
    return ssh_client_close(socket)
}


#END_IF // __NAV_FOUNDATION_SOCKETUTILS__
