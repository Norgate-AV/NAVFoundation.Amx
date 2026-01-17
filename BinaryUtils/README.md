# NAVFoundation.BinaryUtils

A comprehensive library providing utilities for bit manipulation, binary conversions, and BCD (Binary Coded Decimal) operations in AMX NetLinx.

## Overview

The BinaryUtils library provides low-level binary operations commonly needed when interfacing with hardware protocols, implementing data encoding schemes, or performing bitwise operations. It includes functions for bit rotation, bit extraction, binary-to-BCD conversion, and binary representation formatting.

## Features

- **Bit Rotation**: Rotate 32-bit values left or right
- **Bit Extraction**: Extract individual bits from values
- **Binary Representation**: Convert bytes to bit arrays or binary strings
- **BCD Conversion**: Bidirectional conversion between binary integers and BCD format

## Installation

Include the library in your NetLinx project:

```netlinx
#include 'NAVFoundation.BinaryUtils.axi'
```

## API Reference

### Bit Rotation Functions

#### `NAVBinaryRotateLeft(long value, long count)`

Rotates bits of a 32-bit value to the left by the specified count. Bits that are rotated off the left end appear at the right end.

**Parameters:**
- `value` (long): The value to rotate
- `count` (long): Number of positions to rotate left

**Returns:** (long) The rotated value

**Example:**
```netlinx
stack_var long original
stack_var long rotated

original = $01  // Binary: 00000000 00000000 00000000 00000001
rotated = NAVBinaryRotateLeft(original, 4)  // Binary: 00000000 00000000 00000000 00010000
// rotated = $10
```

**Note:** Count should typically be between 1 and 31 for meaningful results.

---

#### `NAVBitRotateLeft(long value, long count)`

Alias for `NAVBinaryRotateLeft`. Rotates bits of a 32-bit value to the left.

**Parameters:**
- `value` (long): The value to rotate
- `count` (long): Number of positions to rotate left

**Returns:** (long) The rotated value

**See:** `NAVBinaryRotateLeft`

---

#### `NAVBinaryRotateRight(long value, long count)`

Rotates bits of a 32-bit value to the right by the specified count. Bits that are rotated off the right end appear at the left end.

**Parameters:**
- `value` (long): The value to rotate
- `count` (long): Number of positions to rotate right

**Returns:** (long) The rotated value

**Example:**
```netlinx
stack_var long original
stack_var long rotated

original = $10  // Binary: 00000000 00000000 00000000 00010000
rotated = NAVBinaryRotateRight(original, 4)  // Binary: 00000000 00000000 00000000 00000001
// rotated = $01
```

**Note:** Count should typically be between 1 and 31 for meaningful results.

---

#### `NAVBitRotateRight(long value, long count)`

Alias for `NAVBinaryRotateRight`. Rotates bits of a 32-bit value to the right.

**Parameters:**
- `value` (long): The value to rotate
- `count` (long): Number of positions to rotate right

**Returns:** (long) The rotated value

**See:** `NAVBinaryRotateRight`

---

### Bit Manipulation Functions

#### `NAVBinaryGetBit(long value, long bit)`

Extracts a single bit from a 32-bit value at the specified position.

**Parameters:**
- `value` (long): The value to extract a bit from
- `bit` (long): The bit position to extract (0-31)

**Returns:** (long) 1 if the specified bit is set, 0 otherwise

**Example:**
```netlinx
stack_var long value
stack_var long bitValue

value = $05  // Binary: 00000000 00000000 00000000 00000101
bitValue = NAVBinaryGetBit(value, 0)  // Returns 1 (rightmost bit)
bitValue = NAVBinaryGetBit(value, 1)  // Returns 0 (second bit from right)
bitValue = NAVBinaryGetBit(value, 2)  // Returns 1 (third bit from right)
```

**Note:** Bit position 0 is the least significant (rightmost) bit.

---

### Binary Representation Functions

#### `NAVByteToBitArray(char value)`

Converts a byte to an array of individual bit values. Each bit is represented as a numeric value (0 or 1) in the returned array.

**Parameters:**
- `value` (char): The byte value to convert

**Returns:** (char[8]) Array of 8 bit values (0 or 1)

**Example:**
```netlinx
stack_var char value
stack_var char result[8]

value = $A5  // Binary: 10100101
result = NAVByteToBitArray(value)
// result = {1, 0, 1, 0, 0, 1, 0, 1}
```

**Use Cases:**
- Analyzing individual bits of protocol bytes
- Implementing custom bit-level protocols
- Debugging binary data structures

---

#### `NAVByteToBinaryString(char value)`

Converts a byte to its binary representation as an 8-character string.

**Parameters:**
- `value` (char): The byte value to convert

**Returns:** (char[8]) Binary representation as an 8-character string

**Example:**
```netlinx
stack_var char value
stack_var char result[8]

value = $A5  // Binary: 10100101
result = NAVByteToBinaryString(value)
// result = '10100101'
```

**Use Cases:**
- Debugging and logging binary data
- Display binary values in user interfaces
- Protocol analysis and troubleshooting

