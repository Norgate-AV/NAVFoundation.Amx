# NAVFoundation.Encoding

The Encoding library for NAVFoundation provides comprehensive byte order conversion, byte array manipulation, and hexadecimal formatting utilities for NetLinx programming. It enables efficient data transformation between different endianness formats and provides flexible hexadecimal string representations for debugging and data interchange.

## Overview

Data encoding and byte manipulation are fundamental operations in control systems, particularly when interfacing with network protocols, binary data formats, and external devices. This library provides a complete suite of functions for converting between host and network byte orders, transforming integers and longs into byte arrays, and formatting binary data as hexadecimal strings.

## Features

- **Byte Order Conversion**: Network/host byte order conversion for 16-bit and 32-bit values
- **Endianness Support**: Explicit little-endian and big-endian conversion functions
- **Byte Array Operations**: Convert integers and longs to byte arrays in both endianness formats
- **Hexadecimal Formatting**: Multiple hex string formats (plain, NetLinx-style, C-style, custom)
- **Flexible Output**: Customizable prefix and separator options for hex string generation
- **Type Safety**: Proper type casting and bounds checking
- **Memory Efficient**: Optimized for NetLinx's memory constraints

## Quick Start

### Byte Order Conversion

```netlinx
#include 'NAVFoundation.Encoding.axi'

DEFINE_START
stack_var long networkValue
stack_var long hostValue

// Convert from network byte order (big-endian) to host byte order
networkValue = $01020304
hostValue = NAVNetworkToHostLong(networkValue)  // $04030201 on little-endian systems

// Convert from host byte order to network byte order (big-endian)
hostValue = $0102
networkValue = NAVHostToNetworkShort(hostValue)  // $0201 on little-endian systems
```

### Byte Array Conversion

```netlinx
#include 'NAVFoundation.Encoding.axi'

DEFINE_START
stack_var long value
stack_var char bytes[4]

// Convert 32-bit long to byte array (little-endian)
value = $12345678
bytes = NAVLongToByteArrayLE(value)  // {$78, $56, $34, $12}

// Convert 32-bit long to byte array (big-endian)
bytes = NAVLongToByteArrayBE(value)  // {$12, $34, $56, $78}
```

### Hexadecimal String Formatting

```netlinx
#include 'NAVFoundation.Encoding.axi'

DEFINE_START
stack_var char bytes[3]
stack_var char hexString[NAV_MAX_BUFFER]

bytes = "$01, $AB, $FF"

// Plain hex string
hexString = NAVByteArrayToHexString(bytes)  // "01abff"

// NetLinx-style hex string
hexString = NAVByteArrayToNetLinxHexString(bytes)  // "$01$AB$FF"

// C-style hex string
hexString = NAVByteArrayToCStyleHexString(bytes)  // "0X01, 0XAB, 0XFF"

// Custom format
hexString = NAVByteArrayToHexStringWithOptions(bytes, '#', ':')  // "#01:#ab:#ff"
```

## Performance Characteristics

### Memory Usage

| Operation Type | Input Size | Output Size | Notes |
|---------------|------------|-------------|-------|
| Byte Order Conversion | 2-4 bytes | 2-4 bytes | In-place conversion |
| Integer to Byte Array | 2 bytes | 2 bytes | Fixed size output |
| Long to Byte Array | 4 bytes | 4 bytes | Fixed size output |
| Hex String (plain) | N bytes | 2N chars | 2 hex chars per byte |
| Hex String (NetLinx) | N bytes | 3N chars | "$XX" per byte |
| Hex String (C-style) | N bytes | 6N-2 chars | "0xXX, " per byte |

### Time Complexity

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Byte Order Conversion | O(1) | Fixed number of bit operations |
| Byte Array Conversion | O(1) | Fixed size arrays (2 or 4 bytes) |
| Hex String Formatting | O(n) | Linear with number of bytes |
| CharToLong Conversion | O(n) | Linear with number of bytes |

## API Reference

### Byte Order Conversion Functions

#### `NAVNetworkToHostLong`
**Purpose**: Convert a 32-bit value from network byte order (big-endian) to host byte order.

**Signature**: `long NAVNetworkToHostLong(long value)`

**Parameters**:
- `value` - Value in network byte order

**Returns**: Value in host byte order

