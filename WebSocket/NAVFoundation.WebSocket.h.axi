PROGRAM_NAME='NAVFoundation.WebSocket.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_WEBSOCKET_H__
#DEFINE __NAV_FOUNDATION_WEBSOCKET_H__ 'NAVFoundation.WebSocket.h'

#include 'NAVFoundation.Url.h.axi'


DEFINE_CONSTANT

// =============================================================================
// WebSocket Buffer Size Configuration
// =============================================================================

/**
 * @constant NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE
 * @description Maximum size for a single frame payload buffer.
 *              This determines the size of frame payload buffers throughout the implementation.
 *              Default: 65535 bytes (64KB - maximum for 16-bit length encoding)
 *
 *              Adjust based on your use case:
 *              - Small messages (chat, commands): 4096 or 8192 bytes
 *              - Medium messages (JSON, XML): 16384 or 32768 bytes
 *              - Large messages (file transfer, video): 65535 bytes or use fragmentation
 *
 *              Note: Larger buffers consume more memory per WebSocket connection.
 * @type {long}
 */
#IF_NOT_DEFINED NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE
constant long NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE    = 65535
#END_IF

/**
 * @constant NAV_WEBSOCKET_FRAGMENT_BUFFER_SIZE
 * @description Maximum size for reassembling fragmented messages.
 *              This is the buffer used to accumulate fragments before delivering complete message.
 *              Default: 65535 bytes (64KB)
 *
 *              Adjust based on your fragmentation needs:
 *              - No fragmentation expected: Match NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE
 *              - Large fragmented messages: Increase (e.g., 131072 for 128KB, 262144 for 256KB)
 *              - Memory constrained: Reduce and handle fragmentation at application level
 *
 *              Note: This is per-connection memory allocation.
 * @type {long}
 */
#IF_NOT_DEFINED NAV_WEBSOCKET_FRAGMENT_BUFFER_SIZE
constant long NAV_WEBSOCKET_FRAGMENT_BUFFER_SIZE      = 65535
#END_IF

/**
 * @constant NAV_WEBSOCKET_HANDSHAKE_REQUEST_SIZE
 * @description Maximum size for WebSocket handshake request.
 *              Default: 2000 bytes
 *
 *              Increase if you need:
 *              - Very long URLs with query strings
 *              - Many custom headers
 *              - Authentication tokens in headers
 *
 *              Typical handshake is 200-500 bytes, default provides ample headroom.
 * @type {integer}
 */
#IF_NOT_DEFINED NAV_WEBSOCKET_HANDSHAKE_REQUEST_SIZE
constant integer NAV_WEBSOCKET_HANDSHAKE_REQUEST_SIZE = 2000
#END_IF

/**
 * @constant NAV_WEBSOCKET_HANDSHAKE_RESPONSE_SIZE
 * @description Maximum size for WebSocket handshake response accumulation.
 *              Default: 10000 bytes
 *
 *              Increase if server sends:
 *              - Many response headers
 *              - Large cookie values
 *              - Verbose error messages
 *
 *              Most handshake responses are under 1000 bytes.
 * @type {integer}
 */
#IF_NOT_DEFINED NAV_WEBSOCKET_HANDSHAKE_RESPONSE_SIZE
constant integer NAV_WEBSOCKET_HANDSHAKE_RESPONSE_SIZE = 10000
#END_IF

/**
 * @constant NAV_WEBSOCKET_ERROR_MESSAGE_SIZE
 * @description Maximum size for error message strings.
 *              Default: 255 bytes
 *
 *              Adjust if you need longer diagnostic messages.
 * @type {integer}
 */
#IF_NOT_DEFINED NAV_WEBSOCKET_ERROR_MESSAGE_SIZE
constant integer NAV_WEBSOCKET_ERROR_MESSAGE_SIZE     = 255
#END_IF


// =============================================================================
// WebSocket Frame Opcodes (RFC 6455 Section 5.2)
// =============================================================================

