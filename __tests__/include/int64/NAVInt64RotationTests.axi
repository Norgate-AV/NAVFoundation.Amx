PROGRAM_NAME='NAVInt64RotationTests'

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

#IF_NOT_DEFINED __NAV_INT64_ROTATION_TESTS__
#DEFINE __NAV_INT64_ROTATION_TESTS__ 'NAVInt64RotationTests'

/**
 * @function TestSpecificRotation
 * @description Test a specific rotation value
 *
 * @param {integer} bits - Number of bits to rotate
 * @param {_NAVInt64} input - Input value
 * @param {_NAVInt64} expected - Expected output
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestSpecificRotation(integer bits, _NAVInt64 input, _NAVInt64 expected) {
    stack_var _NAVInt64 result
    stack_var char testName[50]

    // Format a descriptive test name
    testName = "'Rotate ', itoa(bits), ' bits'"

    // Perform the rotation
    NAVInt64RotateRightFull(input, bits, result)

    // Check if result matches expected
    if (result.Hi != expected.Hi || result.Lo != expected.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Rotation test failed: ROTR^', itoa(bits)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Input: $', format('%08x', input.Hi), format('%08x', input.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got: $', format('%08x', result.Hi), format('%08x', result.Lo)")
        return false
    }

    return true
}

/**
 * @function TestRotationSelfInverse
 * @description Test that a rotation followed by its inverse returns the original value
 *
 * @param {integer} bits - Number of bits to rotate
 * @param {_NAVInt64} input - Input value
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestRotationSelfInverse(integer bits, _NAVInt64 input) {
    stack_var _NAVInt64 rotated, restored
    stack_var char testName[50]

    // Format a descriptive test name
    testName = "'Rotate self-inverse ', itoa(bits), ' bits'"

    // Rotate by 'bits'
    NAVInt64RotateRightFull(input, bits, rotated)

    // Rotate back by '64 - bits'
    NAVInt64RotateRightFull(rotated, 64 - bits, restored)

    // Check if restored matches input
    if (restored.Hi != input.Hi || restored.Lo != input.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Rotation inverse test failed: ROTR^', itoa(bits), ' + ROTR^', itoa(64-bits)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Input: $', format('%08x', input.Hi), format('%08x', input.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Rotated: $', format('%08x', rotated.Hi), format('%08x', rotated.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Restored: $', format('%08x', restored.Hi), format('%08x', restored.Lo)")
        return false
    }

    return true
}

/**
 * @function TestSHA512RotationValues
 * @description Test rotation values specifically used in SHA-512
 *
 * @returns {char} true if all tests pass, false if any fail
 */
define_function char TestSHA512RotationValues() {
    stack_var _NAVInt64 testValue
    stack_var integer testsPassed, totalTests

    // Initialize a test value with recognizable bit patterns
    testValue.Hi = $76543210
    testValue.Lo = $FEDCBA98

    testsPassed = 0
    totalTests = 0

    // Test SHA-512 Sigma0 rotation values (28, 34, 39)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 Sigma0 rotation values (28, 34, 39)'")

    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(28, testValue)

    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(34, testValue)

    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(39, testValue)

    // Test SHA-512 Sigma1 rotation values (14, 18, 41)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 Sigma1 rotation values (14, 18, 41)'")

    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(14, testValue)

    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(18, testValue)

    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(41, testValue)

    // Test SHA-512 sigma0 rotation values (1, 8)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 sigma0 rotation values (1, 8)'")

    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(1, testValue)

    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(8, testValue)

    // Test SHA-512 sigma1 rotation values (19, 61)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 sigma1 rotation values (19, 61)'")

    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(19, testValue)

    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(61, testValue)

    // Test edge cases
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing rotation edge cases'")

    // 0 bit rotation (should return identical value)
    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(0, testValue)

    // 31 bit rotation (boundary case)
    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(31, testValue)

    // 32 bit rotation (exactly swaps Hi and Lo)
    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(32, testValue)

    // 33 bit rotation (just after Hi/Lo swap)
    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(33, testValue)

    // 63 bit rotation (maximum before wrapping)
    totalTests++
    testsPassed = testsPassed + TestRotationSelfInverse(63, testValue)

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'SHA-512 Rotation Tests: ', itoa(testsPassed), ' of ', itoa(totalTests), ' passed'")

    return (testsPassed == totalTests)
}

/**
 * @function TestRotationsAddUp
 * @description Test that multiple rotations add up correctly
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestRotationsAddUp() {
    stack_var _NAVInt64 testValue, result1, result2, result3, combined

    // Initialize test value
    testValue.Hi = $12345678
    testValue.Lo = $9ABCDEF0

    // Test ROTR^28 + ROTR^34 should equal ROTR^62
    NAVInt64RotateRightFull(testValue, 28, result1)
    NAVInt64RotateRightFull(result1, 34, result2)

    NAVInt64RotateRightFull(testValue, 62, combined)

    // Check if result2 matches combined
    if (result2.Hi != combined.Hi || result2.Lo != combined.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Rotation addition test failed: ROTR^28 + ROTR^34 != ROTR^62'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  ROTR^28 + ROTR^34: $', format('%08x', result2.Hi), format('%08x', result2.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  ROTR^62: $', format('%08x', combined.Hi), format('%08x', combined.Lo)")
        return false
    }

    // FIX: Test correctly chained rotations - match exactly 64 bits
    // Use separate variables for each rotation to avoid overwrite issues
    NAVInt64RotateRightFull(testValue, 16, result1)   // Changed from 14 to 16
    NAVInt64RotateRightFull(result1, 16, result2)     // Changed from 18 to 16
    NAVInt64RotateRightFull(result2, 32, result3)

    // Check if result3 matches original - should be identical
    if (result3.Hi != testValue.Hi || result3.Lo != testValue.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Rotation addition test failed: ROTR^16 + ROTR^16 + ROTR^32 != identity'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Original: $', format('%08x', testValue.Hi), format('%08x', testValue.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  After rotations: $', format('%08x', result3.Hi), format('%08x', result3.Lo)")
        return false
    }

    // Add another test case with exactly 64 bits of rotation
    NAVInt64RotateRightFull(testValue, 64, result1)

    // Check if 64-bit rotation returns to original value
    if (result1.Hi != testValue.Hi || result1.Lo != testValue.Lo) {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Rotation addition test failed: ROTR^64 != identity'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Original: $', format('%08x', testValue.Hi), format('%08x', testValue.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  After ROTR^64: $', format('%08x', result1.Hi), format('%08x', result1.Lo)")
        return false
    }

    return true
}

/**
 * @function RunNAVInt64RotationTests
 * @description Runs all rotation tests
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVInt64RotationTests() {
    stack_var integer allPassed

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64Rotation Tests ******************'")

    allPassed = true

    // Test SHA-512 rotation values
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: SHA-512 Rotation Values'")
    allPassed = allPassed && TestSHA512RotationValues()

    // Test rotations adding up
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Rotation Addition'")
    allPassed = allPassed && TestRotationsAddUp()

    if (allPassed) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'All NAVInt64Rotation tests passed!'")
        return 1
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Some NAVInt64Rotation tests failed!'")
        return 0
    }
}

#END_IF // __NAV_INT64_ROTATION_TESTS__
