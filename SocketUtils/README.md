# NAVFoundation.SocketUtils

A comprehensive socket utility library for NAVFoundation that provides a robust set of functions for managing TCP, UDP, TLS, and SSH socket connections with built-in error handling, logging, and exponential backoff retry mechanisms.

## Features

- **Multiple Protocol Support**: TCP, UDP, UDP 2-Way, TLS, and SSH connections
- **Error Handling**: Comprehensive error code handling with human-readable messages
- **Retry Logic**: Built-in exponential backoff with configurable retry parameters
- **Logging**: Automatic error logging for troubleshooting
- **Validation**: Input validation for addresses, ports, and credentials
- **TLS Support**: Secure connections with certificate validation options

## Installation

Include the library in your NetLinx project:

```netlinx
#include 'NAVFoundation.SocketUtils.axi'
```

## Functions

### Socket Connection Management

#### `NAVClientSocketOpen`

Opens a client socket connection to a remote server.

**Parameters:**
- `socket` (integer): Socket ID to use
- `address` (char[]): IP address or hostname of remote server
- `port` (integer): Port number to connect to
- `protocol` (integer): Protocol type (IP_TCP, IP_UDP, or IP_UDP_2WAY)

**Returns:** `slong` - 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

// Connect to a device at 192.168.1.100 on port 23 (Telnet)
result = NAVClientSocketOpen(dvTCPClient.PORT, '192.168.1.100', 23, IP_TCP)
if (result < 0) {
    // Handle error
    NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Connection failed: ', NAVGetSocketError(result)")
}
```

**Notes:**
- IP_UDP client sockets can send datagrams without establishing a connection
- For hostname resolution, ensure DNS is properly configured on the master

---

#### `NAVClientSocketClose`

Closes a client socket connection.

**Parameters:**
- `socket` (integer): Socket ID to close

**Returns:** `slong` - 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

result = NAVClientSocketClose(dvTCPClient.PORT)
if (result < 0) {
    // Handle error
}
```

---

#### `NAVServerSocketOpen`

Opens a server socket that listens for incoming connections.

**Parameters:**
- `socket` (integer): Socket ID to use
- `port` (integer): Port number to listen on
- `protocol` (integer): Protocol type (IP_TCP, IP_UDP, or IP_UDP_2WAY)

**Returns:** `slong` - 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

// Open TCP server on port 8080
result = NAVServerSocketOpen(dvServerSocket.PORT, 8080, IP_TCP)
if (result < 0) {
    // Handle error
}
```

**Notes:**
- For UDP sockets, connections will come in on the same socket ID
- For TCP sockets, new client connections will be received with different socket IDs

---

#### `NAVServerSocketClose`

Closes a server socket and stops listening for connections.

**Parameters:**
- `socket` (integer): Socket ID to close

**Returns:** `slong` - 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

result = NAVServerSocketClose(dvServerSocket.PORT)
if (result < 0) {
    // Handle error
}
```

---

### TLS Connections

#### `NAVClientTlsSocketOpen`

Opens a TLS client socket connection to a remote server.

**Parameters:**
- `socket` (integer): Socket ID to use
- `address` (char[]): IP address or hostname of remote server
- `port` (integer): Port number to connect to
- `mode` (integer): TLS_VALIDATE_CERTIFICATE (0), or TLS_IGNORE_CERTIFICATE_ERRORS (1)

**Returns:** `slong` - 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

// Connect with certificate validation
result = NAVClientTlsSocketOpen(dvTLSClient.PORT, '192.168.1.100', 443, TLS_VALIDATE_CERTIFICATE)
if (result < 0) {
    // Handle error
}

