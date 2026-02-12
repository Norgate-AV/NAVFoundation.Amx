PROGRAM_NAME='NAVFoundation.Cryptography.Sha384'

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
 * @file NAVFoundation.Cryptography.Sha384.axi
 * @brief Implementation of the SHA-384 cryptographic hash function.
 *
 * This module provides functions to compute SHA-384 hashes of data.
 * SHA-384 produces a 384-bit (48-byte) hash value, typically rendered
 * as a 96-character hexadecimal number.
 *
 * This implementation uses the NAVFoundation.Int64 library for 64-bit
 * arithmetic operations required by the SHA-384 algorithm. While the
 * Int64 library has some documented limitations for extreme values,
 * these limitations do not affect the correctness of the SHA-384
 * implementation, which only requires arithmetic within well-defined
 * ranges.
 *
 * SHA-384 is a truncated version of SHA-512, using different initial
 * hash values and outputting only the first 384 bits (6 of the 8
 * 64-bit words) of the result.
 *
 * Implementation based on RFC6234: https://www.rfc-editor.org/rfc/rfc6234
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_SHA384__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_SHA384__ 'NAVFoundation.Cryptography.Sha384'

#include 'NAVFoundation.Cryptography.Sha384.h.axi'
#include 'NAVFoundation.Int64.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'

// Only define SHA384_DEBUG if not already defined elsewhere
#IF_NOT_DEFINED SHA384_DEBUG
// #DEFINE SHA384_DEBUG  // Comment this out to disable debug logging
#END_IF

// #DEFINE SHA384_DEBUG
// #DEFINE SHA384_EXTENSIVE_DEBUG


/**
 * @function NAVSha384DebugLog
 * @description Logs a debug message only if the required level is enabled
 *
 * @param {integer} level - Debug level required for this message
 * @param {char} message - The message to log
 */
define_function NAVSha384DebugLog(integer level, char message[]) {
    #IF_DEFINED SHA384_DEBUG
    if (level <= SHA384_DEBUG_LEVEL) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, message)
    }
    #END_IF
}

/**
 * @function NAVGetSHA384K
 * @internal
 * @description Helper function to get SHA-384 constants as _NAVInt64 structs
 *
 * @param {integer} index - The index of the constant to retrieve (0-79)
 * @param {_NAVInt64} result - The struct to populate with the constant value
 */
define_function NAVGetSHA384K(integer index, _NAVInt64 result) {
    stack_var integer i
    // Adjust index because:
    // 1. SHA-384 spec uses 0-based indexing for K[0]...K[79]
    // 2. NetLinx arrays are 1-based, so our array is SHA384_K[1]...SHA384_K[80]
    // 3. We need to add 1 to convert from 0-based algorithm index to 1-based array index

    // Make a copy so we don't modify the original
    i = index + 1;

    if (i < 1 || i > 80) {
        // Invalid index, set to zero
        result.Hi = 0
        result.Lo = 0
        return
    }

    #IF_DEFINED SHA384_DEBUG
    if (i <= 3 || i >= 78) {
        NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Using K[', itoa(i-1), '] = $', format('%08x', SHA384_K[i][1]), format('%08x', SHA384_K[i][2]), ' at index ', itoa(i)")
    }
    #END_IF

    result.Hi = SHA384_K[i][1]
    result.Lo = SHA384_K[i][2]
}

/**
 * @function NAVSha384GetHash
 * @public
 * @description Computes the SHA-384 hash of an input string
 * This is the main public API function for the SHA-384 module.
 *
 * @param {char[]} value - The input string to be hashed
 *
 * @returns {char[48]} 48-byte SHA-384 hash value (384 bits), or empty string on error
 *
 * @example
 * stack_var char message[100]
 * stack_var char digest[48]
 * stack_var char hexDigest[96]
 *
 * message = 'Hello, World!'
 * digest = NAVSha384GetHash(message)
 * // To convert to hexadecimal display format:
 * hexDigest = NAVHexToString(digest)
 */
