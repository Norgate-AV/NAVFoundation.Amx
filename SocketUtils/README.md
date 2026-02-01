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

### High-Level Connection Management

The library provides a high-level connection management API that simplifies socket handling with built-in retry logic, exponential backoff, and automatic reconnection.

#### `NAVSocketConnectionInit`

Initializes a socket connection structure with default values using an options struct.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure to initialize
- `options` (\_NAVSocketConnectionOptions): Options structure containing initialization parameters

**Returns:** `char` - True (1) if initialization successful, false (0) if validation failed

**Example:**

```netlinx
stack_var _NAVSocketConnection socketConn
stack_var _NAVSocketConnectionOptions options

options.Name = 'Device Connection'
options.Device = dvPort
options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
options.Protocol = IP_TCP
options.Port = 23
options.TimelineId = TL_SOCKET_MAINTAIN

if (!NAVSocketConnectionInit(socketConn, options)) {
    // Handle initialization failure
}
```

**Notes:**

- Device number must be 0 for socket connections
- Socket number (device.PORT) must be greater than 1
- Port must be in range 1-65535
- ConnectionType must be NAV_SOCKET_CONNECTION_TYPE_TCP_UDP, \_SSH, or \_TLS
- For SSH connections, set options.SshUsername and either options.SshPassword or options.SshPrivateKey
- For TLS connections, set options.TlsMode (TLS_VALIDATE_CERTIFICATE or TLS_IGNORE_CERTIFICATE_ERRORS)

---

#### `NAVSocketConnectionSetAddress`

Sets the address for a socket connection with validation.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure
- `address` (char[]): IP address or hostname

**Returns:** `char` - True if address was valid and set (or cleared), false if invalid

**Example:**

```netlinx
// Set IP address
if (NAVSocketConnectionSetAddress(socketConn, '192.168.1.100')) {
    NAVSocketConnectionReset(socketConn)  // Apply changes
}

// Set hostname
if (NAVSocketConnectionSetAddress(socketConn, 'device.local')) {
    NAVSocketConnectionReset(socketConn)
}

// Clear address
NAVSocketConnectionSetAddress(socketConn, '')
```

**Notes:**

- Validates both IP addresses and hostnames
- Empty addresses will clear the connection (returns true)
- Invalid addresses will be rejected and an error will be logged (returns false)
- Call NAVSocketConnectionReset() after changing connection properties to apply changes

---

#### `NAVSocketConnectionSetPort`

Sets the port for a socket connection with validation.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure
- `port` (integer): Port number (1-65535)

**Returns:** `char` - True if port was valid and set, false if invalid

**Example:**

```netlinx
if (NAVSocketConnectionSetPort(socketConn, 8080)) {
    NAVSocketConnectionReset(socketConn)  // Apply changes
}
```

**Notes:**

- Port must be between 1 and 65535 (inclusive)
- Call NAVSocketConnectionReset() after changing connection properties to apply changes

---

#### `NAVSocketConnectionSetAutoReconnect`

Enables or disables automatic reconnection for a socket connection.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure
- `enabled` (char): True to enable auto-reconnect, false to disable

**Example:**

```netlinx
// Disable auto-reconnect
NAVSocketConnectionSetAutoReconnect(socketConn, false)

// Enable auto-reconnect
NAVSocketConnectionSetAutoReconnect(socketConn, true)
```

**Notes:**

- When enabling, automatically starts the connection timeline
- When disabling, stops the connection timeline
- Default is enabled after initialization

---

#### `NAVSocketConnectionSetCredential`

Sets username and password credentials for authenticated connections (SSH).

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure
- `username` (char[]): Username for authentication
- `password` (char[]): Password for authentication

**Returns:** `char` - True if credentials were set successfully, false if validation failed

**Example:**

```netlinx
if (NAVSocketConnectionSetCredential(socketConn, 'admin', 'password123')) {
    // Credentials valid
}
```

**Notes:**

- Username cannot be empty (whitespace is automatically trimmed)
- Password can be empty if using SSH private key authentication
- Primarily used for SSH connections

---

#### `NAVSocketConnectionSetSshPrivateKey`

Sets SSH private key authentication parameters.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure
- `privateKey` (char[]): Path to SSH private key file
- `passphrase` (char[]): Passphrase for private key (empty if not required)

