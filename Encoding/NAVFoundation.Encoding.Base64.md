# NAVFoundation.Encoding.Base64

## Overview

The Base64 implementation provides encoding and decoding functionality based on RFC 4648. Base64 encoding is used to represent binary data in an ASCII string format by translating it into a radix-64 representation, making it suitable for transmission over text-based protocols.

Base64 is commonly used in various applications including:

- Encoding binary data in MIME (email) messages
- Storing complex data in XML or JSON
- Embedding binary data in URL parameters
- Encoding binary files for transfer in plain text environments

Key features of this implementation include:

- Full compliance with RFC 4648 standard Base64 encoding
- Support for both encoding and decoding operations
- Proper handling of padding characters
- Whitespace tolerance during decoding
- Robust error handling for invalid inputs
- Correct processing of binary data, including negative byte values in NetLinx

## API Reference

### Main Functions

#### `NAVBase64Encode`

```netlinx
define_function char[NAV_MAX_BUFFER] NAVBase64Encode(char value[])
```

**Description:** Encodes binary data into a Base64 string representation.

**Parameters:**

- `value` - The binary data to be encoded

**Returns:**

- Base64 encoded string
- Original input if the input is empty

#### `NAVBase64Decode`

```netlinx
define_function char[NAV_MAX_BUFFER] NAVBase64Decode(char value[])
```

**Description:** Decodes a Base64 encoded string back to its original binary form.

**Parameters:**

- `value` - The Base64 encoded string

**Returns:**

- Decoded binary data
- Original input if the input is empty

### Helper Functions

#### `NAVBase64GetCharValue`

```netlinx
define_function sinteger NAVBase64GetCharValue(char c)
```

**Description:** Gets the 6-bit value for a Base64 character.

**Parameters:**

- `c` - A character from a Base64 encoded string

**Returns:**

- Integer value (0-63) corresponding to the character's position in the Base64 alphabet
- Special value `NAV_BASE64_INVALID_VALUE` (-1) for invalid or ignored characters

## Usage Examples

### Basic Encoding and Decoding

```netlinx
// Include the Base64 library
#include 'NAVFoundation.Encoding.Base64.axi'

// Example function
define_function ExampleBase64Usage() {
    stack_var char originalData[100]
    stack_var char encodedData[NAV_MAX_BUFFER]
    stack_var char decodedData[NAV_MAX_BUFFER]

    // Sample data to encode
    originalData = 'Hello, World!'

    // Encode the data to Base64
    encodedData = NAVBase64Encode(originalData)

    // Output the encoded result
    // Should be: "SGVsbG8sIFdvcmxkIQ=="
    send_string 0, "'Base64 encoded: ', encodedData"

    // Decode the Base64 string back to the original data
    decodedData = NAVBase64Decode(encodedData)

    // Verify the result
    if (decodedData == originalData) {
        send_string 0, "'Successfully decoded back to original data'"
    } else {
        send_string 0, "'Decoding error: results don''t match'"
    }
}
```

### Handling Binary Data

```netlinx
// Include the Base64 library
#include 'NAVFoundation.Encoding.Base64.axi'

// Example function for encoding binary data
define_function ExampleBinaryEncoding() {
    stack_var char binaryData[10]
    stack_var char encodedData[NAV_MAX_BUFFER]
    stack_var char decodedData[NAV_MAX_BUFFER]

    // Create binary data including negative values in NetLinx
    binaryData = "$00, $01, $02, $FF, $FE, $FD, $80, $90, $A0, $B0"

    // Encode the binary data to Base64
    encodedData = NAVBase64Encode(binaryData)

    // Output the encoded result
    send_string 0, "'Binary data encoded: ', encodedData"

    // Decode back to binary
    decodedData = NAVBase64Decode(encodedData)

    // Compare lengths for verification
    if (length_array(decodedData) == length_array(binaryData)) {
        send_string 0, "'Binary data length preserved: ', itoa(length_array(decodedData)), ' bytes'"
    }
}
```

### Working with Files

```netlinx
// Include required libraries
#include 'NAVFoundation.Encoding.Base64.axi'
#include 'NAVFoundation.FileUtils.axi'

// Example function to encode a file to Base64
define_function char[NAV_MAX_BUFFER] EncodeFileToBase64(char filePath[]) {
    stack_var char fileContents[NAV_MAX_BUFFER]
    stack_var char encodedData[NAV_MAX_BUFFER]

    // Read the file contents
    if (NAVFileRead(filePath, fileContents) < 0) {
        send_string 0, "'Error: Could not read file'"
        return ''
    }

    // Encode the file contents to Base64
    encodedData = NAVBase64Encode(fileContents)

    return encodedData
}

// Example function to decode Base64 and save to file
define_function SaveBase64ToFile(char encodedData[], char filePath[]) {
    stack_var char decodedData[NAV_MAX_BUFFER]

    // Decode the Base64 data
    decodedData = NAVBase64Decode(encodedData)

    // Write the decoded data to file
    if (NAVFileWrite(filePath, decodedData) < 0) {
        send_string 0, "'Error: Could not write file'"
        return
    }

    send_string 0, "'File saved successfully'"
}
```

