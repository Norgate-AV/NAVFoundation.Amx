#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

constant char PARSE_URL_TESTS[][2048] = {
    // Basic valid URLs (1-15)
    'http://example.com',
    'https://www.example.org/resource',
    'https://example.com/test?foo=bar&baz=123#frag-01',
    'http://127.0.0.1:8080/test-page',
    'https://api.example.com/v1/users/123/posts',
    'http://localhost:3000/api/data?key=value&sort=desc&page=1',
    'https://search.example.org/results?q=test%20query&lang=en',
    'https://subdomain.example.com:8443/path/to/resource',
    'http://demo.example.net/products?category=electronics&brand=samsung&inStock=true',
    'https://api.example.com/v2/users/123/posts/comments/456/replies?sort=newest&limit=50#comment-section',
    'http://subdomain.test.example.com:9000/very/deep/path/structure/file.html?param1=value1&param2=value2&param3=value3#section-2',
    'https://example.com/search?q=test+with+spaces&category=all&page=1&filter=active#results',
    'https://example.com/path?param=value#fragment?with?questions',
    'https://example.com/path#fragment&with&ampersands',
    'http://example.com/path/with/trailing/slash/',

    // Scheme edge cases (16-22)
    'HTTP://example.com',                                   // 16: Uppercase scheme
    'ftp://files.example.com/file.txt',                     // 17: FTP scheme
    'rtsp://stream.example.com:554/video',                  // 18: RTSP scheme
    'ws://websocket.example.com:8080',                      // 19: WebSocket scheme
    'wss://secure-websocket.example.com',                   // 20: Secure WebSocket
    'file:///path/to/file.txt',                             // 21: File scheme with empty host
    's3://bucket-name/object/key',                          // 22: S3 scheme

    // Host edge cases (23-32)
    'http://EXAMPLE.COM',                                   // 23: Uppercase host
    'http://192.168.0.1',                                   // 24: IPv4 address
    'http://192.168.0.1:8080',                              // 25: IPv4 with port
    'http://localhost',                                     // 26: Localhost
    'http://sub.domain.example.com',                        // 27: Multiple subdomains
    'http://example-with-dash.com',                         // 28: Host with hyphens
    'http://example123.com',                                // 29: Host with numbers
    'http://[::1]',                                         // 30: IPv6 loopback
    'http://[2001:db8::1]',                                 // 31: IPv6 address
    'http://[2001:db8::1]:8080',                            // 32: IPv6 with port

    // Port edge cases (33-38)
    'http://example.com:80',                                // 33: Default HTTP port
    'https://example.com:443',                              // 34: Default HTTPS port
    'http://example.com:1',                                 // 35: Min port
    'http://example.com:8080',                              // 36: Common alt port
    'http://example.com:3000',                              // 37: Node.js default
    'http://example.com:65535',                             // 38: Max valid port (will overflow in NetLinx)

    // Path edge cases (39-50)
    'http://example.com/',                                  // 39: Root path
    'http://example.com',                                   // 40: No path
    'http://example.com/path',                              // 41: Simple path
    'http://example.com/path/',                             // 42: Path with trailing slash
    'http://example.com/path/to/resource',                  // 43: Multi-segment path
    'http://example.com//double//slash',                    // 44: Double slashes in path
    'http://example.com/./dot/path',                        // 45: Dot in path
    'http://example.com/../parent/path',                    // 46: Parent reference
    'http://example.com/path%20with%20spaces',              // 47: Percent-encoded spaces
    'http://example.com/path?',                             // 48: Empty query
    'http://example.com/path#',                             // 49: Empty fragment
    'http://example.com/file.txt',                          // 50: File extension

    // Query string edge cases (51-60)
    'http://example.com?key=value',                         // 51: Query without path
    'http://example.com/?key=value',                        // 52: Query with root path
    'http://example.com/path?key',                          // 53: Query key without value
    'http://example.com/path?key=',                         // 54: Query key with empty value
    'http://example.com/path?key1=val1&key2=val2',          // 55: Multiple query params
    'http://example.com/path?key=value&key=value2',         // 56: Duplicate keys
    'http://example.com/path?key=%20',                      // 57: Encoded space
    'http://example.com/path?key=value+with+plus',          // 58: Plus in query
    'http://example.com/path?array[]=1&array[]=2',          // 59: Array-like params
    'http://example.com/path?k1=v1&k2=v2&k3=v3&k4=v4',      // 60: Many params

    // Fragment edge cases (61-66)
    'http://example.com#fragment',                          // 61: Fragment without path
    'http://example.com/#fragment',                         // 62: Fragment with root path
    'http://example.com/path#section',                      // 63: Simple fragment
    'http://example.com/path#section-1',                    // 64: Fragment with hyphen
    'http://example.com/path?query=1#fragment',             // 65: Query and fragment
    'http://example.com/path#fragment?fake=query',          // 66: Question mark in fragment

    // Complex/Combined edge cases (67-72)
    'http://user:pass@example.com',                         // 67: URL with userinfo
    'http://user:pass@example.com:8080/path',               // 68: Userinfo with port and path
    'http://example.com:8080/path?query=1#fragment',        // 69: All components
    'http://192.168.1.1:8080/api?key=val#top',              // 70: IP, port, path, query, fragment
    'http://example.com/%7Euser/path',                      // 71: Tilde in path
    'http://example.com:8080/',                             // 72: Port with root path

    // Edge cases that test parser limits (73-77)
    '//example.com/path',                                   // 73: Protocol-relative URL
    '/path/to/resource',                                    // 74: Absolute path (no scheme/host)
    'http://',                                              // 75: Scheme with empty authority
    'http:///path',                                         // 76: Empty host with path
    ''                                                      // 77: Empty string
}

