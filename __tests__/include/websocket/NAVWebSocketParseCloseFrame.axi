PROGRAM_NAME='NAVWebSocketParseCloseFrame'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test close frame data (frame structures for parsing)
// Close frames: opcode 0x08, payload = 2-byte status code + optional reason

constant integer WEBSOCKET_PARSECLOSEFRAME_TEST_STATUS_CODE[] = {
    1000,   // Test 1: NORMAL_CLOSURE
    1001,   // Test 2: GOING_AWAY
    1002,   // Test 3: PROTOCOL_ERROR
    1003,   // Test 4: UNSUPPORTED_DATA
    1007,   // Test 5: INVALID_PAYLOAD
    1009,   // Test 6: MESSAGE_TOO_BIG
    1005,   // Test 7: Empty payload (NO_STATUS - 1005 per RFC 6455)
    1000,   // Test 8: 1 byte payload (invalid - needs 2 bytes)
    1000    // Test 9: Invalid UTF-8 in reason
}

constant char WEBSOCKET_PARSECLOSEFRAME_TEST_REASON[][30] = {
    'Normal',                   // Test 1
    '',                         // Test 2: Empty reason
    'Protocol error',           // Test 3
    'Bad data',                // Test 4
    'Invalid UTF-8',           // Test 5
    'Too large',               // Test 6
    '',                        // Test 7: No reason (empty payload)
    '',                        // Test 8: Invalid payload length
    {$C0, $80}                 // Test 9: Invalid UTF-8 (overlong encoding)
}

constant sinteger WEBSOCKET_PARSECLOSEFRAME_EXPECTED_STATUS[] = {
    0,      // Test 1: SUCCESS
    0,      // Test 2: SUCCESS
    0,      // Test 3: SUCCESS
    0,      // Test 4: SUCCESS
    0,      // Test 5: SUCCESS
    0,      // Test 6: SUCCESS
    0,      // Test 7: SUCCESS (empty payload is valid, returns NO_STATUS 1005)
    -1,     // Test 8: ERROR_INVALID_FRAME (1 byte not allowed, need 0 or 2+)
    -10     // Test 9: ERROR_INVALID_UTF8 (invalid encoding in reason)
}

constant char WEBSOCKET_PARSECLOSEFRAME_BUILD_PAYLOAD[] = {
    true,   // Test 1: Build payload
    true,   // Test 2: Build payload
    true,   // Test 3: Build payload
    true,   // Test 4: Build payload
    true,   // Test 5: Build payload
    true,   // Test 6: Build payload
    false,  // Test 7: Don't build (empty)
    true,   // Test 8: Build 1 byte only
    true    // Test 9: Build payload with invalid UTF-8
}

define_function TestNAVWebSocketParseCloseFrame() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketParseCloseFrame'")

    for (x = 1; x <= length_array(WEBSOCKET_PARSECLOSEFRAME_TEST_STATUS_CODE); x++) {
        stack_var _NAVWebSocketFrame frame
        stack_var _NAVWebSocketCloseFrame closeData
        stack_var sinteger status
        stack_var char payload[100]
        stack_var char statusBytes[2]

        // Build close frame payload based on test case
        if (!WEBSOCKET_PARSECLOSEFRAME_BUILD_PAYLOAD[x]) {
            // Test 7: Empty payload
            set_length_array(payload, 0)
        }
        else if (x == 8) {
            // Test 8: 1 byte payload (invalid)
            payload[1] = type_cast(WEBSOCKET_PARSECLOSEFRAME_TEST_STATUS_CODE[x] >> 8)
            set_length_array(payload, 1)
        }
        else {
            // Build close frame payload: 2-byte status code (big-endian) + reason
            statusBytes[1] = type_cast(WEBSOCKET_PARSECLOSEFRAME_TEST_STATUS_CODE[x] >> 8)
            statusBytes[2] = type_cast(WEBSOCKET_PARSECLOSEFRAME_TEST_STATUS_CODE[x] band $FF)
            set_length_array(statusBytes, 2)
            payload = "statusBytes, WEBSOCKET_PARSECLOSEFRAME_TEST_REASON[x]"
        }

        frame.Opcode = $08  // CLOSE
        frame.Payload = payload
        frame.PayloadLength = length_array(payload)

        status = NAVWebSocketParseCloseFrame(frame, closeData)

        if (!NAVAssertSignedIntegerEqual('Parse status should match expected',
                                   WEBSOCKET_PARSECLOSEFRAME_EXPECTED_STATUS[x],
                                   status)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_PARSECLOSEFRAME_EXPECTED_STATUS[x]),
                            itoa(status))
            continue
        }

        if (WEBSOCKET_PARSECLOSEFRAME_EXPECTED_STATUS[x] != 0) {
            // If we expected failure, no need to check further
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertIntegerEqual('Status code should match',
                                    WEBSOCKET_PARSECLOSEFRAME_TEST_STATUS_CODE[x],
                                    closeData.StatusCode)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_PARSECLOSEFRAME_TEST_STATUS_CODE[x]),
                            itoa(closeData.StatusCode))
            continue
        }

        if (!NAVAssertStringEqual('Reason should match',
                                    WEBSOCKET_PARSECLOSEFRAME_TEST_REASON[x],
                                    closeData.Reason)) {
            NAVLogTestFailed(x,
                            WEBSOCKET_PARSECLOSEFRAME_TEST_REASON[x],
                            closeData.Reason)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketParseCloseFrame'")
}
