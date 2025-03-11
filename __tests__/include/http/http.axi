#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Http.axi'

define_function RunHttpTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running HTTP Client Tests ====='")

    // URL parsing tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing URL parsing'")
    TestUrlParsing('https://example.com/path?query=value#fragment')
    TestUrlParsing('http://user:pass@localhost:8080/test')
    TestUrlParsing('http://192.168.1.100/api/v1/devices')

    // HTTP request building tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing request building'")
    TestRequestBuilding('GET', 'https://example.com/api', '', '')
    TestRequestBuilding('POST', 'https://example.com/api', '{"name":"test"}', 'application/json')

    // HTTP response parsing tests
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing response parsing'")
    TestResponseParsing()

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'All HTTP tests completed'")
}

// Test helper functions
define_function TestUrlParsing(char url[]) {
    stack_var NAVUrl parsedUrl

    parsedUrl = NAVParseUrl(url)

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'URL: ', url")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Scheme: ', parsedUrl.scheme")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Host: ', parsedUrl.host")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Port: ', itoa(parsedUrl.port)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Path: ', parsedUrl.path")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Query: ', parsedUrl.query")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Fragment: ', parsedUrl.fragment")

    if (length_string(parsedUrl.host)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'URL parsing test passed'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'URL parsing test failed'")
    }
}

define_function TestRequestBuilding(char method[], char url[], char body[], char contentType[]) {
    stack_var char request[4096]

    request = NAVBuildHttpRequest(method, url, body, contentType)

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Built request for ', method, ' ', url")

    if (length_string(request)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Request building test passed'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Request building test failed'")
    }
}

define_function TestResponseParsing() {
    stack_var char response[1024]
    stack_var NAVHttpResponse parsedResponse

    // Sample HTTP response
    response = 'HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 27

{"status":"success","id":123}'

    parsedResponse = NAVParseHttpResponse(response)

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Parsed response:'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Status code: ', itoa(parsedResponse.statusCode)")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Content type: ', parsedResponse.contentType")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Body: ', parsedResponse.body")

    if (parsedResponse.statusCode == 200) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Response parsing test passed'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Response parsing test failed'")
    }
}
