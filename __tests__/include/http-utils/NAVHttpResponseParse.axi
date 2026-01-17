PROGRAM_NAME='HttpResponseParse'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'


DEFINE_VARIABLE

// Test vectors for NAVHttpParseResponse (Headers Only)
volatile char RESPONSE_PARSE_TEST[11][NAV_MAX_BUFFER]

// Test vectors for NAVHttpParseStatusLine
volatile char STATUS_LINE_TEST[14][NAV_MAX_BUFFER]

// Test vectors for NAVHttpParseHeaders
volatile char HEADERS_PARSE_TEST[12][NAV_MAX_BUFFER]


define_function InitializeNAVHttpParseResponseTestData() {
    // Response buffers (headers only - body parsing is separate)
    set_length_array(RESPONSE_PARSE_TEST, 11)
    RESPONSE_PARSE_TEST[1] = "
        'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Content-Length: 13', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    RESPONSE_PARSE_TEST[2] = "
        'HTTP/1.1 404 Not Found', NAV_CR, NAV_LF,
        'Content-Type: text/plain', NAV_CR, NAV_LF,
        'Content-Length: 14', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    RESPONSE_PARSE_TEST[3] = "
        'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
        'Content-Type: text/html', NAV_CR, NAV_LF,
        'Content-Length: 13', NAV_CR, NAV_LF,
        'Server: NAVFoundation/1.0', NAV_CR, NAV_LF,
        'Cache-Control: no-cache', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    RESPONSE_PARSE_TEST[4] = "
        'HTTP/1.1 204 No Content', NAV_CR, NAV_LF,
        'Content-Length: 0', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    RESPONSE_PARSE_TEST[5] = "
        'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Content-Length: 38', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    RESPONSE_PARSE_TEST[6] = "
        'HTTP/1.1 500 Internal Server Error', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    RESPONSE_PARSE_TEST[7] = "
        'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
        'Transfer-Encoding: chunked', NAV_CR, NAV_LF,
        'Content-Length: 9', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    RESPONSE_PARSE_TEST[8] = "
        'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
        'Content-Length: 0', NAV_CR, NAV_LF,
        'X-Custom-Header: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    RESPONSE_PARSE_TEST[9] = "
        'HTTP/1.1 304 Not Modified', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    RESPONSE_PARSE_TEST[10] = "
        'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
        'Content-Length: 0', NAV_CR, NAV_LF,
        'X-Empty:', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    RESPONSE_PARSE_TEST[11] = "
        'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
        'Content-Length: 10', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "

    set_length_array(STATUS_LINE_TEST, 14)
    STATUS_LINE_TEST[1] = 'HTTP/1.1 200 OK'
    STATUS_LINE_TEST[2] = 'HTTP/1.1 404 Not Found'
    STATUS_LINE_TEST[3] = 'HTTP/1.0 500 Internal Server Error'
    STATUS_LINE_TEST[4] = 'HTTP/1.1 201 Created'
    STATUS_LINE_TEST[5] = 'HTTP/1.1 304 Not Modified'
    STATUS_LINE_TEST[6] = 'HTTP/1.1 Status Unknown'  // Invalid - status code not numeric
    STATUS_LINE_TEST[7] = ''  // Invalid - empty
    STATUS_LINE_TEST[8] = 'HTTP/1.1 200'  // Valid - no message
    STATUS_LINE_TEST[9] = "'HTTP/1.1', $09, '200', $09, 'OK'"  // Invalid - tabs instead of spaces
    STATUS_LINE_TEST[10] = 'HTTP/1.1 200 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'  // Long message
    STATUS_LINE_TEST[11] = 'HTTP/1.1 100 Continue'  // Boundary status code
    STATUS_LINE_TEST[12] = 'HTTP/1.1 599 Custom'  // High boundary
    STATUS_LINE_TEST[13] = 'HTTP/1.1 99 Too Low'  // Invalid - too low
    STATUS_LINE_TEST[14] = 'HTTP/1.1 600 Too High'  // Invalid - too high

    set_length_array(HEADERS_PARSE_TEST, 12)
    HEADERS_PARSE_TEST[1] = "'Content-Type: application/json', NAV_CR, NAV_LF"
    HEADERS_PARSE_TEST[2] = "
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Content-Length: 123', NAV_CR, NAV_LF
    "
    HEADERS_PARSE_TEST[3] = "'X-Custom-Header: custom-value', NAV_CR, NAV_LF"
    HEADERS_PARSE_TEST[4] = "''"  // Empty headers
    HEADERS_PARSE_TEST[5] = "'Content-Type:application/json', NAV_CR, NAV_LF"  // No space after colon
    HEADERS_PARSE_TEST[6] = "'Content-Type: ', NAV_CR, NAV_LF"  // Empty value
    HEADERS_PARSE_TEST[7] = "
        'X-Header-1: value1', NAV_CR, NAV_LF,
        'X-Header-2: value2', NAV_CR, NAV_LF,
        'X-Header-3: value3', NAV_CR, NAV_LF,
        'X-Header-4: value4', NAV_CR, NAV_LF,
        'X-Header-5: value5', NAV_CR, NAV_LF
    "  // Multiple headers
    HEADERS_PARSE_TEST[8] = "'Authorization: Bearer token:with:colons', NAV_CR, NAV_LF"  // Colons in value
    HEADERS_PARSE_TEST[9] = "'   Content-Type   :   application/json   ', NAV_CR, NAV_LF"  // Whitespace
    HEADERS_PARSE_TEST[10] = "'Set-Cookie: sessionId=abc123; Path=/; HttpOnly', NAV_CR, NAV_LF"  // Semicolons in value
    HEADERS_PARSE_TEST[11] = "'content-type: application/json', NAV_CR, NAV_LF"  // Lowercase key
    HEADERS_PARSE_TEST[12] = "'X-Header', NAV_CR, NAV_LF"  // No colon - should be skipped
}


