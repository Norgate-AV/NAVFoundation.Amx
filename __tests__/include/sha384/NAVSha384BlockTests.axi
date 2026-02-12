PROGRAM_NAME='NAVSha384BlockTests'

/*
 * Tests for the SHA-384 block processing and padding functionality
 */

#IF_NOT_DEFINED __NAV_SHA384_BLOCK_TESTS__
#DEFINE __NAV_SHA384_BLOCK_TESTS__ 'NAVSha384BlockTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Int64.axi'
#include 'NAVFoundation.Cryptography.Sha384.axi'

/**
 * @function TestSHA384BlockSizes
 * @description Test SHA-384 with various block sizes
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestSHA384BlockSizes() {
    stack_var integer testsPassed, i
    stack_var char input[129]

    testsPassed = 1

    // Test 1: Empty input
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 with empty input'")
    NAVSha384GetHash("")

    // Test 2: Exactly one block (112 bytes)
    // Create an input string that will result in exactly one block with padding
    input = ""
    for (i = 1; i <= 112; i++) {
        input = "input, type_cast('A')"
    }
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 with exactly 112 bytes (single block with padding)'")
    NAVSha384GetHash(input)

    // Test 3: Exactly one full block (128 bytes)
    // Create an input string that is exactly one block
    input = ""
    for (i = 1; i <= 128; i++) {
        input = "input, type_cast('B')"
    }
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 with exactly 128 bytes (one full block)'")
    NAVSha384GetHash(input)

    // Test 4: Just over one block (129 bytes)
    // Create an input string that will span to two blocks
    input = ""
    for (i = 1; i <= 129; i++) {
        input = "input, type_cast('C')"
    }
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 with 129 bytes (just over one block)'")
    NAVSha384GetHash(input)

    return testsPassed
}

/**
 * @function TestSHA384KConstants
 * @description Test access to the K constants used in SHA-384
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestSHA384KConstants() {
    stack_var _NAVInt64 k0, k1, kLast
    stack_var integer testsPassed

    testsPassed = 1

    // Test the first K constant
    NAVGetSHA384K(0, k0)
    if (k0.Hi != $428a2f98 || k0.Lo != $d728ae22) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'K[0] constant incorrect'")
        testsPassed = 0
    }

    // Test second K constant
    NAVGetSHA384K(1, k1)
    if (k1.Hi != $71374491 || k1.Lo != $23ef65cd) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'K[1] constant incorrect'")
        testsPassed = 0
    }

    // Test last K constant
    NAVGetSHA384K(79, kLast)
    if (kLast.Hi != $6c44198c || kLast.Lo != $4a475817) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'K[79] constant incorrect'")
        testsPassed = 0
    }

    return testsPassed
}

/**
 * @function TestSHA384MessageSchedule
 * @description Test message schedule generation
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestSHA384MessageSchedule() {
    stack_var _NAVSha384Context context
    stack_var char testMessage[128]
    stack_var integer i, testsPassed

    testsPassed = 1

    // Initialize context
    NAVSha384Reset(context)

    // Create test message with recognizable pattern
    for (i = 1; i <= 128; i++) {
        testMessage[i] = type_cast(i)  // Just use index as byte value
    }

    // Input the test message
    NAVSha384Input(context, testMessage, 128)

    // For now, we'll just check that processing completes without errors
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing message schedule processing'")

    return testsPassed
}

/**
 * @function RunNAVSha384BlockTests
 * @description Run all SHA-384 block processing tests
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVSha384BlockTests() {
    stack_var integer success

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVSha384Block Tests ******************'")

    success = 1

    // Test block handling with various sizes
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Block Size Handling'")
    success = success && TestSHA384BlockSizes()

    // Test K constants
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: K Constants'")
    success = success && TestSHA384KConstants()

    // Test message schedule
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Message Schedule'")
    success = success && TestSHA384MessageSchedule()

    if (success) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVSha384Block: All tests passed!'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha384Block: Some tests failed!'")
    }

    return success
}

#END_IF // __NAV_SHA384_BLOCK_TESTS__
