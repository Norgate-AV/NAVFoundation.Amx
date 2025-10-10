/**
 * Test suite for URL validation (MODERATE approach).
 *
 * Tests validation features matching industry standards:
 * - JavaScript WHATWG URL API
 * - C# System.Uri
 *
 * Validation Rules:
 * 1. Port range: 0-65535 (per IETF RFC 6335)
 * 2. Scheme format: must start with ALPHA, contain only ALPHA/DIGIT/+/-/. (RFC 3986 Section 3.1)
 * 3. Invalid characters: no control chars (0x00-0x1F, 0x7F), no unencoded spaces
 */

#include 'NAVFoundation.Url.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

/**
 * Test data for URL validation.
 * These URLs should be REJECTED by NAVParseUrl() due to validation errors.
 *
 * NOTE: Control character tests (0x00-0x1F, 0x7F) are tested separately in
 * TestNAVUrlHasInvalidCharacters() because NetLinx doesn't allow mixing
 * hex and ASCII in constant string declarations.
 */
constant char URL_VALIDATION_INVALID_URLS[][256] = {
    // Port validation - invalid ports (1-7)
    'http://example.com:65536/',                            // 1: Port too large (max is 65535)
    'https://www.example.com:99999/path',                   // 2: Port way too large
    'http://example.com:-1/',                               // 3: Negative port
    'ftp://ftp.example.com:100000/file',                    // 4: Port overflow
    'http://192.168.1.1:70000/api',                         // 5: Port out of range
    'https://example.com:65536/path?query=1',               // 6: Port 65536 with query
    'http://[::1]:70000/',                                  // 7: IPv6 with invalid port

    // Scheme validation - invalid schemes (8-15)
    '123://example.com/',                                   // 8: Scheme starts with digit
    '1http://example.com/',                                 // 9: Scheme starts with digit
    'ht!tp://example.com/',                                 // 10: Scheme contains invalid char (!)
    'http_test://example.com/',                             // 11: Scheme contains underscore
    '-http://example.com/',                                 // 12: Scheme starts with hyphen
    '+http://example.com/',                                 // 13: Scheme starts with plus
    '.http://example.com/',                                 // 14: Scheme starts with period
    'h@ttp://example.com/',                                 // 15: Scheme contains @ symbol

    // Invalid characters - unencoded spaces (16-20)
    'http://example.com/path with spaces',                  // 16: Unencoded space in path
    'http://example.com/path to file.txt',                  // 17: Multiple unencoded spaces
    'http://example.com?key=value with space',              // 18: Unencoded space in query value
    'http://example.com?key name=value',                    // 19: Unencoded space in query key
    'http://example.com#fragment with space',               // 20: Unencoded space in fragment

    // Combined validation errors (21-22)
    '123://example.com:99999/',                             // 21: Invalid scheme + invalid port
    'http_test://example.com/path with space'               // 22: Invalid scheme + unencoded space
}

/**
 * Test data for URL validation.
 * These URLs should be ACCEPTED by NAVParseUrl() - they are valid.
 */
constant char URL_VALIDATION_VALID_URLS[][256] = {
    // Valid ports (1-6)
    'http://example.com:0/',                                // 1: Port 0 (system-assigned)
    'http://example.com:1/',                                // 2: Port 1 (minimum)
    'http://example.com:8080/',                             // 3: Port 8080 (common)
    'http://example.com:65535/',                            // 4: Port 65535 (maximum)
    'https://example.com:443/',                             // 5: HTTPS default port
    'http://example.com:3000/api',                          // 6: Node.js default port

    // Valid schemes (7-14)
    'http://example.com/',                                  // 7: Standard HTTP
    'https://example.com/',                                 // 8: Standard HTTPS
    'ftp://ftp.example.com/',                               // 9: FTP
    'file:///path/to/file',                                 // 10: File scheme
    'svn+ssh://example.com/repo',                           // 11: Scheme with plus
    'x-custom://example.com/',                              // 12: Scheme with hyphen
    'h323://example.com/',                                  // 13: Scheme with digits (not first)
    'http1.1://example.com/',                               // 14: Scheme with period and digit

    // Valid encoded characters (15-20)
    'http://example.com/path%20with%20spaces',              // 15: Properly encoded spaces
    'http://example.com/%2Fslash',                          // 16: Encoded slash
    'http://example.com?key=%20value',                      // 17: Encoded space in query
    'http://example.com#frag%20ment',                       // 18: Encoded space in fragment
    'http://example.com/~user/path',                        // 19: Tilde (unreserved, allowed)
    'http://example.com/path_%2Ffile',                      // 20: Mixed encoded/unencoded

    // Valid edge cases (21-25)
    'http://example.com/',                                  // 21: Minimal valid URL
    'http://192.168.1.1:8080/api?key=val#top',              // 22: All components
    'http://[2001:db8::1]:8080/',                           // 23: IPv6 with port
    'https://user:pass@example.com:443/secure',             // 24: Userinfo with port
    'http://example.com/path?a=1&b=2&c=3'                   // 25: Multiple query params
}

