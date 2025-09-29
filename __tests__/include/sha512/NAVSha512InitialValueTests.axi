PROGRAM_NAME='NAVSha512InitialValueTests'

#IF_NOT_DEFINED __NAV_SHA512_INITIAL_VALUE_TESTS__
#DEFINE __NAV_SHA512_INITIAL_VALUE_TESTS__ 'NAVSha512InitialValueTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Int64.axi'
#include 'NAVFoundation.Cryptography.Sha512.h.axi'

/**
 * @function TestInitialHashValues
 * @description Verify that the initial hash values are set correctly
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer TestInitialHashValues() {
    stack_var _NAVSha512Context context
    stack_var integer testsPassed, totalTests
    stack_var integer i

    // The expected initial hash values (first 64 bits of the fractional parts of
    // the square roots of the first 8 prime numbers)
    stack_var long expectHi[8], expectLo[8]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 initial hash values'")

    // Initialize expected values
    expectHi[1] = $6a09e667; expectLo[1] = $f3bcc908
    expectHi[2] = $bb67ae85; expectLo[2] = $84caa73b
    expectHi[3] = $3c6ef372; expectLo[3] = $fe94f82b
    expectHi[4] = $a54ff53a; expectLo[4] = $5f1d36f1
    expectHi[5] = $510e527f; expectLo[5] = $ade682d1
    expectHi[6] = $9b05688c; expectLo[6] = $2b3e6c1f
    expectHi[7] = $1f83d9ab; expectLo[7] = $fb41bd6b
    expectHi[8] = $5be0cd19; expectLo[8] = $137e2179

    // Reset the context to initialize hash values
    NAVSha512Reset(context)

    // Verify each of the 8 hash values
    testsPassed = 0
    totalTests = 8

    for (i = 1; i <= 8; i++) {
        if (context.IntermediateHash[i].Hi == expectHi[i] &&
            context.IntermediateHash[i].Lo == expectLo[i]) {
            testsPassed++
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Initial hash value [', itoa(i), '] is incorrect'")
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expectHi[i]), ' $', format('%08x', expectLo[i])")
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got     : $', format('%08x', context.IntermediateHash[i].Hi), ' $', format('%08x', context.IntermediateHash[i].Lo)")
        }
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'SHA-512 initial hash values: ', itoa(testsPassed), ' of ', itoa(totalTests), ' passed'")
    return (testsPassed == totalTests)
}

/**
 * @function RunNAVSha512InitialValueTests
 * @description Run all SHA-512 initial value tests
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVSha512InitialValueTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVSha512InitialValue Tests ******************'")

    // Test initial hash values
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test: SHA-512 Initial Hash Values'")
    if (TestInitialHashValues()) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVSha512InitialValue: All tests passed!'")
        return 1
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha512InitialValue: Some tests failed!'")
        return 0
    }
}

#END_IF // __NAV_SHA512_INITIAL_VALUE_TESTS__
