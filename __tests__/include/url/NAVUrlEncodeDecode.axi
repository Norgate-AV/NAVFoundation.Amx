PROGRAM_NAME='NAVUrlEncodeDecode'

/**
 * Test cases for NAVUrlEncode and NAVUrlDecode functions
 *
 * Tests RFC 3986 percent-encoding compliance
 */

#IF_NOT_DEFINED __NAV_URL_ENCODE_DECODE_TESTS__
#DEFINE __NAV_URL_ENCODE_DECODE_TESTS__ 'NAVUrlEncodeDecodeTests'


// Test data for encoding tests
DEFINE_CONSTANT

// Test strings to encode
constant char URL_ENCODE_TEST_INPUT[30][100] = {
    // Basic tests (1-5)
    'hello world',              // Test 1: Space
    'user@example.com',         // Test 2: @ symbol
    'path/to/file',             // Test 3: Slashes
    'key=value',                // Test 4: Equals
    'query?param',              // Test 5: Question mark

    // Special characters (6-15)
    'a&b',                      // Test 6: Ampersand
    'price:$100',               // Test 7: Colon and dollar
    'test#fragment',            // Test 8: Hash
    '50%',                      // Test 9: Percent sign
    'a+b',                      // Test 10: Plus sign
    'a,b,c',                    // Test 11: Commas
    'a;b;c',                    // Test 12: Semicolons
    'a<b>c',                    // Test 13: Angle brackets
    'a[b]c',                    // Test 14: Square brackets
    'a{b}c',                    // Test 15: Curly brackets

    // Unreserved characters (16-20) - should NOT be encoded
    'hello-world',              // Test 16: Hyphen (unreserved)
    'file.txt',                 // Test 17: Period (unreserved)
    'user_name',                // Test 18: Underscore (unreserved)
    'path~temp',                // Test 19: Tilde (unreserved)
    'Test123',                  // Test 20: Alphanumeric (unreserved)

    // Complex strings (21-25)
    'hello world & goodbye',    // Test 21: Multiple special chars
    'http://example.com/path',  // Test 22: Full URL
    'Program Files App',        // Test 23: Space in path
    'name="John Doe"',          // Test 24: Quotes
    'a | b',                    // Test 25: Pipe

    // Edge cases (26-30)
    '',                         // Test 26: Empty string
    ' ',                        // Test 27: Single space
    '   ',                      // Test 28: Multiple spaces
    'test',                     // Test 29: No encoding needed
    '!!!'                       // Test 30: Multiple special chars
}

// Expected encoded results
constant char URL_ENCODE_TEST_EXPECTED[30][200] = {
    // Basic tests (1-5)
    'hello%20world',
    'user%40example.com',
    'path%2Fto%2Ffile',
    'key%3Dvalue',
    'query%3Fparam',

    // Special characters (6-15)
    'a%26b',
    'price%3A%24100',
    'test%23fragment',
    '50%25',
    'a%2Bb',
    'a%2Cb%2Cc',
    'a%3Bb%3Bc',
    'a%3Cb%3Ec',
    'a%5Bb%5Dc',
    'a%7Bb%7Dc',

    // Unreserved characters (16-20) - should NOT be encoded
    'hello-world',
    'file.txt',
    'user_name',
    'path~temp',
    'Test123',

    // Complex strings (21-25)
    'hello%20world%20%26%20goodbye',
    'http%3A%2F%2Fexample.com%2Fpath',
    'Program%20Files%20App',
    'name%3D%22John%20Doe%22',
    'a%20%7C%20b',

    // Edge cases (26-30)
    '',
    '%20',
    '%20%20%20',
    'test',
    '%21%21%21'
}


// Test data for decoding tests
constant char URL_DECODE_TEST_INPUT[25][200] = {
    // Basic decoding (1-5)
    'hello%20world',            // Test 1: Decode space
    'user%40example.com',       // Test 2: Decode @
    'path%2Fto%2Ffile',        // Test 3: Decode slashes
    'key%3Dvalue',              // Test 4: Decode equals
    'query%3Fparam',            // Test 5: Decode question mark

    // Multiple encodings (6-10)
    'a%26b%26c',                // Test 6: Multiple ampersands
    'test%20%20test',           // Test 7: Multiple spaces
    'a%2Cb%2Cc%2Cd',           // Test 8: Multiple commas
    'http%3A%2F%2Fexample.com', // Test 9: URL components
    'name%3D%22value%22',       // Test 10: Complex string

    // Mixed encoded/unencoded (11-15)
    'hello%20world',            // Test 11: Partial encoding
    'test%2Fpath',              // Test 12: Partial encoding
    'user%40domain.com',        // Test 13: Partial encoding
    'a%20b%20c',                // Test 14: Multiple encoded
    'test%20%2B%20more',        // Test 15: Mixed operators

    // Case insensitivity (16-18)
    'hello%2Fworld',            // Test 16: Uppercase hex
    'hello%2fworld',            // Test 17: Lowercase hex
    'test%3A%3a',               // Test 18: Mixed case

    // Edge cases (19-25)
    '',                         // Test 19: Empty string
    'test',                     // Test 20: No encoding
    '%20',                      // Test 21: Just encoded space
    'test%',                    // Test 22: Invalid (incomplete)
    'test%2',                   // Test 23: Invalid (incomplete)
    'test%GG',                  // Test 24: Invalid (bad hex)
    'test%20test'               // Test 25: Valid with text
}

