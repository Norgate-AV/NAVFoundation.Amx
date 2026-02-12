// Include core libraries first
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Encoding.axi'

// Define SHA384_DEBUG only if not already defined
#IF_NOT_DEFINED SHA384_DEBUG
#DEFINE SHA384_DEBUG
#END_IF

// Include the SHA-384 implementation which defines the debug levels
#include 'NAVFoundation.Cryptography.Sha384.axi'

// Make sure the debug utils knows about the implementation first
#include 'NAVSha384DebugUtils.axi'

// Define test flags
#DEFINE TESTING_SHA384_SIGMA
#DEFINE TESTING_SHA384_VECTORS
#DEFINE TESTING_SHA384_BLOCK
#DEFINE TESTING_SHA384_OPERATIONS
#DEFINE TESTING_SHA384_INITIAL_VALUES
#DEFINE TESTING_SHA384_PADDING
#DEFINE TESTING_SHA384_HASH

// Only include test modules if they're requested
#IF_DEFINED TESTING_SHA384_SIGMA
#include 'NAVSha384SigmaTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA384_VECTORS
#include 'NAVSha384VectorTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA384_BLOCK
#include 'NAVSha384BlockTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA384_OPERATIONS
#include 'NAVSha384OperationsTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA384_HASH
#include 'NAVSha384HashTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA384_INITIAL_VALUES
#include 'NAVSha384InitialValueTests.axi'
#END_IF

#IF_DEFINED TESTING_SHA384_PADDING
#include 'NAVSha384PaddingTests.axi'
#END_IF

/**
 * @function NAVSha384TestCompareHex
 * @description Compares binary SHA-384 digest with an expected hex string
 *
 * @param {char[48]} digest - Binary SHA-384 digest (48 bytes)
 * @param {char[96]} expected - Expected SHA-384 digest as hex string (96 chars)
 *
 * @returns {integer} 1 if match, 0 if they differ
 */
define_function integer NAVSha384TestCompareHex(char digest[48], char expected[96]) {
    stack_var char hexDigest[96]
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
 * @function NAVSha384Test
 * @description Run SHA-384 test with a given input and expected output
 *
 * @param {char[]} input - Input string to hash
 * @param {char[96]} expected - Expected SHA-384 digest as hex string
 *
 * @returns {integer} 1 if test passes, 0 if it fails
 */
define_function integer NAVSha384Test(char input[], char expected[96]) {
    stack_var char digest[48]

    // Compute the SHA-384 hash
    digest = NAVSha384GetHash(input)

    // Compare the computed digest with expected value
    return NAVSha384TestCompareHex(digest, expected)
}

define_function RunSha384Tests() {
    #IF_DEFINED TESTING_SHA384_SIGMA
    // First run the Sigma function tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-384 Sigma Function Tests ====='")
    RunNAVSha384SigmaTests()
    #END_IF

    #IF_DEFINED TESTING_SHA384_OPERATIONS
    // Run the SHA-384 operations tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-384 Operations Tests ====='")
    RunNAVSha384OperationsTests()
    #END_IF

    #IF_DEFINED TESTING_SHA384_BLOCK
    // Run the block processing tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-384 Block Processing Tests ====='")
    RunNAVSha384BlockTests()
    #END_IF

    #IF_DEFINED TESTING_SHA384_VECTORS
    // Run the test vectors
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-384 Test Vector Tests ====='")
    RunNAVSha384VectorTests()
    #END_IF

    #IF_DEFINED TESTING_SHA384_HASH
    // Then run the full SHA-384 hash tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-384 Hash Tests ====='")
    RunNAVSha384HashTests()
    #END_IF

    #IF_DEFINED TESTING_SHA384_INITIAL_VALUES
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-384 Initial Value Tests ====='")
    RunNAVSha384InitialValueTests()
    #END_IF

    #IF_DEFINED TESTING_SHA384_PADDING
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-384 Padding Tests ====='")
    RunNAVSha384PaddingTests()
    #END_IF
}
