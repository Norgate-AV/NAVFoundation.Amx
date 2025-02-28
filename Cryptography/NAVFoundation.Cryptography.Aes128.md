# NAVFoundation.Cryptography.Aes128

## Overview

NAVFoundation.Cryptography.Aes128 is a pure NetLinx implementation of the Advanced Encryption Standard (AES-128) encryption algorithm. This library provides a secure way to encrypt and decrypt sensitive data in AMX NetLinx-based control systems.

## Features

- **AES-128 ECB mode** - Electronic Code Book mode encryption/decryption
- **PKCS#7 padding** - Standard padding mechanism for handling arbitrary length data
- **Password-based key derivation** - PBKDF2-HMAC-SHA1 for generating encryption keys from passwords
- **Comprehensive error handling** - Detailed error codes and messages
- **Memory-efficient implementation** - Optimized for AMX controllers with limited resources

## Including the Library

```c
#include 'NAVFoundation.Cryptography.Aes128.axi'
```

## Key Concepts

### AES Context

The `_NAVAesContext` struct holds the encryption state including:

- Expanded key schedule for encryption/decryption
- Initialization vector (IV) (for future CBC mode)

### Error Handling

All functions that can fail return `sinteger` error codes:

- `NAV_AES_SUCCESS` (0) indicates successful operation
- Negative values indicate specific errors (see Error Codes section)

## Core Functions

### NAVAes128ContextInit

Initialize an AES Context

```netlinx-source
define_function sinteger NAVAes128ContextInit(_NAVAesContext context, char key[16])
```

Initializes an AES context with a 16-byte key.

**Parameters:**

- `context`: The AES context to initialize
- `key`: 16-bytes (128-bit) encryption key

**Returns:**

- `NAV_AES_SUCCESS` (0) on success
- `NAV_AES_ERROR_INVALID_KEY_LENGTH` (-110) if key is not exactly 16 bytes

## Usage

### Basic Encryption/Decryption

```netlinx-source
define_function SimpleEncryptionExample() {
    stack_var _NAVAesContext context
    stack_var char key[16]
    stack_var char plaintext[100]
    stack_var char ciphertext[200]
    stack_var char decrypted[100]

    // Generate or define your key (must be exactly 16 bytes)
    // For example, a hard-coded key (not recommended for production)
    key = "$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F"

    // Initialize AES context with key
    NAVAes128ContextInit(context, key)

    // Text to encrypt
    plaintext = 'This is my secret message'

    // Encrypt
    NAVAes128ECBEncrypt(context, plaintext, ciphertext) // Produces {}

    // Decrypt
    NAVAes128ECBDecrypt(context, ciphertext, decrypted) // Produces 'This is my secret message'
}
```

## Security Considerations

1. **ECB Mode Limitations**

    - ECB mode encrypts identical plaintext blocks to identical ciphertext blocks
    - For better security with multi-block data, CBC mode should be used (planned for future)

2. **Key Management**

    - Never hard-code encryption keys in production code
    - Use password-based key derivation when possible
    - Store derived keys securely and never expose them

3. **Password Strength**

    - Use strong passwords (min. 12 characters) with mix of numbers, letters, symbols
    - Consider using a passphrase (multiple words) for better security and memorability

4. **Salt Handling**

    - Always use a unique salt for each encryption operation
    - Store the salt alongside the ciphertext (salt is not a secret)
    - Salt should be at least 16 random bytes

5. **Iteration Count**
    - Higher iteration counts in key derivation provide better security
    - Balance security needs against performance constraints
    - `NAV_KDF_DEFAULT_ITERATIONS` provides a reasonable balance

## Error Codes

| Code | Constant                            | Description                                       |
| ---- | ----------------------------------- | ------------------------------------------------- |
| 0    | NAV_AES_SUCCESS                     | Operation completed successfully                  |
| -100 | NAV_AES_ERROR_NULL_CONTEXT          | AES context is null or invalid                    |
| -101 | NAV_AES_ERROR_NULL_PARAMETER        | A required parameter was null                     |
| -102 | NAV_AES_ERROR_MEMORY                | Memory allocation or buffer size error            |
| -110 | NAV_AES_ERROR_INVALID_KEY_LENGTH    | Key is not exactly 16 bytes (128 bits)            |
| -111 | NAV_AES_ERROR_KEY_EXPANSION_FAILED  | Key schedule expansion failed                     |
| -112 | NAV_AES_ERROR_KEY_DERIVATION_FAILED | Password-based key derivation failed              |
| -120 | NAV_AES_ERROR_INVALID_BLOCK_LENGTH  | Ciphertext length is not a multiple of block size |
| -121 | NAV_AES_ERROR_CIPHER_OPERATION      | General cipher operation error                    |
| -130 | NAV_AES_ERROR_INVALID_PADDING       | Invalid padding format                            |
| -131 | NAV_AES_ERROR_PADDING_VERIFICATION  | Padding verification failed during decryption     |
| -140 | NAV_AES_ERROR_INVALID_IV_LENGTH     | IV length is not 16 bytes (for CBC mode)          |

```

```
