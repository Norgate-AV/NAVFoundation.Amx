PROGRAM_NAME='NAVWebSocketBuildHandshakeRequest'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char WEBSOCKET_BUILDHANDSHAKEREQUEST_TEST_URL[][50] = {
    'ws://localhost:8080',                      // Test 1: Basic ws URL
    'ws://example.com',                         // Test 2: No port (default 80)
    'wss://secure.example.com:443',            // Test 3: Secure WebSocket
    'ws://192.168.1.100:3000',                 // Test 4: IP address
    'ws://localhost:8080/path',                // Test 5: With path
    'ws://localhost:8080/path?query=value'     // Test 6: With query string
}

constant char WEBSOCKET_BUILDHANDSHAKEREQUEST_EXPECTED_RESULT[] = {
    true,   // Test 1: Valid
    true,   // Test 2: Valid
    true,   // Test 3: Valid
    true,   // Test 4: Valid
    true,   // Test 5: Valid
    true    // Test 6: Valid
}

define_function TestNAVWebSocketBuildHandshakeRequest() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketBuildHandshakeRequest'")

    for (x = 1; x <= length_array(WEBSOCKET_BUILDHANDSHAKEREQUEST_TEST_URL); x++) {
        stack_var char output[2000]
        stack_var char key[16]
        stack_var char result

        result = NAVWebSocketBuildHandshakeRequest(WEBSOCKET_BUILDHANDSHAKEREQUEST_TEST_URL[x],
                                                   output,
                                                   key)

        if (!NAVAssertBooleanEqual('Build should match expected result',
                                   WEBSOCKET_BUILDHANDSHAKEREQUEST_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_BUILDHANDSHAKEREQUEST_EXPECTED_RESULT[x]),
                            itoa(result))
            continue
        }

        if (!WEBSOCKET_BUILDHANDSHAKEREQUEST_EXPECTED_RESULT[x]) {
            // If we expected failure, no need to check further
            NAVLogTestPassed(x)
            continue
        }

        // Verify output contains required headers
        if (!NAVAssertTrue('Output should contain GET',
                            find_string(output, 'GET', 1) > 0)) {
            NAVLogTestFailed(x, 'Contains GET', 'Missing GET')
            continue
        }

        if (!NAVAssertTrue('Output should contain Upgrade: websocket',
                            find_string(output, 'Upgrade: websocket', 1) > 0)) {
            NAVLogTestFailed(x, 'Contains Upgrade header', 'Missing Upgrade')
            continue
        }

        if (!NAVAssertTrue('Output should contain Sec-WebSocket-Key',
                            find_string(output, 'Sec-WebSocket-Key:', 1) > 0)) {
            NAVLogTestFailed(x, 'Contains Sec-WebSocket-Key', 'Missing key')
            continue
        }

        if (!NAVAssertTrue('Key should be 16 bytes',
                            length_array(key) == 16)) {
            NAVLogTestFailed(x, '16 bytes', itoa(length_array(key)))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketBuildHandshakeRequest'")
}