// Connect ignoring certificate errors (for self-signed certificates)
result = NAVClientTlsSocketOpen(dvTLSClient.PORT, '192.168.1.100', 443, TLS_IGNORE_CERTIFICATE_ERRORS)
```

**Notes:**
- For hostname resolution, ensure DNS is properly configured on the master
- Use TLS_VALIDATE_CERTIFICATE for production environments
- TLS_IGNORE_CERTIFICATE_ERRORS can be used for self-signed certificates in development

---

#### `NAVClientTlsSocketClose`

Closes a TLS client socket connection.

**Parameters:**
- `socket` (integer): Socket ID to close

**Returns:** `slong` - 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

result = NAVClientTlsSocketClose(dvTLSClient.PORT)
if (result < 0) {
    // Handle error
}
```

---

### SSH Connections

#### `NAVClientSecureSocketOpen`

Opens a secure (SSH) client socket connection.

**Parameters:**
- `socket` (integer): Socket ID to use
- `address` (char[]): IP address or hostname of remote server
- `port` (integer): Port number to connect to (defaults to 22 if ≤ 0)
- `username` (char[]): SSH username for authentication
- `password` (char[]): SSH password for authentication (can be empty if using privateKey)
- `privateKey` (char[]): Path to SSH private key file (can be empty if using password)
- `privateKeyPassphrase` (char[]): Passphrase for private key (if required)

**Returns:** `slong` - 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

// Connect using username/password
result = NAVClientSecureSocketOpen(dvSSHClient.PORT, '10.0.0.1', 22, 'admin', 'password', '', '')

// Connect using private key
result = NAVClientSecureSocketOpen(dvSSHClient.PORT, '10.0.0.1', 22, 'admin', '', '/amx/keys/id_rsa', '')

// Connect with private key and passphrase
result = NAVClientSecureSocketOpen(dvSSHClient.PORT, '10.0.0.1', 22, 'admin', '', '/amx/keys/id_rsa', 'keypass')
```

**Notes:**
- Either password or privateKey must be provided
- If port is ≤ 0, defaults to standard SSH port (22)

---

#### `NAVClientSecureSocketClose`

Closes a secure (SSH) client socket connection.

**Parameters:**
- `socket` (integer): Socket ID to close

**Returns:** `slong` - 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

result = NAVClientSecureSocketClose(dvSSHClient.PORT)
if (result < 0) {
    // Handle error
}
```

---

### Error Handling

#### `NAVGetSocketError`

Converts a socket error code to a human-readable error message.

**Parameters:**
- `error` (slong): Error code returned by a socket operation

**Returns:** `char[]` - Human-readable error description

**Example:**
```netlinx
stack_var slong result
stack_var char errorMessage[NAV_MAX_BUFFER]

result = NAVClientSocketOpen(dvTCPClient.PORT, '192.168.1.100', 23, IP_TCP)
if (result < 0) {
    errorMessage = NAVGetSocketError(result)
    NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Socket error: ', errorMessage")
}
```

---

#### `NAVGetSocketProtocol`

Converts a protocol constant to a human-readable protocol name.

**Parameters:**
- `protocol` (integer): Protocol value (IP_TCP, IP_UDP, or IP_UDP_2WAY)

**Returns:** `char[]` - Human-readable protocol name

**Example:**
```netlinx
stack_var integer protocol
stack_var char protocolName[NAV_MAX_BUFFER]

protocol = IP_TCP
protocolName = NAVGetSocketProtocol(protocol)  // Returns 'TCP'
```

---

#### `NAVGetTlsSocketMode`

Converts a TLS mode constant to a human-readable mode name.

**Parameters:**
- `mode` (integer): Protocol value (TLS_VALIDATE_CERTIFICATE, or TLS_IGNORE_CERTIFICATE_ERRORS)

**Returns:** `char[]` - Human-readable mode name

**Example:**
```netlinx
stack_var integer mode
stack_var char modeName[NAV_MAX_BUFFER]

mode = TLS_VALIDATE_CERTIFICATE
modeName = NAVGetTlsSocketMode(mode)  // Returns 'TLS Validate Certificate'
```

---

### Retry Logic

#### `NAVSocketGetExponentialBackoff`

Calculates an exponential backoff interval for socket connection retry attempts with jitter.

