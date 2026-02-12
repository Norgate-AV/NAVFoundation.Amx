# NAVFoundation.NetUtils

Network utility functions for parsing, validating, and manipulating IP addresses and network endpoints in NetLinx.

## Overview

NAVFoundation.NetUtils provides a comprehensive, RFC-compliant toolkit for working with IPv4 addresses, hostnames, and network endpoints. The library includes robust parsing, validation, and formatting functions designed with security and correctness in mind.

**Key Features:**

- ✅ RFC 791 compliant IPv4 parser
- ✅ RFC 952/1123 compliant hostname parser
- ✅ Host:port parsing and formatting
- ✅ Network endpoint structures
- ✅ Comprehensive validation and error handling
- ✅ Extensible design (IPv6-ready)
- ✅ Go's net package inspired API
- ✅ High-performance procedural parsing

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Data Structures](#data-structures)
    - [\_NAVIP](#_navip)
    - [\_NAVIPAddr](#_navipaddr)
    - [\_NAVHostname](#_navhostname)
- [Functions](#functions)
    - [NAVNetParseIPv4](#navnetparseipv4)
    - [NAVNetParseIP](#navnetparseip)
    - [NAVNetIPInit](#navnetipi init)
    - [NAVNetParseHostname](#navnetparsehostname)
    - [NAVNetHostnameInit](#navnethostnameinit)
    - [NAVNetIsMalformedIP](#navnetismalformedip)
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

// Parse and validate hostname
stack_var _NAVHostname host
if (NAVNetParseHostname('example.com', host)) {
    // host.Hostname = 'example.com'
    // host.LabelCount = 2
    // host.Labels[1] = 'example'
    // host.Labels[2] = 'com'
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

### \_NAVIP

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

### \_NAVIPAddr

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

### \_NAVHostname

Structure for holding parsed hostname components per RFC 952 and RFC 1123.

**Properties:**

- `char Hostname[253]` - Complete hostname string (max 253 chars per RFC 1123)
- `char Labels[127][64]` - Individual labels separated by dots
    - Each label max 63 characters
    - Max 127 labels (theoretical maximum for 253-char hostname)
- `integer LabelCount` - Number of labels in the hostname

**Example:**

```netlinx
stack_var _NAVHostname host
NAVNetHostnameInit(host)  // Initialize to clean state

if (NAVNetParseHostname('subdomain.example.com', host)) {
    send_string 0, "'Hostname: ', host.Hostname"           // subdomain.example.com
    send_string 0, "'Label Count: ', itoa(host.LabelCount)" // 3
    send_string 0, "'Label 1: ', host.Labels[1]"           // subdomain
    send_string 0, "'Label 2: ', host.Labels[2]"           // example
    send_string 0, "'Label 3: ', host.Labels[3]"           // com
}
```

**RFC 952/1123 Requirements:**

- Total length ≤ 253 characters
- Each label 1-63 characters
- Labels contain only letters (a-z, A-Z), digits (0-9), and hyphens (-)
- Labels must start and end with alphanumeric characters (not hyphen)
- No underscores allowed (unlike DNS TXT records)
- No leading or trailing dots or hyphens

**Note:** The `LabelCount` field allows efficient iteration and validation of multi-level domain names.

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

### NAVNetParseHostname

Parses and validates a hostname string according to RFC 952 and RFC 1123 standards.

**Signature:**

```netlinx
define_function char NAVNetParseHostname(char data[], _NAVHostname hostname)
```

**Parameters:**

- `data` - The hostname string to parse (e.g., "example.com", "subdomain.example.com")
- `hostname` - Structure to populate with parsed hostname components

**Returns:** `true` if parsing and validation succeeded, `false` otherwise

**RFC 952/1123 Requirements:**

- ✅ Total length ≤ 253 characters
- ✅ Labels separated by dots
- ✅ Each label 1-63 characters
- ✅ Labels contain only: letters (a-z, A-Z), digits (0-9), hyphens (-)
- ✅ Labels must start with alphanumeric character
- ✅ Labels must end with alphanumeric character
- ✅ No leading or trailing dots or hyphens
- ✅ No underscores (RFC compliance)

**Validation:**

- Rejects empty strings
- Rejects hostnames > 253 characters
- Rejects labels > 63 characters
- Rejects leading/trailing dots or hyphens
- Rejects consecutive dots (e.g., "host..name.com")
- Rejects underscores (not RFC compliant)
- Rejects special characters (@, #, $, %, etc.)
- Rejects whitespace within hostname (trimmed before parsing)

**Example:**

```netlinx
stack_var _NAVHostname host

// Valid hostnames
NAVNetParseHostname('example.com', host)              // ✓ Basic domain
NAVNetParseHostname('subdomain.example.com', host)    // ✓ Multi-level
NAVNetParseHostname('my-device.local', host)          // ✓ With hyphen
NAVNetParseHostname('localhost', host)                // ✓ Single label
NAVNetParseHostname('server1', host)                  // ✓ With digit
NAVNetParseHostname('123test.example.com', host)      // ✓ Label starting with digit
NAVNetParseHostname(' example.com ', host)            // ✓ Trimmed

// Invalid hostnames (return false)
NAVNetParseHostname('example_.com', host)             // ✗ Underscore (RFC violation)
NAVNetParseHostname('-example.com', host)             // ✗ Leading hyphen
NAVNetParseHostname('example.com-', host)             // ✗ Trailing hyphen
NAVNetParseHostname('.example.com', host)             // ✗ Leading dot
NAVNetParseHostname('example..com', host)             // ✗ Consecutive dots
NAVNetParseHostname('example.com.', host)             // ✗ Trailing dot
NAVNetParseHostname('exam ple.com', host)             // ✗ Space in hostname
NAVNetParseHostname('this-is-a-very-long-label-that-exceeds-sixty-three-characters-maximum.com', host) // ✗ Label > 63 chars
```

**Normalization:**
The function normalizes hostnames by:

- Trimming leading/trailing whitespace
- Splitting into individual labels
- Storing normalized form in `hostname.Hostname`
- Populating `hostname.Labels[]` array with individual components

**Use Cases:**

- Validating user-provided hostnames before DNS lookup
- Parsing configuration files with hostname values
- Ensuring RFC compliance in network applications
- Separating multi-level domain names into components
- Validating hostname format before connecting

**Performance Note:** Uses procedural parsing with O(n) linear time complexity, significantly faster than regex-based validation (~100ms vs 1-6 seconds for complex hostnames).

**Security Note:** Strictly rejects underscores, which are not RFC 952/1123 compliant. While some DNS implementations allow underscores in TXT records, they are not valid in hostnames and can cause compatibility issues.

### NAVNetHostnameInit

Initializes a hostname structure to a clean state.

**Signature:**

```netlinx
define_function NAVNetHostnameInit(_NAVHostname hostname)
```

**Parameters:**

- `hostname` - Structure to initialize

**Returns:** None

**Sets:**

- `Hostname` = empty string
- `Labels` = all empty strings
- `LabelCount` = 0

**Example:**

```netlinx
stack_var _NAVHostname host

// Initialize before reuse
NAVNetHostnameInit(host)

// Parse new hostname
NAVNetParseHostname('example.com', host)
```

**Note:** Automatically called by `NAVNetParseHostname()`, so manual initialization is typically unnecessary unless reusing structures or explicitly clearing state.

### NAVNetIsMalformedIP

Determines if a string appears to be a malformed IP address by checking if it contains only digits and dots.

**Signature:**

```netlinx
define_function char NAVNetIsMalformedIP(char address[])
```

**Parameters:**

- `address` - String to check

**Returns:** `true` if the string contains only digits and dots (indicating a malformed IP), `false` if it contains other characters (likely a valid hostname)

**Behavior:**

This function is designed to be used after `NAVNetParseIP()` or `NAVNetParseIPv4()` fails, to determine whether the failure was due to:

1. A malformed IP address (e.g., "256.1.1.1", "192.168.1") - should be rejected
2. A valid hostname that happens to start with digits - should be passed to `NAVNetParseHostname()`

The function performs a simple character-by-character check:

- Returns `true` if the string contains ONLY digits (0-9) and dots (.)
- Returns `false` if it contains any other characters (letters, hyphens, etc.)
- Returns `false` for empty strings

**Example:**

```netlinx
stack_var _NAVIP ip
stack_var _NAVHostname host
stack_var char address[255]

address = '256.1.1.1'  // Invalid IP - octet out of range

// Try to parse as IP address
if (!NAVNetParseIP(address, ip)) {
    // Parsing failed - determine why
    if (NAVNetIsMalformedIP(address)) {
        // Contains only digits and dots, but invalid format
        send_string 0, "'ERROR: Malformed IP address: ', address"
        return  // Reject this input
    } else {
        // Contains other characters, might be a valid hostname
        if (NAVNetParseHostname(address, host)) {
            send_string 0, "'Valid hostname: ', host.Hostname"
            // Proceed with DNS lookup
        }
    }
}
```

**Common Use Cases:**

```netlinx
// Example 1: Malformed IPs (returns true)
NAVNetIsMalformedIP('256.1.1.1')      // true - octet out of range
NAVNetIsMalformedIP('192.168.1')      // true - too few octets
NAVNetIsMalformedIP('192.168..1')     // true - empty octet
NAVNetIsMalformedIP('999.999.999.999') // true - all octets invalid
NAVNetIsMalformedIP('192.168.1.1.1')  // true - too many octets

// Example 2: Valid hostnames (returns false)
NAVNetIsMalformedIP('example.com')    // false - contains letters
NAVNetIsMalformedIP('server-1')       // false - contains hyphen
NAVNetIsMalformedIP('192abc')         // false - contains letters
NAVNetIsMalformedIP('my-server.local') // false - valid hostname format

// Example 3: Edge cases
NAVNetIsMalformedIP('')               // false - empty string
NAVNetIsMalformedIP('192.168.1.1:8080') // false - contains colon
```

**Typical Usage Pattern:**

```netlinx
define_function char ParseAddressOrHostname(char input[], _NAVIP ip, _NAVHostname host) {
    stack_var char trimmed[255]

    trimmed = NAVTrimString(input)

    // Step 1: Try to parse as IP address
    if (NAVNetParseIP(trimmed, ip)) {
        send_string 0, "'Parsed as IP: ', ip.Address"
        return true
    }

    // Step 2: IP parsing failed - determine why
    if (NAVNetIsMalformedIP(trimmed)) {
        // String looks like an IP but is invalid (e.g., "256.1.1.1")
        send_string 0, "'ERROR: Malformed IP address: ', trimmed"
        return false  // Reject - this is definitely invalid
    }

    // Step 3: Not a malformed IP, try parsing as hostname
    if (NAVNetParseHostname(trimmed, host)) {
        send_string 0, "'Parsed as hostname: ', host.Hostname"
        return true
    }

    // Step 4: Neither valid IP nor valid hostname
    send_string 0, "'ERROR: Invalid address or hostname: ', trimmed"
    return false
}
```

**Use Cases:**

- Distinguishing between malformed IPs and valid hostnames during address validation
- Preventing "192.168.1.256" from being treated as a hostname
- Providing better error messages to users ("invalid IP" vs "invalid hostname")
- Security: Rejecting obviously malformed input before expensive DNS lookups
- Input validation in configuration parsers

**Performance:** O(n) linear time complexity - simple character iteration, extremely fast.

**Note:** This function does NOT validate IP address structure (octet count, ranges, etc.). It only checks character composition. Always use `NAVNetParseIP()` first for actual IP validation.

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

### Hostname Validation and Parsing

```netlinx
define_function char ValidateHostname(char userInput[]) {
    stack_var _NAVHostname host
    stack_var integer i

    if (!NAVNetParseHostname(userInput, host)) {
        send_string 0, "'ERROR: Invalid hostname: ', userInput"
        return false
    }

    send_string 0, "'Valid hostname: ', host.Hostname"
    send_string 0, "'Label count: ', itoa(host.LabelCount)"

    // Display each label
    for (i = 1; i <= host.LabelCount; i++) {
        send_string 0, "'  Label ', itoa(i), ': ', host.Labels[i]"
    }

    // Check if it's a fully qualified domain name (FQDN)
    if (host.LabelCount >= 2) {
        send_string 0, "'Domain: ', host.Labels[host.LabelCount]"
        send_string 0, "'Subdomain: ', host.Labels[1]"
    }

    return true
}

define_function char IsLocalDomain(_NAVHostname host) {
    // Check if hostname ends with .local
    if (host.LabelCount > 0) {
        return (lower_string(host.Labels[host.LabelCount]) == 'local')
    }
    return false
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

- **215 total tests** across 5 test suites
- **100% passing** (70 + 31 + 29 + 15 + 70)

**Test Suites:**

1. `NAVNetParseIPv4`: 70 tests (18 valid, 52 invalid)
2. `NAVNetSplitHostPort`: 31 tests (14 valid, 17 invalid)
3. `NAVNetParseIPAddr`: 29 tests (13 valid, 16 invalid)
4. `NAVNetJoinHostPort`: 15 tests (10 valid, 5 invalid)
5. `NAVNetParseHostname`: 70 tests (20 valid, 50 invalid)

**Coverage Includes:**

- Valid addresses (min, max, common ranges)
- Invalid formats (wrong octets, overflow, underflow)
- Edge cases (empty, whitespace, special characters)
- Boundary conditions (0, 255, 65535)
- Security validations (leading zeros, octal confusion)
- Port overflow (using SLONG for detection)
- Hostname RFC compliance (underscores, hyphens, length limits)
- Label validation (start/end with alphanumeric, 63 char max)

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

### RFC 952 - DOD Internet Host Table Specification

Full compliance with hostname requirements:

- ✅ Labels contain only letters, digits, and hyphens
- ✅ Labels start and end with alphanumeric characters
- ✅ No underscores in hostnames

### RFC 1123 - Requirements for Internet Hosts

Full compliance with hostname updates:

- ✅ Total hostname length ≤ 253 characters
- ✅ Each label 1-63 characters
- ✅ Labels may start with digits (updated from RFC 952)
- ✅ Case-insensitive comparison

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

| Function              | Purpose                       | Returns   |
| --------------------- | ----------------------------- | --------- |
| `NAVNetParseIPv4`     | Parse IPv4 address            | `boolean` |
| `NAVNetParseIP`       | Parse IP (v4/v6)              | `boolean` |
| `NAVNetIPInit`        | Initialize IP structure       | `void`    |
| `NAVNetParseHostname` | Parse and validate hostname   | `boolean` |
| `NAVNetHostnameInit`  | Initialize hostname structure | `void`    |
| `NAVNetSplitHostPort` | Split host:port string        | `boolean` |
| `NAVNetParseIPAddr`   | Parse IP:port with validation | `boolean` |
| `NAVNetJoinHostPort`  | Join host+port to string      | `string`  |

| Structure      | Purpose                     | Size         |
| -------------- | --------------------------- | ------------ |
| `_NAVIP`       | IP address (v4/v6)          | 62 bytes     |
| `_NAVIPAddr`   | IP + Port endpoint          | 64 bytes     |
| `_NAVHostname` | Parsed hostname with labels | ~8,383 bytes |

## License

MIT License - Copyright (c) 2010-2026 Norgate AV

## Support

For issues, questions, or contributions, please refer to the main NAVFoundation repository.