/**
 * @constant NAV_WEBSOCKET_OPCODE_CONTINUATION
 * @description Denotes a continuation frame in a fragmented message.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_OPCODE_CONTINUATION    = $00

/**
 * @constant NAV_WEBSOCKET_OPCODE_TEXT
 * @description Denotes a text frame containing UTF-8 encoded data.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_OPCODE_TEXT            = $01

/**
 * @constant NAV_WEBSOCKET_OPCODE_BINARY
 * @description Denotes a binary frame containing arbitrary binary data.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_OPCODE_BINARY          = $02

/**
 * @constant NAV_WEBSOCKET_OPCODE_CLOSE
 * @description Denotes a connection close control frame.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_OPCODE_CLOSE           = $08

/**
 * @constant NAV_WEBSOCKET_OPCODE_PING
 * @description Denotes a ping control frame.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_OPCODE_PING            = $09

/**
 * @constant NAV_WEBSOCKET_OPCODE_PONG
 * @description Denotes a pong control frame (response to ping).
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_OPCODE_PONG            = $0A


// =============================================================================
// WebSocket Frame Limits and Boundaries
// =============================================================================

/**
 * @constant NAV_WEBSOCKET_MAX_CONTROL_PAYLOAD
 * @description Maximum payload length for control frames (ping, pong, close).
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_MAX_CONTROL_PAYLOAD    = 125

/**
 * @constant NAV_WEBSOCKET_MAX_MESSAGE_SIZE
 * @description Maximum size for reassembled fragmented messages (10MB).
 *              Prevents memory exhaustion from malicious large fragmented messages.
 * @type {long}
 */
constant long NAV_WEBSOCKET_MAX_MESSAGE_SIZE          = 10485760

/**
 * @constant NAV_WEBSOCKET_MAX_PAYLOAD_16
 * @description Maximum payload length that can be encoded with 16-bit length.
 * @type {long}
 */
constant long NAV_WEBSOCKET_MAX_PAYLOAD_16            = 65535

/**
 * @constant NAV_WEBSOCKET_PAYLOAD_LENGTH_16
 * @description Payload length indicator for 16-bit extended length.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_PAYLOAD_LENGTH_16      = 126

/**
 * @constant NAV_WEBSOCKET_PAYLOAD_LENGTH_64
 * @description Payload length indicator for 64-bit extended length.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_PAYLOAD_LENGTH_64      = 127

/**
 * @constant NAV_WEBSOCKET_MASKING_KEY_LENGTH
 * @description Length of the masking key in bytes.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_MASKING_KEY_LENGTH     = 4


// =============================================================================
// WebSocket Handshake Constants (RFC 6455)
// =============================================================================

/**
 * @constant NAV_WEBSOCKET_GUID
 * @description Magic string used in WebSocket handshake for generating Sec-WebSocket-Accept.
 * This is the GUID defined in RFC 6455 Section 1.3.
 * @type {char[]}
 */
constant char NAV_WEBSOCKET_GUID[]                    = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'


// =============================================================================
// WebSocket Close Status Codes (RFC 6455 Section 7.4)
// =============================================================================

