PROGRAM_NAME='HttpResponseParse'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Tests for NAVHttpParseResponse function
 * These tests define the expected behavior for parsing HTTP responses
 */
define_function TestNAVHttpParseResponse() {
    stack_var _NAVHttpResponse response
    stack_var char buffer[2048]
    stack_var char result

    NAVLog("'***************** NAVHttpParseResponse *****************'")

    // Test 1: Parse simple 200 OK response
    buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
              'Content-Type: application/json', NAV_CR, NAV_LF,
              'Content-Length: 13', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF,
              '{"test":true}'"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result) {
        NAVLogTestFailed(1, 'Should parse simple 200 response', 'Parse failed')
        return
    }

    if (response.Status.Code != 200) {
        NAVLogTestFailed(1, '200', itoa(response.Status.Code))
        return
    }

    if (response.Status.Message != 'OK') {
        NAVLogTestFailed(1, 'OK', response.Status.Message)
        return
    }

    NAVLogTestPassed(1)

    // Test 2: Parse 404 Not Found response
    buffer = "'HTTP/1.1 404 Not Found', NAV_CR, NAV_LF,
              'Content-Type: text/plain', NAV_CR, NAV_LF,
              'Content-Length: 14', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF,
              'Page not found'"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result || response.Status.Code != 404) {
        NAVLogTestFailed(2, 'Should parse 404 response', 'Parse failed or wrong code')
        return
    }

    if (response.Status.Message != 'Not Found') {
        NAVLogTestFailed(2, 'Not Found', response.Status.Message)
        return
    }

    NAVLogTestPassed(2)

    // Test 3: Parse response with multiple headers
    buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
              'Content-Type: text/html', NAV_CR, NAV_LF,
              'Content-Length: 13', NAV_CR, NAV_LF,
              'Server: NAVFoundation/1.0', NAV_CR, NAV_LF,
              'Cache-Control: no-cache', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF,
              '<html></html>'"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result || response.Headers.Count < 4) {
        NAVLogTestFailed(3, 'Should parse multiple headers', "'Got ', itoa(response.Headers.Count), ' headers'")
        return
    }

    NAVLogTestPassed(3)

    // Test 4: Parse response with empty body
    buffer = "'HTTP/1.1 204 No Content', NAV_CR, NAV_LF,
              'Content-Length: 0', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result || response.Status.Code != 204) {
        NAVLogTestFailed(4, 'Should parse 204 with no body', 'Parse failed')
        return
    }

    if (length_array(response.Body) != 0) {
        NAVLogTestFailed(4, 'Empty body', "'Body length: ', itoa(length_array(response.Body))")
        return
    }

    NAVLogTestPassed(4)

    // Test 5: Parse response with JSON body
    buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
              'Content-Type: application/json', NAV_CR, NAV_LF,
              'Content-Length: 38', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF,
              '{"status":"success","data":{"id":123}}'"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result) {
        NAVLogTestFailed(5, 'Should parse JSON response', 'Parse failed')
        return
    }

    if (response.Body != '{"status":"success","data":{"id":123}}') {
        NAVLogTestFailed(5, 'JSON body preserved', response.Body)
        return
    }

    NAVLogTestPassed(5)

    // Test 6: Parse 500 Internal Server Error
    buffer = "'HTTP/1.1 500 Internal Server Error', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result || response.Status.Code != 500) {
        NAVLogTestFailed(6, 'Should parse 500 response', 'Parse failed')
        return
    }

    NAVLogTestPassed(6)

    // Test 7: Parse response with chunked transfer encoding (should handle or skip)
    buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
              'Transfer-Encoding: chunked', NAV_CR, NAV_LF,
              'Content-Length: 9', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF,
              'test body'"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    // At minimum, should parse status line
    if (!result || response.Status.Code != 200) {
        NAVLogTestFailed(7, 'Should handle chunked encoding', 'Parse failed')
        return
    }

    NAVLogTestPassed(7)

    {
        stack_var integer x

        buffer = ''

        for (x = 1; x <= 900; x++) {
            buffer = "buffer, 'A'"
        }
    }

    // Test 8: Parse response with extremely long header value (250+ chars)
    buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
              'Content-Length: 0', NAV_CR, NAV_LF,
              'X-Custom-Header: ', buffer, NAV_CR, NAV_LF,
              NAV_CR, NAV_LF"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result) {
        NAVLogTestFailed(8, 'Should handle long header values', 'Parse failed')
        return
    }

    if (length_array(NAVHttpGetHeaderValue(response.Headers, 'X-Custom-Header')) != 900) {
        NAVLogTestFailed(8, 'Long header preserved', "'Got ', itoa(length_array(NAVHttpGetHeaderValue(response.Headers, 'X-Custom-Header'))), ' chars'")
        return
    }

    NAVLogTestPassed(8)

    // Test 9: Parse response with no headers (just status line)
    buffer = "'HTTP/1.1 304 Not Modified', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result || response.Status.Code != 304) {
        NAVLogTestFailed(9, 'Should parse response with no headers', 'Parse failed')
        return
    }

    if (response.Headers.Count != 0) {
        NAVLogTestFailed(9, 'No headers', "'Got ', itoa(response.Headers.Count), ' headers'")
        return
    }

    NAVLogTestPassed(9)

    // Test 10: Parse response with header that has no value
    buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
              'Content-Length: 0', NAV_CR, NAV_LF,
              'X-Empty:', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result) {
        NAVLogTestFailed(10, 'Should handle empty header value', 'Parse failed')
        return
    }

    NAVLogTestPassed(10)

    // Test 11: Parse response with body larger than Content-Length (should only take specified bytes)
    buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
              'Content-Length: 10', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF,
              '1234567890EXTRADATA'"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result) {
        NAVLogTestFailed(11, 'Should extract exact Content-Length bytes', 'Parse failed')
        return
    }

    if (response.Body != '1234567890') {
        NAVLogTestFailed(11, '1234567890', response.Body)
        return
    }

    NAVLogTestPassed(11)

    // Test 12: Parse response with maximum number of headers
    buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
              'Header-1: Value1', NAV_CR, NAV_LF,
              'Header-2: Value2', NAV_CR, NAV_LF,
              'Header-3: Value3', NAV_CR, NAV_LF,
              'Header-4: Value4', NAV_CR, NAV_LF,
              'Header-5: Value5', NAV_CR, NAV_LF,
              'Header-6: Value6', NAV_CR, NAV_LF,
              'Header-7: Value7', NAV_CR, NAV_LF,
              'Header-8: Value8', NAV_CR, NAV_LF,
              'Header-9: Value9', NAV_CR, NAV_LF,
              'Header-10: Value10', NAV_CR, NAV_LF,
              'Header-11: Value11', NAV_CR, NAV_LF,
              'Header-12: Value12', NAV_CR, NAV_LF,
              'Header-13: Value13', NAV_CR, NAV_LF,
              'Header-14: Value14', NAV_CR, NAV_LF,
              'Header-15: Value15', NAV_CR, NAV_LF,
              'Header-16: Value16', NAV_CR, NAV_LF,
              'Header-17: Value17', NAV_CR, NAV_LF,
              'Header-18: Value18', NAV_CR, NAV_LF,
              'Header-19: Value19', NAV_CR, NAV_LF,
              'Content-Length: 0', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result) {
        NAVLogTestFailed(12, 'Should handle 20 headers', 'Parse failed')
        return
    }

    if (response.Headers.Count != 20) {
        NAVLogTestFailed(12, '20 headers', "'Got ', itoa(response.Headers.Count), ' headers'")
        return
    }

    NAVLogTestPassed(12)

    // Test 13: Parse response exceeding maximum headers (should stop at limit)
    buffer = "'HTTP/1.1 200 OK', NAV_CR, NAV_LF,
              'Header-1: Value1', NAV_CR, NAV_LF,
              'Header-2: Value2', NAV_CR, NAV_LF,
              'Header-3: Value3', NAV_CR, NAV_LF,
              'Header-4: Value4', NAV_CR, NAV_LF,
              'Header-5: Value5', NAV_CR, NAV_LF,
              'Header-6: Value6', NAV_CR, NAV_LF,
              'Header-7: Value7', NAV_CR, NAV_LF,
              'Header-8: Value8', NAV_CR, NAV_LF,
              'Header-9: Value9', NAV_CR, NAV_LF,
              'Header-10: Value10', NAV_CR, NAV_LF,
              'Header-11: Value11', NAV_CR, NAV_LF,
              'Header-12: Value12', NAV_CR, NAV_LF,
              'Header-13: Value13', NAV_CR, NAV_LF,
              'Header-14: Value14', NAV_CR, NAV_LF,
              'Header-15: Value15', NAV_CR, NAV_LF,
              'Header-16: Value16', NAV_CR, NAV_LF,
              'Header-17: Value17', NAV_CR, NAV_LF,
              'Header-18: Value18', NAV_CR, NAV_LF,
              'Header-19: Value19', NAV_CR, NAV_LF,
              'Header-20: Value20', NAV_CR, NAV_LF,
              'Header-21: Value21', NAV_CR, NAV_LF,
              'Content-Length: 0', NAV_CR, NAV_LF,
              NAV_CR, NAV_LF"

    NAVHttpResponseInit(response)
    result = NAVHttpParseResponse(buffer, response)

    if (!result) {
        NAVLogTestFailed(13, 'Should handle exceeding max headers', 'Parse failed')
        return
    }

    // Should stop at 20 headers (NAV_HTTP_MAX_HEADERS)
    if (response.Headers.Count > 20) {
        NAVLogTestFailed(13, 'Max 20 headers', "'Got ', itoa(response.Headers.Count), ' headers'")
        return
    }

    NAVLogTestPassed(13)
}

