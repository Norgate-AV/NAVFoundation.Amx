PROGRAM_NAME='NAVSha384InitialValueTests'

#IF_NOT_DEFINED __NAV_SHA384_INITIAL_VALUE_TESTS__
#DEFINE __NAV_SHA384_INITIAL_VALUE_TESTS__ 'NAVSha384InitialValueTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Int64.axi'
#include 'NAVFoundation.Cryptography.Sha384.h.axi'

/**
 * @function TestInitialHashValues
 * @description Verify that the initial hash values are set correctly
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer TestInitialHashValues() {
    stack_var _NAVSha384Context context
    stack_var integer testsPassed, totalTests
    stack_var integer i

    // The expected initial hash values (first 64 bits of the fractional parts of
    // the square roots of the first 8 prime numbers)
    stack_var long expectHi[8], expectLo[8]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 initial hash values'")

    // Initialize expected values (SHA-384 IVs from square roots of primes 23, 29, 31, 37, 41, 43, 47, 53)
    expectHi[1] = $cbbb9d5d; expectLo[1] = $c1059ed8
    expectHi[2] = $629a292a; expectLo[2] = $367cd507
    expectHi[3] = $9159015a; expectLo[3] = $3070dd17
    expectHi[4] = $152fecd8; expectLo[4] = $f70e5939
    expectHi[5] = $67332667; expectLo[5] = $ffc00b31
    expectHi[6] = $8eb44a87; expectLo[6] = $68581511
    expectHi[7] = $db0c2e0d; expectLo[7] = $64f98fa7
    expectHi[8] = $47b5481d; expectLo[8] = $befa4fa4

    // Reset the context to initialize hash values
    NAVSha384Reset(context)

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

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'SHA-384 initial hash values: ', itoa(testsPassed), ' of ', itoa(totalTests), ' passed'")
    return (testsPassed == totalTests)
}

/**
 * @function RunNAVSha384InitialValueTests
 * @description Run all SHA-384 initial value tests
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVSha384InitialValueTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVSha384InitialValue Tests ******************'")

    // Test initial hash values
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test: SHA-384 Initial Hash Values'")
    if (TestInitialHashValues()) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVSha384InitialValue: All tests passed!'")
        return 1
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha384InitialValue: Some tests failed!'")
        return 0
    }
}

#END_IF // __NAV_SHA384_INITIAL_VALUE_TESTS__
