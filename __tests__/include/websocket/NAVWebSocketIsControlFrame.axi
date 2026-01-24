PROGRAM_NAME='NAVWebSocketIsControlFrame'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant integer WEBSOCKET_ISCONTROLFRAME_TEST_OPCODE[] = {
    $00,    // Test 1: CONTINUATION - not control
    $01,    // Test 2: TEXT - not control
    $02,    // Test 3: BINARY - not control
    $03,    // Test 4: Reserved data - not control
    $07,    // Test 5: Reserved data - not control
    $08,    // Test 6: CLOSE - control
    $09,    // Test 7: PING - control
    $0A     // Test 8: PONG - control
}

constant char WEBSOCKET_ISCONTROLFRAME_EXPECTED[] = {
    false,  // Test 1: CONTINUATION
    false,  // Test 2: TEXT
    false,  // Test 3: BINARY
    false,  // Test 4: Reserved data
    false,  // Test 5: Reserved data
    true,   // Test 6: CLOSE
    true,   // Test 7: PING
    true    // Test 8: PONG
}

define_function TestNAVWebSocketIsControlFrame() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketIsControlFrame'")

    for (x = 1; x <= length_array(WEBSOCKET_ISCONTROLFRAME_TEST_OPCODE); x++) {
        stack_var char result

        result = NAVWebSocketIsControlFrame(WEBSOCKET_ISCONTROLFRAME_TEST_OPCODE[x])

        if (!NAVAssertBooleanEqual('Control frame detection should match expected result',
                                   WEBSOCKET_ISCONTROLFRAME_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_ISCONTROLFRAME_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketIsControlFrame'")
}
