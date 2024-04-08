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

/*
Based on RFC3174
https://www.rfc-editor.org/rfc/rfc3174
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1__ 'NAVFoundation.Cryptography.Sha1'

#include 'NAVFoundation.Cryptography.Sha1.h.axi'
#include 'NAVFoundation.BinaryUtils.axi'


/**
 * Digests a string and returns the result as a
 * 40-byte hexadecimal string
**/
define_function char[40] NAVSha1GetHash(char value[]) {
    stack_var integer i
    stack_var integer error
    stack_var _NAVSha1Context context
    stack_var char digest[SHA1_HASH_SIZE]
    stack_var char hash[40]

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

    // set_length_array(digest, SHA1_HASH_SIZE)
    error = NAVSha1Result(context, digest)

    if (error > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha1Result Error => ', itoa(error), ', could not compute digest'")
        return ""
    }

    for (i = 0; i < SHA1_HASH_SIZE; i++) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Digest[', itoa(i + 1), '] => ', digest[(i + 1)]")
        hash = "hash, format('%02x', digest[(i + 1)])"
    }

    return hash
}


/**
 *  SHA1Reset
 *
 *  Description:
 *      This function will initialize the SHA1Context in preparation
 *      for computing a new SHA1 message digest.
 *
 *  Parameters:
 *      context: [in/out]
 *          The context to reset.
 *
 *  Returns:
 *      sha Error Code.
 *
**/
define_function integer NAVSha1Reset(_NAVSha1Context context) {
    context.LengthLow           = 0
    context.LengthHigh          = 0
    context.MessageBlockIndex   = 0

    context.IntermediateHash[1] = $67452301
    context.IntermediateHash[2] = $efcdab89
    context.IntermediateHash[3] = $98badcfe
    context.IntermediateHash[4] = $10325476
    context.IntermediateHash[5] = $c3d2e1f0

    context.Computed    = 0
    context.Corrupted   = 0

    return SHA_SUCCESS
}


/**
 *  SHA1Result
 *
 *  Description:
 *      This function will return the 160-bit message digest into the
 *      Message_Digest array  provided by the caller.
 *      NOTE: The first octet of hash is stored in the 0th element,
 *            the last octet of hash in the 19th element.
 *
 *  Parameters:
 *      context: [in/out]
 *          The context to use to calculate the SHA-1 hash.
 *      Message_Digest: [out]
 *          Where the digest is returned.
 *
 *  Returns:
 *      sha Error Code.
 *
**/
define_function integer NAVSha1Result(_NAVSha1Context context, char digest[SHA1_HASH_SIZE]) {
    stack_var integer i

    if (context.Corrupted) {
        return context.Corrupted
    }

    if (!context.Computed) {
        NAVSha1PadMessage(context)

        for (i = 0; i < 64; i++) {
            context.MessageBlock[(i + 1)] = 0
        }

        context.LengthLow = 0
        context.LengthHigh = 0
        context.Computed = 1
    }

    for (i = 0; i < SHA1_HASH_SIZE; i++) {
        digest[(i + 1)] = type_cast(context.IntermediateHash[((i >> 2) + 1)] >> 8 * (3 - ((i + 1) & $03)))
    }

    return SHA_SUCCESS
}


/**
 *  SHA1Input
 *
 *  Description:
 *      This function accepts an array of octets as the next portion
 *      of the message.
 *
 *  Parameters:
 *      context: [in/out]
 *          The SHA context to update
 *      message_array: [in]
 *          An array of characters representing the next portion of
 *          the message.
 *      length: [in]
 *          The length of the message in message_array
 *
 *  Returns:
 *      sha Error Code.
 *
**/
define_function integer NAVSha1Input(_NAVSha1Context context, char message[], integer length) {
    stack_var integer messageIndex

    if (!length) {
        return SHA_SUCCESS
    }

    if (!length_array(message)) {
        return SHA_NULL
    }

    if (context.Computed) {
        context.Corrupted = SHA_STATE_ERROR
        return SHA_STATE_ERROR
    }

    if (context.Corrupted) {
        return context.Corrupted
    }

    while (length > 0 && !context.Corrupted) {
        context.MessageBlock[(context.MessageBlockIndex + 1)] = (message[(messageIndex + 1)] & $FF)
        // NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'context.MessageBlock[', itoa(context.MessageBlockIndex + 1), '] = (message[', itoa(messageIndex + 1), '] & $FF)'")
        // NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'context.MessageBlock[', itoa(context.MessageBlockIndex + 1), '] = ', (message[(messageIndex + 1)] & $FF)")
        context.MessageBlockIndex++


        context.LengthLow = context.LengthLow + 8

        if (context.LengthLow == 0) {
            context.LengthHigh++

            if (context.LengthHigh == 0) {
                // Message is too long
                context.Corrupted = 1
            }
        }

        if (context.MessageBlockIndex == 64) {
            NAVSha1ProcessMessageBlock(context)
        }

        messageIndex++
        length--
    }

    return SHA_SUCCESS
}


