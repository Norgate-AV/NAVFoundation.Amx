PROGRAM_NAME='NAVFoundation.Cryptography.Hmac.h'

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
 * @file NAVFoundation.Cryptography.Hmac.h.axi
 * @brief Header file for HMAC (Keyed-Hash Message Authentication Code) implementation.
 *
 * This header defines constants and algorithm identifiers for HMAC operations.
 * HMAC is defined in RFC 2104 and provides message authentication using
 * cryptographic hash functions combined with a secret key.
 *
 * @see https://www.rfc-editor.org/rfc/rfc2104
 * @copyright 2010-2026 Norgate AV
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC_H__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC_H__ 'NAVFoundation.Cryptography.Hmac.h'


DEFINE_CONSTANT

/**
 * Block sizes for different hash algorithms (in bytes)
 * These are defined by the underlying hash function specifications
 */

/**
 * @constant HMAC_MD5_BLOCK_SIZE
 * @description Block size for MD5 hash function (64 bytes = 512 bits)
 */
constant integer HMAC_MD5_BLOCK_SIZE = 64

/**
 * @constant HMAC_SHA1_BLOCK_SIZE
 * @description Block size for SHA-1 hash function (64 bytes = 512 bits)
 */
constant integer HMAC_SHA1_BLOCK_SIZE = 64

/**
 * @constant HMAC_SHA256_BLOCK_SIZE
 * @description Block size for SHA-256 hash function (64 bytes = 512 bits)
 */
constant integer HMAC_SHA256_BLOCK_SIZE = 64

/**
 * @constant HMAC_SHA384_BLOCK_SIZE
 * @description Block size for SHA-384 hash function (128 bytes = 1024 bits)
 */
constant integer HMAC_SHA384_BLOCK_SIZE = 128

/**
 * @constant HMAC_SHA512_BLOCK_SIZE
 * @description Block size for SHA-512 hash function (128 bytes = 1024 bits)
 */
constant integer HMAC_SHA512_BLOCK_SIZE = 128

/**
 * Hash output sizes for different algorithms (in bytes)
 */

/**
 * @constant HMAC_MD5_HASH_SIZE
 * @description Output size for MD5 HMAC (16 bytes = 128 bits)
 */
constant integer HMAC_MD5_HASH_SIZE = 16

/**
 * @constant HMAC_SHA1_HASH_SIZE
 * @description Output size for SHA-1 HMAC (20 bytes = 160 bits)
 */
constant integer HMAC_SHA1_HASH_SIZE = 20

/**
 * @constant HMAC_SHA256_HASH_SIZE
 * @description Output size for SHA-256 HMAC (32 bytes = 256 bits)
 */
constant integer HMAC_SHA256_HASH_SIZE = 32

/**
 * @constant HMAC_SHA384_HASH_SIZE
 * @description Output size for SHA-384 HMAC (48 bytes = 384 bits)
 */
constant integer HMAC_SHA384_HASH_SIZE = 48

/**
 * @constant HMAC_SHA512_HASH_SIZE
 * @description Output size for SHA-512 HMAC (64 bytes = 512 bits)
 */
constant integer HMAC_SHA512_HASH_SIZE = 64

/**
 * HMAC pad constants as defined in RFC 2104
 */

/**
 * @constant HMAC_IPAD
 * @description Inner padding constant (0x36) - XORed with key for inner hash
 */
constant char HMAC_IPAD = $36

/**
 * @constant HMAC_OPAD
 * @description Outer padding constant (0x5C) - XORed with key for outer hash
 */
constant char HMAC_OPAD = $5C

/**
 * Algorithm identifiers for NAVHmacGetDigest function
 */

/**
 * @constant HMAC_ALGORITHM_MD5
 * @description Identifier for MD5 hash algorithm
 */
constant char HMAC_ALGORITHM_MD5[]    = 'MD5'

/**
 * @constant HMAC_ALGORITHM_SHA1
 * @description Identifier for SHA-1 hash algorithm
 */
constant char HMAC_ALGORITHM_SHA1[]   = 'SHA1'

/**
 * @constant HMAC_ALGORITHM_SHA256
 * @description Identifier for SHA-256 hash algorithm
 */
constant char HMAC_ALGORITHM_SHA256[] = 'SHA256'

/**
 * @constant HMAC_ALGORITHM_SHA384
 * @description Identifier for SHA-384 hash algorithm
 */
constant char HMAC_ALGORITHM_SHA384[] = 'SHA384'

/**
 * @constant HMAC_ALGORITHM_SHA512
 * @description Identifier for SHA-512 hash algorithm
 */
constant char HMAC_ALGORITHM_SHA512[] = 'SHA512'

/**
 * Error codes for HMAC operations
 */

/**
 * @constant HMAC_SUCCESS
 * @description Operation completed successfully
 */
constant integer HMAC_SUCCESS = 0

/**
 * @constant HMAC_ERROR_UNSUPPORTED_ALGORITHM
 * @description The specified algorithm is not supported
 */
constant integer HMAC_ERROR_UNSUPPORTED_ALGORITHM = 1

/**
 * @constant HMAC_ERROR_INVALID_KEY
 * @description The key parameter is invalid (empty or null)
 */
constant integer HMAC_ERROR_INVALID_KEY = 2

/**
 * @constant HMAC_ERROR_INVALID_MESSAGE
 * @description The message parameter is invalid (empty)
 */
constant integer HMAC_ERROR_INVALID_MESSAGE = 3


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_HMAC_H__
