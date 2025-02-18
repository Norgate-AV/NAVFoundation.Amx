PROGRAM_NAME='url'

#DEFINE __MAIN__
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Url.axi'


DEFINE_DEVICE

dvTP    =   10001:1:0


DEFINE_CONSTANT

constant char TEST[][2048] = {
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
    'http://example.com/path/with/trailing/slash/'
    // 'http:/example.com',           // Missing slash
    // 'https://[invalid.ip]/',       // Invalid IP format
    // 'http://example.com:abc',      // Invalid port
    // 'ftp://example.com',          // Unsupported scheme
    // ':not-valid-url',             // Missing scheme and host
    // 'http://',                    // Missing host
    // 'https://example.com:99999',  // Port number too large
    // 'http://exam ple.com'         // Invalid hostname
}

constant char EXPECTED_RESULT[] = {
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
    false,  // Missing slash
    false,  // Invalid IP
    false,  // Invalid port
    false,  // Unsupported scheme
    false,  // Invalid URL
    false,  // Missing host
    false,  // Port too large
    false   // Invalid hostname
}

constant char EXPECTED_SCHEME[][16] = {
    'http',
    'https',
    'https',
    'http',
    'https',
    'http',
    'https',
    'https',
    'http',
    'https',
    'http',
    'https',
    'https',
    'https',
    'http',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
}

constant char EXPECTED_HOST[][255] = {
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
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
}

constant integer EXPECTED_PORT[] = {
    0,
    0,
    0,
    8080,
    0,
    3000,
    0,
    8443,
     0,
    0,
    9000,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
}

constant char EXPECTED_PATH[][255] = {
    '',
    '/resource',
    '/test',
    '/test-page',
    '/v1/users/123/posts',
    '/api/data',
    '/results',
    '/path/to/resource',
    '/products',
    '/v2/users/123/posts/comments/456/replies',
    '/very/deep/path/structure/file.html',
    '/search',
    '/path',
    '/path',
    '/path/with/trailing/slash/',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
}

constant integer EXPECTED_QUERY_COUNT[] = {
    0,
    0,
    2,
    0,
    0,
    3,
    2,
    0,
    3,
    2,
    3,
    4,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
}

constant char EXPECTED_QUERY_KEY[][][255] = {
    {''},
    {''},
    {'foo', 'baz'},
    {''},
    {''},
    {'key', 'sort', 'page'},
    {'q', 'lang'},
    {''},
    {'category', 'brand', 'inStock'},
    {'sort', 'limit'},
    {'param1', 'param2', 'param3'},
    {'q', 'category', 'page', 'filter'},
    {'param'},
    {''},
    {''},
    {''},
    {''},
    {''},
    {''},
    {''},
    {''},
    {''},
    {''}
}

constant char EXPECTED_QUERY_VALUE[][][255] = {
    {''},
    {''},
    {'bar', '123'},
    {''},
    {''},
    {'value', 'desc', '1'},
    {'test%20query', 'en'},
    {''},
    {'electronics', 'samsung', 'true'},
    {'newest', '50'},
    {'value1', 'value2', 'value3'},
    {'test+with+spaces', 'all', '1', 'active'},
    {'value'},
    {''},
    {''},
    {''},
    {''},
    {''},
    {''},
    {''},
    {''},
    {''},
    {''}
}

constant char EXPECTED_FRAGMENT[][255] = {
    '',
    '',
    'frag-01',
    '',
    '',
    '',
    '',
    '',
    '',
    'comment-section',
    'section-2',
    'results',
    'fragment?with?questions',
    'fragment&with&ampersands',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
}


define_function RunTests() {
    stack_var integer x

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var _NAVUrl url
        stack_var char result
        stack_var integer count
        stack_var char failed

        result = NAVParseUrl(TEST[x], url)

        if (result != EXPECTED_RESULT[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected parse result ', NAVBooleanToString(EXPECTED_RESULT[x]), ' but got ', NAVBooleanToString(result)")
            continue
        }

        if (EXPECTED_RESULT[x] && !result) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Could not parse URL'")
            continue
        }

        if (url.Scheme != EXPECTED_SCHEME[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected scheme "', EXPECTED_SCHEME[x], '" but got "', url.Scheme, '"'")
            continue
        }

        if (url.Host != EXPECTED_HOST[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected host "', EXPECTED_HOST[x], '" but got "', url.Host, '"'")
            continue
        }

        if (url.Port != EXPECTED_PORT[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected port ', itoa(EXPECTED_PORT[x]), ' but got ', itoa(url.Port)")
            continue
        }

        if (url.Path != EXPECTED_PATH[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected path "', EXPECTED_PATH[x], '" but got "', url.Path, '"'")
            continue
        }

        count = length_array(url.Queries)

        if (count != EXPECTED_QUERY_COUNT[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected query count ', itoa(EXPECTED_QUERY_COUNT[x]), ' but got ', itoa(count)")
            continue
        }

        if (count > 0) {
            stack_var integer z

            for (z = 1; z <= count; z++) {
                if (url.Queries[z].Key != EXPECTED_QUERY_KEY[x][z]) {
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected query key "', EXPECTED_QUERY_KEY[x][z], '" but got "', url.Queries[z].Key, '"'")
                    failed = true
                    break
                }

                if (url.Queries[z].Value != EXPECTED_QUERY_VALUE[x][z]) {
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected query value "', EXPECTED_QUERY_VALUE[x][z], '" but got "', url.Queries[z].Value, '"'")
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        if (url.Fragment != EXPECTED_FRAGMENT[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed. Expected fragment "', EXPECTED_FRAGMENT[x], '" but got "', url.Fragment, '"'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' passed'")
    }
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
