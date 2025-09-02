PROGRAM_NAME='NAVFoundation.Cryptography.Sha1'

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
 * @file NAVFoundation.Cryptography.Sha1.axi
 * @brief Implementation of the SHA-1 cryptographic hash function.
 *
 * This module provides functions to compute SHA-1 hashes of data.
 * SHA-1 produces a 160-bit (20-byte) hash value, typically rendered
 * as a 40-character hexadecimal number.
 *
 * Implementation based on RFC3174: https://www.rfc-editor.org/rfc/rfc3174
 *
 * @note While SHA-1 is no longer considered secure for many cryptographic
 * purposes, it remains useful for integrity checking and legacy applications.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1__ 'NAVFoundation.Cryptography.Sha1'

#include 'NAVFoundation.Cryptography.Sha1.h.axi'
#include 'NAVFoundation.BinaryUtils.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


/**
 * @function NAVSha1GetHash
 * @public
 * @description Digests a string and returns the result as a 20-byte digest.
 * This is the main public API function for the SHA-1 module.
 *
 * @param {char[]} value - The input string to be hashed
 *
 * @returns {char[20]} 20-byte SHA-1 hash value, or empty string on error
 *
 * @example
 * stack_var char message[100]
 * stack_var char digest[20]
 *
 * message = 'Hello, World!'
 * digest = NAVSha1GetHash(message)
 *
 * @note The digest can be converted to a hex string for display purposes
 *       using NAVByteArrayToHexString from Encoding module
 */
define_function char[20] NAVSha1GetHash(char value[]) {
    stack_var integer error
    stack_var _NAVSha1Context context
    stack_var char digest[SHA1_HASH_SIZE]

    error = NAVSha1Reset(context)

    if (error > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha1Reset Error => ', itoa(error)")
        return ""
    }

    error = NAVSha1Input(context, value, length_array(value))

    if (error > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha1Input Error => ', itoa(error)")
        return ""
    }

    error = NAVSha1Result(context, digest)

    if (error > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha1Result Error => ', itoa(error), ', could not compute digest'")
        return ""
    }

    return digest
}


/**
 * @function NAVSha1Reset
 * @internal
 * @description Initializes the SHA1Context in preparation for computing a new SHA1 message digest.
 *
 * @param {_NAVSha1Context} context - The context to reset
 *
 * @returns {integer} SHA_SUCCESS on success, or an error code
 *
 * @see NAVSha1GetHash
 */
define_function integer NAVSha1Reset(_NAVSha1Context context) {
    context.LengthLow           = 0
    context.LengthHigh          = 0
    context.MessageBlockIndex   = 0

    context.IntermediateHash[1] = $67452301
    context.IntermediateHash[2] = $efcdab89
    context.IntermediateHash[3] = $98badcfe
    context.IntermediateHash[4] = $10325476
    context.IntermediateHash[5] = $c3d2e1f0

    context.Computed    = false
    context.Corrupted   = false

    context.MessageBlock = ""

    return SHA1_SUCCESS
}


/**
 * @function NAVSha1Result
 * @internal
 * @description Returns the 160-bit message digest into the Message_Digest array.
 *
 * @param {_NAVSha1Context} context - The context to use to calculate the SHA-1 hash
 * @param {char[SHA1_HASH_SIZE]} digest - Where the digest is returned
 *
 * @returns {integer} SHA_SUCCESS on success, or an error code
 *
 * @note The first octet of hash is stored in the 0th element,
 *       the last octet of hash in the 19th element.
 *
 * @see NAVSha1GetHash
 */
define_function integer NAVSha1Result(_NAVSha1Context context, char digest[SHA1_HASH_SIZE]) {
    if (context.Corrupted) {
        return context.Corrupted
    }

    if (!context.Computed) {
        NAVSha1PadMessage(context)

        context.MessageBlock = ""

        context.LengthLow = 0
        context.LengthHigh = 0
        context.Computed = true
    }

    digest = "
        NAVLongToByteArrayBE(context.IntermediateHash[1]),
        NAVLongToByteArrayBE(context.IntermediateHash[2]),
        NAVLongToByteArrayBE(context.IntermediateHash[3]),
        NAVLongToByteArrayBE(context.IntermediateHash[4]),
        NAVLongToByteArrayBE(context.IntermediateHash[5])
    "

    return SHA1_SUCCESS
}


/**
 * @function NAVSha1Input
 * @internal
 * @description Accepts an array of octets as the next portion of the message.
 *
 * @param {_NAVSha1Context} context - The SHA context to update
 * @param {char[]} message - An array of characters representing the next portion of the message
 * @param {integer} length - The length of the message in message_array
 *
 * @returns {integer} SHA_SUCCESS on success, or an error code
 *
 * @see NAVSha1GetHash
 */
define_function integer NAVSha1Input(_NAVSha1Context context, char message[], integer length) {
    stack_var integer messageIndex

    if (!length) {
        return SHA1_SUCCESS
    }

    if (context.Computed) {
        context.Corrupted = SHA1_STATE_ERROR
        return SHA1_STATE_ERROR
    }

    if (context.Corrupted) {
        return context.Corrupted
    }

    messageIndex = 0

    while (length > 0 && !context.Corrupted) {
        context.MessageBlock = "context.MessageBlock, message[(messageIndex + 1)] & $FF"
        context.MessageBlockIndex++

        context.LengthLow = context.LengthLow + 8

        if (context.LengthLow == 0) {
            context.LengthHigh++

            if (context.LengthHigh == 0) {
                // Message is too long
                context.Corrupted = true
            }
        }

        if (context.MessageBlockIndex == 64) {
            NAVSha1ProcessMessageBlock(context)
        }

        messageIndex++
        length--
    }

    return SHA1_SUCCESS
}