constant char PARSE_URL_EXPECTED_RESULT[] = {
    // Basic valid URLs (1-15)
    true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true,
    // Scheme edge cases (16-22)
    true, true, true, true, true, true, true,
    // Host edge cases (23-32)
    true, true, true, true, true, true, true, true, true, true,
    // Port edge cases (33-38)
    true, true, true, true, true, true,
    // Path edge cases (39-50)
    true, true, true, true, true, true, true, true, true, true,
    true, true,
    // Query string edge cases (51-60)
    true, true, true, true, true, true, true, true, true, true,
    // Fragment edge cases (61-66)
    true, true, true, true, true, true,
    // Complex/Combined edge cases (67-72)
    true, true, true, true, true, true,
    // Edge cases that test parser limits (73-77)
    true, true, true, true, false
}

constant char PARSE_URL_EXPECTED_SCHEME[][16] = {
    // Basic (1-15): http, https variations
    'http', 'https', 'https', 'http', 'https', 'http', 'https', 'https', 'http', 'https',
    'http', 'https', 'https', 'https', 'http',
    // Scheme tests (16-22): Various schemes (note: schemes normalized to lowercase per RFC 3986)
    'http', 'ftp', 'rtsp', 'ws', 'wss', 'file', 's3',
    // Host tests (23-32): HTTP with various hosts
    'http', 'http', 'http', 'http', 'http', 'http', 'http', 'http', 'http', 'http',
    // Port tests (33-38): HTTP/HTTPS with ports
    'http', 'https', 'http', 'http', 'http', 'http',
    // Path tests (39-50): HTTP with various paths
    'http', 'http', 'http', 'http', 'http', 'http', 'http', 'http', 'http', 'http',
    'http', 'http',
    // Query tests (51-60): HTTP with queries
    'http', 'http', 'http', 'http', 'http', 'http', 'http', 'http', 'http', 'http',
    // Fragment tests (61-66): HTTP with fragments
    'http', 'http', 'http', 'http', 'http', 'http',
    // Complex (67-72): HTTP with userinfo and combinations
    'http', 'http', 'http', 'http', 'http', 'http',
    // Edge cases (73-77): Protocol-relative, absolute path, empty components
    '', '', 'http', 'http', ''
}

constant char PARSE_URL_EXPECTED_HOST[][255] = {
    // Basic (1-15)
    'example.com', 'www.example.org', 'example.com', '127.0.0.1', 'api.example.com',
    'localhost', 'search.example.org', 'subdomain.example.com', 'demo.example.net', 'api.example.com',
    'subdomain.test.example.com', 'example.com', 'example.com', 'example.com', 'example.com',
    // Scheme tests (16-22)
    'example.com', 'files.example.com', 'stream.example.com', 'websocket.example.com', 'secure-websocket.example.com',
    '', 'bucket-name',
    // Host tests (23-32) (note: hosts normalized to lowercase per RFC 3986)
    'example.com', '192.168.0.1', '192.168.0.1', 'localhost', 'sub.domain.example.com',
    'example-with-dash.com', 'example123.com', '[::1]', '[2001:db8::1]', '[2001:db8::1]',
    // Port tests (33-38)
    'example.com', 'example.com', 'example.com', 'example.com', 'example.com', 'example.com',
    // Path tests (39-50)
    'example.com', 'example.com', 'example.com', 'example.com', 'example.com', 'example.com',
    'example.com', 'example.com', 'example.com', 'example.com', 'example.com', 'example.com',
    // Query tests (51-60)
    'example.com', 'example.com', 'example.com', 'example.com', 'example.com', 'example.com',
    'example.com', 'example.com', 'example.com', 'example.com',
    // Fragment tests (61-66)
    'example.com', 'example.com', 'example.com', 'example.com', 'example.com', 'example.com',
    // Complex (67-72)
    'example.com', 'example.com', 'example.com', '192.168.1.1', 'example.com', 'example.com',
    // Edge cases (73-77)
    'example.com', '', '', '', ''
}

constant integer PARSE_URL_EXPECTED_PORT[] = {
    // Basic (1-15)
    0, 0, 0, 8080, 0, 3000, 0, 8443, 0, 0,
    9000, 0, 0, 0, 0,
    // Scheme tests (16-22)
    0, 0, 554, 8080, 0, 0, 0,
    // Host tests (23-32)
    0, 0, 8080, 0, 0, 0, 0, 0, 0, 8080,
    // Port tests (33-38) - Note: 65535 will overflow to -1 in NetLinx signed int
    80, 443, 1, 8080, 3000, 65535,
    // Path tests (39-50)
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0,
    // Query tests (51-60)
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    // Fragment tests (61-66)
    0, 0, 0, 0, 0, 0,
    // Complex (67-72)
    0, 8080, 8080, 8080, 0, 8080,
    // Edge cases (73-77)
    0, 0, 0, 0, 0
}

constant char PARSE_URL_EXPECTED_PATH[][255] = {
    // Basic (1-15)
    '', '/resource', '/test', '/test-page', '/v1/users/123/posts',
    '/api/data', '/results', '/path/to/resource', '/products', '/v2/users/123/posts/comments/456/replies',
    '/very/deep/path/structure/file.html', '/search', '/path', '/path', '/path/with/trailing/slash/',
    // Scheme tests (16-22)
    '', '/file.txt', '/video', '', '', '/path/to/file.txt', '/object/key',
    // Host tests (23-32)
    '', '', '', '', '', '', '', '', '', '',
    // Port tests (33-38)
    '', '', '', '', '', '',
    // Path tests (39-50)
    '/', '', '/path', '/path/', '/path/to/resource', '/double/slash',
    '/dot/path', '/parent/path', '/path%20with%20spaces', '/path', '/path', '/file.txt',
    // Query tests (51-60)
    '', '/', '/path', '/path', '/path', '/path',
    '/path', '/path', '/path', '/path',
    // Fragment tests (61-66)
    '', '/', '/path', '/path', '/path', '/path',
    // Complex (67-72)
    '', '/path', '/path', '/api', '/%7Euser/path', '/',
    // Edge cases (73-77)
    '/path', '/path/to/resource', '', '/path', ''
}