define_function char[48] NAVSha384GetHash(char value[]) {
    stack_var integer error
    stack_var _NAVSha384Context context
    stack_var char digest[SHA384_HASH_SIZE]
    stack_var integer i

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'========== SHA384 BEGIN HASH OPERATION =========='")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Input length: ', itoa(length_array(value)), ' bytes'")
    if (length_array(value) > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'First 10 bytes: ', NAVSha384HexToString(mid_string(value, 1, min_value(10, length_array(value))))")
    }
    #END_IF

    #IF_DEFINED SHA384_DEBUG
    NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Hashing input of length ', itoa(length_array(value))")
    if (length_array(value) < 100) {
        NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Input = "', value, '"'")
    }
    else {
        NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Input (first 50 bytes) = "', mid_string(value, 1, 50), '..."'")
    }
    #END_IF

    error = NAVSha384Reset(context)

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'After reset, context state:'")
    for (i = 1; i <= 8; i++) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Hash[', itoa(i), '] = ', NAVInt64ToDebugString(context.IntermediateHash[i])")
    }
    #END_IF

    if (error > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha384Reset Error => ', itoa(error)")
        return ""
    }

    error = NAVSha384Input(context, value, length_array(value))

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'After input, message block index = ', itoa(context.MessageBlockIndex)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Message length in bits = ', NAVInt64ToDebugString(context.LengthLow)")
    #END_IF

    if (error > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha384Input Error => ', itoa(error)")
        return ""
    }

    error = NAVSha384Result(context, digest)

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'After result, final hash values:'")
    for (i = 1; i <= 8; i++) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Hash[', itoa(i), '] = ', NAVInt64ToDebugString(context.IntermediateHash[i])")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Final digest (hex): ', NAVSha384HexToString(digest)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'========== SHA384 END HASH OPERATION =========='")
    #END_IF

    if (error > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha384Result Error => ', itoa(error), ', could not compute digest'")
        return ""
    }

    return digest
}

/**
 * @function NAVSha384Reset
 * @internal
 * @description Initializes the context in preparation for computing a new SHA-384 message digest
 * Sets up the initial hash values according to the SHA-384 specification.
 *
 * @param {_NAVSha384Context} context - The context to reset
 *
 * @returns {integer} SHA_SUCCESS on success, or an error code
 */
define_function integer NAVSha384Reset(_NAVSha384Context context) {
    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'SHA384 Reset: Initializing context with SHA-384 initial values'")
    #END_IF

    // Initialize length to zero
    context.LengthHigh.Hi = 0
    context.LengthHigh.Lo = 0
    context.LengthLow.Hi = 0
    context.LengthLow.Lo = 0

    context.MessageBlockIndex = 0

    // Initial hash values for SHA-384 (first 64 bits of the fractional parts
    // of the square roots of the 9th through 16th prime numbers: 23, 29, 31, 37, 41, 43, 47, 53)
    // CRITICAL: These values must exactly match the SHA-384 specification - verify each value
    context.IntermediateHash[1].Hi = $cbbb9d5d
    context.IntermediateHash[1].Lo = $c1059ed8

    context.IntermediateHash[2].Hi = $629a292a
    context.IntermediateHash[2].Lo = $367cd507

    context.IntermediateHash[3].Hi = $9159015a
    context.IntermediateHash[3].Lo = $3070dd17

    context.IntermediateHash[4].Hi = $152fecd8
    context.IntermediateHash[4].Lo = $f70e5939

    context.IntermediateHash[5].Hi = $67332667
    context.IntermediateHash[5].Lo = $ffc00b31

    context.IntermediateHash[6].Hi = $8eb44a87
    context.IntermediateHash[6].Lo = $68581511

    context.IntermediateHash[7].Hi = $db0c2e0d
    context.IntermediateHash[7].Lo = $64f98fa7

    context.IntermediateHash[8].Hi = $47b5481d
    context.IntermediateHash[8].Lo = $befa4fa4

    context.Computed  = false
    context.Corrupted = false

    context.MessageBlock = ""

    #IF_DEFINED SHA384_DEBUG
    NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Reset context, initial hash values:'")
    NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'Hash[1] = ', NAVInt64ToDebugString(context.IntermediateHash[1])")
    NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'Hash[8] = ', NAVInt64ToDebugString(context.IntermediateHash[8])")
    #END_IF

    return SHA384_SUCCESS
}

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_INT64_DEBUG_STRING__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_INT64_DEBUG_STRING__
/**
 * @function NAVInt64ToDebugString
 * @internal
 * @description Helper to format Int64 values for debug output
 *
 * @param {_NAVInt64} val - The 64-bit value to format
 *
 * @returns {char[32]} String representation of the value in hexadecimal
 */
define_function char[32] NAVInt64ToDebugString(_NAVInt64 val) {
    return "'$', format('%08x', val.Hi), format('%08x', val.Lo)"
}
#END_IF

/**
 * @function NAVSha384Result
 * @internal
 * @description Finalizes the SHA-384 calculation and returns the 384-bit message digest
 * Performs the padding if needed and produces the final hash value.
 *
 * @param {_NAVSha384Context} context - The context to use to calculate the SHA-384 hash
 * @param {char[SHA384_HASH_SIZE]} digest - Where the digest is returned (48 bytes)
 *
 * @returns {integer} SHA_SUCCESS on success, or an error code
 */
