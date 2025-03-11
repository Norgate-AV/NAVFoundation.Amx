PROGRAM_NAME='NAVFoundation.Cryptography.Md5'

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
 * @file NAVFoundation.Cryptography.Md5.axi
 * @brief Implementation of the MD5 cryptographic hash function.
 *
 * This module provides functions to compute MD5 hashes of data.
 * MD5 produces a 128-bit (16-byte) hash value, typically rendered
 * as a 32-character hexadecimal string.
 *
 * Implementation based on RFC1321: https://www.rfc-editor.org/rfc/rfc1321
 *
 * @note While MD5 is no longer considered secure for cryptographic
 * purposes, it remains useful for checksums and legacy applications.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_MD5__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_MD5__ 'NAVFoundation.Cryptography.Md5'

#include 'NAVFoundation.Cryptography.Md5.h.axi'
#include 'NAVFoundation.BinaryUtils.axi'


/**
 * @function NAVMd5GetHash
 * @public
 * @description Digests a string and returns the result as a 32-character hexadecimal string.
 * This is the main public API function for the MD5 module.
 *
 * @param {char[]} value - The input string to be hashed
 *
 * @returns {char[16]} 16-character binary array representing the MD5 hash value
 *
 * @example
 * stack_var char message[100]
 * stack_var char hash[16]
 *
 * message = 'Hello, World!'
 * hash = NAVMd5GetHash(message)
 * // hash now contains "$65, $a8, $e2, $7d, $88, $79, $28, $38, $31, $b6, $64, $bd, $8b, $7f, $0a, $d4"
 */
define_function char[16] NAVMd5GetHash(char value[]) {
    stack_var _NAVMd5Context context

    NAVMd5Init(context)
    NAVMd5Update(context, value, length_array(value))
    NAVMd5Final(context)

    return context.digest
}


/**
 * @function NAVMd5Init
 * @internal
 * @description Initializes an MD5 context for a new hash computation.
 *
 * This function sets up the context structure with initial values
 * as defined in the MD5 specification.
 *
 * @param {_NAVMd5Context} context - The MD5 context structure to initialize
 *
 * @returns {void}
 *
 * @see NAVMd5GetHash
 */
define_function NAVMd5Init(_NAVMd5Context context) {
    context.count[1] = 0
    context.count[2] = 0

    // Load magic initialization constants.
    context.state[1] = $67452301
    context.state[2] = $efcdab89
    context.state[3] = $98badcfe
    context.state[4] = $10325476
}


/**
 * @function NAVMd5GetCurrentByteCount
 * @internal
 * @description Retrieves the current number of bytes processed in the current block.
 *
 * @param {_NAVMd5Context} context - The MD5 context to query
 *
 * @returns {integer} The number of bytes processed (0-63)
 */
define_function integer NAVMd5GetCurrentByteCount(_NAVMd5Context context) {
    return type_cast((context.count[1] >> 3) & $3F)
}


/**
 * @function NAVMd5UpdateBitCount
 * @internal
 * @description Updates the bit counter in the MD5 context.
 *
 * @param {_NAVMd5Context} context - The MD5 context to update
 * @param {integer} length - The number of bytes being added
 *
 * @returns {void}
 */
define_function NAVMd5UpdateBitCount(_NAVMd5Context context, integer length) {
    stack_var long bits

    bits = length << 3

    context.count[1] = context.count[1] + bits
    context.count[2] = context.count[2] + (length >> 29)

    if (context.count[1] < bits) {
        context.count[2]++
    }
}


/**
 * @function NAVMd5GetChunkSize
 * @internal
 * @description Determines the size of the next data chunk to process.
 *
 * @param {integer} byteCount - The current byte count in the buffer
 * @param {integer} length - The total length of data being processed
 *
 * @returns {integer} The number of bytes to process in this chunk
 */
define_function integer NAVMd5GetChunkSize(integer byteCount, integer length) {
    if ((byteCount + length) > 64) {
        return (64 - byteCount)
    }

    return length
}


/**
 * @function NAVMd5Update
 * @internal
 * @description Processes the next portion of a message for MD5 hashing.
 *
 * This function updates the MD5 context with more input data, processing
 * complete blocks as they become available.
 *
 * @param {_NAVMd5Context} context - The MD5 context to update
 * @param {char[]} data - The input data to process
 * @param {integer} length - The length of the input data
 *
 * @returns {void}
 *
 * @see NAVMd5GetHash
 */
