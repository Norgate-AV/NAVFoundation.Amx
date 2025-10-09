PROGRAM_NAME='NAVUrlCaseNormalization'

/**
 * Test cases for URL case normalization
 *
 * Tests RFC 3986 Section 6.2.2.1 compliance:
 * - Scheme should be normalized to lowercase
 * - Host should be normalized to lowercase
 */

#IF_NOT_DEFINED __NAV_URL_CASE_NORMALIZATION_TESTS__
#DEFINE __NAV_URL_CASE_NORMALIZATION_TESTS__ 'NAVUrlCaseNormalizationTests'


DEFINE_CONSTANT

// Test URLs with various case combinations
constant char CASE_NORM_TEST_URLS[20][200] = {
    // Scheme normalization (1-5)
    'HTTP://example.com',               // Test 1: Uppercase scheme
    'HTTPS://example.com',              // Test 2: Uppercase HTTPS
    'HtTp://example.com',               // Test 3: Mixed case scheme
    'FTP://example.com',                // Test 4: Uppercase FTP
    'http://example.com',               // Test 5: Already lowercase

    // Host normalization (6-10)
    'http://EXAMPLE.COM',               // Test 6: Uppercase host
    'http://Example.Com',               // Test 7: Mixed case host
    'http://WWW.EXAMPLE.COM',           // Test 8: Uppercase subdomain
    'http://API.Example.COM',           // Test 9: Mixed subdomain
    'http://example.com',               // Test 10: Already lowercase

    // Combined normalization (11-15)
    'HTTP://EXAMPLE.COM',               // Test 11: Both uppercase
    'HTTPS://WWW.EXAMPLE.COM',          // Test 12: All uppercase
    'HtTp://ExAmPlE.CoM',               // Test 13: Mixed case both
    'FTP://FTP.EXAMPLE.COM',            // Test 14: FTP uppercase
    'http://example.com',               // Test 15: Already normalized

    // With paths and ports (16-20)
    'HTTP://EXAMPLE.COM/path',          // Test 16: Uppercase with path
    'HTTPS://EXAMPLE.COM:8080/path',    // Test 17: Uppercase with port
    'HTTP://API.EXAMPLE.COM/v1/data',   // Test 18: Subdomain with path
    'HTTPS://Example.COM:443/Path',     // Test 19: Mixed case with path
    'HTTP://EXAMPLE.COM?query=value'    // Test 20: Uppercase with query
}

// Expected normalized schemes (all lowercase)
constant char CASE_NORM_EXPECTED_SCHEME[20][16] = {
    'http', 'https', 'http', 'ftp', 'http',     // Tests 1-5
    'http', 'http', 'http', 'http', 'http',     // Tests 6-10
    'http', 'https', 'http', 'ftp', 'http',     // Tests 11-15
    'http', 'https', 'http', 'https', 'http'    // Tests 16-20
}

// Expected normalized hosts (all lowercase)
constant char CASE_NORM_EXPECTED_HOST[20][128] = {
    'example.com', 'example.com', 'example.com', 'example.com', 'example.com',          // Tests 1-5
    'example.com', 'example.com', 'www.example.com', 'api.example.com', 'example.com',  // Tests 6-10
    'example.com', 'www.example.com', 'example.com', 'ftp.example.com', 'example.com',  // Tests 11-15
    'example.com', 'example.com', 'api.example.com', 'example.com', 'example.com'       // Tests 16-20
}

// Expected ports (should be unchanged)
constant integer CASE_NORM_EXPECTED_PORT[20] = {
    0, 0, 0, 0, 0,          // Tests 1-5
    0, 0, 0, 0, 0,          // Tests 6-10
    0, 0, 0, 0, 0,          // Tests 11-15
    0, 8080, 0, 443, 0      // Tests 16-20
}

// Expected paths (should be unchanged - paths are case-sensitive)
constant char CASE_NORM_EXPECTED_PATH[20][128] = {
    '', '', '', '', '',                             // Tests 1-5
    '', '', '', '', '',                             // Tests 6-10
    '', '', '', '', '',                             // Tests 11-15
    '/path', '/path', '/v1/data', '/Path', ''      // Tests 16-20
}


// IPv6 case normalization tests
constant char CASE_NORM_IPV6_URLS[5][200] = {
    'HTTP://[2001:DB8::1]',             // Test 1: Uppercase hex in IPv6
    'http://[2001:db8::1]',             // Test 2: Lowercase hex in IPv6
    'HTTP://[2001:Db8::1]:8080',        // Test 3: Mixed case IPv6 with port
    'HTTPS://[::1]',                    // Test 4: Uppercase scheme, IPv6 localhost
    'http://[2001:0DB8:0000:0000:0000:0000:0000:0001]'  // Test 5: Full IPv6 uppercase
}

constant char CASE_NORM_IPV6_EXPECTED_SCHEME[5][16] = {
    'http', 'http', 'http', 'https', 'http'
}

constant char CASE_NORM_IPV6_EXPECTED_HOST[5][128] = {
    '[2001:db8::1]',
    '[2001:db8::1]',
    '[2001:db8::1]',
    '[::1]',
    '[2001:0db8:0000:0000:0000:0000:0000:0001]'
}