**Example**:
```netlinx
stack_var long networkValue
stack_var long hostValue

networkValue = $01020304  // Bytes in network order
hostValue = NAVNetworkToHostLong(networkValue)  // $04030201 on little-endian systems
```

**Note**: On little-endian systems (like x86), this reverses byte order.

---

#### `NAVHostToNetworkShort`
**Purpose**: Convert a 16-bit value from host byte order to network byte order (big-endian).

**Signature**: `long NAVHostToNetworkShort(long value)`

**Parameters**:
- `value` - Value in host byte order

**Returns**: Value in network byte order

**Example**:
```netlinx
stack_var long hostValue
stack_var long networkValue

hostValue = $0102  // Bytes in host order
networkValue = NAVHostToNetworkShort(hostValue)  // $0201 on little-endian systems
```

**Note**: On little-endian systems (like x86), this reverses byte order.

---

#### `NAVToLittleEndian`
**Purpose**: Convert a 32-bit value to little-endian byte order.

**Signature**: `long NAVToLittleEndian(long value)`

**Parameters**:
- `value` - Value to convert

**Returns**: Value in little-endian byte order

**Example**:
```netlinx
stack_var long bigEndian
stack_var long littleEndian

bigEndian = $01020304  // Bytes in big-endian order
littleEndian = NAVToLittleEndian(bigEndian)  // $04030201
```

**Note**: This is an alias for `NAVNetworkToHostLong` since network order is big-endian.

---

#### `NAVToBigEndian`
**Purpose**: Convert a 16-bit value to big-endian byte order.

**Signature**: `long NAVToBigEndian(long value)`

**Parameters**:
- `value` - Value to convert

**Returns**: Value in big-endian byte order

**Example**:
```netlinx
stack_var long littleEndian
stack_var long bigEndian

littleEndian = $0102  // Bytes in little-endian order
bigEndian = NAVToBigEndian(littleEndian)  // $0201 on little-endian systems
```

**Note**: This is an alias for `NAVHostToNetworkShort` since network order is big-endian.

---

### Integer to Byte Array Functions

#### `NAVIntegerToByteArray`
**Purpose**: Convert a 16-bit integer to a 2-byte array in little-endian order.

**Signature**: `char[2] NAVIntegerToByteArray(integer value)`

**Parameters**:
- `value` - Integer to convert

**Returns**: 2-byte array containing the integer bytes

**Example**:
```netlinx
stack_var integer value
stack_var char bytes[2]

value = $1234
bytes = NAVIntegerToByteArray(value)  // {$34, $12}
```

**Note**: This is an alias for `NAVIntegerToByteArrayLE`.

---

#### `NAVIntegerToByteArrayLE`
**Purpose**: Convert a 16-bit integer to a 2-byte array in little-endian order.

**Signature**: `char[2] NAVIntegerToByteArrayLE(integer value)`

**Parameters**:
- `value` - Integer to convert

**Returns**: 2-byte array containing the integer bytes in little-endian order

**Example**:
```netlinx
stack_var integer value
stack_var char bytes[2]

value = $1234
bytes = NAVIntegerToByteArrayLE(value)  // {$34, $12}
```

---

#### `NAVIntegerToByteArrayBE`
**Purpose**: Convert a 16-bit integer to a 2-byte array in big-endian order.

**Signature**: `char[2] NAVIntegerToByteArrayBE(integer value)`

**Parameters**:
- `value` - Integer to convert

**Returns**: 2-byte array containing the integer bytes in big-endian order

**Example**:
```netlinx
stack_var integer value
stack_var char bytes[2]

value = $1234
bytes = NAVIntegerToByteArrayBE(value)  // {$12, $34}
```

---

### Long to Byte Array Functions

#### `NAVLongToByteArray`
**Purpose**: Convert a 32-bit long to a 4-byte array in little-endian order.

**Signature**: `char[4] NAVLongToByteArray(long value)`

**Parameters**:
- `value` - Long to convert

**Returns**: 4-byte array containing the long bytes

**Example**:
```netlinx
stack_var long value
stack_var char bytes[4]

value = $12345678
bytes = NAVLongToByteArray(value)  // {$78, $56, $34, $12}
```

**Note**: This is an alias for `NAVLongToByteArrayLE`.

---

