PROGRAM_NAME='NAVBase64UrlErrorHandling'

define_function TestNAVBase64UrlErrorHandling() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVBase64UrlErrorHandling')

    // Error handling tests verify that invalid input is handled gracefully
    // without crashing. The function should return a result (even if empty)
    // rather than crash.
    for (x = 1; x <= length_array(BASE64URL_INVALID_TESTS); x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVBase64UrlDecode(BASE64URL_INVALID_TESTS[x])

        // Test passes if the function completes without crashing
        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVBase64UrlErrorHandling')
}
