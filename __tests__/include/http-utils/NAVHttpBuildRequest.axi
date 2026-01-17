PROGRAM_NAME='NAVHttpBuildRequest'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'


define_function HttpExpectedRequestPayloadInit(char payload[][]) {
    payload[1] = "
        'GET / HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        'Content-Length: 16', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"key": "value"}'
    "
    payload[2] = "
        'GET /resource HTTP/1.1', NAV_CR, NAV_LF,
        'Host: www.example.org', NAV_CR, NAV_LF,
        'Content-Length: 17', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'User-Agent: MyHttpClient/1.0', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"param": "data"}'
    "
    payload[3] = "
        'GET /test?foo=bar&baz=123#frag-01 HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        'Content-Length: 14', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Accept: */*', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"foo": "bar"}'
    "
    payload[4] = "
        'GET /test-page HTTP/1.1', NAV_CR, NAV_LF,
        'Host: 127.0.0.1', NAV_CR, NAV_LF,
        'Content-Length: 16', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Accept: */*', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"test": "page"}'
    "
    payload[5] = "
        'GET /v1/users/123/posts HTTP/1.1', NAV_CR, NAV_LF,
        'Host: api.example.com', NAV_CR, NAV_LF,
        'Content-Length: 15', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Connection: keep-alive', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"user": "123"}'
    "
    payload[6] = "
        'GET /api/data?key=value&sort=desc&page=1 HTTP/1.1', NAV_CR, NAV_LF,
        'Host: localhost', NAV_CR, NAV_LF,
        'Content-Length: 16', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"key": "value"}'
    "
    payload[7] = "
        'GET /results?q=test%20query&lang=en HTTP/1.1', NAV_CR, NAV_LF,
        'Host: search.example.org', NAV_CR, NAV_LF,
        'Content-Length: 23', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Authorization: Bearer YOUR_TOKEN_HERE', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"query": "test query"}'
    "
    payload[8] = "
        'GET /path/to/resource HTTP/1.1', NAV_CR, NAV_LF,
        'Host: subdomain.example.com', NAV_CR, NAV_LF,
        'Content-Length: 32', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Authorization: Bearer YOUR_TOKEN_HERE', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"resource": "path/to/resource"}'
    "
    payload[9] = "
        'GET /products?category=electronics&brand=samsung&inStock=true HTTP/1.1', NAV_CR, NAV_LF,
        'Host: demo.example.net', NAV_CR, NAV_LF,
        'Content-Length: 27', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"category": "electronics"}'
    "
    payload[10] = "
        'GET /v2/users/123/posts/comments/456/replies?sort=newest&limit=50#comment-section HTTP/1.1', NAV_CR, NAV_LF,
        'Host: api.example.com', NAV_CR, NAV_LF,
        'Content-Length: 18', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"sort": "newest"}'
    "
    payload[11] = "
        'GET /very/deep/path/structure/file.html?param1=value1&param2=value2&param3=value3#section-2 HTTP/1.1', NAV_CR, NAV_LF,
        'Host: subdomain.test.example.com', NAV_CR, NAV_LF,
        'Content-Length: 20', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"param1": "value1"}'
    "
    payload[12] = "
        'GET /search?q=test+with+spaces&category=all&page=1&filter=active#results HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    payload[13] = "
        'GET /path?param=value#fragment?with?questions HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    payload[14] = "
        'GET /path#fragment&with&ampersands HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    payload[15] = "
        'GET /path/with/trailing/slash/ HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    // Valid edge case payloads (16-26)
    payload[16] = "
        'POST /api/create HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        'Content-Length: 30', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"name":"Test","data":"value"}'
    "
    payload[17] = "
        'PUT /api/update/123 HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        'Content-Length: 20', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"status":"updated"}'
    "
    payload[18] = "
        'DELETE /api/delete/456 HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    payload[19] = "
        'PATCH /api/patch HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        'Content-Length: 15', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"field":"new"}'
    "
    payload[20] = "
        'GET /very/long/path/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    payload[21] = "
        'POST /api HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        'Content-Length: 513', NAV_CR, NAV_LF,
        'Content-Type: application/json',NAV_CR, NAV_LF,
        'Authorization: Bearer AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"data":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"}'
    "
    payload[22] = "
        'POST /lowercase HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        'Content-Length: 15', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"test":"data"}'
    "
    payload[23] = "
        'GET /explicit-https-port HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    payload[24] = "
        'GET /api HTTP/1.1', NAV_CR, NAV_LF,
        'Host: 192.168.1.1', NAV_CR, NAV_LF,
        'Content-Length: 13', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"ip":"test"}'
    "
    payload[25] = "
        'GET / HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    payload[26] = "
        'POST /api/submit HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    // Invalid URL payloads (27-29) - empty since validation should fail
    payload[27] = ''
    payload[28] = ''
    payload[29] = ''
    // Test 36: IPv6 URL
    payload[36] = "
        'GET / HTTP/1.1', NAV_CR, NAV_LF,
        'Host: [::1:8080', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
}

define_function TestNAVHttpBuildRequest() {
    stack_var integer x
    stack_var char expectedRequestPayload[50][NAV_HTTP_MAX_REQUEST_LENGTH]

    NAVLogTestSuiteStart("'NAVHttpBuildRequest'")

    HttpExpectedRequestPayloadInit(expectedRequestPayload)

    for (x = 1; x <= length_array(HTTP_TEST); x++) {
        stack_var _NAVUrl url
        stack_var _NAVHttpRequest request
        stack_var char result
        stack_var char payload[NAV_HTTP_MAX_REQUEST_LENGTH]

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
            NAVLogTestFailed(x, 'Request initialization to succeeded', 'Request initialization failed')
            continue
        }

        if (!HTTP_EXPECTED_RESULT[x]) {
            // Expected to fail initialization, skip build test
            NAVLogTestPassed(x)
            continue
        }

        // Add headers if present
        if (length_array(HTTP_TEST_HEADERS[x]) > 0) {
            stack_var integer z

            for (z = 1; z <= length_array(HTTP_TEST_HEADERS[x]); z++) {
                if (!length_array(HTTP_TEST_HEADERS[x][z][1])) {
                    continue
                }

                NAVHttpRequestAddHeader(request, HTTP_TEST_HEADERS[x][z][1], HTTP_TEST_HEADERS[x][z][2])
            }
        }

        result = NAVHttpBuildRequest(request, payload)

        if (!NAVAssertBooleanEqual('Should build request successfully', HTTP_EXPECTED_BUILD_RESULT[x], result)) {
            NAVLogTestFailed(x, 'Build to succeed', 'Build failed')
            continue
        }

        if (!HTTP_EXPECTED_BUILD_RESULT[x]) {
            // Expected to fail, skip further checks
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertStringEqual('Should match expected payload', expectedRequestPayload[x], payload)) {
            NAVLogTestFailed(x, 'Payload to match', 'Payload mismatch')
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpParseResponse'")
}
