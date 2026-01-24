PROGRAM_NAME='NAVFoundation.WebSocket'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_WEBSOCKET__
#DEFINE __NAV_FOUNDATION_WEBSOCKET__ 'NAVFoundation.WebSocket'

#include 'NAVFoundation.WebSocket.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.Encoding.Base64.axi'
#include 'NAVFoundation.Encoding.Utf8.axi'
#include 'NAVFoundation.Cryptography.Sha1.axi'
#include 'NAVFoundation.HttpUtils.axi'
#include 'NAVFoundation.Url.axi'
#include 'NAVFoundation.SocketUtils.axi'


// =============================================================================
// WebSocket Send Helper Functions
// =============================================================================

/**
 * Sends a pre-built WebSocket frame to a device.
 * Internal helper function - users should call NAVWebSocketSend() instead.
 *
 * @function NAVWebSocketSendFrame
 * @access private
 * @param {dev} device - The device to send the frame to
 * @param {char[]} frame - The frame data to send
 * @returns {char} TRUE if sent successfully, FALSE otherwise
 */
define_function char NAVWebSocketSendFrame(dev device, char frame[]) {
    stack_var long frameLength

    frameLength = length_array(frame)

    if (frameLength == 0) {
        return false
    }

    send_string device, frame

    return true
}


// =============================================================================
// WebSocket Context Management Functions
// =============================================================================

/**
 * Initializes a WebSocket context structure.
 *
 * @function NAVWebSocketInit
 * @access public
 * @param {_NAVWebSocket} ws - WebSocket context to initialize
 * @param {dev} device - Network device to use for the connection
 *
 * @example
 * stack_var _NAVWebSocket ws
 *
 * NAVWebSocketInit(ws, dvSocket)
 * if (NAVWebSocketConnect(ws, 'ws://localhost:8080')) {
 *     // TCP connection initiated
 * }
 */
define_function NAVWebSocketInit(_NAVWebSocket ws, dev device) {
    ws.Device = device

    // Initialize URL struct fields
    ws.Url.Scheme = ''
    ws.Url.Host = ''
    ws.Url.Port = 0
    ws.Url.Path = ''
    ws.Url.FullPath = ''
    ws.Url.Fragment = ''
    ws.Url.HasUserInfo = false
    ws.Url.UserInfo.Username = ''
    ws.Url.UserInfo.Password = ''

    ws.IsConnected = false
    ws.HandshakeRequest = ''

    // Initialize RxBuffer
    NAVWebSocketBufferInit(ws.RxBuffer)
}

/**
 * Connects to a WebSocket server by parsing the URL and opening a TCP socket.
 * This handles URL parsing, handshake preparation, and socket connection.
 *
 * @function NAVWebSocketConnect
 * @access public
 * @param {_NAVWebSocket} ws - WebSocket context (must be initialized with NAVWebSocketInit)
 * @param {char[]} url - Complete WebSocket URL (e.g., 'ws://example.com:8080/socket')
 * @returns {char} TRUE if connection initiated successfully, FALSE otherwise
 *
 * @example
 * stack_var _NAVWebSocket ws
 *
 * NAVWebSocketInit(ws, dvSocket)
 * if (NAVWebSocketConnect(ws, 'ws://localhost:8080/chat')) {
 *     // Connection initiated, wait for NAVWebSocketOnOpenCallback
 * }
 */
define_function char NAVWebSocketConnect(_NAVWebSocket ws, char url[]) {
    stack_var _NAVUrl parsedUrl

    // Don't connect if already connected
    if (NAVWebSocketIsOpen(ws)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketConnect',
                                   'WebSocket is already connected')
        return false
    }

    if (!NAVParseUrl(url, parsedUrl)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketConnect',
                                   'Failed to parse URL')
        return false
    }

    // Store parsed URL
    ws.Url = parsedUrl

    if (!NAVWebSocketBuildHandshakeRequest(url, ws.HandshakeRequest, ws.RxBuffer.HandshakeKey)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketConnect',
                                   'Failed to build handshake request')
        return false
    }

    // DEBUG: Log the handshake request
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_WEBSOCKET__,
                               'NAVWebSocketConnect',
                               "'Handshake request (', itoa(length_array(ws.HandshakeRequest)), ' bytes)'")
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_WEBSOCKET__,
                               'NAVWebSocketConnect',
                               "'Request: ', ws.HandshakeRequest")

    // Open TCP or TLS connection based on URL scheme
    switch (ws.Url.Scheme) {
        case NAV_URL_SCHEME_WS: {
            stack_var slong result

            result = NAVClientSocketOpen(ws.Device.PORT, ws.Url.Host, ws.Url.Port, IP_TCP)

            if (result < 0) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                           __NAV_FOUNDATION_WEBSOCKET__,
                                           'NAVWebSocketConnect',
                                           "'Failed to open socket to ', ws.Url.Host, ':', itoa(ws.Url.Port)")
                return false
            }
        }
        case NAV_URL_SCHEME_WSS: {
            stack_var slong result

            result = NAVClientTlsSocketOpen(ws.Device.PORT,
                                            ws.Url.Host,
                                            ws.Url.Port,
                                            TLS_VALIDATE_CERTIFICATE)

            if (result < 0) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                           __NAV_FOUNDATION_WEBSOCKET__,
                                           'NAVWebSocketConnect',
                                           "'Failed to open TLS socket to ', ws.Url.Host, ':', itoa(ws.Url.Port)")
                return false
            }
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                       __NAV_FOUNDATION_WEBSOCKET__,
                                       'NAVWebSocketConnect',
                                       "'Unsupported URL scheme: ', ws.Url.Scheme")
            return false
        }
    }

    return true
}

/**
 * Handles TCP connection establishment and sends the WebSocket handshake.
 * Call this from the data_event online handler after TCP connects.
 *
 * @function NAVWebSocketOnConnect
 * @access public
 * @param {_NAVWebSocket} ws - WebSocket context
 *
 * @example
 * data_event[dvWebSocket] {
 *     online: {
 *         NAVWebSocketOnConnect(ws)
 *     }
 * }
 */
define_function NAVWebSocketOnConnect(_NAVWebSocket ws) {
    ws.IsConnected = true
    ws.RxBuffer.State = NAV_WEBSOCKET_STATE_CONNECTING
    NAVWebSocketSendFrame(ws.Device, ws.HandshakeRequest)
}

/**
 * Handles TCP disconnection and cleans up WebSocket state.
 * Call this from the data_event offline or onerror handler.
 *
 * @function NAVWebSocketOnDisconnect
 * @access public
 * @param {_NAVWebSocket} ws - WebSocket context
 *
 * @example
 * data_event[dvWebSocket] {
 *     offline: {
 *         NAVWebSocketOnDisconnect(ws)
 *     }
 *     onerror: {
 *         NAVWebSocketOnDisconnect(ws)
 *     }
 * }
 */
define_function NAVWebSocketOnDisconnect(_NAVWebSocket ws) {
    ws.IsConnected = false
    ws.RxBuffer.State = NAV_WEBSOCKET_STATE_IDLE
}

/**
 * Handles TCP errors and cleans up WebSocket state.
 * Call this from the data_event onerror handler.
 *
 * @function NAVWebSocketOnError
 * @access public
 * @param {_NAVWebSocket} ws - WebSocket context
 *
 * @example
 * data_event[dvWebSocket] {
 *     onerror: {
 *         NAVWebSocketOnError(ws)
 *     }
 * }
 */
define_function NAVWebSocketOnError(_NAVWebSocket ws) {
    // For now, just handle like a disconnect
    // Future: could add error-specific handling, retry logic, etc.
    NAVWebSocketOnDisconnect(ws)
}

/**
 * Checks if a WebSocket is in OPEN state (RFC 6455 readyState OPEN).
 * Returns TRUE only when both TCP socket is connected AND handshake is complete.
 *
 * @function NAVWebSocketIsOpen
 * @access public
 * @param {_NAVWebSocket} ws - WebSocket context to check
 * @returns {char} TRUE if in OPEN state (ready to send/receive data), FALSE otherwise
 */
define_function char NAVWebSocketIsOpen(_NAVWebSocket ws) {
    return ws.IsConnected && ws.RxBuffer.State == NAV_WEBSOCKET_STATE_OPEN
}

/**
 * Sends data (text or binary) over an established WebSocket connection.
 * Data is automatically framed as a text frame (opcode 0x01) and masked.
 *
 * @function NAVWebSocketSend
 * @access public
 * @param {_NAVWebSocket} ws - WebSocket context
 * @param {char[]} data - Data to send (text string or binary bytes)
 * @returns {char} TRUE if sent successfully, FALSE otherwise
 *
 * @example
 * stack_var _NAVWebSocket ws
 *
 * // Only send when in OPEN state
 * if (NAVWebSocketIsOpen(ws)) {
 *     NAVWebSocketSend(ws, 'Hello from NetLinx!')
 * }
 */
define_function char NAVWebSocketSend(_NAVWebSocket ws, char data[]) {
    stack_var char frame[65535]

    if (!NAVWebSocketIsOpen(ws)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketSend',
                                   'WebSocket not ready')
        return false
    }

    if (!NAVWebSocketBuildTextFrame(data, NAV_WEBSOCKET_MASKED, frame)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketSend',
                                   'Failed to build text frame')
        return false
    }

    return NAVWebSocketSendFrame(ws.Device, frame)
}