DEFINE_CONSTANT

constant integer RESPONSE_PARSE_EXPECTED_CODE[] = {
    200,  // Test 1: 200 OK
    404,  // Test 2: 404 Not Found
    200,  // Test 3: 200 with multiple headers
    204,  // Test 4: 204 No Content
    200,  // Test 5: 200 with JSON
    500,  // Test 6: 500 Error
    200,  // Test 7: 200 with chunked encoding
    200,  // Test 8: 200 with long header
    304,  // Test 9: 304 Not Modified
    200,  // Test 10: 200 with empty header value
    200   // Test 11: 200 for body test
}

constant char RESPONSE_PARSE_EXPECTED_RESULT[] = {
    true,   // Test 1
    true,   // Test 2
    true,   // Test 3
    true,   // Test 4
    true,   // Test 5
    true,   // Test 6
    true,   // Test 7
    true,   // Test 8
    true,   // Test 9
    true,   // Test 10
    true    // Test 11
}

constant long RESPONSE_PARSE_EXPECTED_CONTENT_LENGTH[] = {
    13,   // Test 1
    14,   // Test 2
    13,   // Test 3
    0,    // Test 4
    38,   // Test 5
    0,    // Test 6
    9,    // Test 7
    0,    // Test 8
    0,    // Test 9
    0,    // Test 10
    10    // Test 11
}

constant integer RESPONSE_PARSE_EXPECTED_HEADER_COUNT[] = {
    2,    // Test 1: Content-Type, Content-Length
    2,    // Test 2: Content-Type, Content-Length
    4,    // Test 3: Multiple headers
    1,    // Test 4: Content-Length only
    2,    // Test 5: Content-Type, Content-Length
    0,    // Test 6: No headers
    2,    // Test 7: Transfer-Encoding, Content-Length
    2,    // Test 8: Content-Length, X-Custom-Header
    0,    // Test 9: No headers
    2,    // Test 10: Content-Length, X-Empty
    1     // Test 11: Content-Length only
}

