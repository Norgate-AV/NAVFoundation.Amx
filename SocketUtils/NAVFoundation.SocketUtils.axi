PROGRAM_NAME='NAVFoundation.SocketUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SOCKETUTILS__
#DEFINE __NAV_FOUNDATION_SOCKETUTILS__ 'NAVFoundation.SocketUtils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.TimelineUtils.axi'
#include 'NAVFoundation.NetUtils.axi'
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
 * stack_var char errorMessage[50]
 *
 * result = NAVClientSocketOpen(dvTCPClient.PORT, '192.168.1.100', 23, IP_TCP)
 * if (result < 0) {
 *     errorMessage = NAVGetSocketError(result)
 *     NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Socket error: ', errorMessage")
 * }
 */
define_function char[50] NAVGetSocketError(slong error) {
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
 * stack_var char protocolName[50]
 *
 * protocol = IP_TCP
 * protocolName = NAVGetSocketProtocol(protocol)  // Returns 'TCP'
 */
define_function char[50] NAVGetSocketProtocol(integer protocol) {
    switch (protocol) {
        case IP_TCP:        { return 'TCP' }
        case IP_UDP:        { return 'UDP' }
        case IP_UDP_2WAY:   { return 'UDP 2-Way' }
        default:            { return "'Unknown protocol (', itoa(protocol), ')'" }
    }
}


/**
 * @function NAVGetTlsSocketMode
 * @public
 * @description Converts a TLS mode constant to a human-readable mode name.
 *
 * @param {integer} mode - Protocol value (TLS_VALIDATE_CERTIFICATE, or TLS_IGNORE_CERTIFICATE_ERRORS)
 *
 * @returns {char[]} Human-readable mode name
 *
 * @example
 * stack_var integer mode
 * stack_var char modeName[50]
 *
 * mode = TLS_VALIDATE_CERTIFICATE
 * modeName = NAVGetTlsSocketMode(mode)  // Returns 'TLS Validate Certificate'
 */
define_function char[50] NAVGetTlsSocketMode(integer mode) {
    switch (mode) {
        case TLS_VALIDATE_CERTIFICATE:      { return 'TLS Validate Certificate' }
        case TLS_IGNORE_CERTIFICATE_ERRORS: { return 'TLS Ignore Certificate Errors' }
        default:                            { return "'Unknown mode (', itoa(mode), ')'" }
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


/**
 * @function NAVClientTlsSocketOpen
 * @public
 * @description Opens a TLS client socket connection to a remote server.
 *
 * @param {integer} socket - Socket ID to use
 * @param {char[]} address - IP address or hostname of remote server
 * @param {integer} port - Port number to connect to
 * @param {integer} mode - TLS_VALIDATE_CERTIFICATE (0), or TLS_IGNORE_CERTIFICATE_ERRORS (1)
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * // Connect to a device at 192.168.1.100 on port 23 (Telnet)
 * result = NAVClientTlsSocketOpen(dvTCPClient.PORT, '192.168.1.100', 23, 0)
 * if (result < 0) {
 *     // Handle error
 * }
 *
 * @note IP_UDP client sockets can send datagrams without establishing a connection
 * @note For hostname resolution, ensure DNS is properly configured on the master
 */
define_function slong NAVClientTlsSocketOpen(integer socket, char address[], integer port, integer mode) {
    stack_var slong result

    address = NAVTrimString(address)

    if (!length_array(address)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientTlsSocketOpen',
                                    "'The host address is an empty string.'")
        return NAV_SOCKET_ERROR_INVALID_HOST_ADDRESS
    }

    if (port <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientTlsSocketOpen',
                                    "NAVGetSocketError(NAV_SOCKET_ERROR_INVALID_PORT)")
        return NAV_SOCKET_ERROR_INVALID_PORT
    }

    result = tls_client_open(socket, address, port, mode)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientTlsSocketOpen',
                                    "'Failed to open socket to ', address, ':', itoa(port), ' TLS mode: ', NAVGetTlsSocketMode(mode)")
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientTlsSocketOpen',
                                    "'Socket error: ', NAVGetSocketError(result)")
    }

    return result
}


/**
 * @function NAVClientTlsSocketClose
 * @public
 * @description Closes a TLS client socket connection.
 *
 * @param {integer} socket - Socket ID to close
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * result = NAVClientTlsSocketClose(dvTCPClient.PORT)
 * if (result < 0) {
 *     // Handle error
 * }
 */
define_function slong NAVClientTlsSocketClose(integer socket) {
    stack_var slong result

    result = tls_client_close(socket)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SOCKETUTILS__,
                                    'NAVClientTlsSocketClose',
                                    "'Failed to close socket. ', NAVGetSocketError(result)")
    }

    return result
}


