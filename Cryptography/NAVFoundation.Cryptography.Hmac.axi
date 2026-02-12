PROGRAM_NAME='NAVFoundation.Cryptography.Hmac'

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

/**
 * @file NAVFoundation.Cryptography.Hmac.axi
 * @brief Implementation of HMAC (Keyed-Hash Message Authentication Code).
 *
 * This module provides HMAC functionality for message authentication using
 * various cryptographic hash functions (MD5, SHA-1, SHA-256, SHA-384, SHA-512).
 *
 * HMAC is defined as:
 *   HMAC(K, m) = H((K' ⊕ opad) || H((K' ⊕ ipad) || m))
 * where:
 *   - H is the hash function
 *   - K' is the key adjusted to block size
 *   - opad is the outer padding constant (0x5C repeated)
 *   - ipad is the inner padding constant (0x36 repeated)
 *   - || denotes concatenation
 *   - ⊕ denotes XOR operation
 *
 * Implementation based on RFC 2104: https://www.rfc-editor.org/rfc/rfc2104
 *
 * @copyright 2010-2026 Norgate AV
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC__ 'NAVFoundation.Cryptography.Hmac'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Hmac.h.axi'
#include 'NAVFoundation.Cryptography.Md5.axi'
#include 'NAVFoundation.Cryptography.Sha1.axi'
#include 'NAVFoundation.Cryptography.Sha256.axi'
#include 'NAVFoundation.Cryptography.Sha384.axi'
#include 'NAVFoundation.Cryptography.Sha512.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


/**
 * @function NAVHmacCompute
 * @private
 * @description Internal helper that performs HMAC computation for any algorithm.
 *              Implements the core HMAC algorithm: HMAC(K,m) = H((K' ⊕ opad) || H((K' ⊕ ipad) || m))
 *
 * @param {char[]} algorithm - Algorithm identifier (use HMAC_ALGORITHM_* constants)
 * @param {integer} blockSize - Block size in bytes for the hash algorithm
 * @param {char[]} key - Secret key for HMAC operation
 * @param {char[]} message - Message to authenticate
 *
 * @returns {char[HMAC_SHA512_HASH_SIZE]} HMAC digest (actual size depends on algorithm)
 *
 * @note This is an internal function not intended for direct use
 * @note Uses SHA512-sized buffers to accommodate all supported algorithms
 */
define_function char[HMAC_SHA512_HASH_SIZE] NAVHmacCompute(
    char algorithm[],
    integer blockSize,
    char key[],
    char message[]
) {
    stack_var char keyAdjusted[HMAC_SHA512_BLOCK_SIZE]
    stack_var char outerKey[HMAC_SHA512_BLOCK_SIZE]
    stack_var char innerKey[HMAC_SHA512_BLOCK_SIZE]
    stack_var integer i

    // Step 1: Adjust key to block size
    if (length_array(key) > blockSize) {
        // If key is longer than block size, hash it
        switch (upper_string(algorithm)) {
            case HMAC_ALGORITHM_MD5: {
                keyAdjusted = NAVMd5GetHash(key)
            }
            case HMAC_ALGORITHM_SHA1: {
                keyAdjusted = NAVSha1GetHash(key)
            }
            case HMAC_ALGORITHM_SHA256: {
                keyAdjusted = NAVSha256GetHash(key)
            }
            case HMAC_ALGORITHM_SHA384: {
                keyAdjusted = NAVSha384GetHash(key)
            }
            case HMAC_ALGORITHM_SHA512: {
                keyAdjusted = NAVSha512GetHash(key)
            }
        }
    }
    else {
        // If key is block size or smaller, zero-pad
        keyAdjusted = key
        while (length_array(keyAdjusted) < blockSize) {
            keyAdjusted = "keyAdjusted, $00"
        }
    }

    // Step 2: Create inner and outer keys by XORing with pad constants
    for (i = 1; i <= blockSize; i++) {
        outerKey = "outerKey, (keyAdjusted[i] bxor HMAC_OPAD)"
        innerKey = "innerKey, (keyAdjusted[i] bxor HMAC_IPAD)"
    }

    // Step 3: Compute HMAC = H(outerKey || H(innerKey || message))
    switch (upper_string(algorithm)) {
        case HMAC_ALGORITHM_MD5: {
            return NAVMd5GetHash("outerKey, NAVMd5GetHash("innerKey, message")")
        }
        case HMAC_ALGORITHM_SHA1: {
            return NAVSha1GetHash("outerKey, NAVSha1GetHash("innerKey, message")")
        }
        case HMAC_ALGORITHM_SHA256: {
            return NAVSha256GetHash("outerKey, NAVSha256GetHash("innerKey, message")")
        }
        case HMAC_ALGORITHM_SHA384: {
            return NAVSha384GetHash("outerKey, NAVSha384GetHash("innerKey, message")")
        }
        case HMAC_ALGORITHM_SHA512: {
            return NAVSha512GetHash("outerKey, NAVSha512GetHash("innerKey, message")")
        }
    }

    return ''
}


