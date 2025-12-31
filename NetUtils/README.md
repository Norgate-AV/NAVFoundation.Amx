# NAVFoundation.NetUtils

Network utility functions for parsing, validating, and manipulating IP addresses and network endpoints in NetLinx.

## Overview

NAVFoundation.NetUtils provides a comprehensive, RFC-compliant toolkit for working with IPv4 addresses and network endpoints. The library includes robust parsing, validation, and formatting functions designed with security and correctness in mind.

**Key Features:**
- ✅ RFC 791 compliant IPv4 parser
- ✅ Host:port parsing and formatting
- ✅ Network endpoint structures
- ✅ Comprehensive validation and error handling
- ✅ Extensible design (IPv6-ready)
- ✅ Go's net package inspired API

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Data Structures](#data-structures)
  - [_NAVIP](#_navip)
  - [_NAVIPAddr](#_navipaddr)
- [Functions](#functions)
  - [NAVNetParseIPv4](#navnetparseipv4)
  - [NAVNetParseIP](#navnetparseip)
  - [NAVNetIPInit](#navnetipi init)
  - [NAVNetSplitHostPort](#navnetsplithostport)
  - [NAVNetParseIPAddr](#navnetparseipaddr)
  - [NAVNetJoinHostPort](#navnetjoinhostport)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)
- [Testing](#testing)
- [Standards Compliance](#standards-compliance)

## Installation

```netlinx
#include 'NAVFoundation.NetUtils.axi'
```

**Dependencies:**
- NAVFoundation.StringUtils
- NAVFoundation.ErrorLogUtils
- NAVFoundation.Core

## Quick Start

```netlinx
// Parse an IPv4 address
stack_var _NAVIP ip
if (NAVNetParseIPv4('192.168.1.1', ip)) {
    // ip.Version = 4
    // ip.Octets[1..4] = {192, 168, 1, 1}
    // ip.Address = '192.168.1.1'
}

// Parse IP address with port
stack_var _NAVIPAddr addr
if (NAVNetParseIPAddr('192.168.1.1:8080', addr)) {
    // addr.IP.Address = '192.168.1.1'
    // addr.Port = 8080
}

// Split host and port
stack_var char host[255]
stack_var integer port
if (NAVNetSplitHostPort('example.com:443', host, port)) {
    // host = 'example.com'
    // port = 443
}

// Join host and port
stack_var char endpoint[NAV_MAX_BUFFER]
endpoint = NAVNetJoinHostPort('192.168.1.1', 8080)
// endpoint = '192.168.1.1:8080'
```

## Data Structures

### _NAVIP

Structure for holding parsed IP address components (IPv4 or IPv6).

**Properties:**
- `char Version` - IP version: 4 = IPv4, 6 = IPv6, 0 = uninitialized
- `char Octets[16]` - Array of bytes representing the IP address
  - First 4 bytes used for IPv4
  - All 16 bytes used for IPv6
- `char Address[45]` - String representation of the IP address
  - Max 15 chars for IPv4 ("255.255.255.255")
  - Max 45 chars for IPv6 (future)

**Example:**
```netlinx
stack_var _NAVIP ip
NAVNetIPInit(ip)  // Initialize to clean state

if (NAVNetParseIPv4('10.0.0.1', ip)) {
    send_string 0, "'IP Version: ', itoa(ip.Version)"     // 4
    send_string 0, "'First Octet: ', itoa(ip.Octets[1])" // 10
    send_string 0, "'Address: ', ip.Address"              // 10.0.0.1
}
```

**Note:** The `Octets` array length is set via `set_length_array()` to 4 for IPv4, allowing code to use `length_array()` for version-agnostic iteration.

### _NAVIPAddr

Structure for holding an IP address with port number (network endpoint).

**Properties:**
- `_NAVIP IP` - The IP address (IPv4 or IPv6)
- `integer Port` - Port number (0-65535, 0 = not specified)

**Example:**
```netlinx
stack_var _NAVIPAddr addr

// Parse complete endpoint
if (NAVNetParseIPAddr('192.168.1.1:8080', addr)) {
    send_string 0, "'Connect to ', addr.IP.Address, ':', itoa(addr.Port)"
}

// Build endpoint programmatically
NAVNetParseIPv4('127.0.0.1', addr.IP)
addr.Port = 3000
send_string 0, NAVNetJoinHostPort(addr.IP.Address, addr.Port)
```

## Functions

### NAVNetParseIPv4

Parses an IPv4 address string into its component parts with full RFC 791 compliance.

**Signature:**
```netlinx
define_function char NAVNetParseIPv4(char data[], _NAVIP ip)
```

**Parameters:**
- `data` - The IPv4 address string to parse
- `ip` - Structure to populate with parsed address components

**Returns:** `true` if parsing succeeded, `false` otherwise

**RFC 791 Requirements:**
- ✅ Dotted-decimal notation (e.g., "192.168.1.1")
- ✅ Exactly 4 octets separated by dots
- ✅ Each octet 0-255 decimal
- ✅ No leading zeros (security best practice)
- ✅ No whitespace within address (trimmed before parsing)

**Validation:**
- Rejects empty strings
- Rejects wrong number of octets (< 4 or > 4)
- Rejects empty octets (e.g., "192..1.1")
- Rejects non-numeric characters
- Rejects octets > 255
- Rejects leading zeros (e.g., "192.168.01.1")
- Rejects whitespace within octets

**Example:**
```netlinx
stack_var _NAVIP ip

// Valid addresses
NAVNetParseIPv4('0.0.0.0', ip)           // ✓ Minimum
NAVNetParseIPv4('255.255.255.255', ip)   // ✓ Maximum
NAVNetParseIPv4('192.168.1.1', ip)       // ✓ Common
NAVNetParseIPv4(' 10.0.0.1 ', ip)        // ✓ Trimmed

// Invalid addresses (return false)
NAVNetParseIPv4('256.1.1.1', ip)         // ✗ Octet > 255
NAVNetParseIPv4('192.168.1', ip)         // ✗ Too few octets
NAVNetParseIPv4('192.168.01.1', ip)      // ✗ Leading zero
NAVNetParseIPv4('192.168.1.1.1', ip)     // ✗ Too many octets
```

**Normalization:**
The function normalizes addresses by:
- Trimming leading/trailing whitespace
- Removing leading zeros from octets (e.g., "01" → "1")
- Storing normalized form in `ip.Address`

**Security Note:** Leading zeros are rejected per RFC 791 and security best practices, as they can be confused with octal notation in some contexts.

### NAVNetParseIP

Convenience wrapper for IP address parsing with automatic version detection (future).

**Signature:**
```netlinx
define_function char NAVNetParseIP(char data[], _NAVIP ip)
```

**Parameters:**
- `data` - The IP address string to parse (IPv4 or IPv6)
- `ip` - Structure to populate with parsed address components

**Returns:** `true` if parsing succeeded, `false` otherwise

**Current Behavior:** Delegates to `NAVNetParseIPv4()` for IPv4 addresses.

**Future:** Will automatically detect and parse IPv6 addresses (RFC 4291).

**Example:**
```netlinx
stack_var _NAVIP ip

// IPv4
if (NAVNetParseIP('192.168.1.1', ip)) {
    // ip.Version = 4
}

// Future IPv6 support
// if (NAVNetParseIP('2001:db8::1', ip)) {
//     // ip.Version = 6
// }
```

### NAVNetIPInit

Initializes an IP structure to a clean state.

**Signature:**
```netlinx
define_function NAVNetIPInit(_NAVIP ip)
```

**Parameters:**
- `ip` - Structure to initialize

**Returns:** None

**Sets:**
- `Version` = 0 (uninitialized)
- `Octets` = all zeros
- `Address` = empty string

**Example:**
```netlinx
stack_var _NAVIP ip

// Initialize before reuse
NAVNetIPInit(ip)

// Parse new address
NAVNetParseIPv4('10.0.0.1', ip)
```

**Note:** Automatically called by `NAVNetParseIPv4()`, so manual initialization is typically unnecessary unless reusing structures.

### NAVNetSplitHostPort

Splits a host:port string into separate host and port components.

**Signature:**
```netlinx
define_function char NAVNetSplitHostPort(char hostport[], char host[], integer port)
```

**Parameters:**
- `hostport` - The host:port string to split
- `host` - Output: the host portion (IP address or hostname)
- `port` - Output: the port number (0-65535, 0 if not specified)

**Returns:** `true` if parsing succeeded, `false` if invalid format

**Behavior:**
- Splits on last colon (future IPv6 bracket support)
- Handles missing port (port = 0)
- Validates port is all digits
- Validates port range 0-65535
- Trims whitespace from input
- Detects multiple colons (invalid)

**Example:**
```netlinx
stack_var char host[255]
stack_var integer port

// With port
NAVNetSplitHostPort('192.168.1.1:8080', host, port)
// host = '192.168.1.1', port = 8080

NAVNetSplitHostPort('example.com:443', host, port)
// host = 'example.com', port = 443

// Without port
NAVNetSplitHostPort('192.168.1.1', host, port)
// host = '192.168.1.1', port = 0

// Invalid formats
NAVNetSplitHostPort(':8080', host, port)           // ✗ No host
NAVNetSplitHostPort('192.168.1.1:', host, port)    // ✗ No port
NAVNetSplitHostPort('192.168.1.1:abc', host, port) // ✗ Non-numeric
```

**Port Validation:**
- Must be all digits
- Must be in range 0-65535
- Uses SLONG internally to detect overflow before type_cast
- Port 0 means "not specified" (valid for some protocols)

### NAVNetParseIPAddr

Parses a host:port string into an IP address and port structure with full validation.

**Signature:**
```netlinx
define_function char NAVNetParseIPAddr(char ipport[], _NAVIPAddr addr)
```

**Parameters:**
- `ipport` - The IP:port string to parse (e.g., "192.168.1.1:8080")
- `addr` - Structure to populate with parsed IP and port

**Returns:** `true` if parsing succeeded, `false` if invalid format or IP

**Validation:**
- Calls `NAVNetSplitHostPort()` for string splitting
- Calls `NAVNetParseIPv4()` for IP validation
- Both host AND port must be valid

**Example:**
```netlinx
stack_var _NAVIPAddr addr

// Parse complete endpoint
if (NAVNetParseIPAddr('192.168.1.1:8080', addr)) {
    send_string 0, "'Connecting to ', addr.IP.Address, ':', itoa(addr.Port)"
    // addr.IP.Version = 4
    // addr.IP.Octets[1..4] = {192, 168, 1, 1}
    // addr.IP.Address = '192.168.1.1'
    // addr.Port = 8080
}

// Without port (port = 0)
if (NAVNetParseIPAddr('127.0.0.1', addr)) {
    // addr.Port = 0 (not specified)
}

// Invalid combinations
NAVNetParseIPAddr('256.1.1.1:8080', addr)    // ✗ Invalid IP
NAVNetParseIPAddr('192.168.1.1:70000', addr) // ✗ Port out of range
NAVNetParseIPAddr('hostname:8080', addr)     // ✗ Not an IP address
```

**Note:** Only accepts literal IP addresses, not hostnames requiring DNS resolution (similar to Go's `net.ParseIP` vs `net.ResolveTCPAddr`).

### NAVNetJoinHostPort

Joins a host and port into a host:port string.

**Signature:**
```netlinx
define_function char[NAV_MAX_BUFFER] NAVNetJoinHostPort(char host[], integer port)
```

**Parameters:**
- `host` - The host (IP address or hostname)
- `port` - The port number (0-65535)

**Returns:** The formatted "host:port" string, or empty string if invalid

**Validation:**
- Trims whitespace from host
- Validates host is not empty
- Validates port range 0-65535

**Example:**
```netlinx
stack_var char endpoint[NAV_MAX_BUFFER]

// IP address with port
endpoint = NAVNetJoinHostPort('192.168.1.1', 8080)
// endpoint = '192.168.1.1:8080'

// Hostname with port
endpoint = NAVNetJoinHostPort('example.com', 443)
// endpoint = 'example.com:443'

// Port 0
endpoint = NAVNetJoinHostPort('localhost', 0)
// endpoint = 'localhost:0'

// Invalid inputs return empty string
endpoint = NAVNetJoinHostPort('', 8080)     // ✗ Empty host
endpoint = NAVNetJoinHostPort('host', -1)   // ✗ Negative port
endpoint = NAVNetJoinHostPort('host', 70000) // ✗ Port out of range
```

**Use Cases:**
- Building configuration strings
- Formatting log messages
- Generating connection strings
- Reverse operation of `NAVNetSplitHostPort`

## Usage Examples

### Basic IP Parsing

```netlinx
define_function ConnectToServer(char ipAddress[]) {
    stack_var _NAVIP ip
    
    if (!NAVNetParseIPv4(ipAddress, ip)) {
        send_string 0, "'ERROR: Invalid IP address: ', ipAddress"
        return
    }
    
    send_string 0, "'Connecting to ', ip.Address, '...'"
    send_string 0, "'  Octet 1: ', itoa(ip.Octets[1])"
    send_string 0, "'  Octet 2: ', itoa(ip.Octets[2])"
    send_string 0, "'  Octet 3: ', itoa(ip.Octets[3])"
    send_string 0, "'  Octet 4: ', itoa(ip.Octets[4])"
    
    // Use validated IP for connection
    ip_client_open(dvDevice.port, ip.Address, 8080, IP_TCP)
}
```

### Endpoint Parsing

```netlinx
define_function ConfigureEndpoint(char endpoint[]) {
    stack_var _NAVIPAddr addr
    
    if (!NAVNetParseIPAddr(endpoint, addr)) {
        send_string 0, "'ERROR: Invalid endpoint: ', endpoint"
        return
    }
    
    if (addr.Port == 0) {
        send_string 0, "'WARNING: No port specified, using default 8080'"
        addr.Port = 8080
    }
    
    send_string 0, "'Server: ', addr.IP.Address"
    send_string 0, "'Port: ', itoa(addr.Port)"
    
    // Use validated endpoint
    ip_client_open(dvDevice.port, addr.IP.Address, addr.Port, IP_TCP)
}
```

### Host:Port Manipulation

```netlinx
define_function char[NAV_MAX_BUFFER] BuildConnectionString(char host[], integer defaultPort) {
    stack_var char parsedHost[255]
    stack_var integer parsedPort
    
    // Try to parse existing host:port
    if (NAVNetSplitHostPort(host, parsedHost, parsedPort)) {
        // Use parsed port if specified, otherwise default
        if (parsedPort == 0) {
            parsedPort = defaultPort
        }
        return NAVNetJoinHostPort(parsedHost, parsedPort)
    }
    
    // Invalid format, return empty
    return ''
}
```

### Network Range Checking

```netlinx
define_function char IsPrivateNetwork(_NAVIP ip) {
    // Check if IP is in private ranges (RFC 1918)
    
    if (ip.Version != 4) {
        return false
    }
    
    // 10.0.0.0/8
    if (ip.Octets[1] == 10) {
        return true
    }
    
    // 172.16.0.0/12
    if (ip.Octets[1] == 172 && ip.Octets[2] >= 16 && ip.Octets[2] <= 31) {
        return true
    }
    
    // 192.168.0.0/16
    if (ip.Octets[1] == 192 && ip.Octets[2] == 168) {
        return true
    }
    
    return false
}
```

### Configuration File Parsing

```netlinx
define_function ParseServerConfig(char configLine[]) {
    stack_var char parts[10][255]
    stack_var integer count
    stack_var _NAVIPAddr server
    
    // Config format: "SERVER=192.168.1.1:8080"
    count = NAVSplitString(configLine, '=', parts)
    
    if (count != 2 || parts[1] != 'SERVER') {
        return
    }
    
    if (NAVNetParseIPAddr(parts[2], server)) {
        send_string 0, "'Server configured: ', server.IP.Address, ':', itoa(server.Port)"
        // Store configuration
        gServerIP = server.IP.Address
        gServerPort = server.Port
    }
    else {
        send_string 0, "'ERROR: Invalid server configuration: ', parts[2]"
    }
}
```

## Error Handling

All parsing functions return boolean success/failure and log detailed errors to the system log.

**Error Logging:**
```netlinx
// Example error messages:
// ERROR:: NAVFoundation.NetUtils.NAVNetParseIPv4() => Invalid argument. The provided IPv4 address string is empty
// ERROR:: NAVFoundation.NetUtils.NAVNetParseIPv4() => Octet 1 value 256 is out of range (0-255)
// ERROR:: NAVFoundation.NetUtils.NAVNetParseIPv4() => Invalid IPv4 format. Expected 4 octets but found 3
// ERROR:: NAVFoundation.NetUtils.NAVNetSplitHostPort() => Port value 65536 is out of range (0-65535)
```

**Error Handling Pattern:**
```netlinx
stack_var _NAVIP ip

if (!NAVNetParseIPv4(userInput, ip)) {
    // Check logs for specific error
    // ERROR is already logged, just handle the failure
    send_string 0, "'Please enter a valid IPv4 address'"
    return
}

// Success - use ip structure
```

## Best Practices

### Input Validation

Always validate user input:
```netlinx
define_function ConfigureIP(char userInput[]) {
    stack_var _NAVIP ip
    
    // Validate before use
    if (!NAVNetParseIPv4(userInput, ip)) {
        send_string dvPanel, "'Invalid IP address'"
        return
    }
    
    // Safe to use
    gDeviceIP = ip.Address
}
```

### Structure Reuse

Initialize structures when reusing:
```netlinx
stack_var _NAVIP ip

for (i = 1; i <= MAX_DEVICES; i++) {
    NAVNetIPInit(ip)  // Clean state for each iteration
    if (NAVNetParseIPv4(deviceIPs[i], ip)) {
        // Process device
    }
}
```

### Port Handling

Check for unspecified ports:
```netlinx
stack_var _NAVIPAddr addr

if (NAVNetParseIPAddr(endpoint, addr)) {
    if (addr.Port == 0) {
        // Use default port
        addr.Port = DEFAULT_PORT
    }
    // Connect using addr.IP.Address and addr.Port
}
```

### String Building

Use `NAVNetJoinHostPort` for consistent formatting:
```netlinx
// Good
stack_var char connectionString[NAV_MAX_BUFFER]
connectionString = NAVNetJoinHostPort(ip.Address, port)

// Avoid manual concatenation (error-prone)
connectionString = "ip.Address, ':', itoa(port)"  // No validation!
```

## Testing

The library includes comprehensive test coverage:

**Test Statistics:**
- **145 total tests** across 4 test suites
- **100% passing** (70 + 31 + 29 + 15)

**Test Suites:**
1. `NAVNetParseIPv4`: 70 tests (18 valid, 52 invalid)
2. `NAVNetSplitHostPort`: 31 tests (14 valid, 17 invalid)
3. `NAVNetParseIPAddr`: 29 tests (13 valid, 16 invalid)
4. `NAVNetJoinHostPort`: 15 tests (10 valid, 5 invalid)

**Coverage Includes:**
- Valid addresses (min, max, common ranges)
- Invalid formats (wrong octets, overflow, underflow)
- Edge cases (empty, whitespace, special characters)
- Boundary conditions (0, 255, 65535)
- Security validations (leading zeros, octal confusion)
- Port overflow (using SLONG for detection)

**Run Tests:**
```powershell
.\Invoke-Test.ps1
```

## Standards Compliance

### RFC 791 - Internet Protocol (IPv4)

Full compliance with IPv4 address format specification:
- ✅ Dotted-decimal notation
- ✅ 4 octets, each 0-255
- ✅ No leading zeros (per security best practices)
- ✅ Octet validation and range checking

### Security Best Practices

- **Leading Zero Rejection**: Prevents octal interpretation confusion
- **Strict Validation**: All octets must be valid decimal
- **Range Checking**: Port overflow detection using SLONG
- **Input Sanitization**: Whitespace trimming, empty string rejection

### Go's net Package Inspiration

API design follows Go's battle-tested patterns:
- `NAVNetParseIP` ≈ `net.ParseIP`
- `NAVNetSplitHostPort` ≈ `net.SplitHostPort`
- `NAVNetJoinHostPort` ≈ `net.JoinHostPort`
- `_NAVIPAddr` ≈ `net.TCPAddr` / `net.UDPAddr`

### Future Standards

**Designed for extensibility:**
- `_NAVIP` structure supports IPv6 (16 bytes, 45 char string)
- `NAVNetParseIP` wrapper ready for IPv6 detection
- `Version` field enables protocol-agnostic code
- `set_length_array()` enables dynamic octet iteration

## API Reference

| Function | Purpose | Returns |
|----------|---------|---------|
| `NAVNetParseIPv4` | Parse IPv4 address | `boolean` |
| `NAVNetParseIP` | Parse IP (v4/v6) | `boolean` |
| `NAVNetIPInit` | Initialize IP structure | `void` |
| `NAVNetSplitHostPort` | Split host:port string | `boolean` |
| `NAVNetParseIPAddr` | Parse IP:port with validation | `boolean` |
| `NAVNetJoinHostPort` | Join host+port to string | `string` |

| Structure | Purpose | Size |
|-----------|---------|------|
| `_NAVIP` | IP address (v4/v6) | 62 bytes |
| `_NAVIPAddr` | IP + Port endpoint | 64 bytes |

## License

MIT License - Copyright (c) 2010-2026 Norgate AV

## Support

For issues, questions, or contributions, please refer to the main NAVFoundation repository.