/**
 * @function NAVSocketGetExponentialBackoff
 * @public
 * @description Calculates an exponential backoff interval for socket connection retry attempts.
 *              Uses a base delay for initial attempts, then applies exponential backoff with jitter
 *              to prevent thundering herd problems.
 *
 * @param {integer} attempt - Current attempt number (1-based)
 * @param {integer} maxRetries - Number of attempts to use base delay before starting exponential backoff
 * @param {long} baseDelay - Base delay in milliseconds for initial attempts
 * @param {long} maxDelay - Maximum delay in milliseconds (cap for exponential growth)
 *
 * @returns {long} Calculated delay interval in milliseconds
 *
 * @example
 * stack_var integer attemptCount
 * stack_var long retryInterval
 *
 * attemptCount = 5
 * retryInterval = NAVSocketGetExponentialBackoff(attemptCount, 3, 5000, 300000)
 * // First 3 attempts: 5000ms
 * // 4th attempt: ~5000ms
 * // 5th attempt: ~10000ms + jitter
 * // 6th attempt: ~20000ms + jitter
 *
 * @note For attempts <= maxRetries, returns baseDelay
 * @note For attempts > maxRetries, uses formula: baseDelay * 2^(attempt - maxRetries) + jitter
 * @note Jitter is a random value between 100-1000ms to prevent synchronized retries
 * @note Final delay is capped at maxDelay (after jitter is added)
 */
define_function long NAVSocketGetExponentialBackoff(integer attempt,
                                                    integer maxRetries,
                                                    long baseDelay,
                                                    long maxDelay) {
    stack_var long interval
    stack_var long jitter
    stack_var integer exponent
    stack_var long multiplier

    // For first N attempts, use base delay
    if (attempt <= maxRetries) {
        interval = baseDelay
    }
    else {
        // After N attempts, start exponential backoff
        exponent = attempt - maxRetries

        // Cap exponent to prevent integer overflow
        // 2^20 = 1,048,576 - beyond this we'll hit maxDelay anyway
        if (exponent > 20) {
            exponent = 20
        }

        // Calculate 2^exponent
        multiplier = power_value(2, exponent)
        interval = baseDelay * multiplier

        // If we've already exceeded maxDelay, cap it before adding jitter
        if (interval > maxDelay) {
            interval = maxDelay
        }
        else {
            // Add jitter (100-1000ms) to prevent thundering herd
            // Note: random_number can return 0 on first call, so ensure minimum jitter
            jitter = random_number(10) * 100  // Should be 1-10 * 100ms = 100-1000ms
            if (jitter == 0) {
                jitter = 100  // Minimum jitter if random_number returns 0
            }

            interval = interval + jitter

            // Cap at maximum delay (after jitter)
            interval = min_value(interval, maxDelay)
        }
    }

    return interval
}


/**
 * @function NAVSocketGetConnectionInterval
 * @public
 * @description Calculates the retry interval for socket connection attempts using exponential backoff.
 *              This is a convenience wrapper around NAVSocketGetExponentialBackoff that uses
 *              the library's default retry constants.
 *
 * @param {integer} attempt - Current attempt number (1-based)
 *
 * @returns {long} Calculated delay interval in milliseconds
 *
 * @example
 * stack_var integer attemptCount
 * stack_var long retryInterval
 *
 * attemptCount++
 * retryInterval = NAVSocketGetConnectionInterval(attemptCount)
 * wait retryInterval 'SOCKET_RETRY' {
 *     NAVClientSocketOpen(dvTCPClient.PORT, '192.168.1.100', 23, IP_TCP)
 * }
 *
 * @note Uses NAV_MAX_SOCKET_CONNECTION_RETRIES (10 attempts before exponential backoff)
 * @note Uses NAV_SOCKET_CONNECTION_INTERVAL_BASE_DELAY (5000ms base delay)
 * @note Uses NAV_SOCKET_CONNECTION_INTERVAL_MAX_DELAY (300000ms maximum delay)
 * @note See NAVSocketGetExponentialBackoff for detailed backoff algorithm
 */
define_function long NAVSocketGetConnectionInterval(integer attempt) {
    return NAVSocketGetExponentialBackoff(attempt,
                                          NAV_MAX_SOCKET_CONNECTION_RETRIES,
                                          NAV_SOCKET_CONNECTION_INTERVAL_BASE_DELAY,
                                          NAV_SOCKET_CONNECTION_INTERVAL_MAX_DELAY)
}


/**
 * @function NAVSocketConnectionIsInitialized
 * @private
 * @description Internal helper to validate that a socket connection has been properly initialized.
 *              Logs an error if not initialized.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure to check
 * @param {char[]} functionName - Name of the calling function for error logging
 *
 * @returns {char} True if initialized, false otherwise
 */
define_function char NAVSocketConnectionIsInitialized(_NAVSocketConnection connection, char functionName[]) {
    if (!connection.IsInitialized) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   functionName,
                                   "'Connection not initialized. Call NAVSocketConnectionInit() first.'")
        return false
    }
    return true
}


