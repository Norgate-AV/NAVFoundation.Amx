PROGRAM_NAME='NAVHttpTestShared'

#include 'NAVFoundation.Core.axi'

DEFINE_CONSTANT

constant char HTTP_TEST[][][2048] = {
    // Method, URL, Body
    {'GET', 'http://example.com', '{"key": "value"}'},
    {'GET', 'https://www.example.org/resource', '{"param": "data"}'},
    {'GET', 'https://example.com/test?foo=bar&baz=123#frag-01', '{"foo": "bar"}'},
    {'GET', 'http://127.0.0.1:8080/test-page', '{"test": "page"}'},
    {'GET', 'https://api.example.com/v1/users/123/posts', '{"user": "123"}'},
    {'GET', 'http://localhost:3000/api/data?key=value&sort=desc&page=1', '{"key": "value"}'},
    {'GET', 'https://search.example.org/results?q=test%20query&lang=en', '{"query": "test query"}'},
    {'GET', 'https://subdomain.example.com:8443/path/to/resource', '{"resource": "path/to/resource"}'},
    {'GET', 'http://demo.example.net/products?category=electronics&brand=samsung&inStock=true', '{"category": "electronics"}'},
    {'GET', 'https://api.example.com/v2/users/123/posts/comments/456/replies?sort=newest&limit=50#comment-section', '{"sort": "newest"}'},
    {'GET', 'http://subdomain.test.example.com:9000/very/deep/path/structure/file.html?param1=value1&param2=value2&param3=value3#section-2', '{"param1": "value1"}'},
    {'GET', 'https://example.com/search?q=test+with+spaces&category=all&page=1&filter=active#results', ''},
    {'GET', 'https://example.com/path?param=value#fragment?with?questions', ''},
    {'GET', 'https://example.com/path#fragment&with&ampersands', ''},
    {'GET', 'http://example.com/path/with/trailing/slash/', ''},
    // Valid edge case tests
    {'POST', 'http://example.com/api/create', '{"name":"Test","data":"value"}'},
    {'PUT', 'http://example.com/api/update/123', '{"status":"updated"}'},
    {'DELETE', 'http://example.com/api/delete/456', ''},
    {'PATCH', 'http://example.com/api/patch', '{"field":"new"}'},
    {'GET', 'http://example.com/very/long/path/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', ''},
    {'POST', 'http://example.com/api', '{"data":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"}'},
    {'post', 'http://example.com/lowercase', '{"test":"data"}'},
    {'GET', 'https://example.com:443/explicit-https-port', ''},
    {'GET', 'http://192.168.1.1:8080/api', '{"ip":"test"}'},
    {'GET', 'http://example.com/', ''},
    {'POST', 'http://example.com/api/submit', ''},
    // Invalid URL tests (should fail validation)
    {'GET', 'httpexample.com', ''},                              // Test 27: Missing ://  (no scheme)
    {'GET', 'ftp://example.com/file', ''},                       // Test 28: Unsupported scheme
    {'GET', 'http:///path/without/host', ''},                    // Test 29: Missing host
    {'GET', 'http://example.com:99999/', ''},                    // Test 30: Invalid port (too high)
    {'GET', '123://example.com/', ''},                           // Test 31: Invalid scheme (starts with digit)
    {'GET', 'http://example.com/path with space', ''},           // Test 32: Unencoded space in path
    {'GET', 'ht!tp://example.com/', ''},                          // Test 33: Invalid character in scheme
    {'GET', 'http://example.com:-1/', ''},                       // Test 34: Negative port
    {'GET', 'https://', ''},                                      // Test 35: Incomplete URL (no host)
    {'GET', 'http://[::1:8080/', ''}                              // Test 36: Malformed IPv6
}