define_function NAVMd5Update(_NAVMd5Context context, char data[], integer length) {
    stack_var integer byteCount
    stack_var integer chunkSize
    stack_var integer start
    stack_var integer leftOver
    stack_var integer i

    if (length <= 0) {
        return
    }

    start = 0
    leftOver = length

    // Compute number of bytes mod 64
    byteCount = NAVMd5GetCurrentByteCount(context)

    // Update number of bits
    NAVMd5UpdateBitCount(context, length)

    // Transform an initial partial block
    if (byteCount > 0) {
        chunkSize = NAVMd5GetChunkSize(byteCount, length)

        context.buffer = "left_string(context.buffer, byteCount), mid_string(data, (start + 1), chunkSize)"

        if ((byteCount + chunkSize) < 64) {
            return
        }

        start = start + chunkSize
        leftOver = leftOver - chunkSize

        NAVMd5Transform(context.state, context.buffer)
    }

    // Transform as many times as possible.
    for (; leftOver >= 64; leftOver = leftOver - 64, start = start + 64) {
        NAVMd5Transform(context.state, "right_string(data, length_array(data) - start)")
    }

    // Buffer remaining input
    if (leftOver > 0) {
        context.buffer = right_string(data, length_array(data) - start)
    }
}


/**
 * @function NAVMd5Transform
 * @internal
 * @description Performs the core MD5 transformation algorithm on a 64-byte block.
 * This implements the main computation of the MD5 algorithm.
 *
 * @param {long[]} state - The MD5 state array (A,B,C,D values)
 * @param {char[]} block - The 64-byte block to process
 *
 * @returns {void}
 */
