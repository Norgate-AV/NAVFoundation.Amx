PROGRAM_NAME='NAVHttpBuildResponse'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

// Test vectors for NAVHttpBuildResponse
constant char BUILD_RESPONSE_TEST_STATUS_CODE[][10] = {
    '200',  // OK
    '404',  // Not Found
    '500',  // Server Error
    '201',  // Created
    '204',  // No Content
    '301',  // Moved Permanently
    '400',  // Bad Request
    '401',  // Unauthorized
    '403',  // Forbidden
    '503'   // Service Unavailable
}

constant char BUILD_RESPONSE_TEST_HEADERS[][][3][256] = {
    // Test 1: Basic response with Content-Type
    {{'Content-Type', 'application/json'}, {'', ''}},
    // Test 2: Response with multiple headers
    {{'Content-Type', 'text/html'}, {'Server', 'NAVFoundation/1.0'}},
    // Test 3: Response with Content-Length
    {{'Content-Type', 'text/plain'}, {'Content-Length', '13'}},
    // Test 4: Created with Location header
    {{'Location', '/api/resource/123'}, {'', ''}},
    // Test 5: No Content - no headers needed
    {{'', ''}, {'', ''}},
    // Test 6: Redirect with Location
    {{'Location', 'https://example.com/new-path'}, {'', ''}},
    // Test 7: Bad request with Content-Type
    {{'Content-Type', 'application/json'}, {'', ''}},
    // Test 8: Unauthorized with WWW-Authenticate
    {{'WWW-Authenticate', 'Bearer'}, {'', ''}},
    // Test 9: Multiple headers
    {{'Content-Type', 'application/json'}, {'Cache-Control', 'no-cache'}},
    // Test 10: Service unavailable with Retry-After
    {{'Retry-After', '120'}, {'', ''}}
}

constant char BUILD_RESPONSE_TEST_BODY[][256] = {
    '{"status":"ok"}',  // Test 1
    '<html></html>',    // Test 2
    'Hello, World!',    // Test 3
    '',                 // Test 4: Created - no body
    '',                 // Test 5: No Content - no body
    '',                 // Test 6: Redirect - no body
    '{"error":"bad"}',  // Test 7
    '',                 // Test 8: Unauthorized - no body
    '{"data":"test"}',  // Test 9
    ''                  // Test 10: Service unavailable - no body
}

constant char BUILD_RESPONSE_EXPECTED[] = {
    true,   // Test 1: Should build OK response
    true,   // Test 2: Should build with multiple headers
    true,   // Test 3: Should build with body
    true,   // Test 4: Should build Created response
    true,   // Test 5: Should build No Content
    true,   // Test 6: Should build redirect
    true,   // Test 7: Should build error response
    true,   // Test 8: Should build unauthorized
    true,   // Test 9: Should build with body and headers
    true    // Test 10: Should build service unavailable
}

define_function TestNAVHttpBuildResponse() {
    stack_var integer x
    stack_var integer h

    NAVLogTestSuiteStart("'NAVHttpBuildResponse'")

    for (x = 1; x <= length_array(BUILD_RESPONSE_TEST_STATUS_CODE); x++) {
        stack_var _NAVHttpResponse response
        stack_var char payload[NAV_MAX_BUFFER]
        stack_var char result

        // Initialize response
        NAVHttpResponseInit(response)
        response.Status.Code = atoi(BUILD_RESPONSE_TEST_STATUS_CODE[x])
        response.Status.Message = NAVHttpGetStatusMessage(response.Status.Code)
        response.Body = BUILD_RESPONSE_TEST_BODY[x]

        // Add headers if specified
        for (h = 1; h <= 2; h++) {
            if (length_array(BUILD_RESPONSE_TEST_HEADERS[x][h][1])) {
                NAVHttpResponseAddHeader(response,
                                        BUILD_RESPONSE_TEST_HEADERS[x][h][1],
                                        BUILD_RESPONSE_TEST_HEADERS[x][h][2])
            }
        }

        payload = NAVHttpBuildResponse(response)
        result = (length_array(payload) > 0)

        if (!NAVAssertBooleanEqual('Should build response',
                                   BUILD_RESPONSE_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(BUILD_RESPONSE_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (BUILD_RESPONSE_EXPECTED[x]) {
            // Verify response starts with HTTP version
            if (!NAVAssertTrue('Should start with HTTP/1.1',
                              NAVStartsWith(payload, 'HTTP/1.1'))) {
                NAVLogTestFailed(x, 'Starts with HTTP/1.1', 'Invalid start')
                continue
            }

            // Verify status code is in payload
            if (!NAVAssertTrue('Should contain status code',
                              NAVContains(payload, BUILD_RESPONSE_TEST_STATUS_CODE[x]))) {
                NAVLogTestFailed(x, 'Contains status code', 'Status code missing')
                continue
            }

            // Verify body is present if expected
            if (length_array(BUILD_RESPONSE_TEST_BODY[x])) {
                if (!NAVAssertTrue('Should contain body',
                                  NAVContains(payload, BUILD_RESPONSE_TEST_BODY[x]))) {
                    NAVLogTestFailed(x, 'Contains body', 'Body missing')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpBuildResponse'")
}