**Parameters:**
- `attempt` (integer): Current attempt number (1-based)
- `maxRetries` (integer): Number of attempts to use base delay before starting exponential backoff
- `baseDelay` (long): Base delay in milliseconds for initial attempts
- `maxDelay` (long): Maximum delay in milliseconds (cap for exponential growth)

**Returns:** `long` - Calculated delay interval in milliseconds

**Example:**
```netlinx
stack_var integer attemptCount
stack_var long retryInterval

attemptCount = 5
retryInterval = NAVSocketGetExponentialBackoff(attemptCount, 3, 5000, 300000)
// First 3 attempts: 5000ms
// 4th attempt: ~5000ms
// 5th attempt: ~10000ms + jitter
// 6th attempt: ~20000ms + jitter
```

**Notes:**
- For attempts ≤ maxRetries, returns baseDelay
- For attempts > maxRetries, uses formula: baseDelay × 2^(attempt - maxRetries) + jitter
- Jitter is a random value between 100-1000ms to prevent synchronized retries
- Final delay is capped at maxDelay (after jitter is added)

---

#### `NAVSocketGetConnectionInterval`

Calculates the retry interval for socket connection attempts using exponential backoff with default settings.

**Parameters:**
- `attempt` (integer): Current attempt number (1-based)

**Returns:** `long` - Calculated delay interval in milliseconds

**Example:**
```netlinx
stack_var integer attemptCount
stack_var long retryInterval

attemptCount++
retryInterval = NAVSocketGetConnectionInterval(attemptCount)
wait retryInterval 'SOCKET_RETRY' {
    NAVClientSocketOpen(dvTCPClient.PORT, '192.168.1.100', 23, IP_TCP)
}
```

**Notes:**
- Uses NAV_MAX_SOCKET_CONNECTION_RETRIES (10 attempts before exponential backoff)
- Uses NAV_SOCKET_CONNECTION_INTERVAL_BASE_DELAY (5000ms base delay)
- Uses NAV_SOCKET_CONNECTION_INTERVAL_MAX_DELAY (300000ms maximum delay)
- See NAVSocketGetExponentialBackoff for detailed backoff algorithm

---

## Constants

### Error Codes

| Constant | Value | Description |
|----------|-------|-------------|
| `NAV_SOCKET_ERROR_INVALID_SERVER_PORT` | -1 | Invalid server port specified |
| `NAV_SOCKET_ERROR_INVALID_PROTOCOL_VALUE` | -2 | Invalid protocol value specified |
| `NAV_SOCKET_ERROR_UNABLE_TO_OPEN_PORT` | -3 | Unable to open communication port |
| `NAV_SOCKET_ERROR_INVALID_HOST_ADDRESS` | -10 | Invalid host address provided |
| `NAV_SOCKET_ERROR_INVALID_PORT` | -11 | Invalid port number specified |
| `NAV_SOCKET_ERROR_GENERAL_FAILURE` | 2 | General failure (usually out of memory) |
| `NAV_SOCKET_ERROR_UNKNOWN_HOST` | 4 | Unknown host (DNS resolution failed) |
| `NAV_SOCKET_ERROR_CONNECTION_REFUSED` | 6 | Connection refused by remote host |
| `NAV_SOCKET_ERROR_CONNECTION_TIMED_OUT` | 7 | Connection attempt timed out |
| `NAV_SOCKET_ERROR_UNKNOWN_CONNECTION_ERROR` | 8 | Unknown connection error |
| `NAV_SOCKET_ERROR_ALREADY_CLOSED` | 9 | Socket is already closed |
| `NAV_SOCKET_ERROR_BINDING_ERROR` | 10 | Unable to bind socket to address/port |
| `NAV_SOCKET_ERROR_LISTENING_ERROR` | 11 | Unable to start listening on socket |
| `NAV_SOCKET_ERROR_LOCAL_PORT_ALREADY_USED` | 14 | The specified local port is already in use |
| `NAV_SOCKET_ERROR_UDP_SOCKET_ALREADY_LISTENING` | 15 | UDP socket is already listening |
| `NAV_SOCKET_ERROR_TOO_MANY_OPEN_SOCKETS` | 16 | Too many open sockets (system limit reached) |
| `NAV_SOCKET_ERROR_LOCAL_PORT_NOT_OPEN` | 17 | The specified local port is not open |

