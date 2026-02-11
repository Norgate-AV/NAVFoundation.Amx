# NAVFoundation.Cryptography.Hmac

## Overview

The NAVFoundation.Cryptography.Hmac library provides HMAC (Hash-based Message Authentication Code) functionality for secure message authentication. HMAC combines a cryptographic hash function with a secret key to verify both the data integrity and authenticity of a message.

## Purpose

HMAC is essential for:

- **Message Authentication** - Verify that a message came from a legitimate sender
- **Data Integrity** - Ensure messages haven't been modified in transit
- **API Security** - Sign API requests and responses
- **JWT Tokens** - Required for signing JSON Web Tokens (HS256, HS384, HS512)
- **Webhook Verification** - Validate incoming webhook payloads
- **Password-Based Operations** - Used in PBKDF2 and other key derivation functions

## Features

- **Multiple Hash Algorithms** - Supports MD5, SHA-1, SHA-256, and SHA-512
- **Binary Output** - Returns raw binary digests for maximum flexibility
- **RFC 2104 Compliant** - Follows the official HMAC specification
- **Type-Safe Functions** - Algorithm-specific functions with fixed return sizes
- **Key Management** - Automatically handles keys of any length per RFC requirements
- **Zero Dependencies** - Uses only NAVFoundation crypto libraries

## Usage

### Include the Library

```netlinx
#include 'NAVFoundation.Cryptography.Hmac.axi'
```

### Basic Example - HMAC-SHA256

```netlinx
define_program 'HMAC Example'

#include 'NAVFoundation.Cryptography.Hmac.axi'
#include 'NAVFoundation.Encoding.axi'

define_start

stack_var char key[50]
stack_var char message[100]
stack_var char digest[HMAC_SHA256_HASH_SIZE]  // 32 bytes
stack_var char hexDigest[64]

// Set up your secret key and message
key = 'my-secret-key'
message = 'Hello, World!'

// Compute HMAC-SHA256
digest = NAVHmacSha256(key, message)

// Convert to hex string for display
hexDigest = NAVByteArrayToHexString(digest)

send_string 0, "'HMAC-SHA256: ', hexDigest"
```

### Algorithm-Specific Functions

For best performance and type safety, use the algorithm-specific functions:

#### HMAC-MD5

```netlinx
stack_var char digest[HMAC_MD5_HASH_SIZE]  // 16 bytes
digest = NAVHmacMd5(key, message)
```

#### HMAC-SHA1

```netlinx
stack_var char digest[HMAC_SHA1_HASH_SIZE]  // 20 bytes
digest = NAVHmacSha1(key, message)
```

#### HMAC-SHA256

```netlinx
stack_var char digest[HMAC_SHA256_HASH_SIZE]  // 32 bytes
digest = NAVHmacSha256(key, message)
```

#### HMAC-SHA512

```netlinx
stack_var char digest[HMAC_SHA512_HASH_SIZE]  // 64 bytes
digest = NAVHmacSha512(key, message)
```

### Generic Function with Algorithm Selection

Alternatively, use the generic function for runtime algorithm selection:

```netlinx
stack_var char digest[HMAC_SHA512_HASH_SIZE]  // 64 bytes (max size for all algorithms)

// SHA-256
digest = NAVHmacGetDigest('SHA256', key, message)

// SHA-512
digest = NAVHmacGetDigest('SHA512', key, message)

// SHA-1
digest = NAVHmacGetDigest('SHA1', key, message)

// MD5
digest = NAVHmacGetDigest('MD5', key, message)
```

**Note:** Algorithm names are case-insensitive. Both 'SHA256' and 'sha256' work.

### API Authentication Example

```netlinx
define_function char[64] SignApiRequest(char endpoint[], char body[], char apiSecret[]) {
    stack_var char message[NAV_MAX_BUFFER]
    stack_var char signature[HMAC_SHA256_HASH_SIZE]

    // Create message to sign: endpoint + body
    message = "endpoint, body"

    // Sign with HMAC-SHA256
    signature = NAVHmacSha256(apiSecret, message)

    return NAVByteArrayToHexString(signature)
}

define_start

stack_var char apiSecret[100]
stack_var char signature[64]

apiSecret = 'super-secret-api-key-12345'
signature = SignApiRequest('/api/devices', '{"name":"Device-1"}', apiSecret)

send_string 0, "'X-Signature: ', signature"
```

### Webhook Verification Example

```netlinx
define_function integer VerifyWebhookSignature(char payload[],
                                                char receivedSignature[],
                                                char webhookSecret[]) {
    stack_var char computedSignature[HMAC_SHA256_HASH_SIZE]
    stack_var char computedHex[64]

    // Compute expected signature
    computedSignature = NAVHmacSha256(webhookSecret, payload)
    computedHex = NAVByteArrayToHexString(computedSignature)

    // Compare signatures (case-insensitive)
    if (lower_string(computedHex) == lower_string(receivedSignature)) {
        return true  // Valid signature
    }

    return false  // Invalid signature
}
```

## API Reference

