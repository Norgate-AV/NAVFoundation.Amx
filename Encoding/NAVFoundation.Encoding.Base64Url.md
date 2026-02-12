# NAVFoundation.Encoding.Base64Url

## Overview

The Base64Url implementation provides URL-safe encoding and decoding functionality based on RFC 4648 Section 5. Base64Url is a variant of Base64 that uses a URL and filename safe alphabet, making it suitable for use in URLs, filenames, and web-based applications without requiring percent-encoding.

The key difference between standard Base64 and Base64Url is the character set used:

| Character | Standard Base64 | Base64Url   |
| --------- | --------------- | ----------- |
| 62nd      | `+`             | `-`         |
| 63rd      | `/`             | `_`         |
| Padding   | `=`             | `=` or none |

Base64Url is commonly used in:

- **JSON Web Tokens (JWT)** - RFC 7515 and RFC 7519 require Base64Url encoding without padding
- URL parameters without requiring percent-encoding
- Filenames on case-sensitive or restricted filesystems
- Cookie values and HTTP headers
- OAuth and OpenID Connect tokens
- API keys and authentication tokens

Key features of this implementation include:

- Full compliance with RFC 4648 Section 5 (URL-safe Base64)
- Support for both padded and unpadded encoding (JWT default is unpadded)
- Automatic padding restoration during decoding
- Conversion functions between standard Base64 and Base64Url
- Robust error handling for invalid inputs
- Optimized for JWT token generation and validation

## Why Base64Url?

Standard Base64 uses `+` and `/` characters which have special meanings in URLs:

- `+` is interpreted as a space in URL query parameters
- `/` is a path separator
- `=` padding can cause issues in some contexts

Base64Url solves these problems by using `-` and `_` which are unreserved characters in URLs (RFC 3986), eliminating the need for percent-encoding.

### JWT Requirements

JSON Web Tokens (JWTs) specifically require Base64Url encoding **without padding** for the header and payload sections. This implementation provides `NAVBase64UrlEncode()` as the default encoding function that omits padding, making it ideal for JWT creation.

## API Reference

### Main Functions

#### `NAVBase64UrlEncode`

```netlinx
define_function char[NAV_MAX_BUFFER] NAVBase64UrlEncode(char value[])
```

**Description:** Encodes binary data into a Base64Url string representation **without padding**. This is the standard encoding method for JWT tokens.

**Parameters:**

- `value` - The binary data to be encoded

**Returns:**

- Base64Url encoded string without padding characters
- Original input if the input is empty

**Usage:** Use this function for JWT token generation and any application requiring unpadded Base64Url encoding.

#### `NAVBase64UrlEncodePadded`

```netlinx
define_function char[NAV_MAX_BUFFER] NAVBase64UrlEncodePadded(char value[])
```

**Description:** Encodes binary data into a Base64Url string representation **with padding**. This is useful when interoperating with systems that require padding.

**Parameters:**

- `value` - The binary data to be encoded

**Returns:**

- Base64Url encoded string with padding characters (`=`)
- Original input if the input is empty

**Usage:** Use this function when you need Base64Url with explicit padding characters.

#### `NAVBase64UrlDecode`

```netlinx
define_function char[NAV_MAX_BUFFER] NAVBase64UrlDecode(char value[])
```

**Description:** Decodes a Base64Url encoded string back to its original binary form. Automatically adds padding if missing, so it can decode both padded and unpadded Base64Url strings.

**Parameters:**

- `value` - The Base64Url encoded string (with or without padding)

**Returns:**

- Decoded binary data
- Original input if the input is empty

**Usage:** Use this function to decode any Base64Url string, including JWT tokens which typically omit padding.

### Conversion Functions

#### `NAVBase64ToBase64Url`

```netlinx
define_function char[NAV_MAX_BUFFER] NAVBase64ToBase64Url(char base64Value[])
```

**Description:** Converts a standard Base64 encoded string to Base64Url format by replacing `+` with `-` and `/` with `_`, and optionally removing padding.

**Parameters:**

- `base64Value` - A standard Base64 encoded string

**Returns:**

- Base64Url encoded string without padding
- Original input if the input is empty

**Usage:** Use this function when you have existing Base64 data that needs to be used in URLs or JWTs.

#### `NAVBase64UrlToBase64`

```netlinx
define_function char[NAV_MAX_BUFFER] NAVBase64UrlToBase64(char base64UrlValue[])
```

**Description:** Converts a Base64Url encoded string to standard Base64 format by replacing `-` with `+` and `_` with `/`, and ensuring proper padding.

**Parameters:**

- `base64UrlValue` - A Base64Url encoded string (with or without padding)

**Returns:**

- Standard Base64 encoded string with padding
- Original input if the input is empty

**Usage:** Use this function when you need to convert Base64Url data to standard Base64 for compatibility with systems expecting standard Base64.