/**
 * @constant NAV_WEBSOCKET_CLOSE_NORMAL
 * @description Normal closure; the connection successfully completed.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_NORMAL           = 1000

/**
 * @constant NAV_WEBSOCKET_CLOSE_GOING_AWAY
 * @description Endpoint is going away (e.g., server shutdown or browser navigation).
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_GOING_AWAY       = 1001

/**
 * @constant NAV_WEBSOCKET_CLOSE_PROTOCOL_ERROR
 * @description Endpoint is terminating due to a protocol error.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_PROTOCOL_ERROR   = 1002

/**
 * @constant NAV_WEBSOCKET_CLOSE_UNSUPPORTED_DATA
 * @description Endpoint received data of a type it cannot accept.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_UNSUPPORTED_DATA = 1003

/**
 * @constant NAV_WEBSOCKET_CLOSE_NO_STATUS
 * @description Reserved. Indicates no status code was present.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_NO_STATUS        = 1005

/**
 * @constant NAV_WEBSOCKET_CLOSE_ABNORMAL
 * @description Reserved. Connection closed abnormally (e.g., no close frame).
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_ABNORMAL         = 1006

/**
 * @constant NAV_WEBSOCKET_CLOSE_INVALID_PAYLOAD
 * @description Endpoint received data inconsistent with message type.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_INVALID_PAYLOAD  = 1007

/**
 * @constant NAV_WEBSOCKET_CLOSE_POLICY_VIOLATION
 * @description Endpoint received message that violates its policy.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_POLICY_VIOLATION = 1008

/**
 * @constant NAV_WEBSOCKET_CLOSE_MESSAGE_TOO_BIG
 * @description Endpoint received message too large to process.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_MESSAGE_TOO_BIG  = 1009

/**
 * @constant NAV_WEBSOCKET_CLOSE_MANDATORY_EXT
 * @description Client expected server to negotiate extension(s).
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_MANDATORY_EXT    = 1010

/**
 * @constant NAV_WEBSOCKET_CLOSE_INTERNAL_ERROR
 * @description Server encountered unexpected condition preventing fulfillment.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_INTERNAL_ERROR   = 1011

/**
 * @constant NAV_WEBSOCKET_CLOSE_TLS_HANDSHAKE_FAILED
 * @description Reserved. TLS handshake failed.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_CLOSE_TLS_HANDSHAKE_FAILED = 1015


// =============================================================================
// WebSocket Operation Status Codes
// =============================================================================

/**
 * @constant NAV_WEBSOCKET_SUCCESS
 * @description Operation completed successfully.
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_SUCCESS                = 0

/**
 * @constant NAV_WEBSOCKET_ERROR_INVALID_FRAME
 * @description Frame structure is invalid or malformed.
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_ERROR_INVALID_FRAME    = -1

/**
 * @constant NAV_WEBSOCKET_ERROR_INCOMPLETE
 * @description Insufficient data to parse complete frame.
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_ERROR_INCOMPLETE       = -2

/**
 * @constant NAV_WEBSOCKET_ERROR_CONTROL_TOO_BIG
 * @description Control frame payload exceeds 125 byte limit.
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_ERROR_CONTROL_TOO_BIG  = -3

/**
 * @constant NAV_WEBSOCKET_ERROR_FRAGMENTED_CTRL
 * @description Control frames must not be fragmented.
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_ERROR_FRAGMENTED_CTRL  = -4

/**
 * @constant NAV_WEBSOCKET_ERROR_INVALID_OPCODE
 * @description Unknown or reserved opcode encountered.
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_ERROR_INVALID_OPCODE   = -5

/**
 * @constant NAV_WEBSOCKET_ERROR_RESERVED_BITS
 * @description Reserved bits set without extension negotiation.
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_ERROR_RESERVED_BITS    = -6

/**
 * @constant NAV_WEBSOCKET_ERROR_BUFFER_TOO_SMALL
 * @description Output buffer is too small for the operation.
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_ERROR_BUFFER_TOO_SMALL = -7

/**
 * @constant NAV_WEBSOCKET_ERROR_INVALID_CLOSE_CODE
 * @description Invalid close status code.
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_ERROR_INVALID_CLOSE_CODE = -8

/**
 * @constant NAV_WEBSOCKET_ERROR_PROTOCOL_ERROR
 * @description Protocol error (e.g., server sent masked frame).
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_ERROR_PROTOCOL_ERROR = -9

/**
 * @constant NAV_WEBSOCKET_ERROR_INVALID_UTF8
 * @description Invalid UTF-8 encoding in text frame.
 * @type {sinteger}
 */
constant sinteger NAV_WEBSOCKET_ERROR_INVALID_UTF8 = -10


// =============================================================================
// WebSocket Frame Options
// =============================================================================

/**
 * @constant NAV_WEBSOCKET_MASKED
 * @description Indicates frame payload should be masked (required for client->server).
 * @type {char}
 */
constant char NAV_WEBSOCKET_MASKED      = true

/**
 * @constant NAV_WEBSOCKET_UNMASKED
 * @description Indicates frame payload should not be masked (used for server->client).
 * @type {char}
 */