/**
 * Test NAVParseUrl with invalid URLs (should reject).
 */
define_function TestNAVParseUrlValidation_Invalid() {
    stack_var _NAVUrl url
    stack_var char result
    stack_var integer i
    stack_var integer testNum
    stack_var integer totalTests

    NAVLog("'***************** NAVParseUrl Validation - Invalid URLs (Should Reject) *****************'")

    totalTests = length_array(URL_VALIDATION_INVALID_URLS)

    for (i = 1; i <= totalTests; i++) {
        testNum = i

        result = NAVParseUrl(URL_VALIDATION_INVALID_URLS[i], url)

        if (!NAVAssertFalse("'URL should be rejected: ', URL_VALIDATION_INVALID_URLS[i]", result)) {
            NAVLogTestFailed(testNum, 'false (rejected)', 'true (accepted)')
        }
        else {
            NAVLogTestPassed(testNum)
        }
    }
}

/**
 * Test NAVParseUrl with valid URLs (should accept).
 */
define_function TestNAVParseUrlValidation_Valid() {
    stack_var _NAVUrl url
    stack_var char result
    stack_var integer i
    stack_var integer testNum
    stack_var integer totalTests

    NAVLog("'***************** NAVParseUrl Validation - Valid URLs (Should Accept) *****************'")

    totalTests = length_array(URL_VALIDATION_VALID_URLS)

    for (i = 1; i <= totalTests; i++) {
        testNum = i + 22  // Offset by number of invalid tests

        result = NAVParseUrl(URL_VALIDATION_VALID_URLS[i], url)

        if (!NAVAssertTrue("'URL should be accepted: ', URL_VALIDATION_VALID_URLS[i]", result)) {
            NAVLogTestFailed(testNum, 'true (accepted)', 'false (rejected)')
        }
        else {
            NAVLogTestPassed(testNum)
        }
    }
}

/**
 * Test NAVUrlIsValidPort helper function.
 */
