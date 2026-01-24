PROGRAM_NAME='NAVWebSocketBuildPongFrame'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char WEBSOCKET_BUILDPONGFRAME_TEST_PAYLOAD[][130] = {
    'pong',                     // Test 1: Normal payload
    '',                         // Test 2: Empty payload
    {$01, $02, $03},           // Test 3: Binary payload
    'y',                        // Test 4: Single byte
    '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345',  // Test 5: Exactly 125 bytes
    '123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456'   // Test 6: 126 bytes (should fail)
}

constant char WEBSOCKET_BUILDPONGFRAME_TEST_MASKED[] = {
    true,   // Test 1: Masked
    true,   // Test 2: Masked
    false,  // Test 3: Unmasked
    true,   // Test 4: Masked
    false,  // Test 5: Unmasked (max size)
    true    // Test 6: Masked (but should fail)
}

constant char WEBSOCKET_BUILDPONGFRAME_EXPECTED_RESULT[] = {
    true,   // Test 1: Valid
    true,   // Test 2: Valid (empty ok)
    true,   // Test 3: Valid
    true,   // Test 4: Valid
    true,   // Test 5: Valid (exactly 125)
    false   // Test 6: Invalid (>125 bytes)
}

define_function TestNAVWebSocketBuildPongFrame() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketBuildPongFrame'")

    for (x = 1; x <= length_array(WEBSOCKET_BUILDPONGFRAME_TEST_PAYLOAD); x++) {
        stack_var char output[1000]
        stack_var char result
        stack_var integer payloadLen

        result = NAVWebSocketBuildPongFrame(WEBSOCKET_BUILDPONGFRAME_TEST_PAYLOAD[x],
                                            WEBSOCKET_BUILDPONGFRAME_TEST_MASKED[x],
                                            output)

        if (!NAVAssertBooleanEqual('Build should match expected result',
                                   WEBSOCKET_BUILDPONGFRAME_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_BUILDPONGFRAME_EXPECTED_RESULT[x]),
                            itoa(result))
            continue
        }

        if (!WEBSOCKET_BUILDPONGFRAME_EXPECTED_RESULT[x]) {
            // If we expected failure, no need to check further
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertTrue('Output should not be empty on success',
                                     length_array(output) > 0)) {
            NAVLogTestFailed(x, 'non-empty output', 'empty output')
            continue
        }

        // Verify opcode is PONG (0x0A) in first byte (lower 4 bits)
        if (!NAVAssertIntegerEqual('Opcode should be PONG (0x0A)',
                                            $0A,
                                            output[1] band $0F)) {
            NAVLogTestFailed(x, itoa($0A), itoa(output[1] band $0F))
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
                                   WEBSOCKET_BUILDPONGFRAME_TEST_MASKED[x],
                                   (output[2] band $80) != 0)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_BUILDPONGFRAME_TEST_MASKED[x]),
                            itoa((output[2] band $80) != 0))
            continue
        }

        // Verify payload length <= 125 for control frames
        payloadLen = length_array(WEBSOCKET_BUILDPONGFRAME_TEST_PAYLOAD[x])

        if (!NAVAssertIntegerEqual('Payload length should match',
                                   payloadLen,
                                   output[2] band $7F)) {
            NAVLogTestFailed(x, itoa(payloadLen), itoa(output[2] band $7F))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketBuildPongFrame'")
}
