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

#### NAVSha256GetHash

```
define_function char[32] NAVSha256GetHash(char value[])
```

**Description:** Computes the SHA-256 hash of the input string and returns a 32-byte binary digest.

**Parameters:**

- `value` - The input string to be hashed

**Returns:**

- 32-byte binary SHA-256 hash on success
- Empty string on error

**Error Handling:**
Errors are logged through the NAVErrorLog system at NAV_LOG_LEVEL_ERROR.

## Usage Examples

### Basic Usage

```netlinx
// Import the SHA-256 module
#include 'NAVFoundation.Cryptography.Sha256.axi'
#include 'NAVFoundation.Encoding.axi'  // For hex conversion

// Define variables
define_variable
{
    char inputMessage[100]
    char binaryDigest[32]
    char hexDigest[64]
}

// Example function
define_function ComputeSha256Example()
{
    // Input message to hash
    inputMessage = 'The quick brown fox jumps over the lazy dog'

    // Compute SHA-256 hash (returns binary format)
    binaryDigest = NAVSha256GetHash(inputMessage)

    // Convert to hexadecimal string for display/use
    hexDigest = NAVByteArrayToHexString(binaryDigest)

    // Output the result
    // Should be: d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592
    send_string 0, "'SHA-256 hash: ', hexDigest"
}
```

### Verifying File Integrity

```netlinx
// Import required modules
#include 'NAVFoundation.Cryptography.Sha256.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.IO.axi'  // Assume this exists for file operations

// Define variables
define_variable
{
    char fileData[10000]
    char expectedHash[64]
    char actualHash[64]
}

// Example function to verify file integrity
define_function VerifyFileIntegrity(char filename[], char expectedHashHex[])
{
    stack_var char binaryDigest[32]

    // Read file content (implementation depends on your file I/O module)
    fileData = NAVReadFile(filename)

    if (length_array(fileData) == 0)
    {
        send_string 0, "'Error: Could not read file'"
        return
    }

    // Compute SHA-256 hash
    binaryDigest = NAVSha256GetHash(fileData)

    // Convert to hex for comparison
    actualHash = NAVByteArrayToHexString(binaryDigest)

    // Compare with expected hash
    if (actualHash == expectedHashHex)
    {
        send_string 0, "'File integrity verified successfully'"
    }
    else
    {
        send_string 0, "'File integrity check failed'"
        send_string 0, "'Expected: ', expectedHashHex"
        send_string 0, "'Actual  : ', actualHash"
    }
}
```

### Secure Password Storage Example

```netlinx
// Import required modules
#include 'NAVFoundation.Cryptography.Sha256.axi'
#include 'NAVFoundation.Encoding.axi'

// Define variables
define_variable
{
    char storedPasswordHash[64]
}

// Function to store a hashed password
define_function StorePassword(char password[])
{
    stack_var char binaryHash[32]

    // Hash the password
    binaryHash = NAVSha256GetHash(password)

    // Convert to hex for storage
    storedPasswordHash = NAVByteArrayToHexString(binaryHash)

    send_string 0, "'Password stored securely'"
}

// Function to verify a password
define_function integer VerifyPassword(char password[])
{
    stack_var char binaryHash[32]
    stack_var char passwordHash[64]

    // Hash the input password
    binaryHash = NAVSha256GetHash(password)

    // Convert to hex for comparison
    passwordHash = NAVByteArrayToHexString(binaryHash)

    // Compare with stored hash
    if (passwordHash == storedPasswordHash)
    {
        send_string 0, "'Password verified successfully'"
        return true
    }
    else
    {
        send_string 0, "'Invalid password'"
        return false
    }
}
```

### HMAC-like Authentication Example

```netlinx
// Import required modules
#include 'NAVFoundation.Cryptography.Sha256.axi'
#include 'NAVFoundation.Encoding.axi'

// Define variables
define_variable
{
    char sharedSecret[100]
}

// Function to generate an authentication token
define_function char[64] GenerateAuthToken(char message[])
{
    stack_var char combinedData[200]
    stack_var char binaryHash[32]

    // Combine the message with a shared secret
    combinedData = "sharedSecret, ':', message"

    // Compute the hash
    binaryHash = NAVSha256GetHash(combinedData)

    // Return the hex representation
    return NAVByteArrayToHexString(binaryHash)
}

// Function to verify an authentication token
define_function integer VerifyAuthToken(char message[], char token[])
{
    stack_var char expectedToken[64]

    // Generate the expected token
    expectedToken = GenerateAuthToken(message)

    // Compare with the provided token
    if (expectedToken == token)
    {
        send_string 0, "'Token verified successfully'"
        return true
    }
    else
    {
        send_string 0, "'Invalid token'"
        return false
    }
}
```

## Reference Values

For testing purposes, here are some test vectors for SHA-256:

| Input                                         | Expected SHA-256 Hash                                            |
| --------------------------------------------- | ---------------------------------------------------------------- |
| "" (empty string)                             | e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 |
| "abc"                                         | ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad |
| "abcdbcdecdefdefgefghfghighijhijkijkljklm"    | 41c0dba2a9d6240849100376a8235e2c82e1b9998a999e21db32dd97496d3376 |
| "The quick brown fox jumps over the lazy dog" | d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592 |

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
