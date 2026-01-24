PROGRAM_NAME='NAVWebSocketBuildTextFrame'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char WEBSOCKET_BUILDTEXTFRAME_TEST_TEXT[][50] = {
    'Hello World',              // Test 1: Normal text
    '',                         // Test 2: Empty text
    'A',                        // Test 3: Single character
    'Test message 123',         // Test 4: Text with numbers
    'こんにちは',                // Test 5: UTF-8 multi-byte characters
    {$C0, $80},                 // Test 6: Invalid UTF-8 (overlong encoding)
    {$ED, $A0, $80},            // Test 7: Invalid UTF-8 (surrogate pair)
    {$FF, $FE},                 // Test 8: Invalid UTF-8 (invalid bytes)
    {$48, $65, $6C, $6C, $6F, $C0}  // Test 9: Invalid UTF-8 (incomplete sequence)
}

constant char WEBSOCKET_BUILDTEXTFRAME_TEST_MASKED[] = {
    true,   // Test 1: Masked
    true,   // Test 2: Masked empty
    false,  // Test 3: Unmasked
    true,   // Test 4: Masked
    false,  // Test 5: Unmasked UTF-8
    true,   // Test 6: Masked (but should fail)
    false,  // Test 7: Unmasked (but should fail)
    true,   // Test 8: Masked (but should fail)
    false   // Test 9: Unmasked (but should fail)
}

constant char WEBSOCKET_BUILDTEXTFRAME_EXPECTED_RESULT[] = {
    true,   // Test 1: Should succeed
    true,   // Test 2: Should succeed (empty is valid)
    true,   // Test 3: Should succeed
    true,   // Test 4: Should succeed
    true,   // Test 5: Should succeed (valid UTF-8)
    false,  // Test 6: Should fail (invalid UTF-8)
    false,  // Test 7: Should fail (surrogate pair)
    false,  // Test 8: Should fail (invalid bytes)
    false   // Test 9: Should fail (incomplete sequence)
}

constant integer WEBSOCKET_BUILDTEXTFRAME_MIN_LENGTH[] = {
    6,      // Test 1: Header (2 bytes) + mask (4 bytes if masked) + payload
    6,      // Test 2: Header + mask
    3,      // Test 3: Header (2 bytes) + 1 byte payload (unmasked)
    21,     // Test 4: Header + mask + 15 bytes
    17,     // Test 5: Header + 15 bytes UTF-8 (unmasked)
    0,      // Test 6: N/A (should fail)
    0,      // Test 7: N/A (should fail)
    0,      // Test 8: N/A (should fail)
    0       // Test 9: N/A (should fail)
}

define_function TestNAVWebSocketBuildTextFrame() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketBuildTextFrame'")

    for (x = 1; x <= length_array(WEBSOCKET_BUILDTEXTFRAME_TEST_TEXT); x++) {
        stack_var char output[1000]
        stack_var char result
        stack_var integer payloadLen

        result = NAVWebSocketBuildTextFrame(WEBSOCKET_BUILDTEXTFRAME_TEST_TEXT[x],
                                            WEBSOCKET_BUILDTEXTFRAME_TEST_MASKED[x],
                                            output)

        if (!NAVAssertBooleanEqual('Build should match expected result',
                                   WEBSOCKET_BUILDTEXTFRAME_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_BUILDTEXTFRAME_EXPECTED_RESULT[x]),
                            itoa(result))
            continue
        }

        if (!WEBSOCKET_BUILDTEXTFRAME_EXPECTED_RESULT[x]) {
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
                                     length_array(output) >= WEBSOCKET_BUILDTEXTFRAME_MIN_LENGTH[x])) {
            NAVLogTestFailed(x,
                            "'>= ', itoa(WEBSOCKET_BUILDTEXTFRAME_MIN_LENGTH[x])",
                            itoa(length_array(output)))
            continue
        }

        // Verify opcode is TEXT (0x01) in first byte (lower 4 bits)
        if (!NAVAssertIntegerEqual('Opcode should be TEXT (0x01)',
                                            $01,
                                            output[1] band $0F)) {
            NAVLogTestFailed(x, itoa($01), itoa(output[1] band $0F))
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
                                   WEBSOCKET_BUILDTEXTFRAME_TEST_MASKED[x],
                                   (output[2] band $80) != 0)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_BUILDTEXTFRAME_TEST_MASKED[x]),
                            itoa((output[2] band $80) != 0))
            continue
        }

        // Verify payload length encoding (lower 7 bits of byte 2)
        payloadLen = length_array(WEBSOCKET_BUILDTEXTFRAME_TEST_TEXT[x])

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

    NAVLogTestSuiteEnd("'NAVWebSocketBuildTextFrame'")
}
