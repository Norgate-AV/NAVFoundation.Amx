# NAVFoundation.Cryptography.Sha512

## Overview

The SHA-512 (Secure Hash Algorithm 512) implementation provides cryptographic hash functionality based on RFC6234. This module generates a 512-bit (64-byte) message digest from input data, typically represented as a 128-character hexadecimal string.

SHA-512 is part of the SHA-2 family of cryptographic hash functions, designed by the NSA. It offers the strongest security among commonly used hash algorithms, making it suitable for the most security-critical applications.

Key features of SHA-512 include:

- 512-bit (64-byte) output digest
- Superior collision resistance compared to SHA-256 and SHA-1
- Built on 64-bit operations, making it efficient on 64-bit systems
- Used in security-critical applications requiring maximum cryptographic strength
- Standardized in FIPS PUB 180-4

## API Reference

### Main Functions

#### `NAVSha512GetHash`

```netlinx
define_function char[64] NAVSha512GetHash(char value[])
```

**Description:** Computes the SHA-512 hash of the input string and returns a 64-byte binary digest.

**Parameters:**

- `value` - The input string to be hashed

**Returns:**

- 64-byte binary SHA-512 hash on success
- Empty string on error

## Usage Examples

### Basic Usage

```netlinx
// Include the SHA-512 library
#include 'NAVFoundation.Cryptography.Sha512.axi'
#include 'NAVFoundation.Encoding.axi'  // For hex conversion

// Example function
define_function ComputeSha512Example() {
    stack_var char message[100]
    stack_var char digest[64]
    stack_var char hash[128]

    // Input message to hash
    message = 'The quick brown fox jumps over the lazy dog'

    // Compute SHA-512 hash (returns binary format)
    digest = NAVSha512GetHash(message)

    // Check for errors
    if (!length_array(digest)) {
        send_string 0, "'Error: Hash computation failed'"
        return
    }

    // Convert to hexadecimal string for display/use
    hash = NAVByteArrayToHexString(digest)

    // Output the result
    // Should be: 07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6
    send_string 0, "'SHA-512 hash: ', hash"
}
```

### Verifying File Integrity

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Sha512.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.FileUtils.axi'  // For file operations

// Example function to verify file integrity
define_function VerifyFileIntegrity(char path[], char expectedHash[]) {
    stack_var char digest[64]
    stack_var char data[10000]  // Adjust size as needed
    stack_var char actualHash[128]

    // Read file content
    if (NAVFileRead(path, data) < 0) {
        send_string 0, "'Error: Could not read file'"
        return
    }

    // Compute SHA-512 hash
    digest = NAVSha512GetHash(data)

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
#include 'NAVFoundation.Cryptography.Sha512.axi'
#include 'NAVFoundation.Encoding.axi'

// Define variables
DEFINE_VARIABLE

volatile char storedPasswordHash[128]
volatile char salt[16]  // Random salt for added security

// Function to generate a salt (placeholder - use a proper random generator)
define_function char[16] GenerateSalt() {
    // In a real implementation, this should be cryptographically random
    // This is just a placeholder
    return "$01,$23,$45,$67,$89,$AB,$CD,$EF,$FE,$DC,$BA,$98,$76,$54,$32,$10"
}

// Function to store a hashed password with salt
define_function StorePassword(char password[]) {
    stack_var char digest[64]
    stack_var char salted_password[1000]

    // Generate a new salt
    salt = GenerateSalt()

    // Combine password with salt
    salted_password = "salt, password"

    // Hash the salted password
    digest = NAVSha512GetHash(salted_password)

    // Convert to hex for storage
    storedPasswordHash = NAVHexToString(digest)

    send_string 0, "'Password stored securely with salt'"
}

// Function to verify a password
define_function char VerifyPassword(char password[]) {
    stack_var char digest[64]
    stack_var char passwordHash[128]
    stack_var char salted_password[1000]

    // Combine provided password with stored salt
    salted_password = "salt, password"

    // Hash the salted password
    digest = NAVSha512GetHash(salted_password)

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
#include 'NAVFoundation.Cryptography.Sha512.axi'
#include 'NAVFoundation.Encoding.axi'

// Note: This example assumes the existence of a digital signature verification function
// that would use the hash as input. The actual signature verification would involve
// public key cryptography which is beyond the scope of this example.

// Function to verify a digitally signed message
define_function char VerifySignedMessage(char message[], char signature[]) {
    stack_var char messageHash[64]

    // Compute the hash of the message
    messageHash = NAVSha512GetHash(message)

    // Check for errors
    if (!length_array(messageHash)) {
        send_string 0, "'Error: Hash computation failed'"
        return false
    }

    // In a real implementation, you would verify the signature against the hash
    // using a public key. This is just a placeholder to show where SHA-512 fits
    // in the signature verification process.
    send_string 0, "'Message hash computed for signature verification'"

    // Placeholder for actual signature verification
    return NAVVerifySignature(messageHash, signature)  // Assume this function exists
}
``` -->

## Reference Values

For testing purposes, here are some test vectors for SHA-512:

| Input                                                                                                              | Expected SHA-512 Hash                                                                                                            |
| ------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| "" (empty string)                                                                                                  | cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e |
| "abc"                                                                                                              | ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f |
| "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu" | 8e959b75dae313da8cf4f72814fc143f8f7779c6eb9f7fa17299aeadb6889018501d289e4900f7e4331b99dec4b5433ac7d329eeb6dd26545e96e55b874be909 |
| "The quick brown fox jumps over the lazy dog"                                                                      | 07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6 |

## Implementation Notes

- The implementation follows RFC6234 specifications
- The NAVSha512 functions return binary digests (byte arrays)
- Use NAVByteArrayToHexString from NAVFoundation.Encoding to convert to hexadecimal strings
- Maximum input size is limited by the NetLinx string capacity
- SHA-512 operates on 64-bit words, which may require special handling in 32-bit environments
- Performance may be affected by large inputs due to string handling limitations in NetLinx

## Security Considerations

SHA-512 offers several security advantages:

- Produces a 512-bit (64-byte) digest, providing higher security margin than SHA-256
- No known practical collision attacks or significant weaknesses
- Resistant against length extension attacks when properly implemented
- Recommended for applications requiring maximum cryptographic strength
- Particularly well-suited for environments where 64-bit operations are efficient

### When to Use SHA-512 vs SHA-256

- **Use SHA-512** when:

    - Maximum security is required
    - Protecting highly sensitive data
    - Operating in environments where 64-bit operations are efficient
    - For long-term security assurance

- **Use SHA-256** when:
    - A balance between security and performance is needed
    - Operating in environments with limited resources
    - Compatibility with systems that don't support SHA-512
    - The additional security margin of SHA-512 is not required

## Compatibility

- This implementation is fully compatible with the SHA-512 specification in RFC6234
- Output matches standard SHA-512 implementations on other platforms
- Widely supported across programming languages and platforms for interoperability
- Some legacy systems may not support SHA-512; consider compatibility requirements when selecting

## See Also

The examples in this document reference these additional NAVFoundation modules:

- [NAVFoundation.Encoding.axi](../Encoding/NAVFoundation.Encoding.md) - Provides conversion utilities including:

    - `NAVByteArrayToHexString()` - Converts binary data to hexadecimal string representation
    - `NAVHexToString()` - Alternative function for hex string conversion

- [NAVFoundation.FileUtils.axi](../FileUtils/NAVFoundation.FileUtils.md) - Provides file operations including:
    - `NAVFileRead()` - Reads data from a file into a buffer

These modules are required dependencies when using the code examples provided in this document.