**Returns:** `char` - True if private key path was set successfully, false if validation failed

**Example:**

```netlinx
// Private key without passphrase
if (NAVSocketConnectionSetSshPrivateKey(socketConn, '/amx/keys/id_rsa', '')) {
    // Private key path valid
}

// Private key with passphrase
if (NAVSocketConnectionSetSshPrivateKey(socketConn, '/amx/keys/id_rsa', 'keypass')) {
    // Private key path valid
}
```

**Notes:**

- Private key path cannot be empty
- Use this instead of password for key-based SSH authentication
- Passphrase can be empty if the key is not encrypted

---

#### `NAVSocketConnectionSetTlsMode`

Sets the TLS certificate validation mode.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure
- `mode` (integer): TLS_VALIDATE_CERTIFICATE (0) or TLS_IGNORE_CERTIFICATE_ERRORS (1)

**Returns:** `char` - True if mode was valid and set successfully, false if validation failed

**Example:**

```netlinx
// Enable certificate validation
if (NAVSocketConnectionSetTlsMode(socketConn, TLS_VALIDATE_CERTIFICATE)) {
    // TLS mode valid
}

// Ignore certificate errors (for self-signed certificates)
if (NAVSocketConnectionSetTlsMode(socketConn, TLS_IGNORE_CERTIFICATE_ERRORS)) {
    // TLS mode valid
}
```

**Notes:**

- Only valid for TLS connection types
- Use TLS_VALIDATE_CERTIFICATE for production environments
- TLS_IGNORE_CERTIFICATE_ERRORS useful for self-signed certificates in development

---

#### `NAVSocketConnectionIsConfigured`

Checks if a socket connection has been properly configured.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure

**Returns:** `char` - True if address and port are configured, false otherwise

**Example:**

```netlinx
if (NAVSocketConnectionIsConfigured(socketConn)) {
    // Connection can be established
    NAVSocketConnectionStart(socketConn)
}
```

**Notes:**

- Returns true only if both address and port are set
- Does not check if the connection is actually online

---

#### `NAVSocketConnectionMaintain`

Maintains a socket connection by attempting to reconnect if disconnected.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure

**Example:**

```netlinx
timeline_event[TL_SOCKET_CHECK] {
    NAVSocketConnectionMaintain(socketConn)
}
```

**Notes:**

- Automatically handles TCP, SSH, and TLS connections based on ConnectionType
- Only reconnects if IsConnected is false and AutoReconnect is enabled
- Implements exponential backoff retry logic
- Call this from a timeline event handler

---

#### `NAVSocketConnectionStart`

Starts the socket connection timeline for automatic reconnection.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure

**Example:**

```netlinx
NAVSocketConnectionStart(socketConn)
```

**Notes:**

- Only starts if connection is configured and AutoReconnect is enabled
- Uses the connection's TimelineId and Interval values
- Timeline calls NAVSocketConnectionMaintain() periodically

---

#### `NAVSocketConnectionStop`

Stops the socket connection timeline and closes the connection.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure

**Example:**

```netlinx
NAVSocketConnectionStop(socketConn)
```

**Notes:**

- Stops the connection timeline
- Closes the connection if it's currently open
- Automatically handles TCP, SSH, and TLS connections based on ConnectionType

---

#### `NAVSocketConnectionReset`

Resets a socket connection by closing it, resetting retry counters, and restarting the connection timeline.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure

**Example:**

```netlinx
// After changing connection properties
NAVSocketConnectionSetAddress(socketConn, '192.168.1.200')
NAVSocketConnectionSetPort(socketConn, 8080)
NAVSocketConnectionReset(socketConn)  // Apply changes
```

**Notes:**

- Closes existing connection if open
- Resets retry counter to 0
- Restarts timeline if AutoReconnect is enabled
- Use this after changing connection properties (address, port, etc.)

---

#### `NAVSocketConnectionHandleOnline`

Handles the online event for a socket connection.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure
- `data` (tdata): Event data from data_event

**Example:**

```netlinx
data_event[dvPort] {
    online: {
        NAVSocketConnectionHandleOnline(socketConn, data)
        // Your custom online handling here
    }
}
```

**Notes:**

- Updates connection state (IsConnected = true)
- Resets retry counter
- Logs connection success
- Call this at the start of your online event handler

---

#### `NAVSocketConnectionHandleOffline`