/**
 * Tests for NAVHttpParseStatusLine function
 * These tests focus on parsing just the status line
 */
define_function TestNAVHttpParseStatusLine() {
    stack_var _NAVHttpStatus status
    stack_var char statusLine[256]
    stack_var char result

    NAVLog("'***************** NAVHttpParseStatusLine *****************'")

    // Test 1: Parse standard 200 OK
    statusLine = 'HTTP/1.1 200 OK'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 200 || status.Message != 'OK') {
        NAVLogTestFailed(1, 'Parse 200 OK', "'Code: ', itoa(status.Code), ' Msg: ', status.Message")
        return
    }

    NAVLogTestPassed(1)

    // Test 2: Parse 404 Not Found
    statusLine = 'HTTP/1.1 404 Not Found'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 404 || status.Message != 'Not Found') {
        NAVLogTestFailed(2, 'Parse 404 Not Found', "'Code: ', itoa(status.Code), ' Msg: ', status.Message")
        return
    }

    NAVLogTestPassed(2)

    // Test 3: Parse 201 Created
    statusLine = 'HTTP/1.1 201 Created'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 201) {
        NAVLogTestFailed(3, 'Parse 201 Created', "'Code: ', itoa(status.Code)")
        return
    }

    NAVLogTestPassed(3)

    // Test 4: Parse 500 Internal Server Error
    statusLine = 'HTTP/1.1 500 Internal Server Error'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 500) {
        NAVLogTestFailed(4, 'Parse 500', "'Code: ', itoa(status.Code)")
        return
    }

    NAVLogTestPassed(4)

    // Test 5: Parse with HTTP/1.0
    statusLine = 'HTTP/1.0 200 OK'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 200) {
        NAVLogTestFailed(5, 'Parse HTTP/1.0 response', "'Code: ', itoa(status.Code)")
        return
    }

    NAVLogTestPassed(5)

    // Test 6: Invalid status line (should fail gracefully)
    statusLine = 'Invalid Status Line'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (result != false) {
        NAVLogTestFailed(6, 'Should fail on invalid status line', 'Parse succeeded unexpectedly')
        return
    }

    NAVLogTestPassed(6)

    // Test 7: Empty status line (should fail)
    statusLine = ''
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (result != false) {
        NAVLogTestFailed(7, 'Should fail on empty status line', 'Parse succeeded unexpectedly')
        return
    }

    NAVLogTestPassed(7)

    // Test 8: Status line with no message (just code)
    statusLine = 'HTTP/1.1 204'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 204) {
        NAVLogTestFailed(8, 'Should parse status without message', "'Code: ', itoa(status.Code)")
        return
    }

    if (length_array(status.Message) != 0) {
        NAVLogTestFailed(8, 'Empty message', status.Message)
        return
    }

    NAVLogTestPassed(8)

    // Test 9: Status line with extra spaces
    statusLine = 'HTTP/1.1  200  OK'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 200) {
        NAVLogTestFailed(9, 'Should handle extra spaces', "'Code: ', itoa(status.Code)")
        return
    }

    NAVLogTestPassed(9)

    // Test 10: Status line with very long message (200 chars)
    statusLine = "'HTTP/1.1 200 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'"
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 200) {
        NAVLogTestFailed(10, 'Should handle long message', "'Code: ', itoa(status.Code)")
        return
    }

    NAVLogTestPassed(10)

    // Test 11: Boundary status codes (100, 599)
    statusLine = 'HTTP/1.1 100 Continue'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 100) {
        NAVLogTestFailed(11, 'Should parse 100', "'Code: ', itoa(status.Code)")
        return
    }

    statusLine = 'HTTP/1.1 599 Custom'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 599) {
        NAVLogTestFailed(11, 'Should parse 599', "'Code: ', itoa(status.Code)")
        return
    }

    NAVLogTestPassed(11)

    // Test 12: Invalid status codes (out of range)
    statusLine = 'HTTP/1.1 99 Too Low'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (result != false) {
        NAVLogTestFailed(12, 'Should reject code < 100', 'Parse succeeded unexpectedly')
        return
    }

    statusLine = 'HTTP/1.1 600 Too High'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (result != false) {
        NAVLogTestFailed(12, 'Should reject code > 599', 'Parse succeeded unexpectedly')
        return
    }

    NAVLogTestPassed(12)

    // Test 13: Status line with message containing multiple spaces
    statusLine = 'HTTP/1.1 404 Not   Found   Here'
    NAVHttpStatusInit(status)
    result = NAVHttpParseStatusLine(statusLine, status)

    if (!result || status.Code != 404) {
        NAVLogTestFailed(13, 'Should parse message with spaces', "'Code: ', itoa(status.Code)")
        return
    }

    if (status.Message != 'Not   Found   Here') {
        NAVLogTestFailed(13, 'Preserve spaces in message', status.Message)
        return
    }

    NAVLogTestPassed(13)
}