/**
 * @function NAVHmacMd5
 * @public
 * @description Computes HMAC-MD5 digest using the provided key and message.
 *
 * @param {char[]} key - Secret key for HMAC operation
 * @param {char[]} message - Message to authenticate
 *
 * @returns {char[HMAC_MD5_HASH_SIZE]} 16-byte HMAC-MD5 digest (binary)
 *
 * @example
 * stack_var char key[50]
 * stack_var char message[100]
 * stack_var char digest[HMAC_MD5_HASH_SIZE]
 *
 * key = 'my-secret-key'
 * message = 'Hello, World!'
 * digest = NAVHmacMd5(key, message)
 *
 * @note Returns empty string if key is empty
 */
define_function char[HMAC_MD5_HASH_SIZE] NAVHmacMd5(char key[], char message[]) {
    // Validate key
    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC__,
                                    'NAVHmacMd5',
                                    'Empty key provided')
        return ''
    }

    return NAVHmacCompute(HMAC_ALGORITHM_MD5, HMAC_MD5_BLOCK_SIZE, key, message)
}


/**
 * @function NAVHmacSha1
 * @public
 * @description Computes HMAC-SHA1 digest using the provided key and message.
 *
 * @param {char[]} key - Secret key for HMAC operation
 * @param {char[]} message - Message to authenticate
 *
 * @returns {char[HMAC_SHA1_HASH_SIZE]} 20-byte HMAC-SHA1 digest (binary)
 *
 * @example
 * stack_var char key[50]
 * stack_var char message[100]
 * stack_var char digest[HMAC_SHA1_HASH_SIZE]
 *
 * key = 'my-secret-key'
 * message = 'Hello, World!'
 * digest = NAVHmacSha1(key, message)
 *
 * @note Returns empty string if key is empty
 */
define_function char[HMAC_SHA1_HASH_SIZE] NAVHmacSha1(char key[], char message[]) {
    // Validate key
    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC__,
                                    'NAVHmacSha1',
                                    'Empty key provided')
        return ''
    }

    return NAVHmacCompute(HMAC_ALGORITHM_SHA1, HMAC_SHA1_BLOCK_SIZE, key, message)
}


/**
 * @function NAVHmacSha256
 * @public
 * @description Computes HMAC-SHA256 digest using the provided key and message.
 *
 * @param {char[]} key - Secret key for HMAC operation
 * @param {char[]} message - Message to authenticate
 *
 * @returns {char[HMAC_SHA256_HASH_SIZE]} 32-byte HMAC-SHA256 digest (binary)
 *
 * @example
 * stack_var char key[50]
 * stack_var char message[100]
 * stack_var char digest[HMAC_SHA256_HASH_SIZE]
 *
 * key = 'my-secret-key'
 * message = 'Hello, World!'
 * digest = NAVHmacSha256(key, message)
 *
 * @note Returns empty string if key is empty
 */
define_function char[HMAC_SHA256_HASH_SIZE] NAVHmacSha256(char key[], char message[]) {
    // Validate key
    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC__,
                                    'NAVHmacSha256',
                                    'Empty key provided')
        return ''
    }

    return NAVHmacCompute(HMAC_ALGORITHM_SHA256, HMAC_SHA256_BLOCK_SIZE, key, message)
}