/**
 *  SHA1ProcessMessageBlock
 *
 *  Description:
 *      This function will process the next 512 bits of the message
 *      stored in the Message_Block array.
 *
 *  Parameters:
 *      None.
 *
 *  Returns:
 *      Nothing.
 *
 *  Comments:
 *      Many of the variable names in this code, especially the
 *      single character names, were used because those were the
 *      names used in the publication.
 *
 *
**/
define_function NAVSha1ProcessMessageBlock(_NAVSha1Context context) {
    stack_var long a
    stack_var long b
    stack_var long c
    stack_var long d
    stack_var long e
    stack_var integer i
    stack_var long w[80]
    stack_var long temp

    // set_length_array(w, 80)
    // set_length_array(context.MessageBlock, 64)

    /**
    *  Initialize the first 16 words in the array w
    **/
    for (i = 0; i < 16; i++) {
        // w[(i + 1)] =    context.MessageBlock[(i * 4) + 1] << 24 |
        //                 context.MessageBlock[(i * 4) + 2] << 16 |
        //                 context.MessageBlock[(i * 4) + 3] << 08 |
        //                 context.MessageBlock[(i * 4) + 4] << 00
        w[(i + 1)] = context.MessageBlock[(i * 4) + 1] << 24
        w[(i + 1)] = w[(i + 1)] | context.MessageBlock[(i * 4) + 2] << 16
        w[(i + 1)] = w[(i + 1)] | context.MessageBlock[(i * 4) + 3] << 08
        w[(i + 1)] = w[(i + 1)] | context.MessageBlock[(i * 4) + 4] << 00

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
        temp = NAVBitRotateLeft(a, 5) + ((b & c) | (~b & d)) + e + w[(i + 1)] + K[1]

        e = d
        d = c
        c = NAVBitRotateLeft(b, 30)
        b = a

        a = temp
    }

    for (i = 20; i < 40; i++) {
        temp = NAVBitRotateLeft(a, 5) + (b ^ c ^ d) + e + w[(i + 1)] + K[2]

        e = d
        d = c
        c = NAVBitRotateLeft(b, 30)
        b = a

        a = temp
    }

    for (i = 40; i < 60; i++) {
        temp = NAVBitRotateLeft(a, 5) + ((b & c) | (b & d) | (c & d)) + e + w[(i + 1)] + K[3]

        e = d
        d = c
        c = NAVBitRotateLeft(b, 30)
        b = a

        a = temp
    }

    for (i = 60; i < 80; i++) {
        temp = NAVBitRotateLeft(a, 5) + (b ^ c ^ d) + e + w[(i + 1)] + K[4]

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

    context.MessageBlockIndex = 0
}


/**
 *  SHA1PadMessage
 *
 *  Description:
 *      According to the standard, the message must be padded to an even
 *      512 bits.  The first padding bit must be a '1'.  The last 64
 *      bits represent the length of the original message.  All bits in
 *      between should be 0.  This function will pad the message
 *      according to those rules by filling the Message_Block array
 *      accordingly.  It will also call the ProcessMessageBlock function
 *      provided appropriately.  When it returns, it can be assumed that
 *      the message digest has been computed.
 *
 *  Parameters:
 *      context: [in/out]
 *          The context to pad
 *      ProcessMessageBlock: [in]
 *          The appropriate SHA*ProcessMessageBlock function
 *  Returns:
 *      Nothing.
 *
**/
define_function NAVSha1PadMessage(_NAVSha1Context context) {
    /**
     *  Check to see if the current message block is too small to hold
     *  the initial padding bits and length.  If so, we will pad the
     *  block, process it, and then continue padding into a second
     *  block.
    **/
    if (context.MessageBlockIndex > 55) {
        context.MessageBlock[(context.MessageBlockIndex + 1)] = $80
        context.MessageBlockIndex++

        while (context.MessageBlockIndex < 64) {
            context.MessageBlock[(context.MessageBlockIndex + 1)] = 0
            context.MessageBlockIndex++
        }

        NAVSha1ProcessMessageBlock(context)

        while (context.MessageBlockIndex < 56) {
            context.MessageBlock[(context.MessageBlockIndex + 1)] = 0
            context.MessageBlockIndex++
        }
    }
    else {
        context.MessageBlock[(context.MessageBlockIndex + 1)] = $80
        context.MessageBlockIndex++

        while (context.MessageBlockIndex < 56) {
            context.MessageBlock[(context.MessageBlockIndex + 1)] = 0
            context.MessageBlockIndex++
        }
    }

    /**
     *  Store the message length as the last 8 octets
    **/
    context.MessageBlock[(56 + 1)] = type_cast(context.LengthHigh >> 24)
    context.MessageBlock[(57 + 1)] = type_cast(context.LengthHigh >> 16)
    context.MessageBlock[(58 + 1)] = type_cast(context.LengthHigh >> 08)
    context.MessageBlock[(59 + 1)] = type_cast(context.LengthHigh >> 00)
    context.MessageBlock[(60 + 1)] = type_cast(context.LengthLow >> 24)
    context.MessageBlock[(61 + 1)] = type_cast(context.LengthLow >> 16)
    context.MessageBlock[(62 + 1)] = type_cast(context.LengthLow >> 08)
    context.MessageBlock[(63 + 1)] = type_cast(context.LengthLow >> 00)

    NAVSha1ProcessMessageBlock(context)
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1__
