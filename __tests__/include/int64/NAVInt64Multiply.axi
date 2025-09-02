PROGRAM_NAME='NAVInt64Multiply'

/*
 * NAVInt64Multiply Tests
 *
 * NOTE: LIMITATION
 * The Int64Multiply function has a documented limitation:
 * It only guarantees correct results for numbers that fit within a true 64-bit result.
 * Multiplications that would require more than 64 bits to represent (like 123456789 * 987654321)
 * may produce truncated results.
 *
 * This limitation is acceptable for the SHA-512 implementation, which is the primary
 * purpose of this library.
 */

#IF_NOT_DEFINED __NAV_INT64_MULTIPLY_TESTS__
#DEFINE __NAV_INT64_MULTIPLY_TESTS__ 'NAVInt64MultiplyTests'

/**
 * @function TestSimpleMultiplication
 * @description Test basic multiplication: 2 * 3 = 6
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestSimpleMultiplication() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    // 2 * 3 = 6
    a.Hi = 0; a.Lo = 2
    b.Hi = 0; b.Lo = 3
    expected.Hi = 0; expected.Lo = 6

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing simple multiplication: 2 * 3'")

    NAVInt64Multiply(a, b, result)

    passed = NAVAssertInt64Equal('Simple multiplication (2 * 3)', expected, result)
    return passed
}

/**
 * @function TestMultiplyByZero
 * @description Test multiplication by zero: 42 * 0 = 0
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestMultiplyByZero() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    // 42 * 0 = 0
    a.Hi = 0; a.Lo = 42
    b.Hi = 0; b.Lo = 0
    expected.Hi = 0; expected.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing multiplication with zero: 42 * 0'")

    NAVInt64Multiply(a, b, result)

    passed = NAVAssertInt64Equal('Multiply by zero', expected, result)
    return passed
}

/**
 * @function TestCrossBoundaryMultiplication
 * @description Test multiplication across 32-bit boundary: 0x10000 * 0x10000 = 0x100000000
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestCrossBoundaryMultiplication() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    // 0x10000 * 0x10000 = 0x100000000
    a.Hi = 0; a.Lo = $10000
    b.Hi = 0; b.Lo = $10000
    expected.Hi = 1; expected.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing cross-boundary multiplication: 0x10000 * 0x10000'")

    NAVInt64Multiply(a, b, result)

    passed = NAVAssertInt64Equal('Cross-boundary multiplication', expected, result)
    return passed
}

/**
 * @function TestMultiplyWithOverflow
 * @description Test multiplication that overflows 32 bits
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestMultiplyWithOverflow() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    // 0x100000000 * 0x100000000 = 0x0 (with overflow)
    a.Hi = 1; a.Lo = 0
    b.Hi = 1; b.Lo = 0
    expected.Hi = 0; expected.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing overflow multiplication: 0x100000000 * 0x100000000'")

    NAVInt64Multiply(a, b, result)

    passed = NAVAssertInt64Equal('Multiply with overflow', expected, result)
    return passed
}

/**
 * @function TestSpecificMultiplicationCases
 * @description Test specific multiplication cases that have been problematic
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestSpecificMultiplicationCases() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    passed = true  // Start with assumption of pass

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing specific multiplication cases'")

    // Test Case 1: 8! * 9 = 9! (factorial calculation issue)
    a.Hi = 0; a.Lo = 40320  // 8! = 40,320
    b.Hi = 0; b.Lo = 9
    expected.Hi = 0; expected.Lo = 362880  // 9! = 362,880

    NAVInt64Multiply(a, b, result)

    if (NAVAssertInt64Equal('8! * 9 = 9!', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: 40320 * 9 should be 362880, got ', itoa(result.Lo),
                   ' ($', format('%08x', result.Hi), format('%08x', result.Lo), ')'")
    }

    // Test Case 2: 9! * 10 = 10! (next factorial step)
    a.Hi = 0; a.Lo = 362880  // 9! = 362,880
    b.Hi = 0; b.Lo = 10
    expected.Hi = 0; expected.Lo = 3628800  // 10! = 3,628,800

    NAVInt64Multiply(a, b, result)

    if (NAVAssertInt64Equal('9! * 10 = 10!', expected, result) == false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed: 362880 * 10 should be 3628800, got ', itoa(result.Lo),
                   ' ($', format('%08x', result.Hi), format('%08x', result.Lo), ')'")
    }

    return passed
}

/**
 * @function TestMultiplyByOne
 * @description Test multiplication by one, which should not change the value
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestMultiplyByOne() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    // 1 * 123456789 = 123456789
    a.Hi = 0; a.Lo = 1
    b.Hi = 0; b.Lo = 123456789
    expected.Hi = 0; expected.Lo = 123456789

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing multiplication by one: 1 * 123456789'")

    NAVInt64Multiply(a, b, result)

    passed = NAVAssertInt64Equal('Multiply by one', expected, result)
    return passed
}

/**
 * @function Int64MultiplyTestPowerOf2
 * @description Test multiplication by powers of 2
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char Int64MultiplyTestPowerOf2() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    // 2 * 2 = 4
    a.Hi = 0; a.Lo = 2
    b.Hi = 0; b.Lo = 2
    expected.Hi = 0; expected.Lo = 4

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing multiplication by power of 2: 2 * 2'")

    NAVInt64Multiply(a, b, result)

    passed = NAVAssertInt64Equal('Multiply by power of 2', expected, result)
    return passed
}

/**
 * @function RunNAVInt64MultiplyTests
 * @description Run all the Int64 multiplication tests
 *
 * @returns {void}
 */
define_function RunNAVInt64MultiplyTests() {
    stack_var integer passCount, totalTests

    passCount = 0
    totalTests = 7

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64Multiply Tests ******************'")

    // Test 1: Simple multiplication
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Simple multiplication'")
    if (TestSimpleMultiplication() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 failed'")
    }

    // Test 2: Multiplication with zero
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Multiplication with zero'")
    if (TestMultiplyByZero() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 failed'")
    }

    // Test 3: Cross-boundary multiplication
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Cross-boundary multiplication'")
    if (TestCrossBoundaryMultiplication() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 failed'")
    }

    // Test 4: Overflow multiplication
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4: Overflow multiplication'")
    if (TestMultiplyWithOverflow() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 failed'")
    }

    // Test 5: Specific multiplication cases
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5: Specific multiplication cases'")
    if (TestSpecificMultiplicationCases() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 failed'")
    }

    // Test 6: Multiplication by one
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 6: Multiplication by one'")
    if (TestMultiplyByOne() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 6 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 6 failed'")
    }

    // Test 7: Multiplication by power of 2
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 7: Multiplication by power of 2'")
    if (Int64MultiplyTestPowerOf2() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 7 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 7 failed'")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVInt64Multiply: ', itoa(passCount), ' of ', itoa(totalTests), ' tests passed'")
}

#END_IF // __NAV_INT64_MULTIPLY_TESTS__