constant integer STATUS_LINE_EXPECTED_CODE[] = {
    200,  // Test 1
    404,  // Test 2
    500,  // Test 3
    201,  // Test 4
    304,  // Test 5
    0,    // Test 6: Invalid
    0,    // Test 7: Invalid
    200,  // Test 8
    0,    // Test 9: Invalid
    200,  // Test 10
    100,  // Test 11
    599,  // Test 12
    0,    // Test 13: Invalid
    0     // Test 14: Invalid
}

constant char STATUS_LINE_EXPECTED_MESSAGE[][200] = {
    'OK',
    'Not Found',
    'Internal Server Error',
    'Created',
    'Not Modified',
    '',  // Invalid
    '',  // Invalid
    '',  // No message
    '',  // Invalid
    'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
    'Continue',
    'Custom',
    '',  // Invalid
    ''   // Invalid
}

constant char STATUS_LINE_EXPECTED_RESULT[] = {
    true,   // Test 1
    true,   // Test 2
    true,   // Test 3
    true,   // Test 4
    true,   // Test 5
    false,  // Test 6: Invalid
    false,  // Test 7: Invalid
    true,   // Test 8
    false,  // Test 9: Invalid
    true,   // Test 10
    true,   // Test 11
    true,   // Test 12
    false,  // Test 13: Invalid
    false   // Test 14: Invalid
}

constant integer HEADERS_PARSE_EXPECTED_COUNT[] = {
    1,   // Test 1
    2,   // Test 2
    1,   // Test 3
    0,   // Test 4
    1,   // Test 5
    1,   // Test 6: Empty value should be stored
    5,   // Test 7
    1,   // Test 8
    1,   // Test 9
    1,   // Test 10
    1,   // Test 11
    0    // Test 12: No colon - skipped
}

constant char HEADERS_PARSE_EXPECTED_RESULT[] = {
    true,   // Test 1
    true,   // Test 2
    true,   // Test 3
    true,   // Test 4: Empty is valid
    true,   // Test 5
    true,   // Test 6
    true,   // Test 7
    true,   // Test 8
    true,   // Test 9
    true,   // Test 10
    true,   // Test 11
    true    // Test 12: Parse succeeds but skips invalid line
}


