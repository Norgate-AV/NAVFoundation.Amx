PROGRAM_NAME='NAVHttpResponseMayHaveBody'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

// Test vectors for NAVHttpResponseMayHaveBody
constant integer RESPONSE_MAY_HAVE_BODY_TEST_CODE[] = {
    // 1xx Informational - never have bodies
    100,  // Continue
    101,  // Switching Protocols
    102,  // Processing
    103,  // Early Hints
    199,  // Any 1xx

    // 2xx Success - may have bodies except 204
    200,  // OK - may have body
    201,  // Created - may have body
    202,  // Accepted - may have body
    203,  // Non-Authoritative Info - may have body
    204,  // No Content - never has body
    205,  // Reset Content - may have body
    206,  // Partial Content - may have body

    // 3xx Redirection - may have bodies except 304
    300,  // Multiple Choices - may have body
    301,  // Moved Permanently - may have body
    302,  // Found - may have body
    303,  // See Other - may have body
    304,  // Not Modified - never has body
    307,  // Temporary Redirect - may have body
    308,  // Permanent Redirect - may have body

    // 4xx Client Errors - may have bodies
    400,  // Bad Request
    401,  // Unauthorized
    403,  // Forbidden
    404,  // Not Found
    405,  // Method Not Allowed
    418,  // I'm a teapot
    429,  // Too Many Requests

    // 5xx Server Errors - may have bodies
    500,  // Internal Server Error
    501,  // Not Implemented
    502,  // Bad Gateway
    503,  // Service Unavailable
    504,  // Gateway Timeout
    505   // HTTP Version Not Supported
}

constant char RESPONSE_MAY_HAVE_BODY_EXPECTED[] = {
    // 1xx - never have bodies
    false,  // 100
    false,  // 101
    false,  // 102
    false,  // 103
    false,  // 199

    // 2xx - may have bodies except 204
    true,   // 200 OK
    true,   // 201 Created
    true,   // 202 Accepted
    true,   // 203 Non-Auth Info
    false,  // 204 No Content
    true,   // 205 Reset Content
    true,   // 206 Partial Content

    // 3xx - may have bodies except 304
    true,   // 300 Multiple Choices
    true,   // 301 Moved Permanently
    true,   // 302 Found
    true,   // 303 See Other
    false,  // 304 Not Modified
    true,   // 307 Temporary Redirect
    true,   // 308 Permanent Redirect

    // 4xx - may have bodies
    true,   // 400 Bad Request
    true,   // 401 Unauthorized
    true,   // 403 Forbidden
    true,   // 404 Not Found
    true,   // 405 Method Not Allowed
    true,   // 418 I'm a teapot
    true,   // 429 Too Many Requests

    // 5xx - may have bodies
    true,   // 500 Internal Server Error
    true,   // 501 Not Implemented
    true,   // 502 Bad Gateway
    true,   // 503 Service Unavailable
    true,   // 504 Gateway Timeout
    true    // 505 Version Not Supported
}

define_function TestNAVHttpResponseMayHaveBody() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpResponseMayHaveBody'")

    for (x = 1; x <= length_array(RESPONSE_MAY_HAVE_BODY_TEST_CODE); x++) {
        stack_var _NAVHttpResponse response
        stack_var char result

        // Initialize response with test status code
        NAVHttpResponseInit(response)
        response.Status.Code = RESPONSE_MAY_HAVE_BODY_TEST_CODE[x]

        result = NAVHttpResponseMayHaveBody(response)

        if (!NAVAssertBooleanEqual('Should correctly determine if body allowed',
                                   RESPONSE_MAY_HAVE_BODY_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(RESPONSE_MAY_HAVE_BODY_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpResponseMayHaveBody'")
}