Handles the offline event for a socket connection.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure
- `data` (tdata): Event data from data_event

**Example:**

```netlinx
data_event[dvPort] {
    offline: {
        NAVSocketConnectionHandleOffline(socketConn, data)
        // Your custom offline handling here
    }
}
```

**Notes:**

- Updates connection state (IsConnected = false)
- Logs disconnection
- Automatically triggers reconnection if AutoReconnect is enabled
- Call this at the start of your offline event handler

---

### Connection Status and Information

#### `NAVSocketConnectionGetStatus`

Gets a human-readable status string for a socket connection.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure

**Returns:** `char[]` - Human-readable status string

**Example:**

```netlinx
stack_var char status[NAV_MAX_CHARS]

status = NAVSocketConnectionGetStatus(socketConn)
// Returns: "Connected", "Disconnected", "Not Configured", or "Connecting (attempt N)"
```

**Possible Return Values:**

- "Connected" - Socket is currently connected
- "Disconnected" - Socket is disconnected and not retrying
- "Not Configured" - Address or port not configured
- "Connecting (attempt N)" - Currently retrying connection (N = attempt number)

---

#### `NAVSocketConnectionGetConnectionTypeString`

Gets a human-readable string representation of the connection type.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure

**Returns:** `char[]` - Connection type string

**Example:**

```netlinx
stack_var char connType[NAV_MAX_CHARS]

connType = NAVSocketConnectionGetConnectionTypeString(socketConn)
// Returns: "TCP/UDP", "SSH", "TLS", or "Unknown (N)"
```

**Possible Return Values:**

- "TCP/UDP" - Standard TCP or UDP connection
- "SSH" - Secure Shell connection
- "TLS" - Transport Layer Security connection
- "Unknown (N)" - Invalid connection type (N = actual numeric value)

---

#### `NAVSocketConnectionGetInfo`

Gets comprehensive information about a socket connection as a formatted string.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure

**Returns:** `char[]` - Formatted connection information string

**Example:**

```netlinx
stack_var char info[NAV_MAX_BUFFER]

info = NAVSocketConnectionGetInfo(socketConn)
// Returns: "Device Connection [TCP/UDP] 192.168.1.100:8080 - Connected"
```

**Format:** `Name [Type] address:port - Status`

**Notes:**

- Includes connection name, type, address, port, and current status
- Useful for logging and debugging
- Returns comprehensive information in a single formatted string

---

#### `NAVSocketConnectionIsRetrying`

Checks if a socket connection is currently in retry mode.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure

**Returns:** `char` - True if connection is retrying, false otherwise

**Example:**

```netlinx
if (NAVSocketConnectionIsRetrying(socketConn)) {
    // Show "connecting..." indicator
}
```

**Notes:**

- Returns true if AutoReconnect is enabled, not connected, and configured
- Returns false if connected or not configured for auto-reconnect

---

#### `NAVSocketConnectionIsConnected`

Checks if a socket connection is currently connected.

**Parameters:**

- `connection` (\_NAVSocketConnection): Socket connection structure

**Returns:** `char` - True if connected, false otherwise

**Example:**

```netlinx
if (NAVSocketConnectionIsConnected(socketConn)) {
    // Send data
}
```

**Notes:**

- Checks the IsConnected flag in the connection structure
- Updated automatically by NAVSocketConnectionHandleOnline/Offline

---

### Utility Functions

#### `NAVIsSocketDevice`

Checks if a device is a socket device (NUMBER = 0).

**Parameters:**

- `device` (dev): Device to check

**Returns:** `char` - True if device is a socket device, false otherwise

**Example:**

```netlinx
if (NAVIsSocketDevice(dvPort)) {
    // Device is a socket device
}
```

**Notes:**

- Socket devices always have NUMBER = 0
- Used internally for validation

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

## Data Structures

### `_NAVSocketConnectionOptions`

Configuration options for initializing a socket connection.

**Fields:**

