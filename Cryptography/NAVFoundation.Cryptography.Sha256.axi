PROGRAM_NAME='NAVFoundation.Cryptography.Sha256'

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
 * @file NAVFoundation.Cryptography.Sha256.axi
 * @brief Implementation of the SHA-256 cryptographic hash function.
 *
 * This module provides functions to compute SHA-256 hashes of data.
 * SHA-256 produces a 256-bit (32-byte) hash value, typically rendered
 * as a 64-character hexadecimal number.
 *
 * Implementation based on RFC6234: https://www.rfc-editor.org/rfc/rfc6234
 *
 * @copyright 2023 Norgate AV Services Limited
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_SHA256__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_SHA256__ 'NAVFoundation.Cryptography.Sha256'

#include 'NAVFoundation.Cryptography.Sha256.h.axi'
#include 'NAVFoundation.BinaryUtils.axi'
#include 'NAVFoundation.Encoding.axi'

/**
 * @function NAVSha256GetHash
 * @public
 * @description Digests a string and returns the result as a 32-byte digest.
 * This is the main public API function for the SHA-256 module.
 *
 * @param {char[]} value - The input string to be hashed
 *
 * @returns {char[32]} 32-byte SHA-256 hash value, or empty string on error
 *
 * @example
 * stack_var char message[100]
 * stack_var char digest[32]
 *
 * message = 'Hello, World!'
 * digest = NAVSha256GetHash(message)
 */
define_function char[32] NAVSha256GetHash(char value[]) {
    stack_var integer error
    stack_var _NAVSha256Context context
    stack_var char digest[SHA256_HASH_SIZE]

    error = NAVSha256Reset(context)

    if (error > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha256Reset Error => ', itoa(error)")
        return ""
    }

    error = NAVSha256Input(context, value, length_array(value))

    if (error > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha256Input Error => ', itoa(error)")
        return ""
    }

    error = NAVSha256Result(context, digest)

    if (error > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha256Result Error => ', itoa(error), ', could not compute digest'")
        return ""
    }

    return digest
}

/**
 * @function NAVSha256Reset
 * @internal
 * @description Initializes the context in preparation for computing a new SHA-256 message digest.
 * This sets up the initial hash values and clears the message block.
 *
 * @param {_NAVSha256Context} context - The context to reset
 *
 * @returns {integer} SHA_SUCCESS on success, or an error code
 */
define_function integer NAVSha256Reset(_NAVSha256Context context) {
    context.LengthLow           = 0
    context.LengthHigh          = 0
    context.MessageBlockIndex   = 0

    // Initial hash values (first 32 bits of the fractional parts of the square roots of the first 8 primes 2..19)
    context.IntermediateHash[1] = $6a09e667
    context.IntermediateHash[2] = $bb67ae85
    context.IntermediateHash[3] = $3c6ef372
    context.IntermediateHash[4] = $a54ff53a
    context.IntermediateHash[5] = $510e527f
    context.IntermediateHash[6] = $9b05688c
    context.IntermediateHash[7] = $1f83d9ab
    context.IntermediateHash[8] = $5be0cd19

    context.Computed    = false
    context.Corrupted   = false

    context.MessageBlock = ""

    return SHA_SUCCESS
}

/**
 * @function NAVSha256Result
 * @internal
 * @description Returns the 256-bit message digest into the digest array.
 * If the digest hasn't been computed yet, it pads the message and completes the calculation.
 *
 * @param {_NAVSha256Context} context - The context to use to calculate the SHA-256 hash
 * @param {char[SHA256_HASH_SIZE]} digest - Where the digest is returned
 *
 * @returns {integer} SHA_SUCCESS on success, or an error code
 */
define_function integer NAVSha256Result(_NAVSha256Context context, char digest[SHA256_HASH_SIZE]) {
    if (context.Corrupted) {
        return context.Corrupted
    }

    if (!context.Computed) {
        NAVSha256PadMessage(context)

        context.MessageBlock = ""

        context.LengthLow = 0
        context.LengthHigh = 0
        context.Computed = true
    }

    // Output all 8 32-bit words as bytes in big-endian format
    digest = "
        NAVLongToByteArrayBE(context.IntermediateHash[1]),
        NAVLongToByteArrayBE(context.IntermediateHash[2]),
        NAVLongToByteArrayBE(context.IntermediateHash[3]),
        NAVLongToByteArrayBE(context.IntermediateHash[4]),
        NAVLongToByteArrayBE(context.IntermediateHash[5]),
        NAVLongToByteArrayBE(context.IntermediateHash[6]),
        NAVLongToByteArrayBE(context.IntermediateHash[7]),
        NAVLongToByteArrayBE(context.IntermediateHash[8])
    "

    return SHA_SUCCESS
}

/**
 * @function NAVSha256Input
 * @internal
 * @description Accepts an array of octets as the next portion of the message.
 * This function can be called multiple times to process large messages in chunks.
 *
 * @param {_NAVSha256Context} context - The SHA context to update
 * @param {char[]} message - An array of characters representing the next portion of the message
 * @param {integer} length - The length of the message in message_array
 *
 * @returns {integer} SHA_SUCCESS on success, or an error code
 */
