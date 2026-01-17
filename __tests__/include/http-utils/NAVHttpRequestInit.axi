PROGRAM_NAME='NAVHttpRequestInit'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

define_function TestNAVHttpRequestInit() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpRequestInit'")

    for (x = 1; x <= length_array(HTTP_TEST); x++) {
        stack_var _NAVUrl url
        stack_var _NAVHttpRequest request
        stack_var char result

        result = NAVParseUrl(HTTP_TEST[x][2], url)

        if (!NAVAssertBooleanEqual('Should parse URL', HTTP_EXPECTED_URL_PARSE_RESULT[x], result)) {
            NAVLogTestFailed(x, 'Valid URL', 'Invalid URL')
            continue
        }

        if (!HTTP_EXPECTED_URL_PARSE_RESULT[x]) {
            // URL parsing failed, skip further checks
            NAVLogTestPassed(x)
            continue
        }

        result = NAVHttpRequestInit(request, HTTP_TEST[x][1], url, HTTP_TEST[x][3])

        if (!NAVAssertBooleanEqual('Should initialize request', HTTP_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(HTTP_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!HTTP_EXPECTED_RESULT[x]) {
            // Expected to fail, skip further checks
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertStringEqual('Should have correct method', HTTP_TEST[x][1], request.Method)) {
            NAVLogTestFailed(x, HTTP_TEST[x][1], request.Method)
            continue
        }

        if (!NAVAssertStringEqual('Should have correct host', HTTP_EXPECTED_HOST[x], request.Host)) {
            NAVLogTestFailed(x, HTTP_EXPECTED_HOST[x], request.Host)
            continue
        }

        if (!NAVAssertStringEqual('Should have correct path', HTTP_EXPECTED_PATH[x], request.Path)) {
            NAVLogTestFailed(x, HTTP_EXPECTED_PATH[x], request.Path)
            continue
        }

        if (!NAVAssertStringEqual('Should have correct body', HTTP_TEST[x][3], request.Body)) {
            NAVLogTestFailed(x, HTTP_TEST[x][3], request.Body)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpRequestInit'")
}
