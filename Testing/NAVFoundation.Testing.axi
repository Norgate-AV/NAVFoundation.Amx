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
 * @function NAVLogTestPassed
 * @public
 * @description Logs a test passed message.
 *
 * @param {integer} test - The test number
 *
 * @example
 * NAVLogTestPassed(1)
 * // Output: "Test 1 passed"
 */
define_function NAVLogTestPassed(integer test) {
    NAVLog("'Test ', itoa(test), ' passed'")
}


/**
 * @function NAVLogTestFailed
 * @public
 * @description Logs a test failed message with expected and actual values.
 *
 * @param {integer} test - The test number
 * @param {char[]} expected - The expected value
 * @param {char[]} result - The actual result value
 *
 * @example
 * NAVLogTestFailed(2, '42', '43')
 * // Output: "Test 2 failed. Expected: "42", but got: "43"."
 *
 * @note If both expected and result are empty strings, comparison details are still shown
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


#END_IF // __NAV_FOUNDATION_TESTING__