define_function integer NAVSha384Result(_NAVSha384Context context, char digest[SHA384_HASH_SIZE]) {
    stack_var integer i

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'SHA384 Result: Creating digest'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Context computed = ', itoa(context.Computed), ', corrupted = ', itoa(context.Corrupted)")
    #END_IF

    if (context.Corrupted) {
        return context.Corrupted
    }

    if (!context.Computed) {
        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Need to pad message and process final block'")
        #END_IF

        NAVSha384PadMessage(context)

        // After padding, we need to explicitly set as computed
        context.Computed = true

        // Important: After padding and setting computed,
        // Zero out the length to ensure any subsequent digests
        // don't add additional bits to the length
        context.LengthHigh.Hi = 0
        context.LengthHigh.Lo = 0
        context.LengthLow.Hi = 0
        context.LengthLow.Lo = 0

        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Final hash values after padding:'")
        for (i = 1; i <= 8; i++) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Hash[', itoa(i), '] = ', NAVInt64ToDebugString(context.IntermediateHash[i])")
        }
        #END_IF
    }

    #IF_DEFINED SHA384_DEBUG
    NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Creating final digest'")
    NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Final hash[1] = ', NAVInt64ToDebugString(context.IntermediateHash[1])")
    NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Final hash[6] = ', NAVInt64ToDebugString(context.IntermediateHash[6])")
    #END_IF

    // Create the final hash value (big-endian)
    // SHA-384 uses only the first 6 of the 8 64-bit words (384 bits = 48 bytes)
    digest = ""
    for (i = 1; i <= 6; i++) {
        stack_var char bytes[8]

        bytes = NAVInt64ToByteArrayBE(context.IntermediateHash[i])
        digest = "digest, bytes"

        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Added to digest - Hash[', itoa(i), '] = ', NAVInt64ToDebugString(context.IntermediateHash[i]), ' as bytes: ', NAVSha384HexToString(bytes)")
        #END_IF

        #IF_DEFINED SHA384_DEBUG
        if (i <= 2) {
            NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Hash[', itoa(i), '] bytes = ', NAVHexToString(bytes)")
        }
        #END_IF
    }

    #IF_DEFINED SHA384_DEBUG
    NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Final digest (first 16 bytes) = ', NAVHexToString(mid_string(digest, 1, 16)), '...'")
    #END_IF

    return SHA384_SUCCESS
}

/**
 * @function NAVSha384Input
 * @internal
 * @description Processes an array of bytes as part of the SHA-384 calculation
 * Updates the context state to include the new data in the hash calculation.
 *
 * @param {_NAVSha384Context} context - The SHA context to update
 * @param {char[]} message - An array of characters representing the next portion of the message
 * @param {integer} length - The length of the message
 *
 * @returns {integer} SHA_SUCCESS on success, or an error code
 */
define_function integer NAVSha384Input(_NAVSha384Context context, char message[], integer length) {
    stack_var integer messageIndex
    stack_var _NAVInt64 temp
    stack_var integer carry

    if (!length) {
        return SHA384_SUCCESS
    }

    if (context.Computed) {
        context.Corrupted = SHA384_STATE_ERROR
        return SHA384_STATE_ERROR
    }

    if (context.Corrupted) {
        return context.Corrupted
    }

    messageIndex = 0

    #IF_DEFINED SHA384_DEBUG
    if (length > 0) {
        NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Input adding ', itoa(length), ' bytes'")
        if (context.MessageBlockIndex > 0 && context.MessageBlockIndex < 10) {
            NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: First few bytes = ', NAVHexToString(mid_string(context.MessageBlock, 1, context.MessageBlockIndex))")
        }
    }
    #END_IF

    while (length > 0 && !context.Corrupted) {
        context.MessageBlock = "context.MessageBlock, message[(messageIndex + 1)] & $FF"
        context.MessageBlockIndex = context.MessageBlockIndex + 1  // Use longhand form

        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Adding byte to message block: ', format('%02x', type_cast(message[(messageIndex + 1)] & $FF)), ' at index ', itoa(context.MessageBlockIndex)")
        #END_IF

        // Update length (add 8 bits)
        context.LengthLow.Lo = context.LengthLow.Lo + 8

        // Check for overflow in the Lo field
        if (context.LengthLow.Lo < 8) { // Overflow occurred
            // Increment Hi field
            context.LengthLow.Hi = context.LengthLow.Hi + 1

            // Check for overflow in the LengthLow.Hi field
            if (context.LengthLow.Hi == 0) {
                #IF_DEFINED SHA384_EXTENSIVE_DEBUG
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'LengthLow.Hi overflow, incrementing LengthHigh.Lo'")
                #END_IF

                // Increment LengthHigh.Lo
                context.LengthHigh.Lo = context.LengthHigh.Lo + 1

                // Check for overflow in LengthHigh.Lo
                if (context.LengthHigh.Lo == 0) {
                    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'LengthHigh.Lo overflow, incrementing LengthHigh.Hi'")
                    #END_IF

                    // Increment LengthHigh.Hi
                    context.LengthHigh.Hi = context.LengthHigh.Hi + 1

                    // Check for overflow - too long message
                    if (context.LengthHigh.Hi == 0) {
                        context.Corrupted = SHA384_INPUT_TOO_LONG
                        return SHA384_INPUT_TOO_LONG
                    }
                }
            }
        }

        if (context.MessageBlockIndex == 128) {
            #IF_DEFINED SHA384_DEBUG
            NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Calling ProcessMessageBlock - block filled'")
            #END_IF
            NAVSha384ProcessMessageBlock(context)
        }

        messageIndex = messageIndex + 1  // Use longhand form
        length = length - 1  // Use longhand form
    }

    return SHA384_SUCCESS
}