### Helper Functions

#### `NAVBase64UrlGetCharValue`

```netlinx
define_function sinteger NAVBase64UrlGetCharValue(char c)
```

**Description:** Gets the 6-bit value for a Base64Url character.

**Parameters:**

- `c` - A character from a Base64Url encoded string

**Returns:**

- Integer value (0-63) corresponding to the character's position in the Base64Url alphabet
- Special value `NAV_BASE64URL_INVALID_VALUE` (-1) for invalid or ignored characters

**Usage:** This is a private helper function primarily used internally during decoding. Direct usage is uncommon.

## Usage Examples

### JWT Token Encoding (Unpadded)

```netlinx
// Include the Base64Url library
#include 'NAVFoundation.Encoding.Base64Url.axi'

// Example function to create a JWT header
define_function char[NAV_MAX_BUFFER] CreateJWTHeader() {
    stack_var char header[200]
    stack_var char encodedHeader[NAV_MAX_BUFFER]

    // Create JSON header (typically {"alg":"HS256","typ":"JWT"})
    header = '{"alg":"HS256","typ":"JWT"}'

    // Encode using Base64Url WITHOUT padding (JWT requirement)
    encodedHeader = NAVBase64UrlEncode(header)

    // Result: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
    // Note: No padding characters at the end
    send_string 0, "'JWT Header: ', encodedHeader"

    return encodedHeader
}

// Example function to create a JWT payload
define_function char[NAV_MAX_BUFFER] CreateJWTPayload(char userId[], long exp) {
    stack_var char payload[500]
    stack_var char encodedPayload[NAV_MAX_BUFFER]

    // Create JSON payload
    payload = "'{',
               '"sub":"', userId, '",',
               '"exp":', itoa(exp),
               '}'"

    // Encode using Base64Url WITHOUT padding
    encodedPayload = NAVBase64UrlEncode(payload)

    send_string 0, "'JWT Payload: ', encodedPayload"

    return encodedPayload
}
```

### Basic Encoding and Decoding

```netlinx
// Include the Base64Url library
#include 'NAVFoundation.Encoding.Base64Url.axi'

// Example function demonstrating unpadded encoding/decoding
define_function ExampleBase64UrlUsage() {
    stack_var char originalData[100]
    stack_var char encodedData[NAV_MAX_BUFFER]
    stack_var char decodedData[NAV_MAX_BUFFER]

    // Sample data to encode
    originalData = 'Hello, World!'

    // Encode the data to Base64Url (no padding)
    encodedData = NAVBase64UrlEncode(originalData)

    // Output the encoded result
    // Should be: "SGVsbG8sIFdvcmxkIQ" (note: no "==" padding)
    send_string 0, "'Base64Url encoded: ', encodedData"

    // Decode the Base64Url string back to the original data
    // Decoder automatically handles missing padding
    decodedData = NAVBase64UrlDecode(encodedData)

    // Verify the result
    if (decodedData == originalData) {
        send_string 0, "'Successfully decoded back to original data'"
    } else {
        send_string 0, "'Decoding error: results don''t match'"
    }
}
```

### Padded Encoding

```netlinx
// Include the Base64Url library
#include 'NAVFoundation.Encoding.Base64Url.axi'

// Example function using padded encoding
define_function ExamplePaddedEncoding() {
    stack_var char originalData[100]
    stack_var char encodedUnpadded[NAV_MAX_BUFFER]
    stack_var char encodedPadded[NAV_MAX_BUFFER]

    originalData = 'test'

    // Encode WITHOUT padding (default for JWT)
    encodedUnpadded = NAVBase64UrlEncode(originalData)
    send_string 0, "'Unpadded: ', encodedUnpadded" // "dGVzdA"

    // Encode WITH padding (for compatibility)
    encodedPadded = NAVBase64UrlEncodePadded(originalData)
    send_string 0, "'Padded: ', encodedPadded" // "dGVzdA=="

    // Both can be decoded successfully
    send_string 0, "'Decoded unpadded: ', NAVBase64UrlDecode(encodedUnpadded)"
    send_string 0, "'Decoded padded: ', NAVBase64UrlDecode(encodedPadded)"
}
```

### Converting Between Base64 and Base64Url

