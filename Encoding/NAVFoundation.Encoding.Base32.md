# NAVFoundation.Encoding.Base32

## Overview

The Base32 implementation provides encoding and decoding functionality based on RFC 4648. Base32 encoding represents binary data in an ASCII string format by translating it into a radix-32 representation, using a 32-character subset of the ASCII alphabet (A-Z and 2-7).

Base32 is commonly used in various applications including:

- Time-based One-Time Password (TOTP) authentication keys
- Applications requiring case-insensitive encoded data
- Systems where human readability and transcription are important
- DNS hostnames that need to represent binary data
- Systems where encoded data must be valid filenames

Key features of this implementation include:

- Full compliance with RFC 4648 standard Base32 encoding
- Support for both encoding and decoding operations
- Case-insensitive decoding
- Proper handling of padding characters
- Whitespace tolerance during decoding
- Robust error handling for invalid inputs
- Correct processing of binary data, including negative byte values in NetLinx

## API Reference

### Main Functions

#### `NAVBase32Encode`

```netlinx
define_function char[NAV_MAX_BUFFER] NAVBase32Encode(char value[])
```

**Description:** Encodes binary data into a Base32 string representation.

**Parameters:**

- `value` - The binary data to be encoded

**Returns:**

- Base32 encoded string
- Original input if the input is empty

#### `NAVBase32Decode`

```netlinx
define_function char[NAV_MAX_BUFFER] NAVBase32Decode(char value[])
```

**Description:** Decodes a Base32 encoded string back to its original binary form.

**Parameters:**

- `value` - The Base32 encoded string

**Returns:**

- Decoded binary data
- Original input if the input is empty

### Helper Functions

#### `NAVBase32GetCharValue`

```netlinx
define_function sinteger NAVBase32GetCharValue(char c)
```

**Description:** Gets the 5-bit value for a Base32 character.

**Parameters:**

- `c` - A character from a Base32 encoded string

**Returns:**

- Integer value (0-31) corresponding to the character's position in the Base32 alphabet
- Special value `NAV_BASE32_INVALID_VALUE` (-1) for invalid or ignored characters

## Usage Examples

### Basic Encoding and Decoding

```netlinx
// Include the Base32 library
#include 'NAVFoundation.Encoding.Base32.axi'

// Example function
define_function ExampleBase32Usage() {
    stack_var char originalData[100]
    stack_var char encodedData[NAV_MAX_BUFFER]
    stack_var char decodedData[NAV_MAX_BUFFER]

    // Sample data to encode
    originalData = 'Hello!!!'

    // Encode the data to Base32
    encodedData = NAVBase32Encode(originalData)

    // Output the encoded result
    // Should be: "JBSWY3DPEEQSC==="
    send_string 0, "'Base32 encoded: ', encodedData"

    // Decode the Base32 string back to the original data
    decodedData = NAVBase32Decode(encodedData)

    // Verify the result
    if (decodedData == originalData) {
        send_string 0, "'Successfully decoded back to original data'"
    } else {
        send_string 0, "'Decoding error: results don''t match'"
    }
}
```

<!-- ### TOTP Authenticator Integration

```netlinx
// Include required libraries
#include 'NAVFoundation.Encoding.Base32.axi'
#include 'NAVFoundation.Cryptography.HMAC.axi'  // Hypothetical library

// Example function for TOTP token generation
define_function char[6] GenerateTOTPCode(char base32Secret[], integer timeStep) {
    stack_var char binarySecret[100]
    stack_var integer currentTime
    stack_var char hmacResult[20]
    stack_var integer offset, truncatedHash, totpValue
    stack_var char totpCode[6]

    // Decode the Base32 secret key to binary
    binarySecret = NAVBase32Decode(base32Secret)

    // Get current Unix time and calculate the counter value (floor(time / timeStep))
    currentTime = GetUnixTime() // Assume this function exists
    currentTime = currentTime / timeStep

    // Generate HMAC-SHA1 of the counter using the binary secret as key
    hmacResult = ComputeHMAC(binarySecret, IntToBigEndianBytes(currentTime)) // Assume these functions exist

    // Extract 4 bytes from the HMAC result based on offset
    offset = type_cast(hmacResult[20] & $0F)
    truncatedHash = ((type_cast(hmacResult[offset+1]) & $7F) << 24) |
                    ((type_cast(hmacResult[offset+2]) & $FF) << 16) |
                    ((type_cast(hmacResult[offset+3]) & $FF) << 8) |
                    (type_cast(hmacResult[offset+4]) & $FF)

    // Calculate 6-digit TOTP code
    totpValue = truncatedHash % 1000000

    // Format as 6 digits with leading zeros if needed
    totpCode = format('%06d', totpValue)

    return totpCode
}
``` -->

