PROGRAM_NAME='NAVBase64UrlEncode'

define_function TestNAVBase64UrlEncode() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVBase64UrlEncode')

    for (x = 1; x <= length_array(BASE64URL_TEST); x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVBase64UrlEncode(BASE64URL_TEST[x])

        if (!NAVAssertStringEqual('Should match expected Base64Url encoding (unpadded)', BASE64URL_EXPECTED_UNPADDED[x], result)) {
            NAVLogTestFailed(x, BASE64URL_EXPECTED_UNPADDED[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVBase64UrlEncode')
}