/**
 * Test case normalization for scheme and host
 */
define_function TestNAVUrlCaseNormalization() {
    stack_var integer x

    NAVLog("'***************** URL Case Normalization *****************'")

    for (x = 1; x <= length_array(CASE_NORM_TEST_URLS); x++) {
        stack_var _NAVUrl url
        stack_var char result

        result = NAVParseUrl(CASE_NORM_TEST_URLS[x], url)

        if (!NAVAssertTrue('Should parse URL', result)) {
            NAVLogTestFailed(x, 'Valid URL', 'Invalid URL')
            continue
        }

        // Check scheme normalization
        if (!NAVAssertStringEqual('Should normalize scheme correctly', CASE_NORM_EXPECTED_SCHEME[x], url.Scheme)) {
            NAVLogTestFailed(x, CASE_NORM_EXPECTED_SCHEME[x], url.Scheme)
            continue
        }

        // Check host normalization
        if (!NAVAssertStringEqual('Should normalize host correctly', CASE_NORM_EXPECTED_HOST[x], url.Host)) {
            NAVLogTestFailed(x, CASE_NORM_EXPECTED_HOST[x], url.Host)
            continue
        }

        // Check port is unchanged
        if (!NAVAssertIntegerEqual('Should keep port unchanged', CASE_NORM_EXPECTED_PORT[x], url.Port)) {
            NAVLogTestFailed(x, itoa(CASE_NORM_EXPECTED_PORT[x]), itoa(url.Port))
            continue
        }

        // Check path is unchanged (case-sensitive)
        if (!NAVAssertStringEqual('Should keep path unchanged', CASE_NORM_EXPECTED_PATH[x], url.Path)) {
            NAVLogTestFailed(x, CASE_NORM_EXPECTED_PATH[x], url.Path)
            continue
        }

        NAVLogTestPassed(x)
    }
}


/**
 * Test case normalization for IPv6 addresses
 */
define_function TestNAVUrlCaseNormalizationIPv6() {
    stack_var integer x

    NAVLog("'***************** URL Case Normalization (IPv6) *****************'")

    for (x = 1; x <= length_array(CASE_NORM_IPV6_URLS); x++) {
        stack_var _NAVUrl url
        stack_var char result

        result = NAVParseUrl(CASE_NORM_IPV6_URLS[x], url)

        if (!NAVAssertTrue('Should parse URL', result)) {
            NAVLogTestFailed(x, 'Valid URL', 'Invalid URL')
            continue
        }

        // Check scheme normalization
        if (!NAVAssertStringEqual('Should normalize scheme', CASE_NORM_IPV6_EXPECTED_SCHEME[x], url.Scheme)) {
            NAVLogTestFailed(x, CASE_NORM_IPV6_EXPECTED_SCHEME[x], url.Scheme)
            continue
        }

        // Check host (IPv6) normalization
        if (!NAVAssertStringEqual('Should normalize host', CASE_NORM_IPV6_EXPECTED_HOST[x], url.Host)) {
            NAVLogTestFailed(x, CASE_NORM_IPV6_EXPECTED_HOST[x], url.Host)
            continue
        }

        NAVLogTestPassed(x)
    }
}


/**
 * Test that paths remain case-sensitive (NOT normalized)
 */
define_function TestNAVUrlPathCaseSensitivity() {
    stack_var _NAVUrl url
    stack_var char result

    NAVLog("'***************** Path Case Sensitivity *****************'")

    // Test 1: Path with mixed case should remain unchanged
    result = NAVParseUrl('http://example.com/Path/To/File.TXT', url)

    if (url.Path == '/Path/To/File.TXT') {
        NAVLogTestPassed(1)
    }
    else {
        NAVLog("'Path case sensitivity test failed'")
        NAVLog("'Expected: [/Path/To/File.TXT]'")
        NAVLog("'Got:      [', url.Path, ']'")
        NAVLogTestFailed(1, '/Path/To/File.TXT', url.Path)
    }

    // Test 2: Query parameters should remain case-sensitive
    result = NAVParseUrl('http://example.com/path?Key=Value', url)

    if (url.Queries[1].Key == 'Key' && url.Queries[1].Value == 'Value') {
        NAVLogTestPassed(2)
    }
    else {
        NAVLog("'Query case sensitivity test failed'")
        NAVLog("'Expected: Key=Value'")
        NAVLog("'Got:      ', url.Queries[1].Key, '=', url.Queries[1].Value")
        NAVLogTestFailed(2, 'Key=Value', "url.Queries[1].Key, '=', url.Queries[1].Value")
    }

    // Test 3: Fragment should remain case-sensitive
    result = NAVParseUrl('http://example.com/path#Section-1', url)

    if (url.Fragment == 'Section-1') {
        NAVLogTestPassed(3)
    }
    else {
        NAVLog("'Fragment case sensitivity test failed'")
        NAVLog("'Expected: [Section-1]'")
        NAVLog("'Got:      [', url.Fragment, ']'")
        NAVLogTestFailed(3, 'Section-1', url.Fragment)
    }
}


#END_IF // __NAV_URL_CASE_NORMALIZATION_TESTS__