/**
 * @function NAVSha1ProcessMessageBlock
 * @internal
 * @description Processes the next 512 bits of the message stored in the Message_Block array.
 *
 * @param {_NAVSha1Context} context - The SHA context containing the block to process
 *
 * @returns {void}
 *
 * @note Many of the variable names in this code, especially the
 *       single character names, were used because those were the
 *       names used in the RFC publication.
 */
define_function NAVSha1ProcessMessageBlock(_NAVSha1Context context) {
    stack_var long a
    stack_var long b
    stack_var long c
    stack_var long d
    stack_var long e
    stack_var integer i
    stack_var long w[80]
    stack_var long temp

    /**
    *  Initialize the first 16 words in the array w
    **/
    for (i = 0; i < 16; i++) {
        w[(i + 1)] = (context.MessageBlock[(i * 4) + 1] & $FF) << 24
        w[(i + 1)] = w[(i + 1)] | (context.MessageBlock[(i * 4) + 2] & $FF) << 16
        w[(i + 1)] = w[(i + 1)] | (context.MessageBlock[(i * 4) + 3] & $FF) << 08
        w[(i + 1)] = w[(i + 1)] | (context.MessageBlock[(i * 4) + 4] & $FF) << 00
    }

    for (i = 16; i < 80; i++) {
        w[(i + 1)] = NAVBitRotateLeft((w[(i + 1) - 3] ^ w[(i + 1) - 8] ^ w[(i + 1) - 14] ^ w[(i + 1) - 16]), 1)
    }

    a = context.IntermediateHash[1]
    b = context.IntermediateHash[2]
    c = context.IntermediateHash[3]
    d = context.IntermediateHash[4]
    e = context.IntermediateHash[5]

    for (i = 0; i < 20; i++) {
        temp = NAVBitRotateLeft(a, 5) + ((b & c) | (~b & d)) + e + w[(i + 1)] + SHA1_K[(0) + 1]

        e = d
        d = c
        c = NAVBitRotateLeft(b, 30)
        b = a

        a = temp
    }

    for (i = 20; i < 40; i++) {
        temp = NAVBitRotateLeft(a, 5) + (b ^ c ^ d) + e + w[(i + 1)] + SHA1_K[(1) + 1]

        e = d
        d = c
        c = NAVBitRotateLeft(b, 30)
        b = a

        a = temp
    }

    for (i = 40; i < 60; i++) {
        temp = NAVBitRotateLeft(a, 5) + ((b & c) | (b & d) | (c & d)) + e + w[(i + 1)] + SHA1_K[(2) + 1]

        e = d
        d = c
        c = NAVBitRotateLeft(b, 30)
        b = a

        a = temp
    }

    for (i = 60; i < 80; i++) {
        temp = NAVBitRotateLeft(a, 5) + (b ^ c ^ d) + e + w[(i + 1)] + SHA1_K[(3) + 1]

        e = d
        d = c
        c = NAVBitRotateLeft(b, 30)
        b = a

        a = temp
    }

    context.IntermediateHash[1] = context.IntermediateHash[1] + a
    context.IntermediateHash[2] = context.IntermediateHash[2] + b
    context.IntermediateHash[3] = context.IntermediateHash[3] + c
    context.IntermediateHash[4] = context.IntermediateHash[4] + d
    context.IntermediateHash[5] = context.IntermediateHash[5] + e

    context.MessageBlock = ""
    context.MessageBlockIndex = 0
}


/**
 * @function NAVSha1PadMessage
 * @internal
 * @description Pads the message according to SHA-1 standard requirements.
 *
 * The message must be padded to an even 512 bits. The first padding bit must be a '1'.
 * The last 64 bits represent the length of the original message in bits.
 * All bits in between should be 0.
 *
 * @param {_NAVSha1Context} context - The context to pad
 *
 * @returns {void}
 *
 * @note When this function returns, the message digest computation is complete
 */
define_function NAVSha1PadMessage(_NAVSha1Context context) {
    /**
     *  Check to see if the current message block is too small to hold
     *  the initial padding bits and length.  If so, we will pad the
     *  block, process it, and then continue padding into a second
     *  block.
    **/

    if (context.MessageBlockIndex > 55) {
        context.MessageBlock = "context.MessageBlock, $80"
        context.MessageBlockIndex++

        while (context.MessageBlockIndex < 64) {
            context.MessageBlock = "context.MessageBlock, $00"
            context.MessageBlockIndex++
        }

        NAVSha1ProcessMessageBlock(context)

        while (context.MessageBlockIndex < 56) {
            context.MessageBlock = "context.MessageBlock, $00"
            context.MessageBlockIndex++
        }
    }
    else {
        context.MessageBlock = "context.MessageBlock, $80"
        context.MessageBlockIndex++

        while (context.MessageBlockIndex < 56) {
            context.MessageBlock = "context.MessageBlock, $00"
            context.MessageBlockIndex++
        }
    }

    /**
     *  Store the message length as the last 8 octets
    **/
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthHigh >> 24)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthHigh >> 16)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthHigh >> 08)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthHigh >> 00)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthLow >> 24)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthLow >> 16)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthLow >> 08)"
    context.MessageBlock = "context.MessageBlock, type_cast(context.LengthLow >> 00)"

    NAVSha1ProcessMessageBlock(context)
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1__
