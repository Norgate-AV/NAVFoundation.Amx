PROGRAM_NAME='NAVWebSocketParseFrame'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test frame data for parsing
constant char WEBSOCKET_PARSEFRAME_TEST_DATA[][25] = {
    {$81, $05, $48, $65, $6C, $6C, $6F},                    // Test 1: Text frame, unmasked, "Hello"
    {$82, $03, $01, $02, $03},                              // Test 2: Binary frame, unmasked
    {$88, $02, $03, $E8},                                   // Test 3: Close frame, status 1000
    {$89, $00},                                              // Test 4: Ping frame, empty
    {$8A, $04, $70, $6F, $6E, $67},                         // Test 5: Pong frame, "pong"
    {$01, $03, $48, $65, $6C},                              // Test 6: Fragmented text (first, not final)
    {$80, $02, $6C, $6F},                                   // Test 7: Continuation frame (final)
    {$81},                                                   // Test 8: Incomplete frame
    {$81, $85, $12, $34, $56, $78, $5A, $51, $3A, $14, $7D}, // Test 9: Masked text frame "Hello" (client->server)
    {$81, $05, $48, $65, $6C, $6C, $6F},                    // Test 10: Unmasked text from server (valid)
    {$89, $80, $12, $34, $56, $78},                         // Test 11: Masked ping frame
    {$C1, $05, $48, $65, $6C, $6C, $6F},                    // Test 12: Text frame with RSV1 set (should fail)
    {$A1, $05, $48, $65, $6C, $6C, $6F},                    // Test 13: Text frame with RSV2 set (should fail)
    {$91, $05, $48, $65, $6C, $6C, $6F},                    // Test 14: Text frame with RSV3 set (should fail)
    {$09, $00}                                               // Test 15: Ping frame with FIN=0 (should fail - control frames cannot be fragmented)
}

constant sinteger WEBSOCKET_PARSEFRAME_EXPECTED_STATUS[] = {
    0,      // Test 1: SUCCESS
    0,      // Test 2: SUCCESS
    0,      // Test 3: SUCCESS
    0,      // Test 4: SUCCESS
    0,      // Test 5: SUCCESS
    0,      // Test 6: SUCCESS
    0,      // Test 7: SUCCESS
    -2,     // Test 8: INCOMPLETE
    -9,     // Test 9: ERROR_PROTOCOL_ERROR (server must not send masked frames)
    0,      // Test 10: SUCCESS (unmasked from server)
    -9,     // Test 11: ERROR_PROTOCOL_ERROR (server must not send masked frames)
    -6,     // Test 12: ERROR_RESERVED_BITS
    -6,     // Test 13: ERROR_RESERVED_BITS
    -6,     // Test 14: ERROR_RESERVED_BITS
    -4      // Test 15: ERROR_FRAGMENTED_CTRL
}

constant integer WEBSOCKET_PARSEFRAME_EXPECTED_OPCODE[] = {
    $01,    // Test 1: TEXT
    $02,    // Test 2: BINARY
    $08,    // Test 3: CLOSE
    $09,    // Test 4: PING
    $0A,    // Test 5: PONG
    $01,    // Test 6: TEXT (first fragment)
    $00,    // Test 7: CONTINUATION
    $00,    // Test 8: N/A
    $01,    // Test 9: TEXT
    $01,    // Test 10: TEXT
    $09,    // Test 11: PING
    $00,    // Test 12: N/A (error)
    $00,    // Test 13: N/A (error)
    $00,    // Test 14: N/A (error)
    $00     // Test 15: N/A (error)
}

constant char WEBSOCKET_PARSEFRAME_EXPECTED_FIN[] = {
    true,   // Test 1: Final frame
    true,   // Test 2: Final frame
    true,   // Test 3: Final frame
    true,   // Test 4: Final frame
    true,   // Test 5: Final frame
    false,  // Test 6: Not final (fragmented)
    true,   // Test 7: Final (continuation)
    false,  // Test 8: N/A
    true,   // Test 9: Final
    true,   // Test 10: Final
    true,   // Test 11: Final
    false,  // Test 12: N/A
    false,  // Test 13: N/A
    false,  // Test 14: N/A
    false   // Test 15: Not final (but invalid)
}

