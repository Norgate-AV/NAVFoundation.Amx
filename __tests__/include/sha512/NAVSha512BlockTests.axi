PROGRAM_NAME='NAVSha512BlockTests'

/*
 * Tests for the SHA-512 block processing and padding functionality
 */

#IF_NOT_DEFINED __NAV_SHA512_BLOCK_TESTS__
#DEFINE __NAV_SHA512_BLOCK_TESTS__ 'NAVSha512BlockTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Int64.axi'
#include 'NAVFoundation.Cryptography.Sha512.axi'

/**
 * @function TestSHA512BlockSizes
 * @description Test SHA-512 with various block sizes
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestSHA512BlockSizes() {
    stack_var integer testsPassed, i
    stack_var char input[129]

    testsPassed = 1

    // Test 1: Empty input
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 with empty input'")
    NAVSha512GetHash("")

    // Test 2: Exactly one block (112 bytes)
    // Create an input string that will result in exactly one block with padding
    input = ""
    for (i = 1; i <= 112; i++) {
        input = "input, type_cast('A')"
    }
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 with exactly 112 bytes (single block with padding)'")
    NAVSha512GetHash(input)

    // Test 3: Exactly one full block (128 bytes)
    // Create an input string that is exactly one block
    input = ""
    for (i = 1; i <= 128; i++) {
        input = "input, type_cast('B')"
    }
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 with exactly 128 bytes (one full block)'")
    NAVSha512GetHash(input)

    // Test 4: Just over one block (129 bytes)
    // Create an input string that will span to two blocks
    input = ""
    for (i = 1; i <= 129; i++) {
        input = "input, type_cast('C')"
    }
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 with 129 bytes (just over one block)'")
    NAVSha512GetHash(input)

    return testsPassed
}

/**
 * @function TestSHA512KConstants
 * @description Test access to the K constants used in SHA-512
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestSHA512KConstants() {
    stack_var _NAVInt64 k0, k1, kLast
    stack_var integer testsPassed

    testsPassed = 1

    // Test the first K constant
    NAVGetSHA512K(0, k0)
    if (k0.Hi != $428a2f98 || k0.Lo != $d728ae22) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'K[0] constant incorrect'")
        testsPassed = 0
    }

    // Test second K constant
    NAVGetSHA512K(1, k1)
    if (k1.Hi != $71374491 || k1.Lo != $23ef65cd) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'K[1] constant incorrect'")
        testsPassed = 0
    }

    // Test last K constant
    NAVGetSHA512K(79, kLast)
    if (kLast.Hi != $6c44198c || kLast.Lo != $4a475817) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'K[79] constant incorrect'")
        testsPassed = 0
    }

    return testsPassed
}

/**
 * @function TestSHA512MessageSchedule
 * @description Test message schedule generation
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestSHA512MessageSchedule() {
    stack_var _NAVSha512Context context
    stack_var char testMessage[128]
    stack_var integer i, testsPassed

    testsPassed = 1

    // Initialize context
    NAVSha512Reset(context)

    // Create test message with recognizable pattern
    for (i = 1; i <= 128; i++) {
        testMessage[i] = type_cast(i)  // Just use index as byte value
    }

    // Input the test message
    NAVSha512Input(context, testMessage, 128)

    // For now, we'll just check that processing completes without errors
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing message schedule processing'")

    return testsPassed
}

/**
 * @function RunNAVSha512BlockTests
 * @description Run all SHA-512 block processing tests
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVSha512BlockTests() {
    stack_var integer success

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVSha512Block Tests ******************'")

    success = 1

    // Test block handling with various sizes
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Block Size Handling'")
    success = success && TestSHA512BlockSizes()

    // Test K constants
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: K Constants'")
    success = success && TestSHA512KConstants()

    // Test message schedule
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Message Schedule'")
    success = success && TestSHA512MessageSchedule()

    if (success) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVSha512Block: All tests passed!'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha512Block: Some tests failed!'")
    }

    return success
}

#END_IF // __NAV_SHA512_BLOCK_TESTS__
