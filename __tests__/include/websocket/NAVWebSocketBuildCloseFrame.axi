PROGRAM_NAME='NAVWebSocketBuildCloseFrame'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant integer WEBSOCKET_BUILDCLOSEFRAME_TEST_CODE[] = {
    1000,   // Test 1: NORMAL_CLOSURE
    1001,   // Test 2: GOING_AWAY
    1002,   // Test 3: PROTOCOL_ERROR
    1003,   // Test 4: UNSUPPORTED_DATA
    1007,   // Test 5: INVALID_PAYLOAD
    1009,   // Test 6: MESSAGE_TOO_BIG
    1004,   // Test 7: Reserved code (should fail)
    999,    // Test 8: Invalid code < 1000 (should fail)
    1000,   // Test 9: Invalid UTF-8 in reason (should fail)
    1000,   // Test 10: Close with empty reason (valid)
    1008    // Test 11: POLICY_VIOLATION
}

constant char WEBSOCKET_BUILDCLOSEFRAME_TEST_REASON[][50] = {
    'Normal closure',           // Test 1
    '',                         // Test 2: Empty reason
    'Protocol error occurred',  // Test 3
    'Unsupported data',        // Test 4
    'Invalid UTF-8',           // Test 5
    'Too big',                 // Test 6
    'Should fail',             // Test 7
    'Invalid',                 // Test 8
    {$C0, $80},                // Test 9: Invalid UTF-8 (overlong)
    '',                        // Test 10: Empty reason (valid)
    'Policy violation'         // Test 11
}

constant char WEBSOCKET_BUILDCLOSEFRAME_TEST_MASKED[] = {
    true,   // Test 1: Masked
    true,   // Test 2: Masked
    false,  // Test 3: Unmasked
    true,   // Test 4: Masked
    false,  // Test 5: Unmasked
    true,   // Test 6: Masked
    true,   // Test 7: Masked (but should fail)
    true,   // Test 8: Masked (but should fail)
    true,   // Test 9: Masked (but should fail - invalid UTF-8)
    false,  // Test 10: Unmasked
    true    // Test 11: Masked
}

constant char WEBSOCKET_BUILDCLOSEFRAME_EXPECTED_RESULT[] = {
    true,   // Test 1: Valid
    true,   // Test 2: Valid (empty reason ok)
    true,   // Test 3: Valid
    true,   // Test 4: Valid
    true,   // Test 5: Valid
    true,   // Test 6: Valid
    false,  // Test 7: Invalid (1004 reserved)
    false,  // Test 8: Invalid (< 1000)
    false,  // Test 9: Invalid (UTF-8 in reason)
    true,   // Test 10: Valid (empty reason)
    true    // Test 11: Valid
}

define_function TestNAVWebSocketBuildCloseFrame() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketBuildCloseFrame'")

    for (x = 1; x <= length_array(WEBSOCKET_BUILDCLOSEFRAME_TEST_CODE); x++) {
        stack_var char output[1000]
        stack_var char result
        stack_var integer expectedLen

        result = NAVWebSocketBuildCloseFrame(WEBSOCKET_BUILDCLOSEFRAME_TEST_CODE[x],
                                             WEBSOCKET_BUILDCLOSEFRAME_TEST_REASON[x],
                                             WEBSOCKET_BUILDCLOSEFRAME_TEST_MASKED[x],
                                             output)

        if (!NAVAssertBooleanEqual('Build should match expected result',
                                   WEBSOCKET_BUILDCLOSEFRAME_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_BUILDCLOSEFRAME_EXPECTED_RESULT[x]),
                            itoa(result))
            continue
        }

        if (!WEBSOCKET_BUILDCLOSEFRAME_EXPECTED_RESULT[x]) {
            // If we expected failure, no need to check further
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertTrue('Output should not be empty on success',
                                     length_array(output) > 0)) {
            NAVLogTestFailed(x, 'non-empty output', 'empty output')
            continue
        }

        // Verify opcode is CLOSE (0x08) in first byte (lower 4 bits)
        if (!NAVAssertIntegerEqual('Opcode should be CLOSE (0x08)',
                                            $08,
                                            output[1] band $0F)) {
            NAVLogTestFailed(x, itoa($08), itoa(output[1] band $0F))
            continue
        }

        // Verify FIN bit is set (bit 7) - control frames must not be fragmented
        if (!NAVAssertTrue('FIN bit should be set for control frame',
                          (output[1] band $80) != 0)) {
            NAVLogTestFailed(x, 'FIN=1', 'FIN=0')
            continue
        }

        // Verify MASK bit matches expected (bit 7 of byte 2)
        if (!NAVAssertBooleanEqual('MASK bit should match masked parameter',
                                   WEBSOCKET_BUILDCLOSEFRAME_TEST_MASKED[x],
                                   (output[2] band $80) != 0)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_BUILDCLOSEFRAME_TEST_MASKED[x]),
                            itoa((output[2] band $80) != 0))
            continue
        }

        // Verify payload length (2 bytes status code + reason length)
        expectedLen = 2 + length_array(WEBSOCKET_BUILDCLOSEFRAME_TEST_REASON[x])

        if (expectedLen <= 125) {
            // Should use 7-bit encoding
            if (!NAVAssertIntegerEqual('Payload length should be status code (2) + reason length',
                                       expectedLen,
                                       output[2] band $7F)) {
                NAVLogTestFailed(x, itoa(expectedLen), itoa(output[2] band $7F))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketBuildCloseFrame'")
}
