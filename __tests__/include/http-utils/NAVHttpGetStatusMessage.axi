PROGRAM_NAME='NAVHttpGetStatusMessage'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

// Test vectors for NAVHttpGetStatusMessage
constant integer STATUS_MESSAGE_TEST_CODE[] = {
    // 1xx Informational
    100,  // Continue
    101,  // Switching Protocols
    102,  // Processing
    103,  // Early Hints

    // 2xx Success
    200,  // OK
    201,  // Created
    202,  // Accepted
    203,  // Non-Authoritative Information
    204,  // No Content
    205,  // Reset Content
    206,  // Partial Content
    207,  // Multi-Status
    208,  // Already Reported
    226,  // IM Used

    // 3xx Redirection
    300,  // Multiple Choices
    301,  // Moved Permanently
    302,  // Found
    303,  // See Other
    304,  // Not Modified
    305,  // Use Proxy
    307,  // Temporary Redirect
    308,  // Permanent Redirect

    // 4xx Client Errors
    400,  // Bad Request
    401,  // Unauthorized
    402,  // Payment Required
    403,  // Forbidden
    404,  // Not Found
    405,  // Method Not Allowed
    406,  // Not Acceptable
    408,  // Request Timeout
    409,  // Conflict
    410,  // Gone
    411,  // Length Required
    412,  // Precondition Failed
    413,  // Payload Too Large
    414,  // URI Too Long
    415,  // Unsupported Media Type
    416,  // Range Not Satisfiable
    417,  // Expectation Failed
    418,  // I'm a teapot
    421,  // Misdirected Request
    422,  // Unprocessable Content
    423,  // Locked
    424,  // Failed Dependency
    425,  // Too Early
    426,  // Upgrade Required
    428,  // Precondition Required
    429,  // Too Many Requests

    // 5xx Server Errors
    500,  // Internal Server Error
    501,  // Not Implemented
    502,  // Bad Gateway
    503,  // Service Unavailable
    504,  // Gateway Timeout
    505,  // HTTP Version Not Supported
    506,  // Variant Also Negotiates
    507,  // Insufficient Storage
    508,  // Loop Detected
    510,  // Not Extended

    // Unknown
    999   // Unknown status code
}

constant char STATUS_MESSAGE_EXPECTED[][60] = {
    // 1xx
    'Continue',
    'Switching Protocols',
    'Processing',
    'Early Hints',

    // 2xx
    'OK',
    'Created',
    'Accepted',
    'Non-Authoritative Information',
    'No Content',
    'Reset Content',
    'Partial Content',
    'Multi-Status',
    'Already Reported',
    'IM Used',

    // 3xx
    'Multiple Choices',
    'Moved Permanently',
    'Found',
    'See Other',
    'Not Modified',
    'Use Proxy',
    'Temporary Redirect',
    'Permanent Redirect',

    // 4xx
    'Bad Request',
    'Unauthorized',
    'Payment Required',
    'Forbidden',
    'Not Found',
    'Method Not Allowed',
    'Not Acceptable',
    'Request Timeout',
    'Conflict',
    'Gone',
    'Length Required',
    'Precondition Failed',
    'Payload Too Large',
    'URI Too Long',
    'Unsupported Media Type',
    'Range Not Satisfiable',
    'Expectation Failed',
    "I'm a teapot",
    'Misdirected Request',
    'Unprocessable Content',
    'Locked',
    'Failed Dependency',
    'Too Early',
    'Upgrade Required',
    'Precondition Required',
    'Too Many Requests',

    // 5xx
    'Internal Server Error',
    'Not Implemented',
    'Bad Gateway',
    'Service Unavailable',
    'Gateway Timeout',
    'HTTP Version Not Supported',
    'Variant Also Negotiates',
    'Insufficient Storage',
    'Loop Detected',
    'Not Extended',

    // Unknown
    'Unknown'
}

define_function TestNAVHttpGetStatusMessage() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpGetStatusMessage'")

    for (x = 1; x <= length_array(STATUS_MESSAGE_TEST_CODE); x++) {
        stack_var char result[NAV_MAX_CHARS]

        result = NAVHttpGetStatusMessage(STATUS_MESSAGE_TEST_CODE[x])

        if (!NAVAssertStringEqual('Should return correct status message',
                                  STATUS_MESSAGE_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            STATUS_MESSAGE_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpGetStatusMessage'")
}
