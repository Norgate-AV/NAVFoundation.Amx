PROGRAM_NAME='NAVFoundation.Cryptography.Pbkdf2'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

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
#include 'NAVFoundation.Cryptography.Sha1.axi'

/*
 * PBKDF2 implementation using HMAC-SHA1 as the pseudorandom function (PRF)
 * Based on RFC 2898: https://tools.ietf.org/html/rfc2898
 */

// HMAC-SHA1 function using key and message
define_function char[20] NAVPbkdf2HmacSha1(char key[], char message[]) {
    stack_var char innerKey[64]
    stack_var char outerKey[64]
    stack_var char innerResult[20]
    stack_var integer i
    stack_var char innerPad[64]
    stack_var char outerPad[64]
    stack_var char combinedInner[NAV_MAX_BUFFER]
    stack_var char combinedOuter[NAV_MAX_BUFFER]

    // Initialize pads with 0x36 for inner and 0x5C for outer
    for (i = 1; i <= 64; i++) {
        innerPad[i] = $36
        outerPad[i] = $5C
    }

    // If key is longer than 64 bytes, hash it
    if (length_array(key) > 64) {
        key = NAVSha1GetHash(key)
    }

    // Prepare the inner and outer keys
    for (i = 1; i <= length_array(key); i++) {
        innerKey[i] = key[i] ^ innerPad[i]
        outerKey[i] = key[i] ^ outerPad[i]
    }

    // If key is shorter than 64 bytes, pad with zeros (already XORed with pads)
    for (i = length_array(key) + 1; i <= 64; i++) {
        innerKey[i] = innerPad[i]
        outerKey[i] = outerPad[i]
    }

    // Set proper lengths
    set_length_array(innerKey, 64)
    set_length_array(outerKey, 64)

    // Inner hash: SHA1(innerKey || message)
    set_length_array(combinedInner, 64 + length_array(message))

    for (i = 1; i <= 64; i++) {
        combinedInner[i] = innerKey[i]
    }

    for (i = 1; i <= length_array(message); i++) {
        combinedInner[64 + i] = message[i]
    }

    innerResult = NAVSha1GetHash(combinedInner)

    // Outer hash: SHA1(outerKey || innerResult)
    set_length_array(combinedOuter, 64 + 20)

    for (i = 1; i <= 64; i++) {
        combinedOuter[i] = outerKey[i]
    }

    for (i = 1; i <= 20; i++) {
        combinedOuter[64 + i] = innerResult[i]
    }

    return NAVSha1GetHash(combinedOuter)
}


// F function for PBKDF2 as defined in RFC 2898
define_function char[20] NAVPbkdf2F(char password[], char salt[], integer iterations, integer blockIndex) {
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
    u = NAVPbkdf2HmacSha1(password, saltWithIndex)
    set_length_array(u, 20) // Ensure proper length

    // Initialize result with first hash
    set_length_array(result, 20)

    for (i = 1; i <= 20; i++) {
        result[i] = u[i]
    }

    // Remaining iterations
    for (i = 2; i <= iterations; i++) {
        u = NAVPbkdf2HmacSha1(password, u)
        set_length_array(u, 20) // Ensure proper length

        // XOR result with u
        for (j = 1; j <= 20; j++) {
            result[j] = result[j] ^ u[j]
        }
    }

    return result
}


// Main PBKDF2 function to derive a key
define_function sinteger NAVPbkdf2Sha1(char password[], char salt[], integer iterations, char derivedKey[], integer keyLength) {
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


// Helper function to generate a random salt
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


// Helper function to get error message for KDF errors
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
