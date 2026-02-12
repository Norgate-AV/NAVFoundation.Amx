PROGRAM_NAME='NAVBase64UrlWhitespace'

define_function TestNAVBase64UrlWhitespace() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVBase64UrlWhitespace')

    for (x = 1; x <= length_array(BASE64URL_WHITESPACE_TESTS); x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVBase64UrlDecode(BASE64URL_WHITESPACE_TESTS[x])

        if (!NAVAssertStringEqual('Should decode correctly ignoring whitespace', BASE64URL_WHITESPACE_EXPECTED, result)) {
            NAVLogTestFailed(x, BASE64URL_WHITESPACE_EXPECTED, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVBase64UrlWhitespace')
}
