PROGRAM_NAME='NAVWebSocketIsValidOpcode'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant integer WEBSOCKET_ISVALIDOPCODE_TEST_OPCODE[] = {
    $00,    // Test 1: CONTINUATION - valid
    $01,    // Test 2: TEXT - valid
    $02,    // Test 3: BINARY - valid
    $03,    // Test 4: Reserved data opcode
    $07,    // Test 5: Reserved data opcode
    $08,    // Test 6: CLOSE - valid control
    $09,    // Test 7: PING - valid control
    $0A,    // Test 8: PONG - valid control
    $0B,    // Test 9: Reserved control opcode
    $0F,    // Test 10: Reserved control opcode
    $FF     // Test 11: Invalid opcode
}

constant char WEBSOCKET_ISVALIDOPCODE_EXPECTED[] = {
    true,   // Test 1: CONTINUATION
    true,   // Test 2: TEXT
    true,   // Test 3: BINARY
    false,  // Test 4: Reserved (0x03)
    false,  // Test 5: Reserved (0x07)
    true,   // Test 6: CLOSE
    true,   // Test 7: PING
    true,   // Test 8: PONG
    false,  // Test 9: Reserved (0x0B)
    false,  // Test 10: Reserved (0x0F)
    false   // Test 11: Invalid (0xFF)
}

define_function TestNAVWebSocketIsValidOpcode() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketIsValidOpcode'")

    for (x = 1; x <= length_array(WEBSOCKET_ISVALIDOPCODE_TEST_OPCODE); x++) {
        stack_var char result

        result = NAVWebSocketIsValidOpcode(WEBSOCKET_ISVALIDOPCODE_TEST_OPCODE[x])

        if (!NAVAssertBooleanEqual('Opcode validation should match expected result',
                                   WEBSOCKET_ISVALIDOPCODE_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_ISVALIDOPCODE_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketIsValidOpcode'")
}
