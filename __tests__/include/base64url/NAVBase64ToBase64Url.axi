PROGRAM_NAME='NAVBase64ToBase64Url'

define_function TestNAVBase64ToBase64Url() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVBase64ToBase64Url')

    for (x = 1; x <= length_array(BASE64_TO_URL_INPUT); x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVBase64ToBase64Url(BASE64_TO_URL_INPUT[x])

        if (!NAVAssertStringEqual('Should match expected Base64Url result', BASE64_TO_URL_EXPECTED[x], result)) {
            NAVLogTestFailed(x, BASE64_TO_URL_EXPECTED[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVBase64ToBase64Url')
}