/**
 * @function NAVSha384PadMessage
 * @internal
 * @description Pads the message according to SHA-384 requirements
 * Adds padding bits and message length to prepare for final hash calculation.
 *
 * @param {_NAVSha384Context} context - The SHA context to pad
 */
define_function NAVSha384PadMessage(_NAVSha384Context context) {
    stack_var integer i

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'SHA384 PadMessage: Starting padding, current index = ', itoa(context.MessageBlockIndex)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Message length in bits = ', NAVInt64ToDebugString(context.LengthLow)")
    if (context.MessageBlockIndex > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Current block data (first 16 bytes): ', NAVSha384HexToString(mid_string(context.MessageBlock, 1, min_value(16, context.MessageBlockIndex)))")
    }
    #END_IF

    // Check if we need to create a new block for padding
    if (context.MessageBlockIndex >= 112) { // Not enough room for length (need 16 bytes at end)
        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Padding requires two blocks - index (', itoa(context.MessageBlockIndex), ') >= 112'")
        #END_IF

        // Pad with 1 bit (0x80) followed by zeros
        context.MessageBlock = "context.MessageBlock, $80"
        context.MessageBlockIndex = context.MessageBlockIndex + 1  // Use longhand form

        // Pad with zeros until we fill this block
        while (context.MessageBlockIndex < 128) {
            context.MessageBlock = "context.MessageBlock, $00"
            context.MessageBlockIndex = context.MessageBlockIndex + 1
        }

        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'First padding block complete (128 bytes total)'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Calling ProcessMessageBlock for first padding block'")
        #END_IF

        // Process this block
        NAVSha384ProcessMessageBlock(context)

        // Create a new block with all zeros
        context.MessageBlock = ""
        for (i = 1; i <= 112; i++) {
            context.MessageBlock = "context.MessageBlock, $00"
        }
        context.MessageBlockIndex = 112

        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Created second padding block with 112 zeros'")
        #END_IF
    }
    else {
        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Padding fits in one block - index (', itoa(context.MessageBlockIndex), ') < 112'")
        #END_IF

        // Append the padding bit and zeros
        context.MessageBlock = "context.MessageBlock, $80"
        context.MessageBlockIndex = context.MessageBlockIndex + 1

        // Pad with zeros until we reach position 112
        while (context.MessageBlockIndex < 112) {
            context.MessageBlock = "context.MessageBlock, $00"
            context.MessageBlockIndex = context.MessageBlockIndex + 1
        }

        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Single block padding complete (', itoa(context.MessageBlockIndex), ' bytes)'")
        #END_IF
    }

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Adding 8 bytes of zeros for high 64 bits of length'")
    #END_IF

    // Append the length in bits as a 128-bit big-endian integer
    // First the high 64 bits (always 0 for our implementation)
    context.MessageBlock = "context.MessageBlock, $00, $00, $00, $00, $00, $00, $00, $00"

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Adding 8 bytes for low 64 bits of length: ', NAVSha384HexToString(NAVInt64ToByteArrayBE(context.LengthLow))")
    #END_IF

    // Then the low 64 bits of length - ensure correct endianness
    context.MessageBlock = "context.MessageBlock, NAVInt64ToByteArrayBE(context.LengthLow)"
    context.MessageBlockIndex = 128

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Final block complete with length (128 bytes total)'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Final block data (last 32 bytes): ', NAVSha384HexToString(mid_string(context.MessageBlock, 97, 32))")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Calling ProcessMessageBlock for final block'")
    #END_IF

    // Process the final block
    NAVSha384ProcessMessageBlock(context)

    #IF_DEFINED SHA384_DEBUG
    NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Processed final block with length'")
    #END_IF
}

/**
 * @function NAVSha384ProcessMessageBlock
 * @internal
 * @description Process a 128-byte message block according to SHA-384 algorithm
 * This is the core compression function of SHA-384.
 *
 * @param {_NAVSha384Context} context - The SHA context to process
 */
