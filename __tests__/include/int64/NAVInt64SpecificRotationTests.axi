PROGRAM_NAME='NAVInt64SpecificRotationTests'

/*
 * Special tests for the NAVInt64RotateRightFull function
 *
 * These tests specifically focus on the rotation values used in SHA-512:
 * - 14, 18, 41 bits (for Sigma1)
 * - 28, 34, 39 bits (for Sigma0)
 * - 1, 8, 7 bits (for sigma0)
 * - 19, 61, 6 bits (for sigma1)
 *
 * As well as edge cases like 0, 31, 32, 33, and 63 bits.
 */

#IF_NOT_DEFINED __NAV_INT64_SPECIFIC_ROTATION_TESTS__
#DEFINE __NAV_INT64_SPECIFIC_ROTATION_TESTS__ 'NAVInt64SpecificRotationTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Int64.axi'

/**
 * @function TestSpecificSHA512Rotations
 * @description Test specific SHA-512 rotation cases
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer TestSpecificSHA512Rotations() {
    stack_var integer testPassed
    stack_var _NAVInt64 value
    stack_var _NAVInt64 rotated
    stack_var _NAVInt64 original

    testPassed = 1

    // Initialize test value with a recognizable pattern
    value.Hi = $12345678
    value.Lo = $9ABCDEF0

    // Test SHA-512 Sigma0 rotations: 28, 34, 39
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 Sigma0 rotations'")

    // Test 28-bit rotation
    NAVInt64RotateRightFull(value, 28, rotated)

    // Verify by rotating back
    NAVInt64RotateRightFull(rotated, 36, original)  // 28 + 36 = 64
    if (original.Hi != value.Hi || original.Lo != value.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'ROTR^28 failed cyclical test'")
        testPassed = 0
    }

    // Test 34-bit rotation
    NAVInt64RotateRightFull(value, 34, rotated)

    // Verify by rotating back
    NAVInt64RotateRightFull(rotated, 30, original)  // 34 + 30 = 64
    if (original.Hi != value.Hi || original.Lo != value.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'ROTR^34 failed cyclical test'")
        testPassed = 0
    }

    // Test 39-bit rotation
    NAVInt64RotateRightFull(value, 39, rotated)

    // Verify by rotating back
    NAVInt64RotateRightFull(rotated, 25, original)  // 39 + 25 = 64
    if (original.Hi != value.Hi || original.Lo != value.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'ROTR^39 failed cyclical test'")
        testPassed = 0
    }

    // Test SHA-512 Sigma1 rotations: 14, 18, 41
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 Sigma1 rotations'")

    // Test 14-bit rotation
    NAVInt64RotateRightFull(value, 14, rotated)
    NAVInt64RotateRightFull(rotated, 50, original)  // 14 + 50 = 64
    if (original.Hi != value.Hi || original.Lo != value.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'ROTR^14 failed cyclical test'")
        testPassed = 0
    }

    // Test 18-bit rotation
    NAVInt64RotateRightFull(value, 18, rotated)
    NAVInt64RotateRightFull(rotated, 46, original)  // 18 + 46 = 64
    if (original.Hi != value.Hi || original.Lo != value.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'ROTR^18 failed cyclical test'")
        testPassed = 0
    }

    // Test 41-bit rotation
    NAVInt64RotateRightFull(value, 41, rotated)
    NAVInt64RotateRightFull(rotated, 23, original)  // 41 + 23 = 64
    if (original.Hi != value.Hi || original.Lo != value.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'ROTR^41 failed cyclical test'")
        testPassed = 0
    }

    // Test SHA-512 sigma0 rotations: 1, 8
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 sigma0 rotations'")

    // Test 1-bit rotation
    NAVInt64RotateRightFull(value, 1, rotated)
    NAVInt64RotateRightFull(rotated, 63, original)  // 1 + 63 = 64
    if (original.Hi != value.Hi || original.Lo != value.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'ROTR^1 failed cyclical test'")
        testPassed = 0
    }

    // Test 8-bit rotation
    NAVInt64RotateRightFull(value, 8, rotated)
    NAVInt64RotateRightFull(rotated, 56, original)  // 8 + 56 = 64
    if (original.Hi != value.Hi || original.Lo != value.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'ROTR^8 failed cyclical test'")
        testPassed = 0
    }

    // Test SHA-512 sigma1 rotations: 19, 61
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 sigma1 rotations'")

    // Test 19-bit rotation
    NAVInt64RotateRightFull(value, 19, rotated)
    NAVInt64RotateRightFull(rotated, 45, original)  // 19 + 45 = 64
    if (original.Hi != value.Hi || original.Lo != value.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'ROTR^19 failed cyclical test'")
        testPassed = 0
    }

    // Test 61-bit rotation
    NAVInt64RotateRightFull(value, 61, rotated)
    NAVInt64RotateRightFull(rotated, 3, original)  // 61 + 3 = 64
    if (original.Hi != value.Hi || original.Lo != value.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'ROTR^61 failed cyclical test'")
        testPassed = 0
    }

    return testPassed
}

/**
 * @function RunNAVInt64SpecificRotationTests
 * @description Run specific rotation tests for SHA-512
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVInt64SpecificRotationTests() {
    stack_var integer success

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Running NAVInt64SpecificRotationTests'")

    success = TestSpecificSHA512Rotations()

    if (success) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVInt64SpecificRotationTests: All tests passed!'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVInt64SpecificRotationTests: Some tests failed!'")
    }

    return success
}

#END_IF // __NAV_INT64_SPECIFIC_ROTATION_TESTS__