constant char NAV_WEBSOCKET_UNMASKED    = false


// =============================================================================
// WebSocket Connection States
// =============================================================================

/**
 * @constant NAV_WEBSOCKET_STATE_IDLE
 * @description WebSocket is idle, not yet initialized.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_STATE_IDLE        = 0

/**
 * @constant NAV_WEBSOCKET_STATE_CONNECTING
 * @description WebSocket handshake in progress.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_STATE_CONNECTING  = 1

/**
 * @constant NAV_WEBSOCKET_STATE_OPEN
 * @description WebSocket handshake complete, ready for data frames.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_STATE_OPEN   = 2

/**
 * @constant NAV_WEBSOCKET_STATE_CLOSING
 * @description WebSocket close frame sent or received.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_STATE_CLOSING     = 3

/**
 * @constant NAV_WEBSOCKET_STATE_CLOSED
 * @description WebSocket connection closed.
 * @type {integer}
 */
constant integer NAV_WEBSOCKET_STATE_CLOSED      = 4


DEFINE_TYPE

/**
 * @struct _NAVWebSocketFrame
 * @description Represents a complete WebSocket frame according to RFC 6455.
 *
 * @property {char} Fin - Final fragment flag (1 = final fragment, 0 = more fragments follow)
 * @property {char} Rsv1 - Reserved bit 1 (must be 0 unless extension negotiated)
 * @property {char} Rsv2 - Reserved bit 2 (must be 0 unless extension negotiated)
 * @property {char} Rsv3 - Reserved bit 3 (must be 0 unless extension negotiated)
 * @property {integer} Opcode - Frame opcode (text, binary, close, ping, pong, continuation)
 * @property {char} Mask - Mask flag (1 = payload is masked, 0 = payload is not masked)
 * @property {long} PayloadLength - Length of payload data in bytes
 * @property {char[4]} MaskingKey - 4-byte masking key (only present if Mask = 1)
 * @property {char[NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE]} Payload - The payload data
 */
struct _NAVWebSocketFrame {
    char Fin
    char Rsv1
    char Rsv2
    char Rsv3
    integer Opcode
    char Mask
    long PayloadLength
    char MaskingKey[4]
    char Payload[NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE]
}

/**
 * @struct _NAVWebSocketFrameOptions
 * @description Options for building WebSocket frames.
 *
 * @property {char} Masked - Whether to mask the frame payload (NAV_WEBSOCKET_MASKED/UNMASKED)
 * @property {char} Fin - Whether this is the final fragment (1 = final, 0 = more fragments)
 */
struct _NAVWebSocketFrameOptions {
    char Masked
    char Fin
}

/**
 * @struct _NAVWebSocketCloseFrame
 * @description Represents the payload of a WebSocket close frame.
 *
 * @property {integer} StatusCode - Close status code (see NAV_WEBSOCKET_CLOSE_* constants)
 * @property {char[123]} Reason - Human-readable close reason (max 123 bytes, UTF-8)
 */
struct _NAVWebSocketCloseFrame {
    integer StatusCode
    char Reason[123]
}

/**
 * @struct _NAVWebSocketFrameParseResult
 * @description Result of parsing a WebSocket frame from raw bytes.
 *
 * @property {sinteger} Status - Parse result status (NAV_WEBSOCKET_SUCCESS or error code)
 * @property {_NAVWebSocketFrame} Frame - The parsed frame structure
 * @property {long} BytesConsumed - Number of bytes consumed from input buffer
 */
struct _NAVWebSocketFrameParseResult {
    sinteger Status
    _NAVWebSocketFrame Frame
    long BytesConsumed
}

/**
 * @struct _NAVWebSocketBuffer
 * @description Buffer structure for processing WebSocket data with state management.
 *
 * Used internally by the WebSocket state machine for incremental frame processing.
 * Connect the Data field to a device buffer using create_buffer.
 *
 * @property {char[NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE]} Data - Buffer containing received WebSocket data
 * @property {char} Semaphore - Prevents concurrent access to buffer
 * @property {integer} State - Current connection state (IDLE, CONNECTING, OPEN, CLOSING, CLOSED)
 * @property {char[16]} HandshakeKey - Key for handshake validation (fixed 16 bytes per RFC)
 * @property {char[NAV_WEBSOCKET_HANDSHAKE_RESPONSE_SIZE]} HandshakeData - Accumulated handshake response
 *
 * @see _NAVWebSocket
 * @see NAVWebSocketProcessBuffer
 */