define_function NAVMd5Transform(long state[], char block[]) {
    stack_var long a
    stack_var long b
    stack_var long c
    stack_var long d
    stack_var long t
    stack_var long x[16]

    a = state[1]
    b = state[2]
    c = state[3]
    d = state[4]

    NAVMd5Decode(x, block, 64)

    // Round 1
    MD5_FF(a, b, c, d,  x[1], MD5_S11, $d76aa478, t, x, 0)
    MD5_FF(d, a, b, c,  x[2], MD5_S12, $e8c7b756, t, x, 1)
    MD5_FF(c, d, a, b,  x[3], MD5_S13, $242070db, t, x, 2)
    MD5_FF(b, c, d, a,  x[4], MD5_S14, $c1bdceee, t, x, 3)
    MD5_FF(a, b, c, d,  x[5], MD5_S11, $f57c0faf, t, x, 4)
    MD5_FF(d, a, b, c,  x[6], MD5_S12, $4787c62a, t, x, 5)
    MD5_FF(c, d, a, b,  x[7], MD5_S13, $a8304613, t, x, 6)
    MD5_FF(b, c, d, a,  x[8], MD5_S14, $fd469501, t, x, 7)
    MD5_FF(a, b, c, d,  x[9], MD5_S11, $698098d8, t, x, 8)
    MD5_FF(d, a, b, c, x[10], MD5_S12, $8b44f7af, t, x, 9)
    MD5_FF(c, d, a, b, x[11], MD5_S13, $ffff5bb1, t, x, 10)
    MD5_FF(b, c, d, a, x[12], MD5_S14, $895cd7be, t, x, 11)
    MD5_FF(a, b, c, d, x[13], MD5_S11, $6b901122, t, x, 12)
    MD5_FF(d, a, b, c, x[14], MD5_S12, $fd987193, t, x, 13)
    MD5_FF(c, d, a, b, x[15], MD5_S13, $a679438e, t, x, 14)
    MD5_FF(b, c, d, a, x[16], MD5_S14, $49b40821, t, x, 15)

    // Round 2
    MD5_GG(a, b, c, d,  x[2], MD5_S21, $f61e2562, t, x, 1)
    MD5_GG(d, a, b, c,  x[7], MD5_S22, $c040b340, t, x, 6)
    MD5_GG(c, d, a, b, x[12], MD5_S23, $265e5a51, t, x, 11)
    MD5_GG(b, c, d, a,  x[1], MD5_S24, $e9b6c7aa, t, x, 0)
    MD5_GG(a, b, c, d,  x[6], MD5_S21, $d62f105d, t, x, 5)
    MD5_GG(d, a, b, c, x[11], MD5_S22, $02441453, t, x, 10)
    MD5_GG(c, d, a, b, x[16], MD5_S23, $d8a1e681, t, x, 15)
    MD5_GG(b, c, d, a,  x[5], MD5_S24, $e7d3fbc8, t, x, 4)
    MD5_GG(a, b, c, d, x[10], MD5_S21, $21e1cde6, t, x, 9)
    MD5_GG(d, a, b, c, x[15], MD5_S22, $c33707d6, t, x, 14)
    MD5_GG(c, d, a, b,  x[4], MD5_S23, $f4d50d87, t, x, 3)
    MD5_GG(b, c, d, a,  x[9], MD5_S24, $455a14ed, t, x, 8)
    MD5_GG(a, b, c, d, x[14], MD5_S21, $a9e3e905, t, x, 13)
    MD5_GG(d, a, b, c,  x[3], MD5_S22, $fcefa3f8, t, x, 2)
    MD5_GG(c, d, a, b,  x[8], MD5_S23, $676f02d9, t, x, 7)
    MD5_GG(b, c, d, a, x[13], MD5_S24, $8d2a4c8a, t, x, 12)

    // Round 3
    MD5_HH(a, b, c, d,  x[6], MD5_S31, $fffa3942, t, x, 5)
    MD5_HH(d, a, b, c,  x[9], MD5_S32, $8771f681, t, x, 8)
    MD5_HH(c, d, a, b, x[12], MD5_S33, $6d9d6122, t, x, 11)
    MD5_HH(b, c, d, a, x[15], MD5_S34, $fde5380c, t, x, 14)
    MD5_HH(a, b, c, d,  x[1], MD5_S31, $a4beea44, t, x, 1)
    MD5_HH(d, a, b, c,  x[5], MD5_S32, $4bdecfa9, t, x, 4)
    MD5_HH(c, d, a, b,  x[8], MD5_S33, $f6bb4b60, t, x, 7)
    MD5_HH(b, c, d, a, x[11], MD5_S34, $bebfbc70, t, x, 10)
    MD5_HH(a, b, c, d, x[14], MD5_S31, $289b7ec6, t, x, 13)
    MD5_HH(d, a, b, c,  x[1], MD5_S32, $eaa127fa, t, x, 0)
    MD5_HH(c, d, a, b,  x[4], MD5_S33, $d4ef3085, t, x, 3)
    MD5_HH(b, c, d, a,  x[7], MD5_S34, $04881d05, t, x, 6)
    MD5_HH(a, b, c, d, x[10], MD5_S31, $d9d4d039, t, x, 9)
    MD5_HH(d, a, b, c, x[13], MD5_S32, $e6db99e5, t, x, 12)
    MD5_HH(c, d, a, b, x[16], MD5_S33, $1fa27cf8, t, x, 15)
    MD5_HH(b, c, d, a,  x[3], MD5_S34, $c4ac5665, t, x, 2)

    // Round 4
    MD5_II(a, b, c, d,  x[1], MD5_S41, $f4292244, t, x, 0)
    MD5_II(d, a, b, c,  x[8], MD5_S42, $432aff97, t, x, 7)
    MD5_II(c, d, a, b, x[15], MD5_S43, $ab9423a7, t, x, 14)
    MD5_II(b, c, d, a,  x[6], MD5_S44, $fc93a039, t, x, 5)
    MD5_II(a, b, c, d, x[13], MD5_S41, $655b59c3, t, x, 12)
    MD5_II(d, a, b, c,  x[4], MD5_S42, $8f0ccc92, t, x, 3)
    MD5_II(c, d, a, b, x[11], MD5_S43, $ffeff47d, t, x, 10)
    MD5_II(b, c, d, a,  x[2], MD5_S44, $85845dd1, t, x, 1)
    MD5_II(a, b, c, d,  x[9], MD5_S41, $6fa87e4f, t, x, 8)
    MD5_II(d, a, b, c, x[16], MD5_S42, $fe2ce6e0, t, x, 15)
    MD5_II(c, d, a, b,  x[7], MD5_S43, $a3014314, t, x, 6)
    MD5_II(b, c, d, a, x[14], MD5_S44, $4e0811a1, t, x, 13)
    MD5_II(a, b, c, d,  x[5], MD5_S41, $f7537e82, t, x, 4)
    MD5_II(d, a, b, c, x[12], MD5_S42, $bd3af235, t, x, 11)
    MD5_II(c, d, a, b,  x[3], MD5_S43, $2ad7d2bb, t, x, 2)
    MD5_II(b, c, d, a, x[10], MD5_S44, $eb86d391, t, x, 9)

    state[1] = state[1] + a
    state[2] = state[2] + b
    state[3] = state[3] + c
    state[4] = state[4] + d
}


