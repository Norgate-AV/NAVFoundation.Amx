PROGRAM_NAME='NAVHttpParseResponseBody'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

// Test vectors for NAVHttpParseResponseBody
constant long PARSE_RESPONSE_BODY_TEST_LENGTH[] = {
    15,   // Test 1: Simple JSON body
    13,   // Test 2: Plain text
    26,   // Test 3: HTML snippet
    0,    // Test 4: No body (Content-Length: 0)
    50,   // Test 5: Longer body
    5,    // Test 6: Short body
    100,  // Test 7: Body with extra data in buffer
    25,   // Test 8: Body with special characters
    200,  // Test 9: Large body
    15    // Test 10: Body followed by extra data
}

constant char PARSE_RESPONSE_BODY_TEST_BUFFER[][256] = {
    '{"status":"ok"}',  // Test 1: Exact match
    'Hello, World!',    // Test 2: Plain text
    '<html><body></body></html>', // Test 3: HTML
    '',                 // Test 4: Empty
    'This is a longer test body with more content here!', // Test 5
    'Short',            // Test 6
    'This is a test body with exactly 100 characters to ensure proper extraction happens correctly!!!!!!!EXTRA', // Test 7
    '{"key":"val!@#$%^&*(){}"}', // Test 8: Special chars
    'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',    // Test 9: 200 A's
    '{"status":"ok"}EXTRA_DATA_HERE' // Test 10: Extra data after body
}

constant char PARSE_RESPONSE_BODY_EXPECTED_BODY[][256] = {
    '{"status":"ok"}',  // Test 1
    'Hello, World!',    // Test 2
    '<html><body></body></html>', // Test 3
    '',                 // Test 4: Empty
    'This is a longer test body with more content here!', // Test 5
    'Short',            // Test 6
    'This is a test body with exactly 100 characters to ensure proper extraction happens correctly!!!!!!!', // Test 7: First 100 chars
    '{"key":"val!@#$%^&*(){}"}', // Test 8
    'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',  // Test 9: 200 A's
    '{"status":"ok"}'   // Test 10: Only the first 15 chars
}

constant char PARSE_RESPONSE_BODY_EXPECTED[] = {
    true,   // Test 1: Should parse
    true,   // Test 2: Should parse
    true,   // Test 3: Should parse
    true,   // Test 4: Empty body is valid
    true,   // Test 5: Should parse
    true,   // Test 6: Should parse
    true,   // Test 7: Should extract exactly 100
    true,   // Test 8: Should parse with special chars
    true,   // Test 9: Should parse large body
    true    // Test 10: Should extract only ContentLength bytes
}

define_function TestNAVHttpParseResponseBody() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpParseResponseBody'")

    for (x = 1; x <= length_array(PARSE_RESPONSE_BODY_TEST_LENGTH); x++) {
        stack_var _NAVHttpResponse response
        stack_var char buffer[NAV_MAX_BUFFER]
        stack_var char result

        // Initialize response with Content-Length
        NAVHttpResponseInit(response)
        response.ContentLength = PARSE_RESPONSE_BODY_TEST_LENGTH[x]

        // Set up buffer
        buffer = PARSE_RESPONSE_BODY_TEST_BUFFER[x]

        result = NAVHttpParseResponseBody(buffer, response)

        if (!NAVAssertBooleanEqual('Should parse body',
                                   PARSE_RESPONSE_BODY_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(PARSE_RESPONSE_BODY_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (PARSE_RESPONSE_BODY_EXPECTED[x]) {
            stack_var char expectedBody[256]

            // Verify body length matches ContentLength
            if (!NAVAssertLongEqual('Body length should match ContentLength',
                                   response.ContentLength,
                                   length_array(response.Body))) {
                NAVLogTestFailed(x,
                                itoa(response.ContentLength),
                                itoa(length_array(response.Body)))
                continue
            }

            // Verify content matches expected body
            expectedBody = PARSE_RESPONSE_BODY_EXPECTED_BODY[x]

            if (!NAVAssertStringEqual('Body content should match',
                                     expectedBody,
                                     response.Body)) {
                NAVLogTestFailed(x,
                                expectedBody,
                                response.Body)
                continue
            }

            // Verify buffer was consumed correctly (only ContentLength bytes removed)
            if (x == 7 || x == 10) {
                // Tests with extra data
                if (!NAVAssertTrue('Buffer should have remaining data',
                                  length_array(buffer) > 0)) {
                    NAVLogTestFailed(x, 'Has remaining data', 'Buffer empty')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpParseResponseBody'")
}