/**
 * @function NAVHmacSha384
 * @public
 * @description Computes HMAC-SHA384 digest using the provided key and message.
 *
 * @param {char[]} key - Secret key for HMAC operation
 * @param {char[]} message - Message to authenticate
 *
 * @returns {char[HMAC_SHA384_HASH_SIZE]} 48-byte HMAC-SHA384 digest (binary)
 *
 * @example
 * stack_var char key[50]
 * stack_var char message[100]
 * stack_var char digest[HMAC_SHA384_HASH_SIZE]
 *
 * key = 'my-secret-key'
 * message = 'Hello, World!'
 * digest = NAVHmacSha384(key, message)
 *
 * @note Returns empty string if key is empty
 */
define_function char[HMAC_SHA384_HASH_SIZE] NAVHmacSha384(char key[], char message[]) {
    // Validate key
    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC__,
                                    'NAVHmacSha384',
                                    'Empty key provided')
        return ''
    }

    return NAVHmacCompute(HMAC_ALGORITHM_SHA384, HMAC_SHA384_BLOCK_SIZE, key, message)
}


/**
 * @function NAVHmacSha512
 * @public
 * @description Computes HMAC-SHA512 digest using the provided key and message.
 *
 * @param {char[]} key - Secret key for HMAC operation
 * @param {char[]} message - Message to authenticate
 *
 * @returns {char[HMAC_SHA512_HASH_SIZE]} 64-byte HMAC-SHA512 digest (binary)
 *
 * @example
 * stack_var char key[50]
 * stack_var char message[100]
 * stack_var char digest[HMAC_SHA512_HASH_SIZE]
 *
 * key = 'my-secret-key'
 * message = 'Hello, World!'
 * digest = NAVHmacSha512(key, message)
 *
 * @note Returns empty string if key is empty
 */
define_function char[HMAC_SHA512_HASH_SIZE] NAVHmacSha512(char key[], char message[]) {
    // Validate key
    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC__,
                                    'NAVHmacSha512',
                                    'Empty key provided')
        return ''
    }

    return NAVHmacCompute(HMAC_ALGORITHM_SHA512, HMAC_SHA512_BLOCK_SIZE, key, message)
}


/**
 * @function NAVHmacGetDigest
 * @public
 * @description Generic HMAC function that accepts an algorithm identifier.
 * Computes HMAC digest using the specified hash algorithm.
 *
 * @param {char[]} algorithm - Hash algorithm to use ('MD5', 'SHA1', 'SHA256', 'SHA512')
 * @param {char[]} key - Secret key for HMAC operation
 * @param {char[]} message - Message to authenticate
 *
 * @returns {char[HMAC_SHA512_HASH_SIZE]} HMAC digest (size depends on algorithm, max 64 bytes for SHA-512)
 *
 * @example
 * stack_var char key[50]
 * stack_var char message[100]
 * stack_var char digest[HMAC_SHA512_HASH_SIZE]
 *
 * key = 'my-secret-key'
 * message = 'Hello, World!'
 * digest = NAVHmacGetDigest('SHA256', key, message)
 *
 * @note Returns empty string if algorithm is unsupported or key is empty
 * @note Algorithm name is case-insensitive
 * @note For better performance and type safety, use algorithm-specific functions
 *       (NAVHmacMd5, NAVHmacSha1, NAVHmacSha256, NAVHmacSha512)
 */
define_function char[HMAC_SHA512_HASH_SIZE] NAVHmacGetDigest(char algorithm[], char key[], char message[]) {
    // Validate key
    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC__,
                                    'NAVHmacGetDigest',
                                    'Empty key provided')
        return ''
    }

    // Dispatch to appropriate algorithm-specific function
    switch (upper_string(algorithm)) {
        case HMAC_ALGORITHM_MD5: {
            return NAVHmacMd5(key, message)
        }
        case HMAC_ALGORITHM_SHA1:
        case 'SHA-1': {
            return NAVHmacSha1(key, message)
        }
        case HMAC_ALGORITHM_SHA256:
        case 'SHA-256': {
            return NAVHmacSha256(key, message)
        }
        case HMAC_ALGORITHM_SHA384:
        case 'SHA-384': {
            return NAVHmacSha384(key, message)
        }
        case HMAC_ALGORITHM_SHA512:
        case 'SHA-512': {
            return NAVHmacSha512(key, message)
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC__,
                                        'NAVHmacGetDigest',
                                        "'Unsupported algorithm: ', algorithm, ' (supported: MD5, SHA1, SHA256, SHA384, SHA512)'")
            return ''
        }
    }
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC__
