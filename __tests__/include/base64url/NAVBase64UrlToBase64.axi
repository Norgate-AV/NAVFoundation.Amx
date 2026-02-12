PROGRAM_NAME='NAVBase64UrlToBase64'

define_function TestNAVBase64UrlToBase64() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVBase64UrlToBase64')

    for (x = 1; x <= length_array(BASE64_TO_URL_INPUT); x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVBase64UrlToBase64(BASE64_TO_URL_EXPECTED[x])

        if (!NAVAssertStringEqual('Should match expected Base64 result', BASE64_TO_URL_INPUT[x], result)) {
            NAVLogTestFailed(x, BASE64_TO_URL_INPUT[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVBase64UrlToBase64')
}