/**
 * @function NAVSocketConnectionInit
 * @public
 * @description Initializes a socket connection structure with default values using an options struct.
 *              Performs validation on device, socket, and port parameters. If options.Id is empty,
 *              it will be automatically populated with the device string (e.g., "0:3:0").
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure to initialize
 * @param {_NAVSocketConnectionOptions} options - Options structure containing initialization parameters
 *
 * @returns {char} True (1) if initialization successful, false (0) if validation failed
 *
 * @example
 * // Automatic Id (will use device string like "0:3:0")
 * stack_var _NAVSocketConnectionOptions options
 * options.Device = dvPort
 * options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
 * options.Protocol = IP_TCP
 * options.Port = IP_PORT
 * options.TimelineId = TL_SOCKET_MAINTAIN
 * if (!NAVSocketConnectionInit(module.Device.SocketConnection, options)) {
 *     // Handle initialization failure
 * }
 *
 * // Custom Id for multiple instances
 * options.Id = 'Camera 1'
 * options.Device = dvCamera1
 * if (!NAVSocketConnectionInit(camera1Connection, options)) {
 *     // Handle initialization failure
 * }
 *
 * @note Device number must be 0 for socket connections
 * @note Socket number (device.PORT) must be greater than 1
 * @note Port must be in range 1-65535
 * @note ConnectionType must be NAV_SOCKET_CONNECTION_TYPE_TCP_UDP, _SSH, or _TLS
 * @note If options.Id is empty, it will be automatically set to NAVDeviceToString(options.Device)
 */
define_function char NAVSocketConnectionInit(_NAVSocketConnection connection,
                                             _NAVSocketConnectionOptions options) {
    // Validate device number must be 0 for socket connections
    if (options.Device.NUMBER != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionInit',
                                   "'Invalid device number: ', itoa(options.Device.NUMBER), ' (must be 0 for socket connections)'")
        return false
    }

    // Validate socket number must be greater than 1
    if (options.Device.PORT <= 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionInit',
                                   "'Invalid socket number: ', itoa(options.Device.PORT), ' (must be greater than 1)'")
        return false
    }

    // Auto-populate Id with device string if not provided
    if (options.Id == '') {
        options.Id = "'[', NAVDeviceToString(options.Device), ']'"
    }

    // Validate port range
    if (options.Port < 1 || options.Port > 65535) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionInit',
                                   "options.Id, ' Invalid port: ', itoa(options.Port), ' (must be between 1 and 65535)'")
        return false
    }

    // Validate timeline ID
    if (options.TimelineId <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionInit',
                                   "options.Id, ' Invalid timeline ID: ', itoa(options.TimelineId), ' (must be greater than 0)'")
        return false
    }

    // Validate connection type - default to TCP/UDP if not specified
    switch (options.ConnectionType) {
        case 0: {
            options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                       __NAV_FOUNDATION_SOCKETUTILS__,
                                       'NAVSocketConnectionInit',
                                       "options.Id, ' Connection type not specified, defaulting to TCP/UDP'")
        }
        case NAV_SOCKET_CONNECTION_TYPE_TCP_UDP:
        case NAV_SOCKET_CONNECTION_TYPE_SSH:
        case NAV_SOCKET_CONNECTION_TYPE_TLS: {
            // Valid connection types - no action needed
        }
        default: {
            options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                       __NAV_FOUNDATION_SOCKETUTILS__,
                                       'NAVSocketConnectionInit',
                                       "options.Id, ' Invalid connection type: ', itoa(options.ConnectionType), ' (must be TCP_UDP, SSH, or TLS), defaulting to TCP_UDP'")
        }
    }

    // Validate protocol - only relevant for TCP_UDP connection types, default to IP_TCP if not specified
    if (options.ConnectionType == NAV_SOCKET_CONNECTION_TYPE_TCP_UDP) {
        switch (options.Protocol) {
            case 0: {
                options.Protocol = IP_TCP
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                           __NAV_FOUNDATION_SOCKETUTILS__,
                                           'NAVSocketConnectionInit',
                                           "options.Id, ': Protocol not specified, defaulting to TCP'")
            }
            case IP_TCP:
            case IP_UDP:
            case IP_UDP_2WAY: {
                // Valid protocols - no action needed
            }
            default: {
                options.Protocol = IP_TCP
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                           __NAV_FOUNDATION_SOCKETUTILS__,
                                           'NAVSocketConnectionInit',
                                           "options.Id, ': Invalid protocol: ', itoa(options.Protocol), ' (must be TCP, UDP, or UDP 2-Way), defaulting to TCP'")
            }
        }
    }

    // Validate TLS mode - only relevant for TLS connection types
    if (options.ConnectionType == NAV_SOCKET_CONNECTION_TYPE_TLS) {
        switch (options.TlsMode) {
            case TLS_VALIDATE_CERTIFICATE:
            case TLS_IGNORE_CERTIFICATE_ERRORS: {
                // Valid TLS modes - no action needed
            }
            default: {
                options.TlsMode = TLS_VALIDATE_CERTIFICATE
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                           __NAV_FOUNDATION_SOCKETUTILS__,
                                           'NAVSocketConnectionInit',
                                           "options.Id, ': Invalid TLS mode: ', itoa(options.TlsMode), ' (must be TLS_VALIDATE_CERTIFICATE or TLS_IGNORE_CERTIFICATE_ERRORS), defaulting to TLS_VALIDATE_CERTIFICATE'")
            }
        }
    }

    // Validate SSH credentials - only relevant for SSH connection types
    if (options.ConnectionType == NAV_SOCKET_CONNECTION_TYPE_SSH) {
        if (!length_array(options.SshUsername)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                       __NAV_FOUNDATION_SOCKETUTILS__,
                                       'NAVSocketConnectionInit',
                                       "options.Id, ': SSH username is required for SSH connections'")
            return false
        }

        if (!length_array(options.SshPassword) && !length_array(options.SshPrivateKey)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                       __NAV_FOUNDATION_SOCKETUTILS__,
                                       'NAVSocketConnectionInit',
                                       "options.Id, ': Either SSH password or private key is required for SSH connections'")
            return false
        }
    }

    // All validations passed, initialize the connection
    connection.Device = options.Device
    connection.Id = options.Id
    connection.Socket = options.Device.PORT
    connection.ConnectionType = options.ConnectionType
    connection.Protocol = options.Protocol
    connection.Port = options.Port
    connection.TlsMode = options.TlsMode

    connection.Credential.Username = options.SshUsername
    connection.Credential.Password = options.SshPassword
    connection.SshPrivateKey = options.SshPrivateKey
    connection.SshPrivateKeyPassphrase = options.SshPrivateKeyPassphrase

    connection.IsConnected = false
    connection.IsNegotiated = false
    connection.IsAuthenticated = false
    connection.IsInitialized = true

    connection.AutoReconnect = true

    connection.TimelineId = options.TimelineId
    connection.RetryCount = 0
    connection.Interval[1] = NAVSocketGetConnectionInterval(connection.RetryCount)

    return true
}


