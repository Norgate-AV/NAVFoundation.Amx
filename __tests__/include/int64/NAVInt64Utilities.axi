PROGRAM_NAME='NAVInt64Utilities'

/*
 * Tests for NAVInt64 utility functions:
 * - NAVInt64Min
 * - NAVInt64Max
 * - NAVInt64Abs
 * - NAVInt64IsNegative
 */

#IF_NOT_DEFINED __NAV_INT64_UTILITIES_TESTS__
#DEFINE __NAV_INT64_UTILITIES_TESTS__ 'NAVInt64UtilitiesTests'

/**
 * @function TestNAVInt64Min
 * @description Test the NAVInt64Min function in different scenarios
 *
 * @returns {char} true if all tests pass, false otherwise
 */
define_function char TestNAVInt64Min() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    passed = true
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing NAVInt64Min function'")

    // Test case 1: a < b, both positive
    a.Hi = 0; a.Lo = 100
    b.Hi = 0; b.Lo = 200
    expected.Hi = 0; expected.Lo = 100

    NAVInt64Min(a, b, result)

    if (NAVAssertInt64Equal('Min of positive numbers', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Min(100, 200) should be 100'")
    }

    // Test case 2: a > b, both positive
    a.Hi = 1; a.Lo = 0
    b.Hi = 0; b.Lo = 1
    expected.Hi = 0; expected.Lo = 1

    NAVInt64Min(a, b, result)

    if (NAVAssertInt64Equal('Min with different magnitudes', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Min(2^32, 1) should be 1'")
    }

    // Test case 3: a < b, both negative
    a.Hi = $FFFFFFFF; a.Lo = $FFFFFF9C  // -100
    b.Hi = $FFFFFFFF; b.Lo = $FFFFFFCE  // -50
    expected.Hi = $FFFFFFFF; expected.Lo = $FFFFFF9C  // -100

    NAVInt64Min(a, b, result)

    if (NAVAssertInt64Equal('Min of negative numbers', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Min(-100, -50) should be -100'")
    }

    // Test case 4: a (negative) < b (positive)
    a.Hi = $FFFFFFFF; a.Lo = $FFFFFFCE  // -50
    b.Hi = 0; b.Lo = 100
    expected.Hi = $FFFFFFFF; expected.Lo = $FFFFFFCE  // -50

    NAVInt64Min(a, b, result)

    if (NAVAssertInt64Equal('Min of mixed signs', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Min(-50, 100) should be -50'")
    }

    // Test case 5: Equal values
    a.Hi = 0; a.Lo = 42
    b.Hi = 0; b.Lo = 42
    expected.Hi = 0; expected.Lo = 42

    NAVInt64Min(a, b, result)

    if (NAVAssertInt64Equal('Min of equal values', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Min(42, 42) should be 42'")
    }

    return passed
}

/**
 * @function TestNAVInt64Max
 * @description Test the NAVInt64Max function in different scenarios
 *
 * @returns {char} true if all tests pass, false otherwise
 */
define_function char TestNAVInt64Max() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    passed = true
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing NAVInt64Max function'")

    // Test case 1: a < b, both positive
    a.Hi = 0; a.Lo = 100
    b.Hi = 0; b.Lo = 200
    expected.Hi = 0; expected.Lo = 200

    NAVInt64Max(a, b, result)

    if (NAVAssertInt64Equal('Max of positive numbers', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Max(100, 200) should be 200'")
    }

    // Test case 2: a > b, both positive
    a.Hi = 1; a.Lo = 0
    b.Hi = 0; b.Lo = 1
    expected.Hi = 1; expected.Lo = 0

    NAVInt64Max(a, b, result)

    if (NAVAssertInt64Equal('Max with different magnitudes', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Max(2^32, 1) should be 2^32'")
    }

    // Test case 3: a < b, both negative
    a.Hi = $FFFFFFFF; a.Lo = $FFFFFF9C  // -100
    b.Hi = $FFFFFFFF; b.Lo = $FFFFFFCE  // -50
    expected.Hi = $FFFFFFFF; expected.Lo = $FFFFFFCE  // -50

    NAVInt64Max(a, b, result)

    if (NAVAssertInt64Equal('Max of negative numbers', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Max(-100, -50) should be -50'")
    }

    // Test case 4: a (negative) < b (positive)
    a.Hi = $FFFFFFFF; a.Lo = $FFFFFFCE  // -50
    b.Hi = 0; b.Lo = 100
    expected.Hi = 0; expected.Lo = 100

    NAVInt64Max(a, b, result)

    if (NAVAssertInt64Equal('Max of mixed signs', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Max(-50, 100) should be 100'")
    }

    // Test case 5: Equal values
    a.Hi = 0; a.Lo = 42
    b.Hi = 0; b.Lo = 42
    expected.Hi = 0; expected.Lo = 42

    NAVInt64Max(a, b, result)

    if (NAVAssertInt64Equal('Max of equal values', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Max(42, 42) should be 42'")
    }

    return passed
}

/**
 * @function TestNAVInt64Abs
 * @description Test the NAVInt64Abs function
 *
 * @returns {char} true if all tests pass, false otherwise
 */
define_function char TestNAVInt64Abs() {
    stack_var _NAVInt64 a, result, expected
    stack_var char passed

    passed = true
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing NAVInt64Abs function'")

    // Test case 1: Positive number
    a.Hi = 0; a.Lo = 123456
    expected.Hi = 0; expected.Lo = 123456

    NAVInt64Abs(a, result)

    if (NAVAssertInt64Equal('Abs of positive number', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Abs(123456) should be 123456'")
    }

    // Test case 2: Negative number
    a.Hi = $FFFFFFFF; a.Lo = $FFFFFF9C  // -100
    expected.Hi = 0; expected.Lo = 100

    NAVInt64Abs(a, result)

    if (NAVAssertInt64Equal('Abs of negative number', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Abs(-100) should be 100'")
    }

    // Test case 3: Zero
    a.Hi = 0; a.Lo = 0
    expected.Hi = 0; expected.Lo = 0

    NAVInt64Abs(a, result)

    if (NAVAssertInt64Equal('Abs of zero', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Abs(0) should be 0'")
    }

    // Test case 4: Large negative number
    a.Hi = $FFFFFFFF; a.Lo = 0  // -2^32
    expected.Hi = 0; expected.Lo = 0
    expected.Hi = 1; expected.Lo = 0  // 2^32

    NAVInt64Abs(a, result)

    if (NAVAssertInt64Equal('Abs of large negative', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: Abs(-2^32) should be 2^32'")
    }

    return passed
}

/**
 * @function TestNAVInt64IsNegative
 * @description Test the NAVInt64IsNegative function
 *
 * @returns {char} true if all tests pass, false otherwise
 */
define_function char TestNAVInt64IsNegative() {
    stack_var _NAVInt64 value
    stack_var integer result, expected
    stack_var char passed

    passed = true
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing NAVInt64IsNegative function'")

    // Test case 1: Positive number
    value.Hi = 0; value.Lo = 123456
    expected = 0  // Not negative

    result = NAVInt64IsNegative(value)

    if (NAVAssertIntegerEqual('IsNegative with positive', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: IsNegative(123456) should be 0'")
    }

    // Test case 2: Negative number
    value.Hi = $FFFFFFFF; value.Lo = $FFFFFF9C  // -100
    expected = 1  // Is negative

    result = NAVInt64IsNegative(value)

    if (NAVAssertIntegerEqual('IsNegative with negative', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: IsNegative(-100) should be 1'")
    }

    // Test case 3: Zero
    value.Hi = 0; value.Lo = 0
    expected = 0  // Not negative

    result = NAVInt64IsNegative(value)

    if (NAVAssertIntegerEqual('IsNegative with zero', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: IsNegative(0) should be 0'")
    }

    // Test case 4: Maximum positive (high bit not set)
    value.Hi = $7FFFFFFF; value.Lo = $FFFFFFFF
    expected = 0  // Not negative

    result = NAVInt64IsNegative(value)

    if (NAVAssertIntegerEqual('IsNegative with max positive', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: IsNegative(MAX_INT64) should be 0'")
    }

    // Test case 5: Minimum negative (high bit set)
    value.Hi = $80000000; value.Lo = 0
    expected = 1  // Is negative

    result = NAVInt64IsNegative(value)

    if (NAVAssertIntegerEqual('IsNegative with min negative', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: IsNegative(MIN_INT64) should be 1'")
    }

    return passed
}

/**
 * @function RunNAVInt64UtilitiesTests
 * @description Run all the utility tests for Int64
 */
define_function RunNAVInt64UtilitiesTests() {
    stack_var integer passed, total

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64Utilities Tests ******************'")

    passed = 0
    total = 0

    // Test 1: Min function
    total++
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Min function'")
    if (TestNAVInt64Min() == true) {
        passed++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 passed'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 failed'")
    }

    // Test 2: Max function
    total++
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Max function'")
    if (TestNAVInt64Max() == true) {
        passed++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 passed'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 failed'")
    }

    // Test 3: Abs function
    total++
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Abs function'")
    if (TestNAVInt64Abs() == true) {
        passed++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 passed'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 failed'")
    }

    // Test 4: IsNegative function
    total++
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4: IsNegative function'")
    if (TestNAVInt64IsNegative() == true) {
        passed++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 passed'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 failed'")
    }

    // Summary
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVInt64Utilities: ', itoa(passed), ' of ', itoa(total), ' tests passed'")
}

#END_IF // __NAV_INT64_UTILITIES_TESTS__