```netlinx
// Include both Base64 libraries
#include 'NAVFoundation.Encoding.Base64.axi'
#include 'NAVFoundation.Encoding.Base64Url.axi'

// Example function showing conversion between formats
define_function ExampleConversion() {
    stack_var char originalData[100]
    stack_var char base64Encoded[NAV_MAX_BUFFER]
    stack_var char base64UrlEncoded[NAV_MAX_BUFFER]
    stack_var char convertedToUrl[NAV_MAX_BUFFER]
    stack_var char convertedToStd[NAV_MAX_BUFFER]

    originalData = 'Convert me?!'

    // Encode using standard Base64
    base64Encoded = NAVBase64Encode(originalData)
    send_string 0, "'Standard Base64: ', base64Encoded"
    // Result: "Q29udmVydCBtZT8h" (if it had + or /, it would show)

    // Convert to Base64Url
    convertedToUrl = NAVBase64ToBase64Url(base64Encoded)
    send_string 0, "'Converted to Base64Url: ', convertedToUrl"

    // Encode directly using Base64Url
    base64UrlEncoded = NAVBase64UrlEncode(originalData)
    send_string 0, "'Direct Base64Url: ', base64UrlEncoded"

    // These should be identical
    if (convertedToUrl == base64UrlEncoded) {
        send_string 0, "'Conversion matches direct encoding'"
    }

    // Convert back to standard Base64
    convertedToStd = NAVBase64UrlToBase64(base64UrlEncoded)
    send_string 0, "'Converted back to Base64: ', convertedToStd"

    // Should match original Base64 encoding
    if (convertedToStd == base64Encoded) {
        send_string 0, "'Round-trip conversion successful'"
    }
}
```

### URL-Safe Encoding Example

```netlinx
// Include the Base64Url library
#include 'NAVFoundation.Encoding.Base64Url.axi'

// Example showing why Base64Url is needed for URLs
define_function ExampleUrlSafeEncoding() {
    stack_var char data[100]
    stack_var char base64[NAV_MAX_BUFFER]
    stack_var char base64Url[NAV_MAX_BUFFER]
    stack_var char url[500]

    // Data that will produce + and / in standard Base64
    data = 'subjects?test=true'

    // Standard Base64 encoding
    base64 = NAVBase64Encode(data)
    send_string 0, "'Standard Base64: ', base64"
    // Might contain: "c3ViamVjdHM/dGVzdD10cnVl" (+ and / characters)

    // Base64Url encoding
    base64Url = NAVBase64UrlEncode(data)
    send_string 0, "'Base64Url: ', base64Url"
    // Will use - and _ instead: "c3ViamVjdHM_dGVzdD10cnVl"

    // Building a URL with the encoded data
    url = "'https://api.example.com/verify?token=', base64Url"
    send_string 0, "'Safe URL: ', url"
    // URL is safe to use without percent-encoding
}
```

### Handling Binary Data

```netlinx
// Include the Base64Url library
#include 'NAVFoundation.Encoding.Base64Url.axi'

// Example function for encoding binary data
define_function ExampleBinaryEncodingUrl() {
    stack_var char binaryData[10]
    stack_var char encodedData[NAV_MAX_BUFFER]
    stack_var char decodedData[NAV_MAX_BUFFER]

    // Create binary data including negative values in NetLinx
    binaryData = "$00, $01, $02, $FF, $FE, $FD, $80, $90, $A0, $B0"

    // Encode the binary data to Base64Url (no padding)
    encodedData = NAVBase64UrlEncode(binaryData)

    // Output the encoded result
    send_string 0, "'Binary data encoded: ', encodedData"

    // Decode back to binary
    decodedData = NAVBase64UrlDecode(encodedData)

    // Compare lengths for verification
    if (length_array(decodedData) == length_array(binaryData)) {
        send_string 0, "'Binary data length preserved: ', itoa(length_array(decodedData)), ' bytes'"
    }

    // Verify byte-by-byte
    stack_var integer i
    stack_var integer mismatch
    mismatch = false

    for (i = 1; i <= length_array(binaryData); i++) {
        if (binaryData[i] != decodedData[i]) {
            mismatch = true
            break
        }
    }

    if (!mismatch) {
        send_string 0, "'All bytes match - perfect round-trip'"
    }
}
```

## Reference Values

For testing purposes, here are test vectors for Base64Url:

### Standard Test Vectors

| Input             | Base64Url (no padding) | Base64Url (padded)     |
| ----------------- | ---------------------- | ---------------------- |
| "" (empty string) | ""                     | ""                     |
| `a`               | `YQ`                   | `YQ==`                 |
| `abc`             | `YWJj`                 | `YWJj`                 |
| `Hello, World!`   | `SGVsbG8sIFdvcmxkIQ`   | `SGVsbG8sIFdvcmxkIQ==` |
| `test`            | `dGVzdA`               | `dGVzdA==`             |
| `testing`         | `dGVzdGluZw`           | `dGVzdGluZw==`         |

### Character Set Differences

Input that demonstrates the difference between Base64 and Base64Url:

| Input              | Standard Base64 | Base64Url (no pad) |
| ------------------ | --------------- | ------------------ |
| `subjects?`        | `c3ViamVjdHM/`  | `c3ViamVjdHM_`     |
| `>>>???`           | `Pj4+Pz8/`      | `Pj4-Pz8_`         |
| Binary: `$FF, $FF` | `//8=`          | `__8`              |
| Binary: `$FB, $FF` | `+/8=`          | `-_8`              |

