PROGRAM_NAME='NAVHttpValidateHeaders'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

// Test vectors for NAVHttpValidateHeaders
constant char VALIDATE_HEADERS_TEST_SETUP[][][3][256] = {
    // Test 1: Valid headers
    {
        {'Content-Type', 'application/json'},
        {'Host', 'example.com'},
        {'', ''}
    },
    // Test 2: Single valid header
    {{'User-Agent', 'Mozilla/5.0'}, {'', ''}, {'', ''}},
    // Test 3: Empty collection (valid - no headers is ok)
    {{'', ''}, {'', ''}, {'', ''}},
    // Test 4: Valid custom header
    {{'X-Custom-Header', 'value'}, {'', ''}, {'', ''}},
    // Test 5: Multiple standard headers
    {{'Accept', '*/*'}, {'Authorization', 'Bearer token'}, {'Content-Length', '123'}},
    // Test 6: Valid headers with long values
    {{'Set-Cookie', 'sessionId=abc123; Path=/; HttpOnly; Secure'}, {'', ''}, {'', ''}},
    // Test 7: Cache-Control header
    {{'Cache-Control', 'no-cache, no-store, must-revalidate'}, {'', ''}, {'', ''}},
    // Test 8: Accept-Encoding header
    {{'Accept-Encoding', 'gzip, deflate, br'}, {'', ''}, {'', ''}},
    // Test 9: Valid custom X-headers
    {{'X-H1', 'v1'}, {'X-H2', 'v2'}, {'X-H3', 'v3'}},
    // Test 10: Single header with special characters in value
    {{'X-Forwarded-For', '203.0.113.195, 70.41.3.18'}, {'', ''}, {'', ''}}
}

constant integer VALIDATE_HEADERS_TEST_COUNT[] = {
    2,   // Test 1: 2 headers
    1,   // Test 2: 1 header
    0,   // Test 3: 0 headers
    1,   // Test 4: 1 header
    3,   // Test 5: 3 headers
    1,   // Test 6: 1 header
    1,   // Test 7: 1 header
    1,   // Test 8: 1 header
    3,   // Test 9: 3 headers (could extend to 10)
    1    // Test 10: 1 header
}

constant char VALIDATE_HEADERS_EXPECTED[] = {
    true,   // Test 1: Valid headers
    true,   // Test 2: Single valid
    true,   // Test 3: Empty is valid
    true,   // Test 4: Custom header
    true,   // Test 5: Multiple standard
    true,   // Test 6: Long value
    true,   // Test 7: Cache-Control
    true,   // Test 8: Accept-Encoding
    true,   // Test 9: Multiple headers
    true    // Test 10: Special chars
}

define_function TestNAVHttpValidateHeaders() {
    stack_var integer x
    stack_var integer h

    NAVLogTestSuiteStart("'NAVHttpValidateHeaders'")

    for (x = 1; x <= length_array(VALIDATE_HEADERS_TEST_SETUP); x++) {
        stack_var _NAVHttpHeaderCollection headers
        stack_var char result

        // Build header collection
        headers.Count = 0
        for (h = 1; h <= 3; h++) {
            if (length_array(VALIDATE_HEADERS_TEST_SETUP[x][h][1])) {
                stack_var _NAVHttpHeader header
                NAVHttpHeaderInit(header,
                                 VALIDATE_HEADERS_TEST_SETUP[x][h][1],
                                 VALIDATE_HEADERS_TEST_SETUP[x][h][2])
                headers.Count++
                headers.Headers[headers.Count] = header
            }
        }

        // Verify count matches expected
        if (!NAVAssertIntegerEqual('Header count should match',
                                   VALIDATE_HEADERS_TEST_COUNT[x],
                                   headers.Count)) {
            NAVLogTestFailed(x,
                            "'Count: ', itoa(VALIDATE_HEADERS_TEST_COUNT[x])",
                            "'Count: ', itoa(headers.Count)")
            continue
        }

        result = NAVHttpValidateHeaders(headers)

        if (!NAVAssertBooleanEqual('Should validate headers correctly',
                                   VALIDATE_HEADERS_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(VALIDATE_HEADERS_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpValidateHeaders'")
}
