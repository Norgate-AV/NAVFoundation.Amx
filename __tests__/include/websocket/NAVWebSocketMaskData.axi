PROGRAM_NAME='NAVWebSocketMaskData'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test vectors for masking operations
// XOR masking is reversible: data XOR key = masked, masked XOR key = data

constant char WEBSOCKET_MASKDATA_TEST_DATA[][20] = {
    'Hello',                        // Test 1: Normal masking
    'Test',                         // Test 2: Masking with zero key (no change)
    {$FF, $FF, $FF, $FF},          // Test 3: Masking all 0xFF bytes
    '',                             // Test 4: Empty data
    {$41, $42, $43, $44, $45, $46, $47, $48}  // Test 5: 8 bytes for key cycle test
}

constant char WEBSOCKET_MASKDATA_TEST_KEYS[][4] = {
    {$12, $34, $56, $78},          // Test 1
    {$00, $00, $00, $00},          // Test 2: Zero key
    {$AA, $BB, $CC, $DD},          // Test 3
    {$12, $34, $56, $78},          // Test 4
    {$01, $02, $03, $04}           // Test 5
}

constant char WEBSOCKET_MASKDATA_EXPECTED[][20] = {
    {$5A, $51, $3A, $14, $7D},     // Test 1: "Hello" XOR {$12, $34, $56, $78, $12}
    'Test',                         // Test 2: XOR with zeros = unchanged
    {$55, $44, $33, $22},          // Test 3: 0xFF XOR key
    '',                             // Test 4: Empty
    {$40, $40, $40, $40, $44, $44, $44, $4C}  // Test 5: Pattern showing key cycling
}

constant integer WEBSOCKET_MASKDATA_EXPECTED_LENGTH[] = {
    5,      // Test 1
    4,      // Test 2
    4,      // Test 3
    0,      // Test 4
    8       // Test 5
}

define_function TestNAVWebSocketMaskData() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketMaskData'")

    for (x = 1; x <= length_array(WEBSOCKET_MASKDATA_TEST_DATA); x++) {
        stack_var char output[100]
        stack_var char input[20]
        stack_var long length

        // Copy test data with proper length
        input = WEBSOCKET_MASKDATA_TEST_DATA[x]
        set_length_array(input, WEBSOCKET_MASKDATA_EXPECTED_LENGTH[x])

        length = NAVWebSocketMaskData(input,
                                      WEBSOCKET_MASKDATA_TEST_KEYS[x],
                                      output)

        // Set output length for comparison
        set_length_array(output, length)

        if (!NAVAssertLongEqual('Masked length should match expected',
                               WEBSOCKET_MASKDATA_EXPECTED_LENGTH[x],
                               length)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_MASKDATA_EXPECTED_LENGTH[x]),
                            itoa(length))
            continue
        }

        if (!NAVAssertStringEqual('Masked data should match expected',
                                  WEBSOCKET_MASKDATA_EXPECTED[x],
                                  output)) {
            NAVLogTestFailed(x, 'expected masked data', 'different data')
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketMaskData'")
}