### Handling Whitespace in Base64 Input

```netlinx
// Include the Base64 library
#include 'NAVFoundation.Encoding.Base64.axi'

// Example function showing whitespace tolerance
define_function ExampleWhitespaceHandling() {
    stack_var char encodedWithWhitespace[500]
    stack_var char decodedData[NAV_MAX_BUFFER]
    stack_var char originalText[100]

    originalText = 'The quick brown fox jumps over the lazy dog.'

    // Base64 with whitespace (spaces, line breaks)
    encodedWithWhitespace = 'VGhlIHF1aW
    NrIGJyb3du
    IGZveCBqdW1w
    cyBvdmVyIHRo
    ZSBsYXp5IGRv
    Zy4='

    // Decode - the implementation automatically handles whitespace
    decodedData = NAVBase64Decode(encodedWithWhitespace)

    // Verify result
    if (decodedData == originalText) {
        send_string 0, "'Successfully decoded Base64 with whitespace'"
    } else {
        send_string 0, "'Error decoding Base64 with whitespace'"
    }
}
```

## Reference Values

For testing purposes, here are some test vectors for Base64:

| Input                     | Expected Base64 Output             |
| ------------------------- | ---------------------------------- |
| "" (empty string)         | "" (empty string)                  |
| `a`                       | `YQ==`                             |
| `abc`                     | `YWJj`                             |
| `Hello, World!`           | `SGVsbG8sIFdvcmxkIQ==`             |
| `Man is distinguished...` | `TWFuIGlzIGRpc3Rpbmd1aXNoZWQuLi4=` |
| `The quick brown fox...`  | `VGhlIHF1aWNrIGJyb3duIGZveC4uLg==` |
| Binary: `"$00, $01, $02"` | `AP/+`                             |

## Implementation Notes

- The implementation follows RFC 4648 specifications for Base64 encoding
- Special consideration is given to handling negative byte values in NetLinx
- Whitespace characters (CR, LF, space, tab) are ignored during decoding
- Invalid characters generate warnings but don't cause fatal errors
- Padding characters ('=') are automatically handled during encoding and decoding
- The implementation has been thoroughly tested with a variety of inputs including:
    - Empty strings
    - ASCII text
    - Binary data with special bytes
    - Various edge cases

## Technical Details

### Base64 Encoding Process

1. **Input Grouping**: The algorithm processes the input data in 3-byte groups (24 bits)
2. **Bit Conversion**: Each 3-byte group is converted into four 6-bit Base64 values
3. **Character Mapping**: Each 6-bit value is mapped to a Base64 character (A-Z, a-z, 0-9, +, /)
4. **Padding**: If the input length is not divisible by 3, padding ('=') is added:
    - 1 byte remaining: Two Base64 characters + "=="
    - 2 bytes remaining: Three Base64 characters + "="

### Base64 Decoding Process

1. **Character Processing**: Each input character is mapped back to its 6-bit value
2. **Bit Reconstruction**: Four 6-bit values are combined to reconstruct three original bytes
3. **Padding Handling**: Padding characters indicate how to handle the final output bytes
4. **Whitespace & Error Tolerance**: Whitespace and invalid characters are gracefully handled

## Compatibility

- This implementation is fully compatible with the Base64 specification in RFC 4648
- Output matches standard Base64 implementations on other platforms
- Base64 encoded data is widely interoperable with other systems and languages
- The decoder is tolerant of common formatting variations (whitespace, line breaks)

## Security Considerations

While Base64 is not an encryption method, it's important to understand its security implications:

- Base64 is an encoding scheme, not encryption - it provides no confidentiality
- Encoded data can be easily decoded by anyone
- Base64 should not be used to hide or secure sensitive information
- The implementation resists error conditions but is not designed to be secure against malicious inputs

### Common Use Cases

- **Appropriate Uses**:

    - Safely transferring binary data in text-based protocols
    - Embedding binary data in text formats like XML or JSON
    - Storing binary data in environments that don't handle binary well

- **Inappropriate Uses**:
    - Hiding sensitive information
    - Password protection
    - Any form of security mechanism

## See Also

The examples in this document reference these additional NAVFoundation modules:

- [NAVFoundation.FileUtils.axi](../FileUtils/NAVFoundation.FileUtils.md) - Provides file operations including:

    - `NAVFileRead()` - Reads data from a file into a buffer
    - `NAVFileWrite()` - Writes data to a file

- [NAVFoundation.Core.axi](../Core/NAVFoundation.Core.md) - Provides core functionality including:

    - Constants like `NAV_MAX_BUFFER`
    - Basic utility functions

- [NAVFoundation.Cryptography.Sha512.axi](../Cryptography/NAVFoundation.Cryptography.Sha512.md) - Can be used together with Base64 for secure hashing and representation
