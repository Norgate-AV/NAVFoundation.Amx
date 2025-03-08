# NAVFoundation.Cryptography.Md5

## Overview

The `NAVFoundation.Cryptography.Md5` module provides an implementation of the MD5 message-digest algorithm for NetLinx. MD5 is a widely-used cryptographic hash function that produces a 128-bit (16-byte) hash value, typically expressed as a 32-character hexadecimal number.

This implementation is based on [RFC 1321](https://www.rfc-editor.org/rfc/rfc1321).

> **Security Note**: While MD5 is no longer considered cryptographically secure against well-funded attackers, it remains useful for checksumming, data integrity verification, and other non-security-critical applications.

## Installation

Include the following files in your NetLinx project:

```netlinx
#include 'NAVFoundation.Cryptography.Md5.axi'
#include 'NAVFoundation.Cryptography.Md5.h.axi'
#include 'NAVFoundation.BinaryUtils.axi'  // Required dependency
```

## API Reference

### NAVMd5GetHash

```netlinx
define_function char[32] NAVMd5GetHash(char value[])
```

**Description:**  
Computes the MD5 hash of a string and returns the result as a 32-character hexadecimal string.

**Parameters:**

- `value[]` - The input string to be hashed

**Returns:**  
A 32-character hexadecimal string representing the MD5 hash value.

**Example:**

```netlinx
stack_var char result[32]
result = NAVMd5GetHash('Hello, World!')
// result will be '65a8e27d8879283831b664bd8b7f0ad4'
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
DEFINE_PROGRAM

define_function fnTestMd5()
{
    stack_var char message[100]
    stack_var char hash[32]

    // Simple string hash
    message = 'Hello, World!'
    hash = NAVMd5GetHash(message)
    send_string 0, "'MD5(Hello, World!) = ', hash"

    // Empty string hash
    message = ''
    hash = NAVMd5GetHash(message)
    send_string 0, "'MD5(empty string) = ', hash"
}

DEFINE_START
{
    fnTestMd5()
}
```

Expected output:

```
MD5(Hello, World!) = 65a8e27d8879283831b664bd8b7f0ad4
MD5(empty string) = d41d8cd98f00b204e9800998ecf8427e
```

### Password Verification Example

```netlinx
DEFINE_DEVICE
dvTP = 10001:1:0  // Touch panel

DEFINE_VARIABLE
char stored_password_hash[32] = 'e10adc3949ba59abbe56e057f20f883e'  // MD5 hash for '123456'

DEFINE_PROGRAM

// Check if password matches the stored hash
define_function char IsPasswordValid(char entered_password[])
{
    stack_var char hash[32]

    hash = NAVMd5GetHash(entered_password)

    return (hash == stored_password_hash)
}

DEFINE_EVENT

// Example button press event to verify password
button_event[dvTP, 1]
{
    push:
    {
        stack_var char password[50]

        // Assume password is retrieved from a text input field
        password = [dvTP, 1]  // Pseudo-code for getting text from a text field

        if (IsPasswordValid(password))
        {
            send_command dvTP, 'SHOW-POPUP "AccessGranted"'
        }
        else
        {
            send_command dvTP, 'SHOW-POPUP "AccessDenied"'
        }
    }
}
```

### File Checksum Validation

```netlinx
DEFINE_DEVICE
dvDevice = 5001:1:0  // Device that can send file data

DEFINE_VARIABLE
char expected_file_hash[32] = '8b7588b30498654be2626aac62ef37a5'  // Example hash
char received_file_buffer[10000]
integer file_buffer_pos = 1

DEFINE_EVENT

// Example event handler for receiving file data
data_event[dvDevice]
{
    online:
    {
        file_buffer_pos = 1
        clear_buffer received_file_buffer
    }

    string:
    {
        // Accumulate received data into buffer
        received_file_buffer = "received_file_buffer, data.text"

        // Check if we received complete file (this is just an example)
        if (find_string(received_file_buffer, 'EOF', 1))
        {
            stack_var char file_content[10000]
            stack_var char file_hash[32]

            // Extract file content without EOF marker
            file_content = remove_string(received_file_buffer, 'EOF', 1)

            // Calculate hash of received file
            file_hash = NAVMd5GetHash(file_content)

            // Validate file integrity
            if (file_hash == expected_file_hash)
            {
                send_string 0, 'File integrity check passed!'
            }
            else
            {
                send_string 0, "'File integrity check failed! Expected: ', expected_file_hash, ' Got: ', file_hash"
            }
        }
    }
}
```

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