### Case-Insensitive Decoding

```netlinx
// Include the Base32 library
#include 'NAVFoundation.Encoding.Base32.axi'

// Example function showing case-insensitive decoding
define_function ExampleCaseInsensitiveDecoding() {
    stack_var char originalData[100]
    stack_var char encodedData[NAV_MAX_BUFFER]
    stack_var char mixedCaseData[NAV_MAX_BUFFER]
    stack_var char decodedData[NAV_MAX_BUFFER]

    // Sample data
    originalData = 'Test case-insensitive decoding'

    // Encode data
    encodedData = NAVBase32Encode(originalData)

    // Create mixed case variant of the encoded data
    mixedCaseData = encodedData
    // Convert some uppercase to lowercase (example)
    if (length_array(mixedCaseData) >= 5) {
        mixedCaseData[1] = 'k' // Instead of 'K'
        mixedCaseData[3] = 'z' // Instead of 'Z'
        mixedCaseData[5] = 'q' // Instead of 'Q'
    }

    // Decode despite casing differences
    decodedData = NAVBase32Decode(mixedCaseData)

    // Verify result
    if (decodedData == originalData) {
        send_string 0, "'Successfully decoded case-insensitive Base32'"
    } else {
        send_string 0, "'Error in case-insensitive decoding'"
    }
}
```

### Handling Binary Data

```netlinx
// Include the Base32 library
#include 'NAVFoundation.Encoding.Base32.axi'

// Example function for encoding binary data
define_function ExampleBinaryEncoding() {
    stack_var char binaryData[10]
    stack_var char encodedData[NAV_MAX_BUFFER]
    stack_var char decodedData[NAV_MAX_BUFFER]

    // Create binary data including negative values in NetLinx
    binaryData = "$00, $01, $02, $FF, $FE, $FD, $80, $90, $A0, $B0"

    // Encode the binary data to Base32
    encodedData = NAVBase32Encode(binaryData)

    // Output the encoded result
    send_string 0, "'Binary data encoded: ', encodedData"

    // Decode back to binary
    decodedData = NAVBase32Decode(encodedData)

    // Compare lengths for verification
    if (length_array(decodedData) == length_array(binaryData)) {
        send_string 0, "'Binary data length preserved: ', itoa(length_array(decodedData)), ' bytes'"
    }
}
```

### Working with Whitespace

```netlinx
// Include the Base32 library
#include 'NAVFoundation.Encoding.Base32.axi'

// Example function showing whitespace tolerance
define_function ExampleWhitespaceHandling() {
    stack_var char encodedWithWhitespace[500]
    stack_var char decodedData[NAV_MAX_BUFFER]
    stack_var char originalText[100]

    originalText = 'Hello!!!'

    // Base32 with whitespace (spaces, line breaks)
    encodedWithWhitespace = 'JBS WY3 DPE
    EQS C==='

    // Decode - the implementation automatically handles whitespace
    decodedData = NAVBase32Decode(encodedWithWhitespace)

    // Verify result
    if (decodedData == originalText) {
        send_string 0, "'Successfully decoded Base32 with whitespace'"
    } else {
        send_string 0, "'Error decoding Base32 with whitespace'"
    }
}
```

