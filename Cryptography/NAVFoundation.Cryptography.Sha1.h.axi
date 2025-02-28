PROGRAM_NAME='NAVFoundation.Cryptography.Sha1.h'

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

/**
 * @file NAVFoundation.Cryptography.Sha1.h.axi
 * @brief Header file for SHA-1 cryptographic hash function implementation.
 *
 * This header defines constants and data structures required for the SHA-1
 * hash implementation based on RFC3174. SHA-1 produces a 160-bit (20-byte)
 * hash value, typically rendered as a 40-character hexadecimal number.
 *
 * @note While SHA-1 is no longer considered secure for many cryptographic
 * purposes, it remains useful for integrity checking and legacy applications.
 *
 * @see https://www.rfc-editor.org/rfc/rfc3174
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1_H__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1_H__ 'NAVFoundation.Cryptography.Sha1.h'


DEFINE_CONSTANT

/**
 * @constant K
 * @description Constants defined in SHA-1 algorithm for each round.
 *
 * These values are used in the SHA-1 hash calculation process during the
 * four rounds (20 steps each) of processing.
 */
constant long K[] = {
    $5a827999,  // Round 1: 0-19 steps
    $6ed9eba1,  // Round 2: 20-39 steps
    $8f1bbcdc,  // Round 3: 40-59 steps
    $ca62c1d6   // Round 4: 60-79 steps
}

/**
 * @constant SHA_SUCCESS
 * @description Hash operation successful
 */
constant integer SHA_SUCCESS            = 0

/**
 * @constant SHA_NULL
 * @description Null pointer parameter
 */
constant integer SHA_NULL               = 1

/**
 * @constant SHA_INPUT_TOO_LONG
 * @description Input data too long
 */
constant integer SHA_INPUT_TOO_LONG     = 2

/**
 * @constant SHA_STATE_ERROR
 * @description Called Input after Result
 */
constant integer SHA_STATE_ERROR        = 3

/**
 * @constant SHA1_HASH_SIZE
 * @description Size of SHA-1 hash in bytes (160 bits)
 */
constant long SHA1_HASH_SIZE            = 20


DEFINE_TYPE

/**
 * @struct _NAVSha1Context
 * @description Context structure for SHA-1 hash operations.
 *
 * This structure holds context information for the SHA-1 hashing operation,
 * including intermediate hash values, message length tracking, and status flags.
 *
 * @property {long[SHA1_HASH_SIZE/4]} IntermediateHash - Message Digest (5 32-bit words)
 * @property {long} LengthLow - Lower 32 bits of message length in bits
 * @property {long} LengthHigh - Upper 32 bits of message length in bits
 * @property {integer} MessageBlockIndex - Index into message block array
 * @property {char[64]} MessageBlock - 512-bit message blocks
 * @property {integer} Computed - Flag indicating if digest is computed
 * @property {integer} Corrupted - Flag indicating if message digest is corrupted
 */
struct _NAVSha1Context {
    // Message Digest (5 32-bit words)
    long IntermediateHash[SHA1_HASH_SIZE / 4]

    // Message length in bits
    long LengthLow
    long LengthHigh

    // Index into message block array
    integer MessageBlockIndex

    // 512-bit message blocks
    char MessageBlock[64]

    // Is the digest computed?
    integer Computed

    // Is the message digest corrupted?
    integer Corrupted
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1_H__