define_function NAVSha384ProcessMessageBlock(_NAVSha384Context context) {
    stack_var integer t
    stack_var _NAVInt64 a, b, c, d, e, f, g, h
    stack_var _NAVInt64 temp1, temp2
    stack_var _NAVInt64 W[80]
    stack_var _NAVInt64 k_t

    // Add the compressed chunk to the current hash value
    stack_var _NAVInt64 accumulator;

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'ProcessMessageBlock: Starting - block index = ', itoa(context.MessageBlockIndex)")

    // Log the first few bytes of the message block for debugging
    if (context.MessageBlockIndex > 0) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Block data (first 16 bytes): ', NAVSha384HexToString(mid_string(context.MessageBlock, 1, min_value(16, context.MessageBlockIndex)))")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Initial hash state:'")
    for (t = 1; t <= 8; t++) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Hash[', itoa(t), '] = ', NAVInt64ToDebugString(context.IntermediateHash[t])")
    }
    #END_IF

    #IF_DEFINED SHA384_DEBUG
    NAVSha384DebugLog(SHA384_LEVEL_VERBOSE, "'SHA384: Processing message block, index=', itoa(context.MessageBlockIndex)")
    #END_IF

    // Initialize the first 16 words in the array W
    // IMPORTANT: Fixed the offset error - the loop was off by 1
    for (t = 0; t < 16; t++) {
        stack_var integer index
        stack_var char bytes[8]

        // Ensure proper byte indexing - critical for correct word loading
        index = t * 8 + 1

        if (index + 7 <= length_array(context.MessageBlock)) {
            // Extract exactly 8 bytes and convert to 64-bit word (big-endian)
            bytes = mid_string(context.MessageBlock, index, 8)
            NAVByteArrayBEToInt64(bytes, W[t+1])

            #IF_DEFINED SHA384_EXTENSIVE_DEBUG
            if (t < 4 || t > 12) { // Log first and last few words for readability
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'W[', itoa(t), '] = ', NAVInt64ToDebugString(W[t+1]), ' (from bytes ', itoa(index), '-', itoa(index+7), ')'")
            }
            #END_IF

            #IF_DEFINED SHA384_DEBUG
            if (t < 2) {
                NAVSha384DebugLog(SHA384_LEVEL_VERBOSE, "'W[', itoa(t), '] = ', NAVInt64ToDebugString(W[t+1]), ' (from bytes ', itoa(index), '-', itoa(index+7), ')'")
            }
            #END_IF
        }
        else {
            // Zero-pad if we reach the end (shouldn't happen with proper padding)
            W[t+1].Hi = 0
            W[t+1].Lo = 0

            #IF_DEFINED SHA384_EXTENSIVE_DEBUG
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'WARNING: Unexpected condition - message block too short at index ', itoa(index)")
            #END_IF
        }
    }

    // Message schedule (expand the message into 80 words)
    // This loop must calculate correctly according to SHA-384 spec
    for (t = 16; t < 80; t++) {
        stack_var _NAVInt64 s0, s1, temp, tempAdd

        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        if (t == 16) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Starting message schedule expansion'")
        }
        #END_IF

        // Calculate s0 = sigma0(W[t-15])
        NAVSha384SigmaSmall0(W[t-15+1], s0)

        // Calculate s1 = sigma1(W[t-2])
        NAVSha384SigmaSmall1(W[t-2+1], s1)

        // Calculate W[t] = W[t-16] + s0 + W[t-7] + s1
        temp.Hi = 0; temp.Lo = 0
        NAVInt64Add(W[t-16+1], s0, temp)

        tempAdd.Hi = 0; tempAdd.Lo = 0
        NAVInt64Add(W[t-7+1], s1, tempAdd)

        NAVInt64Add(temp, tempAdd, W[t+1])

        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        if (t >= 75) { // Log just the last few W values for readability
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'W[', itoa(t), '] = ', NAVInt64ToDebugString(W[t+1])")
        }
        #END_IF

        #IF_DEFINED SHA384_DEBUG
        if (t >= 75) {
            NAVSha384DebugLog(SHA384_LEVEL_VERBOSE, "'W[', itoa(t), '] = ', NAVInt64ToDebugString(W[t+1])")
        }
        #END_IF
    }

    // Initialize the eight working variables with current hash value
    a = context.IntermediateHash[1]
    b = context.IntermediateHash[2]
    c = context.IntermediateHash[3]
    d = context.IntermediateHash[4]
    e = context.IntermediateHash[5]
    f = context.IntermediateHash[6]
    g = context.IntermediateHash[7]
    h = context.IntermediateHash[8]

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Beginning compression function with initial working variables:'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'a = ', NAVInt64ToDebugString(a)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'e = ', NAVInt64ToDebugString(e)")
    #END_IF

    #IF_DEFINED SHA384_DEBUG
    NAVSha384DebugLog(SHA384_LEVEL_VERBOSE, "'Initial state a = ', NAVInt64ToDebugString(a)")
    NAVSha384DebugLog(SHA384_LEVEL_VERBOSE, "'Initial state e = ', NAVInt64ToDebugString(e)")
    #END_IF

    // Main hash computation loop - this is where we implement the SHA-384 round function
    // The transform must match the SHA-384 specification exactly
    for (t = 0; t < 80; t++) {
        stack_var _NAVInt64 T1, T2, Sum0, Sum1, ch, maj

        // Calculate Sigma1(e)
        NAVSha384SigmaBig1(e, Sum1)

        // Calculate Ch(e,f,g)
        NAVSha384CH(e, f, g, ch)

        // T1 = h + Sigma1(e) + Ch(e,f,g) + K[t] + W[t]
        T1.Hi = 0; T1.Lo = 0

        // Get the constant K[t]
        NAVGetSHA384K(t, k_t)

        // Calculate T1 step by step - order of operations matters!
        NAVInt64Add(h, Sum1, T1)
        NAVInt64Add(T1, ch, T1)
        NAVInt64Add(T1, k_t, T1)
        NAVInt64Add(T1, W[t+1], T1)

        // Calculate Sigma0(a)
        NAVSha384SigmaBig0(a, Sum0)

        // Calculate Maj(a,b,c)
        NAVSha384MAJ(a, b, c, maj)

        // T2 = Sigma0(a) + Maj(a,b,c)
        T2.Hi = 0; T2.Lo = 0
        NAVInt64Add(Sum0, maj, T2)

        // Update working variables according to SHA-384 spec
        h = g;
        g = f;
        f = e;

        // e = d + T1
        e.Hi = d.Hi;
        e.Lo = d.Lo;
        NAVInt64Add(e, T1, e);

        d = c;
        c = b;
        b = a;

        // a = T1 + T2
        a.Hi = 0;
        a.Lo = 0;
        NAVInt64Add(T1, T2, a);

        #IF_DEFINED SHA384_EXTENSIVE_DEBUG
        if (t == 0 || t == 19 || t == 39 || t == 59 || t == 79) {  // Log at specific intervals
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Round ', itoa(t), ': a = ', NAVInt64ToDebugString(a), ', e = ', NAVInt64ToDebugString(e)")
        }
        #END_IF

        #IF_DEFINED SHA384_DEBUG
        if (t == 0 || t == 79) {
            NAVSha384DebugLog(SHA384_LEVEL_VERBOSE, "'Round ', itoa(t), ': a = ', NAVInt64ToDebugString(a), ', e = ', NAVInt64ToDebugString(e)")
        }
        #END_IF
    }

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'After compression loop, before adding to hash:'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'a = ', NAVInt64ToDebugString(a), ', Hash[1] = ', NAVInt64ToDebugString(context.IntermediateHash[1])")
    #END_IF

    // Add the compressed chunk to the current hash value using proper temp variables
    // IMPORTANT: We need deep copies to avoid side effects during accumulation
    accumulator.Hi = context.IntermediateHash[1].Hi;
    accumulator.Lo = context.IntermediateHash[1].Lo;
    NAVInt64Add(accumulator, a, accumulator);
    context.IntermediateHash[1].Hi = accumulator.Hi;
    context.IntermediateHash[1].Lo = accumulator.Lo;

    accumulator.Hi = context.IntermediateHash[2].Hi;
    accumulator.Lo = context.IntermediateHash[2].Lo;
    NAVInt64Add(accumulator, b, accumulator);
    context.IntermediateHash[2].Hi = accumulator.Hi;
    context.IntermediateHash[2].Lo = accumulator.Lo;

    accumulator.Hi = context.IntermediateHash[3].Hi;
    accumulator.Lo = context.IntermediateHash[3].Lo;
    NAVInt64Add(accumulator, c, accumulator);
    context.IntermediateHash[3].Hi = accumulator.Hi;
    context.IntermediateHash[3].Lo = accumulator.Lo;

    accumulator.Hi = context.IntermediateHash[4].Hi;
    accumulator.Lo = context.IntermediateHash[4].Lo;
    NAVInt64Add(accumulator, d, accumulator);
    context.IntermediateHash[4].Hi = accumulator.Hi;
    context.IntermediateHash[4].Lo = accumulator.Lo;

    accumulator.Hi = context.IntermediateHash[5].Hi;
    accumulator.Lo = context.IntermediateHash[5].Lo;
    NAVInt64Add(accumulator, e, accumulator);
    context.IntermediateHash[5].Hi = accumulator.Hi;
    context.IntermediateHash[5].Lo = accumulator.Lo;

    accumulator.Hi = context.IntermediateHash[6].Hi;
    accumulator.Lo = context.IntermediateHash[6].Lo;
    NAVInt64Add(accumulator, f, accumulator);
    context.IntermediateHash[6].Hi = accumulator.Hi;
    context.IntermediateHash[6].Lo = accumulator.Lo;

    accumulator.Hi = context.IntermediateHash[7].Hi;
    accumulator.Lo = context.IntermediateHash[7].Lo;
    NAVInt64Add(accumulator, g, accumulator);
    context.IntermediateHash[7].Hi = accumulator.Hi;
    context.IntermediateHash[7].Lo = accumulator.Lo;

    accumulator.Hi = context.IntermediateHash[8].Hi;
    accumulator.Lo = context.IntermediateHash[8].Lo;
    NAVInt64Add(accumulator, h, accumulator);
    context.IntermediateHash[8].Hi = accumulator.Hi;
    context.IntermediateHash[8].Lo = accumulator.Lo;

    #IF_DEFINED SHA384_EXTENSIVE_DEBUG
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'After adding to intermediate hash:'")
    for (t = 1; t <= 8; t++) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Hash[', itoa(t), '] = ', NAVInt64ToDebugString(context.IntermediateHash[t])")
    }
    #END_IF

    #IF_DEFINED SHA384_DEBUG
    NAVSha384DebugLog(SHA384_LEVEL_VERBOSE, "'After block, Hash[1] = ', NAVInt64ToDebugString(context.IntermediateHash[1])")
    NAVSha384DebugLog(SHA384_LEVEL_VERBOSE, "'After block, Hash[5] = ', NAVInt64ToDebugString(context.IntermediateHash[5])")
    #END_IF

    // Clear the message block for next use
    context.MessageBlockIndex = 0
    context.MessageBlock = ""
}