### JWT Example Vectors

| Component | Content                       | Base64Url Encoding                     |
| --------- | ----------------------------- | -------------------------------------- |
| Header    | `{"alg":"HS256","typ":"JWT"}` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9` |
| Payload   | `{"sub":"1234567890"}`        | `eyJzdWIiOiIxMjM0NTY3ODkwIn0`          |

Note: JWT tokens concatenate header.payload.signature using `.` as separator.

## Implementation Notes

- The implementation follows RFC 4648 Section 5 specifications for Base64Url encoding
- Default encoding (`NAVBase64UrlEncode`) omits padding to comply with JWT standards (RFC 7515)
- Decoding automatically handles both padded and unpadded input
- Special consideration is given to handling negative byte values in NetLinx
- The character set uses `-` (hyphen/minus) instead of `+` and `_` (underscore) instead of `/`
- Whitespace characters are ignored during decoding for robustness
- Conversion functions allow easy migration between standard Base64 and Base64Url formats
- The implementation has been thoroughly tested with:
    - Empty strings
    - ASCII text
    - Binary data with special bytes
    - JWT token components
    - Data requiring character set differences (+ / → - \_)

## Comparison: Base64 vs Base64Url

| Feature                 | Standard Base64       | Base64Url             |
| ----------------------- | --------------------- | --------------------- |
| Character 62            | `+` (plus)            | `-` (hyphen)          |
| Character 63            | `/` (slash)           | `_` (underscore)      |
| Padding                 | Always `=`            | Optional `=`          |
| URL safe                | No (needs %-encoding) | Yes                   |
| Filename safe           | No                    | Yes                   |
| JWT compatible          | No                    | Yes (without padding) |
| RFC                     | RFC 4648              | RFC 4648 Section 5    |
| Use in query parameters | Requires encoding     | Direct use            |

## When to Use Which Encoding

### Use Base64Url When:

- Creating or parsing JWT tokens
- Embedding data in URLs or query parameters
- Storing data in filenames
- Working with web APIs that expect URL-safe encoding
- Cookie values or HTTP headers with URL content
- OAuth tokens or API keys

### Use Standard Base64 When:

- MIME/email encoding (RFC 2045)
- Data URIs (e.g., `data:image/png;base64,`)
- XML or JSON embedded binary data
- Legacy systems expecting standard Base64
- PEM-encoded certificates or keys

### Converting Between Formats

Use `NAVBase64ToBase64Url()` and `NAVBase64UrlToBase64()` when you need to:

- Interface between systems using different encoding standards
- Convert legacy Base64 data for use in modern web APIs
- Migrate existing data to URL-safe format
- Debug encoding issues by comparing both formats

## Technical Details

### Character Map

The Base64Url character map is defined in `NAVFoundation.Encoding.Base64Url.h.axi`:

```netlinx
NAV_BASE64URL_MAP = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
                    'abcdefghijklmnopqrstuvwxyz' +
                    '0123456789-_'
```

Positions 0-61 match standard Base64, but positions 62 and 63 use `-` and `_` instead of `+` and `/`.

### Padding Behavior

- **Unpadded encoding** (default): Used by JWT. Length not divisible by 4 is acceptable.
- **Padded encoding**: Adds `=` characters to make length divisible by 4 for compatibility.
- **Decoding**: Automatically calculates and adds missing padding if needed.

### Padding Calculation

The decoder calculates required padding:

```netlinx
switch (length_array(value) % 4) {
    case 2: value = "value, '=='"  // Add 2 padding chars
    case 3: value = "value, '='"   // Add 1 padding char
}
```

## Security Considerations

- Base64Url encoding is **not encryption** - it only transforms data representation
- Encoded data is easily decoded and should not be considered secure
- Use proper encryption (AES, RSA) or signatures (HMAC, JWT) for security
- JWT tokens should always be validated with proper signature verification
- Do not expose sensitive data in JWT payloads without encryption
- Always validate decoded data before use to prevent injection attacks

## Related Libraries

- **NAVFoundation.Encoding.Base64** - Standard Base64 encoding (RFC 4648)
- **NAVFoundation.Encoding.Base32** - Base32 encoding for case-insensitive systems
- **NAVFoundation.Cryptography.Hmac** - HMAC signatures for JWT
- **NAVFoundation.Json** - JSON parsing for JWT payloads

## References

- RFC 4648 - The Base16, Base32, and Base64 Data Encodings
- RFC 4648 Section 5 - Base64url Encoding
- RFC 7515 - JSON Web Signature (JWS)
- RFC 7519 - JSON Web Token (JWT)
- RFC 3986 - Uniform Resource Identifier (URI): Generic Syntax