/**
 * Tests for NAVHttpParseHeaders function
 * These tests focus on parsing header lines
 */
define_function TestNAVHttpParseHeaders() {
    stack_var _NAVHttpHeaderCollection headers
    stack_var char headerBlock[NAV_MAX_BUFFER]
    stack_var char result

    NAVLog("'***************** NAVHttpParseHeaders *****************'")

    // Test 1: Parse single header
    headerBlock = "'Content-Type: application/json', NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 1) {
        NAVLogTestFailed(1, 'Should parse single header', "'Count: ', itoa(headers.Count)")
        return
    }

    if (headers.Headers[1].Key != 'Content-Type' ||
        headers.Headers[1].Value != 'application/json') {
        NAVLogTestFailed(1, 'Content-Type: application/json',
                        "'', headers.Headers[1].Key, ': ', headers.Headers[1].Value")
        return
    }

    NAVLogTestPassed(1)

    // Test 2: Parse multiple headers
    headerBlock = "'Content-Type: text/html', NAV_CR, NAV_LF,
                   'Content-Length: 1234', NAV_CR, NAV_LF,
                   'Server: NAVFoundation', NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 3) {
        NAVLogTestFailed(2, 'Should parse 3 headers', "'Count: ', itoa(headers.Count)")
        return
    }

    NAVLogTestPassed(2)

    // Test 3: Parse header with spaces around colon
    headerBlock = "'Authorization : Bearer TOKEN123', NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 1) {
        NAVLogTestFailed(3, 'Should handle spaces around colon', "'Count: ', itoa(headers.Count)")
        return
    }

    NAVLogTestPassed(3)

    // Test 4: Parse header with value containing colons
    headerBlock = "'Date: Mon, 08 Oct 2025 13:30:00 GMT', NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 1) {
        NAVLogTestFailed(4, 'Should parse header with colons in value', "'Count: ', itoa(headers.Count)")
        return
    }

    if (headers.Headers[1].Value != 'Mon, 08 Oct 2025 13:30:00 GMT') {
        NAVLogTestFailed(4, 'Mon, 08 Oct 2025 13:30:00 GMT', headers.Headers[1].Value)
        return
    }

    NAVLogTestPassed(4)

    // Test 5: Empty header block
    headerBlock = ''
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 0) {
        NAVLogTestFailed(5, 'Should handle empty headers', "'Count: ', itoa(headers.Count)")
        return
    }

    NAVLogTestPassed(5)

    // Test 6: Header with empty value
    headerBlock = "'X-Empty-Value:', NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 1) {
        NAVLogTestFailed(6, 'Should parse header with empty value', "'Count: ', itoa(headers.Count)")
        return
    }

    if (length_array(headers.Headers[1].Value) != 0) {
        NAVLogTestFailed(6, 'Empty value', headers.Headers[1].Value)
        return
    }

    NAVLogTestPassed(6)

    // Test 7: Header with very long key (250 chars)
    headerBlock = "'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX: Value', NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 1) {
        NAVLogTestFailed(7, 'Should handle long header key', "'Count: ', itoa(headers.Count)")
        return
    }

    NAVLogTestPassed(7)

    // Test 8: Header with very long value (500 chars - testing buffer capacity)
    headerBlock = "'X-Long: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 1) {
        NAVLogTestFailed(8, 'Should handle long header value', "'Count: ', itoa(headers.Count)")
        return
    }

    NAVLogTestPassed(8)

    // Test 9: Multiple headers with varying whitespace
    headerBlock = "'Content-Type:application/json', NAV_CR, NAV_LF,
                   'Content-Length :123', NAV_CR, NAV_LF,
                   'Server: NAVFoundation', NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 3) {
        NAVLogTestFailed(9, 'Should handle varying whitespace', "'Count: ', itoa(headers.Count)")
        return
    }

    NAVLogTestPassed(9)

    // Test 10: Header with special characters in value
    headerBlock = "'X-Special: !@#$%^&*()_+-=[]{}|;:,.<>?', NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 1) {
        NAVLogTestFailed(10, 'Should handle special characters', "'Count: ', itoa(headers.Count)")
        return
    }

    NAVLogTestPassed(10)

    // Test 11: Header block with trailing CRLF
    headerBlock = "'Content-Type: text/html', NAV_CR, NAV_LF, NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    if (!result || headers.Count != 1) {
        NAVLogTestFailed(11, 'Should handle trailing CRLF', "'Count: ', itoa(headers.Count)")
        return
    }

    NAVLogTestPassed(11)

    // Test 12: Header block with blank lines in between
    headerBlock = "'Content-Type: text/html', NAV_CR, NAV_LF,
                   NAV_CR, NAV_LF,
                   'Content-Length: 100', NAV_CR, NAV_LF"
    headers.Count = 0
    result = NAVHttpParseHeaders(headerBlock, headers)

    // Should parse headers up to first blank line
    if (!result || headers.Count != 1) {
        NAVLogTestFailed(12, 'Should stop at blank line', "'Count: ', itoa(headers.Count)")
        return
    }

    NAVLogTestPassed(12)
}

