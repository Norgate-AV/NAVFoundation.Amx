PROGRAM_NAME='NAVFoundation.Cryptography.Md5.h'

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
 * @file NAVFoundation.Cryptography.Md5.h.axi
 * @brief Header file for MD5 cryptographic hash function implementation.
 *
 * This header defines constants and data structures required for the MD5
 * hash implementation based on RFC1321. MD5 produces a 128-bit (16-byte)
 * hash value, typically rendered as a 32-character hexadecimal number.
 *
 * @see https://www.rfc-editor.org/rfc/rfc1321
 *
 * @note While MD5 is no longer considered secure for cryptographic
 * purposes, it remains useful for checksums and legacy applications.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_MD5_H__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_MD5_H__ 'NAVFoundation.Cryptography.Md5.h'


DEFINE_CONSTANT

/**
 * @constant S11-S44
 * @description Shift constants for MD5Transform routine.
 * These values define the per-round shift amounts used in the MD5 algorithm.
 */
constant long S11 = 7
constant long S12 = 12
constant long S13 = 17
constant long S14 = 22

constant long S21 = 5
constant long S22 = 9
constant long S23 = 14
constant long S24 = 20

constant long S31 = 4
constant long S32 = 11
constant long S33 = 16
constant long S34 = 23

constant long S41 = 6
constant long S42 = 10
constant long S43 = 15
constant long S44 = 21

/**
 * @constant S
 * @description Combined shift amounts array for all rounds.
 * This provides indexed access to shift values for the algorithm.
 */
constant long S[64] = {
    07, 12, 17, 22, 07, 12, 17, 22, 07, 12, 17, 22, 07, 12, 17, 22,
    05, 09, 14, 20, 05, 09, 14, 20, 05, 09, 14, 20, 05, 09, 14, 20,
    04, 11, 16, 23, 04, 11, 16, 23, 04, 11, 16, 23, 04, 11, 16, 23,
    06, 10, 15, 21, 06, 10, 15, 21, 06, 10, 15, 21, 06, 10, 15, 21
}

/**
 * @constant K
 * @description Precomputed constants used in each round of the MD5 algorithm.
 * These are derived from the sine function and provide non-linearity.
 */
constant long K[64] = {
    $d76aa478, $e8c7b756, $242070db, $c1bdceee,
    $f57c0faf, $4787c62a, $a8304613, $fd469501,
    $698098d8, $8b44f7af, $ffff5bb1, $895cd7be,
    $6b901122, $fd987193, $a679438e, $49b40821,

    $f61e2562, $c040b340, $265e5a51, $e9b6c7aa,
    $d62f105d, $02441453, $d8a1e681, $e7d3fbc8,
    $21e1cde6, $c33707d6, $f4d50d87, $455a14ed,
    $a9e3e905, $fcefa3f8, $676f02d9, $8d2a4c8a,

    $fffa3942, $8771f681, $6d9d6122, $fde5380c,
    $a4beea44, $4bdecfa9, $f6bb4b60, $bebfbc70,
    $289b7ec6, $eaa127fa, $d4ef3085, $04881d05,
    $d9d4d039, $e6db99e5, $1fa27cf8, $c4ac5665,

    $f4292244, $432aff97, $ab9423a7, $fc93a039,
    $655b59c3, $8f0ccc92, $ffeff47d, $85845dd1,
    $6fa87e4f, $fe2ce6e0, $a3014314, $4e0811a1,
    $f7537e82, $bd3af235, $2ad7d2bb, $eb86d391
}

/**
 * @constant PADDING
 * @description Standard padding bytes used to extend messages to the required length.
 * The first byte is 0x80, followed by zeros, as per MD5 specification.
 */
constant char PADDING[64] = {
    $80, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,

    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,

    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00,

    $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00
}


DEFINE_TYPE

/**
 * @struct _NAVMd5Context
 * @description Context structure for MD5 hash operations.
 *
 * This structure holds state information for the MD5 hashing operation,
 * including intermediate hash values, message length tracking, and buffer.
 *
 * @property {long[4]} state - Contains the A,B,C,D hash state variables
 * @property {long[2]} count - Message length in bits (64-bit value)
 * @property {char[64]} buffer - 512-bit message block buffer
 * @property {char[16]} digest - Final 16-byte MD5 hash output
 */
struct _NAVMd5Context {
    // state (ABCD)
    long state[4]

    // number of bits, modulo 2^64 (lsb first)
    long count[2]

    // input buffer
    char buffer[64]

    // final output
    char digest[16]
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_MD5_H__