/**
 * @function NAVSocketConnectionSetAddress
 * @public
 * @description Sets the address for a socket connection with validation.
 *              Validates both IP addresses and hostnames before setting.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 * @param {char[]} address - IP address or hostname
 *
 * @returns {char} True if address was valid and set (or cleared), false if invalid
 *
 * @example
 * if (NAVSocketConnectionSetAddress(module.Device.SocketConnection, '192.168.1.100')) {
 *     NAVSocketConnectionReset(module.Device.SocketConnection)  // Apply changes
 * }
 *
 * @note Empty addresses are accepted and will clear the connection (returns true)
 * @note Invalid addresses will be rejected and an error will be logged (returns false)
 * @note You must call NAVSocketConnectionReset() after changing connection properties to apply changes
 */
define_function char NAVSocketConnectionSetAddress(_NAVSocketConnection connection, char address[]) {
    stack_var _NAVIP ip
    stack_var char addr[255]

    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionSetAddress')) {
        return false
    }

    addr = NAVTrimString(address)

    // Handle empty address - only allow clearing if there's an existing address
    if (!length_array(addr)) {
        if (!length_array(connection.Address)) {
            // Address is already empty, cannot clear nothing
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                       __NAV_FOUNDATION_SOCKETUTILS__,
                                       'NAVSocketConnectionSetAddress',
                                       "connection.Id, ': Address cannot be empty'")
            return false
        }

        // Clear existing address
        connection.Address = ''
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_INFO,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionSetAddress',
                                   "connection.Id, ': Clearing IP address'")
        return true
    }

    // Try to parse as IP address first
    if (NAVNetParseIP(addr, ip)) {
        connection.Address = ip.Address
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_INFO,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionSetAddress',
                                   "connection.Id, ': Using IP address: ', ip.Address")
        return true
    }

    // Reject if it looks like a malformed IP address (contains only digits and dots)
    // This prevents treating "256.1.1.1" or "192.168.1" as hostnames
    if (NAVNetIsMalformedIP(addr)) {
        connection.Address = ''
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionSetAddress',
                                   "connection.Id, ': Malformed IP address: ', addr")
        return false
    }

    {
        stack_var _NAVHostname hostname

        if (NAVNetParseHostname(addr, hostname)) {
            connection.Address = hostname.Hostname
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_INFO,
                                       __NAV_FOUNDATION_SOCKETUTILS__,
                                       'NAVSocketConnectionSetAddress',
                                       "connection.Id, ': Using hostname: ', hostname.Hostname")
            return true
        }
    }

    // Invalid address - reject and log error
    connection.Address = ''
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                               __NAV_FOUNDATION_SOCKETUTILS__,
                               'NAVSocketConnectionSetAddress',
                               "connection.Id, ': Invalid IP address or hostname: ', addr")
    return false
}


/**
 * @function NAVSocketConnectionSetPort
 * @public
 * @description Sets the port for a socket connection with validation.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 * @param {integer} port - Port number (1-65535)
 *
 * @returns {char} True if port was valid and set, false if invalid
 *
 * @example
 * if (NAVSocketConnectionSetPort(module.Device.SocketConnection, 23)) {
 *     NAVSocketConnectionReset(module.Device.SocketConnection)  // Apply changes
 * }
 *
 * @note Port must be between 1 and 65535 (inclusive)
 * @note You must call NAVSocketConnectionReset() after changing connection properties to apply changes
 */
