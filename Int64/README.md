# NAVFoundation.Int64

## Overview

The NAVFoundation.Int64 library provides 64-bit integer support for AMX NetLinx applications. Since NetLinx natively only supports 32-bit integers, this library simulates 64-bit integers using a structure with high and low 32-bit components. The library enables mathematical operations, bit manipulation, and conversions for 64-bit integers, which are essential for cryptographic operations, handling large numeric values, and implementing algorithms that require extended precision.

The library was primarily designed to support the SHA-512 cryptographic hash implementation but can be used for any application requiring 64-bit integer arithmetic.

## Key Features

- 64-bit integer representation using paired 32-bit values
- Basic arithmetic operations (addition, subtraction, multiplication, division)
- Bitwise operations (AND, OR, XOR, NOT)
- Bit shifting and rotation
- Comparison functions
- Conversion between 64-bit integers and various formats (string, hex, byte arrays)
- Big-endian and little-endian byte array support
- Signed and unsigned 64-bit integer handling

## Data Structure

The library defines a structure to represent 64-bit integers:

```netlinx
struct _NAVInt64 {
    long Hi    // High 32 bits (most significant)
    long Lo    // Low 32 bits (least significant)
}
```

## API Reference

### Basic Arithmetic Operations

#### NAVInt64Add

```netlinx
define_function integer NAVInt64Add(_NAVInt64 a, _NAVInt64 b, _NAVInt64 result)
```

**Description:** Adds two 64-bit integers.

**Parameters:**

- `a` - First 64-bit integer
- `b` - Second 64-bit integer
- `result` - Result of a + b

**Returns:** 1 if carry occurred, 0 otherwise

---

#### NAVInt64AddLong

```netlinx
define_function integer NAVInt64AddLong(_NAVInt64 a, long b, _NAVInt64 result)
```

**Description:** Adds a 32-bit integer to a 64-bit integer.

**Parameters:**

- `a` - 64-bit integer
- `b` - 32-bit integer to add
- `result` - Result of a + b

**Returns:** 1 if carry occurred, 0 otherwise

---

#### NAVInt64Subtract

```netlinx
define_function integer NAVInt64Subtract(_NAVInt64 a, _NAVInt64 b, _NAVInt64 result)
```

**Description:** Subtracts one 64-bit integer from another.

**Parameters:**

- `a` - First 64-bit integer (minuend)
- `b` - Second 64-bit integer to subtract (subtrahend)
- `result` - Result of a - b

**Returns:** 1 if borrow occurred (result is negative), 0 otherwise

---

#### NAVInt64Multiply

```netlinx
define_function NAVInt64Multiply(_NAVInt64 a, _NAVInt64 b, _NAVInt64 result)
```

**Description:** Multiplies two 64-bit integers.

**Parameters:**

- `a` - First 64-bit integer (multiplicand)
- `b` - Second 64-bit integer (multiplier)
- `result` - Result of a \* b

**Note:** This implementation has limited precision and may truncate results that would require more than 64 bits.

---

#### NAVInt64Divide

```netlinx
define_function integer NAVInt64Divide(_NAVInt64 dividend, _NAVInt64 divisor, _NAVInt64 quotient, _NAVInt64 remainder, integer computeRemainder)
```

**Description:** Divides one 64-bit integer by another.

**Parameters:**

- `dividend` - The number being divided
- `divisor` - The number to divide by
- `quotient` - The result of division (dividend / divisor)
- `remainder` - The remainder of division
- `computeRemainder` - Flag to compute the remainder (1) or not (0)

**Returns:** 0 on success, 1 on error (division by zero)

**Note:** This implementation has limitations when dealing with very large values.

### Bitwise Operations

#### NAVInt64BitAnd

```netlinx
define_function NAVInt64BitAnd(_NAVInt64 a, _NAVInt64 b, _NAVInt64 result)
```

**Description:** Performs bitwise AND on two 64-bit integers.

**Parameters:**

- `a` - First 64-bit integer
- `b` - Second 64-bit integer
- `result` - Result of a & b

---

#### NAVInt64BitOr

```netlinx
define_function NAVInt64BitOr(_NAVInt64 a, _NAVInt64 b, _NAVInt64 result)
```

