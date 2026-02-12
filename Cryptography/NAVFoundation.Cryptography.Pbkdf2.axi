PROGRAM_NAME='NAVFoundation.Cryptography.Pbkdf2'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_PBKDF2__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_PBKDF2__ 'NAVFoundation.Cryptography.Pbkdf2'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Pbkdf2.h.axi'
#include 'NAVFoundation.Cryptography.Hmac.axi'

/*
 * PBKDF2 implementation using HMAC-SHA1 as the pseudorandom function (PRF)
 * Based on RFC 2898: https://tools.ietf.org/html/rfc2898
 */

/**
 * @function NAVPbkdf2F
 * @internal
 * @description F function for PBKDF2 as defined in RFC 2898.
 * Computes the XOR of iterations iterations of HMAC-SHA1 for a specific block.
 *
 * @param {char[]} password - Password input for key derivation
 * @param {char[]} salt - Salt value for key derivation
 * @param {integer} iterations - Number of iterations to perform
 * @param {integer} blockIndex - The block number being processed (1-based)
 *
 * @returns {char[20]} 20-byte result for this block
 *
 * @note Internal function used by PBKDF2 implementation
 */
define_function char[20] NAVPbkdf2F(char password[],
                                    char salt[],
                                    integer iterations,
                                    integer blockIndex) {
    stack_var char blockIndexBytes[4]
    stack_var char saltWithIndex[NAV_MAX_BUFFER]
    stack_var char u[20]
    stack_var char result[20]
    stack_var integer i, j

    // Convert block index to 4 bytes (big-endian)
    blockIndexBytes[1] = type_cast((blockIndex >> 24) & $FF)
    blockIndexBytes[2] = type_cast((blockIndex >> 16) & $FF)
    blockIndexBytes[3] = type_cast((blockIndex >> 8) & $FF)
    blockIndexBytes[4] = type_cast(blockIndex & $FF)
    set_length_array(blockIndexBytes, 4)

    // Concatenate salt with block index
    set_length_array(saltWithIndex, length_array(salt) + 4)

    for (i = 1; i <= length_array(salt); i++) {
        saltWithIndex[i] = salt[i]
    }

    for (i = 1; i <= 4; i++) {
        saltWithIndex[length_array(salt) + i] = blockIndexBytes[i]
    }

    // First iteration
    u = NAVHmacSha1(password, saltWithIndex)
    set_length_array(u, 20) // Ensure proper length

    // Initialize result with first hash
    set_length_array(result, 20)

    for (i = 1; i <= 20; i++) {
        result[i] = u[i]
    }

    // Remaining iterations
    for (i = 2; i <= iterations; i++) {
        u = NAVHmacSha1(password, u)
        set_length_array(u, 20) // Ensure proper length

        // XOR result with u
        for (j = 1; j <= 20; j++) {
            result[j] = result[j] ^ u[j]
        }
    }

    return result
}


/**
 * @function NAVPbkdf2Sha1
 * @public
 * @description Derives a cryptographic key from a password using PBKDF2-HMAC-SHA1.
 * This implements the Password-Based Key Derivation Function 2 from RFC 2898.
 *
 * @param {char[]} password - Password input for key derivation (any length, must not be empty)
 * @param {char[]} salt - Salt value for key derivation (at least 8 bytes recommended)
 * @param {integer} iterations - Number of iterations to perform (higher values increase security)
 * @param {char[]} derivedKey - Output buffer to receive the derived key
 * @param {integer} keyLength - Desired length of the derived key in bytes
 *
 * @returns {sinteger} NAV_KDF_SUCCESS on success, or an error code on failure
 *
 * @example
 * stack_var char password[50]
 * stack_var char salt[16]
 * stack_var char key[32]
 * stack_var sinteger result
 *
 * password = 'SecurePassword123'
 * salt = NAVPbkdf2GetRandomSalt(16)
 * result = NAVPbkdf2Sha1(password, salt, NAV_KDF_DEFAULT_ITERATIONS, key, 32)
 *
 * @note Higher iteration counts improve security but slow down derivation
 * @note Always use a unique salt for each key derivation
 * @note Salt should be stored alongside the encrypted data
 * @see NAVPbkdf2GetRandomSalt
 */
