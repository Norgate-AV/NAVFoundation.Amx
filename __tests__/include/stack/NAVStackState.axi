PROGRAM_NAME='NAVStackState'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char STATE_STRING_ITEMS[][50] = {
    'alpha',
    'beta',
    'gamma',
    'delta',
    'epsilon'
}

constant integer STATE_INTEGER_ITEMS[] = {
    100,
    200,
    300,
    400,
    500
}

/**
 * Test string stack isEmpty functionality
 */
define_function TestNAVStackStringIsEmpty() {
    stack_var _NAVStackString stack

    NAVLog("'***************** TestNAVStackStringIsEmpty *****************'")

    NAVStackInitString(stack, 5)

    if (!NAVAssertTrue('New stack should be empty', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVStackPushString(stack, STATE_STRING_ITEMS[1])

    if (!NAVAssertFalse('Stack with items should not be empty', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(2, 'false', 'true')
    }
    else {
        NAVLogTestPassed(2)
    }

    NAVStackPopString(stack)

    if (!NAVAssertTrue('Stack should be empty after popping all items', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test integer stack isEmpty functionality
 */
define_function TestNAVStackIntegerIsEmpty() {
    stack_var _NAVStackInteger stack

    NAVLog("'***************** TestNAVStackIntegerIsEmpty *****************'")

    NAVStackInitInteger(stack, 5)

    if (!NAVAssertTrue('New stack should be empty', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVStackPushInteger(stack, STATE_INTEGER_ITEMS[1])

    if (!NAVAssertFalse('Stack with items should not be empty', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(2, 'false', 'true')
    }
    else {
        NAVLogTestPassed(2)
    }

    NAVStackPopInteger(stack)

    if (!NAVAssertTrue('Stack should be empty after popping all items', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test string stack isFull functionality
 */
define_function TestNAVStackStringIsFull() {
    stack_var _NAVStackString stack
    stack_var integer x

    NAVLog("'***************** TestNAVStackStringIsFull *****************'")

    NAVStackInitString(stack, 3)

    if (!NAVAssertFalse('Empty stack should not be full', NAVStackStringIsFull(stack))) {
        NAVLogTestFailed(1, 'false', 'true')
    }
    else {
        NAVLogTestPassed(1)
    }

    for (x = 1; x <= 3; x++) {
        NAVStackPushString(stack, STATE_STRING_ITEMS[x])
    }

    if (!NAVAssertTrue('Stack should be full after filling', NAVStackStringIsFull(stack))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }

    NAVStackPopString(stack)

    if (!NAVAssertFalse('Stack should not be full after popping', NAVStackStringIsFull(stack))) {
        NAVLogTestFailed(3, 'false', 'true')
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test integer stack isFull functionality
 */
define_function TestNAVStackIntegerIsFull() {
    stack_var _NAVStackInteger stack
    stack_var integer x

    NAVLog("'***************** TestNAVStackIntegerIsFull *****************'")

    NAVStackInitInteger(stack, 3)

    if (!NAVAssertFalse('Empty stack should not be full', NAVStackIntegerIsFull(stack))) {
        NAVLogTestFailed(1, 'false', 'true')
    }
    else {
        NAVLogTestPassed(1)
    }

    for (x = 1; x <= 3; x++) {
        NAVStackPushInteger(stack, STATE_INTEGER_ITEMS[x])
    }

    if (!NAVAssertTrue('Stack should be full after filling', NAVStackIntegerIsFull(stack))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }

    NAVStackPopInteger(stack)

    if (!NAVAssertFalse('Stack should not be full after popping', NAVStackIntegerIsFull(stack))) {
        NAVLogTestFailed(3, 'false', 'true')
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test string stack getCount functionality
 */
define_function TestNAVStackStringGetCount() {
    stack_var _NAVStackString stack
    stack_var integer x

    NAVLog("'***************** TestNAVStackStringGetCount *****************'")

    NAVStackInitString(stack, 5)

    if (!NAVAssertIntegerEqual('Empty stack count should be 0', 0, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(1, itoa(0), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }

    for (x = 1; x <= 5; x++) {
        NAVStackPushString(stack, STATE_STRING_ITEMS[x])
        if (!NAVAssertIntegerEqual("'Count should be ', itoa(x)", x, NAVStackStringGetCount(stack))) {
            NAVLogTestFailed(x + 1, itoa(x), itoa(NAVStackStringGetCount(stack)))
        }
        else {
            NAVLogTestPassed(x + 1)
        }
    }

    for (x = 4; x >= 1; x--) {
        NAVStackPopString(stack)
        if (!NAVAssertIntegerEqual("'Count should be ', itoa(x)", x, NAVStackStringGetCount(stack))) {
            NAVLogTestFailed(x + 6, itoa(x), itoa(NAVStackStringGetCount(stack)))
        }
        else {
            NAVLogTestPassed(x + 6)
        }
    }
}

/**
 * Test integer stack getCount functionality
 */
define_function TestNAVStackIntegerGetCount() {
    stack_var _NAVStackInteger stack
    stack_var integer x

    NAVLog("'***************** TestNAVStackIntegerGetCount *****************'")

    NAVStackInitInteger(stack, 5)

    if (!NAVAssertIntegerEqual('Empty stack count should be 0', 0, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(1, itoa(0), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }

    for (x = 1; x <= 5; x++) {
        NAVStackPushInteger(stack, STATE_INTEGER_ITEMS[x])
        if (!NAVAssertIntegerEqual("'Count should be ', itoa(x)", x, NAVStackIntegerGetCount(stack))) {
            NAVLogTestFailed(x + 1, itoa(x), itoa(NAVStackIntegerGetCount(stack)))
        }
        else {
            NAVLogTestPassed(x + 1)
        }
    }

    for (x = 4; x >= 1; x--) {
        NAVStackPopInteger(stack)
        if (!NAVAssertIntegerEqual("'Count should be ', itoa(x)", x, NAVStackIntegerGetCount(stack))) {
            NAVLogTestFailed(x + 6, itoa(x), itoa(NAVStackIntegerGetCount(stack)))
        }
        else {
            NAVLogTestPassed(x + 6)
        }
    }
}

/**
 * Test string stack getCapacity functionality
 */
define_function TestNAVStackStringGetCapacity() {
    stack_var _NAVStackString stack

    NAVLog("'***************** TestNAVStackStringGetCapacity *****************'")

    NAVStackInitString(stack, 10)

    if (!NAVAssertIntegerEqual('Capacity should be 10', 10, NAVStackStringGetCapacity(stack))) {
        NAVLogTestFailed(1, itoa(10), itoa(NAVStackStringGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Capacity should not change when pushing items
    NAVStackPushString(stack, STATE_STRING_ITEMS[1])

    if (!NAVAssertIntegerEqual('Capacity should still be 10', 10, NAVStackStringGetCapacity(stack))) {
        NAVLogTestFailed(2, itoa(10), itoa(NAVStackStringGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test integer stack getCapacity functionality
 */
define_function TestNAVStackIntegerGetCapacity() {
    stack_var _NAVStackInteger stack

    NAVLog("'***************** TestNAVStackIntegerGetCapacity *****************'")

    NAVStackInitInteger(stack, 10)

    if (!NAVAssertIntegerEqual('Capacity should be 10', 10, NAVStackIntegerGetCapacity(stack))) {
        NAVLogTestFailed(1, itoa(10), itoa(NAVStackIntegerGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Capacity should not change when pushing items
    NAVStackPushInteger(stack, STATE_INTEGER_ITEMS[1])

    if (!NAVAssertIntegerEqual('Capacity should still be 10', 10, NAVStackIntegerGetCapacity(stack))) {
        NAVLogTestFailed(2, itoa(10), itoa(NAVStackIntegerGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }
}