**Description:** Performs bitwise OR on two 64-bit integers.

**Parameters:**

- `a` - First 64-bit integer
- `b` - Second 64-bit integer
- `result` - Result of a | b

---

#### NAVInt64BitXor

```netlinx
define_function NAVInt64BitXor(_NAVInt64 a, _NAVInt64 b, _NAVInt64 result)
```

**Description:** Performs bitwise XOR on two 64-bit integers.

**Parameters:**

- `a` - First 64-bit integer
- `b` - Second 64-bit integer
- `result` - Result of a ^ b

---

#### NAVInt64BitNot

```netlinx
define_function NAVInt64BitNot(_NAVInt64 a, _NAVInt64 result)
```

**Description:** Performs bitwise NOT on a 64-bit integer.

**Parameters:**

- `a` - The 64-bit integer to negate
- `result` - Result of ~a

### Shift and Rotate Operations

#### NAVInt64ShiftRight

```netlinx
define_function NAVInt64ShiftRight(_NAVInt64 a, integer bits, _NAVInt64 result)
```

**Description:** Performs a logical right shift on a 64-bit value.

**Parameters:**

- `a` - The 64-bit integer to shift
- `bits` - Number of bits to shift (0-63)
- `result` - Result of shift

---

#### NAVInt64ShiftLeft

```netlinx
define_function NAVInt64ShiftLeft(_NAVInt64 a, integer bits, _NAVInt64 result)
```

**Description:** Performs a logical left shift on a 64-bit value.

**Parameters:**

- `a` - The 64-bit integer to shift
- `bits` - Number of bits to shift (0-63)
- `result` - Result of shift

---

#### NAVInt64RotateRight

```netlinx
define_function NAVInt64RotateRight(_NAVInt64 a, integer bits, _NAVInt64 result)
```

**Description:** Performs a circular right rotation on a 64-bit value (treating Hi and Lo as separate 32-bit values).

**Parameters:**

- `a` - The 64-bit integer to rotate
- `bits` - Number of bits to rotate (0-31)
- `result` - Result of rotation

**Note:** This operation treats the high and low 32-bit parts separately.

---

#### NAVInt64RotateLeft

```netlinx
define_function NAVInt64RotateLeft(_NAVInt64 a, integer bits, _NAVInt64 result)
```

**Description:** Performs a circular left rotation on a 64-bit value (treating Hi and Lo as separate 32-bit values).

**Parameters:**

- `a` - The 64-bit integer to rotate
- `bits` - Number of bits to rotate (0-31)
- `result` - Result of rotation

**Note:** This operation treats the high and low 32-bit parts separately.

---

#### NAVInt64RotateRightFull

```netlinx
define_function NAVInt64RotateRightFull(_NAVInt64 x, integer bits, _NAVInt64 result)
```

**Description:** Performs a circular right rotation on a full 64-bit value, properly handling rotation across the 32-bit word boundary.

**Parameters:**

- `x` - The 64-bit integer to rotate
- `bits` - Number of bits to rotate (0-63)
- `result` - Result of rotation

### Comparison Operations

#### NAVInt64Compare

```netlinx
define_function sinteger NAVInt64Compare(_NAVInt64 a, _NAVInt64 b)
```

**Description:** Compares two 64-bit integers as signed values.

**Parameters:**

- `a` - First 64-bit integer
- `b` - Second 64-bit integer

**Returns:** -1 if a < b, 0 if a == b, 1 if a > b

---

#### NAVInt64IsZero

```netlinx
define_function integer NAVInt64IsZero(_NAVInt64 a)
```

**Description:** Checks if a 64-bit integer is zero.

**Parameters:**

- `a` - The 64-bit integer to check

**Returns:** 1 if zero, 0 if non-zero

---

#### NAVInt64IsNegative

```netlinx
define_function integer NAVInt64IsNegative(_NAVInt64 a)
```

**Description:** Checks if a 64-bit integer is negative.

**Parameters:**

- `a` - The 64-bit integer to check

**Returns:** 1 if negative, 0 if zero or positive

---

#### NAVInt64Min

