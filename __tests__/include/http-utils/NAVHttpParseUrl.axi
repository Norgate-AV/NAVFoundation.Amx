PROGRAM_NAME='NAVHttpParseUrl'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

// Test vectors for NAVHttpParseUrl
constant char PARSE_URL_TEST_INPUT[][256] = {
    'http://example.com',                                    // Test 1: Simple HTTP URL
    'https://example.com',                                   // Test 2: Simple HTTPS URL
    'http://example.com:8080',                               // Test 3: HTTP with port
    'https://example.com:8443',                              // Test 4: HTTPS with port
    'http://example.com/path/to/resource',                   // Test 5: HTTP with path
    'https://example.com/api/v1',                            // Test 6: HTTPS with path
    'http://example.com/path?query=value',                   // Test 7: HTTP with query
    'https://example.com:443/api?id=123&name=test',          // Test 8: Full URL with query
    'example.com',                                           // Test 9: No scheme (should default to http)
    'example.com:8080',                                      // Test 10: No scheme with port
    'example.com/path',                                      // Test 11: No scheme with path
    'ftp://example.com',                                     // Test 12: Invalid scheme (should default to http)
    'HTTP://EXAMPLE.COM',                                    // Test 13: Uppercase scheme and host
    'http://192.168.1.1',                                    // Test 14: IP address
    'http://192.168.1.1:8080/api'                            // Test 15: IP with port and path
}

constant char PARSE_URL_EXPECTED_SCHEME[][16] = {
    'http',     // Test 1
    'https',    // Test 2
    'http',     // Test 3
    'https',    // Test 4
    'http',     // Test 5
    'https',    // Test 6
    'http',     // Test 7
    'https',    // Test 8
    'http',     // Test 9: Defaults to http
    'http',     // Test 10: Defaults to http
    'http',     // Test 11: Defaults to http
    'http',     // Test 12: Invalid scheme defaults to http
    'http',     // Test 13: Lowercase normalized
    'http',     // Test 14
    'http'      // Test 15
}

constant char PARSE_URL_EXPECTED_HOST[][512] = {
    'example.com',      // Test 1
    'example.com',      // Test 2
    'example.com',      // Test 3
    'example.com',      // Test 4
    'example.com',      // Test 5
    'example.com',      // Test 6
    'example.com',      // Test 7
    'example.com',      // Test 8
    'example.com',      // Test 9
    'example.com',      // Test 10
    'example.com',      // Test 11
    'example.com',      // Test 12
    'example.com',      // Test 13: Host normalized to lowercase
    '192.168.1.1',      // Test 14
    '192.168.1.1'       // Test 15
}

constant integer PARSE_URL_EXPECTED_PORT[] = {
    0,      // Test 1: No port specified
    0,      // Test 2: No port specified
    8080,   // Test 3
    8443,   // Test 4
    0,      // Test 5: No port specified
    0,      // Test 6: No port specified
    0,      // Test 7: No port specified
    443,    // Test 8
    0,      // Test 9: No port specified
    8080,   // Test 10
    0,      // Test 11: No port specified
    0,      // Test 12: No port specified
    0,      // Test 13: No port specified
    0,      // Test 14: No port specified
    8080    // Test 15
}

constant char PARSE_URL_EXPECTED_PATH[][256] = {
    '',                     // Test 1: No path
    '',                     // Test 2: No path
    '',                     // Test 3: No path
    '',                     // Test 4: No path
    '/path/to/resource',    // Test 5
    '/api/v1',              // Test 6
    '/path',                // Test 7
    '/api',                 // Test 8
    '',                     // Test 9: No path
    '',                     // Test 10: No path
    '/path',                // Test 11
    '',                     // Test 12: No path
    '',                     // Test 13: No path
    '',                     // Test 14: No path
    '/api'                  // Test 15
}

constant char PARSE_URL_SHOULD_SUCCEED[] = {
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
    true,   // Test 11
    true,   // Test 12
    true,   // Test 13
    true,   // Test 14
    true    // Test 15
}

define_function TestNAVHttpParseUrl() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpParseUrl'")

    for (x = 1; x <= length_array(PARSE_URL_TEST_INPUT); x++) {
        stack_var _NAVUrl url
        stack_var char result

        result = NAVHttpParseUrl(PARSE_URL_TEST_INPUT[x], url)

        if (!NAVAssertBooleanEqual('Should parse URL successfully',
                                   PARSE_URL_SHOULD_SUCCEED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(PARSE_URL_SHOULD_SUCCEED[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (!result) {
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertStringEqual('Should extract correct scheme',
                                 PARSE_URL_EXPECTED_SCHEME[x],
                                 url.Scheme)) {
            NAVLogTestFailed(x,
                            PARSE_URL_EXPECTED_SCHEME[x],
                            url.Scheme)
            continue
        }

        if (!NAVAssertStringEqual('Should extract correct host',
                                 PARSE_URL_EXPECTED_HOST[x],
                                 url.Host)) {
            NAVLogTestFailed(x,
                            PARSE_URL_EXPECTED_HOST[x],
                            url.Host)
            continue
        }

        if (!NAVAssertIntegerEqual('Should extract correct port',
                                  PARSE_URL_EXPECTED_PORT[x],
                                  url.Port)) {
            NAVLogTestFailed(x,
                            itoa(PARSE_URL_EXPECTED_PORT[x]),
                            itoa(url.Port))
            continue
        }

        if (!NAVAssertStringEqual('Should extract correct path',
                                 PARSE_URL_EXPECTED_PATH[x],
                                 url.Path)) {
            NAVLogTestFailed(x,
                            PARSE_URL_EXPECTED_PATH[x],
                            url.Path)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpParseUrl'")
}