/**
 * Sends a ping frame over an established WebSocket connection.
 * Internal function - ping/pong is handled automatically by the library.
 *
 * @function NAVWebSocketSendPing
 * @access private
 * @param {_NAVWebSocket} ws - WebSocket context
 * @param {char[]} payload - Optional ping payload (max 125 bytes)
 * @returns {char} TRUE if sent successfully, FALSE otherwise
 *
 * @example
 * stack_var _NAVWebSocket ws
 *
 * if (NAVWebSocketIsOpen(ws)) {
 *     NAVWebSocketSendPing(ws, 'ping')
 * }
 */
define_function char NAVWebSocketSendPing(_NAVWebSocket ws, char payload[]) {
    stack_var char frame[150]

    if (!NAVWebSocketIsOpen(ws)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketSendPing',
                                   'WebSocket not ready')
        return false
    }

    if (!NAVWebSocketBuildPingFrame(payload, NAV_WEBSOCKET_MASKED, frame)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketSendPing',
                                   'Failed to build ping frame')
        return false
    }

    return NAVWebSocketSendFrame(ws.Device, frame)
}

/**
 * Sends a close frame with custom status code and reason.
 * For advanced use cases where you need to signal specific close reasons.
 *
 * @function NAVWebSocketSendClose
 * @access public
 * @param {_NAVWebSocket} ws - WebSocket context
 * @param {integer} statusCode - Close status code (see NAV_WEBSOCKET_CLOSE_* constants)
 * @param {char[]} reason - Optional human-readable reason (max 123 bytes)
 * @returns {char} TRUE if close frame sent successfully, FALSE otherwise
 *
 * @example
 * stack_var _NAVWebSocket ws
 *
 * // Signal protocol error
 * NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_PROTOCOL_ERROR, 'Invalid frame received')
 *
 * @note For normal closes, use NAVWebSocketClose(ws) instead
 */
define_function char NAVWebSocketSendClose(_NAVWebSocket ws, integer statusCode, char reason[]) {
    stack_var char frame[150]
    stack_var char result

    // Don't close if not connected
    if (!NAVWebSocketIsOpen(ws)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketSendClose',
                                   'WebSocket is not connected')
        return false
    }

    result = true

    if (ws.RxBuffer.State == NAV_WEBSOCKET_STATE_OPEN) {
        if (NAVWebSocketBuildCloseFrame(statusCode, reason, NAV_WEBSOCKET_MASKED, frame)) {
            result = NAVWebSocketSendFrame(ws.Device, frame)
        }

        // RFC 6455 §7.1.3: Enter CLOSING state and wait for server's close frame
        // The actual TCP close happens when we receive the server's close frame
        ws.RxBuffer.State = NAV_WEBSOCKET_STATE_CLOSING
    }
    else {
        // If not connected, close immediately
        ws.IsConnected = false
        ws.RxBuffer.State = NAV_WEBSOCKET_STATE_CLOSED
        ws.RxBuffer.HandshakeData = ''

        // Close the underlying socket
        NAVWebSocketCloseSocket(ws)
    }

    return result
}

/**
 * Closes the WebSocket connection with a normal close status.
 * This is the simple version for most use cases.
 *
 * @function NAVWebSocketClose
 * @access public
 * @param {_NAVWebSocket} ws - WebSocket context
 * @returns {char} TRUE if close frame sent successfully, FALSE otherwise
 *
 * @example
 * stack_var _NAVWebSocket ws
 *
 * NAVWebSocketClose(ws)
 *
 * @note For advanced close with custom code/reason, use NAVWebSocketSendClose()
 */
define_function char NAVWebSocketClose(_NAVWebSocket ws) {
    return NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_NORMAL, '')
}

/**
 * Processes incoming data in a WebSocket connection.
 * Call this from your data_event[device].string handler.
 *
 * @function NAVWebSocketProcessData
 * @access private
 * @deprecated Use NAVWebSocketProcessBuffer() instead - this is a legacy function
 * @param {_NAVWebSocket} ws - WebSocket context
 * @param {char[]} data - Incoming data from the socket
 * @returns {char} TRUE if processing completed, FALSE if an error occurred
 *
 * @note Handles handshake validation (transitions CONNECTING → OPEN)
 * @note After handshake, frames are automatically buffered via create_buffer
 *
 * @example
 * data_event[dvSocket] {
 *     string: {
 *         if (!NAVWebSocketProcessData(ws, data.text)) {
 *             // Handle error
 *         }
 *     }
 * }
 */
define_function char NAVWebSocketProcessData(_NAVWebSocket ws, char data[]) {
    // After handshake, just buffer incoming frame data
    if (ws.RxBuffer.State == NAV_WEBSOCKET_STATE_OPEN) {
        // Data is automatically buffered via create_buffer
        return true
    }

    // Accumulate handshake response
    ws.RxBuffer.HandshakeData = "ws.RxBuffer.HandshakeData, data"

    // Wait for complete HTTP response (ends with double CRLF)
    if (!NAVContains(ws.RxBuffer.HandshakeData, "NAV_CR, NAV_LF, NAV_CR, NAV_LF")) {
        return true
    }

    // Validate the handshake response
    if (!NAVWebSocketValidateHandshakeResponse(ws.RxBuffer.HandshakeData, ws.RxBuffer.HandshakeKey)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketProcessData',
                                   'Handshake validation failed')
        return false
    }

    // Handshake successful
    ws.RxBuffer.State = NAV_WEBSOCKET_STATE_OPEN
    ws.RxBuffer.HandshakeData = ''

    return true
}

/**
 * Parses the next frame from the WebSocket receive buffer.
 * Call this repeatedly until it returns NAV_WEBSOCKET_ERROR_INCOMPLETE.
 *
 * @function NAVWebSocketGetNextFrame
 * @access private
 * @param {_NAVWebSocket} ws - WebSocket context
 * @param {_NAVWebSocketFrameParseResult} result - Parse result with frame data
 * @returns {char} TRUE if a frame was parsed, FALSE if incomplete or error
 *
 * @example
 * stack_var _NAVWebSocket ws
 * stack_var _NAVWebSocketFrameParseResult result
 *
 * while (NAVWebSocketGetNextFrame(ws, result)) {
 *     switch (result.Frame.Opcode) {
 *         case NAV_WEBSOCKET_OPCODE_TEXT: {
 *             // Handle text message
 *         }
 *         case NAV_WEBSOCKET_OPCODE_PING: {
 *             // Send pong response
 *         }
 *     }
 * }
 */
define_function char NAVWebSocketGetNextFrame(_NAVWebSocket ws, _NAVWebSocketFrameParseResult result) {
    stack_var char temp[65535]

    if (NAVWebSocketParseFrame(ws.RxBuffer.Data, result) != NAV_WEBSOCKET_SUCCESS) {
        return false
    }

    if (result.BytesConsumed > 0) {
        temp = NAVStringSubstring(ws.RxBuffer.Data, type_cast(result.BytesConsumed + 1), 0)
        ws.RxBuffer.Data = temp
    }

    return true
}


// =============================================================================
// WebSocket Handshake Functions
// =============================================================================

/**
 * Builds a WebSocket handshake request (HTTP Upgrade request).
 *
 * @function NAVWebSocketBuildHandshakeRequest
 * @access private
 * @param {char[]} url - Complete WebSocket URL (e.g., 'ws://example.com:8080/socket')
 * @param {char[]} output - Output buffer to write the HTTP request to
 * @param {char[16]} key - Output array to store the generated Sec-WebSocket-Key for validation
 * @returns {char} TRUE if successful, FALSE otherwise
 *
 * @example
 * stack_var char request[2000]
 * stack_var char key[16]
 *
 * if (NAVWebSocketBuildHandshakeRequest('ws://example.com:8080/socket', request, key)) {
 *     send_string dvSocket, request
 *     // Save 'key' for later validation of server response
 * }
 *
 * @note The key parameter receives the 16-byte key needed to validate the server's response
 * @note URL scheme can be 'ws://' or 'wss://' (converted to http/https internally)
 */