constant char HTTP_TEST_HEADERS[][10][2][2048] = {
    // Key, Value
    {
        {''}
    },
    {
        {'User-Agent', 'MyHttpClient/1.0'}
    },
    {
        {'Accept', '*/*'}
    },
    {
        {'Accept', '*/*'}
    },
    {
        {'Connection', 'keep-alive'}
    },
    {
        {'Content-Type', 'application/json'}
    },
    {
        {'Content-Type', 'application/json'},
        {'Authorization', 'Bearer YOUR_TOKEN_HERE'}
    },
    {
        {'Content-Type', 'application/json'},
        {'Authorization', 'Bearer YOUR_TOKEN_HERE'}
    },
    {
        {'Content-Type', 'application/json'}
    },
    {
        {'Content-Type', 'application/json'}
    },
    {
        {'Content-Type', 'application/json'}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    // Valid edge case headers
    {
        {'Content-Type', 'application/json'}
    },
    {
        {'Content-Type', 'application/json'}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {'Content-Type', 'application/json'},
        {'Authorization', 'Bearer AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {'Content-Type', 'application/json'}
    },
    // Invalid URL test headers (empty since tests should fail early)
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    },
    {
        {''}
    }
}

constant char HTTP_EXPECTED_RESULT[] = {
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,   // Long path with queries and fragment
    true,   // Deep path structure
    true,   // Multiple queries with spaces
    true,   // Fragment with question marks
    true,   // Fragment with ampersands
    true,   // Trailing slash
    // Valid edge cases
    true,   // POST request
    true,   // PUT request
    true,   // DELETE request
    true,   // PATCH request
    true,   // Very long path
    true,   // Very long body
    true,   // Lowercase method
    true,   // Explicit HTTPS port
    true,   // IP address with port
    true,   // Root path only
    true,   // POST with empty body
    // Invalid URL expected results
    false,  // Test 27: Missing :// (no scheme) - fails HTTP init
    false,  // Test 28: Unsupported scheme (ftp) - fails HTTP init
    false,  // Test 29: Missing host - fails HTTP init
    false,  // Test 30: Invalid port (too high)
    false,  // Test 31: Invalid scheme (starts with digit)
    false,  // Test 32: Unencoded space in path
    false,  // Test 33: Invalid character in scheme
    false,  // Test 34: Negative port
    false,  // Test 35: Incomplete URL (no host) - fails HTTP init
    true    // Test 36: Malformed IPv6 - HTTP init succeeds
}

constant char HTTP_EXPECTED_URL_PARSE_RESULT[] = {
    true,   // Test 1: Basic HTTP URL
    true,   // Test 2: HTTPS URL with subdomain
    true,   // Test 3: URL with query and fragment
    true,   // Test 4: Localhost with port
    true,   // Test 5: API endpoint
    true,   // Test 6: Localhost with complex query
    true,   // Test 7: Search URL with encoded query
    true,   // Test 8: Subdomain with port
    true,   // Test 9: Complex query parameters
    true,   // Test 10: Long path with query and fragment
    true,   // Test 11: Deep path structure
    true,   // Test 12: Multiple queries with spaces
    true,   // Test 13: Fragment with question marks
    true,   // Test 14: Fragment with ampersands
    true,   // Test 15: Trailing slash
    // Valid edge cases
    true,   // Test 16: POST request
    true,   // Test 17: PUT request
    true,   // Test 18: DELETE request
    true,   // Test 19: PATCH request
    true,   // Test 20: Very long path
    true,   // Test 21: Very long body
    true,   // Test 22: Lowercase method
    true,   // Test 23: Explicit HTTPS port
    true,   // Test 24: IP address with port
    true,   // Test 25: Root path only
    true,   // Test 26: POST with empty body
    // Invalid URL expected results
    true,   // Test 27: Missing :// (no scheme) - actually parses as relative URL
    true,   // Test 28: Unsupported scheme (ftp) - ftp scheme is valid
    true,   // Test 29: Missing host - empty host is allowed
    false,  // Test 30: Invalid port (too high)
    false,  // Test 31: Invalid scheme (starts with digit)
    false,  // Test 32: Unencoded space in path
    false,  // Test 33: Invalid character in scheme
    false,  // Test 34: Negative port
    true,   // Test 35: Incomplete URL (no host) - empty host allowed
    true    // Test 36: Malformed IPv6 - actually valid IPv6 format
}

constant char HTTP_EXPECTED_BUILD_RESULT[] = {
    true,   // Test 1: Basic HTTP URL
    true,   // Test 2: HTTPS URL with subdomain
    true,   // Test 3: URL with query and fragment
    true,   // Test 4: Localhost with port
    true,   // Test 5: API endpoint
    true,   // Test 6: Localhost with complex query
    true,   // Test 7: Search URL with encoded query
    true,   // Test 8: Subdomain with port
    true,   // Test 9: Complex query parameters
    true,   // Test 10: Long path with query and fragment
    true,   // Test 11: Deep path structure
    true,   // Test 12: Multiple queries with spaces
    true,   // Test 13: Fragment with question marks
    true,   // Test 14: Fragment with ampersands
    true,   // Test 15: Trailing slash
    // Valid edge cases
    true,   // Test 16: POST request
    true,   // Test 17: PUT request
    true,   // Test 18: DELETE request
    true,   // Test 19: PATCH request
    true,   // Test 20: Very long path
    true,   // Test 21: Very long body
    true,   // Test 22: Lowercase method
    true,   // Test 23: Explicit HTTPS port
    true,   // Test 24: IP address with port
    true,   // Test 25: Root path only
    true,   // Test 26: POST with empty body
    // Invalid URL expected results (build skipped due to empty host)
    false,  // Test 27: Missing :// (no scheme)
    false,  // Test 28: Unsupported scheme (ftp)
    false,  // Test 29: Missing host
    false,  // Test 30: Invalid port (too high)
    false,  // Test 31: Invalid scheme (starts with digit)
    false,  // Test 32: Unencoded space in path
    false,  // Test 33: Invalid character in scheme
    false,  // Test 34: Negative port
    false,  // Test 35: Incomplete URL (no host)
    true   // Test 36: Malformed IPv6 - build succeeds
}

constant char HTTP_EXPECTED_HOST[][255] = {
    'example.com',
    'www.example.org',
    'example.com',
    '127.0.0.1',
    'api.example.com',
    'localhost',
    'search.example.org',
    'subdomain.example.com',
    'demo.example.net',
    'api.example.com',
    'subdomain.test.example.com',
    'example.com',
    'example.com',
    'example.com',
    'example.com',
    // Valid edge case hosts
    'example.com',
    'example.com',
    'example.com',
    'example.com',
    'example.com',
    'example.com',
    'example.com',
    'example.com',
    '192.168.1.1',
    'example.com',
    'example.com',
    // Invalid URL hosts (empty since validation fails)
    '',     // Test 27: Missing :// (no scheme)
    '',     // Test 28: Unsupported scheme (ftp)
    '',     // Test 29: Missing host
    '',     // Test 30: Invalid port (too high)
    '',     // Test 31: Invalid scheme (starts with digit)
    '',     // Test 32: Unencoded space in path
    '',     // Test 33: Invalid character in scheme
    '',     // Test 34: Negative port
    '',     // Test 35: Incomplete URL (no host)
    '[::1:8080'     // Test 36: Malformed IPv6
}

constant char HTTP_EXPECTED_PATH[][255] = {
    '',
    '/resource',
    '/test?foo=bar&baz=123#frag-01',
    '/test-page',
    '/v1/users/123/posts',
    '/api/data?key=value&sort=desc&page=1',
    '/results?q=test%20query&lang=en',
    '/path/to/resource',
    '/products?category=electronics&brand=samsung&inStock=true',
    '/v2/users/123/posts/comments/456/replies?sort=newest&limit=50#comment-section',
    '/very/deep/path/structure/file.html?param1=value1&param2=value2&param3=value3#section-2',
    '/search?q=test+with+spaces&category=all&page=1&filter=active#results',
    '/path?param=value#fragment?with?questions',
    '/path#fragment&with&ampersands',
    '/path/with/trailing/slash/',
    // Valid edge case paths
    '/api/create',
    '/api/update/123',
    '/api/delete/456',
    '/api/patch',
    '/very/long/path/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
    '/api',
    '/lowercase',
    '/explicit-https-port',
    '/api',
    '/',
    '/api/submit',
    // Invalid URL paths (empty since validation fails)
    '',     // Test 27: Missing :// (no scheme)
    '',     // Test 28: Unsupported scheme (ftp)
    '',     // Test 29: Missing host
    '',     // Test 30: Invalid port (too high)
    '',     // Test 31: Invalid scheme (starts with digit)
    '',     // Test 32: Unencoded space in path
    '',     // Test 33: Invalid character in scheme
    '',     // Test 34: Negative port
    '',     // Test 35: Incomplete URL (no host)
    '/'     // Test 36: Malformed IPv6
}