#### `NAVLongToByteArrayLE`
**Purpose**: Convert a 32-bit long to a 4-byte array in little-endian order.

**Signature**: `char[4] NAVLongToByteArrayLE(long value)`

**Parameters**:
- `value` - Long to convert

**Returns**: 4-byte array containing the long bytes in little-endian order

**Example**:
```netlinx
stack_var long value
stack_var char bytes[4]

value = $12345678
bytes = NAVLongToByteArrayLE(value)  // {$78, $56, $34, $12}
```

---

#### `NAVLongToByteArrayBE`
**Purpose**: Convert a 32-bit long to a 4-byte array in big-endian order.

**Signature**: `char[4] NAVLongToByteArrayBE(long value)`

**Parameters**:
- `value` - Long to convert

**Returns**: 4-byte array containing the long bytes in big-endian order

**Example**:
```netlinx
stack_var long value
stack_var char bytes[4]

value = $12345678
bytes = NAVLongToByteArrayBE(value)  // {$12, $34, $56, $78}
```

---

### Byte Array to Long Conversion

#### `NAVCharToLong`
**Purpose**: Convert a byte array to an array of longs in little-endian order.

**Signature**: `NAVCharToLong(long output[], char input[], integer length)`

**Parameters**:
- `output` - Output array for long values (modified in place)
- `input` - Input byte array
- `length` - Number of bytes to convert from the input

**Returns**: void (output array is modified in place)

**Example**:
```netlinx
stack_var char bytes[8]
stack_var long values[2]

bytes = "$01, $02, $03, $04, $05, $06, $07, $08"
NAVCharToLong(values, bytes, 8)
// values becomes {$04030201, $08070605}
```

**Note**: Converts groups of 4 bytes into longs in little-endian order. The output array length is automatically adjusted.

---

### Hexadecimal String Functions

#### `NAVByteArrayToHexString`
**Purpose**: Convert a byte array to a hexadecimal string without any prefix or separator.

**Signature**: `char[NAV_MAX_BUFFER] NAVByteArrayToHexString(char array[])`

**Parameters**:
- `array` - Byte array to convert

**Returns**: Hexadecimal string representation

**Example**:
```netlinx
stack_var char bytes[3]
stack_var char hexString[NAV_MAX_BUFFER]

bytes = "$01, $23, $45"
hexString = NAVByteArrayToHexString(bytes)  // "012345"
```

---

#### `NAVHexToString`
**Purpose**: Convert a byte array to a hexadecimal string without any prefix or separator.

**Signature**: `char[NAV_MAX_BUFFER] NAVHexToString(char array[])`

**Parameters**:
- `array` - Byte array to convert

**Returns**: Hexadecimal string representation

**Example**:
```netlinx
stack_var char bytes[3]
stack_var char hexString[NAV_MAX_BUFFER]

bytes = "$01, $23, $45"
hexString = NAVHexToString(bytes)  // "012345"
```

**Note**: This is an alias for `NAVByteArrayToHexString`.

---

#### `NAVByteArrayToNetLinxHexString`
**Purpose**: Convert a byte array to a hexadecimal string with NetLinx-style '$' prefix.

**Signature**: `char[NAV_MAX_BUFFER] NAVByteArrayToNetLinxHexString(char array[])`

**Parameters**:
- `array` - Byte array to convert

**Returns**: NetLinx-style hexadecimal string representation

**Example**:
```netlinx
stack_var char bytes[3]
stack_var char hexString[NAV_MAX_BUFFER]

bytes = "$01, $23, $45"
hexString = NAVByteArrayToNetLinxHexString(bytes)  // "$01$23$45"
```

---

#### `NAVByteArrayToCStyleHexString`
**Purpose**: Convert a byte array to a C-style hexadecimal string with "0x" prefix and comma separators.

**Signature**: `char[NAV_MAX_BUFFER] NAVByteArrayToCStyleHexString(char array[])`

**Parameters**:
- `array` - Byte array to convert

**Returns**: C-style hexadecimal string representation

**Example**:
```netlinx
stack_var char bytes[3]
stack_var char hexString[NAV_MAX_BUFFER]

bytes = "$01, $23, $45"
hexString = NAVByteArrayToCStyleHexString(bytes)  // "0X01, 0X23, 0X45"
```

---

