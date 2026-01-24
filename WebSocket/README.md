# NAVFoundation.WebSocket

RFC 6455 compliant WebSocket client implementation for AMX NetLinx systems, featuring automatic handshake handling, frame parsing/building, fragmentation support, and W3C WebSocket API-style callbacks.

## Table of Contents

- [Features](#features)
- [Standards Compliance](#standards-compliance)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
    - [Initialization](#initialization)
    - [Connection Management](#connection-management)
    - [Sending Data](#sending-data)
    - [Callbacks](#callbacks)
    - [State Management](#state-management)
- [Configuration](#configuration)
- [Examples](#examples)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)

## Features

✅ **RFC 6455 Compliant** - Full WebSocket protocol implementation  
✅ **W3C WebSocket API** - Familiar `onopen`, `onmessage`, `onclose`, `onerror` callback pattern  
✅ **Automatic Handshake** - HTTP Upgrade request generation and validation  
✅ **Frame Management** - Automatic frame parsing, masking, and validation  
✅ **Fragmentation Support** - Transparent reassembly of fragmented messages  
✅ **Ping/Pong** - Automatic response to server ping frames  
✅ **UTF-8 Validation** - Text frames validated for proper encoding  
✅ **Secure WebSocket** - Support for both `ws://` and `wss://` URLs  
✅ **Error Handling** - Comprehensive error detection and callbacks

## Standards Compliance

This implementation adheres to:

- **RFC 6455** - The WebSocket Protocol
- **W3C WebSocket API** - Callback naming and behavior
- **RFC 3986** - URI parsing
- **RFC 2616** - HTTP/1.1 for handshake

### WebSocket States (RFC 6455 §4)

| State                            | Value | Description                          |
| -------------------------------- | ----- | ------------------------------------ |
| `NAV_WEBSOCKET_STATE_IDLE`       | 0     | Not initialized                      |
| `NAV_WEBSOCKET_STATE_CONNECTING` | 1     | TCP connected, handshake in progress |
| `NAV_WEBSOCKET_STATE_OPEN`       | 2     | Handshake complete, ready for data   |
| `NAV_WEBSOCKET_STATE_CLOSING`    | 3     | Close frame sent/received            |
| `NAV_WEBSOCKET_STATE_CLOSED`     | 4     | Connection closed                    |

## Quick Start

### Basic WebSocket Client

```netlinx
PROGRAM_NAME='WebSocketExample'

#DEFINE USING_NAV_WEBSOCKET_ON_OPEN_CALLBACK
#DEFINE USING_NAV_WEBSOCKET_ON_MESSAGE_CALLBACK
#DEFINE USING_NAV_WEBSOCKET_ON_CLOSE_CALLBACK
#DEFINE USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK

#include 'NAVFoundation.WebSocket.axi'

DEFINE_DEVICE
dvWebSocket = 0:11:0

DEFINE_VARIABLE
volatile _NAVWebSocket ws

// WebSocket opened - handshake complete
define_function NAVWebSocketOnOpenCallback(_NAVWebSocket ws, _NAVWebSocketOnOpenResult result) {
    send_string 0, "'WebSocket opened to ', ws.Url.Host"

    // Send a message
    NAVWebSocketSend(ws, 'Hello from NetLinx!')
}

// Message received from server
define_function NAVWebSocketOnMessageCallback(_NAVWebSocket ws, _NAVWebSocketOnMessageResult result) {
    switch (result.Opcode) {
        case NAV_WEBSOCKET_OPCODE_TEXT: {
            send_string 0, "'Text: ', result.Data"
        }
        case NAV_WEBSOCKET_OPCODE_BINARY: {
            send_string 0, "'Binary: ', itoa(length_array(result.Data)), ' bytes'"
        }
    }
}

// Connection closed
define_function NAVWebSocketOnCloseCallback(_NAVWebSocket ws, _NAVWebSocketOnCloseResult result) {
    send_string 0, "'Connection closed: ', itoa(result.StatusCode), ' - ', result.Reason"
}

// Error occurred
define_function NAVWebSocketOnErrorCallback(_NAVWebSocket ws, _NAVWebSocketOnErrorResult result) {
    send_string 0, "'Error ', itoa(result.ErrorCode), ': ', result.Message"
}

DEFINE_START {
    // Initialize WebSocket
    NAVWebSocketInit(ws, dvWebSocket)
    create_buffer dvWebSocket, ws.RxBuffer.Data

    // Connect to server
    wait 10 {
        NAVWebSocketConnect(ws, 'ws://localhost:8080/socket')
    }
}

DEFINE_EVENT
data_event[dvWebSocket] {
    online: {
        NAVWebSocketOnConnect(ws)
    }
    offline: {
        NAVWebSocketOnDisconnect(ws)
    }
    onerror: {
        NAVWebSocketOnError(ws)
    }
    string: {
        NAVWebSocketProcessBuffer(ws)
    }
}
```

## API Reference

### Initialization

#### `NAVWebSocketInit(ws, device)`

Initializes a WebSocket context structure.

**Parameters:**

- `ws` (\_NAVWebSocket) - WebSocket context to initialize
- `device` (dev) - Network device for the connection

**Example:**

```netlinx
stack_var _NAVWebSocket ws
NAVWebSocketInit(ws, dvWebSocket)
create_buffer dvWebSocket, ws.RxBuffer.Data  // Required for automatic buffering
```

### Connection Management

#### `NAVWebSocketConnect(ws, url)`

Connects to a WebSocket server.

**Parameters:**

- `ws` (\_NAVWebSocket) - Initialized WebSocket context
- `url` (char[]) - Complete WebSocket URL

**Returns:** `char` - TRUE if connection initiated, FALSE on error

**Supported URL schemes:**

- `ws://` - Unencrypted WebSocket
- `wss://` - WebSocket Secure (TLS)

**Example:**

```netlinx
if (NAVWebSocketConnect(ws, 'ws://example.com:8080/chat')) {
    // Connection initiated, wait for OnOpenCallback
}
```

#### `NAVWebSocketIsOpen(ws)`

Checks if WebSocket is in OPEN state (ready for data transfer).

**Parameters:**

- `ws` (\_NAVWebSocket) - WebSocket context

**Returns:** `char` - TRUE if in OPEN state, FALSE otherwise

**Example:**

```netlinx
if (NAVWebSocketIsOpen(ws)) {
    NAVWebSocketSend(ws, 'Hello!')
}
```

#### `NAVWebSocketClose(ws)`

Gracefully closes the WebSocket connection.

**Parameters:**

- `ws` (\_NAVWebSocket) - WebSocket context

**Returns:** `char` - TRUE if close initiated, FALSE if not connected

**Example:**

```netlinx
NAVWebSocketClose(ws)  // Sends close frame with status 1000 (Normal Closure)
```

### Sending Data

#### `NAVWebSocketSend(ws, data)`

Sends text or binary data over the WebSocket.

**Parameters:**

- `ws` (\_NAVWebSocket) - WebSocket context
- `data` (char[]) - Data to send (automatically framed as text)

**Returns:** `char` - TRUE if sent successfully, FALSE otherwise

**Example:**

```netlinx
NAVWebSocketSend(ws, 'Hello WebSocket!')
NAVWebSocketSend(ws, "'{"type":"message","value":"Hello"}'")  // JSON
```

### Callbacks

Enable callbacks by defining the corresponding preprocessor directive before including the library.

#### OnOpen Callback

Called when the WebSocket handshake completes successfully.

**Enable:**

```netlinx
#DEFINE USING_NAV_WEBSOCKET_ON_OPEN_CALLBACK
```

**Signature:**

```netlinx
define_function NAVWebSocketOnOpenCallback(_NAVWebSocket ws, _NAVWebSocketOnOpenResult result)
```

**Example:**

```netlinx
define_function NAVWebSocketOnOpenCallback(_NAVWebSocket ws, _NAVWebSocketOnOpenResult result) {
    send_string 0, "'Connected to ', ws.Url.Host, ':', itoa(ws.Url.Port)"
    NAVWebSocketSend(ws, 'Hello from NetLinx!')
}
```

#### OnMessage Callback

Called when a message (text or binary frame) is received.

**Enable:**

```netlinx
#DEFINE USING_NAV_WEBSOCKET_ON_MESSAGE_CALLBACK
```

**Signature:**

```netlinx
define_function NAVWebSocketOnMessageCallback(_NAVWebSocket ws, _NAVWebSocketOnMessageResult result)
```

**Result Fields:**

- `result.Opcode` (integer) - `NAV_WEBSOCKET_OPCODE_TEXT` or `NAV_WEBSOCKET_OPCODE_BINARY`
- `result.Data` (char[]) - Message payload
- `result.IsFinal` (char) - TRUE if final fragment

**Example:**

```netlinx
define_function NAVWebSocketOnMessageCallback(_NAVWebSocket ws, _NAVWebSocketOnMessageResult result) {
    switch (result.Opcode) {
        case NAV_WEBSOCKET_OPCODE_TEXT: {
            send_string 0, "'Text message: ', result.Data"
        }
        case NAV_WEBSOCKET_OPCODE_BINARY: {
            send_string 0, "'Binary data: ', itoa(length_array(result.Data)), ' bytes'"
            // Process binary data
        }
    }
}
```

#### OnClose Callback

Called when the WebSocket connection closes.

**Enable:**

```netlinx
#DEFINE USING_NAV_WEBSOCKET_ON_CLOSE_CALLBACK
```

**Signature:**

```netlinx
define_function NAVWebSocketOnCloseCallback(_NAVWebSocket ws, _NAVWebSocketOnCloseResult result)
```

**Result Fields:**

- `result.StatusCode` (integer) - Close status code (see RFC 6455 §7.4)
- `result.Reason` (char[123]) - Optional reason string

**Common Status Codes:**

- `1000` - Normal Closure
- `1001` - Going Away
- `1002` - Protocol Error
- `1003` - Unsupported Data
- `1006` - Abnormal Closure (no close frame received)

**Example:**

```netlinx
define_function NAVWebSocketOnCloseCallback(_NAVWebSocket ws, _NAVWebSocketOnCloseResult result) {
    send_string 0, "'WebSocket closed: ', itoa(result.StatusCode)"
    if (length_array(result.Reason)) {
        send_string 0, "'Reason: ', result.Reason"
    }
}
```

#### OnError Callback

Called when a protocol error occurs.

**Enable:**

```netlinx
#DEFINE USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK
```

**Signature:**

```netlinx
define_function NAVWebSocketOnErrorCallback(_NAVWebSocket ws, _NAVWebSocketOnErrorResult result)
```

**Result Fields:**

- `result.ErrorCode` (sinteger) - Error code (see error constants)
- `result.Message` (char[255]) - Human-readable error message

**Error Codes:**
| Code | Constant | Description |
|------|----------|-------------|
| `-1` | `NAV_WEBSOCKET_ERROR_INVALID_FRAME` | Malformed frame |
| `-2` | `NAV_WEBSOCKET_ERROR_INCOMPLETE` | Incomplete frame data |
| `-5` | `NAV_WEBSOCKET_ERROR_INVALID_OPCODE` | Unknown/reserved opcode |
| `-6` | `NAV_WEBSOCKET_ERROR_RESERVED_BITS` | Reserved bits set |
| `-9` | `NAV_WEBSOCKET_ERROR_PROTOCOL_ERROR` | Protocol violation |
| `-10` | `NAV_WEBSOCKET_ERROR_INVALID_UTF8` | Invalid UTF-8 encoding |

**Example:**

```netlinx
define_function NAVWebSocketOnErrorCallback(_NAVWebSocket ws, _NAVWebSocketOnErrorResult result) {
    send_string 0, "'WebSocket error ', itoa(result.ErrorCode), ': ', result.Message"

    // Optionally close connection on errors
    if (result.ErrorCode == NAV_WEBSOCKET_ERROR_PROTOCOL_ERROR) {
        NAVWebSocketClose(ws)
    }
}
```

### State Management

#### Event Handlers

These functions must be called from your device event handlers:

**`NAVWebSocketOnConnect(ws)`** - Call from `data_event[device].online`  
**`NAVWebSocketOnDisconnect(ws)`** - Call from `data_event[device].offline`  
**`NAVWebSocketOnError(ws)`** - Call from `data_event[device].onerror`  
**`NAVWebSocketProcessBuffer(ws)`** - Call from `data_event[device].string`

**Example:**

```netlinx
data_event[dvWebSocket] {
    online: {
        NAVWebSocketOnConnect(ws)
    }
    offline: {
        NAVWebSocketOnDisconnect(ws)
    }
    onerror: {
        NAVWebSocketOnError(ws)
    }
    string: {
        NAVWebSocketProcessBuffer(ws)
    }
}
```

## Configuration

### Buffer Sizes

Adjust these constants in your code **before** including the WebSocket library:

```netlinx
// Maximum payload size per frame (default: 65535 bytes)
#DEFINE NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE 32768

// Maximum size for fragmented message reassembly (default: 65535 bytes)
#DEFINE NAV_WEBSOCKET_FRAGMENT_BUFFER_SIZE 131072

#include 'NAVFoundation.WebSocket.axi'
```

### Available Configuration Constants

| Constant                                | Default | Description                      |
| --------------------------------------- | ------- | -------------------------------- |
| `NAV_WEBSOCKET_MAX_FRAME_PAYLOAD_SIZE`  | 65535   | Single frame payload buffer size |
| `NAV_WEBSOCKET_FRAGMENT_BUFFER_SIZE`    | 65535   | Fragmented message buffer size   |
| `NAV_WEBSOCKET_HANDSHAKE_REQUEST_SIZE`  | 2000    | Handshake request buffer size    |
| `NAV_WEBSOCKET_HANDSHAKE_RESPONSE_SIZE` | 10000   | Handshake response buffer size   |
| `NAV_WEBSOCKET_ERROR_MESSAGE_SIZE`      | 255     | Error message buffer size        |

## Examples

### Echo Client

```netlinx
define_function NAVWebSocketOnOpenCallback(_NAVWebSocket ws, _NAVWebSocketOnOpenResult result) {
    NAVWebSocketSend(ws, 'echo test message')
}

define_function NAVWebSocketOnMessageCallback(_NAVWebSocket ws, _NAVWebSocketOnMessageResult result) {
    if (result.Opcode == NAV_WEBSOCKET_OPCODE_TEXT) {
        send_string 0, "'Echo received: ', result.Data"
    }
}
```

### JSON Communication

```netlinx
define_function SendJsonCommand(_NAVWebSocket ws, char cmd[], char value[]) {
    stack_var char json[1000]
    json = "'{'"
    json = "json, '"command":"', cmd, '"'"
    json = "json, ',"value":"', value, '"'"
    json = "json, '}'"
    NAVWebSocketSend(ws, json)
}

define_function NAVWebSocketOnOpenCallback(_NAVWebSocket ws, _NAVWebSocketOnOpenResult result) {
    SendJsonCommand(ws, 'subscribe', 'temperature')
}

define_function NAVWebSocketOnMessageCallback(_NAVWebSocket ws, _NAVWebSocketOnMessageResult result) {
    if (result.Opcode == NAV_WEBSOCKET_OPCODE_TEXT) {
        // Parse JSON response (using NAVFoundation.Jsmn or similar)
        send_string 0, "'JSON: ', result.Data"
    }
}
```

### Auto-Reconnect Pattern

```netlinx
DEFINE_CONSTANT
constant long TL_WEBSOCKET_RECONNECT = 1
constant long TL_WEBSOCKET_RECONNECT_DELAY[] = { 5000 }  // 5 seconds

define_function NAVWebSocketOnCloseCallback(_NAVWebSocket ws, _NAVWebSocketOnCloseResult result) {
    send_string 0, "'Connection closed, will reconnect in 5 seconds'"
    timeline_create(TL_WEBSOCKET_RECONNECT,
                    TL_WEBSOCKET_RECONNECT_DELAY,
                    1,
                    TIMELINE_ABSOLUTE,
                    TIMELINE_ONCE)
}

timeline_event[TL_WEBSOCKET_RECONNECT] {
    NAVWebSocketConnect(ws, 'ws://localhost:8080')
}
```

### Heartbeat/Keep-Alive

```netlinx
DEFINE_CONSTANT
constant long TL_WEBSOCKET_HEARTBEAT = 2
constant long TL_WEBSOCKET_HEARTBEAT_INTERVAL[] = { 30000 }  // 30 seconds

define_function NAVWebSocketOnOpenCallback(_NAVWebSocket ws, _NAVWebSocketOnOpenResult result) {
    timeline_create(TL_WEBSOCKET_HEARTBEAT,
                    TL_WEBSOCKET_HEARTBEAT_INTERVAL,
                    length_array(TL_WEBSOCKET_HEARTBEAT_INTERVAL),
                    TIMELINE_ABSOLUTE,
                    TIMELINE_REPEAT)
}

define_function NAVWebSocketOnCloseCallback(_NAVWebSocket ws, _NAVWebSocketOnCloseResult result) {
    timeline_kill(TL_WEBSOCKET_HEARTBEAT)
}

timeline_event[TL_WEBSOCKET_HEARTBEAT] {
    if (NAVWebSocketIsOpen(ws)) {
        NAVWebSocketSend(ws, 'heartbeat')
    }
}
```

## Error Handling

### Protocol Errors

The library automatically handles protocol errors by:

1. Sending a close frame with appropriate status code
2. Triggering the `OnErrorCallback` if defined
3. Closing the underlying socket

### Connection Errors

Monitor TCP/TLS connection state via device events:

```netlinx
data_event[dvWebSocket] {
    onerror: {
        NAVWebSocketOnError(ws)

        // Get socket error details
        stack_var integer errorCode
        errorCode = data.number
        send_string 0, "'Socket error: ', NAVGetSocketError(errorCode)"
    }
}
```

### Validation Errors

- **Invalid UTF-8** - Text frames with invalid UTF-8 encoding are rejected
- **Invalid Close Codes** - Close frames with reserved codes (1004, 1005, 1006, 1015) cannot be sent
- **Control Frame Size** - Control frames (ping, pong, close) limited to 125 bytes
- **Masked Server Frames** - Server must never send masked frames (protocol violation)

## Best Practices

### 1. Always Initialize Before Connecting

```netlinx
NAVWebSocketInit(ws, dvWebSocket)
create_buffer dvWebSocket, ws.RxBuffer.Data  // Required!
```

### 2. Check State Before Sending

```netlinx
if (NAVWebSocketIsOpen(ws)) {
    NAVWebSocketSend(ws, data)
}
```

### 3. Handle All Callbacks

Define all four callbacks for robust error handling:

- `OnOpenCallback` - Connection established
- `OnMessageCallback` - Data received
- `OnCloseCallback` - Connection closed (expected or unexpected)
- `OnErrorCallback` - Protocol errors

### 4. Graceful Shutdown

```netlinx
// Send close frame and wait for server response
NAVWebSocketClose(ws)

// Don't immediately disconnect the socket - let the closing handshake complete
```

### 5. Memory Management

- Adjust buffer sizes based on your message sizes
- Large buffers consume memory per connection
- Consider fragmentation for very large messages

### 6. Security

- Use `wss://` for encrypted connections
- Validate server certificates with `TLS_VALIDATE_CERTIFICATE`
- Never send sensitive data over unencrypted `ws://` connections

### 7. Debugging

Enable debug logging to troubleshoot issues:

```netlinx
set_log_level(NAV_LOG_LEVEL_DEBUG)
```

## WebSocket Server Testing

For development and testing, you can use the included Deno test server:

```bash
deno run --allow-net __tests__/include/websocket/server.js
```

Or use any WebSocket server/service like:

- [websocket.org](https://www.websocket.org/echo.html) - Echo server
- [Postman](https://www.postman.com/) - WebSocket testing
- Node.js `ws` library
- Python `websockets` library

## License

MIT License - Copyright (c) 2010-2026 Norgate AV

## References

- [RFC 6455 - The WebSocket Protocol](https://datatracker.ietf.org/doc/html/rfc6455)
- [W3C WebSocket API](https://www.w3.org/TR/websockets/)
- [MDN WebSocket Documentation](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