### Algorithm-Specific Functions

#### NAVHmacMd5

```netlinx
define_function char[HMAC_MD5_HASH_SIZE] NAVHmacMd5(char key[], char message[])
```

Computes HMAC using MD5 hash function.

**Parameters:**

- `key` - Secret key for authentication (any length)
- `message` - Message to authenticate (any length)

**Returns:** 16-byte binary HMAC-MD5 digest, or empty string if key is empty

**Note:** MD5 is not recommended for new security-sensitive applications.

---

#### NAVHmacSha1

```netlinx
define_function char[HMAC_SHA1_HASH_SIZE] NAVHmacSha1(char key[], char message[])
```

Computes HMAC using SHA-1 hash function.

**Parameters:**

- `key` - Secret key for authentication (any length)
- `message` - Message to authenticate (any length)

**Returns:** 20-byte binary HMAC-SHA1 digest, or empty string if key is empty

**Note:** SHA-1 is acceptable for HMAC but not recommended for new applications.

---

#### NAVHmacSha256

```netlinx
define_function char[HMAC_SHA256_HASH_SIZE] NAVHmacSha256(char key[], char message[])
```

Computes HMAC using SHA-256 hash function. **Recommended for most applications.**

**Parameters:**

- `key` - Secret key for authentication (any length)
- `message` - Message to authenticate (any length)

**Returns:** 32-byte binary HMAC-SHA256 digest, or empty string if key is empty

---

#### NAVHmacSha512

```netlinx
define_function char[HMAC_SHA512_HASH_SIZE] NAVHmacSha512(char key[], char message[])
```

Computes HMAC using SHA-512 hash function. Provides maximum security.

**Parameters:**

- `key` - Secret key for authentication (any length)
- `message` - Message to authenticate (any length)

**Returns:** 64-byte binary HMAC-SHA512 digest, or empty string if key is empty

---

### Generic Function

#### NAVHmacGetDigest

```netlinx
define_function char[HMAC_SHA512_HASH_SIZE] NAVHmacGetDigest(char algorithm[],
                                                              char key[],
                                                              char message[])
```

Generic HMAC function with runtime algorithm selection.

**Parameters:**

- `algorithm` - Hash algorithm: 'MD5', 'SHA1', 'SHA256', 'SHA512' (case-insensitive)
- `key` - Secret key for authentication (any length)
- `message` - Message to authenticate (any length)

**Returns:** Binary HMAC digest (size depends on algorithm, max 64 bytes for SHA-512), or empty string on error

**Note:** For better performance and type safety, use algorithm-specific functions when possible.

## Constants

### Block Sizes

| Constant                 | Value     | Description        |
| ------------------------ | --------- | ------------------ |
| `HMAC_MD5_BLOCK_SIZE`    | 64 bytes  | MD5 block size     |
| `HMAC_SHA1_BLOCK_SIZE`   | 64 bytes  | SHA-1 block size   |
| `HMAC_SHA256_BLOCK_SIZE` | 64 bytes  | SHA-256 block size |
| `HMAC_SHA512_BLOCK_SIZE` | 128 bytes | SHA-512 block size |

### Hash Sizes

| Constant                | Value    | Description         |
| ----------------------- | -------- | ------------------- |
| `HMAC_MD5_HASH_SIZE`    | 16 bytes | MD5 output size     |
| `HMAC_SHA1_HASH_SIZE`   | 20 bytes | SHA-1 output size   |
| `HMAC_SHA256_HASH_SIZE` | 32 bytes | SHA-256 output size |
| `HMAC_SHA512_HASH_SIZE` | 64 bytes | SHA-512 output size |

### Algorithm Identifiers

| Constant                | Value    | Description        |
| ----------------------- | -------- | ------------------ |
| `HMAC_ALGORITHM_MD5`    | 'MD5'    | MD5 identifier     |
| `HMAC_ALGORITHM_SHA1`   | 'SHA1'   | SHA-1 identifier   |
| `HMAC_ALGORITHM_SHA256` | 'SHA256' | SHA-256 identifier |
| `HMAC_ALGORITHM_SHA512` | 'SHA512' | SHA-512 identifier |

### Error Codes

| Constant                           | Value | Description          |
| ---------------------------------- | ----- | -------------------- |
| `HMAC_SUCCESS`                     | 0     | Operation successful |
| `HMAC_ERROR_UNSUPPORTED_ALGORITHM` | 1     | Unknown algorithm    |
| `HMAC_ERROR_INVALID_KEY`           | 2     | Empty or null key    |
| `HMAC_ERROR_INVALID_MESSAGE`       | 3     | Empty message        |

## Algorithm Selection Guide

| Algorithm   | Security Level | Speed     | Recommended Use                   |
| ----------- | -------------- | --------- | --------------------------------- |
| MD5         | ⚠️ Weak        | Very Fast | Legacy systems only               |
| SHA-1       | ⚠️ Weak        | Fast      | Legacy/compatibility              |
| **SHA-256** | ✅ Strong      | Fast      | **General purpose (recommended)** |
| SHA-512     | ✅ Very Strong | Medium    | Maximum security requirements     |