define_function integer NAVSha256Input(_NAVSha256Context context, char message[], integer length) {
    stack_var integer messageIndex
    stack_var long oldLengthLow

    if (!length) {
        return SHA_SUCCESS
    }

    if (context.Computed) {
        context.Corrupted = SHA_STATE_ERROR
        return SHA_STATE_ERROR
    }

    if (context.Corrupted) {
        return context.Corrupted
    }

    messageIndex = 0

    while (length > 0 && !context.Corrupted) {
        // Append the byte to the message block
        context.MessageBlock = "context.MessageBlock, message[(messageIndex + 1)] & $FF"
        context.MessageBlockIndex++

        // Update message length - improved overflow detection
        oldLengthLow = context.LengthLow
        context.LengthLow = context.LengthLow + 8
        if (context.LengthLow < oldLengthLow) {  // Detect overflow
            context.LengthHigh++
            if (context.LengthHigh == 0) {
                // Message is too long
                context.Corrupted = SHA_FAILURE
            }
        }

        // Process the block if it's full
        if (context.MessageBlockIndex == 64) {
            NAVSha256ProcessMessageBlock(context)
        }

        messageIndex++
        length--
    }

    return SHA_SUCCESS
}

/**
 * @function NAVSha256Ch
 * @internal
 * @description SHA-256 Ch (Choose) function: ch(x,y,z) = (x AND y) XOR (NOT x AND z)
 * This function implements the SHA-256 Ch logical function, which chooses bits from
 * y or z depending on the value of the corresponding bit in x.
 *
 * @param {long} x - First input parameter
 * @param {long} y - Second input parameter
 * @param {long} z - Third input parameter
 *
 * @returns {long} Result of the Ch function
 */
define_function long NAVSha256Ch(long x, long y, long z) {
    return ((x & y) ^ ((~x) & z))
}

/**
 * @function NAVSha256Maj
 * @internal
 * @description SHA-256 Maj (Majority) function: maj(x,y,z) = (x AND y) XOR (x AND z) XOR (y AND z)
 * This function implements the SHA-256 Maj logical function, which returns the majority
 * bit value among the corresponding bits in x, y, and z.
 *
 * @param {long} x - First input parameter
 * @param {long} y - Second input parameter
 * @param {long} z - Third input parameter
 *
 * @returns {long} Result of the Maj function
 */
define_function long NAVSha256Maj(long x, long y, long z) {
    return ((x & y) ^ (x & z) ^ (y & z))
}

/**
 * @function NAVSha256SIGMA0
 * @internal
 * @description SHA-256 SIGMA0 function: ROTR^2(x) XOR ROTR^13(x) XOR ROTR^22(x)
 * This function implements the SHA-256 SIGMA0 (uppercase sigma 0) transformation
 * used in the compression function.
 *
 * @param {long} x - Input value
 *
 * @returns {long} Result of the SIGMA0 function
 */
define_function long NAVSha256SIGMA0(long x) {
    return (NAVBitRotateRight(x, 2) ^ NAVBitRotateRight(x, 13) ^ NAVBitRotateRight(x, 22))
}

/**
 * @function NAVSha256SIGMA1
 * @internal
 * @description SHA-256 SIGMA1 function: ROTR^6(x) XOR ROTR^11(x) XOR ROTR^25(x)
 * This function implements the SHA-256 SIGMA1 (uppercase sigma 1) transformation
 * used in the compression function.
 *
 * @param {long} x - Input value
 *
 * @returns {long} Result of the SIGMA1 function
 */
define_function long NAVSha256SIGMA1(long x) {
    return (NAVBitRotateRight(x, 6) ^ NAVBitRotateRight(x, 11) ^ NAVBitRotateRight(x, 25))
}

/**
 * @function NAVSha256SigmaSmall0
 * @internal
 * @description SHA-256 small sigma0 function: ROTR^7(x) XOR ROTR^18(x) XOR SHR^3(x)
 * This function implements the SHA-256 sigma0 (lowercase sigma 0) transformation
 * used in the message schedule preparation.
 *
 * @param {long} x - Input value
 *
 * @returns {long} Result of the small sigma0 function
 */
define_function long NAVSha256SigmaSmall0(long x) {
    return (NAVBitRotateRight(x, 7) ^ NAVBitRotateRight(x, 18) ^ (x >> 3))
}

/**
 * @function NAVSha256SigmaSmall1
 * @internal
 * @description SHA-256 small sigma1 function: ROTR^17(x) XOR ROTR^19(x) XOR SHR^10(x)
 * This function implements the SHA-256 sigma1 (lowercase sigma 1) transformation
 * used in the message schedule preparation.
 *
 * @param {long} x - Input value
 *
 * @returns {long} Result of the small sigma1 function
 */
