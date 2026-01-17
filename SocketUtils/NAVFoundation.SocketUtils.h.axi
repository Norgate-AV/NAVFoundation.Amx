PROGRAM_NAME='NAVFoundation.SocketUtils.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SOCKETUTILS_H__
#DEFINE __NAV_FOUNDATION_SOCKETUTILS_H__ 'NAVFoundation.SocketUtils.h'


DEFINE_CONSTANT

/**
 * @section Socket Error Constants
 * @description Error codes returned by socket operations
 */

/**
 * @constant NAV_SOCKET_ERROR_INVALID_SERVER_PORT
 * @description Error: Invalid server port specified
 */
constant slong NAV_SOCKET_ERROR_INVALID_SERVER_PORT             = -1

/**
 * @constant NAV_SOCKET_ERROR_INVALID_PROTOCOL_VALUE
 * @description Error: Invalid protocol value specified
 */
constant slong NAV_SOCKET_ERROR_INVALID_PROTOCOL_VALUE          = -2

/**
 * @constant NAV_SOCKET_ERROR_UNABLE_TO_OPEN_PORT
 * @description Error: Unable to open communication port
 */
constant slong NAV_SOCKET_ERROR_UNABLE_TO_OPEN_PORT             = -3

/**
 * @constant NAV_SOCKET_ERROR_INVALID_HOST_ADDRESS
 * @description Error: Invalid host address provided
 */
constant slong NAV_SOCKET_ERROR_INVALID_HOST_ADDRESS            = -10

/**
 * @constant NAV_SOCKET_ERROR_INVALID_PORT
 * @description Error: Invalid port number specified
 */
constant slong NAV_SOCKET_ERROR_INVALID_PORT                    = -11

/**
 * @constant NAV_SOCKET_ERROR_GENERAL_FAILURE
 * @description Error: General failure (usually out of memory)
 */
constant slong NAV_SOCKET_ERROR_GENERAL_FAILURE                 = 2

/**
 * @constant NAV_SOCKET_ERROR_UNKNOWN_HOST
 * @description Error: Unknown host (DNS resolution failed)
 */
constant slong NAV_SOCKET_ERROR_UNKNOWN_HOST                    = 4

/**
 * @constant NAV_SOCKET_ERROR_CONNECTION_REFUSED
 * @description Error: Connection refused by remote host
 */
constant slong NAV_SOCKET_ERROR_CONNECTION_REFUSED              = 6

/**
 * @constant NAV_SOCKET_ERROR_CONNECTION_TIMED_OUT
 * @description Error: Connection attempt timed out
 */
constant slong NAV_SOCKET_ERROR_CONNECTION_TIMED_OUT            = 7

/**
 * @constant NAV_SOCKET_ERROR_UNKNOWN_CONNECTION_ERROR
 * @description Error: Unknown connection error
 */
constant slong NAV_SOCKET_ERROR_UNKNOWN_CONNECTION_ERROR        = 8

/**
 * @constant NAV_SOCKET_ERROR_ALREADY_CLOSED
 * @description Error: Socket is already closed
 */
constant slong NAV_SOCKET_ERROR_ALREADY_CLOSED                  = 9

/**
 * @constant NAV_SOCKET_ERROR_BINDING_ERROR
 * @description Error: Unable to bind socket to address/port
 */
constant slong NAV_SOCKET_ERROR_BINDING_ERROR                   = 10

/**
 * @constant NAV_SOCKET_ERROR_LISTENING_ERROR
 * @description Error: Unable to start listening on socket
 */
constant slong NAV_SOCKET_ERROR_LISTENING_ERROR                 = 11

/**
 * @constant NAV_SOCKET_ERROR_LOCAL_PORT_ALREADY_USED
 * @description Error: The specified local port is already in use
 */
constant slong NAV_SOCKET_ERROR_LOCAL_PORT_ALREADY_USED         = 14

/**
 * @constant NAV_SOCKET_ERROR_UDP_SOCKET_ALREADY_LISTENING
 * @description Error: UDP socket is already listening
 */
constant slong NAV_SOCKET_ERROR_UDP_SOCKET_ALREADY_LISTENING    = 15

/**
 * @constant NAV_SOCKET_ERROR_TOO_MANY_OPEN_SOCKETS
 * @description Error: Too many open sockets (system limit reached)
 */
constant slong NAV_SOCKET_ERROR_TOO_MANY_OPEN_SOCKETS           = 16

/**
 * @constant NAV_SOCKET_ERROR_LOCAL_PORT_NOT_OPEN
 * @description Error: The specified local port is not open
 */
constant slong NAV_SOCKET_ERROR_LOCAL_PORT_NOT_OPEN             = 17


/**
 * @section Socket Retry and Backoff Constants
 * @description Configuration constants for socket connection retry behavior and exponential backoff
 */

/**
 * @constant NAV_MAX_SOCKET_CONNECTION_RETRIES
 * @description Maximum number of connection retry attempts before starting exponential backoff.
 *              The first 10 attempts will use the base delay, then exponential backoff begins.
 * @default 10
 */
#IF_NOT_DEFINED NAV_MAX_SOCKET_CONNECTION_RETRIES
constant integer NAV_MAX_SOCKET_CONNECTION_RETRIES = 10
#END_IF

/**
 * @constant NAV_SOCKET_CONNECTION_INTERVAL_BASE_DELAY
 * @description Base delay in milliseconds between socket connection retry attempts.
 *              This delay is used for the first N attempts (where N = NAV_MAX_SOCKET_CONNECTION_RETRIES),
 *              and serves as the base for exponential backoff calculations on subsequent attempts.
 * @default 5000 (5 seconds)
 */
#IF_NOT_DEFINED NAV_SOCKET_CONNECTION_INTERVAL_BASE_DELAY
constant long NAV_SOCKET_CONNECTION_INTERVAL_BASE_DELAY = 5000          // 5 seconds
#END_IF

/**
 * @constant NAV_SOCKET_CONNECTION_INTERVAL_MAX_DELAY
 * @description Maximum delay in milliseconds between socket connection retry attempts.
 *              This value caps the exponential backoff to prevent excessively long wait times.
 *              Even with exponential growth, the delay will never exceed this value.
 * @default 300000 (5 minutes)
 */
#IF_NOT_DEFINED NAV_SOCKET_CONNECTION_INTERVAL_MAX_DELAY
constant long NAV_SOCKET_CONNECTION_INTERVAL_MAX_DELAY = 300000         // 5 minutes
#END_IF


#END_IF // __NAV_FOUNDATION_SOCKETUTILS_H__
