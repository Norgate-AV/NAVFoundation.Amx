# NAVFoundation.Cryptography.Sha256

## Overview

The SHA-256 (Secure Hash Algorithm 256) implementation provides cryptographic hash functionality based on RFC6234. This module generates a 256-bit (32-byte) message digest from input data, typically represented as a 64-character hexadecimal string.

SHA-256 is part of the SHA-2 family of cryptographic hash functions, designed by the NSA. It offers significantly stronger security compared to SHA-1, making it suitable for security-critical applications.

Key features of SHA-256 include:

- 256-bit (32-byte) output digest
- Collision resistance suitable for current security requirements
- Widely used in digital signatures, TLS certificates, and blockchain technologies
- Standardized in FIPS PUB 180-4

## API Reference

### Main Functions

#### `NAVSha256GetHash`

```netlinx
define_function char[32] NAVSha256GetHash(char value[])
```

**Description:** Computes the SHA-256 hash of the input string and returns a 32-byte binary digest.

**Parameters:**

- `value` - The input string to be hashed

**Returns:**

- 32-byte binary SHA-256 hash on success
- Empty string on error

## Usage Examples

### Basic Usage

```netlinx
// Include the SHA-256 library
#include 'NAVFoundation.Cryptography.Sha256.axi'
#include 'NAVFoundation.Encoding.axi'  // For hex conversion

// Example function
define_function ComputeSha256Example() {
    stack_var char message[100]
    stack_var char digest[32]
    stack_var char hash[64]

    // Input message to hash
    message = 'The quick brown fox jumps over the lazy dog'

    // Compute SHA-256 hash (returns binary format)
    digest = NAVSha256GetHash(message)

    // Check for errors
    if (!length_array(digest)) {
        send_string 0, "'Error: Hash computation failed'"
        return
    }

    // Convert to hexadecimal string for display/use
    hash = NAVHexToString(digest)

    // Output the result
    // Should be: d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592
    send_string 0, "'SHA-256 hash: ', hash"
}
```

### Verifying File Integrity

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Sha256.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.FileUtils.axi'

// Example function to verify file integrity
define_function VerifyFileIntegrity(char path[], char expectedHash[]) {
    stack_var char digest[32]
    stack_var char data[1024]  // Adjust size as needed
    stack_var char actualHash[64]

    if (NAVFileRead(path, data) < 0) {
        send_string 0, "'Error: Could not read file'"
        return
    }

    // Compute SHA-256 hash
    digest = NAVSha256GetHash(data)

    // Convert to hex for comparison
    actualHash = NAVHexToString(digest)

    // Compare with expected hash
    if (actualHash == expectedHash) {
        send_string 0, "'File integrity verified successfully'"
    } else {
        send_string 0, "'File integrity check failed'"
        send_string 0, "'Expected: ', expectedHash"
        send_string 0, "'Actual  : ', actualHash"
    }
}
```

### Secure Password Storage Example

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Sha256.axi'
#include 'NAVFoundation.Encoding.axi'

// Define variables
DEFINE_VARIABLE

volatile char passwordHash[64]

// Function to store a hashed password
define_function StorePassword(char password[]) {
    stack_var char digest[32]

    // Hash the password
    digest = NAVSha256GetHash(password)

    // Convert to hex for storage
    passwordHash = NAVHexToString(digest)

    send_string 0, "'Password stored securely'"
}

// Function to verify a password
define_function char VerifyPassword(char password[]) {
    stack_var char digest[32]
    stack_var char hash[64]

    // Hash the input password
    digest = NAVSha256GetHash(password)

    // Convert to hex for comparison
    hash = NAVHexToString(digest)

    // Compare with stored hash
    if (hash == passwordHash) {
        send_string 0, "'Password verified successfully'"
        return true
    } else {
        send_string 0, "'Invalid password'"
        return false
    }
}
```

### HMAC-like Authentication Example

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Sha256.axi'
#include 'NAVFoundation.Encoding.axi'

// Define constants
DEFINE_CONSTANT

constant char SECRET[] = 'sharedSecret123'


// Function to generate an authentication token
define_function char[64] GenerateAuthToken(char message[]) {
    stack_var char data[200]
    stack_var char digest[32]

    // Combine the message with a shared secret
    data = "SECRET, ':', message"

    // Compute the hash
    digest = NAVSha256GetHash(data)

    // Return the hex representation
    return NAVHexToString(digest)
}

// Function to verify an authentication token
define_function char VerifyAuthToken(char message[], char token[]) {
    stack_var char expectedToken[64]

    // Generate the expected token
    expectedToken = GenerateAuthToken(message)

    // Compare with the provided token
    if (expectedToken == token) {
        send_string 0, "'Token verified successfully'"
        return true
    } else {
        send_string 0, "'Invalid token'"
        return false
    }
}
```

## Reference Values

For testing purposes, here are some test vectors for SHA-256:

| Input                                         | Expected SHA-256 Hash                                              |
| --------------------------------------------- | ------------------------------------------------------------------ |
| "" (empty string)                             | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `abc`                                         | `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad` |
| `abcdbcdecdefdefgefghfghighijhijkijkljklm`    | `41c0dba2a9d6240849100376a8235e2c82e1b9998a999e21db32dd97496d3376` |
| `The quick brown fox jumps over the lazy dog` | `d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592` |

## Implementation Notes

- The implementation follows RFC6234 specifications
- The NAVSha256 functions return binary digests (byte arrays)
- Use NAVByteArrayToHexString from NAVFoundation.Encoding to convert to hexadecimal strings
- Maximum input size is limited by the NetLinx string capacity
- Performance may degrade with large inputs due to string handling limitations in NetLinx

## Security Advantages Over SHA-1

SHA-256 offers several security advantages over SHA-1:

- Produces a 256-bit (32-byte) digest compared to SHA-1's 160-bit digest
- No known practical collision attacks (unlike SHA-1)
- Resistant against length extension attacks when properly implemented
- Recommended by NIST and other security organizations for current applications
- Suitable for security-critical applications including digital signatures and certificate validation

## Compatibility

- This implementation is fully compatible with the SHA-256 specification in RFC6234
- Output matches standard SHA-256 implementations on other platforms
- Widely supported across programming languages and platforms for interoperability

## See Also

The examples in this document reference these additional NAVFoundation modules:

- [NAVFoundation.Encoding.axi](../Encoding/NAVFoundation.Encoding.md) - Provides conversion utilities including:

    - `NAVHexToString()` - Converts binary data to hexadecimal string representation
    - `NAVByteArrayToHexString()` - Alternative function for hex string conversion

- [NAVFoundation.FileUtils.axi](../FileUtils/NAVFoundation.FileUtils.md) - Provides file operations including:
    - `NAVFileRead()` - Reads data from a file into a buffer

These modules are required dependencies when using the code examples provided in this document.
