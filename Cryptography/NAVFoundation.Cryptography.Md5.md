# NAVFoundation.Cryptography.Md5

## Overview

The `NAVFoundation.Cryptography.Md5` module provides an implementation of the MD5 message-digest algorithm for NetLinx. MD5 is a widely-used cryptographic hash function that produces a 128-bit (16-byte) hash value.

This implementation is based on [RFC 1321](https://www.rfc-editor.org/rfc/rfc1321).

> **Security Note**: While MD5 is no longer considered cryptographically secure against well-funded attackers, it remains useful for checksumming, data integrity verification, and other non-security-critical applications.

## API Reference

### `NAVMd5GetHash`

```netlinx
define_function char[16] NAVMd5GetHash(char value[])
```

**Description:**  
Computes the MD5 hash of a string and returns the result as a 16-byte raw array.

**Parameters:**

- `value[]` - The input string to be hashed

**Returns:**  
A 16-byte raw array representing the MD5 hash value.

**Example:**

```netlinx
stack_var char result[16]
result = NAVMd5GetHash('Hello, World!')
// result will be a 16-byte array representing the MD5 hashash
// Example: "$65, $a8, $e2, $7d, $88, $79, $28, $38, $31, $b6, $64, $bd, $8b, $7f, $0a, $d4"
```

### Internal Functions

The library includes several internal functions that implement the MD5 algorithm:

- `NAVMd5Init` - Initializes an MD5 context
- `NAVMd5Update` - Updates the context with input data
- `NAVMd5Final` - Finalizes the hash computation
- `NAVMd5Transform` - Core MD5 transformation algorithm
- Various helper functions (F, G, H, I, FF, GG, HH, II)

These functions are not intended for direct use. Instead, use the main `NAVMd5GetHash` function.

## Examples

### Basic Usage

```netlinx
// Include the MD5 library
#include 'NAVFoundation.Cryptography.Md5.axi'
#include 'NAVFoundation.Encoding.axi'  // For hex conversion

// Example function
define_function ComputeMd5Example() {
    stack_var char message[100]
    stack_var char digest[16]
    stack_var char hash[32]

    // Simple string hash
    message = 'Hello, World!'

    // Compute MD5 hash (returns binary format)
    digest = NAVMd5GetHash(message)

    // Check for errors
    if (!length_array(digest)) {
        send_string 0, "'Error: Hash computation failed'"
        return
    }

    // Convert to hexadecimal string for display/use
    hash = NAVHexToString(digest)

    // Output the result
    // Should be: 65a8e27d8879283831b664bd8b7f0ad4
    send_string 0, "'MD5(Hello, World!) = ', hash"

    // Empty string hash
    message = ''
    digest = NAVMd5GetHash(message)
    hash = NAVHexToString(digest)

    // Should be: d41d8cd98f00b204e9800998ecf8427e
    send_string 0, "'MD5(empty string) = ', hash"
}
```

Expected output:

```
MD5(Hello, World!) = 65a8e27d8879283831b664bd8b7f0ad4
MD5(empty string) = d41d8cd98f00b204e9800998ecf8427e
```

### Password Verification Example

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Md5.axi'
#include 'NAVFoundation.Encoding.axi'

DEFINE_DEVICE
dvTP = 10001:1:0  // Touch panel

DEFINE_VARIABLE
// Store password hash in hex format for readability in code
char stored_password_hex[32] = 'e10adc3949ba59abbe56e057f20f883e'  // MD5 hash for '123456'
char stored_password_digest[16]

// Initialize the stored password digest from hex
define_function InitializePasswordSystem() {
    // Convert hex string to binary digest for comparison
    stored_password_digest = NAVHexStringToByteArray(stored_password_hex)
}

// Check if password matches the stored hash
define_function char IsPasswordValid(char entered_password[]) {
    stack_var char digest[16]

    // Calculate hash of entered password
    digest = NAVMd5GetHash(entered_password)

    // Check for errors
    if (!length_array(digest)) {
        send_string 0, "'Error: Hash computation failed'"
        return false
    }

    // Compare with stored hash
    return (digest == stored_password_digest)
}
```

<!-- ### File Checksum Validation

```netlinx
// Include required libraries
#include 'NAVFoundation.Cryptography.Md5.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.FileUtils.axi'  // For file operations

DEFINE_DEVICE
dvDevice = 5001:1:0  // Device that can send file data

DEFINE_VARIABLE
// Expected hash in hex format for readability
char expected_file_hash_hex[32] = '8b7588b30498654be2626aac62ef37a5'  // Example hash
char expected_file_digest[16]
char received_file_buffer[10000]

// Initialize the checksum validation system
define_function InitializeChecksumSystem() {
    // Convert hex string to binary digest for comparison
    expected_file_digest = NAVHexStringToByteArray(expected_file_hash_hex)

    // Clear the buffer
    clear_buffer received_file_buffer
}

DEFINE_EVENT

// System initialization
define_start {
    InitializeChecksumSystem()
}

// Example event handler for receiving file data
data_event[dvDevice] {
    online: {
        clear_buffer received_file_buffer
    }

    string: {
        // Accumulate received data into buffer
        received_file_buffer = "received_file_buffer, data.text"

        // Check if we received complete file (this is just an example)
        if (find_string(received_file_buffer, 'EOF', 1)) {
            stack_var char file_content[10000]
            stack_var char digest[16]
            stack_var char actual_hash[32]

            // Extract file content without EOF marker
            file_content = remove_string(received_file_buffer, 'EOF', 1)

            // Calculate hash of received file
            digest = NAVMd5GetHash(file_content)

            // Check for errors
            if (!length_array(digest)) {
                send_string 0, "'Error: Hash computation failed'"
                return
            }

            // Convert digest to hex for display
            actual_hash = NAVByteArrayToHexString(digest)

            // Validate file integrity
            if (digest == expected_file_digest) {
                send_string 0, "'File integrity check passed!'"
            }
            else {
                send_string 0, "'File integrity check failed!'"
                send_string 0, "'Expected: ', expected_file_hash_hex"
                send_string 0, "'Actual  : ', actual_hash"
            }
        }
    }
}
``` -->

## Performance Considerations

- MD5 is optimized for 32-bit architectures, making it reasonably efficient on NetLinx processors
- For very large data sets, consider processing the data in chunks
- The algorithm requires minimal memory overhead (approximately 200 bytes of stack space)

## Common Use Cases

- Data integrity verification
- File checksumming
- Simple non-security-critical authentication
- Hash-based data lookups

## Limitations

- **Not for cryptographic security**: MD5 is vulnerable to collision attacks and should not be used for security purposes
- **String length limitations**: Be aware of NetLinx string length limitations when processing large inputs
- **Performance**: While reasonably fast, processing very large data sets may impact system responsiveness

## Dependencies

This module requires:

- `NAVFoundation.BinaryUtils.axi` - For bit manipulation operations

## See Also

This module uses and can be used with:

- [NAVFoundation.BinaryUtils.axi](../Utils/NAVFoundation.BinaryUtils.md) - Required for bit manipulation operations
- [NAVFoundation.FileUtils.axi](../FileUtils/NAVFoundation.FileUtils.md) - For file operations when doing checksum validation
- [NAVFoundation.Encoding.axi](../Encoding/NAVFoundation.Encoding.md) - For additional encoding functions

## License

This module is part of the NAVFoundation library and is licensed under the MIT License.
