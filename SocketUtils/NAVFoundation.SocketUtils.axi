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
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.SocketUtils.h.axi'


/**
 * @function NAVGetSocketError
 * @public
 * @description Converts a socket error code to a human-readable error message.
 *
 * @param {slong} error - Error code returned by a socket operation
 *
 * @returns {char[]} Human-readable error description
 *
 * @example
 * stack_var slong result
 * stack_var char errorMessage[NAV_MAX_BUFFER]
 *
 * result = NAVClientSocketOpen(dvTCPClient.PORT, '192.168.1.100', 23, IP_TCP)
 * if (result < 0) {
 *     errorMessage = NAVGetSocketError(result)
 *     NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Socket error: ', errorMessage")
 * }
 */
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


/**
 * @function NAVGetSocketProtocol
 * @public
 * @description Converts a protocol constant to a human-readable protocol name.
 *
 * @param {integer} protocol - Protocol value (IP_TCP, IP_UDP, or IP_UDP_2WAY)
 *
 * @returns {char[]} Human-readable protocol name
 *
 * @example
 * stack_var integer protocol
 * stack_var char protocolName[NAV_MAX_BUFFER]
 *
 * protocol = IP_TCP
 * protocolName = NAVGetSocketProtocol(protocol)  // Returns 'TCP'
 */
define_function char[NAV_MAX_BUFFER] NAVGetSocketProtocol(integer protocol) {
    switch (protocol) {
        case IP_TCP:        { return 'TCP' }
        case IP_UDP:        { return 'UDP' }
        case IP_UDP_2WAY:   { return 'UDP 2-Way' }
        default:            { return "'Unknown protocol (', itoa(protocol), ')'" }
    }
}


/**
 * @function NAVServerSocketOpen
 * @public
 * @description Opens a server socket that listens for incoming connections.
 *
 * @param {integer} socket - Socket ID to use
 * @param {integer} port - Port number to listen on
 * @param {integer} protocol - Protocol type (IP_TCP, IP_UDP, or IP_UDP_2WAY)
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * // Open TCP server on port 8080
 * result = NAVServerSocketOpen(dvServerSocket.PORT, 8080, IP_TCP)
 * if (result < 0) {
 *     // Handle error
 * }
 *
 * @note For UDP sockets, connections will come in on the same socket ID
 * @note For TCP sockets, new client connections will be received with different socket IDs
 */
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


/**
 * @function NAVServerSocketClose
 * @public
 * @description Closes a server socket and stops listening for connections.
 *
 * @param {integer} socket - Socket ID to close
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * result = NAVServerSocketClose(dvServerSocket.PORT)
 * if (result < 0) {
 *     // Handle error
 * }
 */
define_function slong NAVServerSocketClose(integer socket) {
    return ip_server_close(socket)
}


/**
 * @function NAVClientSocketOpen
 * @public
 * @description Opens a client socket connection to a remote server.
 *
 * @param {integer} socket - Socket ID to use
 * @param {char[]} address - IP address or hostname of remote server
 * @param {integer} port - Port number to connect to
 * @param {integer} protocol - Protocol type (IP_TCP, IP_UDP, or IP_UDP_2WAY)
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * // Connect to a device at 192.168.1.100 on port 23 (Telnet)
 * result = NAVClientSocketOpen(dvTCPClient.PORT, '192.168.1.100', 23, IP_TCP)
 * if (result < 0) {
 *     // Handle error
 * }
 *
 * @note IP_UDP client sockets can send datagrams without establishing a connection
 * @note For hostname resolution, ensure DNS is properly configured on the master
 */
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


/**
 * @function NAVClientSocketClose
 * @public
 * @description Closes a client socket connection.
 *
 * @param {integer} socket - Socket ID to close
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * result = NAVClientSocketClose(dvTCPClient.PORT)
 * if (result < 0) {
 *     // Handle error
 * }
 */
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


/**
 * @function NAVClientSecureSocketOpen
 * @public
 * @description Opens a secure (SSH) client socket connection.
 *
 * @param {integer} socket - Socket ID to use
 * @param {char[]} address - IP address or hostname of remote server
 * @param {integer} port - Port number to connect to (defaults to 22 if ≤ 0)
 * @param {char[]} username - SSH username for authentication
 * @param {char[]} password - SSH password for authentication (can be empty if using privateKey)
 * @param {char[]} privateKey - Path to SSH private key file (can be empty if using password)
 * @param {char[]} privateKeyPassphrase - Passphrase for private key (if required)
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * // Connect using username/password
 * result = NAVClientSecureSocketOpen(dvSSHClient.PORT, '10.0.0.1', 22, 'admin', 'password', '', '')
 *
 * // Connect using private key
 * result = NAVClientSecureSocketOpen(dvSSHClient.PORT, '10.0.0.1', 22, 'admin', '', '/amx/keys/id_rsa', '')
 *
 * @note Either password or privateKey must be provided
 * @note If port is ≤ 0, defaults to standard SSH port (22)
 */
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


/**
 * @function NAVClientSecureSocketClose
 * @public
 * @description Closes a secure (SSH) client socket connection.
 *
 * @param {integer} socket - Socket ID to close
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * result = NAVClientSecureSocketClose(dvSSHClient.PORT)
 * if (result < 0) {
 *     // Handle error
 * }
 */
define_function slong NAVClientSecureSocketClose(integer socket) {
    return ssh_client_close(socket)
}


#END_IF // __NAV_FOUNDATION_SOCKETUTILS__
