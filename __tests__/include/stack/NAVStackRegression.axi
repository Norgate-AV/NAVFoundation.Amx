PROGRAM_NAME='NAVStackRegression'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Test error recovery after attempting to pop from empty string stack
 */
define_function TestNAVStackStringErrorRecovery() {
    stack_var _NAVStackString stack
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVStackStringErrorRecovery *****************'")

    NAVStackInitString(stack, 5)

    // Try to pop from empty stack
    result = NAVStackPopString(stack)

    if (!NAVAssertStringEqual('Pop from empty should return empty string', '', result)) {
        NAVLogTestFailed(1, '', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Stack should still be functional after error
    NAVStackPushString(stack, 'Recovery Test')

    if (!NAVAssertIntegerEqual('Should be able to push after error', 1, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(2, itoa(1), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPopString(stack)

    if (!NAVAssertStringEqual('Should be able to pop after error', 'Recovery Test', result)) {
        NAVLogTestFailed(3, 'Recovery Test', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test error recovery after attempting to pop from empty integer stack
 */
define_function TestNAVStackIntegerErrorRecovery() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerErrorRecovery *****************'")

    NAVStackInitInteger(stack, 5)

    // Try to pop from empty stack
    result = NAVStackPopInteger(stack)

    if (!NAVAssertIntegerEqual('Pop from empty should return 0', 0, result)) {
        NAVLogTestFailed(1, itoa(0), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Stack should still be functional after error
    NAVStackPushInteger(stack, 999)

    if (!NAVAssertIntegerEqual('Should be able to push after error', 1, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(2, itoa(1), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVStackPopInteger(stack)

    if (!NAVAssertIntegerEqual('Should be able to pop after error', 999, result)) {
        NAVLogTestFailed(3, itoa(999), itoa(result))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test string stack with rapid push and pop cycles
 */
define_function TestNAVStackStringRapidOperations() {
    stack_var _NAVStackString stack
    stack_var integer cycle
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVStackStringRapidOperations *****************'")

    NAVStackInitString(stack, 10)

    // Perform 10 cycles of push/pop
    for (cycle = 1; cycle <= 10; cycle++) {
        NAVStackPushString(stack, "'Cycle', itoa(cycle)")
        result = NAVStackPopString(stack)

        if (!NAVAssertStringEqual("'Cycle ', itoa(cycle), ' pop should return correct value'", "'Cycle', itoa(cycle)", result)) {
            NAVLogTestFailed(cycle, "'Cycle', itoa(cycle)", result)
            return
        }
    }

    NAVLogTestPassed(1)

    if (!NAVAssertTrue('Stack should be empty after rapid operations', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test integer stack with rapid push and pop cycles
 */
define_function TestNAVStackIntegerRapidOperations() {
    stack_var _NAVStackInteger stack
    stack_var integer cycle
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerRapidOperations *****************'")

    NAVStackInitInteger(stack, 10)

    // Perform 10 cycles of push/pop
    for (cycle = 1; cycle <= 10; cycle++) {
        NAVStackPushInteger(stack, cycle * 100)
        result = NAVStackPopInteger(stack)

        if (!NAVAssertIntegerEqual("'Cycle ', itoa(cycle), ' pop should return correct value'", cycle * 100, result)) {
            NAVLogTestFailed(cycle, itoa(cycle * 100), itoa(result))
            return
        }
    }

    NAVLogTestPassed(1)

    if (!NAVAssertTrue('Stack should be empty after rapid operations', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test string stack full and empty cycles
 */
define_function TestNAVStackStringFullEmptyCycles() {
    stack_var _NAVStackString stack
    stack_var integer cycle
    stack_var integer x

    NAVLog("'***************** TestNAVStackStringFullEmptyCycles *****************'")

    NAVStackInitString(stack, 3)

    // Perform 3 cycles of fill and empty
    for (cycle = 1; cycle <= 3; cycle++) {
        // Fill the stack
        for (x = 1; x <= 3; x++) {
            NAVStackPushString(stack, "'Cycle', itoa(cycle), '-', itoa(x)")
        }

        if (!NAVAssertTrue("'Stack should be full in cycle ', itoa(cycle)", NAVStackStringIsFull(stack))) {
            NAVLogTestFailed(cycle * 2 - 1, 'true', 'false')
            return
        }
        else {
            NAVLogTestPassed(cycle * 2 - 1)
        }

        // Empty the stack
        for (x = 1; x <= 3; x++) {
            NAVStackPopString(stack)
        }

        if (!NAVAssertTrue("'Stack should be empty in cycle ', itoa(cycle)", NAVStackStringIsEmpty(stack))) {
            NAVLogTestFailed(cycle * 2, 'true', 'false')
            return
        }
        else {
            NAVLogTestPassed(cycle * 2)
        }
    }
}

/**
 * Test integer stack full and empty cycles
 */
define_function TestNAVStackIntegerFullEmptyCycles() {
    stack_var _NAVStackInteger stack
    stack_var integer cycle
    stack_var integer x

    NAVLog("'***************** TestNAVStackIntegerFullEmptyCycles *****************'")

    NAVStackInitInteger(stack, 3)

    // Perform 3 cycles of fill and empty
    for (cycle = 1; cycle <= 3; cycle++) {
        // Fill the stack
        for (x = 1; x <= 3; x++) {
            NAVStackPushInteger(stack, (cycle * 100) + x)
        }

        if (!NAVAssertTrue("'Stack should be full in cycle ', itoa(cycle)", NAVStackIntegerIsFull(stack))) {
            NAVLogTestFailed(cycle * 2 - 1, 'true', 'false')
            return
        }
        else {
            NAVLogTestPassed(cycle * 2 - 1)
        }

        // Empty the stack
        for (x = 1; x <= 3; x++) {
            NAVStackPopInteger(stack)
        }

        if (!NAVAssertTrue("'Stack should be empty in cycle ', itoa(cycle)", NAVStackIntegerIsEmpty(stack))) {
            NAVLogTestFailed(cycle * 2, 'true', 'false')
            return
        }
        else {
            NAVLogTestPassed(cycle * 2)
        }
    }
}

/**
 * Test string stack reinitialization
 */
define_function TestNAVStackStringReinitialization() {
    stack_var _NAVStackString stack
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVStackStringReinitialization *****************'")

    // Initialize and use stack
    NAVStackInitString(stack, 5)
    NAVStackPushString(stack, 'First')
    NAVStackPushString(stack, 'Second')

    if (!NAVAssertIntegerEqual('Count should be 2', 2, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(1, itoa(2), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Reinitialize with different capacity
    NAVStackInitString(stack, 10)

    if (!NAVAssertIntegerEqual('After reinit, capacity should be 10', 10, NAVStackStringGetCapacity(stack))) {
        NAVLogTestFailed(2, itoa(10), itoa(NAVStackStringGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertTrue('After reinit, stack should be empty', NAVStackStringIsEmpty(stack))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }

    // Should be able to use stack normally after reinit
    NAVStackPushString(stack, 'New Data')
    result = NAVStackPopString(stack)

    if (!NAVAssertStringEqual('Should work normally after reinit', 'New Data', result)) {
        NAVLogTestFailed(4, 'New Data', result)
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test integer stack reinitialization
 */
define_function TestNAVStackIntegerReinitialization() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerReinitialization *****************'")

    // Initialize and use stack
    NAVStackInitInteger(stack, 5)
    NAVStackPushInteger(stack, 111)
    NAVStackPushInteger(stack, 222)

    if (!NAVAssertIntegerEqual('Count should be 2', 2, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(1, itoa(2), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Reinitialize with different capacity
    NAVStackInitInteger(stack, 10)

    if (!NAVAssertIntegerEqual('After reinit, capacity should be 10', 10, NAVStackIntegerGetCapacity(stack))) {
        NAVLogTestFailed(2, itoa(10), itoa(NAVStackIntegerGetCapacity(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertTrue('After reinit, stack should be empty', NAVStackIntegerIsEmpty(stack))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }

    // Should be able to use stack normally after reinit
    NAVStackPushInteger(stack, 333)
    result = NAVStackPopInteger(stack)

    if (!NAVAssertIntegerEqual('Should work normally after reinit', 333, result)) {
        NAVLogTestFailed(4, itoa(333), itoa(result))
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test string stack with special characters
 */
define_function TestNAVStackStringSpecialCharacters() {
    stack_var _NAVStackString stack
    stack_var char testStrings[5][NAV_MAX_BUFFER]
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer x

    NAVLog("'***************** TestNAVStackStringSpecialCharacters *****************'")

    testStrings[1] = "'Hello World'"
    testStrings[2] = "'Special: !@#$%^&*()'"
    testStrings[3] = "'Tabs:', $09, 'and', $09, 'newlines', $0A"
    testStrings[4] = "'Unicode: ', $C2, $A9, $C2, $AE"  // Copyright and Registered symbols
    testStrings[5] = "'Empty and Spaces:     '"

    NAVStackInitString(stack, 5)

    // Push all test strings
    for (x = 1; x <= 5; x++) {
        NAVStackPushString(stack, testStrings[x])
    }

    // Pop and verify in reverse order
    for (x = 5; x >= 1; x--) {
        result = NAVStackPopString(stack)
        if (!NAVAssertStringEqual("'Test string ', itoa(x), ' should match'", testStrings[x], result)) {
            NAVLogTestFailed(6 - x, testStrings[x], result)
            return
        }
        else {
            NAVLogTestPassed(6 - x)
        }
    }
}

/**
 * Test integer stack with boundary values
 */
define_function TestNAVStackIntegerBoundaryValues() {
    stack_var _NAVStackInteger stack
    stack_var integer result

    NAVLog("'***************** TestNAVStackIntegerBoundaryValues *****************'")

    NAVStackInitInteger(stack, 5)

    // Test minimum value
    NAVStackPushInteger(stack, 0)
    result = NAVStackPopInteger(stack)

    if (!NAVAssertIntegerEqual('Should handle 0 correctly', 0, result)) {
        NAVLogTestFailed(1, itoa(0), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test maximum positive value (for 16-bit signed integer)
    NAVStackPushInteger(stack, 32767)
    result = NAVStackPopInteger(stack)

    if (!NAVAssertIntegerEqual('Should handle 32767 correctly', 32767, result)) {
        NAVLogTestFailed(2, itoa(32767), itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test negative values
    // NAVStackPushInteger(stack, abs_value(-1))
    // result = NAVStackPopInteger(stack)

    // if (!NAVAssertIntegerEqual('Should handle -1 correctly', abs_value(-1), result)) {
    //     NAVLogTestFailed(3, itoa(abs_value(-1)), itoa(result))
    // }
    // else {
    //     NAVLogTestPassed(3)
    // }

    // Test minimum negative value
    // NAVStackPushInteger(stack, -32768)
    // result = NAVStackPopInteger(stack)

    // if (!NAVAssertIntegerEqual('Should handle -32768 correctly', -32768, result)) {
    //     NAVLogTestFailed(4, itoa(-32768), itoa(result))
    // }
    // else {
    //     NAVLogTestPassed(4)
    // }
}

/**
 * Test multiple peek operations don't affect state
 */
define_function TestNAVStackStringMultiplePeeks() {
    stack_var _NAVStackString stack
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer x

    NAVLog("'***************** TestNAVStackStringMultiplePeeks *****************'")

    NAVStackInitString(stack, 5)
    NAVStackPushString(stack, 'PeekTest')

    // Perform 10 peeks
    for (x = 1; x <= 10; x++) {
        result = NAVStackPeekString(stack)
        if (!NAVAssertStringEqual("'Peek ', itoa(x), ' should return PeekTest'", 'PeekTest', result)) {
            NAVLogTestFailed(x, 'PeekTest', result)
            return
        }
    }

    NAVLogTestPassed(1)

    if (!NAVAssertIntegerEqual('Count should still be 1 after multiple peeks', 1, NAVStackStringGetCount(stack))) {
        NAVLogTestFailed(2, itoa(1), itoa(NAVStackStringGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test multiple peek operations don't affect state
 */
define_function TestNAVStackIntegerMultiplePeeks() {
    stack_var _NAVStackInteger stack
    stack_var integer result
    stack_var integer x

    NAVLog("'***************** TestNAVStackIntegerMultiplePeeks *****************'")

    NAVStackInitInteger(stack, 5)
    NAVStackPushInteger(stack, 555)

    // Perform 10 peeks
    for (x = 1; x <= 10; x++) {
        result = NAVStackPeekInteger(stack)
        if (!NAVAssertIntegerEqual("'Peek ', itoa(x), ' should return 555'", 555, result)) {
            NAVLogTestFailed(x, itoa(555), itoa(result))
            return
        }
    }

    NAVLogTestPassed(1)

    if (!NAVAssertIntegerEqual('Count should still be 1 after multiple peeks', 1, NAVStackIntegerGetCount(stack))) {
        NAVLogTestFailed(2, itoa(1), itoa(NAVStackIntegerGetCount(stack)))
    }
    else {
        NAVLogTestPassed(2)
    }
}