- `Name` (char[]): Human-readable name for the connection
- `Device` (dev): Device to use for the connection
- `ConnectionType` (integer): Type of connection (TCP_UDP, SSH, or TLS)
- `Protocol` (integer): Protocol for TCP/UDP connections (IP_TCP, IP_UDP, IP_UDP_2WAY)
- `Port` (integer): Port number to connect to (1-65535)
- `TimelineId` (integer): Timeline ID for connection maintenance
- `TlsMode` (integer): TLS certificate validation mode (TLS_VALIDATE_CERTIFICATE or TLS_IGNORE_CERTIFICATE_ERRORS)
- `SshUsername` (char[]): Username for SSH authentication
- `SshPassword` (char[]): Password for SSH authentication
- `SshPrivateKey` (char[]): Path to SSH private key file
- `SshPrivateKeyPassphrase` (char[]): Passphrase for encrypted private key

**Example:**

```netlinx
stack_var _NAVSocketConnectionOptions options

options.Name = 'My Device'
options.Device = dvPort
options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
options.Protocol = IP_TCP
options.Port = 23
options.TimelineId = TL_MAINTAIN
```

---

### `_NAVSocketConnection`

Socket connection structure that maintains connection state and configuration.

**Fields:**

- `Name` (char[]): Connection name
- `Device` (dev): Device reference
- `Socket` (integer): Socket ID (device.PORT)
- `Address` (char[]): IP address or hostname
- `Port` (integer): Port number
- `ConnectionType` (integer): Connection type
- `Protocol` (integer): Protocol type
- `TlsMode` (integer): TLS mode
- `Credential` (\_NAVCredential): Username/password credentials
- `SshPrivateKey` (char[]): SSH private key path
- `SshPrivateKeyPassphrase` (char[]): Private key passphrase
- `IsConnected` (char): Connection status flag
- `IsNegotiated` (char): TLS/SSH negotiation status
- `IsAuthenticated` (char): Authentication status
- `IsInitialized` (char): Initialization status
- `AutoReconnect` (char): Auto-reconnect enabled flag
- `TimelineId` (integer): Timeline ID
- `RetryCount` (integer): Current retry attempt number
- `Interval[1]` (long): Connection interval array

**Notes:**

- Do not modify fields directly; use the provided setter functions
- Initialized by NAVSocketConnectionInit()
- State updated automatically by event handlers

---

## Constants

### Connection Types

| Constant                             | Value | Description                               |
| ------------------------------------ | ----- | ----------------------------------------- |
| `NAV_SOCKET_CONNECTION_TYPE_TCP_UDP` | 1     | Standard TCP or UDP connection            |
| `NAV_SOCKET_CONNECTION_TYPE_SSH`     | 2     | Secure Shell (SSH) connection             |
| `NAV_SOCKET_CONNECTION_TYPE_TLS`     | 3     | Transport Layer Security (TLS) connection |

**Example:**

```netlinx
options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_SSH
```

---

### Error Codes

| Constant                                        | Value | Description                                  |
| ----------------------------------------------- | ----- | -------------------------------------------- |
| `NAV_SOCKET_ERROR_INVALID_SERVER_PORT`          | -1    | Invalid server port specified                |
| `NAV_SOCKET_ERROR_INVALID_PROTOCOL_VALUE`       | -2    | Invalid protocol value specified             |
| `NAV_SOCKET_ERROR_UNABLE_TO_OPEN_PORT`          | -3    | Unable to open communication port            |
| `NAV_SOCKET_ERROR_INVALID_HOST_ADDRESS`         | -10   | Invalid host address provided                |
| `NAV_SOCKET_ERROR_INVALID_PORT`                 | -11   | Invalid port number specified                |
| `NAV_SOCKET_ERROR_GENERAL_FAILURE`              | 2     | General failure (usually out of memory)      |
| `NAV_SOCKET_ERROR_UNKNOWN_HOST`                 | 4     | Unknown host (DNS resolution failed)         |
| `NAV_SOCKET_ERROR_CONNECTION_REFUSED`           | 6     | Connection refused by remote host            |
| `NAV_SOCKET_ERROR_CONNECTION_TIMED_OUT`         | 7     | Connection attempt timed out                 |
| `NAV_SOCKET_ERROR_UNKNOWN_CONNECTION_ERROR`     | 8     | Unknown connection error                     |
| `NAV_SOCKET_ERROR_ALREADY_CLOSED`               | 9     | Socket is already closed                     |
| `NAV_SOCKET_ERROR_BINDING_ERROR`                | 10    | Unable to bind socket to address/port        |
| `NAV_SOCKET_ERROR_LISTENING_ERROR`              | 11    | Unable to start listening on socket          |
| `NAV_SOCKET_ERROR_LOCAL_PORT_ALREADY_USED`      | 14    | The specified local port is already in use   |
| `NAV_SOCKET_ERROR_UDP_SOCKET_ALREADY_LISTENING` | 15    | UDP socket is already listening              |
| `NAV_SOCKET_ERROR_TOO_MANY_OPEN_SOCKETS`        | 16    | Too many open sockets (system limit reached) |
| `NAV_SOCKET_ERROR_LOCAL_PORT_NOT_OPEN`          | 17    | The specified local port is not open         |

