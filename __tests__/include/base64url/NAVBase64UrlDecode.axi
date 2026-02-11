PROGRAM_NAME='NAVBase64UrlDecode'

define_function TestNAVBase64UrlDecode() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVBase64UrlDecode - Unpadded')

    for (x = 1; x <= length_array(BASE64URL_TEST); x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVBase64UrlDecode(BASE64URL_EXPECTED_UNPADDED[x])

        if (!NAVAssertStringEqual('Should match expected Base64Url decoded value', BASE64URL_TEST[x], result)) {
            NAVLogTestFailed(x, BASE64URL_TEST[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVBase64UrlDecode - Unpadded')

    NAVLogTestSuiteStart('NAVBase64UrlDecode - Padded')

    for (x = 1; x <= length_array(BASE64URL_TEST); x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVBase64UrlDecode(BASE64URL_EXPECTED_PADDED[x])

        if (!NAVAssertStringEqual('Should match expected Base64Url decoded value', BASE64URL_TEST[x], result)) {
            NAVLogTestFailed(x, BASE64URL_TEST[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVBase64UrlDecode - Padded')
}