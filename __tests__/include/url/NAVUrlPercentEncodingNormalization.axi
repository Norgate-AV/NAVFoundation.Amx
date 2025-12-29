PROGRAM_NAME='NAVUrlPercentEncodingNormalization'

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

/**
 * Test suite for NAVUrlNormalizePercentEncoding function.
 * Tests RFC 3986 Section 6.2.2.3: Percent-Encoding Normalization
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_URL_PERCENT_ENCODING_NORMALIZATION__
#DEFINE __NAV_FOUNDATION_URL_PERCENT_ENCODING_NORMALIZATION__ 'NAVUrlPercentEncodingNormalization'

#include 'NAVFoundation.Url.axi'
#include 'NAVFoundation.Assert.axi'

/**
 * Test NAVUrlNormalizePercentEncoding function.
 *
 * RFC 3986 Section 6.2.2.3 states:
 * - Percent-encoding triplets should use uppercase hexadecimal digits
 * - Unreserved characters (ALPHA / DIGIT / "-" / "." / "_" / "~")
 *   should not be percent-encoded
 */
define_function TestNAVUrlNormalizePercentEncoding() {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer testNum

    NAVLog("'***************** NAVUrlNormalizePercentEncoding - RFC 3986 Section 6.2.2.3 *****************'")

    // Test 1: Lowercase hex digits should be converted to uppercase
    testNum = 1
    result = NAVUrlNormalizePercentEncoding('%2f')

    if (!NAVAssertStringEqual('Should convert lowercase hex to uppercase', '%2F', result)) {
        NAVLogTestFailed(testNum, '%2F', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 2: Multiple lowercase sequences
    testNum = 2
    result = NAVUrlNormalizePercentEncoding('path%2fto%2ffile')

    if (!NAVAssertStringEqual('Should convert all lowercase hex to uppercase', 'path%2Fto%2Ffile', result)) {
        NAVLogTestFailed(testNum, 'path%2Fto%2Ffile', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 3: Mixed case hex digits
    testNum = 3
    result = NAVUrlNormalizePercentEncoding('%2F%2f%3A%3a')

    if (!NAVAssertStringEqual('Should normalize mixed case hex', '%2F%2F%3A%3A', result)) {
        NAVLogTestFailed(testNum, '%2F%2F%3A%3A', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 4: Unreserved character - uppercase letter (A = %41)
    testNum = 4
    result = NAVUrlNormalizePercentEncoding('%41')

    if (!NAVAssertStringEqual('Should decode unreserved uppercase letter', 'A', result)) {
        NAVLogTestFailed(testNum, 'A', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 5: Unreserved character - lowercase letter (z = %7A)
    testNum = 5
    result = NAVUrlNormalizePercentEncoding('%7A')

    if (!NAVAssertStringEqual('Should decode unreserved lowercase letter', 'z', result)) {
        NAVLogTestFailed(testNum, 'z', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 6: Unreserved character - digit (5 = %35)
    testNum = 6
    result = NAVUrlNormalizePercentEncoding('%35')

    if (!NAVAssertStringEqual('Should decode unreserved digit', '5', result)) {
        NAVLogTestFailed(testNum, '5', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 7: Unreserved character - hyphen (- = %2D)
    testNum = 7
    result = NAVUrlNormalizePercentEncoding('%2D')

    if (!NAVAssertStringEqual('Should decode unreserved hyphen', '-', result)) {
        NAVLogTestFailed(testNum, '-', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 8: Unreserved character - period (. = %2E)
    testNum = 8
    result = NAVUrlNormalizePercentEncoding('%2E')

    if (!NAVAssertStringEqual('Should decode unreserved period', '.', result)) {
        NAVLogTestFailed(testNum, '.', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 9: Unreserved character - underscore (_ = %5F)
    testNum = 9
    result = NAVUrlNormalizePercentEncoding('%5F')

    if (!NAVAssertStringEqual('Should decode unreserved underscore', '_', result)) {
        NAVLogTestFailed(testNum, '_', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 10: Unreserved character - tilde (~ = %7E)
    testNum = 10
    result = NAVUrlNormalizePercentEncoding('%7E')

    if (!NAVAssertStringEqual('Should decode unreserved tilde', '~', result)) {
        NAVLogTestFailed(testNum, '~', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 11: Reserved character - space should remain encoded (space = %20)
    testNum = 11
    result = NAVUrlNormalizePercentEncoding('%20')

    if (!NAVAssertStringEqual('Should keep space encoded', '%20', result)) {
        NAVLogTestFailed(testNum, '%20', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 12: Reserved character - forward slash should remain encoded (/ = %2F)
    testNum = 12
    result = NAVUrlNormalizePercentEncoding('%2F')

    if (!NAVAssertStringEqual('Should keep forward slash encoded', '%2F', result)) {
        NAVLogTestFailed(testNum, '%2F', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 13: Reserved character - question mark should remain encoded (? = %3F)
    testNum = 13
    result = NAVUrlNormalizePercentEncoding('%3F')

    if (!NAVAssertStringEqual('Should keep question mark encoded', '%3F', result)) {
        NAVLogTestFailed(testNum, '%3F', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 14: Reserved character - ampersand should remain encoded (& = %26)
    testNum = 14
    result = NAVUrlNormalizePercentEncoding('%26')

    if (!NAVAssertStringEqual('Should keep ampersand encoded', '%26', result)) {
        NAVLogTestFailed(testNum, '%26', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 15: Reserved character - equals should remain encoded (= = %3D)
    testNum = 15
    result = NAVUrlNormalizePercentEncoding('%3D')

    if (!NAVAssertStringEqual('Should keep equals encoded', '%3D', result)) {
        NAVLogTestFailed(testNum, '%3D', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 16: Reserved character - hash should remain encoded (# = %23)
    testNum = 16
    result = NAVUrlNormalizePercentEncoding('%23')

    if (!NAVAssertStringEqual('Should keep hash encoded', '%23', result)) {
        NAVLogTestFailed(testNum, '%23', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 17: Reserved character - at sign should remain encoded (@ = %40)
    testNum = 17
    result = NAVUrlNormalizePercentEncoding('%40')

    if (!NAVAssertStringEqual('Should keep at sign encoded', '%40', result)) {
        NAVLogTestFailed(testNum, '%40', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 18: Reserved character - colon should remain encoded (: = %3A)
    testNum = 18
    result = NAVUrlNormalizePercentEncoding('%3A')

    if (!NAVAssertStringEqual('Should keep colon encoded', '%3A', result)) {
        NAVLogTestFailed(testNum, '%3A', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 19: Mix of unreserved and reserved characters
    testNum = 19
    result = NAVUrlNormalizePercentEncoding('%41%42%43%20%44%45%46')

    if (!NAVAssertStringEqual('Should decode unreserved, keep space encoded', 'ABC%20DEF', result)) {
        NAVLogTestFailed(testNum, 'ABC%20DEF', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 20: Complete word with unreserved characters
    testNum = 20
    result = NAVUrlNormalizePercentEncoding('%48%65%6C%6C%6F')

    if (!NAVAssertStringEqual('Should decode unreserved word', 'Hello', result)) {
        NAVLogTestFailed(testNum, 'Hello', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 21: URL path component with mix
    testNum = 21
    result = NAVUrlNormalizePercentEncoding('%7euser%2ffiles')

    if (!NAVAssertStringEqual('Should normalize path component', '~user%2Ffiles', result)) {
        NAVLogTestFailed(testNum, '~user%2Ffiles', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 22: Non-encoded characters should pass through
    testNum = 22
    result = NAVUrlNormalizePercentEncoding('hello-world_123.txt')

    if (!NAVAssertStringEqual('Should pass through non-encoded text', 'hello-world_123.txt', result)) {
        NAVLogTestFailed(testNum, 'hello-world_123.txt', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 23: Mix of encoded and non-encoded
    testNum = 23
    result = NAVUrlNormalizePercentEncoding('hello%20world%21')

    if (!NAVAssertStringEqual('Should handle mixed content', 'hello%20world%21', result)) {
        NAVLogTestFailed(testNum, 'hello%20world%21', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 24: Invalid percent sequence should pass through
    testNum = 24
    result = NAVUrlNormalizePercentEncoding('%GG')

    if (!NAVAssertStringEqual('Should pass through invalid sequence', '%GG', result)) {
        NAVLogTestFailed(testNum, '%GG', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 25: Incomplete percent sequence should pass through
    testNum = 25
    result = NAVUrlNormalizePercentEncoding('%2')

    if (!NAVAssertStringEqual('Should pass through incomplete sequence', '%2', result)) {
        NAVLogTestFailed(testNum, '%2', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 26: Percent at end should pass through
    testNum = 26
    result = NAVUrlNormalizePercentEncoding('test%')

    if (!NAVAssertStringEqual('Should pass through trailing percent', 'test%', result)) {
        NAVLogTestFailed(testNum, 'test%', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 27: Empty string
    testNum = 27
    result = NAVUrlNormalizePercentEncoding('')

    if (!NAVAssertStringEqual('Should handle empty string', '', result)) {
        NAVLogTestFailed(testNum, '', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 28: All unreserved characters A-Z
    testNum = 28
    result = NAVUrlNormalizePercentEncoding('%41%42%43%44%45%46%47%48%49%4A%4B%4C%4D%4E%4F%50%51%52%53%54%55%56%57%58%59%5A')

    if (!NAVAssertStringEqual('Should decode all uppercase letters', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', result)) {
        NAVLogTestFailed(testNum, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 29: All unreserved characters a-z
    testNum = 29
    result = NAVUrlNormalizePercentEncoding('%61%62%63%64%65%66%67%68%69%6A%6B%6C%6D%6E%6F%70%71%72%73%74%75%76%77%78%79%7A')

    if (!NAVAssertStringEqual('Should decode all lowercase letters', 'abcdefghijklmnopqrstuvwxyz', result)) {
        NAVLogTestFailed(testNum, 'abcdefghijklmnopqrstuvwxyz', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 30: All unreserved characters 0-9
    testNum = 30
    result = NAVUrlNormalizePercentEncoding('%30%31%32%33%34%35%36%37%38%39')

    if (!NAVAssertStringEqual('Should decode all digits', '0123456789', result)) {
        NAVLogTestFailed(testNum, '0123456789', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 31: All unreserved special characters
    testNum = 31
    result = NAVUrlNormalizePercentEncoding('%2D%2E%5F%7E')

    if (!NAVAssertStringEqual('Should decode all unreserved special chars', '-._~', result)) {
        NAVLogTestFailed(testNum, '-._~', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 32: Practical example - username with tilde (common in UNIX paths)
    testNum = 32
    result = NAVUrlNormalizePercentEncoding('/home/%7euser/documents')

    if (!NAVAssertStringEqual('Should normalize tilde in path', '/home/~user/documents', result)) {
        NAVLogTestFailed(testNum, '/home/~user/documents', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 33: Practical example - filename with unreserved chars
    testNum = 33
    result = NAVUrlNormalizePercentEncoding('%66%69%6C%65%5F%6E%61%6D%65%2E%74%78%74')

    if (!NAVAssertStringEqual('Should decode filename', 'file_name.txt', result)) {
        NAVLogTestFailed(testNum, 'file_name.txt', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 34: Practical example - query parameter with reserved chars
    testNum = 34
    result = NAVUrlNormalizePercentEncoding('%6E%61%6D%65%3D%76%61%6C%75%65')

    if (!NAVAssertStringEqual('Should normalize query param', 'name%3Dvalue', result)) {
        NAVLogTestFailed(testNum, 'name%3Dvalue', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 35: Case normalization with lowercase hex
    testNum = 35
    result = NAVUrlNormalizePercentEncoding('%7e%75%73%65%72')

    if (!NAVAssertStringEqual('Should decode and normalize', '~user', result)) {
        NAVLogTestFailed(testNum, '~user', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 36: Multiple percent signs
    testNum = 36
    result = NAVUrlNormalizePercentEncoding('%%')

    if (!NAVAssertStringEqual('Should handle multiple percent signs', '%%', result)) {
        NAVLogTestFailed(testNum, '%%', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 37: Percent sign followed by valid and invalid sequences
    testNum = 37
    result = NAVUrlNormalizePercentEncoding('%41%GG%42')

    if (!NAVAssertStringEqual('Should handle mix of valid and invalid', 'A%GGB', result)) {
        NAVLogTestFailed(testNum, 'A%GGB', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 38: UTF-8 encoded character (should remain encoded) - é = %C3%A9
    testNum = 38
    result = NAVUrlNormalizePercentEncoding('%C3%A9')

    if (!NAVAssertStringEqual('Should normalize UTF-8 hex to uppercase', '%C3%A9', result)) {
        NAVLogTestFailed(testNum, '%C3%A9', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 39: Complex real-world URL path
    testNum = 39
    result = NAVUrlNormalizePercentEncoding('%7euser%2fdocs%2ffile%5f123%2Etxt')

    if (!NAVAssertStringEqual('Should normalize complex path', '~user%2Fdocs%2Ffile_123.txt', result)) {
        NAVLogTestFailed(testNum, '~user%2Fdocs%2Ffile_123.txt', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 40: Query string with multiple parameters
    testNum = 40
    result = NAVUrlNormalizePercentEncoding('%6E%61%6D%65%3D%76%61%6C%75%65%26%69%64%3D%31%32%33')

    if (!NAVAssertStringEqual('Should normalize query string', 'name%3Dvalue%26id%3D123', result)) {
        NAVLogTestFailed(testNum, 'name%3Dvalue%26id%3D123', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }
}

#END_IF // __NAV_FOUNDATION_URL_PERCENT_ENCODING_NORMALIZATION__