### Retry Configuration

| Constant                                    | Default Value | Description                                                          |
| ------------------------------------------- | ------------- | -------------------------------------------------------------------- |
| `NAV_MAX_SOCKET_CONNECTION_RETRIES`         | 10            | Maximum number of retry attempts before starting exponential backoff |
| `NAV_SOCKET_CONNECTION_INTERVAL_BASE_DELAY` | 5000 ms       | Base delay between socket connection retry attempts                  |
| `NAV_SOCKET_CONNECTION_INTERVAL_MAX_DELAY`  | 300000 ms     | Maximum delay between retry attempts (5 minutes)                     |

**Note:** These constants can be overridden by defining them before including the library:

```netlinx
#define NAV_MAX_SOCKET_CONNECTION_RETRIES 5
#define NAV_SOCKET_CONNECTION_INTERVAL_BASE_DELAY 3000
#define NAV_SOCKET_CONNECTION_INTERVAL_MAX_DELAY 60000

#include 'NAVFoundation.SocketUtils.axi'
```

---

## Complete Examples

### High-Level Connection Management Example

Here's a complete example using the high-level connection management API:

```netlinx
PROGRAM_NAME='SocketConnectionExample'

#include 'NAVFoundation.SocketUtils.axi'

DEFINE_CONSTANT

TL_SOCKET_MAINTAIN = 1

DEFINE_DEVICE

dvDevice = 0:3:0

DEFINE_TYPE

structure _Module {
    _NAVSocketConnection SocketConnection
}

DEFINE_VARIABLE

volatile _Module module

DEFINE_START

// Initialize the socket connection
{
    stack_var _NAVSocketConnectionOptions options

    options.Name = 'Device Connection'
    options.Device = dvDevice
    options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
    options.Protocol = IP_TCP
    options.Port = 23
    options.TimelineId = TL_SOCKET_MAINTAIN

    if (!NAVSocketConnectionInit(module.SocketConnection, options)) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Failed to initialize socket connection'")
        return
    }

    // Configure connection details
    if (!NAVSocketConnectionSetAddress(module.SocketConnection, '192.168.1.100')) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Failed to set address'")
        return
    }

    // Start the connection
    NAVSocketConnectionStart(module.SocketConnection)
}

DEFINE_EVENT

data_event[dvDevice] {
    online: {
        NAVSocketConnectionHandleOnline(module.SocketConnection, data)

        // Connection is now online and ready
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                   "'Connection online: ', NAVSocketConnectionGetInfo(module.SocketConnection)")
    }
    offline: {
        NAVSocketConnectionHandleOffline(module.SocketConnection, data)

        // Connection will automatically retry if AutoReconnect is enabled
        NAVErrorLog(NAV_LOG_LEVEL_WARNING,
                   "'Connection offline, status: ', NAVSocketConnectionGetStatus(module.SocketConnection)")
    }
    string: {
        // Handle incoming data
    }
}

timeline_event[TL_SOCKET_MAINTAIN] {
    // Maintain the connection (handles reconnection automatically)
    NAVSocketConnectionMaintain(module.SocketConnection)
}
```

### SSH Connection Example

Example using SSH with password authentication:

