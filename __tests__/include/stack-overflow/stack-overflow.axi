PROGRAM_NAME='NAVStackOverflowTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

/**
 * Test Suite: Intentional Stack Overflow Tests
 *
 * Purpose: Trigger genuine stack overflow conditions to observe
 * what runtime errors NetLinx generates. This helps differentiate
 * between actual stack overflow and other runtime errors.
 *
 * WARNING: These tests are designed to cause errors/crashes.
 *
 * FINDINGS:
 * ======================
 * Genuine stack overflow in NetLinx - CONFIRMED WITH MULTIPLE TEST RUNS:
 *
 * Test Run 1: Reached depth 1825, then FATAL CRASH + REBOOT
 * Test Run 2: Reached depth 1825, then FATAL CRASH + REBOOT (reproducible)
 *
 * Stack overflow characteristics:
 * FATAL CRASH - NetLinx master goes completely offline and REBOOTS
 * NO RUNTIME ERRORS - Zero DoNumberExpression, GetNumber, or any errors
 * SILENT FAILURE - No warnings, no error messages before crash
 * High recursion tolerance: 1825+ levels consistently reached
 * Memory consumption: ~127KB per 5 recursion levels (large frames)
 * Steady memory decline: 340MB → 280MB over entire test run
 * Crash is sudden and complete - last log entry at depth 1825
 * System requires full reboot to recover
 */

DEFINE_VARIABLE

volatile integer stackOverflowDepth

/**
 * Recursive function with large stack frames
 * Allocates ~3KB per call to consume stack quickly
 */
define_function integer NAVStackOverflowLargeFrames(integer depth) {
    // Allocate large local arrays to consume stack quickly
    stack_var char bigArray1[1000]
    stack_var char bigArray2[1000]
    stack_var char bigArray3[1000]
    stack_var integer localVars[100]
    stack_var integer result

    stackOverflowDepth = depth

    if (depth % 5 == 0) {
        NAVLog("'[ StackOverflow Large ]: Recursion depth ', itoa(depth)")
    }

    // Fill arrays to prevent compiler optimization
    bigArray1[1] = type_cast(depth)
    bigArray2[1] = type_cast(depth)
    bigArray3[1] = type_cast(depth)
    localVars[1] = depth

    // Recurse until stack overflow
    result = NAVStackOverflowLargeFrames(depth + 1)

    return result + localVars[1]
}

/**
 * Recursive function with small stack frames
 * Minimal local variables to see maximum recursion depth
 */
define_function integer NAVStackOverflowSmallFrames(integer depth) {
    stack_var integer result

    if (depth % 100 == 0) {
        NAVLog("'[ StackOverflow Small ]: Recursion depth ', itoa(depth)")
    }

    stackOverflowDepth = depth

    // Recurse until stack overflow
    result = NAVStackOverflowSmallFrames(depth + 1)

    return result + depth
}

/**
 * Recursive function with medium stack frames
 * Simulates typical function call overhead
 */
define_function integer NAVStackOverflowMediumFrames(integer depth) {
    stack_var char buffer[256]
    stack_var integer vars[10]
    stack_var integer result

    if (depth % 10 == 0) {
        NAVLog("'[ StackOverflow Medium ]: Recursion depth ', itoa(depth)")
    }

    stackOverflowDepth = depth

    // Fill to prevent optimization
    buffer[1] = type_cast(depth)
    vars[1] = depth

    // Recurse until stack overflow
    result = NAVStackOverflowMediumFrames(depth + 1)

    return result + vars[1]
}

/**
 * Test: Stack overflow with large stack frames
 */
define_function char NAVTestStackOverflowLargeFrames() {
    NAVLog("'====== Test: Stack Overflow - Large Frames ======'")
    NAVLog("'INTENTIONAL ERROR TEST: Watch for runtime errors'")

    stackOverflowDepth = 0

    NAVStackOverflowLargeFrames(1)

    NAVLog("'Maximum depth reached: ', itoa(stackOverflowDepth)")
    NAVLogTestPassed(1)

    return true
}

/**
 * Test: Stack overflow with small stack frames
 */
define_function char NAVTestStackOverflowSmallFrames() {
    NAVLog("'====== Test: Stack Overflow - Small Frames ======'")
    NAVLog("'INTENTIONAL ERROR TEST: Watch for runtime errors'")

    stackOverflowDepth = 0

    NAVStackOverflowSmallFrames(1)

    NAVLog("'Maximum depth reached: ', itoa(stackOverflowDepth)")
    NAVLogTestPassed(2)

    return true
}

/**
 * Test: Stack overflow with medium stack frames
 */
define_function char NAVTestStackOverflowMediumFrames() {
    NAVLog("'====== Test: Stack Overflow - Medium Frames ======'")
    NAVLog("'INTENTIONAL ERROR TEST: Watch for runtime errors'")

    stackOverflowDepth = 0

    NAVStackOverflowMediumFrames(1)

    NAVLog("'Maximum depth reached: ', itoa(stackOverflowDepth)")
    NAVLogTestPassed(3)

    return true
}

/**
 * Main test runner
 */
define_function RunStackOverflowTests() {
    NAVLog("'***************** Stack Overflow Tests *****************'")
    NAVLog("'WARNING: These tests intentionally cause stack overflow'")
    NAVLog("'Purpose: Identify runtime error signatures for comparison'")
    NAVLog("'========================================================='")

    // Test 1: Large frames (should overflow quickly)
    NAVTestStackOverflowLargeFrames()

    NAVLog("'---'")

    // Test 2: Medium frames
    NAVTestStackOverflowMediumFrames()

    NAVLog("'---'")

    // Test 3: Small frames (should go deepest)
    NAVTestStackOverflowSmallFrames()
}