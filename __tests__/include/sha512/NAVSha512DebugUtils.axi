PROGRAM_NAME='NAVSha512DebugUtils'

/*
 * Debugging utilities for SHA-512 implementation
 */

#IF_NOT_DEFINED __NAV_SHA512_DEBUG_UTILS__
#DEFINE __NAV_SHA512_DEBUG_UTILS__ 'NAVSha512DebugUtils'

// Make sure we have SHA512_DEBUG defined for consistent behavior
#IF_NOT_DEFINED SHA512_DEBUG
#DEFINE SHA512_DEBUG
#END_IF

// Include required files
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Int64.axi'
#include 'NAVFoundation.Cryptography.Sha512.h.axi'

// IMPORTANT: Remove the duplicate function definition
// The NAVSha512DebugLog function is already defined in the main implementation

/**
 * @function DumpSha512Context
 * @description Outputs detailed information about a SHA-512 context
 *
 * @param {_NAVSha512Context} context - The context to analyze
 */
define_function DumpSha512Context(_NAVSha512Context context) {
    stack_var integer i
    stack_var char hashStr[17]

    // Use the debug log function from the main implementation
    NAVSha512DebugLog(SHA512_LEVEL_MINIMAL, "'SHA-512 Context:'")
    NAVSha512DebugLog(SHA512_LEVEL_MINIMAL, "'- Computed: ', itoa(context.Computed)")
    NAVSha512DebugLog(SHA512_LEVEL_MINIMAL, "'- Corrupted: ', itoa(context.Corrupted)")
    NAVSha512DebugLog(SHA512_LEVEL_MINIMAL, "'- MessageBlockIndex: ', itoa(context.MessageBlockIndex)")

    // Length
    NAVInt64ToString(context.LengthHigh, hashStr)
    NAVSha512DebugLog(SHA512_LEVEL_NORMAL, "'- LengthHigh: ', hashStr")
    NAVInt64ToString(context.LengthLow, hashStr)
    NAVSha512DebugLog(SHA512_LEVEL_NORMAL, "'- LengthLow: ', hashStr")

    // Intermediate hash
    for (i = 1; i <= 8; i++) {
        NAVInt64ToHexString(context.IntermediateHash[i], hashStr, 0)
        NAVSha512DebugLog(SHA512_LEVEL_NORMAL, "'- Hash[', itoa(i), '] = $', hashStr")
    }

    // First few bytes of message block - only in verbose mode
    NAVSha512DebugLog(SHA512_LEVEL_VERBOSE, "'- MessageBlock (first 16 bytes): ',
        format('%02x', type_cast(context.MessageBlock[1])), ' ',
        format('%02x', type_cast(context.MessageBlock[2])), ' ',
        format('%02x', type_cast(context.MessageBlock[3])), ' ',
        format('%02x', type_cast(context.MessageBlock[4])), ' ',
        format('%02x', type_cast(context.MessageBlock[5])), ' ',
        format('%02x', type_cast(context.MessageBlock[6])), ' ',
        format('%02x', type_cast(context.MessageBlock[7])), ' ',
        format('%02x', type_cast(context.MessageBlock[8])), ' ',
        format('%02x', type_cast(context.MessageBlock[9])), ' ',
        format('%02x', type_cast(context.MessageBlock[10])), ' ',
        format('%02x', type_cast(context.MessageBlock[11])), ' ',
        format('%02x', type_cast(context.MessageBlock[12])), ' ',
        format('%02x', type_cast(context.MessageBlock[13])), ' ',
        format('%02x', type_cast(context.MessageBlock[14])), ' ',
        format('%02x', type_cast(context.MessageBlock[15])), ' ',
        format('%02x', type_cast(context.MessageBlock[16])), '...'")
}

/**
 * @function VerifySha512W
 * @description Verifies the calculated message schedule against expected values
 *
 * @param {_NAVInt64[]} W - The message schedule array
 * @param {char[]} expectedHex[] - Array of expected hex values for W[0]...W[15]
 * @param {integer} count - Number of elements to check
 *
 * @returns {integer} 1 if all match, 0 if any differ
 */
define_function integer VerifySha512W(_NAVInt64 W[], char expectedHex[][], integer count) {
    stack_var integer i
    stack_var char actualHex[17]

    for (i = 1; i <= count; i++) {
        NAVInt64ToHexString(W[i], actualHex, 0)
        if (actualHex != expectedHex[i]) {
            NAVSha512DebugLog(SHA512_LEVEL_MINIMAL, "'W[', itoa(i), '] mismatch:'")
            NAVSha512DebugLog(SHA512_LEVEL_MINIMAL, "'  Expected: $', expectedHex[i]")
            NAVSha512DebugLog(SHA512_LEVEL_MINIMAL, "'  Got:      $', actualHex")
            return 0
        }
    }
    return 1
}

#END_IF // __NAV_SHA512_DEBUG_UTILS__
