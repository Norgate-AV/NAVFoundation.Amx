PROGRAM_NAME='http'

#DEFINE __MAIN__
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.HttpUtils.axi'


DEFINE_DEVICE

dvTP    =   10001:1:0


DEFINE_CONSTANT

constant char TEST[][][2048] = {
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
    {'GET', 'http://example.com/path/with/trailing/slash/', ''}
}

constant char TEST_HEADERS[][10][2][2048] = {
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
    }
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


constant char EXPECTED_PATH[][255] = {
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
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
}


define_function ExpectedRequestPayloadInit(char payload[][]) {
    payload[1] = "
        'GET / HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        'Content-Length: 16', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"key": "value"}'
    "
    payload[2] = "
        'GET /resource HTTP/1.1', NAV_CR, NAV_LF,
        'Host: www.example.org', NAV_CR, NAV_LF,
        'Content-Length: 17', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'User-Agent: MyHttpClient/1.0', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"param": "data"}'
    "
    payload[3] = "
        'GET /test?foo=bar&baz=123#frag-01 HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        'Content-Length: 14', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Accept: */*', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"foo": "bar"}'
    "
    payload[4] = "
        'GET /test-page HTTP/1.1', NAV_CR, NAV_LF,
        'Host: 127.0.0.1', NAV_CR, NAV_LF,
        'Content-Length: 16', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Accept: */*', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"test": "page"}'
    "
    payload[5] = "
        'GET /v1/users/123/posts HTTP/1.1', NAV_CR, NAV_LF,
        'Host: api.example.com', NAV_CR, NAV_LF,
        'Content-Length: 15', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Connection: keep-alive', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"user": "123"}'
    "
    payload[6] = "
        'GET /api/data?key=value&sort=desc&page=1 HTTP/1.1', NAV_CR, NAV_LF,
        'Host: localhost', NAV_CR, NAV_LF,
        'Content-Length: 16', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"key": "value"}'
    "
    payload[7] = "
        'GET /results?q=test%20query&lang=en HTTP/1.1', NAV_CR, NAV_LF,
        'Host: search.example.org', NAV_CR, NAV_LF,
        'Content-Length: 23', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Authorization: Bearer YOUR_TOKEN_HERE', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"query": "test query"}'
    "
    payload[8] = "
        'GET /path/to/resource HTTP/1.1', NAV_CR, NAV_LF,
        'Host: subdomain.example.com', NAV_CR, NAV_LF,
        'Content-Length: 32', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        'Authorization: Bearer YOUR_TOKEN_HERE', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"resource": "path/to/resource"}'
    "
    payload[9] = "
        'GET /products?category=electronics&brand=samsung&inStock=true HTTP/1.1', NAV_CR, NAV_LF,
        'Host: demo.example.net', NAV_CR, NAV_LF,
        'Content-Length: 27', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"category": "electronics"}'
    "
    payload[10] = "
        'GET /v2/users/123/posts/comments/456/replies?sort=newest&limit=50#comment-section HTTP/1.1', NAV_CR, NAV_LF,
        'Host: api.example.com', NAV_CR, NAV_LF,
        'Content-Length: 18', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"sort": "newest"}'
    "
    payload[11] = "
        'GET /very/deep/path/structure/file.html?param1=value1&param2=value2&param3=value3#section-2 HTTP/1.1', NAV_CR, NAV_LF,
        'Host: subdomain.test.example.com', NAV_CR, NAV_LF,
        'Content-Length: 20', NAV_CR, NAV_LF,
        'Content-Type: application/json', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF,
        '{"param1": "value1"}'
    "
    payload[12] = "
        'GET /search?q=test+with+spaces&category=all&page=1&filter=active#results HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    payload[13] = "
        'GET /path?param=value#fragment?with?questions HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    payload[14] = "
        'GET /path#fragment&with&ampersands HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
    payload[15] = "
        'GET /path/with/trailing/slash/ HTTP/1.1', NAV_CR, NAV_LF,
        'Host: example.com', NAV_CR, NAV_LF,
        NAV_CR, NAV_LF
    "
}


define_function RunTests() {
    stack_var integer x
    stack_var char expectedRequestPayload[20][NAV_HTTP_MAX_REQUEST_LENGTH]

    ExpectedRequestPayloadInit(expectedRequestPayload)

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var _NAVHttpRequest request
        stack_var char result
        stack_var char payload[NAV_HTTP_MAX_REQUEST_LENGTH]

        result = NAVHttpRequestInit(request, TEST[x][1], TEST[x][2], TEST[x][3])

        if (result != EXPECTED_RESULT[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Expected init result "', NAVBooleanToString(EXPECTED_RESULT[x]), '" but got "', NAVBooleanToString(result), '"'")
            continue
        }

        if (EXPECTED_RESULT[x] && !result) {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Failed to init request'")
            continue
        }

        if (request.Method != TEST[x][1]) {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Expected method "', TEST[x][1], '" but got "', request.Method, '"'")
            continue
        }

        if (request.Host != EXPECTED_HOST[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Expected host "', EXPECTED_HOST[x], '" but got "', request.Host, '"'")
            continue
        }

        if (request.Path != EXPECTED_PATH[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Expected path "', EXPECTED_PATH[x], '" but got "', request.Path, '"'")
            continue
        }

        if (request.Body != TEST[x][3]) {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Expected body "', TEST[x][3], '" but got "', request.Body, '"'")
            continue
        }

        if (length_array(TEST_HEADERS[x]) > 0) {
            stack_var integer z

            for (z = 1; z <= length_array(TEST_HEADERS[x]); z++) {
                if (!length_array(TEST_HEADERS[x][z])) {
                    continue
                }

                NAVHttpRequestAddHeader(request, TEST_HEADERS[x][z][1], TEST_HEADERS[x][z][2])
            }
        }

        result = NAVHttpBuildRequest(request, payload)

        if (!result) {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Failed to build request'")
            continue
        }

        if (payload != expectedRequestPayload[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Payload does not match expected'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', expectedRequestPayload[x]")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Actual  : ', payload")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' passed'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Payload: ', payload")
    }
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
