PROGRAM_NAME='NAVHttpGetDefaultPort'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

DEFINE_CONSTANT

// Test vectors for NAVHttpGetDefaultPort
constant char GET_DEFAULT_PORT_TEST_SCHEME[][10] = {
    'http',      // Test 1: Standard HTTP
    'https',     // Test 2: Standard HTTPS
    'HTTP',      // Test 3: Uppercase HTTP
    'HTTPS',     // Test 4: Uppercase HTTPS
    'ftp',       // Test 5: Unknown scheme (should default to http)
    'ws',        // Test 6: Unknown scheme (should default to http)
    '',          // Test 7: Empty scheme (should default to http)
    'custom'     // Test 8: Custom scheme (should default to http)
}

constant integer GET_DEFAULT_PORT_EXPECTED[] = {
    80,    // Test 1: http
    443,   // Test 2: https
    80,    // Test 3: HTTP
    443,   // Test 4: HTTPS
    80,    // Test 5: Unknown defaults to http
    80,    // Test 6: Unknown defaults to http
    80,    // Test 7: Empty defaults to http
    80     // Test 8: Custom defaults to http
}

define_function TestNAVHttpGetDefaultPort() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVHttpGetDefaultPort'")

    for (x = 1; x <= length_array(GET_DEFAULT_PORT_TEST_SCHEME); x++) {
        stack_var integer result

        result = NAVHttpGetDefaultPort(GET_DEFAULT_PORT_TEST_SCHEME[x])

        if (!NAVAssertIntegerEqual('Should return correct default port',
                                   GET_DEFAULT_PORT_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(GET_DEFAULT_PORT_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVHttpGetDefaultPort'")
}