define_function char NAVSocketConnectionSetPort(_NAVSocketConnection connection, integer port) {
    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionSetPort')) {
        return false
    }

    // Validate port range
    if (port <= 0 || port > 65535) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionSetPort',
                                   "connection.Id, ': Invalid port number: ', itoa(port), ' (must be 1-65535)'")
        return false
    }

    connection.Port = port
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_INFO,
                               __NAV_FOUNDATION_SOCKETUTILS__,
                               'NAVSocketConnectionSetPort',
                               "connection.Id, ': Port set to ', itoa(port)")
    return true
}


/**
 * @function NAVSocketConnectionSetAutoReconnect
 * @public
 * @description Enables or disables automatic reconnection for a socket connection.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 * @param {char} enabled - True to enable auto-reconnect, false to disable
 *
 * @example
 * // Disable auto-reconnect
 * NAVSocketConnectionSetAutoReconnect(module.Device.SocketConnection, false)
 *
 * // Enable auto-reconnect
 * NAVSocketConnectionSetAutoReconnect(module.Device.SocketConnection, true)
 */
define_function NAVSocketConnectionSetAutoReconnect(_NAVSocketConnection connection, char enabled) {
    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionSetAutoReconnect')) {
        return
    }

    connection.AutoReconnect = enabled

    if (enabled) {
        // Start the timeline if auto-reconnect is being enabled
        NAVSocketConnectionStart(connection)
    }
    else {
        // Stop the timeline if auto-reconnect is being disabled
        NAVTimelineStop(connection.TimelineId)
    }
}


/**
 * @function NAVSocketConnectionSetCredential
 * @public
 * @description Sets username and password credentials for authenticated connections (SSH).
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 * @param {char[]} username - Username for authentication
 * @param {char[]} password - Password for authentication
 *
 * @returns {char} True if credentials were set successfully, false if validation failed
 *
 * @example
 * if (NAVSocketConnectionSetCredential(module.Device.SocketConnection, 'admin', 'password123')) {
 *     // Credentials valid
 * }
 */
define_function char NAVSocketConnectionSetCredential(_NAVSocketConnection connection, char username[], char password[]) {
    stack_var char trimmedUsername[NAV_MAX_CHARS]

    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionSetCredential')) {
        return false
    }

    // Create internal copy before trimming
    trimmedUsername = username
    trimmedUsername = NAVTrimString(trimmedUsername)

    if (!length_array(trimmedUsername)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionSetCredential',
                                   "connection.Id, ': Username cannot be empty'")
        return false
    }

    connection.Credential.Username = trimmedUsername
    connection.Credential.Password = password
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_SOCKETUTILS__,
                               'NAVSocketConnectionSetCredential',
                               "connection.Id, ': Credentials set for user: ', trimmedUsername")
    return true
}


/**
 * @function NAVSocketConnectionSetSshPrivateKey
 * @public
 * @description Sets SSH private key authentication parameters.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 * @param {char[]} privateKey - Path to SSH private key file
 * @param {char[]} passphrase - Passphrase for private key (empty if not required)
 *
 * @returns {char} True if private key path was set successfully, false if validation failed
 *
 * @example
 * if (NAVSocketConnectionSetSshPrivateKey(module.Device.SocketConnection, '/amx/keys/id_rsa', '')) {
 *     // Private key path valid
 * }
 */
define_function char NAVSocketConnectionSetSshPrivateKey(_NAVSocketConnection connection, char privateKey[], char passphrase[]) {
    stack_var char trimmedPrivateKey[NAV_MAX_CHARS]

    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionSetSshPrivateKey')) {
        return false
    }

    // Create internal copy before trimming
    trimmedPrivateKey = privateKey
    trimmedPrivateKey = NAVTrimString(trimmedPrivateKey)

    if (!length_array(trimmedPrivateKey)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionSetSshPrivateKey',
                                   "connection.Id, ': Private key path cannot be empty'")
        return false
    }

    connection.SshPrivateKey = trimmedPrivateKey
    connection.SshPrivateKeyPassphrase = passphrase
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_SOCKETUTILS__,
                               'NAVSocketConnectionSetSshPrivateKey',
                               "connection.Id, ': SSH private key configured'")
    return true
}


/**
 * @function NAVSocketConnectionSetTlsMode
 * @public
 * @description Sets the TLS certificate validation mode.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 * @param {integer} mode - TLS_VALIDATE_CERTIFICATE (0) or TLS_IGNORE_CERTIFICATE_ERRORS (1)
 *
 * @returns {char} True if mode was valid and set successfully, false if validation failed
 *
 * @example
 * if (NAVSocketConnectionSetTlsMode(module.Device.SocketConnection, TLS_VALIDATE_CERTIFICATE)) {
 *     // TLS mode valid
 * }
 */
