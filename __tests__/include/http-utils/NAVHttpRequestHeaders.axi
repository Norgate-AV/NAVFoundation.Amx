PROGRAM_NAME='HttpRequestHeaders'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

// Test vectors for NAVHttpRequestAddHeader
constant char REQUEST_ADD_HEADER_TEST[][2][2048] = {
    // Key, Value
    {'Content-Type', 'application/json'},
    {'Authorization', 'Bearer TOKEN123'},
    {'', 'value'},  // Empty key - should fail
    {'X-Empty-Header', ''},  // Empty value - should fail
    {'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', 'value'},  // Long key
    {'X-Long-Value', 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'},  // Long value
    {'X-Special-Key_123', 'test-value'},  // Special chars in key
    {'123', 'numeric-key'}  // Numeric key
}

constant char REQUEST_ADD_HEADER_EXPECTED[] = {
    true,   // Test 1: Normal header
    true,   // Test 2: Second header
    false,  // Test 3: Empty key should fail
    false,  // Test 4: Empty value should fail
    true,   // Test 5: Long key should succeed
    true,   // Test 6: Long value should succeed
    true,   // Test 7: Special chars should succeed
    true    // Test 8: Numeric key should succeed
}

// Test vectors for NAVHttpRequestUpdateHeader
constant char REQUEST_UPDATE_HEADER_TEST[][3][2048] = {
    // Key, Initial Value, New Value
    {'Content-Type', 'text/plain', 'application/json'},
    {'Authorization', 'Bearer OLD_TOKEN', 'Bearer NEW_TOKEN'},
    {'X-Non-Existent', '', 'value'},  // Non-existent key - should fail
    {'', 'value', 'new-value'},  // Empty key - should fail
    {'User-Agent', 'Old-Agent/1.0', 'New-Agent/2.0'},  // Normal update
    {'Content-Type', 'application/json', 'application/xml'},  // Update again
    {'X-Custom', 'old', 'new'}  // Custom header update
}

constant char REQUEST_UPDATE_HEADER_EXPECTED[] = {
    true,   // Test 1: Normal update
    true,   // Test 2: Authorization update
    false,  // Test 3: Non-existent key should fail
    false,  // Test 4: Empty key should fail
    true,   // Test 5: Normal update
    true,   // Test 6: Update again
    true    // Test 7: Custom header update
}

// Test vectors for NAVHttpHeaderHelpers
constant char HEADER_HELPER_TEST[][3][2048] = {
    // Operation, Key, Expected Value
    {'exists', 'Content-Type', '1'},  // Check if header exists
    {'value', 'Content-Type', 'application/json'},  // Get header value
    {'exists', 'Authorization', '1'},  // Check another header
    {'value', 'Authorization', 'Bearer TOKEN'},  // Get auth value
    {'exists', 'X-Missing', '0'},  // Non-existent header
    {'value', 'X-Custom', 'custom-value'},  // Custom header value
    {'value', 'X-Missing', ''},  // Missing header returns empty
    {'exists', 'X-Custom', '1'},  // Custom header exists
    {'exists', 'Host', '1'},  // Host header exists
    {'value', 'Host', 'example.com'}  // Host value
}

constant char HEADER_HELPER_SETUP[][2][2048] = {
    // Key, Value
    {'Content-Type', 'application/json'},
    {'Authorization', 'Bearer TOKEN'},
    {'X-Custom', 'custom-value'}
}

// Test vectors for NAVHttpResponseAddHeader
constant char RESPONSE_ADD_HEADER_TEST[][2][2048] = {
    // Key, Value
    {'Content-Type', 'application/json'},
    {'Content-Length', '1234'},
    {'', 'value'},  // Empty key - should fail
    {'X-Empty', ''}  // Empty value - should fail
}

constant char RESPONSE_ADD_HEADER_EXPECTED[] = {
    true,   // Test 1: Normal header
    true,   // Test 2: Content-Length
    false,  // Test 3: Empty key should fail
    false   // Test 4: Empty value should fail
}

// Test vectors for NAVHttpResponseUpdateHeader
constant char RESPONSE_UPDATE_HEADER_TEST[][3][2048] = {
    // Key, Initial Value, New Value
    {'Content-Type', 'text/plain', 'application/json'},
    {'X-NonExistent', '', 'value'},  // Non-existent key - should fail
    {'', 'value', 'new'}  // Empty key - should fail
}

constant char RESPONSE_UPDATE_HEADER_EXPECTED[] = {
    true,   // Test 1: Normal update
    false,  // Test 2: Non-existent key should fail
    false   // Test 3: Empty key should fail
}

// Test vectors for Header Edge Cases
constant char HEADER_EDGE_CASE_TEST[][2][2048] = {
    // Description, Test Data
    {'max-headers', 'Content-Type'},  // Test max headers limit
    {'case-sensitive-lookup', 'Content-Type'},  // Case sensitive lookup test
    {'update-preserves-order', 'Accept'},  // Update header preserves order
    {'get-first-header', 'Host'},  // Get header value for first header
    {'trailing-spaces', 'X-Trailing  '},  // Trailing spaces in value
    {'special-chars', 'X-Special!@#$%'}  // Special chars in value
}

constant char HEADER_EDGE_CASE_EXPECTED[] = {
    true,   // Test 1: Should handle max headers
    false,  // Test 2: Case-sensitive lookup should fail (content-type != Content-Type)
    true,   // Test 3: Update should preserve order
    true,   // Test 4: Should get first header
    true,   // Test 5: Trailing spaces should work
    true    // Test 6: Special chars should work
}

// Test vectors for Header Validation
constant char HEADER_VALIDATION_TEST[][3][2048] = {
    // Key, Value, Description
    {'Content-Type', 'application/json', 'valid'},
    {'Content-Length', '1234', 'valid number'},
    {'X-Custom', 'any-value-here', 'custom header'},
    {'Authorization', 'Bearer abc123', 'auth token'},
    {'Accept', '*/*', 'wildcard accept'},
    {'Cache-Control', 'no-cache, no-store, must-revalidate', 'complex value'},
    {'Set-Cookie', 'sessionId=abc123; Path=/; HttpOnly', 'cookie with semicolons'},
    {'User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', 'complex user agent'},
    {'X-Forwarded-For', '203.0.113.195, 70.41.3.18, 150.172.238.178', 'multiple IPs'}
}

constant char HEADER_VALIDATION_EXPECTED[] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true   // Test 9
}