constant char PARSE_URL_EXPECTED_FULL_PATH[][1024] = {
    // Basic (1-15)
    '', '/resource', '/test?foo=bar&baz=123#frag-01', '/test-page', '/v1/users/123/posts',
    '/api/data?key=value&sort=desc&page=1', '/results?q=test%20query&lang=en', '/path/to/resource',
    '/products?category=electronics&brand=samsung&inStock=true',
    '/v2/users/123/posts/comments/456/replies?sort=newest&limit=50#comment-section',
    '/very/deep/path/structure/file.html?param1=value1&param2=value2&param3=value3#section-2',
    '/search?q=test+with+spaces&category=all&page=1&filter=active#results',
    '/path?param=value#fragment?with?questions', '/path#fragment&with&ampersands', '/path/with/trailing/slash/',
    // Scheme tests (16-22)
    '', '/file.txt', '/video', '', '', '/path/to/file.txt', '/object/key',
    // Host tests (23-32)
    '', '', '', '', '', '', '', '', '', '',
    // Port tests (33-38)
    '', '', '', '', '', '',
    // Path tests (39-50)
    '/', '', '/path', '/path/', '/path/to/resource', '/double/slash',
    '/dot/path', '/parent/path', '/path%20with%20spaces', '/path?', '/path#', '/file.txt',
    // Query tests (51-60)
    '?key=value', '/?key=value', '/path?key', '/path?key=', '/path?key1=val1&key2=val2',
    '/path?key=value&key=value2', '/path?key=%20', '/path?key=value+with+plus',
    '/path?array[]=1&array[]=2', '/path?k1=v1&k2=v2&k3=v3&k4=v4',
    // Fragment tests (61-66)
    '#fragment', '/#fragment', '/path#section', '/path#section-1',
    '/path?query=1#fragment', '/path#fragment?fake=query',
    // Complex (67-72)
    '', '/path', '/path?query=1#fragment', '/api?key=val#top', '/%7Euser/path', '/',
    // Edge cases (73-77)
    '/path', '/path/to/resource', '', '/path', ''
}

constant integer PARSE_URL_EXPECTED_QUERY_COUNT[] = {
    // Basic (1-15)
    0, 0, 2, 0, 0, 3, 2, 0, 3, 2,
    3, 4, 1, 0, 0,
    // Scheme tests (16-22)
    0, 0, 0, 0, 0, 0, 0,
    // Host tests (23-32)
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    // Port tests (33-38)
    0, 0, 0, 0, 0, 0,
    // Path tests (39-50)
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0,
    // Query tests (51-60)
    1, 1, 1, 1, 2, 2, 1, 1, 2, 4,
    // Fragment tests (61-66)
    0, 0, 0, 0, 1, 0,
    // Complex (67-72)
    0, 0, 1, 1, 0, 0,
    // Edge cases (73-77)
    0, 0, 0, 0, 0
}

constant char PARSE_URL_EXPECTED_QUERY_KEY[][][255] = {
    // Basic (1-15) - Tests 3,6,7,9,10,11,12,13 have queries
    {''}, {''}, {'foo', 'baz'}, {''}, {''},
    {'key', 'sort', 'page'}, {'q', 'lang'}, {''},
    {'category', 'brand', 'inStock'}, {'sort', 'limit'},
    {'param1', 'param2', 'param3'}, {'q', 'category', 'page', 'filter'},
    {'param'}, {''}, {''},
    // Scheme tests (16-22)
    {''}, {''}, {''}, {''}, {''}, {''}, {''},
    // Host tests (23-32)
    {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''},
    // Port tests (33-38)
    {''}, {''}, {''}, {''}, {''}, {''},
    // Path tests (39-50)
    {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''},
    // Query tests (51-60)
    {'key'}, {'key'}, {'key'}, {'key'}, {'key1', 'key2'},
    {'key', 'key'}, {'key'}, {'key'}, {'array[]', 'array[]'}, {'k1', 'k2', 'k3', 'k4'},
    // Fragment tests (61-66)
    {''}, {''}, {''}, {''}, {'query'}, {''},
    // Complex (67-72)
    {''}, {''}, {'query'}, {'key'}, {''}, {''},
    // Edge cases (73-77)
    {''}, {''}, {''}, {''}, {''}
}

constant char PARSE_URL_EXPECTED_QUERY_VALUE[][][255] = {
    // Basic (1-15) - Tests 3,6,7,9,10,11,12,13 have queries
    {''}, {''}, {'bar', '123'}, {''}, {''},
    {'value', 'desc', '1'}, {'test%20query', 'en'}, {''},
    {'electronics', 'samsung', 'true'}, {'newest', '50'},
    {'value1', 'value2', 'value3'}, {'test+with+spaces', 'all', '1', 'active'},
    {'value'}, {''}, {''},
    // Scheme tests (16-22)
    {''}, {''}, {''}, {''}, {''}, {''}, {''},
    // Host tests (23-32)
    {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''},
    // Port tests (33-38)
    {''}, {''}, {''}, {''}, {''}, {''},
    // Path tests (39-50)
    {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''}, {''},
    // Query tests (51-60) - CORRECTED to match actual URLs
    {'value'}, {'value'}, {''}, {''}, {'val1', 'val2'},
    {'value', 'value2'}, {'%20'}, {'value+with+plus'}, {'1', '2'}, {'v1', 'v2', 'v3', 'v4'},
    // Fragment tests (61-66)
    {''}, {''}, {''}, {''}, {'1'}, {''},
    // Complex (67-72) - CORRECTED to match actual URLs
    {''}, {''}, {'1'}, {'val'}, {''}, {''},
    // Edge cases (73-77)
    {''}, {''}, {''}, {''}, {''}
}