### Retry Configuration

| Constant | Default Value | Description |
|----------|---------------|-------------|
| `NAV_MAX_SOCKET_CONNECTION_RETRIES` | 10 | Maximum number of retry attempts before starting exponential backoff |
| `NAV_SOCKET_CONNECTION_INTERVAL_BASE_DELAY` | 5000 ms | Base delay between socket connection retry attempts |
| `NAV_SOCKET_CONNECTION_INTERVAL_MAX_DELAY` | 300000 ms | Maximum delay between retry attempts (5 minutes) |

**Note:** These constants can be overridden by defining them before including the library:

```netlinx
#define NAV_MAX_SOCKET_CONNECTION_RETRIES 5
#define NAV_SOCKET_CONNECTION_INTERVAL_BASE_DELAY 3000
#define NAV_SOCKET_CONNECTION_INTERVAL_MAX_DELAY 60000

#include 'NAVFoundation.SocketUtils.axi'
```

---

## Complete Example

Here's a complete example demonstrating socket connection with automatic retry using exponential backoff:

```netlinx
PROGRAM_NAME='SocketExample'

#include 'NAVFoundation.SocketUtils.axi'

DEFINE_DEVICE
dvTCPClient = 0:3:0

DEFINE_VARIABLE
volatile integer connectionAttempt = 0
volatile char deviceAddress[NAV_MAX_CHARS] = '192.168.1.100'
volatile integer devicePort = 23

DEFINE_START

ConnectToDevice()

DEFINE_FUNCTION ConnectToDevice() {
    stack_var slong result
    
    connectionAttempt++
    
    result = NAVClientSocketOpen(dvTCPClient.PORT, deviceAddress, devicePort, IP_TCP)
    
    if (result < 0) {
        stack_var long retryInterval
        
        NAVErrorLog(NAV_LOG_LEVEL_WARNING, 
                   "'Connection attempt ', itoa(connectionAttempt), ' failed: ', NAVGetSocketError(result)")
        
        // Calculate next retry interval
        retryInterval = NAVSocketGetConnectionInterval(connectionAttempt)
        
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                   "'Retrying in ', itoa(retryInterval), 'ms...'")
        
        // Schedule retry
        wait retryInterval 'SOCKET_RETRY' {
            ConnectToDevice()
        }
    }
    else {
        connectionAttempt = 0  // Reset on success
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Connected successfully'")
    }
}

DEFINE_EVENT

data_event[dvTCPClient] {
    online: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Device is online'")
        connectionAttempt = 0
    }
    offline: {
        NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'Device went offline, reconnecting...'")
        cancel_wait 'SOCKET_RETRY'
        connectionAttempt = 0
        wait 10 'SOCKET_RETRY' {
            ConnectToDevice()
        }
    }
    string: {
        // Handle incoming data
    }
}
```

---

## Best Practices

1. **Always Check Return Values**: Socket operations can fail for various reasons. Always check the return value and handle errors appropriately.

2. **Use Exponential Backoff**: When implementing reconnection logic, use the provided exponential backoff functions to avoid overwhelming the network or target device.

3. **Log Errors**: Use the error conversion functions to provide meaningful error messages in your logs.

4. **Validate Input**: The library validates addresses and ports, but ensure you provide valid values to avoid unnecessary error handling.

5. **Clean Up Connections**: Always close sockets when they're no longer needed to free up system resources.

6. **Handle Offline Events**: Implement proper `offline` event handlers to manage disconnections gracefully.

7. **Configure Retry Parameters**: Adjust the retry constants based on your application's requirements and network conditions.

---

## License

MIT License - Copyright (c) 2010-2026 Norgate AV