define_function char NAVWebSocketBuildHandshakeRequest(char url[], char output[], char key[16]) {
    stack_var integer i
    stack_var char base64Key[NAV_MAX_BUFFER]
    stack_var _NAVHttpRequest request
    stack_var _NAVUrl parsedUrl

    // Parse the URL
    if (!NAVParseUrl(url, parsedUrl)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_WEBSOCKET__,
                                    'NAVWebSocketBuildHandshakeRequest',
                                    "'Failed to parse WebSocket URL: ', url")
        return false
    }

    // Convert ws/wss schemes to http/https for HTTP request
    switch (parsedUrl.Scheme) {
        case NAV_URL_SCHEME_WS: {
            parsedUrl.Scheme = NAV_URL_SCHEME_HTTP
        }
        case NAV_URL_SCHEME_WSS: {
            parsedUrl.Scheme = NAV_URL_SCHEME_HTTPS
        }
        case NAV_URL_SCHEME_HTTP:
        case NAV_URL_SCHEME_HTTPS: {
            // Supported schemes
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_WEBSOCKET__,
                                        'NAVWebSocketBuildHandshakeRequest',
                                        "'Unsupported URL scheme for WebSocket: ', parsedUrl.Scheme")
            return false
        }
    }

    // Generate random 16-byte key
    for (i = 1; i <= 16; i++) {
        key[i] = type_cast(random_number(256) - 1)
    }

    // Base64 encode the key
    set_length_array(key, 16)
    base64Key = NAVBase64Encode(key)

    // Initialize HTTP request
    if (!NAVHttpRequestInit(request, NAV_HTTP_METHOD_GET, parsedUrl, '')) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_WEBSOCKET__,
                                    'NAVWebSocketBuildHandshakeRequest',
                                    "'Failed to initialize HTTP request for WebSocket handshake'")
        return false
    }

    // Add WebSocket-specific headers
    if (!NAVHttpRequestAddHeader(request, NAV_HTTP_HEADER_UPGRADE, 'websocket')) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_WEBSOCKET__,
                                    'NAVWebSocketBuildHandshakeRequest',
                                    "'Failed to add Upgrade header'")
        return false
    }

    if (!NAVHttpRequestAddHeader(request, NAV_HTTP_HEADER_CONNECTION, NAV_HTTP_CONNECTION_UPGRADE)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_WEBSOCKET__,
                                    'NAVWebSocketBuildHandshakeRequest',
                                    "'Failed to add Connection header'")
        return false
    }

    if (!NAVHttpRequestAddHeader(request, NAV_HTTP_HEADER_SEC_WEBSOCKET_KEY, base64Key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_WEBSOCKET__,
                                    'NAVWebSocketBuildHandshakeRequest',
                                    "'Failed to add Sec-WebSocket-Key header'")
        return false
    }

    if (!NAVHttpRequestAddHeader(request, NAV_HTTP_HEADER_SEC_WEBSOCKET_VERSION, NAV_HTTP_WEBSOCKET_VERSION)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_WEBSOCKET__,
                                    'NAVWebSocketBuildHandshakeRequest',
                                    "'Failed to add Sec-WebSocket-Version header'")
        return false
    }

    // Build the complete HTTP request
    if (!NAVHttpBuildRequest(request, output)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_WEBSOCKET__,
                                    'NAVWebSocketBuildHandshakeRequest',
                                    "'Failed to build HTTP request'")
        return false
    }

    return true
}


/**
 * Validates a WebSocket handshake response from the server.
 *
 * @function NAVWebSocketValidateHandshakeResponse
 * @access private
 * @param {char[]} response - The complete HTTP response from the server
 * @param {char[16]} key - The original 16-byte key sent in the request
 * @returns {char} TRUE if valid, FALSE otherwise
 *
 * @example
 * stack_var char key[16]
 *
 * // key was saved from NAVWebSocketBuildHandshakeRequest
 * if (NAVWebSocketValidateHandshakeResponse(serverResponse, key)) {
 *     // Handshake successful, can now send/receive WebSocket frames
 * }
 *
 * @note This validates the HTTP 101 status and Sec-WebSocket-Accept header
 */
define_function char NAVWebSocketValidateHandshakeResponse(char response[], char key[16]) {
    stack_var char base64Key[NAV_MAX_BUFFER]
    stack_var char concatenated[NAV_MAX_BUFFER]
    stack_var char sha1Hash[20]
    stack_var char expectedAccept[NAV_MAX_BUFFER]
    stack_var char actualAccept[NAV_MAX_BUFFER]
    stack_var _NAVHttpResponse httpResponse
    stack_var integer i

    // DEBUG: Log raw response
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_WEBSOCKET__,
                               'NAVWebSocketValidateHandshakeResponse',
                               "'Raw response (', itoa(length_array(response)), ' bytes)'")
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_WEBSOCKET__,
                               'NAVWebSocketValidateHandshakeResponse',
                               "'Response: ', response")

    // Initialize response structure
    NAVHttpResponseInit(httpResponse)

    // Parse response headers (includes status line parsing)
    if (!NAVHttpParseResponse(response, httpResponse)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketValidateHandshakeResponse',
                                   'Failed to parse HTTP response')
        return false
    }

    // DEBUG: Log parsed status
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_WEBSOCKET__,
                               'NAVWebSocketValidateHandshakeResponse',
                               "'Status: ', itoa(httpResponse.Status.Code), ' ', httpResponse.Status.Message")
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_WEBSOCKET__,
                               'NAVWebSocketValidateHandshakeResponse',
                               "'Header count: ', itoa(httpResponse.Headers.Count)")

    // DEBUG: Log all headers
    for (i = 1; i <= httpResponse.Headers.Count; i++) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketValidateHandshakeResponse',
                                   "'Header[', itoa(i), ']: ', httpResponse.Headers.Headers[i].Key, ': ', httpResponse.Headers.Headers[i].Value")
    }

    // Verify status code is 101 Switching Protocols
    if (httpResponse.Status.Code != NAV_HTTP_STATUS_CODE_INFO_SWITCHING_PROTOCOLS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketValidateHandshakeResponse',
                                   "'Invalid status code: ', itoa(httpResponse.Status.Code), ' (expected 101)'")
        return false
    }

    // Base64 encode the original key
    base64Key = NAVBase64Encode(key)
    if (!length_array(base64Key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketValidateHandshakeResponse',
                                   'Failed to Base64 encode key')
        return false
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_WEBSOCKET__,
                               'NAVWebSocketValidateHandshakeResponse',
                               "'Base64 key: ', base64Key")

    // Concatenate with WebSocket GUID
    concatenated = "base64Key, NAV_WEBSOCKET_GUID"

    // SHA-1 hash the concatenated string
    sha1Hash = NAVSha1GetHash(concatenated)
    if (!length_array(sha1Hash)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketValidateHandshakeResponse',
                                   'Failed to generate SHA-1 hash')
        return false
    }

    // Base64 encode the hash
    expectedAccept = NAVBase64Encode(sha1Hash)
    if (!length_array(expectedAccept)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketValidateHandshakeResponse',
                                   'Failed to Base64 encode SHA-1 hash')
        return false
    }
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_WEBSOCKET__,
                               'NAVWebSocketValidateHandshakeResponse',
                               "'Expected Accept: ', expectedAccept")

    // Check if Sec-WebSocket-Accept header exists
    if (!NAVHttpHeaderKeyExists(httpResponse.Headers, NAV_HTTP_HEADER_SEC_WEBSOCKET_ACCEPT)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketValidateHandshakeResponse',
                                   'Sec-WebSocket-Accept header not found')
        return false
    }

    // Get Sec-WebSocket-Accept header value
    actualAccept = NAVHttpGetHeaderValue(httpResponse.Headers, NAV_HTTP_HEADER_SEC_WEBSOCKET_ACCEPT)
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_WEBSOCKET__,
                               'NAVWebSocketValidateHandshakeResponse',
                               "'Actual Accept: ', actualAccept")

    // Compare expected and actual
    if (actualAccept != expectedAccept) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketValidateHandshakeResponse',
                                   'Sec-WebSocket-Accept mismatch')
        return false
    }

    return true
}


// =============================================================================
// Utility Functions
// =============================================================================

/**
 * Validates a close status code per RFC 6455 §7.4.
 * Checks that the code is in a valid range and not reserved.
 *
 * @function NAVWebSocketIsValidCloseCode
 * @access private
 * @param {integer} code - The close status code to validate
 * @returns {char} TRUE if valid, FALSE if invalid/reserved
 *
 * @example
 * if (!NAVWebSocketIsValidCloseCode(statusCode)) {
 *     // Invalid close code
 * }
 */
define_function char NAVWebSocketIsValidCloseCode(integer code) {
    // 0-999: Not used
    if (code < 1000) {
        return false
    }

    // 1000-2999: Reserved by RFC
    if (code >= 1000 && code <= 2999) {
        // These codes cannot appear on the wire (RFC 6455 §7.4.1)
        if (code == 1004 || code == 1005 || code == 1006 || code == 1015) {
            return false
        }

        // Valid protocol codes: 1000-1003, 1007-1011
        return true
    }

    // 3000-3999: Registered with IANA (valid)
    if (code >= 3000 && code <= 3999) {
        return true
    }

    // 4000-4999: Private use (valid)
    if (code >= 4000 && code <= 4999) {
        return true
    }

    // 5000+: Invalid
    return false
}

/**
 * Closes the underlying socket (TCP or TLS) based on the WebSocket URL scheme.
 *
 * @function NAVWebSocketCloseSocket
 * @access private
 * @param {_NAVWebSocket} ws - WebSocket context
 *
 * @example
 * NAVWebSocketCloseSocket(ws)
 */
define_function NAVWebSocketCloseSocket(_NAVWebSocket ws) {
    switch (ws.Url.Scheme) {
        case NAV_URL_SCHEME_WS: {
            NAVClientSocketClose(ws.Device.PORT)
        }
        case NAV_URL_SCHEME_WSS: {
            NAVClientTlsSocketClose(ws.Device.PORT)
        }
    }
}

/**
 * Checks if a given opcode represents a control frame.
 *
 * @function NAVWebSocketIsControlFrame
 * @access private
 * @param {integer} opcode - The opcode to check
 * @returns {char} 1 if the opcode is a control frame (close, ping, pong), 0 otherwise
 *
 * @example
 * if (NAVWebSocketIsControlFrame(NAV_WEBSOCKET_OPCODE_PING)) {
 *     // Handle control frame
 * }
 */