define_function TestNAVHttpParseResponse() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpParseResponse'")

    InitializeNAVHttpParseResponseTestData()

    for (x = 1; x <= length_array(RESPONSE_PARSE_TEST); x++) {
        stack_var _NAVHttpResponse response
        stack_var char result

        NAVHttpResponseInit(response)
        result = NAVHttpParseResponse(RESPONSE_PARSE_TEST[x], response)

        if (!NAVAssertBooleanEqual('Should parse response',
                                   RESPONSE_PARSE_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(RESPONSE_PARSE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (!RESPONSE_PARSE_EXPECTED_RESULT[x]) {
            NAVLogTestPassed(x)
            continue
        }

        // Verify status code
        if (!NAVAssertIntegerEqual('Status code should match',
                                   RESPONSE_PARSE_EXPECTED_CODE[x],
                                   response.Status.Code)) {
            NAVLogTestFailed(x,
                            "itoa(RESPONSE_PARSE_EXPECTED_CODE[x])",
                            "itoa(response.Status.Code)")
            continue
        }

        // Verify content length
        if (!NAVAssertLongEqual('Content-Length should match',
                               RESPONSE_PARSE_EXPECTED_CONTENT_LENGTH[x],
                               response.ContentLength)) {
            NAVLogTestFailed(x,
                            "itoa(RESPONSE_PARSE_EXPECTED_CONTENT_LENGTH[x])",
                            "itoa(response.ContentLength)")
            continue
        }

        // Verify header count (at minimum)
        if (response.Headers.Count < RESPONSE_PARSE_EXPECTED_HEADER_COUNT[x]) {
            NAVLogTestFailed(x,
                            "'At least ', itoa(RESPONSE_PARSE_EXPECTED_HEADER_COUNT[x]), ' headers'",
                            "'Got ', itoa(response.Headers.Count)")
            continue
        }

        // Special test for Test 5 - parse body separately
        if (x == 5) {
            stack_var char bodyData[NAV_MAX_BUFFER]
            bodyData = '{"status":"success","data":{"id":123}}'

            result = NAVHttpParseResponseBody(bodyData, response)

            if (!NAVAssertBooleanEqual('Should parse body', true, result)) {
                NAVLogTestFailed(x, 'Body parse success', 'Body parse failed')
                continue
            }

            if (!NAVAssertStringEqual('Body should match',
                                     '{"status":"success","data":{"id":123}}',
                                     response.Body)) {
                NAVLogTestFailed(x, 'JSON body preserved', response.Body)
                continue
            }
        }

        // Special test for Test 11 - parse body with extra data
        if (x == 11) {
            stack_var char bodyData[NAV_MAX_BUFFER]
            bodyData = '1234567890EXTRADATA'

            result = NAVHttpParseResponseBody(bodyData, response)

            if (!NAVAssertBooleanEqual('Should parse body', true, result)) {
                NAVLogTestFailed(x, 'Body parse success', 'Body parse failed')
                continue
            }

            if (!NAVAssertStringEqual('Should extract exact Content-Length bytes',
                                     '1234567890',
                                     response.Body)) {
                NAVLogTestFailed(x, '1234567890', response.Body)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpParseResponse'")
}


define_function TestNAVHttpParseStatusLine() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpParseStatusLine'")

    InitializeNAVHttpParseResponseTestData()

    for (x = 1; x <= length_array(STATUS_LINE_TEST); x++) {
        stack_var _NAVHttpStatus status
        stack_var char result

        NAVHttpStatusInit(status)
        result = NAVHttpParseStatusLine(STATUS_LINE_TEST[x], status)

        if (!NAVAssertBooleanEqual('Should return expected result',
                                   STATUS_LINE_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(STATUS_LINE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (!STATUS_LINE_EXPECTED_RESULT[x]) {
            NAVLogTestPassed(x)
            continue
        }

        // Verify status code
        if (!NAVAssertIntegerEqual('Status code should match',
                                   STATUS_LINE_EXPECTED_CODE[x],
                                   status.Code)) {
            NAVLogTestFailed(x,
                            "itoa(STATUS_LINE_EXPECTED_CODE[x])",
                            "itoa(status.Code)")
            continue
        }

        // Verify status message
        if (!NAVAssertStringEqual('Status message should match',
                                 STATUS_LINE_EXPECTED_MESSAGE[x],
                                 status.Message)) {
            NAVLogTestFailed(x,
                            STATUS_LINE_EXPECTED_MESSAGE[x],
                            status.Message)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpParseStatusLine'")
}


define_function TestNAVHttpParseHeaders() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpParseHeaders'")

    InitializeNAVHttpParseResponseTestData()

    for (x = 1; x <= length_array(HEADERS_PARSE_TEST); x++) {
        stack_var _NAVHttpHeaderCollection headers
        stack_var char result

        headers.Count = 0
        result = NAVHttpParseHeaders(HEADERS_PARSE_TEST[x], headers)

        if (!NAVAssertBooleanEqual('Should parse headers',
                                   HEADERS_PARSE_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(HEADERS_PARSE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify header count
        if (!NAVAssertIntegerEqual('Header count should match',
                                   HEADERS_PARSE_EXPECTED_COUNT[x],
                                   headers.Count)) {
            NAVLogTestFailed(x,
                            "itoa(HEADERS_PARSE_EXPECTED_COUNT[x])",
                            "'Got ', itoa(headers.Count)")
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpParseHeaders'")
}