define_function char NAVSocketConnectionSetTlsMode(_NAVSocketConnection connection, integer mode) {
    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionSetTlsMode')) {
        return false
    }

    if (mode != TLS_VALIDATE_CERTIFICATE && mode != TLS_IGNORE_CERTIFICATE_ERRORS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionSetTlsMode',
                                   "connection.Id, ': Invalid TLS mode: ', itoa(mode), ' (must be TLS_VALIDATE_CERTIFICATE or TLS_IGNORE_CERTIFICATE_ERRORS)'")
        return false
    }

    connection.TlsMode = mode
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_SOCKETUTILS__,
                               'NAVSocketConnectionSetTlsMode',
                               "connection.Id, ': TLS mode set to: ', NAVGetTlsSocketMode(mode)")
    return true
}


/**
 * @function NAVSocketConnectionIsConfigured
 * @public
 * @description Checks if a socket connection has been properly configured.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 *
 * @returns {char} True if address and port are configured, false otherwise
 *
 * @example
 * if (NAVSocketConnectionIsConfigured(module.Device.SocketConnection)) {
 *     // Connection can be established
 * }
 */
define_function char NAVSocketConnectionIsConfigured(_NAVSocketConnection connection) {
    return (length_array(connection.Address) && connection.Port > 0)
}


/**
 * @function NAVSocketConnectionMaintain
 * @public
 * @description Maintains a socket connection by attempting to reconnect if disconnected.
 *              Automatically handles TCP, SSH, and TLS connections based on ConnectionType.
 *              Call this from a timeline event handler.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 *
 * @example
 * timeline_event[TL_SOCKET_CHECK] {
 *     NAVSocketConnectionMaintain(module.Device.SocketConnection)
 * }
 */
define_function NAVSocketConnectionMaintain(_NAVSocketConnection connection) {
    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionMaintain')) {
        return
    }

    if (connection.IsConnected) {
        return
    }

    if (!connection.AutoReconnect) {
        return
    }

    if (!NAVSocketConnectionIsConfigured(connection)) {
        return
    }

    switch (connection.ConnectionType) {
        case NAV_SOCKET_CONNECTION_TYPE_TCP_UDP: {
            NAVClientSocketOpen(connection.Socket,
                                connection.Address,
                                connection.Port,
                                connection.Protocol)
        }
        case NAV_SOCKET_CONNECTION_TYPE_SSH: {
            NAVClientSecureSocketOpen(connection.Socket,
                                      connection.Address,
                                      connection.Port,
                                      connection.Credential.Username,
                                      connection.Credential.Password,
                                      connection.SshPrivateKey,
                                      connection.SshPrivateKeyPassphrase)
        }
        case NAV_SOCKET_CONNECTION_TYPE_TLS: {
            NAVClientTlsSocketOpen(connection.Socket,
                                   connection.Address,
                                   connection.Port,
                                   connection.TlsMode)
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_SOCKETUTILS__,
                                       'NAVSocketConnectionMaintain',
                                       "connection.Id, ': Unknown connection type: ', itoa(connection.ConnectionType)")
        }
    }
}


/**
 * @function NAVSocketConnectionStart
 * @public
 * @description Starts the socket connection timeline for automatic reconnection.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 *
 * @example
 * NAVSocketConnectionStart(module.Device.SocketConnection)
 */
define_function NAVSocketConnectionStart(_NAVSocketConnection connection) {
    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionStart')) {
        return
    }

    if (!NAVSocketConnectionIsConfigured(connection)) {
        return
    }

    if (!connection.AutoReconnect) {
        return
    }

    NAVTimelineStart(connection.TimelineId,
                     connection.Interval,
                     TIMELINE_ABSOLUTE,
                     TIMELINE_REPEAT)
}


/**
 * @function NAVSocketConnectionStop
 * @public
 * @description Stops the socket connection timeline and closes the connection.
 *              Automatically handles TCP, SSH, and TLS connections based on ConnectionType.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 *
 * @example
 * NAVSocketConnectionStop(module.Device.SocketConnection)
 */
define_function NAVSocketConnectionStop(_NAVSocketConnection connection) {
    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionStop')) {
        return
    }

    NAVTimelineStop(connection.TimelineId)

    if (connection.IsConnected) {
        switch (connection.ConnectionType) {
            case NAV_SOCKET_CONNECTION_TYPE_TCP_UDP: {
                NAVClientSocketClose(connection.Socket)
            }
            case NAV_SOCKET_CONNECTION_TYPE_SSH: {
                NAVClientSecureSocketClose(connection.Socket)
            }
            case NAV_SOCKET_CONNECTION_TYPE_TLS: {
                NAVClientTlsSocketClose(connection.Socket)
            }
        }
    }
}


/**
 * @function NAVSocketConnectionReset
 * @public
 * @description Resets a socket connection by closing it, resetting retry counters,
 *              and restarting the connection timeline. Automatically handles TCP, SSH,
 *              and TLS connections based on ConnectionType.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 *
 * @example
 * NAVSocketConnectionReset(module.Device.SocketConnection)
 */
