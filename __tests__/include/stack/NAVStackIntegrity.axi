PROGRAM_NAME='NAVStackIntegrity'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Test LIFO (Last In First Out) ordering for string stack
 */
define_function TestNAVStackStringLIFOOrdering() {
    stack_var _NAVStackString stack
    stack_var char result[NAV_MAX_BUFFER]
    stack_var char items[5][50]

    NAVLog("'***************** TestNAVStackStringLIFOOrdering *****************'")

    items[1] = 'First'
    items[2] = 'Second'
    items[3] = 'Third'
    items[4] = 'Fourth'
    items[5] = 'Fifth'

    NAVStackInitString(stack, 5)

    // Push in order: First, Second, Third, Fourth, Fifth
    NAVStackPushString(stack, items[1])
    NAVStackPushString(stack, items[2])
    NAVStackPushString(stack, items[3])
    NAVStackPushString(stack, items[4])
    NAVStackPushString(stack, items[5])

    // Pop should return in reverse order: Fifth, Fourth, Third, Second, First
    result = NAVStackPopString(stack)
    if (!NAVAssertStringEqual('First pop should return Fifth', items[5], result)) {
        NAVLogTestFailed(1, items[5], result)
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVStackPopString(stack)
    if (!NAVAssertStringEqual('Second pop should return Fourth', items[4], result)) {
        NAVLogTestFailed(2, items[4], result)
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPopString(stack)
    if (!NAVAssertStringEqual('Third pop should return Third', items[3], result)) {
        NAVLogTestFailed(3, items[3], result)
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVStackPopString(stack)
    if (!NAVAssertStringEqual('Fourth pop should return Second', items[2], result)) {
        NAVLogTestFailed(4, items[2], result)
    }
    else {
        NAVLogTestPassed(4)
    }

    result = NAVStackPopString(stack)
    if (!NAVAssertStringEqual('Fifth pop should return First', items[1], result)) {
        NAVLogTestFailed(5, items[1], result)
    }
    else {
        NAVLogTestPassed(5)
    }
}

/**
 * Test LIFO (Last In First Out) ordering for integer stack
 */
define_function TestNAVStackIntegerLIFOOrdering() {
    stack_var _NAVStackInteger stack
    stack_var integer result
    stack_var integer items[5]

    NAVLog("'***************** TestNAVStackIntegerLIFOOrdering *****************'")

    items[1] = 10
    items[2] = 20
    items[3] = 30
    items[4] = 40
    items[5] = 50

    NAVStackInitInteger(stack, 5)

    // Push in order: 10, 20, 30, 40, 50
    NAVStackPushInteger(stack, items[1])
    NAVStackPushInteger(stack, items[2])
    NAVStackPushInteger(stack, items[3])
    NAVStackPushInteger(stack, items[4])
    NAVStackPushInteger(stack, items[5])

    // Pop should return in reverse order: 50, 40, 30, 20, 10
    result = NAVStackPopInteger(stack)
    if (!NAVAssertIntegerEqual('First pop should return 50', items[5], result)) {
        NAVLogTestFailed(1, itoa(items[5]), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVStackPopInteger(stack)
    if (!NAVAssertIntegerEqual('Second pop should return 40', items[4], result)) {
        NAVLogTestFailed(2, itoa(items[4]), itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPopInteger(stack)
    if (!NAVAssertIntegerEqual('Third pop should return 30', items[3], result)) {
        NAVLogTestFailed(3, itoa(items[3]), itoa(result))
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVStackPopInteger(stack)
    if (!NAVAssertIntegerEqual('Fourth pop should return 20', items[2], result)) {
        NAVLogTestFailed(4, itoa(items[2]), itoa(result))
    }
    else {
        NAVLogTestPassed(4)
    }

    result = NAVStackPopInteger(stack)
    if (!NAVAssertIntegerEqual('Fifth pop should return 10', items[1], result)) {
        NAVLogTestFailed(5, itoa(items[1]), itoa(result))
    }
    else {
        NAVLogTestPassed(5)
    }
}

/**
 * Test data persistence after peek operations for string stack
 */
define_function TestNAVStackStringDataPersistence() {
    stack_var _NAVStackString stack
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVStackStringDataPersistence *****************'")

    NAVStackInitString(stack, 5)

    NAVStackPushString(stack, 'TestData')

    // Multiple peeks should return the same value
    result = NAVStackPeekString(stack)
    if (!NAVAssertStringEqual('First peek should return TestData', 'TestData', result)) {
        NAVLogTestFailed(1, 'TestData', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVStackPeekString(stack)
    if (!NAVAssertStringEqual('Second peek should still return TestData', 'TestData', result)) {
        NAVLogTestFailed(2, 'TestData', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Count should still be 1', 1, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(3, itoa(1), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(3)
    }

    // Pop should return the same value
    result = NAVStackPopString(stack)
    if (!NAVAssertStringEqual('Pop should return TestData', 'TestData', result)) {
        NAVLogTestFailed(4, 'TestData', result)
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test data persistence after peek operations for integer stack
 */
define_function TestNAVStackIntegerDataPersistence() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerDataPersistence *****************'")

    NAVStackInitInteger(stack, 5)

    NAVStackPushInteger(stack, 777)

    // Multiple peeks should return the same value
    result = NAVStackPeekInteger(stack)
    if (!NAVAssertIntegerEqual('First peek should return 777', 777, result)) {
        NAVLogTestFailed(1, itoa(777), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVStackPeekInteger(stack)
    if (!NAVAssertIntegerEqual('Second peek should still return 777', 777, result)) {
        NAVLogTestFailed(2, itoa(777), itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Count should still be 1', 1, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(3, itoa(1), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(3)
    }

    // Pop should return the same value
    result = NAVStackPopInteger(stack)
    if (!NAVAssertIntegerEqual('Pop should return 777', 777, result)) {
        NAVLogTestFailed(4, itoa(777), itoa(result))
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test interleaved push and pop operations for string stack
 */
define_function TestNAVStackStringInterleavedOperations() {
    stack_var _NAVStackString stack
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVStackStringInterleavedOperations *****************'")

    NAVStackInitString(stack, 10)

    NAVStackPushString(stack, 'A')
    NAVStackPushString(stack, 'B')

    result = NAVStackPopString(stack)  // Should be 'B'
    if (!NAVAssertStringEqual('Pop should return B', 'B', result)) {
        NAVLogTestFailed(1, 'B', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVStackPushString(stack, 'C')
    NAVStackPushString(stack, 'D')

    result = NAVStackPopString(stack)  // Should be 'D'
    if (!NAVAssertStringEqual('Pop should return D', 'D', result)) {
        NAVLogTestFailed(2, 'D', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPopString(stack)  // Should be 'C'
    if (!NAVAssertStringEqual('Pop should return C', 'C', result)) {
        NAVLogTestFailed(3, 'C', result)
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVStackPopString(stack)  // Should be 'A'
    if (!NAVAssertStringEqual('Pop should return A', 'A', result)) {
        NAVLogTestFailed(4, 'A', result)
    }
    else {
        NAVLogTestPassed(4)
    }

    if (!NAVAssertTrue('Stack should be empty', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(5, 'true', 'false')
    }
    else {
        NAVLogTestPassed(5)
    }
}

/**
 * Test interleaved push and pop operations for integer stack
 */
define_function TestNAVStackIntegerInterleavedOperations() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerInterleavedOperations *****************'")

    NAVStackInitInteger(stack, 10)

    NAVStackPushInteger(stack, 100)
    NAVStackPushInteger(stack, 200)

    result = NAVStackPopInteger(stack)  // Should be 200
    if (!NAVAssertIntegerEqual('Pop should return 200', 200, result)) {
        NAVLogTestFailed(1, itoa(200), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVStackPushInteger(stack, 300)
    NAVStackPushInteger(stack, 400)

    result = NAVStackPopInteger(stack)  // Should be 400
    if (!NAVAssertIntegerEqual('Pop should return 400', 400, result)) {
        NAVLogTestFailed(2, itoa(400), itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPopInteger(stack)  // Should be 300
    if (!NAVAssertIntegerEqual('Pop should return 300', 300, result)) {
        NAVLogTestFailed(3, itoa(300), itoa(result))
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVStackPopInteger(stack)  // Should be 100
    if (!NAVAssertIntegerEqual('Pop should return 100', 100, result)) {
        NAVLogTestFailed(4, itoa(100), itoa(result))
    }
    else {
        NAVLogTestPassed(4)
    }

    if (!NAVAssertTrue('Stack should be empty', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(5, 'true', 'false')
    }
    else {
        NAVLogTestPassed(5)
    }
}

/**
 * Test string stack maintains state consistency through operations
 */
define_function TestNAVStackStringStateConsistency() {
    stack_var _NAVStackString stack
    stack_var integer x

    NAVLog("'***************** TestNAVStackStringStateConsistency *****************'")

    NAVStackInitString(stack, 5)

    // Verify initial state
    if (!NAVAssertTrue('Initial isEmpty should be true', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(1, 'true', 'false')
        return
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertFalse('Initial isFull should be false', NAVStackStringIsFull(stack))) {
        NAVLogTestFailed(2, 'false', 'true')
        return
    }
    else {
        NAVLogTestPassed(2)
    }

    // Fill stack and verify state
    for (x = 1; x <= 5; x++) {
        NAVStackPushString(stack, "'Item', itoa(x)")
    }

    if (!NAVAssertFalse('Full isEmpty should be false', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(3, 'false', 'true')
        return
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertTrue('Full isFull should be true', NAVStackStringIsFull(stack))) {
        NAVLogTestFailed(4, 'true', 'false')
        return
    }
    else {
        NAVLogTestPassed(4)
    }

    // Empty stack and verify state
    for (x = 1; x <= 5; x++) {
        NAVStackPopString(stack)
    }

    if (!NAVAssertTrue('Final isEmpty should be true', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(5, 'true', 'false')
    }
    else {
        NAVLogTestPassed(5)
    }

    if (!NAVAssertFalse('Final isFull should be false', NAVStackStringIsFull(stack))) {
        NAVLogTestFailed(6, 'false', 'true')
    }
    else {
        NAVLogTestPassed(6)
    }
}

/**
 * Test integer stack maintains state consistency through operations
 */
define_function TestNAVStackIntegerStateConsistency() {
    stack_var _NAVStackInteger stack
    stack_var integer x

    NAVLog("'***************** TestNAVStackIntegerStateConsistency *****************'")

    NAVStackInitInteger(stack, 5)

    // Verify initial state
    if (!NAVAssertTrue('Initial isEmpty should be true', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(1, 'true', 'false')
        return
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertFalse('Initial isFull should be false', NAVStackIntegerIsFull(stack))) {
        NAVLogTestFailed(2, 'false', 'true')
        return
    }
    else {
        NAVLogTestPassed(2)
    }

    // Fill stack and verify state
    for (x = 1; x <= 5; x++) {
        NAVStackPushInteger(stack, x * 10)
    }

    if (!NAVAssertFalse('Full isEmpty should be false', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(3, 'false', 'true')
        return
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertTrue('Full isFull should be true', NAVStackIntegerIsFull(stack))) {
        NAVLogTestFailed(4, 'true', 'false')
        return
    }
    else {
        NAVLogTestPassed(4)
    }

    // Empty stack and verify state
    for (x = 1; x <= 5; x++) {
        NAVStackPopInteger(stack)
    }

    if (!NAVAssertTrue('Final isEmpty should be true', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(5, 'true', 'false')
    }
    else {
        NAVLogTestPassed(5)
    }

    if (!NAVAssertFalse('Final isFull should be false', NAVStackIntegerIsFull(stack))) {
        NAVLogTestFailed(6, 'false', 'true')
    }
    else {
        NAVLogTestPassed(6)
    }
}
