#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'

/**
 * Diagnostic tests for malformed URLs
 * This demonstrates what happens when URLs are missing slashes in the scheme delimiter
 */
define_function TestMalformedUrlDiagnostic() {
    stack_var _NAVUrl url
    stack_var integer testNum
    stack_var char success

    NAVLogTestSuiteStart('Malformed URL Diagnostic Tests')

    // Test 1: Correct URL - http://192.168.10.157:8000/configs
    testNum = 1
    success = NAVParseUrl('http://192.168.10.157:8000/configs', url)

    NAVErrorLog(NAV_LOG_LEVEL_INFO, "itoa(testNum), ': Correct URL: http://192.168.10.157:8000/configs'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'  Scheme: [', url.Scheme, ']'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'  Host: [', url.Host, ']'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'  Port: ', itoa(url.Port)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'  Path: [', url.Path, ']'")

    if (!NAVAssertStringEqual('Correct URL should have scheme=http', 'http', url.Scheme)) {
        NAVLogTestFailed(testNum, 'Expected scheme: http', "url.Scheme")
    }
    else if (!NAVAssertStringEqual('Correct URL should have host=192.168.10.157', '192.168.10.157', url.Host)) {
        NAVLogTestFailed(testNum, 'Expected host: 192.168.10.157', "url.Host")
    }
    else if (!NAVAssertIntegerEqual('Correct URL should have port=8000', 8000, url.Port)) {
        NAVLogTestFailed(testNum, 'Expected port: 8000', "itoa(url.Port)")
    }
    else if (!NAVAssertStringEqual('Correct URL should have path=/configs', '/configs', url.Path)) {
        NAVLogTestFailed(testNum, 'Expected path: /configs', "url.Path")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 2: Malformed URL - http:/192.168.10.157:8000/configs (only one slash)
    testNum = 2
    success = NAVParseUrl('http:/192.168.10.157:8000/configs', url)

    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "itoa(testNum), ': Malformed URL (one slash): http:/192.168.10.157:8000/configs'")
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  Scheme: [', url.Scheme, ']'")
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  Host: [', url.Host, ']'")
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  Port: ', itoa(url.Port)")
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  Path: [', url.Path, ']'")
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  ^^ This shows INCORRECT parsing due to missing slash'")

    // This will demonstrate the bug - it will parse incorrectly
    if (url.Scheme == '' && url.Host == 'http' && url.Port == 192) {
        NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  CONFIRMED: This URL is malformed and parsed incorrectly!'")
        NAVLogTestPassed(testNum)
    }
    else {
        NAVLogTestFailed(testNum, 'Expected malformed parsing', "'See log output'")
    }

    // Test 3: Malformed URL - http:192.168.10.157:8000/configs (no slashes)
    testNum = 3
    success = NAVParseUrl('http:192.168.10.157:8000/configs', url)

    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "itoa(testNum), ': Malformed URL (no slashes): http:192.168.10.157:8000/configs'")
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  Scheme: [', url.Scheme, ']'")
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  Host: [', url.Host, ']'")
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  Port: ', itoa(url.Port)")
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  Path: [', url.Path, ']'")
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  ^^ This shows INCORRECT parsing due to missing slashes'")

    // When there are no slashes, it treats everything as a relative path
    // The host becomes "http:192.168.10.157" (up to the next colon), port becomes 8000
    if (url.Scheme == '' && url.Host == 'http:192.168.10.157' && url.Port == 8000) {
        NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'  CONFIRMED: This URL is malformed and parsed incorrectly!'")
        NAVLogTestPassed(testNum)
    }
    else {
        NAVLogTestFailed(testNum, 'Expected malformed parsing', "'See log output'")
    }

    // Test 4: Another correct URL for comparison
    testNum = 4
    success = NAVParseUrl('http://example.com:8080/path', url)

    NAVErrorLog(NAV_LOG_LEVEL_INFO, "itoa(testNum), ': Correct URL: http://example.com:8080/path'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'  Scheme: [', url.Scheme, ']'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'  Host: [', url.Host, ']'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'  Port: ', itoa(url.Port)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'  Path: [', url.Path, ']'")

    if (!NAVAssertStringEqual('Correct URL should have scheme=http', 'http', url.Scheme)) {
        NAVLogTestFailed(testNum, 'Expected scheme: http', "url.Scheme")
    }
    else if (!NAVAssertStringEqual('Correct URL should have host=example.com', 'example.com', url.Host)) {
        NAVLogTestFailed(testNum, 'Expected host: example.com', "url.Host")
    }
    else if (!NAVAssertIntegerEqual('Correct URL should have port=8080', 8080, url.Port)) {
        NAVLogTestFailed(testNum, 'Expected port: 8080', "itoa(url.Port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'===================================================='")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'DIAGNOSIS: If you see incorrect parsing in your program,'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'check that your URL string includes BOTH slashes in ://'")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'===================================================='")
}
