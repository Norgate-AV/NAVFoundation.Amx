PROGRAM_NAME='NAVStackBasic'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char BASIC_STRING_ITEMS[][50] = {
    'item1',
    'item2',
    'item3',
    'item4',
    'item5'
}

constant integer BASIC_INTEGER_ITEMS[] = {
    10,
    20,
    30,
    40,
    50
}

/**
 * Test basic string stack initialization functionality
 */
define_function TestNAVStackStringInit() {
    stack_var _NAVStackString stack

    NAVLog("'***************** TestNAVStackStringInit *****************'")

    NAVStackInitString(stack, 10)

    if (!NAVAssertIntegerEqual('Stack capacity should be 10', 10, stack.Properties.Capacity)) {
        NAVLogTestFailed(1, itoa(10), itoa(stack.Properties.Capacity))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Stack top should be 0', 0, stack.Properties.Top)) {
        NAVLogTestFailed(2, itoa(0), itoa(stack.Properties.Top))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertTrue('Stack should be empty', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test basic integer stack initialization functionality
 */
define_function TestNAVStackIntegerInit() {
    stack_var _NAVStackInteger stack

    NAVLog("'***************** TestNAVStackIntegerInit *****************'")

    NAVStackInitInteger(stack, 10)

    if (!NAVAssertIntegerEqual('Stack capacity should be 10', 10, stack.Properties.Capacity)) {
        NAVLogTestFailed(1, itoa(10), itoa(stack.Properties.Capacity))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Stack top should be 0', 0, stack.Properties.Top)) {
        NAVLogTestFailed(2, itoa(0), itoa(stack.Properties.Top))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertTrue('Stack should be empty', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test basic string stack push functionality
 */
define_function TestNAVStackStringPush() {
    stack_var _NAVStackString stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackStringPush *****************'")

    NAVStackInitString(stack, 5)

    result = NAVStackPushString(stack, BASIC_STRING_ITEMS[1])
    if (!NAVAssertIntegerEqual('First push should succeed', true, result)) {
        NAVLogTestFailed(1, itoa(true), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should be 1 after push', 1, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(2, itoa(1), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPushString(stack, BASIC_STRING_ITEMS[2])
    if (!NAVAssertIntegerEqual('Count should be 2 after second push', 2, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(3, itoa(2), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVStackPushString(stack, BASIC_STRING_ITEMS[3])
    if (!NAVAssertIntegerEqual('Count should be 3 after third push', 3, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(4, itoa(3), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(4)
    }

    if (!NAVAssertFalse('Stack should not be empty', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(5, 'false', 'true')
    }
    else {
        NAVLogTestPassed(5)
    }
}

/**
 * Test basic integer stack push functionality
 */
define_function TestNAVStackIntegerPush() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerPush *****************'")

    NAVStackInitInteger(stack, 5)

    result = NAVStackPushInteger(stack, BASIC_INTEGER_ITEMS[1])
    if (!NAVAssertIntegerEqual('First push should succeed', true, result)) {
        NAVLogTestFailed(1, itoa(true), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should be 1 after push', 1, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(2, itoa(1), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPushInteger(stack, BASIC_INTEGER_ITEMS[2])
    if (!NAVAssertIntegerEqual('Count should be 2 after second push', 2, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(3, itoa(2), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVStackPushInteger(stack, BASIC_INTEGER_ITEMS[3])
    if (!NAVAssertIntegerEqual('Count should be 3 after third push', 3, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(4, itoa(3), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(4)
    }

    if (!NAVAssertFalse('Stack should not be empty', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(5, 'false', 'true')
    }
    else {
        NAVLogTestPassed(5)
    }
}

/**
 * Test basic string stack pop functionality
 */
define_function TestNAVStackStringPop() {
    stack_var _NAVStackString stack
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVStackStringPop *****************'")

    NAVStackInitString(stack, 5)

    NAVStackPushString(stack, BASIC_STRING_ITEMS[1])
    NAVStackPushString(stack, BASIC_STRING_ITEMS[2])
    NAVStackPushString(stack, BASIC_STRING_ITEMS[3])

    result = NAVStackPopString(stack)
    if (!NAVAssertStringEqual('Popped item should be item3 (LIFO)', BASIC_STRING_ITEMS[3], result)) {
        NAVLogTestFailed(1, BASIC_STRING_ITEMS[3], result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should be 2 after pop', 2, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(2, itoa(2), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPopString(stack)
    if (!NAVAssertStringEqual('Popped item should be item2', BASIC_STRING_ITEMS[2], result)) {
        NAVLogTestFailed(3, BASIC_STRING_ITEMS[2], result)
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('Count should be 1 after second pop', 1, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(4, itoa(1), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(4)
    }

    result = NAVStackPopString(stack)
    if (!NAVAssertStringEqual('Popped item should be item1', BASIC_STRING_ITEMS[1], result)) {
        NAVLogTestFailed(5, BASIC_STRING_ITEMS[1], result)
    }
    else {
        NAVLogTestPassed(5)
    }

    if (!NAVAssertIntegerEqual('Count should be 0 after final pop', 0, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(6, itoa(0), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(6)
    }

    if (!NAVAssertTrue('Stack should be empty', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(7, 'true', 'false')
    }
    else {
        NAVLogTestPassed(7)
    }
}

/**
 * Test basic integer stack pop functionality
 */
define_function TestNAVStackIntegerPop() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerPop *****************'")

    NAVStackInitInteger(stack, 5)

    NAVStackPushInteger(stack, BASIC_INTEGER_ITEMS[1])
    NAVStackPushInteger(stack, BASIC_INTEGER_ITEMS[2])
    NAVStackPushInteger(stack, BASIC_INTEGER_ITEMS[3])

    result = NAVStackPopInteger(stack)
    if (!NAVAssertIntegerEqual('Popped item should be 30 (LIFO)', BASIC_INTEGER_ITEMS[3], result)) {
        NAVLogTestFailed(1, itoa(BASIC_INTEGER_ITEMS[3]), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should be 2 after pop', 2, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(2, itoa(2), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPopInteger(stack)
    if (!NAVAssertIntegerEqual('Popped item should be 20', BASIC_INTEGER_ITEMS[2], result)) {
        NAVLogTestFailed(3, itoa(BASIC_INTEGER_ITEMS[2]), itoa(result))
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('Count should be 1 after second pop', 1, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(4, itoa(1), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(4)
    }

    result = NAVStackPopInteger(stack)
    if (!NAVAssertIntegerEqual('Popped item should be 10', BASIC_INTEGER_ITEMS[1], result)) {
        NAVLogTestFailed(5, itoa(BASIC_INTEGER_ITEMS[1]), itoa(result))
    }
    else {
        NAVLogTestPassed(5)
    }

    if (!NAVAssertIntegerEqual('Count should be 0 after final pop', 0, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(6, itoa(0), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(6)
    }

    if (!NAVAssertTrue('Stack should be empty', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(7, 'true', 'false')
    }
    else {
        NAVLogTestPassed(7)
    }
}

/**
 * Test basic string stack peek functionality
 */
define_function TestNAVStackStringPeek() {
    stack_var _NAVStackString stack
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVStackStringPeek *****************'")

    NAVStackInitString(stack, 5)

    NAVStackPushString(stack, BASIC_STRING_ITEMS[1])
    NAVStackPushString(stack, BASIC_STRING_ITEMS[2])
    NAVStackPushString(stack, BASIC_STRING_ITEMS[3])

    result = NAVStackPeekString(stack)
    if (!NAVAssertStringEqual('Peeked item should be item3', BASIC_STRING_ITEMS[3], result)) {
        NAVLogTestFailed(1, BASIC_STRING_ITEMS[3], result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should still be 3 after peek', 3, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(2, itoa(3), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPeekString(stack)
    if (!NAVAssertStringEqual('Peeked item should still be item3', BASIC_STRING_ITEMS[3], result)) {
        NAVLogTestFailed(3, BASIC_STRING_ITEMS[3], result)
    }
    else {
        NAVLogTestPassed(3)
    }

    // Pop and verify peek updates
    NAVStackPopString(stack)
    result = NAVStackPeekString(stack)
    if (!NAVAssertStringEqual('After pop, peeked item should be item2', BASIC_STRING_ITEMS[2], result)) {
        NAVLogTestFailed(4, BASIC_STRING_ITEMS[2], result)
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test basic integer stack peek functionality
 */
define_function TestNAVStackIntegerPeek() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerPeek *****************'")

    NAVStackInitInteger(stack, 5)

    NAVStackPushInteger(stack, BASIC_INTEGER_ITEMS[1])
    NAVStackPushInteger(stack, BASIC_INTEGER_ITEMS[2])
    NAVStackPushInteger(stack, BASIC_INTEGER_ITEMS[3])

    result = NAVStackPeekInteger(stack)
    if (!NAVAssertIntegerEqual('Peeked item should be 30', BASIC_INTEGER_ITEMS[3], result)) {
        NAVLogTestFailed(1, itoa(BASIC_INTEGER_ITEMS[3]), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should still be 3 after peek', 3, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(2, itoa(3), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPeekInteger(stack)
    if (!NAVAssertIntegerEqual('Peeked item should still be 30', BASIC_INTEGER_ITEMS[3], result)) {
        NAVLogTestFailed(3, itoa(BASIC_INTEGER_ITEMS[3]), itoa(result))
    }
    else {
        NAVLogTestPassed(3)
    }

    // Pop and verify peek updates
    NAVStackPopInteger(stack)
    result = NAVStackPeekInteger(stack)
    if (!NAVAssertIntegerEqual('After pop, peeked item should be 20', BASIC_INTEGER_ITEMS[2], result)) {
        NAVLogTestFailed(4, itoa(BASIC_INTEGER_ITEMS[2]), itoa(result))
    }
    else {
        NAVLogTestPassed(4)
    }
}
