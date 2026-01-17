PROGRAM_NAME='NAVHttpInferContentType'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

// Test vectors for NAVHttpInferContentType
constant char INFER_CONTENT_TYPE_TEST[][512] = {
    '{"name":"test","value":123}',  // Test 1: JSON object
    '[1,2,3,4,5]',                  // Test 2: JSON array
    '{"users":[{"id":1}]}',         // Test 3: Complex JSON
    '[]',                           // Test 4: Empty JSON array
    '{}',                           // Test 5: Empty JSON object
    '<?xml version="1.0"?>',        // Test 6: XML
    '<html><body>Hello</body></html>', // Test 7: HTML (partial match)
    'Hello, World!',                // Test 8: Plain text
    '<!DOCTYPE html>',              // Test 9: Plain text (no <html> tag)
    'true',                         // Test 10: Plain text (not JSON)
    '{"incomplete"',                // Test 11: Incomplete JSON (should be plain text)
    '<xml>test</xml>',              // Test 12: Plain text (no <?xml)
    '  {"name":"test"}  ',          // Test 13: JSON with whitespace
    '',                             // Test 14: Empty string
    'Just some text'                // Test 15: Plain text
}

constant char INFER_CONTENT_TYPE_EXPECTED[][50] = {
    'application/json',    // Test 1
    'application/json',    // Test 2
    'application/json',    // Test 3
    'application/json',    // Test 4
    'application/json',    // Test 5
    'text/xml',           // Test 6
    'text/html',          // Test 7: HTML tag detected
    'text/plain',         // Test 8
    'text/plain',         // Test 9
    'text/plain',         // Test 10
    'text/plain',         // Test 11
    'text/plain',         // Test 12
    'text/plain',         // Test 13: Leading whitespace prevents detection
    'text/plain',         // Test 14: Empty defaults to plain
    'text/plain'          // Test 15
}

define_function TestNAVHttpInferContentType() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpInferContentType'")

    for (x = 1; x <= length_array(INFER_CONTENT_TYPE_TEST); x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVHttpInferContentType(INFER_CONTENT_TYPE_TEST[x])

        if (!NAVAssertStringEqual('Should infer correct content type',
                                  INFER_CONTENT_TYPE_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            INFER_CONTENT_TYPE_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpInferContentType'")
}
