PROGRAM_NAME='NAVWebSocketBuildBinaryFrame'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char WEBSOCKET_BUILDBINARYFRAME_TEST_DATA[][50] = {
    {$01, $02, $03, $04, $05},          // Test 1: Normal binary data
    '',                                  // Test 2: Empty data
    {$FF},                               // Test 3: Single byte
    {$00, $00, $00, $00},               // Test 4: Zero bytes
    {$DE, $AD, $BE, $EF, $CA, $FE}     // Test 5: Hex pattern
}

constant char WEBSOCKET_BUILDBINARYFRAME_TEST_MASKED[] = {
    true,   // Test 1: Masked
    true,   // Test 2: Masked empty
    false,  // Test 3: Unmasked
    true,   // Test 4: Masked
    false   // Test 5: Unmasked
}

constant char WEBSOCKET_BUILDBINARYFRAME_EXPECTED_RESULT[] = {
    true,   // Test 1: Should succeed
    true,   // Test 2: Should succeed
    true,   // Test 3: Should succeed
    true,   // Test 4: Should succeed
    true    // Test 5: Should succeed
}

constant integer WEBSOCKET_BUILDBINARYFRAME_MIN_LENGTH[] = {
    11,     // Test 1: Header (2) + mask (4) + 5 bytes
    6,      // Test 2: Header + mask
    3,      // Test 3: Header + 1 byte (unmasked)
    10,     // Test 4: Header + mask + 4 bytes
    8       // Test 5: Header + 6 bytes (unmasked)
}

define_function TestNAVWebSocketBuildBinaryFrame() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketBuildBinaryFrame'")

    for (x = 1; x <= length_array(WEBSOCKET_BUILDBINARYFRAME_TEST_DATA); x++) {
        stack_var char output[1000]
        stack_var char result
        stack_var integer payloadLen

        result = NAVWebSocketBuildBinaryFrame(WEBSOCKET_BUILDBINARYFRAME_TEST_DATA[x],
                                              WEBSOCKET_BUILDBINARYFRAME_TEST_MASKED[x],
                                              output)

        if (!NAVAssertBooleanEqual('Build should match expected result',
                                   WEBSOCKET_BUILDBINARYFRAME_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_BUILDBINARYFRAME_EXPECTED_RESULT[x]),
                            itoa(result))
            continue
        }

        if (!WEBSOCKET_BUILDBINARYFRAME_EXPECTED_RESULT[x]) {
            // If we expected failure, no need to check further
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertTrue('Output should not be empty on success',
                                     length_array(output) > 0)) {
            NAVLogTestFailed(x, 'non-empty output', 'empty output')
            continue
        }

        if (!NAVAssertTrue('Output should be minimum expected length',
                                     length_array(output) >= WEBSOCKET_BUILDBINARYFRAME_MIN_LENGTH[x])) {
            NAVLogTestFailed(x,
                            "'>= ', itoa(WEBSOCKET_BUILDBINARYFRAME_MIN_LENGTH[x])",
                            itoa(length_array(output)))
            continue
        }

        // Verify opcode is BINARY (0x02) in first byte (lower 4 bits)
        if (!NAVAssertIntegerEqual('Opcode should be BINARY (0x02)',
                                            $02,
                                            output[1] band $0F)) {
            NAVLogTestFailed(x, itoa($02), itoa(output[1] band $0F))
            continue
        }

        // Verify FIN bit is set (bit 7)
        if (!NAVAssertTrue('FIN bit should be set for complete frame',
                          (output[1] band $80) != 0)) {
            NAVLogTestFailed(x, 'FIN=1', 'FIN=0')
            continue
        }

        // Verify MASK bit matches expected (bit 7 of byte 2)
        if (!NAVAssertBooleanEqual('MASK bit should match masked parameter',
                                   WEBSOCKET_BUILDBINARYFRAME_TEST_MASKED[x],
                                   (output[2] band $80) != 0)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_BUILDBINARYFRAME_TEST_MASKED[x]),
                            itoa((output[2] band $80) != 0))
            continue
        }

        // Verify payload length encoding (lower 7 bits of byte 2)
        payloadLen = length_array(WEBSOCKET_BUILDBINARYFRAME_TEST_DATA[x])

        if (payloadLen <= 125) {
            // Should use 7-bit encoding
            if (!NAVAssertIntegerEqual('Payload length should use 7-bit encoding',
                                       payloadLen,
                                       output[2] band $7F)) {
                NAVLogTestFailed(x, itoa(payloadLen), itoa(output[2] band $7F))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketBuildBinaryFrame'")
}
