# NAVFoundation.Cryptography.Sha384

## Overview

The SHA-384 (Secure Hash Algorithm 384) implementation provides cryptographic hash functionality based on RFC6234. This module generates a 384-bit (48-byte) message digest from input data, typically represented as a 96-character hexadecimal string.

SHA-384 is part of the SHA-2 family of cryptographic hash functions, designed by the NSA. It is essentially a truncated version of SHA-512, using different initial hash values and outputting only the first 384 bits of the result.

Key features of SHA-384 include:

- 384-bit (48-byte) output digest
- Excellent collision resistance, stronger than SHA-256 but more compact than SHA-512
- Built on 64-bit operations (same algorithm as SHA-512)
- Used in security-critical applications requiring strong cryptographic strength
- Standardized in FIPS PUB 180-4

## API Reference

### Main Functions

#### `NAVSha384GetHash`

```netlinx
define_function char[48] NAVSha384GetHash(char value[])
```

**Description:** Computes the SHA-384 hash of the input string and returns a 48-byte binary digest.

**Parameters:**

- `value` - The input string to be hashed

**Returns:**

- 48-byte binary SHA-384 hash on success
- Empty string on error

## Usage Examples

### Basic Usage

```netlinx
// Include the SHA-384 library
#include 'NAVFoundation.Cryptography.Sha384.axi'
#include 'NAVFoundation.Encoding.axi'  // For hex conversion

// Example function
define_function ComputeSha384Example() {
    stack_var char message[100]
    stack_var char digest[48]
    stack_var char hash[96]

    // Input message to hash
    message = 'The quick brown fox jumps over the lazy dog'

    // Compute SHA-384 hash (returns binary format)
    digest = NAVSha384GetHash(message)

    // Check for errors
    if (!length_array(digest)) {
        send_string 0, "'Error: Hash computation failed'"
        return
    }

    // Convert to hexadecimal string for display/use
    hash = NAVByteArrayToHexString(digest)

    // Output the result
    // Should be: ca737f1014a48f4c0b6dd43cb177b0afd9e5169367544c494011e3317dbf9a509cb1e5dc1e85a941bbee3d7f2afbc9b1
    send_string 0, "'SHA-384 hash: ', hash"
}
```

### Verifying File Integrity

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Sha384.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.FileUtils.axi'  // For file operations

