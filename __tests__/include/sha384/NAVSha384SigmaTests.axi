PROGRAM_NAME='NAVSha384SigmaTests'

/*
 * Tests for the SHA-384 specific Sigma functions
 *
 * These tests verify that the SHA-384 specific Sigma functions work correctly:
 * - SigmaBig0: ROTR^28(x) XOR ROTR^34(x) XOR ROTR^39(x)
 * - SigmaBig1: ROTR^14(x) XOR ROTR^18(x) XOR ROTR^41(x)
 * - SigmaSmall0: ROTR^1(x) XOR ROTR^8(x) XOR SHR^7(x)
 * - SigmaSmall1: ROTR^19(x) XOR ROTR^61(x) XOR SHR^6(x)
 * - CH: (x AND y) XOR ((NOT x) AND z)
 * - MAJ: (x AND y) XOR (x AND z) XOR (y AND z)
 */

#IF_NOT_DEFINED __NAV_SHA384_SIGMA_TESTS__
#DEFINE __NAV_SHA384_SIGMA_TESTS__ 'NAVSha384SigmaTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Int64.axi'
// We already include this in the main test file, so it's not necessary here
// #include 'NAVFoundation.Cryptography.Sha384.axi'

/**
 * @function TestSigmaBig0
 * @description Manually calculate SigmaBig0 and compare with function
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestSigmaBig0() {
    stack_var integer testPassed
    stack_var _NAVInt64 value
    stack_var _NAVInt64 rot28, rot34, rot39, expected, actual

    testPassed = 1

    // Initialize test value with a recognizable pattern
    value.Hi = $12345678
    value.Lo = $9ABCDEF0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 SigmaBig0 function'")

    // Manually calculate SigmaBig0 = ROTR^28(x) XOR ROTR^34(x) XOR ROTR^39(x)
    NAVInt64RotateRightFull(value, 28, rot28)
    NAVInt64RotateRightFull(value, 34, rot34)
    NAVInt64RotateRightFull(value, 39, rot39)

    // Calculate expected result
    NAVInt64BitXor(rot28, rot34, expected)
    NAVInt64BitXor(expected, rot39, expected)

    // Get actual result from function
    NAVSha384SigmaBig0(value, actual)

    // Compare results
    if (actual.Hi != expected.Hi || actual.Lo != expected.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'SigmaBig0 test failed'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got:      $', format('%08x', actual.Hi), format('%08x', actual.Lo)")
        testPassed = 0
    }

    return testPassed
}

/**
 * @function TestSigmaBig1
 * @description Manually calculate SigmaBig1 and compare with function
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestSigmaBig1() {
    stack_var integer testPassed
    stack_var _NAVInt64 value
    stack_var _NAVInt64 rot14, rot18, rot41, expected, actual

    testPassed = 1

    // Initialize test value with a recognizable pattern
    value.Hi = $12345678
    value.Lo = $9ABCDEF0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 SigmaBig1 function'")

    // Manually calculate SigmaBig1 = ROTR^14(x) XOR ROTR^18(x) XOR ROTR^41(x)
    NAVInt64RotateRightFull(value, 14, rot14)
    NAVInt64RotateRightFull(value, 18, rot18)
    NAVInt64RotateRightFull(value, 41, rot41)

    // Calculate expected result
    NAVInt64BitXor(rot14, rot18, expected)
    NAVInt64BitXor(expected, rot41, expected)

    // Get actual result from function
    NAVSha384SigmaBig1(value, actual)

    // Compare results
    if (actual.Hi != expected.Hi || actual.Lo != expected.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'SigmaBig1 test failed'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got:      $', format('%08x', actual.Hi), format('%08x', actual.Lo)")
        testPassed = 0
    }

    return testPassed
}

/**
 * @function TestSigmaSmall0
 * @description Manually calculate SigmaSmall0 and compare with function
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestSigmaSmall0() {
    stack_var integer testPassed
    stack_var _NAVInt64 value
    stack_var _NAVInt64 rot1, rot8, shr7, expected, actual

    testPassed = 1

    // Initialize test value with a recognizable pattern
    value.Hi = $12345678
    value.Lo = $9ABCDEF0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 SigmaSmall0 function'")

    // Manually calculate SigmaSmall0 = ROTR^1(x) XOR ROTR^8(x) XOR SHR^7(x)
    NAVInt64RotateRightFull(value, 1, rot1)
    NAVInt64RotateRightFull(value, 8, rot8)
    NAVInt64ShiftRight(value, 7, shr7)

    // Calculate expected result
    NAVInt64BitXor(rot1, rot8, expected)
    NAVInt64BitXor(expected, shr7, expected)

    // Get actual result from function
    NAVSha384SigmaSmall0(value, actual)

    // Compare results
    if (actual.Hi != expected.Hi || actual.Lo != expected.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'SigmaSmall0 test failed'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got:      $', format('%08x', actual.Hi), format('%08x', actual.Lo)")
        testPassed = 0
    }

    return testPassed
}

/**
 * @function TestSigmaSmall1
 * @description Manually calculate SigmaSmall1 and compare with function
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestSigmaSmall1() {
    stack_var integer testPassed
    stack_var _NAVInt64 value
    stack_var _NAVInt64 rot19, rot61, shr6, expected, actual

    testPassed = 1

    // Initialize test value with a recognizable pattern
    value.Hi = $12345678
    value.Lo = $9ABCDEF0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 SigmaSmall1 function'")

    // Manually calculate SigmaSmall1 = ROTR^19(x) XOR ROTR^61(x) XOR SHR^6(x)
    NAVInt64RotateRightFull(value, 19, rot19)
    NAVInt64RotateRightFull(value, 61, rot61)
    NAVInt64ShiftRight(value, 6, shr6)

    // Calculate expected result
    NAVInt64BitXor(rot19, rot61, expected)
    NAVInt64BitXor(expected, shr6, expected)

    // Get actual result from function
    NAVSha384SigmaSmall1(value, actual)

    // Compare results
    if (actual.Hi != expected.Hi || actual.Lo != expected.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'SigmaSmall1 test failed'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got:      $', format('%08x', actual.Hi), format('%08x', actual.Lo)")
        testPassed = 0
    }

    return testPassed
}

/**
 * @function TestCH
 * @description Test the CH function: (x AND y) XOR ((NOT x) AND z)
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestCH() {
    stack_var integer testPassed
    stack_var _NAVInt64 x, y, z
    stack_var _NAVInt64 temp1, temp2, notX, expected, actual

    testPassed = 1

    // Initialize test values
    x.Hi = $AAAAAAAA  // 10101010...
    x.Lo = $AAAAAAAA

    y.Hi = $CCCCCCCC  // 11001100...
    y.Lo = $CCCCCCCC

    z.Hi = $F0F0F0F0  // 11110000...
    z.Lo = $F0F0F0F0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 CH function'")

    // Manually calculate CH = (x AND y) XOR ((NOT x) AND z)
    NAVInt64BitAnd(x, y, temp1)

    NAVInt64BitNot(x, notX)
    NAVInt64BitAnd(notX, z, temp2)

    NAVInt64BitXor(temp1, temp2, expected)

    // Get actual result from function
    NAVSha384CH(x, y, z, actual)

    // Compare results
    if (actual.Hi != expected.Hi || actual.Lo != expected.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'CH test failed'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got:      $', format('%08x', actual.Hi), format('%08x', actual.Lo)")
        testPassed = 0
    }

    return testPassed
}

/**
 * @function TestMAJ
 * @description Test the MAJ function: (x AND y) XOR (x AND z) XOR (y AND z)
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestMAJ() {
    stack_var integer testPassed
    stack_var _NAVInt64 x, y, z
    stack_var _NAVInt64 temp1, temp2, temp3, expected, actual

    testPassed = 1

    // Initialize test values
    x.Hi = $AAAAAAAA  // 10101010...
    x.Lo = $AAAAAAAA

    y.Hi = $CCCCCCCC  // 11001100...
    y.Lo = $CCCCCCCC

    z.Hi = $F0F0F0F0  // 11110000...
    z.Lo = $F0F0F0F0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-384 MAJ function'")

    // Manually calculate MAJ = (x AND y) XOR (x AND z) XOR (y AND z)
    NAVInt64BitAnd(x, y, temp1)
    NAVInt64BitAnd(x, z, temp2)
    NAVInt64BitAnd(y, z, temp3)

    NAVInt64BitXor(temp1, temp2, expected)
    NAVInt64BitXor(expected, temp3, expected)

    // Get actual result from function
    NAVSha384MAJ(x, y, z, actual)

    // Compare results
    if (actual.Hi != expected.Hi || actual.Lo != expected.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'MAJ test failed'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got:      $', format('%08x', actual.Hi), format('%08x', actual.Lo)")
        testPassed = 0
    }

    return testPassed
}

/**
 * @function RunNAVSha384SigmaTests
 * @description Run all SHA-384 Sigma function tests
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVSha384SigmaTests() {
    stack_var integer success

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVSha384Sigma Tests ******************'")

    success = 1

    // Test SigmaBig0
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: SigmaBig0'")
    success = success && TestSigmaBig0()

    // Test SigmaBig1
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: SigmaBig1'")
    success = success && TestSigmaBig1()

    // Test SigmaSmall0
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: SigmaSmall0'")
    success = success && TestSigmaSmall0()

    // Test SigmaSmall1
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4: SigmaSmall1'")
    success = success && TestSigmaSmall1()

    // Test CH
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5: CH'")
    success = success && TestCH()

    // Test MAJ
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 6: MAJ'")
    success = success && TestMAJ()

    if (success) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVSha384Sigma: All tests passed!'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVSha384Sigma: Some tests failed!'")
    }

    return success
}

#END_IF // __NAV_SHA384_SIGMA_TESTS__