define_function char NAVWebSocketIsControlFrame(integer opcode) {
    return (opcode >= NAV_WEBSOCKET_OPCODE_CLOSE && opcode <= NAV_WEBSOCKET_OPCODE_PONG)
}


/**
 * Validates that an opcode is defined and valid according to RFC 6455.
 *
 * @function NAVWebSocketIsValidOpcode
 * @access private
 * @param {integer} opcode - The opcode to validate
 * @returns {char} 1 if the opcode is valid, 0 otherwise
 *
 * @example
 * if (!NAVWebSocketIsValidOpcode(frame.Opcode)) {
 *     // Handle invalid opcode
 * }
 */
define_function char NAVWebSocketIsValidOpcode(integer opcode) {
    switch (opcode) {
        case NAV_WEBSOCKET_OPCODE_CONTINUATION:
        case NAV_WEBSOCKET_OPCODE_TEXT:
        case NAV_WEBSOCKET_OPCODE_BINARY:
        case NAV_WEBSOCKET_OPCODE_CLOSE:
        case NAV_WEBSOCKET_OPCODE_PING:
        case NAV_WEBSOCKET_OPCODE_PONG: {
            return true
        }
        default: {
            return false
        }
    }
}


/**
 * Generates a random 4-byte masking key for WebSocket frame masking.
 *
 * @function NAVWebSocketGenerateMaskingKey
 * @access private
 * @param {char[4]} key - Output array to store the generated masking key
 *
 * @example
 * stack_var char maskingKey[4]
 * NAVWebSocketGenerateMaskingKey(maskingKey)
 */
define_function NAVWebSocketGenerateMaskingKey(char key[4]) {
    stack_var integer i

    for (i = 1; i <= NAV_WEBSOCKET_MASKING_KEY_LENGTH; i++) {
        key[i] = type_cast(random_number(256) - 1)
    }

    set_length_array(key, NAV_WEBSOCKET_MASKING_KEY_LENGTH)
}


/**
 * Applies or removes WebSocket masking using XOR operation.
 * This function works for both masking and unmasking since XOR is reversible.
 *
 * @function NAVWebSocketMaskData
 * @access private
 * @param {char[]} data - The data to mask or unmask
 * @param {char[4]} maskingKey - The 4-byte masking key
 * @param {char[]} output - Output buffer to store the masked/unmasked data
 * @returns {long} The length of the processed data
 *
 * @example
 * stack_var char masked[1000]
 * stack_var char maskingKey[4]
 * stack_var long length
 *
 * NAVWebSocketGenerateMaskingKey(maskingKey)
 * length = NAVWebSocketMaskData(payload, maskingKey, masked)
 */
define_function long NAVWebSocketMaskData(char data[], char maskingKey[4], char output[]) {
    stack_var long i
    stack_var long length

    length = length_array(data)

    for (i = 1; i <= length; i++) {
        output[i] = data[i] bxor maskingKey[((i - 1) % NAV_WEBSOCKET_MASKING_KEY_LENGTH) + 1]
    }

    return length
}


// =============================================================================
// Frame Validation Functions
// =============================================================================

/**
 * Validates a WebSocket frame structure for RFC 6455 compliance.
 *
 * @function NAVWebSocketValidateFrame
 * @access private
 * @param {_NAVWebSocketFrame} frame - The frame to validate
 * @returns {sinteger} NAV_WEBSOCKET_SUCCESS if valid, otherwise an error code
 *
 * @example
 * stack_var sinteger result
 * result = NAVWebSocketValidateFrame(frame)
 * if (result != NAV_WEBSOCKET_SUCCESS) {
 *     // Handle validation error
 * }
 */
define_function sinteger NAVWebSocketValidateFrame(_NAVWebSocketFrame frame) {
    // Check for invalid opcode
    if (!NAVWebSocketIsValidOpcode(frame.Opcode)) {
        return NAV_WEBSOCKET_ERROR_INVALID_OPCODE
    }

    // Reserved bits must be 0 unless extensions are negotiated
    if (frame.Rsv1 || frame.Rsv2 || frame.Rsv3) {
        return NAV_WEBSOCKET_ERROR_RESERVED_BITS
    }

    // Control frames must not be fragmented
    if (NAVWebSocketIsControlFrame(frame.Opcode) && !frame.Fin) {
        return NAV_WEBSOCKET_ERROR_FRAGMENTED_CTRL
    }

    // Control frames must have payload <= 125 bytes
    if (NAVWebSocketIsControlFrame(frame.Opcode) && frame.PayloadLength > NAV_WEBSOCKET_MAX_CONTROL_PAYLOAD) {
        return NAV_WEBSOCKET_ERROR_CONTROL_TOO_BIG
    }

    return NAV_WEBSOCKET_SUCCESS
}


// =============================================================================
// Frame Building Functions (for sending)
// =============================================================================

/**
 * Builds a complete WebSocket frame ready to send over the wire.
 *
 * @function NAVWebSocketBuildFrame
 * @access private
 * @param {_NAVWebSocketFrame} frame - Frame structure with data to send
 * @param {char[]} output - Output buffer to write the frame bytes to
 * @returns {char} TRUE if successful, FALSE otherwise
 *
 * @example
 * stack_var _NAVWebSocketFrame frame
 * stack_var char output[65535]
 *
 * frame.Fin = 1
 * frame.Opcode = NAV_WEBSOCKET_OPCODE_TEXT
 * frame.PayloadLength = length_array(data)
 * frame.Payload = data
 *
 * if (NAVWebSocketBuildFrame(frame, output)) {
 *     NAVWebSocketSend(dvSocket, output)
 * }
 */
define_function char NAVWebSocketBuildFrame(_NAVWebSocketFrame frame, char output[]) {
    stack_var char firstByte
    stack_var char secondByte
    stack_var char lengthBytes[8]
    stack_var char maskedPayload[65535]
    stack_var sinteger validationResult

    // Validate frame first
    validationResult = NAVWebSocketValidateFrame(frame)
    if (validationResult != NAV_WEBSOCKET_SUCCESS) {
        return false
    }

    // First byte: FIN, RSV1-3, Opcode
    firstByte = 0
    if (frame.Fin) {
        firstByte = type_cast(firstByte bor $80)  // Set FIN bit
    }

    if (frame.Rsv1) {
        firstByte = type_cast(firstByte bor $40)  // Set RSV1 bit
    }

    if (frame.Rsv2) {
        firstByte = type_cast(firstByte bor $20)  // Set RSV2 bit
    }

    if (frame.Rsv3) {
        firstByte = type_cast(firstByte bor $10)  // Set RSV3 bit
    }

    firstByte = type_cast(firstByte bor (frame.Opcode band $0F))  // Set opcode bits

    // Second byte: MASK bit
    secondByte = 0
    if (frame.Mask) {
        secondByte = secondByte bor $80  // Set MASK bit
    }

    // Build output starting with first byte
    output = "firstByte"

    // Add second byte + payload length encoding
    select {
        active (frame.PayloadLength <= NAV_WEBSOCKET_MAX_CONTROL_PAYLOAD): {
            // Length fits in 7 bits
            secondByte = secondByte bor type_cast(frame.PayloadLength band $7F)
            output = "output, secondByte"
        }
        active (frame.PayloadLength <= NAV_WEBSOCKET_MAX_PAYLOAD_16): {
            // Use 16-bit extended length
            secondByte = secondByte bor NAV_WEBSOCKET_PAYLOAD_LENGTH_16
            lengthBytes = NAVIntegerToByteArrayBE(type_cast(frame.PayloadLength))
            output = "output, secondByte, lengthBytes"
        }
        active (true): {
            // Use 64-bit extended length (limited to 32-bit in NetLinx)
            secondByte = secondByte bor NAV_WEBSOCKET_PAYLOAD_LENGTH_64
            lengthBytes = NAVLongToByteArrayBE(frame.PayloadLength)
            // 8-byte length: 4 zeros + 4-byte actual length
            output = "output, secondByte, $00, $00, $00, $00, lengthBytes"
        }
    }

    // Add masking key if frame is masked
    if (frame.Mask) {
        output = "output, frame.MaskingKey"
    }

    // Add payload
    if (frame.PayloadLength > 0) {
        if (frame.Mask) {
            NAVWebSocketMaskData(frame.Payload, frame.MaskingKey, maskedPayload)
            set_length_array(maskedPayload, frame.PayloadLength)
            output = "output, maskedPayload"
        }
        else {
            output = "output, frame.Payload"
        }
    }

    return true
}


/**
 * Builds a text frame containing UTF-8 encoded text.
 *
 * @function NAVWebSocketBuildTextFrame
 * @access private
 * @param {char[]} text - UTF-8 encoded text to send
 * @param {char} masked - NAV_WEBSOCKET_MASKED or NAV_WEBSOCKET_UNMASKED
 * @param {char[]} output - Output buffer to write the frame bytes to
 * @returns {char} TRUE if successful, FALSE otherwise
 *
 * @example
 * stack_var char output[1000]
 *
 * if (NAVWebSocketBuildTextFrame('Hello WebSocket!', NAV_WEBSOCKET_MASKED, output)) {
 *     NAVWebSocketSend(dvSocket, output)
 * }
 */