define_function long NAVSha256SigmaSmall1(long x) {
    return (NAVBitRotateRight(x, 17) ^ NAVBitRotateRight(x, 19) ^ (x >> 10))
}

/**
 * @function NAVSha256ProcessMessageBlock
 * @internal
 * @description Process the next 512 bits of the message stored in the MessageBlock array.
 * This is the core function of the SHA-256 algorithm that applies the compression function
 * to transform a 512-bit block into the next hash state.
 *
 * @param {_NAVSha256Context} context - The SHA context containing the block to process
 */
define_function NAVSha256ProcessMessageBlock(_NAVSha256Context context) {
    stack_var long w[64]
    stack_var integer t
    stack_var long a, b, c, d, e, f, g, h
    stack_var long temp1, temp2

    // Initialize the first 16 words in array w
    for (t = 0; t < 16; t++) {
        w[(t + 1)] = (context.MessageBlock[(t * 4) + 1] & $FF) << 24
        w[(t + 1)] = w[(t + 1)] | ((context.MessageBlock[(t * 4) + 2] & $FF) << 16)
        w[(t + 1)] = w[(t + 1)] | ((context.MessageBlock[(t * 4) + 3] & $FF) << 8)
        w[(t + 1)] = w[(t + 1)] | (context.MessageBlock[(t * 4) + 4] & $FF)
    }

    // Extend the first 16 words into the remaining 48 words w[16..63]
    for (t = 16; t < 64; t++) {
        // Updated to use the new naming convention
        w[(t + 1)] = NAVSha256SigmaSmall1(w[(t - 2) + 1]) + w[(t - 7) + 1] + NAVSha256SigmaSmall0(w[(t - 15) + 1]) + w[(t - 16) + 1]
    }

    // Initialize working variables to current hash value
    a = context.IntermediateHash[1]
    b = context.IntermediateHash[2]
    c = context.IntermediateHash[3]
    d = context.IntermediateHash[4]
    e = context.IntermediateHash[5]
    f = context.IntermediateHash[6]
    g = context.IntermediateHash[7]
    h = context.IntermediateHash[8]

    // Computation loop (64 rounds)
    for (t = 0; t < 64; t++) {
        // Updated to use the new naming convention
        temp1 = h + NAVSha256SIGMA1(e) + NAVSha256Ch(e, f, g) + K[(t + 1)] + w[(t + 1)]
        temp2 = NAVSha256SIGMA0(a) + NAVSha256Maj(a, b, c)

        h = g
        g = f
        f = e
        e = d + temp1
        d = c
        c = b
        b = a
        a = temp1 + temp2
    }

    // Add the compressed chunk to the current hash value
    context.IntermediateHash[1] = context.IntermediateHash[1] + a
    context.IntermediateHash[2] = context.IntermediateHash[2] + b
    context.IntermediateHash[3] = context.IntermediateHash[3] + c
    context.IntermediateHash[4] = context.IntermediateHash[4] + d
    context.IntermediateHash[5] = context.IntermediateHash[5] + e
    context.IntermediateHash[6] = context.IntermediateHash[6] + f
    context.IntermediateHash[7] = context.IntermediateHash[7] + g
    context.IntermediateHash[8] = context.IntermediateHash[8] + h

    // Reset message block index
    context.MessageBlock = ""
    context.MessageBlockIndex = 0
}

/**
 * @function NAVSha256PadMessage
 * @internal
 * @description Pads the message according to SHA-256 requirements.
 * According to the standard, the message must be padded to an even
 * 512 bits. The first padding bit must be a '1'. The last 64 bits
 * represent the length of the original message in bits. All bits in between
 * should be 0.
 *
 * @param {_NAVSha256Context} context - The context to pad
 */
define_function NAVSha256PadMessage(_NAVSha256Context context) {
    // Check if the current message block is too small to hold padding and length
    if (context.MessageBlockIndex > 55) {
        context.MessageBlock = "context.MessageBlock, $80"
        context.MessageBlockIndex++

        // Fill with zeros until end of block
        while (context.MessageBlockIndex < 64) {
            context.MessageBlock = "context.MessageBlock, $00"
            context.MessageBlockIndex++
        }

        NAVSha256ProcessMessageBlock(context)

        // Fill new block with zeros up to the last 8 bytes
        while (context.MessageBlockIndex < 56) {
            context.MessageBlock = "context.MessageBlock, $00"
            context.MessageBlockIndex++
        }
    }
    else {
        // Add the padding bit (1 followed by zeros)
        context.MessageBlock = "context.MessageBlock, $80"
        context.MessageBlockIndex++

        // Fill with zeros until the last 8 bytes
        while (context.MessageBlockIndex < 56) {
            context.MessageBlock = "context.MessageBlock, $00"
            context.MessageBlockIndex++
        }
    }

    // Append the length in bits as a 64-bit big-endian integer
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthHigh >> 24)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthHigh >> 16)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthHigh >> 8)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthHigh)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthLow >> 24)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthLow >> 16)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthLow >> 8)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthLow)"

    NAVSha256ProcessMessageBlock(context)
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_SHA256__
