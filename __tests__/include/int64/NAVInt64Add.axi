PROGRAM_NAME='NAVInt64Add'

/*
 * Test cases for NAVInt64Add functions
 */

#IF_NOT_DEFINED __NAV_INT64_ADD_TESTS__
#DEFINE __NAV_INT64_ADD_TESTS__ 'NAVInt64AddTests'

/**
 * @function TestSimpleAddition
 * @description Test basic addition: 1 + 2 = 3
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestSimpleAddition() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var integer carry
    stack_var char passed

    // 1 + 2 = 3
    a.Hi = 0; a.Lo = 1
    b.Hi = 0; b.Lo = 2
    expected.Hi = 0; expected.Lo = 3

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing simple addition: 1 + 2'")

    carry = NAVInt64Add(a, b, result)

    passed = NAVAssertInt64Equal('Simple addition (1 + 2)', expected, result)
    if (passed == false) {
        return false
    }

    passed = NAVAssertIntegerEqual('No carry expected', 0, carry)
    return passed
}

/**
 * @function TestAdditionWithCarry
 * @description Test addition with carry from low to high 32 bits
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestAdditionWithCarry() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var integer carry
    stack_var char passed

    // 0xFFFFFFFF + 1 = 0x100000000
    a.Hi = 0; a.Lo = $FFFFFFFF
    b.Hi = 0; b.Lo = 1
    expected.Hi = 1; expected.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing addition with carry: $FFFFFFFF + 1'")

    carry = NAVInt64Add(a, b, result)

    passed = NAVAssertInt64Equal('Addition with carry', expected, result)
    if (passed == false) {
        return false
    }

    passed = NAVAssertIntegerEqual('No overall carry expected', 0, carry)
    return passed
}

/**
 * @function TestAdditionWithFinalCarry
 * @description Test addition that produces a final carry
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestAdditionWithFinalCarry() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var integer carry
    stack_var char passed

    // 0xFFFFFFFFFFFFFFFF + 1 = 0x0 (with carry)
    a.Hi = $FFFFFFFF; a.Lo = $FFFFFFFF
    b.Hi = 0; b.Lo = 1
    expected.Hi = 0; expected.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing addition with final carry: max value + 1'")

    carry = NAVInt64Add(a, b, result)

    passed = NAVAssertInt64Equal('Addition with final carry', expected, result)
    if (passed == false) {
        return false
    }

    passed = NAVAssertIntegerEqual('Final carry expected', 1, carry)
    return passed
}

/**
 * @function TestAddingZero
 * @description Test addition with zero, which should not change the value
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestAddingZero() {
    stack_var _NAVInt64 a, b, result, expected
    stack_var integer carry
    stack_var char passed

    // 0x123456789ABCDEF0 + 0 = 0x123456789ABCDEF0
    a.Hi = $12345678; a.Lo = $9ABCDEF0
    b.Hi = 0; b.Lo = 0
    expected.Hi = $12345678; expected.Lo = $9ABCDEF0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing adding zero: num + 0'")

    carry = NAVInt64Add(a, b, result)

    passed = NAVAssertInt64Equal('Adding zero', expected, result)
    if (passed == false) {
        return false
    }

    passed = NAVAssertIntegerEqual('No carry expected', 0, carry)
    return passed
}

/**
 * @function TestAddLongOverflow
 * @description Test NAVInt64AddLong function with overflow
 *
 * @returns {char} true if test passes, false if it fails
 */
define_function char TestAddLongOverflow() {
    stack_var _NAVInt64 a, result, expected
    stack_var integer carry
    stack_var char passed
    stack_var long b

    // 0xFFFFFFFF + 1 = 0x100000000 using AddLong
    a.Hi = 0; a.Lo = $FFFFFFFF
    b = 1
    expected.Hi = 1; expected.Lo = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing AddLong with carry: $FFFFFFFF + 1'")

    carry = NAVInt64AddLong(a, b, result)

    passed = NAVAssertInt64Equal('AddLong with carry', expected, result)
    if (passed == false) {
        return false
    }

    passed = NAVAssertIntegerEqual('No overall carry expected', 0, carry)
    return passed
}

/**
 * @function RunNAVInt64AddTests
 * @description Run all the Int64 addition tests
 *
 * @returns {void}
 */
define_function RunNAVInt64AddTests() {
    stack_var integer passCount, totalTests

    passCount = 0
    totalTests = 5

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64Add Tests ******************'")

    // Test 1
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Simple addition'")
    if (TestSimpleAddition() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 failed'")
    }

    // Test 2
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Addition with carry'")
    if (TestAdditionWithCarry() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 failed'")
    }

    // Test 3
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Addition with final carry'")
    if (TestAdditionWithFinalCarry() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 failed'")
    }

    // Test 4
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4: Adding zero'")
    if (TestAddingZero() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 failed'")
    }

    // Test 5
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5: AddLong with overflow'")
    if (TestAddLongOverflow() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 failed'")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVInt64Add: ', itoa(passCount), ' of ', itoa(totalTests), ' tests passed'")
}

#END_IF // __NAV_INT64_ADD_TESTS__
