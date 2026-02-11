PROGRAM_NAME='NAVBase64UrlRoundTrip'

#include 'NAVFoundation.Encoding.Base64.axi'

define_function TestNAVBase64UrlRoundTrip() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVBase64UrlRoundTrip')

    for (x = 1; x <= length_array(BASE64URL_TEST); x++) {
        stack_var char base64[NAV_MAX_BUFFER]
        stack_var char base64Url[NAV_MAX_BUFFER]
        stack_var char convertedUrl[NAV_MAX_BUFFER]
        stack_var char convertedBase64[NAV_MAX_BUFFER]
        stack_var char decodedFromBase64[NAV_MAX_BUFFER]
        stack_var char decodedFromUrl[NAV_MAX_BUFFER]

        // Encode to both formats
        base64 = NAVBase64Encode(BASE64URL_TEST[x])
        base64Url = NAVBase64UrlEncode(BASE64URL_TEST[x])

        // Convert Base64 to Base64Url
        convertedUrl = NAVBase64ToBase64Url(base64)

        // Convert back to Base64
        convertedBase64 = NAVBase64UrlToBase64(convertedUrl)

        // Decode both
        decodedFromBase64 = NAVBase64Decode(convertedBase64)
        decodedFromUrl = NAVBase64UrlDecode(convertedUrl)

        // Verify decoded values match original
        if (!NAVAssertStringEqual('Base64 round-trip should match original', BASE64URL_TEST[x], decodedFromBase64)) {
            NAVLogTestFailed(x, BASE64URL_TEST[x], decodedFromBase64)
            continue
        }

        if (!NAVAssertStringEqual('Base64Url round-trip should match original', BASE64URL_TEST[x], decodedFromUrl)) {
            NAVLogTestFailed(x, BASE64URL_TEST[x], decodedFromUrl)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVBase64UrlRoundTrip')
}
