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

### NAVAes128ECBEncrypt

Encrypt data using AES-128 in ECB mode

```netlinx-source
define_function sinteger NAVAes128ECBEncrypt(_NAVAesContext context, char plaintext[], char ciphertext[])
```

Encrypts the given plaintext using the provided AES context.

**Parameters:**

- `context`: The initialized AES context
- `plaintext`: The data to encrypt
- `ciphertext`: The buffer to store the encrypted data

**Returns:**

- `NAV_AES_SUCCESS` (0) on success
- `NAV_AES_ERROR_NULL_CONTEXT` (-100) if context is null
- `NAV_AES_ERROR_NULL_PARAMETER` (-101) if plaintext or ciphertext is null
- `NAV_AES_ERROR_MEMORY` (-102) if memory allocation fails

### NAVAes128ECBDecrypt

Decrypt data using AES-128 in ECB mode

```netlinx-source
define_function sinteger NAVAes128ECBDecrypt(_NAVAesContext context, char ciphertext[], char plaintext[])
```

Decrypts the given ciphertext using the provided AES context.

**Parameters:**

- `context`: The initialized AES context
- `ciphertext`: The data to decrypt
- `plaintext`: The buffer to store the decrypted data

**Returns:**

- `NAV_AES_SUCCESS` (0) on success
- `NAV_AES_ERROR_NULL_CONTEXT` (-100) if context is null
- `NAV_AES_ERROR_NULL_PARAMETER` (-101) if ciphertext or plaintext is null
- `NAV_AES_ERROR_MEMORY` (-102) if memory allocation fails

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

### Advanced Examples

#### Example 1: Comprehensive Error Handling

```netlinx-source
define_function char[NAV_MAX_BUFFER] EncryptWithErrorHandling(char message[], char key[16]) {
    stack_var _NAVAesContext context
    stack_var char ciphertext[NAV_MAX_BUFFER]
    stack_var sinteger result

    // Initialize AES context
    result = NAVAes128ContextInit(context, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'AES context initialization failed: ', NAVAes128GetError(result)")
        return ''
    }

    // Encrypt data
    result = NAVAes128ECBEncrypt(context, message, ciphertext)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Encryption failed: ', NAVAes128GetError(result)")
        return ''
    }

    return ciphertext
}

define_function char[NAV_MAX_BUFFER] DecryptWithErrorHandling(char ciphertext[], char key[16]) {
    stack_var _NAVAesContext context
    stack_var char plaintext[NAV_MAX_BUFFER]
    stack_var sinteger result

    // Verify input
    if (length_array(ciphertext) == 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, 'Decrypt failed: Empty ciphertext')
        return ''
    }

    // Check input length (must be multiple of 16)
    if (length_array(ciphertext) % 16 != 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Decrypt failed: Invalid ciphertext length (', itoa(length_array(ciphertext)), ' bytes)'")
        return ''
    }

    // Initialize AES context
    result = NAVAes128ContextInit(context, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'AES context initialization failed: ', NAVAes128GetError(result)")
        return ''
    }

    // Decrypt data
    result = NAVAes128ECBDecrypt(context, ciphertext, plaintext)
    if (result != NAV_AES_SUCCESS) {
        switch(result) {
            case NAV_AES_ERROR_PADDING_VERIFICATION: {
                NAVErrorLog(NAV_LOG_LEVEL_ERROR, 'Decrypt failed: Invalid padding (likely wrong key)')
                break
            }
            default: {
                NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Decrypt failed: ', NAVAes128GetError(result)")
            }
        }
        return ''
    }

    return plaintext
}

// Example usage:
define_function TestAdvancedEncryption() {
    stack_var char key[16]
    stack_var char message[100]
    stack_var char encrypted[NAV_MAX_BUFFER]
    stack_var char decrypted[NAV_MAX_BUFFER]

    // Define key and message
    key = "$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F"
    message = 'This is a confidential message'

    // Encrypt
    encrypted = EncryptWithErrorHandling(message, key)
    if (length_array(encrypted) == 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, 'Encryption process failed')
        return
    }

    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Message encrypted successfully: ', itoa(length_array(encrypted)), ' bytes'")

    // Decrypt
    decrypted = DecryptWithErrorHandling(encrypted, key)
    if (length_array(decrypted) == 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, 'Decryption process failed')
        return
    }

    // Verify
    if (message == decrypted) {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, 'Decryption successful - message verified')
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, 'Decryption produced incorrect result')
    }
}
```

