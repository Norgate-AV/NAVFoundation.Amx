PROGRAM_NAME='sha512'

#DEFINE __MAIN__

// Include core libraries first
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Encoding.axi'

// Define SHA512_DEBUG only if not already defined
#IF_NOT_DEFINED SHA512_DEBUG
#DEFINE SHA512_DEBUG
#END_IF

// Include the SHA-512 implementation which defines the debug levels
#include 'NAVFoundation.Cryptography.Sha512.axi'

// Make sure the debug utils knows about the implementation first
#include 'NAVSha512DebugUtils.axi'

// Define test flags
#DEFINE TESTING_SHA512_SIGMA
#DEFINE TESTING_SHA512_VECTORS
#DEFINE TESTING_SHA512_BLOCK
#DEFINE TESTING_SHA512_OPERATIONS
#DEFINE TESTING_SHA512_INITIAL_VALUES
#DEFINE TESTING_SHA512_PADDING
#DEFINE TESTING_SHA512_HASH

// Only include test modules if they're requested
#IF_DEFINED TESTING_SHA512_SIGMA
#include 'NAVSha512SigmaTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA512_VECTORS
#include 'NAVSha512VectorTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA512_BLOCK
#include 'NAVSha512BlockTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA512_OPERATIONS
#include 'NAVSha512OperationsTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA512_HASH
#include 'NAVSha512HashTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA512_INITIAL_VALUES
#include 'NAVSha512InitialValueTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA512_PADDING
#include 'NAVSha512PaddingTests.axi'
#END_IF


DEFINE_DEVICE

dvTP    =   10001:1:0


define_function RunTests() {
    #IF_DEFINED TESTING_SHA512_SIGMA
    // First run the Sigma function tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-512 Sigma Function Tests ====='")
    RunNAVSha512SigmaTests()
    #END_IF

    #IF_DEFINED TESTING_SHA512_OPERATIONS
    // Run the SHA-512 operations tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-512 Operations Tests ====='")
    RunNAVSha512OperationsTests()
    #END_IF

    #IF_DEFINED TESTING_SHA512_BLOCK
    // Run the block processing tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-512 Block Processing Tests ====='")
    RunNAVSha512BlockTests()
    #END_IF

    #IF_DEFINED TESTING_SHA512_VECTORS
    // Run the test vectors
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-512 Test Vector Tests ====='")
    RunNAVSha512VectorTests()
    #END_IF

    #IF_DEFINED TESTING_SHA512_HASH
    // Then run the full SHA-512 hash tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-512 Hash Tests ====='")
    RunNAVSha512HashTests()
    #END_IF

    #IF_DEFINED TESTING_SHA512_INITIAL_VALUES
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-512 Initial Value Tests ====='")
    RunNAVSha512InitialValueTests()
    #END_IF

    #IF_DEFINED TESTING_SHA512_PADDING
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-512 Padding Tests ====='")
    RunNAVSha512PaddingTests()
    #END_IF
}


/**
 * @function NAVSha512TestCompareHex
 * @description Compares binary SHA-512 digest with an expected hex string
 *
 * @param {char[64]} digest - Binary SHA-512 digest (64 bytes)
 * @param {char[128]} expected - Expected SHA-512 digest as hex string (128 chars)
 *
 * @returns {integer} 1 if match, 0 if they differ
 */
define_function integer NAVSha512TestCompareHex(char digest[64], char expected[128]) {
    stack_var char hexDigest[128]
    stack_var integer i

    // Convert binary digest to lowercase hex string
    hexDigest = NAVHexToString(digest)

    // Debug output to see exact comparison
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', expected")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', hexDigest")

    // Compare the hex strings
    return (hexDigest == expected)
}

/**
 * @function NAVSha512Test
 * @description Run SHA-512 test with a given input and expected output
 *
 * @param {char[]} input - Input string to hash
 * @param {char[128]} expected - Expected SHA-512 digest as hex string
 *
 * @returns {integer} 1 if test passes, 0 if it fails
 */
define_function integer NAVSha512Test(char input[], char expected[128]) {
    stack_var char digest[64]

    // Compute the SHA-512 hash
    digest = NAVSha512GetHash(input)

    // Compare the computed digest with expected value
    return NAVSha512TestCompareHex(digest, expected)
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        set_log_level(NAV_LOG_LEVEL_DEBUG)
        RunTests()
    }
}
