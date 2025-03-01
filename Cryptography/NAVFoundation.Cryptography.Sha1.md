# NAVFoundation.Cryptography.Sha1

## Overview

The SHA-1 (Secure Hash Algorithm 1) implementation provides cryptographic hash functionality based on RFC3174. This module generates a 160-bit (20-byte) message digest from input data, typically represented as a 40-character hexadecimal string.

While SHA-1 is no longer considered secure for cryptographic signature purposes, it remains useful for:

- Data integrity verification
- Non-security critical checksums
- Legacy system compatibility

## Security Notice

**Important:** SHA-1 has been deprecated for security-sensitive applications. Known vulnerabilities include collision attacks. For security-critical applications, consider using SHA-256 or higher.

## API Reference

### Main Functions

#### NAVSha1GetHash

```
define_function char[20] NAVSha1GetHash(char value[])
```

**Description:** Computes the SHA-1 hash of the input string and returns a 20-byte binary digest.

**Parameters:**

- `value` - The input string to be hashed

**Returns:**

- 20-byte binary SHA-1 hash on success
- Empty string on error

**Error Handling:**
Errors are logged through the NAVErrorLog system at NAV_LOG_LEVEL_ERROR.

## Usage Examples

### Basic Usage

```netlinx
// Import the SHA-1 module
#include 'NAVFoundation.Cryptography.Sha1.axi'
#include 'NAVFoundation.Encoding.axi'  // For hex conversion

// Define variables
define_variable
{
    char inputMessage[100]
    char binaryDigest[20]
    char hexDigest[40]
}

// Example function
define_function ComputeSha1Example()
{
    // Input message to hash
    inputMessage = 'The quick brown fox jumps over the lazy dog'

    // Compute SHA-1 hash (returns binary format)
    binaryDigest = NAVSha1GetHash(inputMessage)

    // Convert to hexadecimal string for display/use
    hexDigest = NAVByteArrayToHexString(binaryDigest)

    // Output the result
    // Should be: 2fd4e1c67a2d28fced849ee1bb76e7391b93eb12
    send_string 0, "'SHA-1 hash: ', hexDigest"
}
```

### Verifying File Integrity

```netlinx
// Import required modules
#include 'NAVFoundation.Cryptography.Sha1.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.IO.axi'  // Assume this exists for file operations

// Define variables
define_variable
{
    char fileData[10000]
    char expectedHash[40]
    char actualHash[40]
}

// Example function to verify file integrity
define_function VerifyFileIntegrity(char filename[], char expectedHashHex[])
{
    stack_var char binaryDigest[20]

    // Read file content (implementation depends on your file I/O module)
    fileData = NAVReadFile(filename)

    if (length_array(fileData) == 0)
    {
        send_string 0, "'Error: Could not read file'"
        return
    }

    // Compute SHA-1 hash
    binaryDigest = NAVSha1GetHash(fileData)

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

### Password Storage Example

```netlinx
// Import required modules
#include 'NAVFoundation.Cryptography.Sha1.axi'
#include 'NAVFoundation.Encoding.axi'

// Define variables
define_variable
{
    char storedPasswordHash[40]
}

// Function to store a hashed password
define_function StorePassword(char password[])
{
    stack_var char binaryHash[20]

    // Hash the password
    binaryHash = NAVSha1GetHash(password)

    // Convert to hex for storage
    storedPasswordHash = NAVByteArrayToHexString(binaryHash)

    send_string 0, "'Password stored securely'"
}

// Function to verify a password
define_function integer VerifyPassword(char password[])
{
    stack_var char binaryHash[20]
    stack_var char passwordHash[40]

    // Hash the input password
    binaryHash = NAVSha1GetHash(password)

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

## Reference Values

For testing purposes, here are some test vectors:

| Input                                                      | Expected SHA-1 Hash                      |
| ---------------------------------------------------------- | ---------------------------------------- |
| "" (empty string)                                          | da39a3ee5e6b4b0d3255bfef95601890afd80709 |
| "abc"                                                      | a9993e364706816aba3e25717850c26c9cd0d89d |
| "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" | 84983e441c3bd26ebaae4aa1f95129e5e54670f1 |
| "The quick brown fox jumps over the lazy dog"              | 2fd4e1c67a2d28fced849ee1bb76e7391b93eb12 |

## Implementation Notes

- The implementation follows RFC3174 specifications
- The NAVSha1 functions return binary digests (byte arrays)
- Use NAVByteArrayToHexString from NAVFoundation.Encoding to convert to hexadecimal strings
- Maximum input size is limited by the NetLinx string capacity
- Performance may degrade with large inputs due to string handling limitations in NetLinx

## Compatibility

- This implementation is fully compatible with the SHA-1 specification in RFC3174
- Output matches standard SHA-1 implementations on other platforms