### Example 2: Password-Based Key Derivation

```netlinx-source
define_function char[NAV_MAX_BUFFER] EncryptWithPassword(char message[], char password[], char salt[]) {
    stack_var _NAVAesContext context
    stack_var char key[16]
    stack_var char ciphertext[NAV_MAX_BUFFER]
    stack_var sinteger result

    // Derive key from password
    result = NAVAes128DeriveKey(password, salt, NAV_KDF_DEFAULT_ITERATIONS, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Key derivation failed: ', NAVAes128GetError(result)")
        return ''
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, 'Key derived successfully')

    // Initialize AES context
    result = NAVAes128ContextInit(context, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'AES context initialization failed: ', NAVAes128GetError(result)")
        return ''
    }

    // Encrypt data
    result = NAVAes128ECBEncrypt(context, message, ciphertext)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Encryption failed: ', NAVAes128GetError(result)")
        return ''
    }

    return ciphertext
}

define_function char[NAV_MAX_BUFFER] DecryptWithPassword(char ciphertext[], char password[], char salt[]) {
    stack_var _NAVAesContext context
    stack_var char key[16]
    stack_var char plaintext[NAV_MAX_BUFFER]
    stack_var sinteger result

    // Derive key from password
    result = NAVAes128DeriveKey(password, salt, NAV_KDF_DEFAULT_ITERATIONS, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Key derivation failed: ', NAVAes128GetError(result)")
        return ''
    }

    // Initialize AES context
    result = NAVAes128ContextInit(context, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'AES context initialization failed: ', NAVAes128GetError(result)")
        return ''
    }

    // Decrypt data
    result = NAVAes128ECBDecrypt(context, ciphertext, plaintext)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Decrypt failed: ', NAVAes128GetError(result)")
        return ''
    }

    return plaintext
}

// Example usage:
define_function TestPasswordEncryption() {
    stack_var char password[50]
    stack_var char salt[16]
    stack_var char message[100]
    stack_var char encrypted[NAV_MAX_BUFFER]
    stack_var char decrypted[NAV_MAX_BUFFER]

    // Create user password and random salt
    password = 'MyStrongPassword123!'

    // Generate a random salt - should be unique per encryption
    // In production, store this salt with the ciphertext
    salt = NAVPbkdf2GetRandomSalt(16)

    message = 'This message is protected with a password'

    // Encrypt
    encrypted = EncryptWithPassword(message, password, salt)
    if (length_array(encrypted) == 0) {
        return
    }

    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Message encrypted successfully with password: ', itoa(length_array(encrypted)), ' bytes'")

    // In a real application, you would store both the salt and encrypted data
    // Simulating retrieval for decryption:
    decrypted = DecryptWithPassword(encrypted, password, salt)
    if (length_array(decrypted) == 0) {
        return
    }

    // Verify
    if (message == decrypted) {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, 'Password-based decryption successful')
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, 'Password-based decryption failed')
    }

    // Example with wrong password
    decrypted = DecryptWithPassword(encrypted, 'WrongPassword', salt)
    if (length_array(decrypted) == 0) {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, 'Wrong password correctly rejected')
    }
}
```

### Example 3: Encrypting Binary Data

