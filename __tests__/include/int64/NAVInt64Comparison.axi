PROGRAM_NAME='NAVInt64Comparison'

/*
 * Test cases for NAVInt64 comparison operations
 */

#IF_NOT_DEFINED __NAV_INT64_COMPARISON_TESTS__
#DEFINE __NAV_INT64_COMPARISON_TESTS__ 'NAVInt64ComparisonTests'

/**
 * @function TestEqualityComparison
 * @description Test comparison of equal values
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestEqualityComparison() {
    stack_var _NAVInt64 a, b
    stack_var sinteger result
    stack_var char passed

    // Equal values: 0x0000000000000064 == 0x0000000000000064
    a.Hi = 0; a.Lo = 100
    b.Hi = 0; b.Lo = 100

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing equality comparison: 100 == 100'")

    result = NAVInt64Compare(a, b)

    passed = NAVAssertSignedIntegerEqual('Equal values should return 0', 0, result)
    return passed
}

/**
 * @function TestLessThanComparison
 * @description Test less than comparison
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestLessThanComparison() {
    stack_var _NAVInt64 a, b
    stack_var sinteger result
    stack_var char passed

    // Less than: 0x0000000000000064 < 0x00000000000000C8
    a.Hi = 0; a.Lo = 100
    b.Hi = 0; b.Lo = 200

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing less than comparison: 100 < 200'")

    result = NAVInt64Compare(a, b)

    passed = NAVAssertSignedIntegerEqual('Less than should return -1', -1, result)
    return passed
}

/**
 * @function TestGreaterThanComparison
 * @description Test greater than comparison
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestGreaterThanComparison() {
    stack_var _NAVInt64 a, b
    stack_var sinteger result
    stack_var char passed

    // Greater than: 0x00000000000000C8 > 0x0000000000000064
    a.Hi = 0; a.Lo = 200
    b.Hi = 0; b.Lo = 100

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing greater than comparison: 200 > 100'")

    result = NAVInt64Compare(a, b)

    passed = NAVAssertSignedIntegerEqual('Greater than should return 1', 1, result)
    return passed
}

/**
 * @function TestHighPartComparison
 * @description Test comparison where high parts differ
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestHighPartComparison() {
    stack_var _NAVInt64 a, b
    stack_var sinteger result
    stack_var char passed

    // High parts differ: 0x0000000100000000 > 0x0000000000000001
    a.Hi = 1; a.Lo = 0
    b.Hi = 0; b.Lo = 1

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing high part comparison: 2^32 > 1'")

    result = NAVInt64Compare(a, b)

    passed = NAVAssertSignedIntegerEqual('Higher high part should return 1', 1, result)
    return passed
}

/**
 * @function TestZeroDetection
 * @description Test zero detection function
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestZeroDetection() {
    stack_var _NAVInt64 zero, nonZero
    stack_var integer result1, result2
    stack_var char passed

    zero.Hi = 0; zero.Lo = 0
    nonZero.Hi = 0; nonZero.Lo = 1

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing zero detection'")

    result1 = NAVInt64IsZero(zero)
    result2 = NAVInt64IsZero(nonZero)

    passed = NAVAssertIntegerEqual('Zero detection on zero', 1, result1)
    if (!passed) return false

    passed = NAVAssertIntegerEqual('Zero detection on non-zero', 0, result2)
    return passed
}

/**
 * @function RunNAVInt64ComparisonTests
 * @description Run all the Int64 comparison tests
 *
 * @returns {void}
 */
define_function RunNAVInt64ComparisonTests() {
    stack_var integer passCount, totalTests

    passCount = 0
    totalTests = 5

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64Comparison Tests ******************'")

    // Test 1
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Equality comparison'")
    if (TestEqualityComparison()) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 failed'")
    }

    // Test 2
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Less than comparison'")
    if (TestLessThanComparison()) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 failed'")
    }

    // Test 3
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Greater than comparison'")
    if (TestGreaterThanComparison()) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 failed'")
    }

    // Test 4
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4: High part comparison'")
    if (TestHighPartComparison()) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 failed'")
    }

    // Test 5
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5: Zero detection'")
    if (TestZeroDetection()) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 failed'")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVInt64Comparison: ', itoa(passCount), ' of ', itoa(totalTests), ' tests passed'")
}

#END_IF // __NAV_INT64_COMPARISON_TESTS__