/**
 * @function NAVSha384SigmaBig0
 * @internal
 * @description SHA-384 SIGMA0 function: ROTR^28(x) XOR ROTR^34(x) XOR ROTR^39(x)
 * Used in the SHA-384 compression function for the working variable 'a'.
 *
 * @param {_NAVInt64} x - The input value
 * @param {_NAVInt64} result - The result of the operation
 */
define_function NAVSha384SigmaBig0(_NAVInt64 x, _NAVInt64 result) {
    stack_var _NAVInt64 temp1, temp2, temp3, tempXor

    // Using NAVInt64RotateRightFull for true 64-bit rotations
    NAVInt64RotateRightFull(x, 28, temp1)
    NAVInt64RotateRightFull(x, 34, temp2)
    NAVInt64RotateRightFull(x, 39, temp3)

    // Combine results correctly
    tempXor.Hi = 0; tempXor.Lo = 0
    NAVInt64BitXor(temp1, temp2, tempXor)
    NAVInt64BitXor(tempXor, temp3, result)
}

/**
 * @function NAVSha384SigmaBig1
 * @internal
 * @description SHA-384 SIGMA1 function: ROTR^14(x) XOR ROTR^18(x) XOR ROTR^41(x)
 * Used in the SHA-384 compression function for the working variable 'e'.
 *
 * @param {_NAVInt64} x - The input value
 * @param {_NAVInt64} result - The result of the operation
 */