define_function TestNAVHttpRequestAddHeader() {
    stack_var integer x
    stack_var integer initialHeaderCount

    NAVLogTestSuiteStart("'NAVHttpRequestAddHeader'")

    for (x = 1; x <= length_array(REQUEST_ADD_HEADER_TEST); x++) {
        stack_var _NAVHttpRequest request
        stack_var _NAVUrl url
        stack_var char result

        // Initialize a request (this adds Host header automatically)
        NAVParseUrl('http://example.com/test', url)
        NAVHttpRequestInit(request, 'GET', url, '')
        initialHeaderCount = request.Headers.Count

        result = NAVHttpRequestAddHeader(request,
                                         REQUEST_ADD_HEADER_TEST[x][1],
                                         REQUEST_ADD_HEADER_TEST[x][2])

        if (!NAVAssertBooleanEqual('Should return expected result',
                                   REQUEST_ADD_HEADER_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(REQUEST_ADD_HEADER_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify header count changed appropriately
        if (REQUEST_ADD_HEADER_EXPECTED[x]) {
            if (!NAVAssertIntegerEqual('Header count should increase',
                                      initialHeaderCount + 1,
                                      request.Headers.Count)) {
                NAVLogTestFailed(x, 'Count increased', "'Count: ', itoa(request.Headers.Count)")
                continue
            }

            // Verify the header was added correctly
            if (!NAVAssertStringEqual('Header key should match',
                                     REQUEST_ADD_HEADER_TEST[x][1],
                                     request.Headers.Headers[request.Headers.Count].Key)) {
                NAVLogTestFailed(x,
                                REQUEST_ADD_HEADER_TEST[x][1],
                                request.Headers.Headers[request.Headers.Count].Key)
                continue
            }

            if (!NAVAssertStringEqual('Header value should match',
                                     REQUEST_ADD_HEADER_TEST[x][2],
                                     request.Headers.Headers[request.Headers.Count].Value)) {
                NAVLogTestFailed(x,
                                REQUEST_ADD_HEADER_TEST[x][2],
                                request.Headers.Headers[request.Headers.Count].Value)
                continue
            }
        }
        else {
            // Failed operations should not change count
            if (!NAVAssertIntegerEqual('Header count should not change',
                                      initialHeaderCount,
                                      request.Headers.Count)) {
                NAVLogTestFailed(x, 'Count unchanged', "'Count: ', itoa(request.Headers.Count)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpRequestAddHeader'")
}


define_function TestNAVHttpRequestUpdateHeader() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpRequestUpdateHeader'")

    for (x = 1; x <= length_array(REQUEST_UPDATE_HEADER_TEST); x++) {
        stack_var _NAVHttpRequest request
        stack_var _NAVUrl url
        stack_var char result

        // Initialize request
        NAVParseUrl('http://example.com/test', url)
        NAVHttpRequestInit(request, 'GET', url, '')

        // Add initial header if key is not empty
        if (length_array(REQUEST_UPDATE_HEADER_TEST[x][1])) {
            NAVHttpRequestAddHeader(request,
                                   REQUEST_UPDATE_HEADER_TEST[x][1],
                                   REQUEST_UPDATE_HEADER_TEST[x][2])
        }

        // Try to update
        result = NAVHttpRequestUpdateHeader(request,
                                           REQUEST_UPDATE_HEADER_TEST[x][1],
                                           REQUEST_UPDATE_HEADER_TEST[x][3])

        if (!NAVAssertBooleanEqual('Should return expected result',
                                   REQUEST_UPDATE_HEADER_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(REQUEST_UPDATE_HEADER_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify value was updated if expected to succeed
        if (REQUEST_UPDATE_HEADER_EXPECTED[x]) {
            stack_var char value[2048]
            value = NAVHttpGetHeaderValue(request.Headers, REQUEST_UPDATE_HEADER_TEST[x][1])

            if (!NAVAssertStringEqual('Value should be updated',
                                     REQUEST_UPDATE_HEADER_TEST[x][3],
                                     value)) {
                NAVLogTestFailed(x, REQUEST_UPDATE_HEADER_TEST[x][3], value)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpRequestUpdateHeader'")
}


define_function TestNAVHttpHeaderHelpers() {
    stack_var integer x
    stack_var integer i
    stack_var _NAVHttpRequest request
    stack_var _NAVUrl url

    NAVLogTestSuiteStart("'NAVHttpHeaderHelpers'")

    // Setup: Initialize request and add test headers
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')

    for (i = 1; i <= length_array(HEADER_HELPER_SETUP); i++) {
        NAVHttpRequestAddHeader(request,
                               HEADER_HELPER_SETUP[i][1],
                               HEADER_HELPER_SETUP[i][2])
    }

    // Run tests
    for (x = 1; x <= length_array(HEADER_HELPER_TEST); x++) {
        stack_var char operation[50]
        stack_var char key[2048]
        stack_var char expectedValue[2048]
        stack_var char result[2048]

        operation = HEADER_HELPER_TEST[x][1]
        key = HEADER_HELPER_TEST[x][2]
        expectedValue = HEADER_HELPER_TEST[x][3]

        if (operation == 'exists') {
            stack_var char exists
            exists = NAVHttpHeaderKeyExists(request.Headers, key)

            if (!NAVAssertBooleanEqual('Header existence should match',
                                       atoi(expectedValue),
                                       exists)) {
                NAVLogTestFailed(x, expectedValue, NAVBooleanToString(exists))
                continue
            }
        }
        else if (operation == 'value') {
            result = NAVHttpGetHeaderValue(request.Headers, key)

            if (!NAVAssertStringEqual('Header value should match',
                                     expectedValue,
                                     result)) {
                NAVLogTestFailed(x, expectedValue, result)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpHeaderHelpers'")
}


define_function TestNAVHttpResponseAddHeader() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpResponseAddHeader'")

    for (x = 1; x <= length_array(RESPONSE_ADD_HEADER_TEST); x++) {
        stack_var _NAVHttpResponse response
        stack_var char result
        stack_var integer initialCount

        NAVHttpResponseInit(response)
        initialCount = response.Headers.Count

        result = NAVHttpResponseAddHeader(response,
                                          RESPONSE_ADD_HEADER_TEST[x][1],
                                          RESPONSE_ADD_HEADER_TEST[x][2])

        if (!NAVAssertBooleanEqual('Should return expected result',
                                   RESPONSE_ADD_HEADER_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(RESPONSE_ADD_HEADER_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (RESPONSE_ADD_HEADER_EXPECTED[x]) {
            if (!NAVAssertIntegerEqual('Header count should increase',
                                      initialCount + 1,
                                      response.Headers.Count)) {
                NAVLogTestFailed(x, 'Count increased', "'Count: ', itoa(response.Headers.Count)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpResponseAddHeader'")
}


define_function TestNAVHttpResponseUpdateHeader() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpResponseUpdateHeader'")

    for (x = 1; x <= length_array(RESPONSE_UPDATE_HEADER_TEST); x++) {
        stack_var _NAVHttpResponse response
        stack_var char result

        NAVHttpResponseInit(response)

        // Add initial header if key exists
        if (length_array(RESPONSE_UPDATE_HEADER_TEST[x][1])) {
            NAVHttpResponseAddHeader(response,
                                    RESPONSE_UPDATE_HEADER_TEST[x][1],
                                    RESPONSE_UPDATE_HEADER_TEST[x][2])
        }

        result = NAVHttpResponseUpdateHeader(response,
                                            RESPONSE_UPDATE_HEADER_TEST[x][1],
                                            RESPONSE_UPDATE_HEADER_TEST[x][3])

        if (!NAVAssertBooleanEqual('Should return expected result',
                                   RESPONSE_UPDATE_HEADER_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(RESPONSE_UPDATE_HEADER_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpResponseUpdateHeader'")
}


define_function TestNAVHttpHeaderEdgeCases() {
    stack_var _NAVHttpRequest request
    stack_var _NAVUrl url
    stack_var integer i
    stack_var integer maxHeaders
    stack_var char result
    stack_var char headerKeys[9][50]

    NAVLogTestSuiteStart("'NAVHttpHeaderEdgeCases'")

    // Test 1: Add maximum number of headers (10 max)
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')

    // List of valid headers to test the limit (Host is already added by Init)
    headerKeys[1] = 'Content-Type'
    headerKeys[2] = 'Accept'
    headerKeys[3] = 'Authorization'
    headerKeys[4] = 'Cache-Control'
    headerKeys[5] = 'User-Agent'
    headerKeys[6] = 'Referer'
    headerKeys[7] = 'Accept-Encoding'
    headerKeys[8] = 'Accept-Language'
    headerKeys[9] = 'Connection'

    maxHeaders = 10 - request.Headers.Count  // Account for auto-added headers

    // Try to add headers up to the limit
    for (i = 1; i <= maxHeaders && i <= 9; i++) {
        result = NAVHttpRequestAddHeader(request, headerKeys[i], "'Value-', itoa(i)")
        if (!result) {
            break
        }
    }

    if (request.Headers.Count > 10) {
        NAVLogTestFailed(1, 'Should not exceed 10 headers', "'Exceeded with ', itoa(request.Headers.Count), ' headers'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Case-sensitive header lookup (should NOT find with different case)
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')
    NAVHttpRequestAddHeader(request, 'Content-Type', 'application/json')

    // Try to find with different case (lookup is case-sensitive)
    if (NAVHttpFindHeader(request.Headers, 'content-type') == 0) {
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, 'Case-sensitive lookup expected', 'Found with different case')
    }

    // Test 3: Update header preserves order
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')
    NAVHttpRequestAddHeader(request, 'Content-Type', 'text/plain')
    NAVHttpRequestAddHeader(request, 'Accept', '*/*')
    NAVHttpRequestAddHeader(request, 'Authorization', 'Bearer TOKEN')

    i = NAVHttpFindHeader(request.Headers, 'Accept')
    NAVHttpRequestUpdateHeader(request, 'Accept', 'application/json')

    if (NAVHttpFindHeader(request.Headers, 'Accept') != i) {
        NAVLogTestFailed(3, 'Header position preserved', 'Position changed')
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test 4: Get header value for first header in list (Host header)
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')

    if (NAVHttpGetHeaderValue(request.Headers, 'Host') == 'example.com') {
        NAVLogTestPassed(4)
    }
    else {
        NAVLogTestFailed(4, 'example.com', NAVHttpGetHeaderValue(request.Headers, 'Host'))
    }

    // Test 5: Headers with trailing spaces in value
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')

    result = NAVHttpRequestAddHeader(request, 'X-Trailing', 'value  ')

    if (result == true) {
        NAVLogTestPassed(5)
    }
    else {
        NAVLogTestFailed(5, 'Should allow trailing spaces', 'Failed')
    }

    // Test 6: Headers with special characters in value
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')

    result = NAVHttpRequestAddHeader(request, 'X-Special', 'value!@#$%')

    if (result == true) {
        NAVLogTestPassed(6)
    }
    else {
        NAVLogTestFailed(6, 'Should allow special chars', 'Failed')
    }

    NAVLogTestSuiteEnd("'NAVHttpHeaderEdgeCases'")
}


define_function TestNAVHttpHeaderValidation() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpHeaderValidation'")

    for (x = 1; x <= length_array(HEADER_VALIDATION_TEST); x++) {
        stack_var _NAVHttpRequest request
        stack_var _NAVUrl url
        stack_var char result

        NAVParseUrl('http://example.com/test', url)
        NAVHttpRequestInit(request, 'GET', url, '')

        result = NAVHttpRequestAddHeader(request,
                                         HEADER_VALIDATION_TEST[x][1],
                                         HEADER_VALIDATION_TEST[x][2])

        if (!NAVAssertBooleanEqual('Should validate header',
                                   HEADER_VALIDATION_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(HEADER_VALIDATION_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpHeaderValidation'")
}