constant char PARSE_URL_EXPECTED_FRAGMENT[][255] = {
    // Basic (1-15)
    '', '', 'frag-01', '', '', '', '', '', '', 'comment-section',
    'section-2', 'results', 'fragment?with?questions', 'fragment&with&ampersands', '',
    // Scheme tests (16-22)
    '', '', '', '', '', '', '',
    // Host tests (23-32)
    '', '', '', '', '', '', '', '', '', '',
    // Port tests (33-38)
    '', '', '', '', '', '',
    // Path tests (39-50)
    '', '', '', '', '', '', '', '', '', '', '', '',
    // Query tests (51-60)
    '', '', '', '', '', '', '', '', '', '',
    // Fragment tests (61-66) - CORRECTED to match actual URLs
    'fragment', 'fragment', 'section', 'section-1', 'fragment', 'fragment?fake=query',
    // Complex (67-72) - CORRECTED to match actual URLs
    '', '', 'fragment', 'top', '', '',
    // Edge cases (73-77)
    '', '', '', '', ''
}

constant char PARSE_URL_EXPECTED_HAS_USERINFO[] = {
    // Basic (1-15)
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false,
    // Scheme tests (16-22)
    false, false, false, false, false, false, false,
    // Host tests (23-32)
    false, false, false, false, false, false, false, false, false, false,
    // Port tests (33-38)
    false, false, false, false, false, false,
    // Path tests (39-50)
    false, false, false, false, false, false, false, false, false, false, false, false,
    // Query tests (51-60)
    false, false, false, false, false, false, false, false, false, false,
    // Fragment tests (61-66)
    false, false, false, false, false, false,
    // Complex (67-72) - Tests 67-68 have userinfo
    true, true, false, false, false, false,
    // Edge cases (73-77)
    false, false, false, false, false
}

constant char PARSE_URL_EXPECTED_USERNAME[][128] = {
    // Basic (1-15)
    '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '',
    // Scheme tests (16-22)
    '', '', '', '', '', '', '',
    // Host tests (23-32)
    '', '', '', '', '', '', '', '', '', '',
    // Port tests (33-38)
    '', '', '', '', '', '',
    // Path tests (39-50)
    '', '', '', '', '', '', '', '', '', '', '', '',
    // Query tests (51-60)
    '', '', '', '', '', '', '', '', '', '',
    // Fragment tests (61-66)
    '', '', '', '', '', '',
    // Complex (67-72)
    'user', 'user', '', '', '', '',
    // Edge cases (73-77)
    '', '', '', '', ''
}

constant char PARSE_URL_EXPECTED_PASSWORD[][128] = {
    // Basic (1-15)
    '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '',
    // Scheme tests (16-22)
    '', '', '', '', '', '', '',
    // Host tests (23-32)
    '', '', '', '', '', '', '', '', '', '',
    // Port tests (33-38)
    '', '', '', '', '', '',
    // Path tests (39-50)
    '', '', '', '', '', '', '', '', '', '', '', '',
    // Query tests (51-60)
    '', '', '', '', '', '', '', '', '', '',
    // Fragment tests (61-66)
    '', '', '', '', '', '',
    // Complex (67-72)
    'pass', 'pass', '', '', '', '',
    // Edge cases (73-77)
    '', '', '', '', ''
}