define_function char NAVWebSocketBuildTextFrame(char text[], char masked, char output[]) {
    stack_var _NAVWebSocketFrame frame

    // Validate UTF-8 encoding
    if (!NAVEncodingIsValidUtf8(text)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketBuildTextFrame',
                                   'Invalid UTF-8 encoding in outgoing text')
        return false
    }

    frame.Fin = 1
    frame.Rsv1 = 0
    frame.Rsv2 = 0
    frame.Rsv3 = 0
    frame.Opcode = NAV_WEBSOCKET_OPCODE_TEXT
    frame.Mask = masked
    frame.PayloadLength = length_array(text)
    frame.Payload = text

    if (masked) {
        NAVWebSocketGenerateMaskingKey(frame.MaskingKey)
    }

    return NAVWebSocketBuildFrame(frame, output)
}


/**
 * Builds a binary frame containing arbitrary binary data.
 *
 * @function NAVWebSocketBuildBinaryFrame
 * @access private
 * @param {char[]} data - Binary data to send
 * @param {char} masked - NAV_WEBSOCKET_MASKED or NAV_WEBSOCKET_UNMASKED
 * @param {char[]} output - Output buffer to write the frame bytes to
 * @returns {char} TRUE if successful, FALSE otherwise
 *
 * @example
 * stack_var char binaryData[100]
 * stack_var char output[200]
 *
 * if (NAVWebSocketBuildBinaryFrame(binaryData, NAV_WEBSOCKET_MASKED, output)) {
 *     NAVWebSocketSend(dvSocket, output)
 * }
 */
define_function char NAVWebSocketBuildBinaryFrame(char data[], char masked, char output[]) {
    stack_var _NAVWebSocketFrame frame

    frame.Fin = 1
    frame.Rsv1 = 0
    frame.Rsv2 = 0
    frame.Rsv3 = 0
    frame.Opcode = NAV_WEBSOCKET_OPCODE_BINARY
    frame.Mask = masked
    frame.PayloadLength = length_array(data)
    frame.Payload = data

    if (masked) {
        NAVWebSocketGenerateMaskingKey(frame.MaskingKey)
    }

    return NAVWebSocketBuildFrame(frame, output)
}


/**
 * Builds a close frame with optional status code and reason.
 *
 * @function NAVWebSocketBuildCloseFrame
 * @access private
 * @param {integer} statusCode - WebSocket close status code (see NAV_WEBSOCKET_CLOSE_* constants)
 * @param {char[]} reason - Optional human-readable reason (max 123 bytes, UTF-8)
 * @param {char} masked - NAV_WEBSOCKET_MASKED or NAV_WEBSOCKET_UNMASKED
 * @param {char[]} output - Output buffer to write the frame bytes to
 * @returns {char} TRUE if successful, FALSE otherwise
 *
 * @example
 * stack_var char output[200]
 *
 * if (NAVWebSocketBuildCloseFrame(NAV_WEBSOCKET_CLOSE_NORMAL, 'Goodbye', NAV_WEBSOCKET_MASKED, output)) {
 *     NAVWebSocketSend(dvSocket, output)
 * }
 */
define_function char NAVWebSocketBuildCloseFrame(integer statusCode, char reason[], char masked, char output[]) {
    stack_var _NAVWebSocketFrame frame
    stack_var char payload[125]
    stack_var integer reasonLength

    // Validate close status code
    if (!NAVWebSocketIsValidCloseCode(statusCode)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketBuildCloseFrame',
                                   "'Invalid close status code: ', itoa(statusCode)")
        return false
    }

    frame.Fin = 1
    frame.Rsv1 = 0
    frame.Rsv2 = 0
    frame.Rsv3 = 0
    frame.Opcode = NAV_WEBSOCKET_OPCODE_CLOSE
    frame.Mask = masked

    // Build payload: status code (2 bytes, big-endian) + reason
    payload = NAVIntegerToByteArrayBE(statusCode)

    reasonLength = length_array(reason)
    if (reasonLength > 0) {
        // Validate UTF-8 encoding in reason
        if (!NAVEncodingIsValidUtf8(reason)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                       __NAV_FOUNDATION_WEBSOCKET__,
                                       'NAVWebSocketBuildCloseFrame',
                                       'Invalid UTF-8 encoding in close reason')
            return false
        }

        // Limit reason to fit in control frame (125 - 2 = 123 bytes)
        if (reasonLength > 123) {
            reasonLength = 123
        }

        payload = "payload, left_string(reason, reasonLength)"
    }

    frame.PayloadLength = 2 + reasonLength
    frame.Payload = payload

    if (masked) {
        NAVWebSocketGenerateMaskingKey(frame.MaskingKey)
    }

    return NAVWebSocketBuildFrame(frame, output)
}


/**
 * Builds a ping frame with optional payload.
 *
 * @function NAVWebSocketBuildPingFrame
 * @access private
 * @param {char[]} payload - Optional ping payload (max 125 bytes)
 * @param {char} masked - NAV_WEBSOCKET_MASKED or NAV_WEBSOCKET_UNMASKED
 * @param {char[]} output - Output buffer to write the frame bytes to
 * @returns {char} TRUE if successful, FALSE otherwise
 *
 * @example
 * stack_var char output[200]
 *
 * if (NAVWebSocketBuildPingFrame('ping', NAV_WEBSOCKET_MASKED, output)) {
 *     NAVWebSocketSend(dvSocket, output)
 * }
 */
define_function char NAVWebSocketBuildPingFrame(char payload[], char masked, char output[]) {
    stack_var _NAVWebSocketFrame frame

    frame.Fin = 1
    frame.Rsv1 = 0
    frame.Rsv2 = 0
    frame.Rsv3 = 0
    frame.Opcode = NAV_WEBSOCKET_OPCODE_PING
    frame.Mask = masked
    frame.PayloadLength = length_array(payload)
    frame.Payload = payload

    if (masked) {
        NAVWebSocketGenerateMaskingKey(frame.MaskingKey)
    }

    return NAVWebSocketBuildFrame(frame, output)
}


/**
 * Builds a pong frame (response to ping) with optional payload.
 * The payload should typically echo the ping payload.
 *
 * @function NAVWebSocketBuildPongFrame
 * @access private
 * @param {char[]} payload - Optional pong payload (should echo ping payload, max 125 bytes)
 * @param {char} masked - NAV_WEBSOCKET_MASKED or NAV_WEBSOCKET_UNMASKED
 * @param {char[]} output - Output buffer to write the frame bytes to
 * @returns {char} TRUE if successful, FALSE otherwise
 *
 * @example
 * stack_var char output[200]
 *
 * // Echo the ping payload back
 * if (NAVWebSocketBuildPongFrame(pingFrame.Payload, NAV_WEBSOCKET_UNMASKED, output)) {
 *     NAVWebSocketSend(dvSocket, output)
 * }
 */
define_function char NAVWebSocketBuildPongFrame(char payload[], char masked, char output[]) {
    stack_var _NAVWebSocketFrame frame

    frame.Fin = 1
    frame.Rsv1 = 0
    frame.Rsv2 = 0
    frame.Rsv3 = 0
    frame.Opcode = NAV_WEBSOCKET_OPCODE_PONG
    frame.Mask = masked
    frame.PayloadLength = length_array(payload)
    frame.Payload = payload

    if (masked) {
        NAVWebSocketGenerateMaskingKey(frame.MaskingKey)
    }

    return NAVWebSocketBuildFrame(frame, output)
}


// =============================================================================
// Frame Parsing Functions (for receiving)
// =============================================================================

/**
 * Calculates the total frame length needed to parse a complete frame.
 * Useful for checking if enough data has been received.
 *
 * @function NAVWebSocketGetFrameLength
 * @access private
 * @param {char[]} data - Raw bytes received from socket
 * @returns {slong} Total frame length in bytes, NAV_WEBSOCKET_ERROR_INCOMPLETE if not enough data,
 *                  or other negative error code
 *
 * @example
 * stack_var slong frameLength
 * frameLength = NAVWebSocketGetFrameLength(receivedData)
 * if (frameLength > 0 && length_array(receivedData) >= frameLength) {
 *     // We have a complete frame
 * }
 */
define_function slong NAVWebSocketGetFrameLength(char data[]) {
    stack_var long dataLength
    stack_var char secondByte
    stack_var char masked
    stack_var long payloadLength
    stack_var long headerLength
    stack_var long totalLength
    stack_var integer offset

    dataLength = length_array(data)

    // Need at least 2 bytes for basic header
    if (dataLength < 2) {
        return NAV_WEBSOCKET_ERROR_INCOMPLETE
    }

    // Parse second byte to get mask flag and payload length
    secondByte = data[2]
    masked = (secondByte band $80) > 0
    payloadLength = secondByte band $7F

    offset = 2

    // Determine extended payload length if needed
    switch (payloadLength) {
        case NAV_WEBSOCKET_PAYLOAD_LENGTH_16: {
            // 16-bit extended length
            if (dataLength < 4) {
                return NAV_WEBSOCKET_ERROR_INCOMPLETE
            }

            payloadLength = NAVByteArrayToIntegerBE(data, 3)
            offset = 4
        }
        case NAV_WEBSOCKET_PAYLOAD_LENGTH_64: {
            // 64-bit extended length
            if (dataLength < 10) {
                return NAV_WEBSOCKET_ERROR_INCOMPLETE
            }

            // NetLinx limitation: can only handle 32-bit lengths
            // Check that upper 32 bits are 0
            if (data[3] != 0 || data[4] != 0 || data[5] != 0 || data[6] != 0) {
                return NAV_WEBSOCKET_ERROR_INVALID_FRAME
            }

            payloadLength = NAVByteArrayToLongBE(data, 7)
            offset = 10
        }
    }

    // Add masking key length if present
    if (masked) {
        offset = offset + NAV_WEBSOCKET_MASKING_KEY_LENGTH
    }

    totalLength = offset + payloadLength

    // Check if we have complete frame
    if (dataLength < totalLength) {
        return NAV_WEBSOCKET_ERROR_INCOMPLETE
    }

    return type_cast(totalLength)
}