/**
 * @function NAVMd5GetPaddingLength
 * @internal
 * @description Calculates the padding length required for MD5 finalization.
 *
 * @param {_NAVMd5Context} context - The MD5 context to analyze
 *
 * @returns {integer} The number of padding bytes required
 */
define_function integer NAVMd5GetPaddingLength(_NAVMd5Context context) {
    stack_var integer count

    count = NAVMd5GetCurrentByteCount(context)

    if (count < 56) {
        return (56 - count)
    }

    return (120 - count)
}


/**
 * @function NAVMd5Decode
 * @internal
 * @description Converts a byte array to an array of 32-bit words.
 *
 * @param {long[]} output - The 32-bit word array destination
 * @param {char[]} input - The byte array source
 * @param {integer} length - The number of bytes to convert
 *
 * @returns {void}
 *
 * @note Assumes length is a multiple of 4
 */
define_function NAVMd5Decode(long output[], char input[], integer length) {
    stack_var integer i
    stack_var integer j

    for (i = 0, j = 0; j < length; i++, j = j + 4) {
        output[(i + 1)] =   input[(j + 1) + 0] << 00 |
                            input[(j + 1) + 1] << 08 |
                            input[(j + 1) + 2] << 16 |
                            input[(j + 1) + 3] << 24
    }

    set_length_array(output, j)
}


/**
 * @function NAVMd5Encode
 * @internal
 * @description Converts an array of 32-bit words to a byte array.
 *
 * @param {char[]} output - The byte array destination
 * @param {long[]} input - The 32-bit word array source
 * @param {integer} length - The number of bytes to convert
 *
 * @returns {void}
 *
 * @note Assumes length is a multiple of 4
 */
define_function NAVMd5Encode(char output[], long input[], integer length) {
    stack_var integer i
    stack_var integer j

    for (i = 0, j = 0; j < length; i++, j = j + 4) {
        output[j + 1] = type_cast((input[(i + 1)] >> 00) & $FF)
        output[j + 2] = type_cast((input[(i + 1)] >> 08) & $FF)
        output[j + 3] = type_cast((input[(i + 1)] >> 16) & $FF)
        output[j + 4] = type_cast((input[(i + 1)] >> 24) & $FF)
    }

    set_length_array(output, j)
}


/**
 * @function NAVMd5Final
 * @internal
 * @description Finalizes the MD5 hash computation and produces the final digest.
 *
 * This function completes the MD5 hash computation by adding padding and
 * length information, then producing the final hash value.
 *
 * @param {_NAVMd5Context} context - The MD5 context to finalize
 *
 * @returns {void}
 *
 * @see NAVMd5GetHash
 */
define_function NAVMd5Final(_NAVMd5Context context){
    stack_var char bits[8]

    // Save number of bits
    NAVMd5Encode(bits, context.count, 8)

    // Pad out to 56 mod 64.
    NAVMd5Update(context, MD5_PADDING, NAVMd5GetPaddingLength(context))

    // Append length (before padding)
    NAVMd5Update(context, bits, 8)

    // Store state in digest
    NAVMd5Encode(context.digest, context.state, 16)
}


/**
 * @function MD5_F
 * @internal
 * @description Basic MD5 function F.
 *
 * @param {long} x - Input value
 * @param {long} y - Input value
 * @param {long} z - Input value
 *
 * @returns {long} Result of the F function
 */
define_function long MD5_F(long x, long y, long z) { return ((x & y) | (~x & z)) }


/**
 * @function MD5_G
 * @internal
 * @description Basic MD5 function G.
 *
 * @param {long} x - Input value
 * @param {long} y - Input value
 * @param {long} z - Input value
 *
 * @returns {long} Result of the G function
 */
