PROGRAM_NAME='NAVFoundation.Testing'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_TESTING__
#DEFINE __NAV_FOUNDATION_TESTING__ 'NAVFoundation.Testing'

#include 'NAVFoundation.Core.axi'


/**
 * Log a test pass result.
 *
 * Outputs a standardized pass message to the NetLinx diagnostics log.
 * Used by test suites to report individual test success.
 *
 * @param test  The test number (typically 1-based)
 *
 * @example
 *   NAVLogTestPassed(1)
 *   // Output: "Test 1 passed"
 */
define_function NAVLogTestPassed(integer test) {
    NAVLog("'Test ', itoa(test), ' passed'")
}


/**
 * Log a test failure with expected vs actual values.
 *
 * Outputs a standardized failure message including what was expected
 * and what was actually received. Handles empty string comparisons
 * gracefully by showing them explicitly in the output.
 *
 * @param test      The test number (typically 1-based)
 * @param expected  The expected value as a string
 * @param result    The actual result value as a string
 *
 * @example
 *   NAVLogTestFailed(2, '42', '43')
 *   // Output: "Test 2 failed. Expected: "42", but got: "43"."
 *
 *   NAVLogTestFailed(3, 'true', '')
 *   // Output: "Test 3 failed. Expected: "true", but got: ""."
 *
 * @note If both expected and result are empty, the comparison is still
 *       shown to make the failure explicit
 */
define_function NAVLogTestFailed(integer test, char expected[], char result[]) {
    stack_var char message[NAV_MAX_BUFFER]

    message = "'Test ', itoa(test), ' failed'"

    // Show comparison if expected has content OR if result has content
    // This covers cases where:
    // - expected='abc', result='xyz' → Show both
    // - expected='abc', result='' → Show expected, got empty
    // - expected='', result='xyz' → Show expected empty, got xyz
    // - expected='', result='' → Show expected empty, got empty
    if (length_array(expected) || length_array(result)) {
        message = "message, '. Expected: "', expected, '"'"
        message = "message, ', but got: "', result, '".'"
    }

    NAVLog(message)
}


/**
 * Log the start of a named test suite.
 *
 * Outputs a prominent header marker indicating the beginning of a test suite.
 * Used to group related tests together in the diagnostics log output.
 *
 * @param suiteName  The name of the test suite (e.g., "JSMN", "StringUtils")
 *
 * @example
 *   NAVLogTestSuiteStart('JSMN Parser')
 *   // Output: "================= Starting Test Suite: JSMN Parser ================="
 *
 * @see NAVLogTestSuiteEnd
 */
define_function NAVLogTestSuiteStart(char suiteName[]) {
    NAVLog("'================= Starting Test Suite: ', suiteName, ' ================='")
}

/**
 * Log the end of a named test suite.
 *
 * Outputs a prominent footer marker indicating the completion of a test suite.
 * Should be called after all tests in the suite have completed.
 *
 * @param suiteName  The name of the test suite being completed
 *
 * @example
 *   NAVLogTestSuiteEnd('JSMN Parser')
 *   // Output: "================= Finished Test Suite: JSMN Parser ================="
 *
 * @see NAVLogTestSuiteStart
 */
define_function NAVLogTestSuiteEnd(char suiteName[]) {
    NAVLog("'================= Finished Test Suite: ', suiteName, ' ================='")
}

/**
 * Log the start of the overall test run.
 *
 * Outputs a prominent header marker indicating the beginning of all tests.
 * Should be called once at the start of the entire test execution, before
 * any test suites run.
 *
 * @example
 *   NAVLogTestStart()
 *   // Output: "================= Starting Tests ================="
 *
 * @see NAVLogTestEnd
 */
define_function NAVLogTestStart() {
    NAVLog("'================= Starting Tests ================='")
}

/**
 * Log the end of the overall test run.
 *
 * Outputs a prominent footer marker indicating the completion of all tests.
 * Should be called once at the end of the entire test execution, after
 * all test suites have completed.
 *
 * @example
 *   NAVLogTestEnd()
 *   // Output: "================= Finished Tests ================="
 *
 * @see NAVLogTestStart
 */
define_function NAVLogTestEnd() {
    NAVLog("'================= Finished Tests ================='")
}


#END_IF // __NAV_FOUNDATION_TESTING__