/**
 * Parses a WebSocket frame from raw bytes received from socket.
 *
 * @function NAVWebSocketParseFrame
 * @access private
 * @param {char[]} data - Raw bytes received from socket
 * @param {_NAVWebSocketFrameParseResult} result - Output structure to store parse result
 * @returns {sinteger} Parse status (NAV_WEBSOCKET_SUCCESS or error code)
 *
 * @example
 * data_event[socket] {
 *     string: {
 *         stack_var _NAVWebSocketFrameParseResult result
 *
 *         if (NAVWebSocketParseFrame(data.text, result) == NAV_WEBSOCKET_SUCCESS) {
 *             // Process frame based on opcode
 *             switch (result.Frame.Opcode) {
 *                 case NAV_WEBSOCKET_OPCODE_TEXT: {
 *                     // Handle text message
 *                 }
 *                 case NAV_WEBSOCKET_OPCODE_CLOSE: {
 *                     // Handle close
 *                 }
 *             }
 *         }
 *     }
 * }
 */
define_function sinteger NAVWebSocketParseFrame(char data[], _NAVWebSocketFrameParseResult result) {
    stack_var long dataLength
    stack_var char firstByte
    stack_var char secondByte
    stack_var integer offset
    stack_var long i
    stack_var slong frameLength

    // Initialize result
    result.Status = NAV_WEBSOCKET_SUCCESS
    result.BytesConsumed = 0

    dataLength = length_array(data)

    // Check if we have enough data for a complete frame
    frameLength = NAVWebSocketGetFrameLength(data)
    if (frameLength < 0) {
        result.Status = type_cast(frameLength)
        return result.Status
    }

    offset = 1

    // Parse first byte: FIN, RSV1-3, Opcode
    firstByte = data[offset]
    offset = offset + 1

    result.Frame.Fin = (firstByte band $80) > 0
    result.Frame.Rsv1 = (firstByte band $40) > 0
    result.Frame.Rsv2 = (firstByte band $20) > 0
    result.Frame.Rsv3 = (firstByte band $10) > 0
    result.Frame.Opcode = firstByte band $0F

    // Parse second byte: MASK, Payload length
    secondByte = data[offset]
    offset = offset + 1

    result.Frame.Mask = (secondByte band $80) > 0
    result.Frame.PayloadLength = secondByte band $7F

    // RFC 6455 §5.1: Server frames MUST NOT be masked
    // A client MUST close the connection if it detects a masked frame from server
    if (result.Frame.Mask) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketParseFrame',
                                   'Protocol error: Server sent masked frame')
        result.Status = NAV_WEBSOCKET_ERROR_PROTOCOL_ERROR
        return result.Status
    }

    // Parse extended payload length if needed
    switch (result.Frame.PayloadLength) {
        case NAV_WEBSOCKET_PAYLOAD_LENGTH_16: {
            result.Frame.PayloadLength = NAVByteArrayToIntegerBE(data, offset)
            offset = offset + 2
        }
        case NAV_WEBSOCKET_PAYLOAD_LENGTH_64: {
            // Skip upper 32 bits (already validated in NAVWebSocketGetFrameLength)
            offset = offset + 4
            result.Frame.PayloadLength = NAVByteArrayToLongBE(data, offset)
            offset = offset + 4
        }
    }

    // Parse masking key if present
    if (result.Frame.Mask) {
        for (i = 1; i <= NAV_WEBSOCKET_MASKING_KEY_LENGTH; i++) {
            result.Frame.MaskingKey[i] = data[offset]
            offset = offset + 1
        }
    }

    // Parse payload
    if (result.Frame.PayloadLength > 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketParseFrame',
                                   "'Parsing payload: ', itoa(result.Frame.PayloadLength), ' bytes, Masked: ', itoa(result.Frame.Mask), ', Offset: ', itoa(offset)")

        for (i = 1; i <= result.Frame.PayloadLength; i++) {
            result.Frame.Payload[i] = data[offset]
            offset = offset + 1
        }

        set_length_array(result.Frame.Payload, result.Frame.PayloadLength)

        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketParseFrame',
                                   "'Raw payload length: ', itoa(length_array(result.Frame.Payload))")

        // Unmask payload if needed
        if (result.Frame.Mask) {
            stack_var char unmaskedPayload[65535]
            stack_var long unmaskedLength
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                       __NAV_FOUNDATION_WEBSOCKET__,
                                       'NAVWebSocketParseFrame',
                                       'Unmasking payload...')
            unmaskedLength = NAVWebSocketMaskData(result.Frame.Payload, result.Frame.MaskingKey, unmaskedPayload)
            set_length_array(unmaskedPayload, unmaskedLength)
            result.Frame.Payload = unmaskedPayload
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                       __NAV_FOUNDATION_WEBSOCKET__,
                                       'NAVWebSocketParseFrame',
                                       "'Unmasked payload length: ', itoa(length_array(result.Frame.Payload))")
        }
    }

    result.BytesConsumed = offset - 1

    // Validate the parsed frame
    result.Status = NAVWebSocketValidateFrame(result.Frame)

    return result.Status
}


/**
 * Parses a close frame to extract the status code and reason string.
 *
 * @function NAVWebSocketParseCloseFrame
 * @access private
 * @param {_NAVWebSocketFrame} frame - The parsed close frame
 * @param {_NAVWebSocketCloseFrame} closeData - Output structure to store status code and reason
 * @returns {sinteger} NAV_WEBSOCKET_SUCCESS if parsed successfully, otherwise error code
 *
 * @example
 * stack_var _NAVWebSocketCloseFrame closeData
 * if (result.Frame.Opcode == NAV_WEBSOCKET_OPCODE_CLOSE) {
 *     if (NAVWebSocketParseCloseFrame(result.Frame, closeData) == NAV_WEBSOCKET_SUCCESS) {
 *         // closeData.StatusCode contains the close code
 *         // closeData.Reason contains the reason string
 *     }
 * }
 */
define_function sinteger NAVWebSocketParseCloseFrame(_NAVWebSocketFrame frame, _NAVWebSocketCloseFrame closeData) {
    if (frame.Opcode != NAV_WEBSOCKET_OPCODE_CLOSE) {
        return NAV_WEBSOCKET_ERROR_INVALID_FRAME
    }

    // Close frame with no payload
    if (frame.PayloadLength == 0) {
        closeData.StatusCode = NAV_WEBSOCKET_CLOSE_NO_STATUS
        closeData.Reason = ''
        return NAV_WEBSOCKET_SUCCESS
    }

    // Close frame must have at least 2 bytes for status code
    if (frame.PayloadLength < 2) {
        return NAV_WEBSOCKET_ERROR_INVALID_FRAME
    }

    // Parse status code (big-endian)
    closeData.StatusCode = NAVByteArrayToIntegerBE(frame.Payload, 1)

    // Validate close status code
    if (!NAVWebSocketIsValidCloseCode(closeData.StatusCode)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketParseCloseFrame',
                                   "'Invalid close status code from server: ', itoa(closeData.StatusCode)")
        return NAV_WEBSOCKET_ERROR_INVALID_CLOSE_CODE
    }

    // Parse reason if present
    if (frame.PayloadLength > 2) {
        closeData.Reason = right_string(frame.Payload, frame.PayloadLength - 2)

        // Validate UTF-8 encoding in reason
        if (!NAVEncodingIsValidUtf8(closeData.Reason)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                       __NAV_FOUNDATION_WEBSOCKET__,
                                       'NAVWebSocketParseCloseFrame',
                                       'Invalid UTF-8 in close frame reason')
            return NAV_WEBSOCKET_ERROR_INVALID_UTF8
        }
    }
    else {
        closeData.Reason = ''
    }

    return NAV_WEBSOCKET_SUCCESS
}


// =============================================================================
// WebSocket Buffer Processing (State Machine)
// =============================================================================

/**
 * Initializes a WebSocket buffer structure for use with NAVWebSocketProcessBuffer.
 *
 * @function NAVWebSocketBufferInit
 * @access private
 * @param {_NAVWebSocketBuffer} buffer - Buffer to initialize
 *
 * @example
 * stack_var _NAVWebSocketBuffer wsBuffer
 *
 * NAVWebSocketBufferInit(wsBuffer)
 * create_buffer dvSocket, wsBuffer.Data
 *
 * @see NAVWebSocketProcessBuffer
 * @see _NAVWebSocketBuffer
 */
define_function NAVWebSocketBufferInit(_NAVWebSocketBuffer buffer) {
    buffer.Data = ''
    buffer.Semaphore = false
    buffer.State = NAV_WEBSOCKET_STATE_IDLE
    buffer.HandshakeKey = ''
    buffer.HandshakeData = ''
    // Initialize fragmentation fields
    buffer.FragmentBuffer = ''
    buffer.FragmentOpcode = 0
    buffer.IsFragmenting = false
}