define_function sinteger NAVPbkdf2Sha1(char password[],
                                        char salt[],
                                        integer iterations,
                                        char derivedKey[],
                                        integer keyLength) {
    stack_var integer l, r, i, j, offset
    stack_var char block[20]

    // Validate parameters
    if (length_array(password) == 0) {
        return NAV_KDF_ERROR_INVALID_PARAMETER
    }

    if (length_array(salt) < NAV_KDF_SALT_SIZE_MINIMUM) {
        return NAV_KDF_ERROR_INVALID_SALT_SIZE
    }

    if (keyLength <= 0) {
        return NAV_KDF_ERROR_INVALID_OUTPUT_LEN
    }

    if (iterations < 1) {
        return NAV_KDF_ERROR_ITERATION_COUNT
    }

    // Clear and initialize output array
    set_length_array(derivedKey, keyLength)

    // Calculate number of blocks needed
    l = (keyLength + 19) / 20  // Ceiling division by 20 (SHA1 hash size)
    r = keyLength - ((l - 1) * 20)  // Remainder for last block

    // Generate each block
    for (i = 1; i <= l; i++) {
        block = NAVPbkdf2F(password, salt, iterations, i)
        set_length_array(block, 20) // Ensure proper length

        // Copy appropriate number of bytes from this block
        offset = (i - 1) * 20

        for (j = 1; j <= 20; j++) {
            // Only copy bytes that fit within the requested key length
            if (i < l || j <= r) {
                derivedKey[offset + j] = block[j]
            }
        }
    }

    return NAV_KDF_SUCCESS
}


/**
 * @function NAVPbkdf2GetRandomSalt
 * @public
 * @description Generates a random salt of the specified length for use with PBKDF2.
 * A salt should be unique for each password/key derivation.
 *
 * @param {integer} saltLength - Desired length of the salt in bytes
 *
 * @returns {char[]} Random salt of specified length
 *
 * @example
 * stack_var char salt[16]
 *
 * // Generate a 16-byte random salt
 * salt = NAVPbkdf2GetRandomSalt(16)
 *
 * @note If saltLength is <= 0, the default salt size (16 bytes) will be used
 * @note The salt is not a secret but should be stored with the encrypted data
 * @note Each encrypted item should have its own unique salt
 */
define_function char[NAV_MAX_BUFFER] NAVPbkdf2GetRandomSalt(integer saltLength) {
    stack_var char salt[NAV_MAX_BUFFER]
    stack_var integer i

    if (saltLength <= 0) {
        saltLength = NAV_KDF_DEFAULT_SALT_SIZE
    }

    set_length_array(salt, saltLength)

    // Generate random bytes for salt
    for (i = 1; i <= saltLength; i++) {
        salt[i] = random_number(256) - 1  // 0-255
    }

    return salt
}


/**
 * @function NAVPbkdf2GetError
 * @public
 * @description Converts a PBKDF2 error code to a human-readable error message.
 *
 * @param {sinteger} error - Error code returned by a PBKDF2 function
 *
 * @returns {char[100]} Human-readable description of the error
 *
 * @example
 * stack_var sinteger result
 *
 * result = NAVPbkdf2Sha1(password, salt, iterations, key, keyLength)
 * if (result != NAV_KDF_SUCCESS) {
 *     NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Error: ', NAVPbkdf2GetError(result)")
 * }
 */
define_function char[100] NAVPbkdf2GetError(sinteger error) {
    switch (error) {
        case NAV_KDF_SUCCESS:                 { return 'Success' }
        case NAV_KDF_ERROR_INVALID_PARAMETER: { return 'Invalid parameter' }
        case NAV_KDF_ERROR_INVALID_SALT_SIZE: { return 'Invalid salt size' }
        case NAV_KDF_ERROR_INVALID_OUTPUT_LEN:{ return 'Invalid output length' }
        case NAV_KDF_ERROR_ITERATION_COUNT:   { return 'Invalid iteration count' }
        case NAV_KDF_ERROR_MEMORY:            { return 'Memory error' }
        default:                              { return 'Unknown error' }
    }
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_PBKDF2__