#### `NAVByteArrayToHexStringWithOptions`
**Purpose**: Convert a byte array to a hexadecimal string with customizable prefix and separator.

**Signature**: `char[NAV_MAX_BUFFER] NAVByteArrayToHexStringWithOptions(char array[], char prefix[], char separator[])`

**Parameters**:
- `array` - Byte array to convert
- `prefix` - String to place before each byte (e.g., '$' or '0x')
- `separator` - String to place between bytes (e.g., ', ' or '')

**Returns**: Customized hexadecimal string representation

**Example**:
```netlinx
stack_var char bytes[3]
stack_var char hexString[NAV_MAX_BUFFER]

bytes = "$01, $23, $45"
// Returns "#01:#23:#45"
hexString = NAVByteArrayToHexStringWithOptions(bytes, '#', ':')
```

---

#### `NAVByteToHexString`
**Purpose**: Convert a single byte to its hexadecimal string representation.

**Signature**: `char[2] NAVByteToHexString(char byte)`

**Parameters**:
- `byte` - The byte value to convert

**Returns**: Two-character hexadecimal string

**Example**:
```netlinx
stack_var char byte
stack_var char hexString[2]

byte = $A5
hexString = NAVByteToHexString(byte)  // "a5"
```

---

## Common Use Cases

### Network Protocol Implementation

```netlinx
DEFINE_FUNCTION sendNetworkPacket(char data[]) {
    stack_var integer dataLength
    stack_var char packet[1000]
    stack_var char lengthBytes[2]
    
    // Get data length
    dataLength = length_array(data)
    
    // Convert length to network byte order (big-endian)
    lengthBytes = NAVIntegerToByteArrayBE(dataLength)
    
    // Build packet: [2-byte length][data]
    packet = "lengthBytes, data"
    
    // Send packet
    send_string dvDevice, packet
}

DEFINE_FUNCTION parseNetworkPacket(char packet[]) {
    stack_var char lengthBytes[2]
    stack_var integer dataLength
    stack_var long tempLength
    stack_var char data[1000]
    
    // Extract length bytes
    lengthBytes[1] = packet[1]
    lengthBytes[2] = packet[2]
    
    // Convert from network byte order
    tempLength = lengthBytes[1] << 8 | lengthBytes[2]
    dataLength = type_cast(tempLength)
    
    // Extract data
    data = mid_string(packet, 3, dataLength)
    
    // Process data
    processData(data)
}
```

### Binary Data Debugging

```netlinx
DEFINE_FUNCTION logBinaryData(char label[], char data[]) {
    stack_var char hexString[NAV_MAX_BUFFER]
    
    // Format as NetLinx hex string for debugging
    hexString = NAVByteArrayToNetLinxHexString(data)
    
    send_string 0, "label, ': ', hexString"
    send_string 0, "'Length: ', itoa(length_array(data)), ' bytes'"
}

DEFINE_START
stack_var char response[100]

// Received binary response from device
response = "$02, $00, $1A, $FF, $03"

// Log it in readable format
logBinaryData('Device Response', response)
// Output: "Device Response: $02$00$1A$FF$03"
// Output: "Length: 5 bytes"
```

### Multi-byte Value Parsing

```netlinx
DEFINE_FUNCTION parseDeviceStatus(char statusPacket[]) {
    stack_var char temperatureBytes[4]
    stack_var char humidityBytes[2]
    stack_var long temperatures[1]
    stack_var integer humidity
    stack_var slong actualTemp
    
    // Extract 4-byte temperature value (little-endian)
    temperatureBytes[1] = statusPacket[1]
    temperatureBytes[2] = statusPacket[2]
    temperatureBytes[3] = statusPacket[3]
    temperatureBytes[4] = statusPacket[4]
    
    // Convert bytes to long
    NAVCharToLong(temperatures, temperatureBytes, 4)
    actualTemp = type_cast(temperatures[1])
    
    // Extract 2-byte humidity value (big-endian)
    humidityBytes[1] = statusPacket[5]
    humidityBytes[2] = statusPacket[6]
    humidity = type_cast(humidityBytes[1] << 8 | humidityBytes[2])
    
    send_string 0, "'Temperature: ', format('%d', actualTemp), ' C'"
    send_string 0, "'Humidity: ', itoa(humidity), '%'"
}
```

### Custom Protocol Encoder