/**
 * Processes incoming WebSocket data using a state machine.
 * Call this from your data_event string handler. This function handles:
 * - Handshake validation (fires NAVWebSocketOnOpenCallback)
 * - Automatic ping/pong responses
 * - Frame parsing and buffering
 * - Message callbacks (fires NAVWebSocketOnMessageCallback)
 * - Close frame handling (fires NAVWebSocketOnCloseCallback)
 * - Error handling (fires NAVWebSocketOnErrorCallback)
 *
 * @function NAVWebSocketProcessBuffer
 * @access public
 * @param {_NAVWebSocket} ws - WebSocket context structure
 *
 * @example
 * #DEFINE USING_NAV_WEBSOCKET_ON_OPEN_CALLBACK
 * define_function NAVWebSocketOnOpenCallback(_NAVWebSocket ws, _NAVWebSocketOnOpenResult result) {
 *     send_string 0, "'WebSocket opened to ', ws.Url.Host, ':', itoa(ws.Url.Port)"
 * }
 *
 * #DEFINE USING_NAV_WEBSOCKET_ON_MESSAGE_CALLBACK
 * define_function NAVWebSocketOnMessageCallback(_NAVWebSocket ws, _NAVWebSocketOnMessageResult result) {
 *     switch (result.Opcode) {
 *         case NAV_WEBSOCKET_OPCODE_TEXT: {
 *             send_string 0, "'Text from ', ws.Host, ': ', result.Data"
 *         }
 *         case NAV_WEBSOCKET_OPCODE_BINARY: {
 *             send_string 0, "'Binary from ', ws.Host, ': ', itoa(length_array(result.Data)), ' bytes'"
 *         }
 *     }
 * }
 *
 * #DEFINE USING_NAV_WEBSOCKET_ON_CLOSE_CALLBACK
 * define_function NAVWebSocketOnCloseCallback(_NAVWebSocket ws, _NAVWebSocketOnCloseResult result) {
 *     send_string 0, "'Connection to ', ws.Host, ' closed: ', itoa(result.StatusCode), ' - ', result.Reason"
 * }
 *
 * #DEFINE USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK
 * define_function NAVWebSocketOnErrorCallback(_NAVWebSocket ws, _NAVWebSocketOnErrorResult result) {
 *     send_string 0, "'Error on ', ws.Host, ': ', result.Message"
 * }
 *
 * data_event[dvSocket] {
 *     string: {
 *         NAVWebSocketProcessBuffer(ws)
 *     }
 * }
 *
 * @see NAVWebSocketInit
 * @see _NAVWebSocket
 */