define_function long MD5_G(long x, long y, long z) { return ((x & z) | (y & ~z)) }


/**
 * @function MD5_H
 * @internal
 * @description Basic MD5 function H.
 *
 * @param {long} x - Input value
 * @param {long} y - Input value
 * @param {long} z - Input value
 *
 * @returns {long} Result of the H function
 */
define_function long MD5_H(long x, long y, long z) { return (x ^ y ^ z)          }


/**
 * @function MD5_I
 * @internal
 * @description Basic MD5 function I.
 *
 * @param {long} x - Input value
 * @param {long} y - Input value
 * @param {long} z - Input value
 *
 * @returns {long} Result of the I function
 */
define_function long MD5_I(long x, long y, long z) { return (y ^ (x | ~z))       }


/**
 * @function MD5_FF
 * @internal
 * @description MD5 transformation function for round 1.
 *
 * @param {long} a - Input value
 * @param {long} b - Input value
 * @param {long} c - Input value
 * @param {long} d - Input value
 * @param {long} x - Input value
 * @param {long} s - Shift amount
 * @param {long} ac - Constant value
 * @param {long} t - Temporary value
 * @param {long[]} xx - Array of input values
 * @param {long} k - Index into the array
 *
 * @returns {void}
 */
define_function MD5_FF(long a, long b, long c, long d, long x, long s, long ac, long t, long xx[], long k) {
    k++
    // a = a + F(b, c, d) + x + ac
    t = a + MD5_F(b, c, d) + xx[k] + ac
    // a = NAVBitRotateLeft(a, s)
    a = NAVBitRotateLeft(t, s)
    a = a + b
}


/**
 * @function MD5_GG
 * @internal
 * @description MD5 transformation function for round 2.
 *
 * @param {long} a - Input value
 * @param {long} b - Input value
 * @param {long} c - Input value
 * @param {long} d - Input value
 * @param {long} x - Input value
 * @param {long} s - Shift amount
 * @param {long} ac - Constant value
 * @param {long} t - Temporary value
 * @param {long[]} xx - Array of input values
 * @param {long} k - Index into the array
 *
 * @returns {void}
 */
define_function MD5_GG(long a, long b, long c, long d, long x, long s, long ac, long t, long xx[], long k) {
    k++
    // a = a + G(b, c, d) + x + ac
    t = a + MD5_G(b, c, d) + xx[k] + ac
    // a = NAVBitRotateLeft(a, s)
    a = NAVBitRotateLeft(t, s)
    a = a + b
}


/**
 * @function MD5_HH
 * @internal
 * @description MD5 transformation function for round 3.
 *
 * @param {long} a - Input value
 * @param {long} b - Input value
 * @param {long} c - Input value
 * @param {long} d - Input value
 * @param {long} x - Input value
 * @param {long} s - Shift amount
 * @param {long} ac - Constant value
 * @param {long} t - Temporary value
 * @param {long[]} xx - Array of input values
 * @param {long} k - Index into the array
 *
 * @returns {void}
 */
define_function MD5_HH(long a, long b, long c, long d, long x, long s, long ac, long t, long xx[], long k) {
    k++
    // a = a + H(b, c, d) + x + ac
    t = a + MD5_H(b, c, d) + xx[k] + ac
    // a = NAVBitRotateLeft(a, s)
    a = NAVBitRotateLeft(t, s)
    a = a + b
}


/**
 * @function MD5_II
 * @internal
 * @description MD5 transformation function for round 4.
 *
 * @param {long} a - Input value
 * @param {long} b - Input value
 * @param {long} c - Input value
 * @param {long} d - Input value
 * @param {long} x - Input value
 * @param {long} s - Shift amount
 * @param {long} ac - Constant value
 * @param {long} t - Temporary value
 * @param {long[]} xx - Array of input values
 * @param {long} k - Index into the array
 *
 * @returns {void}
 */
define_function MD5_II(long a, long b, long c, long d, long x, long s, long ac, long t, long xx[], long k) {
    k++
    // a = a + I(b, c, d) + x + ac
    t = a + MD5_I(b, c, d) + xx[k] + ac
    // a = NAVBitRotateLeft(a, s)
    a = NAVBitRotateLeft(t, s)
    a = a + b
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_MD5__