define_function NAVSocketConnectionReset(_NAVSocketConnection connection) {
    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionReset')) {
        return
    }

    NAVTimelineStop(connection.TimelineId)

    if (connection.IsConnected) {
        switch (connection.ConnectionType) {
            case NAV_SOCKET_CONNECTION_TYPE_TCP_UDP: {
                NAVClientSocketClose(connection.Socket)
            }
            case NAV_SOCKET_CONNECTION_TYPE_SSH: {
                NAVClientSecureSocketClose(connection.Socket)
            }
            case NAV_SOCKET_CONNECTION_TYPE_TLS: {
                NAVClientTlsSocketClose(connection.Socket)
            }
        }
    }

    // Always reset retry count for clean state
    connection.RetryCount = 0
    connection.Interval[1] = NAVSocketGetConnectionInterval(connection.RetryCount)

    // Restart timeline if configured and auto-reconnect is enabled
    NAVSocketConnectionStart(connection)
}


/**
 * @function NAVSocketConnectionHandleOnline
 * @public
 * @description Handles the online event for a socket connection.
 *              Call this from the online handler in data_event.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 * @param {tdata} data - Event data from data_event
 *
 * @example
 * data_event[dvPort] {
 *     online: {
 *         NAVSocketConnectionHandleOnline(module.Device.SocketConnection, data)
 *         // Module-specific online handling...
 *     }
 * }
 */
define_function NAVSocketConnectionHandleOnline(_NAVSocketConnection connection, tdata data) {
    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionHandleOnline')) {
        return
    }

    // Only handle IP connection events (device.number == 0)
    if (data.device.number != 0) {
        return
    }

    connection.IsConnected = true

    // Reset retry count on successful connection
    connection.RetryCount = 0
    connection.Interval[1] = NAVSocketGetConnectionInterval(connection.RetryCount)
    NAVTimelineReload(connection.TimelineId, connection.Interval)

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_INFO,
                               __NAV_FOUNDATION_SOCKETUTILS__,
                               'NAVSocketConnectionHandleOnline',
                               "connection.Id, ': Socket connected to ', connection.Address, ':', itoa(connection.Port)")
}


/**
 * @function NAVSocketConnectionHandleOffline
 * @public
 * @description Handles the offline event for a socket connection.
 *              Call this from the offline handler in data_event.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 * @param {tdata} data - Event data from data_event
 *
 * @example
 * data_event[dvPort] {
 *     offline: {
 *         NAVSocketConnectionHandleOffline(module.Device.SocketConnection, data)
 *         // Module-specific offline handling...
 *     }
 * }
 */
define_function NAVSocketConnectionHandleOffline(_NAVSocketConnection connection, tdata data) {
    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionHandleOffline')) {
        return
    }

    // Only handle IP connection events (device.number == 0)
    if (data.device.number != 0) {
        return
    }

    NAVClientSocketClose(data.device.port)

    connection.IsConnected = false
    connection.IsNegotiated = false
    connection.IsAuthenticated = false

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_INFO,
                               __NAV_FOUNDATION_SOCKETUTILS__,
                               'NAVSocketConnectionHandleOffline',
                               "connection.Id, ': Socket disconnected from ', connection.Address, ':', itoa(connection.Port)")
}


/**
 * @function NAVSocketConnectionHandleError
 * @public
 * @description Handles the onerror event for a socket connection with exponential backoff.
 *              Call this from the onerror handler in data_event.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 * @param {tdata} data - Event data from data_event
 *
 * @example
 * data_event[dvPort] {
 *     onerror: {
 *         NAVSocketConnectionHandleError(module.Device.SocketConnection, data)
 *         // Module-specific error handling...
 *     }
 * }
 */
define_function NAVSocketConnectionHandleError(_NAVSocketConnection connection, tdata data) {
    if (!NAVSocketConnectionIsInitialized(connection, 'NAVSocketConnectionHandleError')) {
        return
    }

    // Only handle IP connection events (device.number == 0)
    if (data.device.number != 0) {
        return
    }

    connection.RetryCount++

    // Single consolidated warning with all relevant information
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                               __NAV_FOUNDATION_SOCKETUTILS__,
                               'NAVSocketConnectionHandleError',
                               "connection.Id, ': Connection failed - ', NAVGetSocketError(type_cast(data.number)), ' (retry ', itoa(connection.RetryCount), ' in ', itoa(connection.Interval[1]), 'ms)'")

    if (connection.RetryCount <= NAV_MAX_SOCKET_CONNECTION_RETRIES) {
        // Still in base retry phase - timeline already running at base interval
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                   __NAV_FOUNDATION_SOCKETUTILS__,
                                   'NAVSocketConnectionHandleError',
                                   "connection.Id, ': Using base retry interval: ', itoa(connection.Interval[1]), 'ms'")
        return
    }

    // Calculate new exponential backoff interval
    connection.Interval[1] = NAVSocketGetConnectionInterval(connection.RetryCount)

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_SOCKETUTILS__,
                               'NAVSocketConnectionHandleError',
                               "connection.Id, ': Using exponential backoff interval: ', itoa(connection.Interval[1]), 'ms'")

    // Restart timeline with new interval
    NAVTimelineReload(connection.TimelineId, connection.Interval)
}