constant char WEBSOCKET_PARSEFRAME_EXPECTED_PAYLOAD[][10] = {
    'Hello',        // Test 1
    {$01, $02, $03},// Test 2
    {$03, $E8},     // Test 3
    '',             // Test 4
    'pong',         // Test 5
    'Hel',          // Test 6
    'lo',           // Test 7
    '',             // Test 8
    'Hello',        // Test 9 (unmasked after parsing)
    'Hello',        // Test 10
    '',             // Test 11
    '',             // Test 12
    '',             // Test 13
    '',             // Test 14
    ''              // Test 15
}

constant integer WEBSOCKET_PARSEFRAME_EXPECTED_PAYLOAD_LENGTH[] = {
    5,  // Test 1
    3,  // Test 2
    2,  // Test 3
    0,  // Test 4
    4,  // Test 5
    3,  // Test 6
    2,  // Test 7
    0,  // Test 8
    5,  // Test 9
    5,  // Test 10
    0,  // Test 11
    0,  // Test 12
    0,  // Test 13
    0,  // Test 14
    0   // Test 15
}

define_function TestNAVWebSocketParseFrame() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketParseFrame'")

    for (x = 1; x <= length_array(WEBSOCKET_PARSEFRAME_TEST_DATA); x++) {
        stack_var _NAVWebSocketFrameParseResult parseResult
        stack_var sinteger status
        stack_var char payloadMatch

        status = NAVWebSocketParseFrame(WEBSOCKET_PARSEFRAME_TEST_DATA[x], parseResult)

        if (!NAVAssertSignedIntegerEqual('Parse status should match expected',
                                   WEBSOCKET_PARSEFRAME_EXPECTED_STATUS[x],
                                   status)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_PARSEFRAME_EXPECTED_STATUS[x]),
                            itoa(status))
            continue
        }

        // Only check frame details if parse succeeded
        if (status == 0 && x <= length_array(WEBSOCKET_PARSEFRAME_EXPECTED_OPCODE)) {
            if (!NAVAssertIntegerEqual('Opcode should match expected',
                                      WEBSOCKET_PARSEFRAME_EXPECTED_OPCODE[x],
                                      parseResult.Frame.Opcode)) {
                NAVLogTestFailed(x,
                                itoa(WEBSOCKET_PARSEFRAME_EXPECTED_OPCODE[x]),
                                itoa(parseResult.Frame.Opcode))
                continue
            }

            if (!NAVAssertBooleanEqual('FIN bit should match expected',
                                      WEBSOCKET_PARSEFRAME_EXPECTED_FIN[x],
                                      parseResult.Frame.Fin)) {
                NAVLogTestFailed(x,
                                itoa(WEBSOCKET_PARSEFRAME_EXPECTED_FIN[x]),
                                itoa(parseResult.Frame.Fin))
                continue
            }

            if (!NAVAssertLongEqual('Payload length should match expected',
                                   WEBSOCKET_PARSEFRAME_EXPECTED_PAYLOAD_LENGTH[x],
                                   parseResult.Frame.PayloadLength)) {
                NAVLogTestFailed(x,
                                itoa(WEBSOCKET_PARSEFRAME_EXPECTED_PAYLOAD_LENGTH[x]),
                                itoa(parseResult.Frame.PayloadLength))
                continue
            }

            // Verify payload content
            set_length_array(parseResult.Frame.Payload, parseResult.Frame.PayloadLength)
            if (!NAVAssertStringEqual('Payload content should match expected',
                                     WEBSOCKET_PARSEFRAME_EXPECTED_PAYLOAD[x],
                                     parseResult.Frame.Payload)) {
                NAVLogTestFailed(x, 'expected payload', 'different payload')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketParseFrame'")
}