### Recommendations

- **SHA-256**: Best choice for most applications (JWT HS256, API signing, webhooks)
- **SHA-512**: Use when maximum security is required (JWT HS512, high-value transactions)
- **SHA-1**: Only for legacy systems or when compatibility requires it
- **MD5**: Avoid for any security-sensitive applications

## Implementation Details

### HMAC Algorithm

HMAC is computed as follows (from RFC 2104):

```
HMAC(K, m) = H((K' ⊕ opad) || H((K' ⊕ ipad) || m))
```

Where:

- `H` = Hash function (MD5, SHA-1, SHA-256, or SHA-512)
- `K` = Secret key
- `K'` = Key adjusted to block size (hashed if too long, padded if too short)
- `m` = Message to authenticate
- `ipad` = Inner padding (0x36 repeated)
- `opad` = Outer padding (0x5C repeated)
- `⊕` = XOR operation
- `||` = Concatenation

### Optimized Implementation

The NAVFoundation HMAC implementation uses a refactored architecture for maintainability:

- **Private Helper Function**: Core HMAC logic implemented once in `NAVHmacCompute()`
- **Public API Functions**: Each algorithm function validates input and delegates to the helper
- **Memory Efficiency**: Algorithm-specific buffer sizes (64-128 bytes vs 1024 bytes)
- **String Concatenation**: Uses reliable NetLinx string concatenation pattern
- **Type Safety**: Constant-based return types (`HMAC_*_HASH_SIZE`) ensure correct buffer allocation

### Key Length Handling

1. **Key longer than block size**: Key is hashed to reduce to hash output size, then padded to block size
2. **Key shorter than block size**: Key is padded with zeros to block size
3. **Key equals block size**: Key is used as-is

This ensures keys of any length are properly handled according to RFC 2104.

### Binary Output

All HMAC functions return binary (raw byte) output, not hex strings. This provides:

- **Flexibility** - Can convert to hex, Base64, or use directly
- **Efficiency** - No unnecessary encoding overhead
- **Compatibility** - Required for JWT, PBKDF2, and other protocols
- **Compactness** - Binary is 50% smaller than hex representation

To convert to hex string for display:

```netlinx
#include 'NAVFoundation.Encoding.axi'

hexString = NAVByteArrayToHexString(digest)
```

## Security Considerations

### Key Management

- **Key Length**: Use at least 128 bits (16 bytes) for adequate security
- **Key Generation**: Use cryptographically secure random number generators
- **Key Storage**: Never store keys in plain text or source code
- **Key Rotation**: Implement periodic key rotation for long-lived systems

### Message Validation

- **Always verify signatures**: Never trust unsigned messages in security contexts
- **Use constant-time comparison**: Prevents timing attacks when comparing HMACs
- **Include timestamps**: Prevent replay attacks by including message timestamps
- **Use unique nonces**: For one-time operations, include unique identifiers

### Algorithm Choice

- Prefer SHA-256 or SHA-512 for new implementations
- MD5 and SHA-1 HMAC are not completely broken but should be avoided
- HMAC remains secure even when underlying hash has collision vulnerabilities
- Consider performance vs. security trade-offs for your specific use case

## Dependencies

- `NAVFoundation.Core.axi` - Core utilities
- `NAVFoundation.Cryptography.Md5.axi` - MD5 hash function
- `NAVFoundation.Cryptography.Sha1.axi` - SHA-1 hash function
- `NAVFoundation.Cryptography.Sha256.axi` - SHA-256 hash function
- `NAVFoundation.Cryptography.Sha512.axi` - SHA-512 hash function
- `NAVFoundation.ErrorLogUtils.axi` - Error logging

## Standards Compliance

- **RFC 2104** - HMAC: Keyed-Hashing for Message Authentication
- Fully compatible with standard HMAC implementations
- Test vectors validated against reference implementations

## Related Libraries

- [PBKDF2](./NAVFoundation.Cryptography.Pbkdf2.md) - Uses HMAC for key derivation
- [MD5](./NAVFoundation.Cryptography.Md5.md) - Underlying hash function
- [SHA1](./NAVFoundation.Cryptography.Sha1.md) - Underlying hash function
- [SHA256](./NAVFoundation.Cryptography.Sha256.md) - Underlying hash function
- [SHA512](./NAVFoundation.Cryptography.Sha512.md) - Underlying hash function
- [Base64](../Encoding/NAVFoundation.Encoding.Base64.md) - For encoding HMAC output
- JWT (future) - Will use HMAC for token signing

## Examples

### Complete API Authentication System

See the [examples directory](../../__tests__/examples/) for complete working examples including:

- REST API request signing
- Webhook signature verification
- Time-based one-time passwords (TOTP)
- JWT token signing (when JWT library is available)

## License

MIT License - Copyright (c) 2010-2026 Norgate AV

---

For questions or issues, please visit the [NAVFoundation repository](https://github.com/Norgate-AV/NAVFoundation.Amx).
