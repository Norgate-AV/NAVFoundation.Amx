PROGRAM_NAME='NAVInt64BitOps'

/*
 * Test cases for NAVInt64 bitwise operations
 */

#IF_NOT_DEFINED __NAV_INT64_BITOPS_TESTS__
#DEFINE __NAV_INT64_BITOPS_TESTS__ 'NAVInt64BitOpsTests'

/**
 * @function TestBitAnd
 * @description Test the NAVInt64BitAnd function
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestBitAnd() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    // 0xF0F0F0F0AAAAAAAA & 0x0F0F0F0F55555555 = 0x0000000000000000
    a.Hi = $F0F0F0F0; a.Lo = $AAAAAAAA
    b.Hi = $0F0F0F0F; b.Lo = $55555555
    expected.Hi = 0; expected.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing bitwise AND: $F0F0F0F0AAAAAAAA & $0F0F0F0F55555555'")

    NAVInt64BitAnd(a, b, result)

    passed = NAVAssertInt64Equal('BitAnd operation', expected, result)
    return passed
}

/**
 * @function TestBitOr
 * @description Test the NAVInt64BitOr function
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestBitOr() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    // 0xF0F0F0F0AAAAAAAA | 0x0F0F0F0F55555555 = 0xFFFFFFFFFFFFFFFF
    a.Hi = $F0F0F0F0; a.Lo = $AAAAAAAA
    b.Hi = $0F0F0F0F; b.Lo = $55555555
    expected.Hi = $FFFFFFFF; expected.Lo = $FFFFFFFF

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing bitwise OR: $F0F0F0F0AAAAAAAA | $0F0F0F0F55555555'")

    NAVInt64BitOr(a, b, result)

    passed = NAVAssertInt64Equal('BitOr operation', expected, result)
    return passed
}

/**
 * @function TestBitXor
 * @description Test the NAVInt64BitXor function
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestBitXor() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var char passed

    // 0xF0F0F0F0AAAAAAAA ^ 0x0F0F0F0F55555555 = 0xFFFFFFFFFFFFFFFF
    a.Hi = $F0F0F0F0; a.Lo = $AAAAAAAA
    b.Hi = $0F0F0F0F; b.Lo = $55555555
    expected.Hi = $FFFFFFFF; expected.Lo = $FFFFFFFF

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing bitwise XOR: $F0F0F0F0AAAAAAAA ^ $0F0F0F0F55555555'")

    NAVInt64BitXor(a, b, result)

    passed = NAVAssertInt64Equal('BitXor operation', expected, result)
    return passed
}

/**
 * @function TestBitNot
 * @description Test the NAVInt64BitNot function
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestBitNot() {
    stack_var _NAVInt64 a, result, expected
    stack_var char passed

    // ~0xF0F0F0F0AAAAAAAA = 0x0F0F0F0F55555555
    a.Hi = $F0F0F0F0; a.Lo = $AAAAAAAA
    expected.Hi = $0F0F0F0F; expected.Lo = $55555555

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing bitwise NOT: ~$F0F0F0F0AAAAAAAA'")

    NAVInt64BitNot(a, result)

    passed = NAVAssertInt64Equal('BitNot operation', expected, result)
    return passed
}

/**
 * @function TestMixedBitwiseOps
 * @description Test combining multiple bitwise operations
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestMixedBitwiseOps() {
    stack_var _NAVInt64 a, b, not_a, temp, result, expected
    stack_var char passed

    // (a & b) ^ (~a) where a=0xAAAAAAAAAAAAAAAA, b=0x5555555555555555
    a.Hi = $AAAAAAAA; a.Lo = $AAAAAAAA
    b.Hi = $55555555; b.Lo = $55555555

    // Corrected expected value:
    // a & b = 0 (no bits overlap between alternating patterns)
    // ~a = 0x5555555555555555
    // 0 ^ 0x5555555555555555 = 0x5555555555555555
    expected.Hi = $55555555; expected.Lo = $55555555

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing mixed bitwise ops: (a & b) ^ (~a)'")

    // Step 1: Calculate ~a
    NAVInt64BitNot(a, not_a)

    // Step 2: Calculate a & b
    NAVInt64BitAnd(a, b, temp)

    // Step 3: Calculate (a & b) ^ (~a)
    NAVInt64BitXor(temp, not_a, result)

    passed = NAVAssertInt64Equal('Mixed bitwise operations', expected, result)
    return passed
}

/**
 * @function RunNAVInt64BitOpsTests
 * @description Run all the Int64 bitwise operation tests
 *
 * @returns {void}
 */
define_function RunNAVInt64BitOpsTests() {
    stack_var integer passCount, totalTests

    passCount = 0
    totalTests = 5

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64BitOps Tests ******************'")

    // Test 1
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Bitwise AND'")
    if (TestBitAnd() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 failed'")
    }

    // Test 2
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Bitwise OR'")
    if (TestBitOr() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 failed'")
    }

    // Test 3
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Bitwise XOR'")
    if (TestBitXor() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 failed'")
    }

    // Test 4
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4: Bitwise NOT'")
    if (TestBitNot() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 failed'")
    }

    // Test 5
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5: Mixed bitwise operations'")
    if (TestMixedBitwiseOps() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 failed'")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVInt64BitOps: ', itoa(passCount), ' of ', itoa(totalTests), ' tests passed'")
}

#END_IF // __NAV_INT64_BITOPS_TESTS__