define_function NAVSha384SigmaBig1(_NAVInt64 x, _NAVInt64 result) {
    stack_var _NAVInt64 temp1, temp2, temp3, tempXor

    // Using NAVInt64RotateRightFull for true 64-bit rotations
    NAVInt64RotateRightFull(x, 14, temp1)
    NAVInt64RotateRightFull(x, 18, temp2)
    NAVInt64RotateRightFull(x, 41, temp3)

    // Combine results correctly
    tempXor.Hi = 0; tempXor.Lo = 0
    NAVInt64BitXor(temp1, temp2, tempXor)
    NAVInt64BitXor(tempXor, temp3, result)
}

/**
 * @function NAVSha384SigmaSmall0
 * @internal
 * @description SHA-384 sigma0 function: ROTR^1(x) XOR ROTR^8(x) XOR SHR^7(x)
 * Used in the SHA-384 message schedule calculation.
 *
 * @param {_NAVInt64} x - The input value
 * @param {_NAVInt64} result - The result of the operation
 */
define_function NAVSha384SigmaSmall0(_NAVInt64 x, _NAVInt64 result) {
    stack_var _NAVInt64 temp1, temp2, temp3

    // Use proper full 64-bit rotations for the first two operations
    NAVInt64RotateRightFull(x, 1, temp1)
    NAVInt64RotateRightFull(x, 8, temp2)
    NAVInt64ShiftRight(x, 7, temp3)

    // Combine results correctly
    result.Hi = 0; result.Lo = 0
    NAVInt64BitXor(temp1, temp2, result)
    NAVInt64BitXor(result, temp3, result)
}