define_function TestNAVParseUrl() {
    stack_var integer x

    NAVLog("'***************** NAVParseUrl *****************'")

    for (x = 1; x <= length_array(PARSE_URL_TESTS); x++) {
        stack_var _NAVUrl url
        stack_var char result
        stack_var integer count

        result = NAVParseUrl(PARSE_URL_TESTS[x], url)

        if (!NAVAssertBooleanEqual('Should parse URL', PARSE_URL_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(PARSE_URL_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!PARSE_URL_EXPECTED_RESULT[x]) {
            // Expected to fail, skip further checks
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertStringEqual('Should have correct scheme', PARSE_URL_EXPECTED_SCHEME[x], url.Scheme)) {
            NAVLogTestFailed(x, PARSE_URL_EXPECTED_SCHEME[x], url.Scheme)
            continue
        }

        if (!NAVAssertStringEqual('Should have correct host', PARSE_URL_EXPECTED_HOST[x], url.Host)) {
            NAVLogTestFailed(x, PARSE_URL_EXPECTED_HOST[x], url.Host)
            continue
        }

        if (url.Port != PARSE_URL_EXPECTED_PORT[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected port ', itoa(PARSE_URL_EXPECTED_PORT[x]), ' but got ', itoa(url.Port)")
            continue
        }

        if (!NAVAssertIntegerEqual('Should have correct port', PARSE_URL_EXPECTED_PORT[x], url.Port)) {
            NAVLogTestFailed(x, itoa(PARSE_URL_EXPECTED_PORT[x]), itoa(url.Port))
            continue
        }

        if (!NAVAssertStringEqual('Should have correct full path', PARSE_URL_EXPECTED_FULL_PATH[x], url.FullPath)) {
            NAVLogTestFailed(x, PARSE_URL_EXPECTED_FULL_PATH[x], url.FullPath)
            continue
        }

        if (!NAVAssertStringEqual('Should have correct path', PARSE_URL_EXPECTED_PATH[x], url.Path)) {
            NAVLogTestFailed(x, PARSE_URL_EXPECTED_PATH[x], url.Path)
            continue
        }

        count = length_array(url.Queries)

        if (!NAVAssertIntegerEqual('Should have correct query count', PARSE_URL_EXPECTED_QUERY_COUNT[x], count)) {
            NAVLogTestFailed(x, itoa(PARSE_URL_EXPECTED_QUERY_COUNT[x]), itoa(count))
            continue
        }

        if (count > 0) {
            stack_var integer z
            stack_var char failed

            for (z = 1; z <= count; z++) {
                if (!NAVAssertStringEqual('Should have correct query key', PARSE_URL_EXPECTED_QUERY_KEY[x][z], url.Queries[z].Key)) {
                    NAVLogTestFailed(x, PARSE_URL_EXPECTED_QUERY_KEY[x][z], url.Queries[z].Key)
                    failed = true
                    break
                }

                if (!NAVAssertStringEqual('Should have correct query value', PARSE_URL_EXPECTED_QUERY_VALUE[x][z], url.Queries[z].Value)) {
                    NAVLogTestFailed(x, PARSE_URL_EXPECTED_QUERY_VALUE[x][z], url.Queries[z].Value)
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        if (!NAVAssertBooleanEqual('Should have correct HasUserInfo flag', PARSE_URL_EXPECTED_HAS_USERINFO[x], url.HasUserInfo)) {
            NAVLogTestFailed(x, NAVBooleanToString(PARSE_URL_EXPECTED_HAS_USERINFO[x]), NAVBooleanToString(url.HasUserInfo))
            continue
        }

        if (!NAVAssertStringEqual('Should have correct username', PARSE_URL_EXPECTED_USERNAME[x], url.UserInfo.Username)) {
            NAVLogTestFailed(x, PARSE_URL_EXPECTED_USERNAME[x], url.UserInfo.Username)
            continue
        }

        if (!NAVAssertStringEqual('Should have correct password', PARSE_URL_EXPECTED_PASSWORD[x], url.UserInfo.Password)) {
            NAVLogTestFailed(x, PARSE_URL_EXPECTED_PASSWORD[x], url.UserInfo.Password)
            continue
        }

        if (!NAVAssertStringEqual('Should have correct fragment', PARSE_URL_EXPECTED_FRAGMENT[x], url.Fragment)) {
            NAVLogTestFailed(x, PARSE_URL_EXPECTED_FRAGMENT[x], url.Fragment)
            continue
        }

        NAVLogTestPassed(x)
    }
}


define_function TestNAVBuildUrlWithUserInfo() {
    stack_var _NAVUrl url
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer testNum

    NAVLog("'***************** NAVBuildUrl with UserInfo *****************'")

    // Test 1: URL with username and password
    testNum = 1
    url.Scheme = 'http'
    url.UserInfo.Username = 'user'
    url.UserInfo.Password = 'pass'
    url.HasUserInfo = true
    url.Host = 'example.com'
    url.Port = 0
    url.Path = ''
    url.Fragment = ''

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with userinfo', 'http://user:pass@example.com', result)) {
        NAVLogTestFailed(testNum, 'http://user:pass@example.com', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 2: URL with username only (no password)
    testNum = 2
    url.Scheme = 'ftp'
    url.UserInfo.Username = 'ftpuser'
    url.UserInfo.Password = ''
    url.HasUserInfo = true
    url.Host = 'ftp.example.com'
    url.Port = 21
    url.Path = '/files'
    url.Fragment = ''

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with username only', 'ftp://ftpuser@ftp.example.com/files', result)) {
        NAVLogTestFailed(testNum, 'ftp://ftpuser@ftp.example.com/files', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 3: Round-trip test with userinfo
    testNum = 3
    if (NAVParseUrl('http://user:pass@example.com:8080/path', url)) {
        stack_var char rebuilt[NAV_MAX_BUFFER]
        rebuilt = NAVBuildUrl(url)

        if (!NAVAssertStringEqual('Should reconstruct original URL', 'http://user:pass@example.com:8080/path', rebuilt)) {
            NAVLogTestFailed(testNum, 'http://user:pass@example.com:8080/path', rebuilt)
        }
        else {
            NAVLogTestPassed(testNum)
        }
    }
    else {
        NAVLogTestFailed(testNum, 'Parse successful', 'Parse failed')
    }

    // Test 4: Simple HTTP URL without port
    testNum = 4
    url.Scheme = 'http'
    url.UserInfo.Username = ''
    url.UserInfo.Password = ''
    url.HasUserInfo = false
    url.Host = 'www.example.com'
    url.Port = 0
    url.Path = '/index.html'
    set_length_array(url.Queries, 0)
    url.Fragment = ''

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build simple HTTP URL', 'http://www.example.com/index.html', result)) {
        NAVLogTestFailed(testNum, 'http://www.example.com/index.html', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 5: HTTPS URL with custom port
    testNum = 5
    url.Scheme = 'https'
    url.Host = 'secure.example.com'
    url.Port = 8443
    url.Path = '/api/v1/users'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build HTTPS URL with custom port', 'https://secure.example.com:8443/api/v1/users', result)) {
        NAVLogTestFailed(testNum, 'https://secure.example.com:8443/api/v1/users', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 6: URL with query string
    testNum = 6
    url.Scheme = 'http'
    url.Host = 'example.com'
    url.Port = 0
    url.Path = '/search'
    url.Queries[1].Key = 'q'
    url.Queries[1].Value = 'test'
    url.Queries[2].Key = 'page'
    url.Queries[2].Value = '1'
    set_length_array(url.Queries, 2)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with query string', 'http://example.com/search?q=test&page=1', result)) {
        NAVLogTestFailed(testNum, 'http://example.com/search?q=test&page=1', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Reset queries for next test
    set_length_array(url.Queries, 0)

    // Test 7: URL with fragment only
    testNum = 7
    url.Scheme = 'https'
    url.Host = 'docs.example.com'
    url.Port = 0
    url.Path = '/guide'
    set_length_array(url.Queries, 0)
    url.Fragment = 'section-2'
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with fragment', 'https://docs.example.com/guide#section-2', result)) {
        NAVLogTestFailed(testNum, 'https://docs.example.com/guide#section-2', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 8: URL with query and fragment
    testNum = 8
    url.Scheme = 'http'
    url.Host = 'example.com'
    url.Port = 0
    url.Path = '/page'
    url.Queries[1].Key = 'id'
    url.Queries[1].Value = '123'
    set_length_array(url.Queries, 1)
    url.Fragment = 'top'
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with query and fragment', 'http://example.com/page?id=123#top', result)) {
        NAVLogTestFailed(testNum, 'http://example.com/page?id=123#top', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Reset queries for next test
    set_length_array(url.Queries, 0)

    // Test 9: URL with empty path (root)
    testNum = 9
    url.Scheme = 'http'
    url.Host = 'example.com'
    url.Port = 80
    url.Path = ''
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with empty path', 'http://example.com', result)) {
        NAVLogTestFailed(testNum, 'http://example.com', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 10: URL with IPv4 address
    testNum = 10
    url.Scheme = 'http'
    url.Host = '192.168.1.100'
    url.Port = 8080
    url.Path = '/admin'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with IPv4 address', 'http://192.168.1.100:8080/admin', result)) {
        NAVLogTestFailed(testNum, 'http://192.168.1.100:8080/admin', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 11: URL with IPv6 address
    testNum = 11
    url.Scheme = 'http'
    url.Host = '[2001:db8::1]'
    url.Port = 0
    url.Path = '/'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with IPv6 address', 'http://[2001:db8::1]/', result)) {
        NAVLogTestFailed(testNum, 'http://[2001:db8::1]/', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 12: FTP URL with port
    testNum = 12
    url.Scheme = 'ftp'
    url.Host = 'ftp.example.com'
    url.Port = 21
    url.Path = '/pub/files'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build FTP URL', 'ftp://ftp.example.com/pub/files', result)) {
        NAVLogTestFailed(testNum, 'ftp://ftp.example.com/pub/files', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 13: Complex path with encoded query parameters
    testNum = 13
    url.Scheme = 'http'
    url.Host = 'example.com'
    url.Port = 0
    url.Path = '/path/to/resource'
    url.Queries[1].Key = 'param'
    url.Queries[1].Value = 'value%20with%20spaces'
    set_length_array(url.Queries, 1)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with encoded query', 'http://example.com/path/to/resource?param=value%20with%20spaces', result)) {
        NAVLogTestFailed(testNum, 'http://example.com/path/to/resource?param=value%20with%20spaces', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Reset queries for next test
    set_length_array(url.Queries, 0)

    // Test 14: URL with multiple query parameters
    testNum = 14
    url.Scheme = 'https'
    url.Host = 'api.example.com'
    url.Port = 0
    url.Path = '/v2/search'
    url.Queries[1].Key = 'q'
    url.Queries[1].Value = 'test'
    url.Queries[2].Key = 'sort'
    url.Queries[2].Value = 'date'
    url.Queries[3].Key = 'order'
    url.Queries[3].Value = 'desc'
    url.Queries[4].Key = 'limit'
    url.Queries[4].Value = '10'
    set_length_array(url.Queries, 4)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with multiple query params', 'https://api.example.com/v2/search?q=test&sort=date&order=desc&limit=10', result)) {
        NAVLogTestFailed(testNum, 'https://api.example.com/v2/search?q=test&sort=date&order=desc&limit=10', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Reset queries for next test
    set_length_array(url.Queries, 0)

    // Test 15: URL with userinfo and all components
    testNum = 15
    url.Scheme = 'https'
    url.UserInfo.Username = 'admin'
    url.UserInfo.Password = 'secret'
    url.HasUserInfo = true
    url.Host = 'secure.example.com'
    url.Port = 443
    url.Path = '/dashboard'
    url.Queries[1].Key = 'view'
    url.Queries[1].Value = 'summary'
    set_length_array(url.Queries, 1)
    url.Fragment = 'stats'

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build complete URL with all components', 'https://admin:secret@secure.example.com/dashboard?view=summary#stats', result)) {
        NAVLogTestFailed(testNum, 'https://admin:secret@secure.example.com/dashboard?view=summary#stats', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Reset queries for next test
    set_length_array(url.Queries, 0)

    // Test 16: Round-trip with complex URL
    testNum = 16
    if (NAVParseUrl('https://user:pass@api.example.com:8443/v1/users?active=true&role=admin#results', url)) {
        stack_var char rebuilt2[NAV_MAX_BUFFER]
        rebuilt2 = NAVBuildUrl(url)

        if (!NAVAssertStringEqual('Should round-trip complex URL', 'https://user:pass@api.example.com:8443/v1/users?active=true&role=admin#results', rebuilt2)) {
            NAVLogTestFailed(testNum, 'https://user:pass@api.example.com:8443/v1/users?active=true&role=admin#results', rebuilt2)
        }
        else {
            NAVLogTestPassed(testNum)
        }
    }
    else {
        NAVLogTestFailed(testNum, 'Parse successful', 'Parse failed')
    }

    // Test 17: URL with path (normalized)
    testNum = 17
    url.Scheme = 'http'
    url.Host = 'example.com'
    url.Port = 0
    url.Path = '/api/reference'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with normalized path', 'http://example.com/api/reference', result)) {
        NAVLogTestFailed(testNum, 'http://example.com/api/reference', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 18: URL with fragment containing special characters
    testNum = 18
    url.Scheme = 'http'
    url.Host = 'example.com'
    url.Port = 0
    url.Path = '/page'
    set_length_array(url.Queries, 0)
    url.Fragment = 'section:subsection'
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with fragment containing colon', 'http://example.com/page#section:subsection', result)) {
        NAVLogTestFailed(testNum, 'http://example.com/page#section:subsection', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 19: URL with subdomain
    testNum = 19
    url.Scheme = 'https'
    url.Host = 'api.v2.example.com'
    url.Port = 0
    url.Path = '/endpoint'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with subdomain', 'https://api.v2.example.com/endpoint', result)) {
        NAVLogTestFailed(testNum, 'https://api.v2.example.com/endpoint', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 20: URL with trailing slash
    testNum = 20
    url.Scheme = 'http'
    url.Host = 'example.com'
    url.Port = 0
    url.Path = '/directory/'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should build URL with trailing slash', 'http://example.com/directory/', result)) {
        NAVLogTestFailed(testNum, 'http://example.com/directory/', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 21: HTTP with default port 80 (should be omitted)
    testNum = 21
    url.Scheme = 'http'
    url.Host = 'example.com'
    url.Port = 80
    url.Path = '/path'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should omit default port 80 for HTTP', 'http://example.com/path', result)) {
        NAVLogTestFailed(testNum, 'http://example.com/path', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 22: HTTPS with default port 443 (should be omitted)
    testNum = 22
    url.Scheme = 'https'
    url.Host = 'example.com'
    url.Port = 443
    url.Path = '/secure'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should omit default port 443 for HTTPS', 'https://example.com/secure', result)) {
        NAVLogTestFailed(testNum, 'https://example.com/secure', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 23: FTP with default port 21 (should be omitted)
    testNum = 23
    url.Scheme = 'ftp'
    url.Host = 'ftp.example.com'
    url.Port = 21
    url.Path = '/pub'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should omit default port 21 for FTP', 'ftp://ftp.example.com/pub', result)) {
        NAVLogTestFailed(testNum, 'ftp://ftp.example.com/pub', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 24: HTTP with non-default port 8080 (should be included)
    testNum = 24
    url.Scheme = 'http'
    url.Host = 'example.com'
    url.Port = 8080
    url.Path = '/api'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should include non-default port 8080 for HTTP', 'http://example.com:8080/api', result)) {
        NAVLogTestFailed(testNum, 'http://example.com:8080/api', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 25: HTTPS with non-default port 8443 (should be included)
    testNum = 25
    url.Scheme = 'https'
    url.Host = 'example.com'
    url.Port = 8443
    url.Path = '/secure'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should include non-default port 8443 for HTTPS', 'https://example.com:8443/secure', result)) {
        NAVLogTestFailed(testNum, 'https://example.com:8443/secure', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 26: WebSocket with default port 80 (should be omitted)
    testNum = 26
    url.Scheme = 'ws'
    url.Host = 'example.com'
    url.Port = 80
    url.Path = '/socket'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should omit default port 80 for WebSocket', 'ws://example.com/socket', result)) {
        NAVLogTestFailed(testNum, 'ws://example.com/socket', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 27: Secure WebSocket with default port 443 (should be omitted)
    testNum = 27
    url.Scheme = 'wss'
    url.Host = 'example.com'
    url.Port = 443
    url.Path = '/secure-socket'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should omit default port 443 for Secure WebSocket', 'wss://example.com/secure-socket', result)) {
        NAVLogTestFailed(testNum, 'wss://example.com/secure-socket', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 28: SFTP with default port 22 (should be omitted)
    testNum = 28
    url.Scheme = 'sftp'
    url.Host = 'sftp.example.com'
    url.Port = 22
    url.Path = '/files'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should omit default port 22 for SFTP', 'sftp://sftp.example.com/files', result)) {
        NAVLogTestFailed(testNum, 'sftp://sftp.example.com/files', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 29: RTSP with default port 554 (should be omitted)
    testNum = 29
    url.Scheme = 'rtsp'
    url.Host = 'media.example.com'
    url.Port = 554
    url.Path = '/stream'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should omit default port 554 for RTSP', 'rtsp://media.example.com/stream', result)) {
        NAVLogTestFailed(testNum, 'rtsp://media.example.com/stream', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 30: Custom scheme with port (no default, should be included)
    testNum = 30
    url.Scheme = 'custom'
    url.Host = 'example.com'
    url.Port = 9000
    url.Path = '/api'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should include port for custom scheme without default', 'custom://example.com:9000/api', result)) {
        NAVLogTestFailed(testNum, 'custom://example.com:9000/api', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 31: HTTP default port with uppercase scheme (should be omitted)
    testNum = 31
    url.Scheme = 'HTTP'
    url.Host = 'example.com'
    url.Port = 80
    url.Path = '/test'
    set_length_array(url.Queries, 0)
    url.Fragment = ''
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should omit default port 80 for uppercase HTTP', 'HTTP://example.com/test', result)) {
        NAVLogTestFailed(testNum, 'HTTP://example.com/test', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 32: HTTPS default port with query and fragment (should be omitted)
    testNum = 32
    url.Scheme = 'https'
    url.Host = 'example.com'
    url.Port = 443
    url.Path = '/page'
    url.Queries[1].Key = 'id'
    url.Queries[1].Value = '123'
    set_length_array(url.Queries, 1)
    url.Fragment = 'section'
    url.HasUserInfo = false

    result = NAVBuildUrl(url)

    if (!NAVAssertStringEqual('Should omit default port with query and fragment', 'https://example.com/page?id=123#section', result)) {
        NAVLogTestFailed(testNum, 'https://example.com/page?id=123#section', result)
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Reset queries for next test
    set_length_array(url.Queries, 0)
}


/**
 * Tests for NAVUrlGetDefaultPort function
 * RFC 3986 Section 6.2.3: Scheme-based normalization
 */
define_function TestNAVUrlGetDefaultPort() {
    stack_var integer testNum
    stack_var integer port

    NAVLog("'***************** NAVUrlGetDefaultPort *****************'")

    // Test 1: HTTP default port
    testNum = 1
    port = NAVUrlGetDefaultPort(NAV_URL_SCHEME_HTTP)

    if (!NAVAssertIntegerEqual('Should return 80 for HTTP', NAV_URL_DEFAULT_PORT_HTTP, port)) {
        NAVLogTestFailed(testNum, 'Expected: 80', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 2: HTTPS default port
    testNum = 2
    port = NAVUrlGetDefaultPort(NAV_URL_SCHEME_HTTPS)

    if (!NAVAssertIntegerEqual('Should return 443 for HTTPS', NAV_URL_DEFAULT_PORT_HTTPS, port)) {
        NAVLogTestFailed(testNum, 'Expected: 443', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 3: FTP default port
    testNum = 3
    port = NAVUrlGetDefaultPort(NAV_URL_SCHEME_FTP)

    if (!NAVAssertIntegerEqual('Should return 21 for FTP', NAV_URL_DEFAULT_PORT_FTP, port)) {
        NAVLogTestFailed(testNum, 'Expected: 21', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 4: SFTP default port
    testNum = 4
    port = NAVUrlGetDefaultPort(NAV_URL_SCHEME_SFTP)

    if (!NAVAssertIntegerEqual('Should return 22 for SFTP', NAV_URL_DEFAULT_PORT_SFTP, port)) {
        NAVLogTestFailed(testNum, 'Expected: 22', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 5: RTSP default port
    testNum = 5
    port = NAVUrlGetDefaultPort(NAV_URL_SCHEME_RTSP)

    if (!NAVAssertIntegerEqual('Should return 554 for RTSP', NAV_URL_DEFAULT_PORT_RTSP, port)) {
        NAVLogTestFailed(testNum, 'Expected: 554', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 6: RTSPS default port
    testNum = 6
    port = NAVUrlGetDefaultPort(NAV_URL_SCHEME_RTSPS)

    if (!NAVAssertIntegerEqual('Should return 322 for RTSPS', NAV_URL_DEFAULT_PORT_RTSPS, port)) {
        NAVLogTestFailed(testNum, 'Expected: 322', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 7: WebSocket default port
    testNum = 7
    port = NAVUrlGetDefaultPort(NAV_URL_SCHEME_WS)

    if (!NAVAssertIntegerEqual('Should return 80 for WebSocket', NAV_URL_DEFAULT_PORT_WS, port)) {
        NAVLogTestFailed(testNum, 'Expected: 80', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 8: Secure WebSocket default port
    testNum = 8
    port = NAVUrlGetDefaultPort(NAV_URL_SCHEME_WSS)

    if (!NAVAssertIntegerEqual('Should return 443 for Secure WebSocket', NAV_URL_DEFAULT_PORT_WSS, port)) {
        NAVLogTestFailed(testNum, 'Expected: 443', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 9: Uppercase HTTP (should be case-insensitive)
    testNum = 9
    port = NAVUrlGetDefaultPort('HTTP')

    if (!NAVAssertIntegerEqual('Should return 80 for uppercase HTTP', NAV_URL_DEFAULT_PORT_HTTP, port)) {
        NAVLogTestFailed(testNum, 'Expected: 80', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 10: Mixed case HTTPS (should be case-insensitive)
    testNum = 10
    port = NAVUrlGetDefaultPort('HtTpS')

    if (!NAVAssertIntegerEqual('Should return 443 for mixed case HTTPS', NAV_URL_DEFAULT_PORT_HTTPS, port)) {
        NAVLogTestFailed(testNum, 'Expected: 443', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 11: Unknown scheme (should return 0)
    testNum = 11
    port = NAVUrlGetDefaultPort('custom')

    if (!NAVAssertIntegerEqual('Should return 0 for unknown scheme', 0, port)) {
        NAVLogTestFailed(testNum, 'Expected: 0', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 12: Empty scheme (should return 0)
    testNum = 12
    port = NAVUrlGetDefaultPort('')

    if (!NAVAssertIntegerEqual('Should return 0 for empty scheme', 0, port)) {
        NAVLogTestFailed(testNum, 'Expected: 0', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }

    // Test 13: S3 scheme (no default port, should return 0)
    testNum = 13
    port = NAVUrlGetDefaultPort('s3')

    if (!NAVAssertIntegerEqual('Should return 0 for S3 scheme', 0, port)) {
        NAVLogTestFailed(testNum, 'Expected: 0', "itoa(port)")
    }
    else {
        NAVLogTestPassed(testNum)
    }
}