```netlinx
define_function NAVInt64Min(_NAVInt64 a, _NAVInt64 b, _NAVInt64 result)
```

**Description:** Returns the minimum of two 64-bit integers.

**Parameters:**

- `a` - First 64-bit integer
- `b` - Second 64-bit integer
- `result` - The smaller value

---

#### NAVInt64Max

```netlinx
define_function NAVInt64Max(_NAVInt64 a, _NAVInt64 b, _NAVInt64 result)
```

**Description:** Returns the maximum of two 64-bit integers.

**Parameters:**

- `a` - First 64-bit integer
- `b` - Second 64-bit integer
- `result` - The larger value

### Conversion Functions

#### NAVInt64ToByteArrayBE

```netlinx
define_function char[8] NAVInt64ToByteArrayBE(_NAVInt64 value)
```

**Description:** Converts a 64-bit integer to a big-endian byte array.

**Parameters:**

- `value` - The 64-bit integer to convert

**Returns:** 8-byte big-endian representation

---

#### NAVByteArrayBEToInt64

```netlinx
define_function NAVByteArrayBEToInt64(char bytes[], _NAVInt64 result)
```

**Description:** Converts an 8-byte big-endian array to a 64-bit integer.

**Parameters:**

- `bytes` - The byte array in big-endian format
- `result` - The structure to populate with the converted value

---

#### NAVInt64ToByteArrayLE

```netlinx
define_function char[8] NAVInt64ToByteArrayLE(_NAVInt64 value)
```

**Description:** Converts a 64-bit integer to a little-endian byte array.

**Parameters:**

- `value` - The 64-bit integer to convert

**Returns:** 8-byte little-endian representation

---

#### NAVByteArrayLEToInt64

```netlinx
define_function NAVByteArrayLEToInt64(char bytes[], _NAVInt64 result)
```

**Description:** Converts an 8-byte little-endian array to a 64-bit integer.

**Parameters:**

- `bytes` - The byte array in little-endian format
- `result` - The structure to populate with the converted value

---

#### NAVInt64ToString

```netlinx
define_function integer NAVInt64ToString(_NAVInt64 value, char result[])
```

**Description:** Converts a 64-bit integer to decimal string.

**Parameters:**

- `value` - The 64-bit integer to convert
- `result` - The output string buffer

**Returns:** Length of the resulting string

**Note:** For extremely large values, the string representation may encounter precision limitations.

---

#### NAVInt64ToHexString

```netlinx
define_function integer NAVInt64ToHexString(_NAVInt64 value, char result[], integer addPrefix)
```

**Description:** Converts a 64-bit integer to a hexadecimal string.

**Parameters:**

- `value` - The 64-bit integer to convert
- `result` - The output string buffer
- `addPrefix` - Flag to add '0x' prefix (1) or not (0)

**Returns:** Length of the resulting string

---

#### NAVInt64FromString

```netlinx
define_function integer NAVInt64FromString(char str[], _NAVInt64 result)
```

**Description:** Converts a decimal string to a 64-bit integer.

**Parameters:**

- `str` - String containing decimal number (with optional minus sign)
- `result` - The converted value

**Returns:** 0 on success, 1 on invalid input

---

#### NAVInt64FromHexString

```netlinx
define_function integer NAVInt64FromHexString(char str[], _NAVInt64 result)
```

**Description:** Converts a hexadecimal string to a 64-bit integer.

**Parameters:**

- `str` - String containing hex number (with or without 0x prefix)
- `result` - The converted value

**Returns:** 0 on success, 1 on error

### Sign Operations

#### NAVInt64Negate

```netlinx
define_function NAVInt64Negate(_NAVInt64 a, _NAVInt64 result)
```