// Expected decoded results
constant char URL_DECODE_TEST_EXPECTED[25][100] = {
    // Basic decoding (1-5)
    'hello world',
    'user@example.com',
    'path/to/file',
    'key=value',
    'query?param',

    // Multiple encodings (6-10)
    'a&b&c',
    'test  test',
    'a,b,c,d',
    'http://example.com',
    'name="value"',

    // Mixed encoded/unencoded (11-15)
    'hello world',
    'test/path',
    'user@domain.com',
    'a b c',
    'test + more',

    // Case insensitivity (16-18)
    'hello/world',
    'hello/world',
    'test::',

    // Edge cases (19-25)
    '',
    'test',
    ' ',
    'test%',                    // Invalid - left as-is
    'test%2',                   // Invalid - left as-is
    'test%GG',                  // Invalid - left as-is
    'test test'
}


// Round-trip test data (encode then decode should return original)
constant char URL_ROUNDTRIP_TEST[15][100] = {
    'hello world',
    'user@example.com',
    'a=b&c=d',
    'path/to/file.txt',
    'test#fragment',
    'price: $50.00',
    'hello-world_123',
    'test~temp',
    'a & b | c',
    'query?key=value',
    'path-to-file',
    'a,b,c;d;e',
    '"quoted text"',
    '<html>tag</html>',
    '[array]{object}'
}


/**
 * Test NAVUrlEncode function
 */
define_function TestNAVUrlEncode() {
    stack_var integer x
    stack_var char encoded[NAV_MAX_BUFFER]
    stack_var integer totalTests

    NAVLog("'***************** NAVUrlEncode *****************'")

    totalTests = 30

    for (x = 1; x <= totalTests; x++) {
        encoded = NAVUrlEncode(URL_ENCODE_TEST_INPUT[x])

        if (encoded == URL_ENCODE_TEST_EXPECTED[x]) {
            NAVLogTestPassed(x)
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                       "'Test ', itoa(x), ' failed. Input: [', URL_ENCODE_TEST_INPUT[x], ']'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                       "'Expected: [', URL_ENCODE_TEST_EXPECTED[x], ']'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                       "'Got:      [', encoded, ']'")
            NAVLogTestFailed(x, URL_ENCODE_TEST_EXPECTED[x], encoded)
        }
    }
}


/**
 * Test NAVUrlDecode function
 */
define_function TestNAVUrlDecode() {
    stack_var integer x
    stack_var char decoded[NAV_MAX_BUFFER]
    stack_var integer totalTests

    NAVLog("'***************** NAVUrlDecode *****************'")

    totalTests = 25

    for (x = 1; x <= totalTests; x++) {
        decoded = NAVUrlDecode(URL_DECODE_TEST_INPUT[x])

        if (decoded == URL_DECODE_TEST_EXPECTED[x]) {
            NAVLogTestPassed(x)
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                       "'Test ', itoa(x), ' failed. Input: [', URL_DECODE_TEST_INPUT[x], ']'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                       "'Expected: [', URL_DECODE_TEST_EXPECTED[x], ']'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                       "'Got:      [', decoded, ']'")
            NAVLogTestFailed(x, URL_DECODE_TEST_EXPECTED[x], decoded)
        }
    }
}


/**
 * Test round-trip encoding/decoding (encode then decode should return original)
 */
define_function TestNAVUrlRoundTrip() {
    stack_var integer x
    stack_var char encoded[NAV_MAX_BUFFER]
    stack_var char decoded[NAV_MAX_BUFFER]
    stack_var integer totalTests

    NAVLog("'***************** NAVUrl Round-Trip Tests *****************'")

    totalTests = 15

    for (x = 1; x <= totalTests; x++) {
        // Encode then decode
        encoded = NAVUrlEncode(URL_ROUNDTRIP_TEST[x])
        decoded = NAVUrlDecode(encoded)

        if (decoded == URL_ROUNDTRIP_TEST[x]) {
            NAVLogTestPassed(x)
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                       "'Round-trip test ', itoa(x), ' failed'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                       "'Original: [', URL_ROUNDTRIP_TEST[x], ']'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                       "'Encoded:  [', encoded, ']'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                       "'Decoded:  [', decoded, ']'")
            NAVLogTestFailed(x, URL_ROUNDTRIP_TEST[x], decoded)
        }
    }
}


#END_IF // __NAV_URL_ENCODE_DECODE_TESTS__