## Reference Values

For testing purposes, here are some test vectors for Base32 from RFC 4648:

| Input    | Expected Base32 Output |
| -------- | ---------------------- |
| ""       | "" (empty string)      |
| `f`      | `MY======`             |
| `fo`     | `MZXQ====`             |
| `foo`    | `MZXW6===`             |
| `foob`   | `MZXW6YQ=`             |
| `fooba`  | `MZXW6YTB`             |
| `foobar` | `MZXW6YTBOI======`     |

## Implementation Notes

- The implementation follows RFC 4648 specifications for Base32 encoding
- Special consideration is given to handling negative byte values in NetLinx
- Base32 uses a character set of A-Z and 2-7 (32 characters total)
- Case-insensitive decoding is supported (both 'a' and 'A' are treated the same)
- Whitespace characters (CR, LF, space, tab) are ignored during decoding
- Invalid characters generate warnings but don't cause fatal errors
- Padding characters ('=') are automatically handled during encoding and decoding
- The implementation has been thoroughly tested with a variety of inputs

## Technical Details

### Base32 Encoding Process

1. **Input Grouping**: The algorithm processes the input data in 5-byte groups (40 bits)
2. **Bit Conversion**: Each 5-byte group is converted into eight 5-bit Base32 values
3. **Character Mapping**: Each 5-bit value is mapped to a Base32 character (A-Z, 2-7)
4. **Padding**: If the input length is not divisible by 5, padding ('=') is added according to this table:

| Bytes Remaining | Base32 Chars | Padding Chars |
| --------------- | ------------ | ------------- |
| 1               | 2            | 6             |
| 2               | 4            | 4             |
| 3               | 5            | 3             |
| 4               | 7            | 1             |

### Base32 Decoding Process

1. **Character Processing**: Each input character is mapped back to its 5-bit value
2. **Bit Reconstruction**: Eight 5-bit values are combined to reconstruct five original bytes
3. **Padding Handling**: Padding characters indicate how to handle the final output bytes
4. **Case Normalization**: Lowercase characters are converted to uppercase before mapping
5. **Whitespace & Error Tolerance**: Whitespace and invalid characters are gracefully handled

## Compatibility

- This implementation is fully compatible with the Base32 specification in RFC 4648
- Output matches standard Base32 implementations on other platforms
- Base32 encoded data is widely interoperable with other systems and languages
- The decoder supports case-insensitive input for maximum compatibility
- Commonly used in TOTP/2FA applications for key representation

## Security Considerations

- Base32 is an encoding scheme, not encryption - it provides no confidentiality
- Encoded data can be easily decoded by anyone
- Base32 is commonly used for TOTP secret keys, but this is for representation only
- The case-insensitivity and restricted character set make Base32 resilient to transcription errors
- The implementation gracefully handles error conditions

### Common Use Cases

- **Appropriate Uses**:

    - Secret keys for TOTP/2FA applications
    - Case-insensitive data encoding
    - Situations where data may be manually entered or transcribed
    - DNS labels and filenames (Base32 avoids problematic characters)
    - Systems where uppercase/lowercase distinction is unreliable

- **Advantages over Base64**:
    - Case-insensitive decoding
    - Avoids characters that might be confused: 0 (zero) vs O (capital o), 1 (one) vs l (lowercase L)
    - Contains no special characters that might cause issues in URLs, filenames, or DNS labels

## See Also

The examples in this document reference these additional NAVFoundation modules:

- [NAVFoundation.Encoding.Base64.axi](NAVFoundation.Encoding.Base64.md) - Another encoding scheme with different characteristics:

    - More compact encoding (33% size increase vs 60% for Base32)
    - Case-sensitive
    - Uses special characters (+ and /)

- [NAVFoundation.Core.axi](../Core/NAVFoundation.Core.md) - Provides core functionality including:
    - Constants like `NAV_MAX_BUFFER`
    - Basic utility functions