/**
 * @function NAVSha384SigmaSmall1
 * @internal
 * @description SHA-384 sigma1 function: ROTR^19(x) XOR ROTR^61(x) XOR SHR^6(x)
 * Used in the SHA-384 message schedule calculation.
 *
 * @param {_NAVInt64} x - The input value
 * @param {_NAVInt64} result - The result of the operation
 */
define_function NAVSha384SigmaSmall1(_NAVInt64 x, _NAVInt64 result) {
    stack_var _NAVInt64 temp1, temp2, temp3

    // Use proper full 64-bit rotations for the first two operations
    NAVInt64RotateRightFull(x, 19, temp1)
    NAVInt64RotateRightFull(x, 61, temp2)
    NAVInt64ShiftRight(x, 6, temp3)

    // Combine results correctly
    result.Hi = 0; result.Lo = 0
    NAVInt64BitXor(temp1, temp2, result)
    NAVInt64BitXor(result, temp3, result)
}

/**
 * @function NAVSha384CH
 * @internal
 * @description SHA-384 CH function: (x AND y) XOR ((NOT x) AND z)
 * The "choose" function: for each bit, select either y or z based on the value of x.
 *
 * @param {_NAVInt64} x - The first input value
 * @param {_NAVInt64} y - The second input value
 * @param {_NAVInt64} z - The third input value
 * @param {_NAVInt64} result - The result of the operation
 */
define_function NAVSha384CH(_NAVInt64 x, _NAVInt64 y, _NAVInt64 z, _NAVInt64 result) {
    stack_var _NAVInt64 temp1, temp2, not_x

    // x AND y
    NAVInt64BitAnd(x, y, temp1)

    // NOT x
    NAVInt64BitNot(x, not_x)

    // (NOT x) AND z
    NAVInt64BitAnd(not_x, z, temp2)

    // Combine with XOR
    NAVInt64BitXor(temp1, temp2, result)
}

/**
 * @function NAVSha384MAJ
 * @internal
 * @description SHA-384 MAJ function: (x AND y) XOR (x AND z) XOR (y AND z)
 * The "majority" function: for each bit position, select the value that appears
 * most often among the three inputs.
 *
 * @param {_NAVInt64} x - The first input value
 * @param {_NAVInt64} y - The second input value
 * @param {_NAVInt64} z - The third input value
 * @param {_NAVInt64} result - The result of the operation
 */
define_function NAVSha384MAJ(_NAVInt64 x, _NAVInt64 y, _NAVInt64 z, _NAVInt64 result) {
    stack_var _NAVInt64 temp1, temp2, temp3

    // x AND y
    NAVInt64BitAnd(x, y, temp1)

    // x AND z
    NAVInt64BitAnd(x, z, temp2)

    // y AND z
    NAVInt64BitAnd(y, z, temp3)

    // Combine with XOR
    NAVInt64BitXor(temp1, temp2, temp1)
    NAVInt64BitXor(temp1, temp3, result)
}

/**
 * @function NAVSha384TraceIntermediateState
 * @internal
 * @description Helper to trace the intermediate hash state
 * Logs the current values of the 8 hash registers for debugging.
 *
 * @param {_NAVSha384Context} context - The SHA context to trace
 */
define_function NAVSha384TraceIntermediateState(_NAVSha384Context context) {
    #IF_DEFINED SHA384_DEBUG
    if (SHA384_DEBUG_LEVEL >= SHA384_LEVEL_NORMAL) {
        stack_var integer i
        NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'SHA384: Current intermediate hash state:'")
        for (i = 1; i <= 8; i++) {
            NAVSha384DebugLog(SHA384_LEVEL_NORMAL, "'    Hash[', itoa(i), '] = ', NAVInt64ToDebugString(context.IntermediateHash[i])")
        }
    }
    #END_IF
}

// Add a helper function to log binary data in a readable way
/**
 * @function NAVSha384HexToString
 * @internal
 * @description Helper function to convert binary data to hexadecimal string
 *
 * @param {char[]} bytes - The binary data to convert
 *
 * @returns {char[500]} Hexadecimal string representation of the input data
 */
define_function char[500] NAVSha384HexToString(char bytes[]) {
    stack_var char result[500]
    stack_var integer i, len

    result = ''
    len = length_array(bytes)

    for (i = 1; i <= min_value(len, 128); i++) {
        // Use the proper hex formatting without commas
        result = "result, format('%02x', bytes[i])"
    }

    if (len > 128) {
        result = "result, '...'"
    }

    return result
}

#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_SHA384__