define_function TestNAVUrlIsValidPort() {
    stack_var char result
    stack_var integer testNum

    NAVLog("'***************** NAVUrlIsValidPort - Port Range Validation *****************'")

    // Test 1: Port 0 (valid - system-assigned)
    testNum = 48
    result = NAVUrlIsValidPort(0)

    if (!NAVAssertTrue('Port 0 should be valid (system-assigned)', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 2: Port 1 (valid - minimum)
    testNum = 49
    result = NAVUrlIsValidPort(1)

    if (!NAVAssertTrue('Port 1 should be valid (minimum)', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 3: Port 65535 (valid - maximum)
    testNum = 50
    result = NAVUrlIsValidPort(65535)

    if (!NAVAssertTrue('Port 65535 should be valid (maximum)', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }
}

/**
 * Test NAVUrlIsValidScheme helper function.
 */
define_function TestNAVUrlIsValidScheme() {
    stack_var char result
    stack_var integer testNum

    NAVLog("'***************** NAVUrlIsValidScheme - Scheme Format Validation *****************'")

    // Test 1: Valid scheme - http
    testNum = 51
    result = NAVUrlIsValidScheme('http')

    if (!NAVAssertTrue('Scheme "http" should be valid', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 2: Valid scheme - https
    testNum = 52
    result = NAVUrlIsValidScheme('https')

    if (!NAVAssertTrue('Scheme "https" should be valid', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 3: Valid scheme - with plus (svn+ssh)
    testNum = 53
    result = NAVUrlIsValidScheme('svn+ssh')

    if (!NAVAssertTrue('Scheme "svn+ssh" should be valid', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 4: Valid scheme - with hyphen (x-custom)
    testNum = 54
    result = NAVUrlIsValidScheme('x-custom')

    if (!NAVAssertTrue('Scheme "x-custom" should be valid', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 5: Valid scheme - with period (git.protocol)
    testNum = 55
    result = NAVUrlIsValidScheme('git.protocol')

    if (!NAVAssertTrue('Scheme "git.protocol" should be valid', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 6: Invalid scheme - starts with digit (123)
    testNum = 56
    result = NAVUrlIsValidScheme('123')

    if (!NAVAssertFalse('Scheme "123" should be invalid (starts with digit)', result)) {
        NAVLogTestFailed(testNum, 'false', 'true')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 7: Invalid scheme - starts with digit (1http)
    testNum = 57
    result = NAVUrlIsValidScheme('1http')

    if (!NAVAssertFalse('Scheme "1http" should be invalid (starts with digit)', result)) {
        NAVLogTestFailed(testNum, 'false', 'true')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 8: Invalid scheme - contains exclamation (ht!tp)
    testNum = 55
    result = NAVUrlIsValidScheme('ht!tp')

    if (!NAVAssertFalse('Scheme "ht!tp" should be invalid (contains !)', result)) {
        NAVLogTestFailed(testNum, 'false', 'true')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 9: Invalid scheme - contains underscore (http_test)
    testNum = 56
    result = NAVUrlIsValidScheme('http_test')

    if (!NAVAssertFalse('Scheme "http_test" should be invalid (contains _)', result)) {
        NAVLogTestFailed(testNum, 'false', 'true')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 10: Invalid scheme - empty string
    testNum = 57
    result = NAVUrlIsValidScheme('')

    if (!NAVAssertFalse('Empty scheme should be invalid', result)) {
        NAVLogTestFailed(testNum, 'false', 'true')
    }
    else {
        NAVLogTestPassed(testNum)
    }
}

/**
 * Test NAVUrlHasInvalidCharacters helper function.
 */
define_function TestNAVUrlHasInvalidCharacters() {
    stack_var char result
    stack_var integer testNum

    NAVLog("'***************** NAVUrlHasInvalidCharacters - Character Validation *****************'")

    // Test 1: Valid - no invalid characters
    testNum = 58
    result = NAVUrlHasInvalidCharacters('http://example.com/path')

    if (!NAVAssertFalse('Standard URL should have no invalid characters', result)) {
        NAVLogTestFailed(testNum, 'false', 'true')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 2: Valid - encoded space is OK
    testNum = 59
    result = NAVUrlHasInvalidCharacters('http://example.com/path%20file')

    if (!NAVAssertFalse('Encoded space should be valid', result)) {
        NAVLogTestFailed(testNum, 'false', 'true')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 3: Invalid - unencoded space
    testNum = 60
    result = NAVUrlHasInvalidCharacters('http://example.com/path with space')

    if (!NAVAssertTrue('Unencoded space should be invalid', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 4: Invalid - control character 0x01
    testNum = 59
    result = NAVUrlHasInvalidCharacters("'http://example.com/',$01")

    if (!NAVAssertTrue('Control character 0x01 should be invalid', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 5: Invalid - DEL character 0x7F
    testNum = 60
    result = NAVUrlHasInvalidCharacters("'http://example.com/',$7F")

    if (!NAVAssertTrue('DEL character 0x7F should be invalid', result)) {
        NAVLogTestFailed(testNum, 'true', 'false')
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 6: Valid - tilde is allowed
    testNum = 61
    result = NAVUrlHasInvalidCharacters('http://example.com/~user')

    if (!NAVAssertFalse('Tilde should be valid', result)) {
        NAVLogTestFailed(testNum, 'false', 'true')
    }
    else {
        NAVLogTestPassed(testNum)
    }
}