```netlinx
PROGRAM_NAME='SSHConnectionExample'

#include 'NAVFoundation.SocketUtils.axi'

DEFINE_CONSTANT

TL_SSH_MAINTAIN = 1

DEFINE_DEVICE

dvSSH = 0:4:0

DEFINE_VARIABLE

volatile _NAVSocketConnection sshConn

DEFINE_START

{
    stack_var _NAVSocketConnectionOptions options

    options.Name = 'SSH Device'
    options.Device = dvSSH
    options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_SSH
    options.Port = 22
    options.TimelineId = TL_SSH_MAINTAIN
    options.SshUsername = 'admin'
    options.SshPassword = 'password123'

    if (NAVSocketConnectionInit(sshConn, options)) {
        NAVSocketConnectionSetAddress(sshConn, 'device.local')
        NAVSocketConnectionStart(sshConn)
    }
}

DEFINE_EVENT

data_event[dvSSH] {
    online: {
        NAVSocketConnectionHandleOnline(sshConn, data)
    }
    offline: {
        NAVSocketConnectionHandleOffline(sshConn, data)
    }
}

timeline_event[TL_SSH_MAINTAIN] {
    NAVSocketConnectionMaintain(sshConn)
}
```

### TLS Connection Example

Example using TLS with certificate validation:

```netlinx
PROGRAM_NAME='TLSConnectionExample'

#include 'NAVFoundation.SocketUtils.axi'

DEFINE_CONSTANT

TL_TLS_MAINTAIN = 1

DEFINE_DEVICE

dvTLS = 0:5:0

DEFINE_VARIABLE

volatile _NAVSocketConnection tlsConn

DEFINE_START

{
    stack_var _NAVSocketConnectionOptions options

    options.Name = 'Secure API'
    options.Device = dvTLS
    options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TLS
    options.Port = 443
    options.TimelineId = TL_TLS_MAINTAIN
    options.TlsMode = TLS_VALIDATE_CERTIFICATE

    if (NAVSocketConnectionInit(tlsConn, options)) {
        NAVSocketConnectionSetAddress(tlsConn, 'api.example.com')
        NAVSocketConnectionStart(tlsConn)
    }
}

DEFINE_EVENT

data_event[dvTLS] {
    online: {
        NAVSocketConnectionHandleOnline(tlsConn, data)
    }
    offline: {
        NAVSocketConnectionHandleOffline(tlsConn, data)
    }
}

timeline_event[TL_TLS_MAINTAIN] {
    NAVSocketConnectionMaintain(tlsConn)
}
```

### Low-Level API Example

Here's a complete example demonstrating socket connection with automatic retry using the low-level API and exponential backoff:

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

1. **Use High-Level API**: For most applications, use the high-level connection management API (`NAVSocketConnectionInit`, `NAVSocketConnectionMaintain`, etc.) instead of the low-level socket functions. This provides automatic retry logic, exponential backoff, and simpler state management.

2. **Initialize Once**: Call `NAVSocketConnectionInit()` once during DEFINE_START. Reuse the same connection structure throughout your program.

3. **Handle Events Properly**: Always call `NAVSocketConnectionHandleOnline()` and `NAVSocketConnectionHandleOffline()` in your data_event handlers. These update internal state and trigger automatic reconnection.

4. **Use Timeline for Maintenance**: Create a dedicated timeline for `NAVSocketConnectionMaintain()`. This handles reconnection attempts automatically with exponential backoff.

5. **Check Configuration Status**: Use `NAVSocketConnectionIsConfigured()` before attempting to start a connection to ensure address and port are properly set.

6. **Reset After Changes**: Always call `NAVSocketConnectionReset()` after changing connection properties (address, port, credentials) to apply the changes and restart the connection.

7. **Monitor Connection Status**: Use `NAVSocketConnectionGetStatus()` and `NAVSocketConnectionGetInfo()` for debugging and user feedback about connection state.

8. **Always Check Return Values**: For setter functions that return boolean values, always check the return value and handle validation failures appropriately.

9. **Log Errors**: Use the error conversion functions (`NAVGetSocketError`) to provide meaningful error messages in your logs.

10. **Validate Input**: While the library validates addresses, ports, and credentials, ensure you provide valid values to avoid unnecessary error handling.

11. **Clean Up Connections**: Use `NAVSocketConnectionStop()` when you need to completely stop a connection and its timeline (e.g., during shutdown).

12. **Configure Retry Parameters**: Adjust the retry constants (`NAV_MAX_SOCKET_CONNECTION_RETRIES`, etc.) based on your application's requirements and network conditions.

13. **Handle SSH/TLS Properly**: For SSH connections, provide either password or private key. For TLS connections, choose the appropriate certificate validation mode for your environment.

14. **Use Descriptive Names**: Give connections meaningful names in the options struct to make logs and debugging easier.

---

## License

MIT License - Copyright (c) 2010-2026 Norgate AV
