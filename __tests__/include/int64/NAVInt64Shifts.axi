PROGRAM_NAME='NAVInt64Shifts'

/*
 * Test cases for NAVInt64 shift and rotate operations
 */

#IF_NOT_DEFINED __NAV_INT64_SHIFTS_TESTS__
#DEFINE __NAV_INT64_SHIFTS_TESTS__ 'NAVInt64ShiftsTests'

/**
 * @function TestShiftLeft
 * @description Test the NAVInt64ShiftLeft function
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestShiftLeft() {
    stack_var _NAVInt64 value, result, expected
    stack_var char passed

    // 0x0000000100000000 << 4 = 0x0000001000000000
    value.Hi = 1; value.Lo = 0
    expected.Hi = 16; expected.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing shift left: $0000000100000000 << 4'")

    NAVInt64ShiftLeft(value, 4, result)

    passed = NAVAssertInt64Equal('ShiftLeft operation', expected, result)
    return passed
}

/**
 * @function TestShiftRight
 * @description Test the NAVInt64ShiftRight function
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestShiftRight() {
    stack_var _NAVInt64 value, result, expected
    stack_var char passed

    // 0x0000000100000000 >> 4 = 0x0000000010000000
    value.Hi = 1; value.Lo = 0
    expected.Hi = 0; expected.Lo = $10000000

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing shift right: $0000000100000000 >> 4'")

    NAVInt64ShiftRight(value, 4, result)

    passed = NAVAssertInt64Equal('ShiftRight operation', expected, result)
    return passed
}

/**
 * @function TestShiftEdgeCases
 * @description Test edge cases for shift operations
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestShiftEdgeCases() {
    stack_var _NAVInt64 value, result1, result2, result3, expected1, expected2, expected3
    stack_var char passed

    // Setup test value
    value.Hi = $12345678; value.Lo = $9ABCDEF0

    // Shift by 0 bits (should be unchanged)
    expected1.Hi = $12345678; expected1.Lo = $9ABCDEF0
    NAVInt64ShiftLeft(value, 0, result1)
    passed = NAVAssertInt64Equal('Shift by 0 bits', expected1, result1)
    if (passed == false) return false

    // Shift by 32 bits
    expected2.Hi = $9ABCDEF0; expected2.Lo = 0
    NAVInt64ShiftLeft(value, 32, result2)
    passed = NAVAssertInt64Equal('Shift by 32 bits', expected2, result2)
    if (passed == false) return false

    // Shift by 64 bits (all bits shifted out)
    expected3.Hi = 0; expected3.Lo = 0
    NAVInt64ShiftLeft(value, 64, result3)
    passed = NAVAssertInt64Equal('Shift by 64 bits', expected3, result3)

    return passed
}

/**
 * @function TestRotateLeft
 * @description Test the NAVInt64RotateLeft function
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestRotateLeft() {
    stack_var _NAVInt64 value, result, expected
    stack_var char passed

    // 0x8000000000000001 <<< 1 = 0x0000000000000003
    value.Hi = $80000000; value.Lo = 1
    expected.Hi = 1; expected.Lo = 2

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing rotate left: $8000000000000001 <<< 1'")

    NAVInt64RotateLeft(value, 1, result)

    passed = NAVAssertInt64Equal('RotateLeft operation', expected, result)
    return passed
}

/**
 * @function TestRotateRight
 * @description Test the NAVInt64RotateRight function
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestRotateRight() {
    stack_var _NAVInt64 value, result, expected
    stack_var char passed

    // 0x8000000000000001 >>> 1 = 0x4000000080000000
    value.Hi = $80000000; value.Lo = 1
    expected.Hi = $40000000; expected.Lo = $80000000

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing rotate right: $8000000000000001 >>> 1'")

    NAVInt64RotateRight(value, 1, result)

    passed = NAVAssertInt64Equal('RotateRight operation', expected, result)
    return passed
}

/**
 * @function RunNAVInt64ShiftsTests
 * @description Run all the Int64 shift and rotate tests
 *
 * @returns {void}
 */
define_function RunNAVInt64ShiftsTests() {
    stack_var integer passCount, totalTests

    passCount = 0
    totalTests = 5

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64Shifts Tests ******************'")

    // Test 1
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Left Shift'")
    if (TestShiftLeft() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 failed'")
    }

    // Test 2
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Shift right'")
    if (TestShiftRight() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 failed'")
    }

    // Test 3
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Shift edge cases'")
    if (TestShiftEdgeCases() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 failed'")
    }

    // Test 4
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4: Rotate left'")
    if (TestRotateLeft() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 failed'")
    }

    // Test 5
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5: Rotate right'")
    if (TestRotateRight() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 failed'")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVInt64Shifts: ', itoa(passCount), ' of ', itoa(totalTests), ' tests passed'")
}

#END_IF // __NAV_INT64_SHIFTS_TESTS__