define_function NAVWebSocketProcessBuffer(_NAVWebSocket ws) {
    stack_var _NAVWebSocketFrameParseResult parseResult
    stack_var _NAVWebSocketCloseFrame closeData
    stack_var char pongFrame[200]

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                               __NAV_FOUNDATION_WEBSOCKET__,
                               'NAVWebSocketProcessBuffer',
                               "'Called, buffer length: ', itoa(length_array(ws.RxBuffer.Data)), ', state: ', itoa(ws.RxBuffer.State)")
    if (length_array(ws.RxBuffer.Data) > 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                   __NAV_FOUNDATION_WEBSOCKET__,
                                   'NAVWebSocketProcessBuffer',
                                   "'Buffer contents: ', ws.RxBuffer.Data")
    }

    // Prevent concurrent access
    if (ws.RxBuffer.Semaphore) {
        return
    }

    ws.RxBuffer.Semaphore = true

    // Initialize state if idle (first call)
    if (ws.RxBuffer.State == NAV_WEBSOCKET_STATE_IDLE) {
        ws.RxBuffer.State = NAV_WEBSOCKET_STATE_CONNECTING
    }

    // Process buffer based on current state
    while (length_array(ws.RxBuffer.Data)) {
        switch (ws.RxBuffer.State) {
            case NAV_WEBSOCKET_STATE_CONNECTING: {
                // Accumulate handshake response
                ws.RxBuffer.HandshakeData = "ws.RxBuffer.HandshakeData, ws.RxBuffer.Data"
                // Clear buffer after copying to handshake data
                set_length_array(ws.RxBuffer.Data, 0)

                // Wait for complete HTTP response (CRLF CRLF)
                if (!NAVContains(ws.RxBuffer.HandshakeData, "NAV_CR, NAV_LF, NAV_CR, NAV_LF")) {
                    break
                }

                // Validate handshake
                if (!NAVWebSocketValidateHandshakeResponse(ws.RxBuffer.HandshakeData, ws.RxBuffer.HandshakeKey)) {
                    #IF_DEFINED USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK
                    {
                        stack_var _NAVWebSocketOnErrorResult errorResult

                        errorResult.ErrorCode = NAV_WEBSOCKET_ERROR_INVALID_FRAME
                        errorResult.Message = 'Handshake validation failed'

                        NAVWebSocketOnErrorCallback(ws, errorResult)
                    }
                    #END_IF

                    ws.RxBuffer.State = NAV_WEBSOCKET_STATE_CLOSED
                    break
                }

                // Handshake successful
                ws.RxBuffer.State = NAV_WEBSOCKET_STATE_OPEN
                ws.RxBuffer.HandshakeData = ''

                #IF_DEFINED USING_NAV_WEBSOCKET_ON_OPEN_CALLBACK
                {
                    stack_var _NAVWebSocketOnOpenResult openResult
                    NAVWebSocketOnOpenCallback(ws, openResult)
                }
                #END_IF

                continue
            }

            case NAV_WEBSOCKET_STATE_OPEN: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                           __NAV_FOUNDATION_WEBSOCKET__,
                                           'NAVWebSocketProcessBuffer',
                                           "'OPEN state, buffer length: ', itoa(length_array(ws.RxBuffer.Data))")

                // Parse next frame from buffer
                if (NAVWebSocketParseFrame(ws.RxBuffer.Data, parseResult) != NAV_WEBSOCKET_SUCCESS) {
                    if (parseResult.Status == NAV_WEBSOCKET_ERROR_INCOMPLETE) {
                        // Need more data
                        break
                    }

                    // Protocol error - send close frame with protocol error code
                    NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_PROTOCOL_ERROR, 'Protocol error')

                    #IF_DEFINED USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK
                    {
                        stack_var _NAVWebSocketOnErrorResult errorResult

                        errorResult.ErrorCode = parseResult.Status
                        errorResult.Message = 'Frame parsing error'

                        NAVWebSocketOnErrorCallback(ws, errorResult)
                    }
                    #END_IF

                    break
                }

                // Remove processed bytes from buffer using get_buffer_string
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                           __NAV_FOUNDATION_WEBSOCKET__,
                                           'NAVWebSocketProcessBuffer',
                                           "'Consuming ', itoa(parseResult.BytesConsumed), ' bytes from buffer'")
                get_buffer_string(ws.RxBuffer.Data, parseResult.BytesConsumed)
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                           __NAV_FOUNDATION_WEBSOCKET__,
                                           'NAVWebSocketProcessBuffer',
                                           "'After removal, buffer length: ', itoa(length_array(ws.RxBuffer.Data))")

                // Handle frame based on opcode
                switch (parseResult.Frame.Opcode) {
                    case NAV_WEBSOCKET_OPCODE_CONTINUATION: {
                        // RFC 6455 §5.4: Continuation frame
                        if (!ws.RxBuffer.IsFragmenting) {
                            // Continuation frame without initial fragment - protocol error
                            NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_PROTOCOL_ERROR, 'Unexpected continuation frame')
                            break
                        }

                        // Check fragment size limit before appending
                        if (length_array(ws.RxBuffer.FragmentBuffer) + length_array(parseResult.Frame.Payload) > NAV_WEBSOCKET_MAX_MESSAGE_SIZE) {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                       __NAV_FOUNDATION_WEBSOCKET__,
                                                       'NAVWebSocketProcessBuffer',
                                                       "'Fragmented message exceeds maximum size: ', itoa(length_array(ws.RxBuffer.FragmentBuffer) + length_array(parseResult.Frame.Payload)), ' bytes'")
                            NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_MESSAGE_TOO_BIG, 'Message exceeds maximum size')

                            #IF_DEFINED USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK
                            {
                                stack_var _NAVWebSocketOnErrorResult errorResult
                                errorResult.ErrorCode = NAV_WEBSOCKET_ERROR_BUFFER_TOO_SMALL
                                errorResult.Message = 'Message exceeds maximum allowed size'
                                NAVWebSocketOnErrorCallback(ws, errorResult)
                            }
                            #END_IF

                            break
                        }

                        // Append payload to fragment buffer
                        ws.RxBuffer.FragmentBuffer = "ws.RxBuffer.FragmentBuffer, parseResult.Frame.Payload"

                        // Check if this is the final fragment
                        if (parseResult.Frame.Fin) {
                            // For text frames, validate UTF-8 encoding
                            if (ws.RxBuffer.FragmentOpcode == NAV_WEBSOCKET_OPCODE_TEXT) {
                                if (!NAVEncodingIsValidUtf8(ws.RxBuffer.FragmentBuffer)) {
                                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                               __NAV_FOUNDATION_WEBSOCKET__,
                                                               'NAVWebSocketProcessBuffer',
                                                               'Invalid UTF-8 in fragmented text message')
                                    NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_INVALID_PAYLOAD, 'Invalid UTF-8')

                                    #IF_DEFINED USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK
                                    {
                                        stack_var _NAVWebSocketOnErrorResult errorResult
                                        errorResult.ErrorCode = NAV_WEBSOCKET_ERROR_INVALID_UTF8
                                        errorResult.Message = 'Invalid UTF-8 encoding in text frame'
                                        NAVWebSocketOnErrorCallback(ws, errorResult)
                                    }
                                    #END_IF

                                    break
                                }
                            }

                            // Message complete - fire callback with reassembled data
                            #IF_DEFINED USING_NAV_WEBSOCKET_ON_MESSAGE_CALLBACK
                            {
                                stack_var _NAVWebSocketOnMessageResult messageResult

                                messageResult.Opcode = ws.RxBuffer.FragmentOpcode
                                messageResult.Data = ws.RxBuffer.FragmentBuffer
                                messageResult.IsFinal = true

                                NAVWebSocketOnMessageCallback(ws, messageResult)
                            }
                            #END_IF

                            // Reset fragmentation state
                            ws.RxBuffer.IsFragmenting = false
                            ws.RxBuffer.FragmentBuffer = ''
                            ws.RxBuffer.FragmentOpcode = 0
                        }
                    }

                    case NAV_WEBSOCKET_OPCODE_TEXT:
                    case NAV_WEBSOCKET_OPCODE_BINARY: {
                        // Check if this is a fragmented message
                        if (!parseResult.Frame.Fin) {
                            // First fragment of a fragmented message
                            if (ws.RxBuffer.IsFragmenting) {
                                // Already fragmenting - protocol error
                                NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_PROTOCOL_ERROR, 'Interleaved fragments')
                                break
                            }

                            // Check initial fragment size
                            if (length_array(parseResult.Frame.Payload) > NAV_WEBSOCKET_MAX_MESSAGE_SIZE) {
                                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                           __NAV_FOUNDATION_WEBSOCKET__,
                                                           'NAVWebSocketProcessBuffer',
                                                           "'Initial fragment exceeds maximum size: ', itoa(length_array(parseResult.Frame.Payload)), ' bytes'")
                                NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_MESSAGE_TOO_BIG, 'Message exceeds maximum size')

                                #IF_DEFINED USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK
                                {
                                    stack_var _NAVWebSocketOnErrorResult errorResult
                                    errorResult.ErrorCode = NAV_WEBSOCKET_ERROR_BUFFER_TOO_SMALL
                                    errorResult.Message = 'Message exceeds maximum allowed size'
                                    NAVWebSocketOnErrorCallback(ws, errorResult)
                                }
                                #END_IF

                                break
                            }

                            // Start fragment reassembly
                            ws.RxBuffer.IsFragmenting = true
                            ws.RxBuffer.FragmentOpcode = parseResult.Frame.Opcode
                            ws.RxBuffer.FragmentBuffer = parseResult.Frame.Payload
                        }
                        else {
                            // Complete message in single frame
                            if (ws.RxBuffer.IsFragmenting) {
                                // Received non-continuation frame while fragmenting - protocol error
                                NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_PROTOCOL_ERROR, 'Expected continuation frame')
                                break
                            }

                            // For text frames, validate UTF-8 encoding
                            if (parseResult.Frame.Opcode == NAV_WEBSOCKET_OPCODE_TEXT) {
                                if (!NAVEncodingIsValidUtf8(parseResult.Frame.Payload)) {
                                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                               __NAV_FOUNDATION_WEBSOCKET__,
                                                               'NAVWebSocketProcessBuffer',
                                                               'Invalid UTF-8 in text message')
                                    NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_INVALID_PAYLOAD, 'Invalid UTF-8')

                                    #IF_DEFINED USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK
                                    {
                                        stack_var _NAVWebSocketOnErrorResult errorResult
                                        errorResult.ErrorCode = NAV_WEBSOCKET_ERROR_INVALID_UTF8
                                        errorResult.Message = 'Invalid UTF-8 encoding in text frame'
                                        NAVWebSocketOnErrorCallback(ws, errorResult)
                                    }
                                    #END_IF

                                    break
                                }
                            }

                            // Fire message callback
                            #IF_DEFINED USING_NAV_WEBSOCKET_ON_MESSAGE_CALLBACK
                            {
                                stack_var _NAVWebSocketOnMessageResult messageResult

                                messageResult.Opcode = parseResult.Frame.Opcode
                                messageResult.Data = parseResult.Frame.Payload
                                messageResult.IsFinal = true

                                NAVWebSocketOnMessageCallback(ws, messageResult)
                            }
                            #END_IF
                        }
                    }

                    case NAV_WEBSOCKET_OPCODE_CLOSE: {
                        // Parse close frame
                        NAVWebSocketParseCloseFrame(parseResult.Frame, closeData)

                        // If we haven't sent close frame yet, send it now (echo close)
                        if (ws.RxBuffer.State == NAV_WEBSOCKET_STATE_OPEN) {
                            NAVWebSocketSendClose(ws, closeData.StatusCode, closeData.Reason)
                        }

                        ws.RxBuffer.State = NAV_WEBSOCKET_STATE_CLOSED
                        ws.IsConnected = false

                        // Close the underlying socket
                        NAVWebSocketCloseSocket(ws)

                        #IF_DEFINED USING_NAV_WEBSOCKET_ON_CLOSE_CALLBACK
                        {
                            stack_var _NAVWebSocketOnCloseResult closeResult

                            closeResult.StatusCode = closeData.StatusCode
                            closeResult.Reason = closeData.Reason

                            NAVWebSocketOnCloseCallback(ws, closeResult)
                        }
                        #END_IF
                    }

                    case NAV_WEBSOCKET_OPCODE_PING: {
                        // Auto-respond with pong
                        if (NAVWebSocketBuildPongFrame(parseResult.Frame.Payload, NAV_WEBSOCKET_UNMASKED, pongFrame)) {
                            NAVWebSocketSendFrame(ws.Device, pongFrame)
                        }
                    }

                    case NAV_WEBSOCKET_OPCODE_PONG: {
                        // Pong received - silently ignore (could add callback if needed)
                    }

                    default: {
                        // RFC 6455 §5.2: Reserved opcodes must cause protocol error
                        // Opcodes 0x03-0x07 (data frames) and 0x0B-0x0F (control frames) are reserved
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                   __NAV_FOUNDATION_WEBSOCKET__,
                                                   'NAVWebSocketProcessBuffer',
                                                   "'Received frame with reserved opcode: 0x', itohex(parseResult.Frame.Opcode)")
                        NAVWebSocketSendClose(ws, NAV_WEBSOCKET_CLOSE_PROTOCOL_ERROR, 'Reserved opcode')

                        #IF_DEFINED USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK
                        {
                            stack_var _NAVWebSocketOnErrorResult errorResult
                            errorResult.ErrorCode = NAV_WEBSOCKET_ERROR_INVALID_OPCODE
                            errorResult.Message = 'Received frame with reserved opcode'
                            NAVWebSocketOnErrorCallback(ws, errorResult)
                        }
                        #END_IF

                        break
                    }
                }

                continue
            }

            case NAV_WEBSOCKET_STATE_CLOSING: {
                // RFC 6455 §7.1.3: We sent close frame, waiting for server's close response
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                           __NAV_FOUNDATION_WEBSOCKET__,
                                           'NAVWebSocketProcessBuffer',
                                           'CLOSING state, waiting for server close frame')

                // Parse next frame from buffer
                if (NAVWebSocketParseFrame(ws.RxBuffer.Data, parseResult) != NAV_WEBSOCKET_SUCCESS) {
                    if (parseResult.Status == NAV_WEBSOCKET_ERROR_INCOMPLETE) {
                        // Need more data
                        break
                    }

                    // Error while closing - just close socket
                    ws.RxBuffer.State = NAV_WEBSOCKET_STATE_CLOSED
                    ws.IsConnected = false

                    NAVWebSocketCloseSocket(ws)
                    break
                }

                // Remove processed bytes from buffer
                get_buffer_string(ws.RxBuffer.Data, parseResult.BytesConsumed)

                // Check if it's a close frame
                if (parseResult.Frame.Opcode == NAV_WEBSOCKET_OPCODE_CLOSE) {
                    // Server responded with close frame - graceful close complete
                    NAVWebSocketParseCloseFrame(parseResult.Frame, closeData)

                    ws.RxBuffer.State = NAV_WEBSOCKET_STATE_CLOSED
                    ws.IsConnected = false

                    // Close the underlying socket
                    NAVWebSocketCloseSocket(ws)

                    #IF_DEFINED USING_NAV_WEBSOCKET_ON_CLOSE_CALLBACK
                    {
                        stack_var _NAVWebSocketOnCloseResult closeResult

                        closeResult.StatusCode = closeData.StatusCode
                        closeResult.Reason = closeData.Reason

                        NAVWebSocketOnCloseCallback(ws, closeResult)
                    }
                    #END_IF
                }
                // Ignore other frames while closing

                continue
            }

            case NAV_WEBSOCKET_STATE_CLOSED: {
                // Connection closed - discard any remaining data
                ws.RxBuffer.Data = ''
                break
            }
        }

        // Break out of while loop if we didn't continue
        break
    }

    ws.RxBuffer.Semaphore = false
}


#END_IF // __NAV_FOUNDATION_WEBSOCKET__
