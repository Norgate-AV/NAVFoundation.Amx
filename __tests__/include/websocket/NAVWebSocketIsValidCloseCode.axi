PROGRAM_NAME='NAVWebSocketIsValidCloseCode'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant integer WEBSOCKET_ISVALIDCLOSECODE_TEST_CODE[] = {
    999,    // Test 1: Below valid range
    1000,   // Test 2: NORMAL_CLOSURE - valid
    1001,   // Test 3: GOING_AWAY - valid
    1002,   // Test 4: PROTOCOL_ERROR - valid
    1003,   // Test 5: UNSUPPORTED_DATA - valid
    1004,   // Test 6: Reserved - invalid
    1005,   // Test 7: NO_STATUS - reserved, invalid on wire
    1006,   // Test 8: ABNORMAL - reserved, invalid on wire
    1007,   // Test 9: INVALID_PAYLOAD - valid
    1008,   // Test 10: POLICY_VIOLATION - valid
    1009,   // Test 11: MESSAGE_TOO_BIG - valid
    1010,   // Test 12: MANDATORY_EXT - valid
    1011,   // Test 13: INTERNAL_ERROR - valid
    1015,   // Test 14: TLS_HANDSHAKE - reserved, invalid on wire
    2999,   // Test 15: End of standard range - valid
    3000,   // Test 16: Start of library range - valid
    3999,   // Test 17: End of library range - valid
    4000,   // Test 18: Start of private range - valid
    4999    // Test 19: End of private range - valid
}

constant char WEBSOCKET_ISVALIDCLOSECODE_EXPECTED[] = {
    false,  // Test 1: < 1000
    true,   // Test 2: 1000
    true,   // Test 3: 1001
    true,   // Test 4: 1002
    true,   // Test 5: 1003
    false,  // Test 6: 1004 reserved
    false,  // Test 7: 1005 reserved
    false,  // Test 8: 1006 reserved
    true,   // Test 9: 1007
    true,   // Test 10: 1008
    true,   // Test 11: 1009
    true,   // Test 12: 1010
    true,   // Test 13: 1011
    false,  // Test 14: 1015 reserved
    true,   // Test 15: 2999
    true,   // Test 16: 3000
    true,   // Test 17: 3999
    true,   // Test 18: 4000
    true    // Test 19: 4999
}

define_function TestNAVWebSocketIsValidCloseCode() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketIsValidCloseCode'")

    for (x = 1; x <= length_array(WEBSOCKET_ISVALIDCLOSECODE_TEST_CODE); x++) {
        stack_var char result

        result = NAVWebSocketIsValidCloseCode(WEBSOCKET_ISVALIDCLOSECODE_TEST_CODE[x])

        if (!NAVAssertBooleanEqual('Close code validation should match expected result',
                                   WEBSOCKET_ISVALIDCLOSECODE_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_ISVALIDCLOSECODE_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketIsValidCloseCode'")
}