```netlinx-source
define_function BinaryDataEncryptionExample() {
    stack_var _NAVAesContext context
    stack_var char key[16]
    stack_var char binaryData[100]
    stack_var char encrypted[NAV_MAX_BUFFER]
    stack_var char decrypted[NAV_MAX_BUFFER]
    stack_var integer i
    stack_var sinteger result

    // Initialize with a key
    for (i = 1; i <= 16; i++) {
        key[i] = i // Simple key for demonstration
    }

    result = NAVAes128ContextInit(context, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'AES context initialization failed: ', NAVAes128GetError(result)")
        return
    }

    // Create binary data with mixed content
    set_length_array(binaryData, 100)
    for (i = 1; i <= 100; i++) {
        // Mix of binary values including zeros
        binaryData[i] = type_cast(i % 256)
    }

    // Encrypt the binary data
    result = NAVAes128ECBEncrypt(context, binaryData, encrypted)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Binary encryption failed: ', NAVAes128GetError(result)")
        return
    }

    // Log encryption result
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Binary data encrypted: ', itoa(length_array(encrypted)), ' bytes'")

    // Decrypt the data
    result = NAVAes128ECBDecrypt(context, encrypted, decrypted)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Binary decryption failed: ', NAVAes128GetError(result)")
        return
    }

    // Verify all bytes match
    if (length_array(decrypted) != length_array(binaryData)) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Length mismatch: Original=', itoa(length_array(binaryData)),
                                         ' Decrypted=', itoa(length_array(decrypted))")
        return
    }

    for (i = 1; i <= length_array(binaryData); i++) {
        if (decrypted[i] != binaryData[i]) {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Binary data mismatch at byte ', itoa(i)")
            return
        }
    }

    NAVErrorLog(NAV_LOG_LEVEL_INFO, 'Binary data successfully encrypted and decrypted')
}
```

### Example 4: Secure Configuration Storage