```netlinx
DEFINE_FUNCTION char[1000] encodeCustomPacket(char command[], char payload[]) {
    stack_var char packet[1000]
    stack_var char header[10]
    stack_var integer payloadLength
    stack_var char lengthBytes[4]
    
    // Create header with 4-byte length (little-endian)
    payloadLength = length_array(payload)
    lengthBytes = NAVLongToByteArrayLE(payloadLength)
    
    // Build header: [STX][4-byte length][command]
    header = "$02, lengthBytes, command"
    
    // Build complete packet
    packet = "header, payload, $03"  // ETX at end
    
    return packet
}

DEFINE_FUNCTION displayPacketInfo(char packet[]) {
    stack_var char hexDump[NAV_MAX_BUFFER]
    
    // Create formatted hex dump
    hexDump = NAVByteArrayToHexStringWithOptions(packet, '0x', ' ')
    
    send_string 0, "'Packet Dump: ', hexDump"
}
```

### Endianness-Aware Data Storage

```netlinx
DEFINE_FUNCTION saveConfigValue(integer configId, long value) {
    stack_var char configBytes[6]
    stack_var char idBytes[2]
    stack_var char valueBytes[4]
    
    // Store config ID in big-endian (standard for storage)
    idBytes = NAVIntegerToByteArrayBE(configId)
    
    // Store value in little-endian (device native format)
    valueBytes = NAVLongToByteArrayLE(value)
    
    // Combine into storage format
    configBytes = "idBytes, valueBytes"
    
    // Write to storage
    writeToStorage(configBytes)
}

DEFINE_FUNCTION long loadConfigValue(integer configId) {
    stack_var char configBytes[6]
    stack_var char valueBytes[4]
    stack_var long values[1]
    
    // Read from storage
    configBytes = readFromStorage(configId)
    
    // Extract value bytes (skip 2-byte ID)
    valueBytes = right_string(configBytes, 4)
    
    // Convert from little-endian
    NAVCharToLong(values, valueBytes, 4)
    
    return values[1]
}
```

## Additional Libraries

The NAVFoundation.Encoding collection also includes:

- [Base64](./NAVFoundation.Encoding.Base64.md) - RFC 4648 compliant Base64 encoding for general purpose binary-to-text encoding
- [Base32](./NAVFoundation.Encoding.Base32.md) - RFC 4648 compliant Base32 encoding with case-insensitive handling for human-readable data

## Best Practices

### Byte Order Considerations

1. **Network Protocols**: Always use big-endian (network byte order) for multi-byte values in network protocols
2. **Device Communication**: Check device documentation for expected endianness
3. **Consistency**: Be consistent with endianness within your application
4. **Documentation**: Document the expected byte order in function comments

### Hexadecimal String Formatting

1. **Debugging**: Use NetLinx-style formatting (`$XX`) for debug logs to match AMX conventions
2. **External Systems**: Use C-style formatting (`0xXX`) when interfacing with C-based systems
3. **Readability**: Add separators (commas, colons) for long byte sequences
4. **Performance**: Use plain hex strings (no prefix/separator) when performance is critical

### Memory Management

1. **Buffer Sizing**: Ensure hex string buffers are large enough (minimum 2 chars per byte + prefixes/separators)
2. **Array Lengths**: Always set proper array lengths before passing to conversion functions
3. **Return Values**: Check return values for error conditions
4. **Temporary Variables**: Use stack variables for intermediate conversions to avoid heap fragmentation

### Error Handling

1. **Range Checking**: Validate input values before conversion
2. **Array Bounds**: Verify array lengths match expected sizes
3. **Logging**: Log conversion operations for debugging
4. **Fallbacks**: Provide default values for error cases

## Implementation Notes

- All byte order conversions assume NetLinx runs on little-endian hardware (typical for AMX processors)
- Hex string output uses lowercase letters by default, except when passed through `upper_string()`
- The `NAVCharToLong` function automatically adjusts the output array length
- All functions are optimized for performance with minimal memory allocation
- Type casting is used explicitly to maintain NetLinx type safety

## Related Libraries

- **NAVFoundation.BinaryUtils** - Binary data manipulation and bit operations
- **NAVFoundation.StringUtils** - String manipulation and formatting utilities
- **NAVFoundation.SocketUtils** - Network communication with byte order handling