**Description:** Negates a 64-bit integer (two's complement).

**Parameters:**

- `a` - The 64-bit integer to negate
- `result` - The negated result

---

#### NAVInt64Abs

```netlinx
define_function NAVInt64Abs(_NAVInt64 a, _NAVInt64 result)
```

**Description:** Returns the absolute value of a 64-bit integer.

**Parameters:**

- `a` - Input 64-bit integer
- `result` - Absolute value result

### Utility Functions

#### NAVInt64FindHighestBit

```netlinx
define_function sinteger NAVInt64FindHighestBit(_NAVInt64 value)
```

**Description:** Finds the highest bit set in a 64-bit integer (0-63).

**Parameters:**

- `value` - The 64-bit integer to check

**Returns:** Position of highest bit set (0-63) or -1 if value is zero

## Usage Examples

### Basic Arithmetic

```netlinx
#include 'NAVFoundation.Int64.axi'

// Example function showing basic arithmetic
define_function Int64ArithmeticExample()
{
    stack_var _NAVInt64 a, b, result
    stack_var char resultStr[20]

    // Initialize values
    a.Hi = 0
    a.Lo = 1000

    b.Hi = 0
    b.Lo = 500

    // Addition
    NAVInt64Add(a, b, result)
    NAVInt64ToString(result, resultStr)
    send_string 0, "'Addition: 1000 + 500 = ', resultStr"  // Should output 1500

    // Subtraction
    NAVInt64Subtract(a, b, result)
    NAVInt64ToString(result, resultStr)
    send_string 0, "'Subtraction: 1000 - 500 = ', resultStr"  // Should output 500

    // Multiplication
    NAVInt64Multiply(a, b, result)
    NAVInt64ToString(result, resultStr)
    send_string 0, "'Multiplication: 1000 * 500 = ', resultStr"  // Should output 500000

    // Division
    NAVInt64Divide(a, b, result, b, 0)  // Using b as placeholder for remainder
    NAVInt64ToString(result, resultStr)
    send_string 0, "'Division: 1000 / 500 = ', resultStr"  // Should output 2
}
```

### Working with Large Numbers

```netlinx
define_function Int64LargeNumberExample()
{
    stack_var _NAVInt64 billion, two, result
    stack_var char resultStr[30]

    // Set up one billion
    billion.Hi = 0
    billion.Lo = 1000000000

    // Set up two
    two.Hi = 0
    two.Lo = 2

    // Multiply to get two billion
    NAVInt64Multiply(billion, two, result)
    NAVInt64ToString(result, resultStr)
    send_string 0, "'Two billion = ', resultStr"  // Should output 2000000000

    // A value that exceeds 32-bit capacity
    result.Hi = 5  // This represents 5 * 2^32
    result.Lo = 0
    NAVInt64ToString(result, resultStr)
    send_string 0, "'Large value = ', resultStr"  // Should output ~21.47 billion
}
```

### Bitwise Operations

```netlinx
define_function Int64BitwiseExample()
{
    stack_var _NAVInt64 a, b, result
    stack_var char hexResult[20]

    // Initialize values
    a.Hi = 0
    a.Lo = $AAAA5555  // Binary: 1010...0101

    b.Hi = 0
    b.Lo = $5555AAAA  // Binary: 0101...1010

    // AND operation
    NAVInt64BitAnd(a, b, result)
    NAVInt64ToHexString(result, hexResult, 1)
    send_string 0, "'Bitwise AND: ', hexResult"  // Should output 0x00000000

    // OR operation
    NAVInt64BitOr(a, b, result)
    NAVInt64ToHexString(result, hexResult, 1)
    send_string 0, "'Bitwise OR: ', hexResult"   // Should output 0xFFFFFFFF

    // XOR operation
    NAVInt64BitXor(a, b, result)
    NAVInt64ToHexString(result, hexResult, 1)
    send_string 0, "'Bitwise XOR: ', hexResult"  // Should output 0xFFFFFFFF

    // NOT operation
    NAVInt64BitNot(a, result)
    NAVInt64ToHexString(result, hexResult, 1)
    send_string 0, "'Bitwise NOT: ', hexResult"
}
```

### Shift and Rotate Operations

```netlinx
define_function Int64ShiftRotateExample()
{
    stack_var _NAVInt64 value, result
    stack_var char hexResult[20]

    // Initialize value
    value.Hi = 0
    value.Lo = $0000000F  // Binary: ...00001111

    // Left shift
    NAVInt64ShiftLeft(value, 4, result)
    NAVInt64ToHexString(result, hexResult, 1)
    send_string 0, "'Left shift by 4: ', hexResult"  // Should output 0x000000F0

    // Right shift
    value.Lo = $F0000000  // Binary: 1111...0000
    NAVInt64ShiftRight(value, 4, result)
    NAVInt64ToHexString(result, hexResult, 1)
    send_string 0, "'Right shift by 4: ', hexResult"  // Should output 0x0F000000

    // Rotate right
    value.Hi = $12345678
    value.Lo = $9ABCDEF0
    NAVInt64RotateRight(value, 8, result)
    NAVInt64ToHexString(result, hexResult, 1)
    send_string 0, "'Rotate right by 8: ', hexResult"
}
```

### Conversion Examples

```netlinx
define_function Int64ConversionExample()
{
    stack_var _NAVInt64 value, result
    stack_var char byteArray[8]
    stack_var char hexString[20], decString[20]

    // Initialize a value
    value.Hi = $01234567
    value.Lo = $89ABCDEF

    // Convert to hex string
    NAVInt64ToHexString(value, hexString, 1)
    send_string 0, "'Hex representation: ', hexString"

    // Convert to decimal string
    NAVInt64ToString(value, decString)
    send_string 0, "'Decimal representation: ', decString"

    // Convert to byte array (big-endian)
    byteArray = NAVInt64ToByteArrayBE(value)
    send_string 0, "'Byte array (hex): ', NAVByteArrayToHexString(byteArray)"

    // Convert back from byte array
    NAVByteArrayBEToInt64(byteArray, result)
    NAVInt64ToHexString(result, hexString, 1)
    send_string 0, "'Converted back: ', hexString"

    // Parse from string
    NAVInt64FromString('123456789', result)
    NAVInt64ToHexString(result, hexString, 1)
    send_string 0, "'From decimal string: ', hexString"

    // Parse from hex string
    NAVInt64FromHexString('0xABCD1234', result)
    NAVInt64ToString(result, decString)
    send_string 0, "'From hex string: ', decString"
}
```

### Cryptographic Use Case (HMAC Component)

```netlinx
// Example showing how Int64 would be used in cryptographic context
define_function SimulateHmacOperation()
{
    stack_var _NAVInt64 messageBlock[16]  // Simulated 1024-bit message block
    stack_var _NAVInt64 hashState[8]      // Simulated hash state
    stack_var _NAVInt64 temp1, temp2, sum
    stack_var integer i

    // Initialize mock hash state (these would normally be standard constants)
    hashState[1].Hi = $6A09E667
    hashState[1].Lo = $F3BCC908

    // Simulate a single round of SHA-512 compression function
    for (i = 1; i <= 8; i++)
    {
        // Rotation operations - critical in cryptographic algorithms
        NAVInt64RotateRight(hashState[i], 28, temp1)
        NAVInt64RotateRight(hashState[i], 34, temp2)
        NAVInt64BitXor(temp1, temp2, temp1)

        // Addition operation - used extensively in hash functions
        NAVInt64Add(hashState[i], messageBlock[i], sum)

        // Update hash state
        hashState[i] = sum
    }

    // The resulting hashState would be used for further cryptographic processing
}
```

## Implementation Notes

### Limitations

1. **Multiplication**: Operations involving very large numbers may result in precision loss due to 64-bit result truncation.
2. **Division**: Limited precision for very large values or complex divisions.
3. **String Conversion**: String conversion for extremely large values near the 64-bit limit may not be perfectly accurate.
4. **Bit Rotation**: The standard rotation functions treat high and low 32-bit parts separately, which works well for cryptographic operations but differs from true 64-bit rotation. Use NAVInt64RotateRightFull for full 64-bit rotation.
5. **Performance**: Operations on 64-bit integers are significantly slower than native 32-bit operations due to the overhead of simulating 64-bit arithmetic.

### Optimization Notes

- For simple operations where values fit within 32 bits, it's more efficient to use native 32-bit operations.
- The library is optimized for use in cryptographic operations, particularly SHA-512.
- Division is the most complex and performance-intensive operation - avoid if possible in performance-critical code.
- For performance-critical applications, consider whether the precision of 64-bit integers is actually necessary.

## Compatibility

The Int64 library is compatible with all AMX NetLinx environments, as it uses only standard NetLinx features to implement 64-bit integer functionality.