```netlinx-source
// Structure to hold sensitive system configuration
define_type
struct ConfigData {
    char apiKey[50]
    char serverPassword[30]
    integer securePort
    char authToken[128]
}

// Save encrypted configuration to a file
define_function sinteger SaveEncryptedConfig(ConfigData config, char masterPassword[]) {
    stack_var char salt[16]
    stack_var char key[16]
    stack_var char configBuffer[NAV_MAX_BUFFER]
    stack_var char encrypted[NAV_MAX_BUFFER]
    stack_var _NAVAesContext context
    stack_var sinteger result
    stack_var integer fileHandle

    // Generate random salt
    salt = NAVPbkdf2GetRandomSalt(16)

    // Derive key from master password
    result = NAVAes128DeriveKey(masterPassword, salt, NAV_KDF_DEFAULT_ITERATIONS, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Key derivation failed: ', NAVAes128GetError(result)")
        return result
    }

    // Initialize AES context
    result = NAVAes128ContextInit(context, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'AES context initialization failed: ', NAVAes128GetError(result)")
        return result
    }

    // Serialize config to a buffer
    configBuffer = "config.apiKey, '|', config.serverPassword, '|',
                   itoa(config.securePort), '|', config.authToken"

    // Encrypt config
    result = NAVAes128ECBEncrypt(context, configBuffer, encrypted)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Config encryption failed: ', NAVAes128GetError(result)")
        return result
    }

    // Convert binary data to storage format
    stack_var char saltHex[50]
    stack_var char encryptedHex[NAV_MAX_BUFFER * 2]
    stack_var integer i

    saltHex = ''
    for (i = 1; i <= length_array(salt); i++) {
        saltHex = "saltHex, format('%02X', salt[i])"
    }

    encryptedHex = ''
    for (i = 1; i <= length_array(encrypted); i++) {
        encryptedHex = "encryptedHex, format('%02X', encrypted[i])"
    }

    // Write to file: format is salt + newline + encrypted data
    fileHandle = file_open('config.enc', FILE_WRITE_ONLY)
    if (fileHandle < 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Failed to open config file for writing: ', itoa(fileHandle)")
        return -1
    }

    file_write_line(fileHandle, saltHex)
    file_write_line(fileHandle, encryptedHex)
    file_close(fileHandle)

    NAVErrorLog(NAV_LOG_LEVEL_INFO, 'Encrypted configuration saved successfully')
    return NAV_AES_SUCCESS
}

// Load and decrypt configuration from a file
define_function sinteger LoadEncryptedConfig(char masterPassword[], ConfigData config) {
    stack_var char saltHex[50]
    stack_var char encryptedHex[NAV_MAX_BUFFER * 2]
    stack_var char salt[16]
    stack_var char encrypted[NAV_MAX_BUFFER]
    stack_var char key[16]
    stack_var char decrypted[NAV_MAX_BUFFER]
    stack_var _NAVAesContext context
    stack_var sinteger result
    stack_var integer fileHandle
    stack_var integer i, pos, nextPos

    // Read from file
    fileHandle = file_open('config.enc', FILE_READ_ONLY)
    if (fileHandle < 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Failed to open config file for reading: ', itoa(fileHandle)")
        return -1
    }

    saltHex = file_read_line(fileHandle, 50)
    encryptedHex = file_read_line(fileHandle, NAV_MAX_BUFFER * 2)
    file_close(fileHandle)

    // Convert hex salt back to binary
    set_length_array(salt, 16)
    for (i = 0; i < 16; i++) {
        stack_var char hexPair[3]
        stack_var integer value

        hexPair = mid_string(saltHex, i*2+1, 2)
        value = hextoi(hexPair)
        salt[i+1] = type_cast(value)
    }

    // Convert hex encrypted data back to binary
    set_length_array(encrypted, length_string(encryptedHex) / 2)
    for (i = 0; i < length_array(encrypted); i++) {
        stack_var char hexPair[3]
        stack_var integer value

        hexPair = mid_string(encryptedHex, i*2+1, 2)
        value = hextoi(hexPair)
        encrypted[i+1] = type_cast(value)
    }

    // Derive key from master password
    result = NAVAes128DeriveKey(masterPassword, salt, NAV_KDF_DEFAULT_ITERATIONS, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Key derivation failed: ', NAVAes128GetError(result)")
        return result
    }

    // Initialize AES context
    result = NAVAes128ContextInit(context, key)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'AES context initialization failed: ', NAVAes128GetError(result)")
        return result
    }

    // Decrypt config
    result = NAVAes128ECBDecrypt(context, encrypted, decrypted)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Config decryption failed: ', NAVAes128GetError(result)")
        return result
    }

    // Parse decrypted config
    // Format: apiKey|serverPassword|securePort|authToken

    // Extract API key
    pos = 1
    nextPos = find_string(decrypted, '|', pos)
    if (nextPos == 0) return -1
    config.apiKey = mid_string(decrypted, pos, nextPos-pos)

    // Extract server password
    pos = nextPos + 1
    nextPos = find_string(decrypted, '|', pos)
    if (nextPos == 0) return -1
    config.serverPassword = mid_string(decrypted, pos, nextPos-pos)

    // Extract secure port
    pos = nextPos + 1
    nextPos = find_string(decrypted, '|', pos)
    if (nextPos == 0) return -1
    config.securePort = atoi(mid_string(decrypted, pos, nextPos-pos))

    // Extract auth token
    pos = nextPos + 1
    config.authToken = mid_string(decrypted, pos, length_string(decrypted)-pos+1)

    NAVErrorLog(NAV_LOG_LEVEL_INFO, 'Encrypted configuration loaded successfully')
    return NAV_AES_SUCCESS
}

// Example usage
define_function TestConfigEncryption() {
    stack_var ConfigData config
    stack_var ConfigData loadedConfig
    stack_var char masterPassword[50]
    stack_var sinteger result

    // Set up test config
    config.apiKey = 'ak_12345_ABCDEFG1234567890'
    config.serverPassword = 'supersecret$password!'
    config.securePort = 8443
    config.authToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'

    // Set master password
    masterPassword = 'MasterConfigPassword123!'

    // Save config
    result = SaveEncryptedConfig(config, masterPassword)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, 'Failed to save encrypted config')
        return
    }

    // Clear loaded config to ensure we're getting fresh data
    loadedConfig.apiKey = ''
    loadedConfig.serverPassword = ''
    loadedConfig.securePort = 0
    loadedConfig.authToken = ''

    // Load config
    result = LoadEncryptedConfig(masterPassword, loadedConfig)
    if (result != NAV_AES_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, 'Failed to load encrypted config')
        return
    }

    // Verify loaded config matches original
    if (config.apiKey != loadedConfig.apiKey ||
        config.serverPassword != loadedConfig.serverPassword ||
        config.securePort != loadedConfig.securePort ||
        config.authToken != loadedConfig.authToken) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, 'Config verification failed - data mismatch')
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, 'Config encryption/decryption verified successfully')
    }
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

## Input/Output Encoding

When storing or transmitting encrypted data, you'll often need to encode the binary ciphertext. Here are common encoding approaches:

### Base64 Encoding

Base64 is often used to represent binary data as ASCII text.

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
