PROGRAM_NAME='NAVWebSocketValidateHandshakeResponse'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test handshake responses with known keys and accept values
constant char WEBSOCKET_VALIDATEHANDSHAKERESPONSE_TEST_KEY[][16] = {
    {$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F},  // Test 1: Valid key
    {$10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F},  // Test 2: Different key
    {$AA, $BB, $CC, $DD, $EE, $FF, $00, $11, $22, $33, $44, $55, $66, $77, $88, $99},  // Test 3: Another key
    {$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F},  // Test 4: Valid key (malformed response)
    {$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F}   // Test 5: Valid key (missing header)
}

constant char WEBSOCKET_VALIDATEHANDSHAKERESPONSE_EXPECTED[] = {
    true,   // Test 1: Valid
    true,   // Test 2: Valid
    false,  // Test 3: Invalid accept
    false,  // Test 4: Wrong status
    false   // Test 5: Missing header
}


DEFINE_VARIABLE

volatile char WEBSOCKET_VALIDATEHANDSHAKERESPONSE_TEST_RESPONSE[5][300]


define_function InitializeValidateHandshakeResponseTestData() {
    // Test 1: Valid response with correct accept for key {$00..$0F}
    // Base64 key AAECAwQFBgcICQoLDA0ODw== generates accept Bz3qJYTGdOe8gUSpLosEdiLKDrk=
    WEBSOCKET_VALIDATEHANDSHAKERESPONSE_TEST_RESPONSE[1] = "
        'HTTP/1.1 101 Switching Protocols',
        $0D, $0A,
        'Upgrade: websocket',
        $0D, $0A,
        'Connection: Upgrade',
        $0D, $0A,
        'Sec-WebSocket-Accept: Bz3qJYTGdOe8gUSpLosEdiLKDrk=',
        $0D, $0A, $0D, $0A
    "

    // Test 2: Valid response with correct accept for key {$10..$1F}
    // Base64 key EBESExQVFhcYGRobHB0eHw== generates accept cW0HMpChSOllUrDZnf5AIF3ENuY=
    WEBSOCKET_VALIDATEHANDSHAKERESPONSE_TEST_RESPONSE[2] = "
        'HTTP/1.1 101 Switching Protocols',
        $0D, $0A,
        'Upgrade: websocket',
        $0D, $0A,
        'Connection: Upgrade',
        $0D, $0A,
        'Sec-WebSocket-Accept: cW0HMpChSOllUrDZnf5AIF3ENuY=',
        $0D, $0A, $0D, $0A
    "

    // Test 3: Invalid accept value
    WEBSOCKET_VALIDATEHANDSHAKERESPONSE_TEST_RESPONSE[3] = "
        'HTTP/1.1 101 Switching Protocols',
        $0D, $0A,
        'Upgrade: websocket',
        $0D, $0A,
        'Connection: Upgrade',
        $0D, $0A,
        'Sec-WebSocket-Accept: wrongacceptvalue',
        $0D, $0A, $0D, $0A
    "

    // Test 4: Wrong status code
    WEBSOCKET_VALIDATEHANDSHAKERESPONSE_TEST_RESPONSE[4] = "
        'HTTP/1.1 400 Bad Request',
        $0D, $0A, $0D, $0A
    "

    // Test 5: Missing Sec-WebSocket-Accept header
    WEBSOCKET_VALIDATEHANDSHAKERESPONSE_TEST_RESPONSE[5] = "
        'HTTP/1.1 101 Switching Protocols',
        $0D, $0A,
        'Upgrade: websocket',
        $0D, $0A,
        'Connection: Upgrade',
        $0D, $0A, $0D, $0A
    "
}

define_function TestNAVWebSocketValidateHandshakeResponse() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketValidateHandshakeResponse'")

    InitializeValidateHandshakeResponseTestData()

    for (x = 1; x <= length_array(WEBSOCKET_VALIDATEHANDSHAKERESPONSE_TEST_KEY); x++) {
        stack_var char result

        result = NAVWebSocketValidateHandshakeResponse(WEBSOCKET_VALIDATEHANDSHAKERESPONSE_TEST_RESPONSE[x],
            WEBSOCKET_VALIDATEHANDSHAKERESPONSE_TEST_KEY[x])

        if (!NAVAssertBooleanEqual('Validation should match expected result',
                                   WEBSOCKET_VALIDATEHANDSHAKERESPONSE_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_VALIDATEHANDSHAKERESPONSE_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketValidateHandshakeResponse'")
}
