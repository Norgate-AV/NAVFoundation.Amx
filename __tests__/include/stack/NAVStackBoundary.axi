PROGRAM_NAME='NAVStackBoundary'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Test popping from an empty string stack
 */
define_function TestNAVStackStringPopEmpty() {
    stack_var _NAVStackString stack
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVStackStringPopEmpty *****************'")

    NAVStackInitString(stack, 5)

    result = NAVStackPopString(stack)

    if (!NAVAssertStringEqual('Popping empty stack should return empty string', '', result)) {
        NAVLogTestFailed(1, '', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertTrue('Stack should still be empty', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test popping from an empty integer stack
 */
define_function TestNAVStackIntegerPopEmpty() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerPopEmpty *****************'")

    NAVStackInitInteger(stack, 5)

    result = NAVStackPopInteger(stack)

    if (!NAVAssertIntegerEqual('Popping empty stack should return 0', 0, result)) {
        NAVLogTestFailed(1, itoa(0), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertTrue('Stack should still be empty', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test peeking at an empty string stack
 */
define_function TestNAVStackStringPeekEmpty() {
    stack_var _NAVStackString stack
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVStackStringPeekEmpty *****************'")

    NAVStackInitString(stack, 5)

    result = NAVStackPeekString(stack)

    if (!NAVAssertStringEqual('Peeking empty stack should return empty string', '', result)) {
        NAVLogTestFailed(1, '', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertTrue('Stack should still be empty', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test peeking at an empty integer stack
 */
define_function TestNAVStackIntegerPeekEmpty() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerPeekEmpty *****************'")

    NAVStackInitInteger(stack, 5)

    result = NAVStackPeekInteger(stack)

    if (!NAVAssertIntegerEqual('Peeking empty stack should return 0', 0, result)) {
        NAVLogTestFailed(1, itoa(0), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertTrue('Stack should still be empty', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test pushing to a full string stack
 */
define_function TestNAVStackStringPushFull() {
    stack_var _NAVStackString stack
    stack_var char result
    stack_var integer x

    NAVLog("'***************** TestNAVStackStringPushFull *****************'")

    NAVStackInitString(stack, 3)

    // Fill the stack
    for (x = 1; x <= 3; x++) {
        NAVStackPushString(stack, "'Item', itoa(x)")
    }

    if (!NAVAssertTrue('Stack should be full', NAVStackStringIsFull(stack))) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    // Try to push to full stack
    result = NAVStackPushString(stack, 'Overflow Item')

    if (!NAVAssertFalse('Push to full stack should fail', result)) {
        NAVLogTestFailed(2, 'false', 'true')
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Count should still be 3', 3, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(3, itoa(3), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test pushing to a full integer stack
 */
define_function TestNAVStackIntegerPushFull() {
    stack_var _NAVStackInteger stack
    stack_var char result
    stack_var integer x

    NAVLog("'***************** TestNAVStackIntegerPushFull *****************'")

    NAVStackInitInteger(stack, 3)

    // Fill the stack
    for (x = 1; x <= 3; x++) {
        NAVStackPushInteger(stack, x * 10)
    }

    if (!NAVAssertTrue('Stack should be full', NAVStackIntegerIsFull(stack))) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    // Try to push to full stack
    result = NAVStackPushInteger(stack, 999)

    if (!NAVAssertFalse('Push to full stack should fail', result)) {
        NAVLogTestFailed(2, 'false', 'true')
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Count should still be 3', 3, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(3, itoa(3), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test string stack initialization with capacity of 1
 */
define_function TestNAVStackStringInitCapacityOne() {
    stack_var _NAVStackString stack
    stack_var char result

    NAVLog("'***************** TestNAVStackStringInitCapacityOne *****************'")

    NAVStackInitString(stack, 1)

    if (!NAVAssertIntegerEqual('Capacity should be 1', 1, NAVStackStringGetCapacity(stack))) {
        NAVLogTestFailed(1, itoa(1), itoa(NAVStackStringGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVStackPushString(stack, 'Single Item')

    if (!NAVAssertTrue('Should be able to push one item', result)) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertTrue('Stack should be full', NAVStackStringIsFull(stack))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVStackPushString(stack, 'Second Item')

    if (!NAVAssertFalse('Should not be able to push second item', result)) {
        NAVLogTestFailed(4, 'false', 'true')
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test integer stack initialization with capacity of 1
 */
define_function TestNAVStackIntegerInitCapacityOne() {
    stack_var _NAVStackInteger stack
    stack_var char result

    NAVLog("'***************** TestNAVStackIntegerInitCapacityOne *****************'")

    NAVStackInitInteger(stack, 1)

    if (!NAVAssertIntegerEqual('Capacity should be 1', 1, NAVStackIntegerGetCapacity(stack))) {
        NAVLogTestFailed(1, itoa(1), itoa(NAVStackIntegerGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVStackPushInteger(stack, 42)

    if (!NAVAssertTrue('Should be able to push one item', result)) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertTrue('Stack should be full', NAVStackIntegerIsFull(stack))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVStackPushInteger(stack, 84)

    if (!NAVAssertFalse('Should not be able to push second item', result)) {
        NAVLogTestFailed(4, 'false', 'true')
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test string stack initialization with capacity of zero (should default to max)
 */
define_function TestNAVStackStringInitCapacityZero() {
    stack_var _NAVStackString stack

    NAVLog("'***************** TestNAVStackStringInitCapacityZero *****************'")

    NAVStackInitString(stack, 0)

    if (!NAVAssertIntegerEqual('Capacity should default to NAV_MAX_STACK_SIZE', NAV_MAX_STACK_SIZE, NAVStackStringGetCapacity(stack))) {
        NAVLogTestFailed(1, itoa(NAV_MAX_STACK_SIZE), itoa(NAVStackStringGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test integer stack initialization with capacity of zero (should default to max)
 */
define_function TestNAVStackIntegerInitCapacityZero() {
    stack_var _NAVStackInteger stack

    NAVLog("'***************** TestNAVStackIntegerInitCapacityZero *****************'")

    NAVStackInitInteger(stack, 0)

    if (!NAVAssertIntegerEqual('Capacity should default to NAV_MAX_STACK_SIZE', NAV_MAX_STACK_SIZE, NAVStackIntegerGetCapacity(stack))) {
        NAVLogTestFailed(1, itoa(NAV_MAX_STACK_SIZE), itoa(NAVStackIntegerGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test string stack initialization with capacity exceeding max
 */
define_function TestNAVStackStringInitCapacityExceedsMax() {
    stack_var _NAVStackString stack

    NAVLog("'***************** TestNAVStackStringInitCapacityExceedsMax *****************'")

    NAVStackInitString(stack, NAV_MAX_STACK_SIZE + 100)

    if (!NAVAssertIntegerEqual('Capacity should be capped at NAV_MAX_STACK_SIZE', NAV_MAX_STACK_SIZE, NAVStackStringGetCapacity(stack))) {
        NAVLogTestFailed(1, itoa(NAV_MAX_STACK_SIZE), itoa(NAVStackStringGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test integer stack initialization with capacity exceeding max
 */
define_function TestNAVStackIntegerInitCapacityExceedsMax() {
    stack_var _NAVStackInteger stack

    NAVLog("'***************** TestNAVStackIntegerInitCapacityExceedsMax *****************'")

    NAVStackInitInteger(stack, NAV_MAX_STACK_SIZE + 100)

    if (!NAVAssertIntegerEqual('Capacity should be capped at NAV_MAX_STACK_SIZE', NAV_MAX_STACK_SIZE, NAVStackIntegerGetCapacity(stack))) {
        NAVLogTestFailed(1, itoa(NAV_MAX_STACK_SIZE), itoa(NAVStackIntegerGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test pushing empty string to string stack
 */
define_function TestNAVStackStringPushEmptyString() {
    stack_var _NAVStackString stack
    stack_var char result

    NAVLog("'***************** TestNAVStackStringPushEmptyString *****************'")

    NAVStackInitString(stack, 5)

    result = NAVStackPushString(stack, '')

    // Should succeed but may log a warning
    if (!NAVAssertTrue('Push empty string should succeed', result)) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should be 1', 1, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(2, itoa(1), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test string stack with very long strings
 */
define_function TestNAVStackStringLongStrings() {
    stack_var _NAVStackString stack
    stack_var char longString[NAV_MAX_BUFFER]
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer x

    NAVLog("'***************** TestNAVStackStringLongStrings *****************'")

    NAVStackInitString(stack, 3)

    // Create a long string
    for (x = 1; x <= 100; x++) {
        longString = "longString, 'A'"
    }

    NAVStackPushString(stack, longString)
    result = NAVStackPeekString(stack)

    if (!NAVAssertStringEqual('Long string should be stored correctly', longString, result)) {
        NAVLogTestFailed(1, "'String length: ', itoa(length_array(longString))", "'String length: ', itoa(length_array(result))")
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test integer stack with zero values
 */
define_function TestNAVStackIntegerZeroValues() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerZeroValues *****************'")

    NAVStackInitInteger(stack, 5)

    NAVStackPushInteger(stack, 0)

    if (!NAVAssertIntegerEqual('Count should be 1', 1, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(1, itoa(1), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVStackPeekInteger(stack)

    if (!NAVAssertIntegerEqual('Peek should return 0', 0, result)) {
        NAVLogTestFailed(2, itoa(0), itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPopInteger(stack)

    if (!NAVAssertIntegerEqual('Pop should return 0', 0, result)) {
        NAVLogTestFailed(3, itoa(0), itoa(result))
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertTrue('Stack should be empty', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(4, 'true', 'false')
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test integer stack with negative values
 */
// define_function TestNAVStackIntegerNegativeValues() {
//     stack_var _NAVStackInteger stack
//     stack_var sinteger negativeValue
//     stack_var integer result

//     NAVLog("'***************** TestNAVStackIntegerNegativeValues *****************'")

//     NAVStackInitInteger(stack, 5)

//     negativeValue = -42

//     NAVStackPushInteger(stack, negativeValue)
//     result = NAVStackPeekInteger(stack)

//     if (!NAVAssertIntegerEqual('Peek should return -42', negativeValue, result)) {
//         NAVLogTestFailed(1, itoa(negativeValue), itoa(result))
//     }
//     else {
//         NAVLogTestPassed(1)
//     }

//     result = NAVStackPopInteger(stack)

//     if (!NAVAssertIntegerEqual('Pop should return -42', negativeValue, result)) {
//         NAVLogTestFailed(2, itoa(negativeValue), itoa(result))
//     }
//     else {
//         NAVLogTestPassed(2)
//     }
// }