struct _NAVWebSocketBuffer {
    char Data[NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE]
    char Semaphore
    integer State
    char HandshakeKey[16]
    char HandshakeData[NAV_WEBSOCKET_HANDSHAKE_RESPONSE_SIZE]
    // Fragmentation support
    char FragmentBuffer[NAV_WEBSOCKET_FRAGMENT_BUFFER_SIZE]      // Accumulates fragmented message data
    integer FragmentOpcode          // Opcode of first fragment
    char IsFragmenting              // True if currently reassembling fragments
}

/**
 * @struct _NAVWebSocket
 * @description WebSocket connection context and state management.
 *              Use this struct to track all WebSocket connection information
 *              and state across your application.
 *
 * @property {dev} Device - The network device for this WebSocket connection
 * @property {_NAVUrl} Url - Parsed URL structure containing scheme, host, port, path
 * @property {char} IsConnected - TCP/TLS socket connection state flag (true=socket connected)
 * @property {char[NAV_WEBSOCKET_HANDSHAKE_REQUEST_SIZE]} HandshakeRequest - Built handshake request ready to send
 * @property {_NAVWebSocketBuffer} RxBuffer - Embedded buffer for callback-based processing
 *
 * @note Access URL components via ws.Url.Host, ws.Url.Port, ws.Url.Scheme, etc.
 * @note Handshake key, response data, and receive buffer are in RxBuffer
 * @note Check RxBuffer.State for WebSocket readyState (IDLE, CONNECTING, OPEN, CLOSING, CLOSED)
 */
struct _NAVWebSocket {
    dev Device
    _NAVUrl Url
    char IsConnected
    char HandshakeRequest[NAV_WEBSOCKET_HANDSHAKE_REQUEST_SIZE]
    _NAVWebSocketBuffer RxBuffer
}

/**
 * @struct _NAVWebSocketOnOpenResult
 * @description Result structure passed to onopen callback.
 *
 * @see NAVWebSocketOnOpenCallback
 */
struct _NAVWebSocketOnOpenResult {
    char Reserved  // Placeholder for future use
}

/**
 * @struct _NAVWebSocketOnMessageResult
 * @description Result structure passed to onmessage callback.
 *
 * @property {integer} Opcode - Frame opcode (TEXT or BINARY)
 * @property {char[NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE]} Data - Message payload
 * @property {char} IsFinal - Whether this is the final fragment (FIN bit)
 *
 * @see NAVWebSocketOnMessageCallback
 */
struct _NAVWebSocketOnMessageResult {
    integer Opcode
    char Data[NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE]
    char IsFinal
}

/**
 * @struct _NAVWebSocketOnErrorResult
 * @description Result structure passed to onerror callback.
 *
 * @property {sinteger} ErrorCode - Error code from NAV_WEBSOCKET_ERROR_* constants
 * @property {char[NAV_WEBSOCKET_ERROR_MESSAGE_SIZE]} Message - Human-readable error message
 *
 * @see NAVWebSocketOnErrorCallback
 */
struct _NAVWebSocketOnErrorResult {
    sinteger ErrorCode
    char Message[NAV_WEBSOCKET_ERROR_MESSAGE_SIZE]
}

/**
 * @struct _NAVWebSocketOnCloseResult
 * @description Result structure passed to onclose callback.
 *
 * @property {integer} StatusCode - Close status code
 * @property {char[]} Reason - Close reason string
 *
 * @see NAVWebSocketOnCloseCallback
 */
struct _NAVWebSocketOnCloseResult {
    integer StatusCode
    char Reason[123]
}


#END_IF // __NAV_FOUNDATION_WEBSOCKET_H__