// Example function to verify file integrity
define_function VerifyFileIntegrity(char path[], char expectedHash[]) {
    stack_var char digest[48]
    stack_var char data[10000]  // Adjust size as needed
    stack_var char actualHash[96]

    // Read file content
    if (NAVFileRead(path, data) < 0) {
        send_string 0, "'Error: Could not read file'"
        return
    }

    // Compute SHA-384 hash
    digest = NAVSha384GetHash(data)

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

### Secure Password Storage

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Sha384.axi'
#include 'NAVFoundation.Encoding.axi'

// Define variables
DEFINE_VARIABLE

volatile char storedPasswordHash[96]
volatile char salt[16]  // Random salt for added security

// Function to generate a salt (placeholder - use a proper random generator)
define_function char[16] GenerateSalt() {
    // In a real implementation, this should be cryptographically random
    // This is just a placeholder
    return "$01,$23,$45,$67,$89,$AB,$CD,$EF,$FE,$DC,$BA,$98,$76,$54,$32,$10"
}

// Function to store a hashed password with salt
define_function StorePassword(char password[]) {
    stack_var char digest[48]
    stack_var char salted_password[1000]

    // Generate a new salt
    salt = GenerateSalt()

    // Combine password with salt
    salted_password = "salt, password"

    // Hash the salted password
    digest = NAVSha384GetHash(salted_password)

    // Convert to hex for storage
    storedPasswordHash = NAVHexToString(digest)

    send_string 0, "'Password stored securely with salt'"
}

// Function to verify a password
define_function char VerifyPassword(char password[]) {
    stack_var char digest[48]
    stack_var char passwordHash[96]
    stack_var char salted_password[1000]

    // Combine provided password with stored salt
    salted_password = "salt, password"

    // Hash the salted password
    digest = NAVSha384GetHash(salted_password)

    // Convert to hex for comparison
    passwordHash = NAVHexToString(digest)

    // Compare with stored hash
    if (passwordHash == storedPasswordHash) {
        send_string 0, "'Password verified successfully'"
        return true
    } else {
        send_string 0, "'Invalid password'"
        return false
    }
}
```

<!-- ### Digital Signature Verification Example

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Sha384.axi'
#include 'NAVFoundation.Encoding.axi'

// Note: This example assumes the existence of a digital signature verification function
// that would use the hash as input. The actual signature verification would involve
// public key cryptography which is beyond the scope of this example.

// Function to verify a digitally signed message
define_function char VerifySignedMessage(char message[], char signature[]) {
    stack_var char messageHash[48]

    // Compute the hash of the message
    messageHash = NAVSha384GetHash(message)

    // Check for errors
    if (!length_array(messageHash)) {
        send_string 0, "'Error: Hash computation failed'"
        return false
    }

    // In a real implementation, you would verify the signature against the hash
    // using a public key. This is just a placeholder to show where SHA-384 fits
    // in the signature verification process.
    send_string 0, "'Message hash computed for signature verification'"

    // Placeholder for actual signature verification
    return NAVVerifySignature(messageHash, signature)  // Assume this function exists
}
``` -->

## Reference Values

For testing purposes, here are some test vectors for SHA-384:

| Input                                                                                                              | Expected SHA-384 Hash                                                                            |
| ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| "" (empty string)                                                                                                  | 38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b |
| "abc"                                                                                                              | cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7 |
| "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu" | 09330c33f71147e83d192fc782cd1b4753111b173b3b05d22fa08086e3b0f712fcc7c71a557e2db966c3e9fa91746039 |
| "The quick brown fox jumps over the lazy dog"                                                                      | ca737f1014a48f4c0b6dd43cb177b0afd9e5169367544c494011e3317dbf9a509cb1e5dc1e85a941bbee3d7f2afbc9b1 |

## Implementation Notes

- The implementation follows RFC6234 specifications
- The NAVSha384 functions return binary digests (byte arrays)
- Use NAVByteArrayToHexString from NAVFoundation.Encoding to convert to hexadecimal strings
- Maximum input size is limited by the NetLinx string capacity
- SHA-384 operates on 64-bit words, which may require special handling in 32-bit environments
- Performance may be affected by large inputs due to string handling limitations in NetLinx

## Security Considerations

SHA-384 offers several security advantages:

- Produces a 384-bit (48-byte) digest, providing higher security margin than SHA-256
- No known practical collision attacks or significant weaknesses
- Resistant against length extension attacks when properly implemented
- Recommended for applications requiring maximum cryptographic strength
- Particularly well-suited for environments where 64-bit operations are efficient

### When to Use SHA-384 vs SHA-256

- **Use SHA-384** when:
    - Maximum security is required
    - Protecting highly sensitive data
    - Operating in environments where 64-bit operations are efficient
    - For long-term security assurance

- **Use SHA-256** when:
    - A balance between security and performance is needed
    - Operating in environments with limited resources
    - Compatibility with systems that don't support SHA-384
    - The additional security margin of SHA-384 is not required

## Compatibility

- This implementation is fully compatible with the SHA-384 specification in RFC6234
- Output matches standard SHA-384 implementations on other platforms
- Widely supported across programming languages and platforms for interoperability
- Some legacy systems may not support SHA-384; consider compatibility requirements when selecting

## See Also

The examples in this document reference these additional NAVFoundation modules:

- [NAVFoundation.Encoding.axi](../Encoding/NAVFoundation.Encoding.md) - Provides conversion utilities including:
    - `NAVByteArrayToHexString()` - Converts binary data to hexadecimal string representation
    - `NAVHexToString()` - Alternative function for hex string conversion

- [NAVFoundation.FileUtils.axi](../FileUtils/NAVFoundation.FileUtils.md) - Provides file operations including:
    - `NAVFileRead()` - Reads data from a file into a buffer

These modules are required dependencies when using the code examples provided in this document.
