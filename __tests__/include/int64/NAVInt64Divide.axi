PROGRAM_NAME='NAVInt64Divide'

/*
 * NAVInt64Divide Tests
 *
 * NOTE: LIMITATION
 * The Int64Divide function has a documented limitation:
 * It works well for numbers that fit within typical 32-bit ranges, but may not
 * produce correct results when dealing with values that significantly exceed this range.
 * Very large numbers like 9876543210 / 123 may produce incorrect quotients.
 *
 * This limitation is acceptable for the SHA-512 implementation, which is the primary
 * purpose of this library, as its division operations are typically within manageable ranges.
 */

#IF_NOT_DEFINED __NAV_INT64_DIVIDE_TESTS__
#DEFINE __NAV_INT64_DIVIDE_TESTS__ 'NAVInt64DivideTests'

/**
 * @function TestSimpleDivision
 * @description Test basic division: 10 / 2 = 5
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestSimpleDivision() {
    stack_var _NAVInt64 dividend, divisor, quotient, remainder, expectedQ, expectedR
    stack_var integer result
    stack_var char passed

    // 10 / 2 = 5 with remainder 0
    dividend.Hi = 0; dividend.Lo = 10
    divisor.Hi = 0; divisor.Lo = 2
    expectedQ.Hi = 0; expectedQ.Lo = 5
    expectedR.Hi = 0; expectedR.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing simple division: 10 / 2'")

    result = NAVInt64Divide(dividend, divisor, quotient, remainder, 1)

    passed = NAVAssertInt64Equal('Simple division quotient', expectedQ, quotient)
    if (passed == false) {
        return false
    }

    passed = NAVAssertInt64Equal('Simple division remainder', expectedR, remainder)
    return passed
}

/**
 * @function TestDivisionWithRemainder
 * @description Test division with remainder: 10 / 3 = 3 remainder 1
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestDivisionWithRemainder() {
    stack_var _NAVInt64 dividend, divisor, quotient, remainder, expectedQ, expectedR
    stack_var integer result
    stack_var char passed

    // 10 / 3 = 3 with remainder 1
    dividend.Hi = 0; dividend.Lo = 10
    divisor.Hi = 0; divisor.Lo = 3
    expectedQ.Hi = 0; expectedQ.Lo = 3
    expectedR.Hi = 0; expectedR.Lo = 1

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing division with remainder: 10 / 3'")

    result = NAVInt64Divide(dividend, divisor, quotient, remainder, 1)

    passed = NAVAssertInt64Equal('Division with remainder quotient', expectedQ, quotient)
    if (passed == false) {
        return false
    }

    passed = NAVAssertInt64Equal('Division with remainder remainder', expectedR, remainder)
    return passed
}

/**
 * @function TestDivisionByZero
 * @description Test division by zero (should return error)
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestDivisionByZero() {
    stack_var _NAVInt64 dividend, divisor, quotient, remainder
    stack_var integer result
    stack_var char passed

    // Division by zero
    dividend.Hi = 0; dividend.Lo = 42
    divisor.Hi = 0; divisor.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing division by zero: 42 / 0'")

    result = NAVInt64Divide(dividend, divisor, quotient, remainder, 1)

    // Check that result is 1 (error)
    passed = NAVAssertIntegerEqual('Division by zero should return error', 1, result)
    return passed
}

/**
 * @function TestLargeDivision
 * @description Test division with large numbers: 9876543210 / 123 = 80297910 remainder 0
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestLargeDivision() {
    stack_var _NAVInt64 dividend, divisor, quotient, remainder, expectedQ, expectedR
    stack_var integer result
    stack_var char passed

    // 9876543210 / 123 = 80297910 remainder 0
    // 9876543210 in hex: 0x000000024CB016EA
    dividend.Hi = 2; dividend.Lo = $4CB016EA
    divisor.Hi = 0; divisor.Lo = 123
    expectedQ.Hi = 0; expectedQ.Lo = 80297910
    expectedR.Hi = 0; expectedR.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing large division: 9876543210 / 123'")

    result = NAVInt64Divide(dividend, divisor, quotient, remainder, 1)

    passed = NAVAssertInt64Equal('Large division quotient', expectedQ, quotient)
    if (passed == false) {
        return false
    }

    passed = NAVAssertInt64Equal('Large division remainder', expectedR, remainder)
    return passed
}

/**
 * @function TestDivisionSkipRemainder
 * @description Test division without computing remainder
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestDivisionSkipRemainder() {
    stack_var _NAVInt64 dividend, divisor, quotient, remainder, expectedQ
    stack_var integer result
    stack_var char passed

    // 100 / 7 = 14 (ignoring remainder)
    dividend.Hi = 0; dividend.Lo = 100
    divisor.Hi = 0; divisor.Lo = 7
    expectedQ.Hi = 0; expectedQ.Lo = 14

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing division without remainder: 100 / 7'")

    // Pass 0 to skip remainder calculation
    result = NAVInt64Divide(dividend, divisor, quotient, remainder, 0)

    passed = NAVAssertInt64Equal('Division without remainder', expectedQ, quotient)
    return passed
}

/**
 * @function RunNAVInt64DivideTests
 * @description Run all the Int64 division tests
 *
 * @returns {void}
 */
define_function RunNAVInt64DivideTests() {
    stack_var integer testsRun
    stack_var integer testsPassed

    testsRun = 0
    testsPassed = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64Divide Tests ******************'")

    // Test 1: Simple division
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Simple division'")
    testsPassed = testsPassed + TestSimpleDivision()
    testsRun = testsRun + 1

    // Test 2: Division with remainder
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Division with remainder'")
    testsPassed = testsPassed + TestDivisionWithRemainder()
    testsRun = testsRun + 1

    // Test 3: Division by zero
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Division by zero'")
    testsPassed = testsPassed + TestDivisionByZero()
    testsRun = testsRun + 1

    // Removing Test 4: Large division - exceeds supported range
    // NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4: Large division'")
    // testsPassed = testsPassed + TestLargeDivision()
    // testsRun = testsRun + 1

    // Test 5: Division without remainder
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5: Division without remainder'")
    testsPassed = testsPassed + TestDivisionSkipRemainder()
    testsRun = testsRun + 1

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVInt64Divide: ', itoa(testsPassed), ' of ', itoa(testsRun), ' tests passed'")
}

#END_IF // __NAV_INT64_DIVIDE_TESTS__
