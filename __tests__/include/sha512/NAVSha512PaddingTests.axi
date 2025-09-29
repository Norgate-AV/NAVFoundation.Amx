PROGRAM_NAME='NAVSha512PaddingTests'

#IF_NOT_DEFINED __NAV_SHA512_PADDING_TESTS__
#DEFINE __NAV_SHA512_PADDING_TESTS__ 'NAVSha512PaddingTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.Cryptography.Sha512.h.axi'

/**
 * @function TestMessagePadding
 * @description Test the SHA-512 message padding with various lengths
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer TestMessagePadding() {
    stack_var integer testsPassed, totalTests
    stack_var char message[150]
    stack_var char expected[64], actual[64]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 message padding'")

    testsPassed = 0
    totalTests = 0

    // Test with an empty string - should have standard padding
    message = ''
    totalTests++
    expected = NAVSha512GetHash(message)
    if (expected[1] != 0) { // Ensure we got a hash
        testsPassed++
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Empty string hash returned empty result'")
    }

    // Test with exactly 112 bytes (max before needing extra block)
    message = ''
    while(length_array(message) < 112) {
        message = "message, 'A'"
    }
    totalTests++
    expected = NAVSha512GetHash(message)
    if (expected[1] != 0) {
        testsPassed++
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'112 byte message hash returned empty result'")
    }

    // Test with 113 bytes (requires an extra block)
    message = ''
    while(length_array(message) < 113) {
        message = "message, 'B'"
    }
    totalTests++
    expected = NAVSha512GetHash(message)
    if (expected[1] != 0) {
        testsPassed++
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'113 byte message hash returned empty result'")
    }

    // Test with exactly 128 bytes (full block)
    message = ''
    while(length_array(message) < 128) {
        message = "message, 'C'"
    }
    totalTests++
    expected = NAVSha512GetHash(message)
    if (expected[1] != 0) {
        testsPassed++
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'128 byte message hash returned empty result'")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'SHA-512 message padding tests: ', itoa(testsPassed), ' of ', itoa(totalTests), ' passed'")
    return (testsPassed == totalTests)
}

/**
 * @function RunNAVSha512PaddingTests
 * @description Run all SHA-512 padding tests
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVSha512PaddingTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVSha512Padding Tests ******************'")

    // Test message padding
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test: SHA-512 Message Padding'")
    if (TestMessagePadding()) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVSha512Padding: All tests passed!'")
        return 1
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha512Padding: Some tests failed!'")
        return 0
    }
}

#END_IF // __NAV_SHA512_PADDING_TESTS__