/**
 * @function NAVIsSocketDevice
 * @public
 * @description Validates if a device is a valid socket device for IP connections.
 *              Checks that the device number is 0 (required for IP connections)
 *              and that the socket/port number is greater than 1.
 *
 * @param {dev} device - Device to validate
 *
 * @returns {char} True if device is a valid socket device, false otherwise
 *
 * @example
 * if (NAVIsSocketDevice(dvPort)) {
 *     // Valid socket device
 * }
 *
 * @note Device number must be 0 for IP socket connections
 * @note Socket number (PORT) must be greater than 1 (port 1 is reserved)
 */
define_function char NAVIsSocketDevice(dev device) {
    return (device.NUMBER == 0 && device.PORT > 1)
}


/**
 * @function NAVSocketConnectionGetStatus
 * @public
 * @description Returns a human-readable status string for a socket connection.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 *
 * @returns {char[]} Status string (e.g., "Connected", "Disconnected", "Connecting", "Not Configured")
 *
 * @example
 * stack_var char status[50]
 * status = NAVSocketConnectionGetStatus(module.Device.SocketConnection)
 * // Returns: "Connected" or "Connecting (attempt 3)" or "Disconnected"
 */
define_function char[50] NAVSocketConnectionGetStatus(_NAVSocketConnection connection) {
    if (!NAVSocketConnectionIsConfigured(connection)) {
        return 'Not Configured'
    }

    if (connection.IsConnected) {
        return 'Connected'
    }

    if (connection.AutoReconnect && connection.RetryCount > 0) {
        return "'Connecting (attempt ', itoa(connection.RetryCount), ')'"
    }

    return 'Disconnected'
}


/**
 * @function NAVSocketConnectionGetConnectionTypeString
 * @public
 * @description Converts a connection type constant to a human-readable string.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 *
 * @returns {char[]} Connection type string ("TCP", "SSH", "TLS", or "Unknown")
 *
 * @example
 * stack_var char connType[50]
 * connType = NAVSocketConnectionGetConnectionTypeString(module.Device.SocketConnection)
 */
define_function char[50] NAVSocketConnectionGetConnectionTypeString(_NAVSocketConnection connection) {
    switch (connection.ConnectionType) {
        case NAV_SOCKET_CONNECTION_TYPE_TCP_UDP: { return 'TCP/UDP' }
        case NAV_SOCKET_CONNECTION_TYPE_SSH: { return 'SSH' }
        case NAV_SOCKET_CONNECTION_TYPE_TLS: { return 'TLS' }
        default: { return "'Unknown (', itoa(connection.ConnectionType), ')'" }
    }
}


/**
 * @function NAVSocketConnectionIsRetrying
 * @public
 * @description Checks if a socket connection is currently in retry/backoff phase.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 *
 * @returns {char} True if connection is retrying (has failed at least once), false otherwise
 *
 * @example
 * if (NAVSocketConnectionIsRetrying(module.Device.SocketConnection)) {
 *     // Connection has failed and is retrying
 * }
 */
define_function char NAVSocketConnectionIsRetrying(_NAVSocketConnection connection) {
    return (connection.RetryCount > 0 && !connection.IsConnected)
}


/**
 * @function NAVSocketConnectionIsConnected
 * @public
 * @description Checks if a socket connection is currently connected.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 *
 * @returns {char} True if connection is connected, false otherwise
 *
 * @example
 * if (NAVSocketConnectionIsConnected(module.Device.SocketConnection)) {
 *     // Socket is connected
 *     send_string module.Device.SocketConnection.Socket, "'COMMAND'"
 * }
 */
define_function char NAVSocketConnectionIsConnected(_NAVSocketConnection connection) {
    return connection.IsConnected
}


/**
 * @function NAVSocketConnectionGetInfo
 * @public
 * @description Returns a formatted string with connection information for logging/debugging.
 *
 * @param {_NAVSocketConnection} connection - Socket connection structure
 *
 * @returns {char[]} Formatted connection info string
 *
 * @example
 * stack_var char info[255]
 * info = NAVSocketConnectionGetInfo(module.Device.SocketConnection)
 * // Returns: "WolfVision Visualizer [TCP] 192.168.1.100:50915 - Connected"
 */
define_function char[255] NAVSocketConnectionGetInfo(_NAVSocketConnection connection) {
    stack_var char info[255]

    info = "connection.Id, ' [', NAVSocketConnectionGetConnectionTypeString(connection), ']'"

    if (length_array(connection.Address)) {
        info = "info, ' ', connection.Address, ':', itoa(connection.Port)"
    }
    else {
        info = "info, ' [No Address]'"
    }

    info = "info, ' - ', NAVSocketConnectionGetStatus(connection)"

    return info
}


#END_IF // __NAV_FOUNDATION_SOCKETUTILS__
