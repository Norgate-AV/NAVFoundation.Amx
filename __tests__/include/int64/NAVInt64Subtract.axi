PROGRAM_NAME='NAVInt64Subtract'

/*
 * Test cases for NAVInt64Subtract functions
 */

#IF_NOT_DEFINED __NAV_INT64_SUBTRACT_TESTS__
#DEFINE __NAV_INT64_SUBTRACT_TESTS__ 'NAVInt64SubtractTests'

/**
 * @function TestSimpleSubtraction
 * @description Test basic subtraction: 100 - 42 = 58
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestSimpleSubtraction() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var integer borrow
    stack_var char passed

    // 100 - 42 = 58
    a.Hi = 0; a.Lo = 100
    b.Hi = 0; b.Lo = 42
    expected.Hi = 0; expected.Lo = 58

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing simple subtraction: 100 - 42'")

    borrow = NAVInt64Subtract(a, b, result)

    passed = NAVAssertInt64Equal('Simple subtraction', expected, result)
    if (passed == false) {
        return false
    }

    passed = NAVAssertIntegerEqual('No borrow expected', 0, borrow)
    return passed
}

/**
 * @function TestSubtractionWithBorrow
 * @description Test subtraction that results in a negative number: 1 - 2 = -1
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestSubtractionWithBorrow() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var integer borrow
    stack_var char passed

    // 1 - 2 = -1 (in two's complement, all bits are 1)
    a.Hi = 0; a.Lo = 1
    b.Hi = 0; b.Lo = 2
    expected.Hi = $FFFFFFFF; expected.Lo = $FFFFFFFF

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing subtraction with borrow: 1 - 2'")

    borrow = NAVInt64Subtract(a, b, result)

    passed = NAVAssertInt64Equal('Subtraction with borrow', expected, result)
    if (passed == false) {
        return false
    }

    passed = NAVAssertIntegerEqual('Borrow expected', 1, borrow)
    return passed
}

/**
 * @function TestCrossBoundarySubtraction
 * @description Test subtraction across 32-bit boundary: 0x100000000 - 1 = 0xFFFFFFFF
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestCrossBoundarySubtraction() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var integer borrow
    stack_var char passed

    // 0x100000000 - 1 = 0xFFFFFFFF
    a.Hi = 1; a.Lo = 0
    b.Hi = 0; b.Lo = 1
    expected.Hi = 0; expected.Lo = $FFFFFFFF

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing cross-boundary subtraction: 0x100000000 - 1'")

    borrow = NAVInt64Subtract(a, b, result)

    passed = NAVAssertInt64Equal('Cross-boundary subtraction', expected, result)
    if (passed == false) {
        return false
    }

    passed = NAVAssertIntegerEqual('No borrow expected', 0, borrow)
    return passed
}

/**
 * @function TestSubtractingZero
 * @description Test subtraction with zero, which should not change the value
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestSubtractingZero() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var integer borrow
    stack_var char passed

    // 0x123456789ABCDEF0 - 0 = 0x123456789ABCDEF0
    a.Hi = $12345678; a.Lo = $9ABCDEF0
    b.Hi = 0; b.Lo = 0
    expected.Hi = $12345678; expected.Lo = $9ABCDEF0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing subtracting zero: num - 0'")

    borrow = NAVInt64Subtract(a, b, result)

    passed = NAVAssertInt64Equal('Subtracting zero', expected, result)
    if (passed == false) {
        return false
    }

    passed = NAVAssertIntegerEqual('No borrow expected', 0, borrow)
    return passed
}

/**
 * @function TestSubtractingSameNumber
 * @description Test subtraction of same number, which should result in zero
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestSubtractingSameNumber() {
    stack_var _NAVInt64 a, result, expected
    stack_var integer borrow
    stack_var char passed

    // 0x123456789ABCDEF0 - 0x123456789ABCDEF0 = 0
    a.Hi = $12345678; a.Lo = $9ABCDEF0
    expected.Hi = 0; expected.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing subtracting same number: num - num'")

    borrow = NAVInt64Subtract(a, a, result)

    passed = NAVAssertInt64Equal('Subtracting same number', expected, result)
    if (passed == false) {
        return false
    }

    passed = NAVAssertIntegerEqual('No borrow expected', 0, borrow)
    return passed
}

/**
 * @function RunNAVInt64SubtractTests
 * @description Run all the Int64 subtraction tests
 *
 * @returns {void}
 */
define_function RunNAVInt64SubtractTests() {
    stack_var integer passCount, totalTests

    passCount = 0
    totalTests = 5

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64Subtract Tests ******************'")

    // Test 1
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Simple subtraction'")
    if (TestSimpleSubtraction() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 failed'")
    }

    // Test 2
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Subtraction with borrow'")
    if (TestSubtractionWithBorrow() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 failed'")
    }

    // Test 3
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Cross-boundary subtraction'")
    if (TestCrossBoundarySubtraction() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 failed'")
    }

    // Test 4
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4: Subtracting zero'")
    if (TestSubtractingZero() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 failed'")
    }

    // Test 5
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5: Subtracting same number'")
    if (TestSubtractingSameNumber() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 failed'")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVInt64Subtract: ', itoa(passCount), ' of ', itoa(totalTests), ' tests passed'")
}

#END_IF // __NAV_INT64_SUBTRACT_TESTS__