---

### BCD Conversion Functions

BCD (Binary Coded Decimal) is a binary encoding where each decimal digit (0-9) is represented by 4 bits (one nibble). This encoding is commonly used in hardware devices like RTCs (Real-Time Clocks), numeric displays, and various embedded systems.

#### `NAVBinaryToBcd(integer value)`

Converts a binary integer to BCD (Binary Coded Decimal) format using the double-dabble algorithm.

**Parameters:**
- `value` (integer): The binary integer to convert (0-9999)

**Returns:** (long) BCD representation of the value

**Example:**
```netlinx
stack_var integer decimal
stack_var long bcd

decimal = 42
bcd = NAVBinaryToBcd(decimal)  // Returns $42 (BCD format)

decimal = 1234
bcd = NAVBinaryToBcd(decimal)  // Returns $1234 (BCD format)
```

**Use Cases:**
- Sending decimal values to hardware that expects BCD encoding
- Implementing BCD-based protocols
- Interfacing with seven-segment displays

**Note:** This implements the double-dabble algorithm for BCD conversion.

---

#### `NAVBcdToBinary(char value)`

Converts a BCD (Binary Coded Decimal) byte to its binary integer value. Each nibble (4 bits) of the input represents a decimal digit (0-9).

**Parameters:**
- `value` (char): The BCD-encoded byte to convert (0x00-0x99)

**Returns:** (integer) Binary integer representation (0-99)

**Example:**
```netlinx
stack_var char bcdValue
stack_var integer decimal

bcdValue = $42  // BCD representation of 42
decimal = NAVBcdToBinary(bcdValue)  // Returns 42

bcdValue = $99  // BCD representation of 99
decimal = NAVBcdToBinary(bcdValue)  // Returns 99
```

**Use Cases:**
- Reading BCD-encoded data from hardware (RTCs, displays, etc.)
- Parsing BCD protocol responses
- Converting BCD values for display or calculation

**Note:** Input values should only use digits 0-9 in each nibble (0x00-0x99).

---

## Common Use Cases

### Working with Hardware Protocols

Many hardware devices use BCD encoding for numeric values:

```netlinx
// Reading time from an RTC chip that returns BCD values
stack_var char bcdHour
stack_var integer hour

bcdHour = $13  // 1:00 PM in BCD
hour = NAVBcdToBinary(bcdHour)  // Converts to 13

// Sending time to a device expecting BCD format
stack_var integer currentHour
stack_var char bcdOutput

currentHour = 15  // 3:00 PM
bcdOutput = NAVBinaryToBcd(currentHour)  // Converts to $15 for transmission
```

### Bit Manipulation for Protocol Implementation

```netlinx
// Extracting flags from a status byte
stack_var char statusByte
stack_var long powerOn
stack_var long errorFlag

statusByte = $85  // Binary: 10000101
powerOn = NAVBinaryGetBit(statusByte, 0)     // Returns 1
errorFlag = NAVBinaryGetBit(statusByte, 7)   // Returns 1

// Rotating data for encryption or encoding
stack_var long data
stack_var long encoded

data = $12345678
encoded = NAVBinaryRotateLeft(data, 8)  // Rotates by one byte
```

### Debugging Binary Data

```netlinx
// Visualizing binary data for debugging
stack_var char rxByte
stack_var char binaryStr[8]

rxByte = $A5
binaryStr = NAVByteToBinaryString(rxByte)
NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Received byte: ',binaryStr")
// Output: "Received byte: 10100101"
```

## Migration Guide

If you're updating from an older version of NAVFoundation.BinaryUtils, the following function names have changed:

| Old Function Name | New Function Name | Notes |
|------------------|-------------------|-------|
| `NAVCharToDecimalBinaryString()` | `NAVByteToBitArray()` | Returns numeric bit array instead of string |
| `NAVCharToAsciiBinaryString()` | `NAVByteToBinaryString()` | Returns ASCII string (behavior unchanged) |
| `NAVDecimalToBinary()` | `NAVBinaryToBcd()` | Corrected naming to reflect BCD conversion |

**New function:**
- `NAVBcdToBinary()` - Reverse BCD conversion for reading hardware values

**Migration steps:**
1. Search your codebase for the old function names
2. Replace with the new names according to the table above
3. For BCD operations, verify you're using the correct direction:
   - Use `NAVBinaryToBcd()` when sending to hardware
   - Use `NAVBcdToBinary()` when reading from hardware

## Dependencies

- `NAVFoundation.Core.h.axi`

## Testing

This library includes comprehensive test coverage with 119 test cases covering all functions and edge cases. Tests are located in:

```
__tests__/include/binary-utils/
```

To run the test suite:

```bash
genlinx build .\__tests__\src\binary-utils.axs
```

## License

MIT License - Copyright (c) 2010-2026 Norgate AV

## See Also

- [NAVFoundation.Core](../Core/README.md)
- [NAVFoundation.Encoding](../Encoding/README.md)
- [NAVFoundation.Math](../Math/README.md)
