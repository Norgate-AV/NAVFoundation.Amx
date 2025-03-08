# NAVFoundation.Cryptography.Pbkdf2

## Overview

The PBKDF2 (Password-Based Key Derivation Function 2) module provides a secure way to derive cryptographic keys from passwords. This implementation uses HMAC-SHA1 as the underlying pseudorandom function and follows the specification defined in [RFC 2898](https://tools.ietf.org/html/rfc2898).

## Purpose

Password-based key derivation is essential for:

- Secure password storage
- Deriving encryption keys from user passwords
- Preventing brute-force and rainbow table attacks
- Creating deterministic keys from passwords

## Key Features

- Standard-compliant PBKDF2 implementation
- Configurable iteration count for security tuning
- Random salt generation
- Detailed error reporting

## API Reference

### NAVPbkdf2Sha1

Derives a cryptographic key from a password using PBKDF2-HMAC-SHA1.

```netlinx
define_function sinteger NAVPbkdf2Sha1(
    char password[],
    char salt[],
    integer iterations,
    char derivedKey[],
    integer keyLength
)
```

#### Parameters

- **password**: The password input for key derivation (must not be empty)
- **salt**: Salt value for key derivation (at least 8 bytes recommended)
- **iterations**: Number of iterations to perform (higher values increase security)
- **derivedKey**: Output buffer to receive the derived key
- **keyLength**: Desired length of the derived key in bytes

#### Return Values

- **NAV_KDF_SUCCESS** (0): Operation completed successfully
- **NAV_KDF_ERROR_INVALID_PARAMETER** (-1): One or more parameters are invalid
- **NAV_KDF_ERROR_INVALID_SALT_SIZE** (-2): Salt is too small
- **NAV_KDF_ERROR_INVALID_OUTPUT_LEN** (-3): Invalid output length specified
- **NAV_KDF_ERROR_ITERATION_COUNT** (-4): Invalid iteration count
- **NAV_KDF_ERROR_MEMORY** (-5): Memory allocation error

### NAVPbkdf2GetRandomSalt

Generates a random salt of the specified length for use with PBKDF2.

```netlinx
define_function char[NAV_MAX_BUFFER] NAVPbkdf2GetRandomSalt(integer saltLength)
```

#### Parameters

- **saltLength**: Desired length of the salt in bytes (if ≤ 0, default 16 bytes is used)

#### Return Values

- A character array containing random bytes to use as salt

### NAVPbkdf2GetError

Converts a PBKDF2 error code to a human-readable error message.

```netlinx
define_function char[100] NAVPbkdf2GetError(sinteger error)
```

#### Parameters

- **error**: Error code returned by a PBKDF2 function

#### Return Values

- A human-readable description of the error

## Usage Examples

### Basic Key Derivation

This example demonstrates how to derive a 32-byte (256-bit) key from a password:

```netlinx
define_function DeriveKeyExample() {
    stack_var char password[50]
    stack_var char salt[16]
    stack_var char derivedKey[32]
    stack_var sinteger result

    // Set up the password and generate a salt
    password = 'MySecurePassword123'
    salt = NAVPbkdf2GetRandomSalt(16)

    // Derive a 32-byte key using 10000 iterations
    result = NAVPbkdf2Sha1(password, salt, 10000, derivedKey, 32)

    if (result == NAV_KDF_SUCCESS) {
        // Key derivation successful, derivedKey now contains the derived key
        send_string 0, "'Key derived successfully'"
    } else {
        // Handle error
        send_string 0, "'Key derivation failed: ', NAVPbkdf2GetError(result)"
    }
}
```

### Password Verification

This example shows how to verify a password by deriving a key and comparing it to a stored key:

```netlinx
define_function char VerifyPasswordWithPbkdf2(char password[], char storedSalt[], char storedKey[]) {
    stack_var char derivedKey[32]
    stack_var sinteger result
    stack_var integer i
    stack_var char keysMatch

    // Derive key using the same salt and parameters as when the key was stored
    result = NAVPbkdf2Sha1(password, storedSalt, 10000, derivedKey, 32)

    if (result != NAV_KDF_SUCCESS) {
        send_string 0, "'Key derivation failed: ', NAVPbkdf2GetError(result)"
        return false
    }

    // Constant-time comparison of keys (to prevent timing attacks)
    keysMatch = true
    for (i = 1; i <= 32; i++) {
        if (derivedKey[i] != storedKey[i]) {
            keysMatch = false
        }
    }

    return keysMatch
}
```

### Complete Password Storage and Verification System

This example demonstrates a complete system for secure password storage and verification:

```netlinx
// Structure to store a password hash with its salt
define_type
structure PasswordHash {
    char salt[16]
    char key[32]
}

// Hash a password for storage
define_function PasswordHash HashPassword(char password[]) {
    stack_var PasswordHash result
    stack_var sinteger status

    // Generate a random salt
    result.salt = NAVPbkdf2GetRandomSalt(16)

    // Derive the key
    status = NAVPbkdf2Sha1(password, result.salt, NAV_KDF_DEFAULT_ITERATIONS, result.key, 32)

    if (status != NAV_KDF_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Password hashing failed: ', NAVPbkdf2GetError(status)")
        clear_buffer(result.salt)
        clear_buffer(result.key)
    }

    return result
}

// Check if a password matches a stored hash
define_function char VerifyPasswordAgainstHash(char password[], PasswordHash storedHash) {
    stack_var char derivedKey[32]
    stack_var sinteger result
    stack_var integer i
    stack_var char keysMatch

    // Derive key from the provided password using the stored salt
    result = NAVPbkdf2Sha1(password, storedHash.salt, NAV_KDF_DEFAULT_ITERATIONS, derivedKey, 32)

    if (result != NAV_KDF_SUCCESS) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Password verification failed: ', NAVPbkdf2GetError(result)")
        return false
    }

    // Constant-time comparison
    keysMatch = true
    for (i = 1; i <= 32; i++) {
        if (derivedKey[i] != storedHash.key[i]) {
            keysMatch = false
        }
    }

    return keysMatch
}

// Example of usage
define_function void PasswordExample() {
    stack_var char password[50]
    stack_var PasswordHash stored
    stack_var char isValid

    // Initially set/register a password
    password = 'SecurePassword123'
    stored = HashPassword(password)

    // Later, verify a login attempt
    password = 'SecurePassword123'
    isValid = VerifyPasswordAgainstHash(password, stored)

    if (isValid) {
        NAVDebugLog(NAV_LOG_LEVEL_INFO, "'Password is correct!'")
    }
    else {
        NAVDebugLog(NAV_LOG_LEVEL_WARNING, "'Invalid password attempt'")
    }
}
```

## Best Practices

1. **Iteration Count**: Choose an iteration count as high as practical for your performance requirements. Higher is more secure.

2. **Unique Salt**: Always use a unique salt for each password/key. Never reuse salts.

3. **Salt Storage**: Store the salt alongside the derived key. The salt is not a secret.

4. **Salt Size**: Use at least 16 bytes (128 bits) for your salt to ensure uniqueness.

5. **Key Length**: Use an appropriate key length for your application. 32 bytes (256 bits) is suitable for most applications.

6. **Constant-Time Comparison**: When comparing derived keys, use constant-time comparison to prevent timing attacks.

## Security Considerations

- PBKDF2 with HMAC-SHA1 is still considered secure for password hashing, but newer algorithms like Argon2 provide better protection against hardware-accelerated attacks.
- The security of PBKDF2 is primarily dependent on the iteration count. As hardware becomes faster, the iteration count should be increased.
- Passwords should have sufficient entropy to resist dictionary attacks.
- For very high-security applications, consider using a memory-hard function like Argon2 if available.

## Performance Considerations

- Higher iteration counts provide better security but require more processing time.
- On resource-constrained systems, balance security with acceptable performance.
- Consider setting iteration counts based on the capabilities of your target hardware.

## See Also

The PBKDF2 module works with these additional NAVFoundation modules:

- [NAVFoundation.Cryptography.Sha1.axi](NAVFoundation.Cryptography.Sha1.md) - Used internally for HMAC-SHA1 operations
- [NAVFoundation.Cryptography.Aes128.axi](NAVFoundation.Cryptography.Aes128.md) - Can use PBKDF2 for key derivation
- [NAVFoundation.Encoding.axi](../Encoding/NAVFoundation.Encoding.md) - For encoding derived keys as hex strings

## References

- [RFC 2898: PBKDF2 Specification](https://tools.ietf.org/html/rfc2898)
- [NIST Special Publication 800-132: Recommendation for Password-Based Key Derivation](https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-132.pdf)
