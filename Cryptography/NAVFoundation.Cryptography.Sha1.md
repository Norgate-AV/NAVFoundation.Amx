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
// Include the SHA-1 library
#include 'NAVFoundation.Cryptography.Sha1.axi'
#include 'NAVFoundation.Encoding.axi'  // For hex conversion

// Example function
define_function ComputeSha1Example() {
    stack_var char message[100]
    stack_var char digest[20]
    stack_var char hash[40]

    // Input message to hash
    message = 'The quick brown fox jumps over the lazy dog'

    // Compute SHA-1 hash (returns binary format)
    digest = NAVSha1GetHash(message)

    // Check for errors
    if (!length_array(digest)) {
        send_string 0, "'Error: Hash computation failed'"
        return
    }

    // Convert to hexadecimal string for display/use
    hash = NAVHexToString(digest)

    // Output the result
    // Should be: 2fd4e1c67a2d28fced849ee1bb76e7391b93eb12
    send_string 0, "'SHA-1 hash: ', hash"
}
```

### Verifying File Integrity

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Sha1.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.FileUtils.axi'

// Example function to verify file integrity
define_function VerifyFileIntegrityWithSha1(char path[], char expectedHash[]) {
    stack_var char digest[20]
    stack_var char data[10000]  // Adjust size as needed
    stack_var char actualHash[40]

    // Read file content
    if (NAVFileRead(path, data) < 0) {
        send_string 0, "'Error: Could not read file'"
        return
    }

    // Compute SHA-1 hash
    digest = NAVSha1GetHash(data)

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

### Password Storage Example

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Sha1.axi'
#include 'NAVFoundation.Encoding.axi'

// Define variables
DEFINE_VARIABLE

volatile char storedPasswordHash[40]

// Function to store a hashed password
define_function StorePasswordWithSha1(char password[]) {
    stack_var char digest[20]

    // Hash the password
    digest = NAVSha1GetHash(password)

    // Convert to hex for storage
    storedPasswordHash = NAVHexToString(digest)

    send_string 0, "'Password stored securely'"
}

// Function to verify a password
define_function char VerifyPasswordWithSha1(char password[]) {
    stack_var char digest[20]
    stack_var char hash[40]

    // Hash the input password
    digest = NAVSha1GetHash(password)

    // Convert to hex for comparison
    hash = NAVHexToString(digest)

    // Compare with stored hash
    if (hash == storedPasswordHash) {
        send_string 0, "'Password verified successfully'"
        return true
    } else {
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
- Widely supported across programming languages and platforms for interoperability

## See Also

The examples in this document reference these additional NAVFoundation modules:

- [NAVFoundation.Encoding.axi](../Encoding/NAVFoundation.Encoding.md) - Provides conversion utilities including:

    - `NAVHexToString()` - Converts binary data to hexadecimal string representation
    - `NAVByteArrayToHexString()` - Alternative function for hex string conversion

- [NAVFoundation.FileUtils.axi](../FileUtils/NAVFoundation.FileUtils.md) - Provides file operations including:

    - `NAVFileRead()` - Reads data from a file into a buffer

- [NAVFoundation.Cryptography.Sha256.axi](NAVFoundation.Cryptography.Sha256.md) - Recommended alternative to SHA-1 for security-critical applications

These modules are required dependencies when using the code examples provided in this document.
