PROGRAM_NAME='NAVWebSocketGetFrameLength'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test frame data with various payload lengths
constant char WEBSOCKET_GETFRAMELENGTH_TEST_DATA[][150] = {
    {$81, $05, $48, $65, $6C, $6C, $6F},                    // Test 1: 5 byte payload, unmasked
    {$81, $85, $12, $34, $56, $78, $5A, $55, $3E, $1C, $5F},  // Test 2: 5 byte payload, masked
    {$81, $00},                                              // Test 3: 0 byte payload, unmasked
    {$81, $80, $12, $34, $56, $78},                         // Test 4: 0 byte payload, masked
    {$81, $7E, $00, $7D, $00, $00, $00},                    // Test 5: 125 bytes (16-bit length) - header only for length calc
    {$81, $7F, $00, $00, $00, $00, $00, $00, $00, $64},     // Test 6: 100 bytes (64-bit length) - header only
    {$81, $FE, $00, $7D, $12, $34, $56, $78},               // Test 7: 125 bytes masked (16-bit) - header only
    {$81}                                                    // Test 8: Incomplete header
}

constant slong WEBSOCKET_GETFRAMELENGTH_EXPECTED[] = {
    7,      // Test 1: 2 (header) + 5 (payload)
    11,     // Test 2: 2 (header) + 4 (mask) + 5 (payload)
    2,      // Test 3: 2 (header) + 0 (payload)
    6,      // Test 4: 2 (header) + 4 (mask) + 0 (payload)
    -2,     // Test 5: Incomplete - need full 16-bit extended length + payload
    -2,     // Test 6: Incomplete - need full 64-bit extended length + payload
    -2,     // Test 7: Incomplete - need full 16-bit extended length + mask + payload
    -2      // Test 8: Incomplete - need at least 2 bytes for basic header
}

define_function TestNAVWebSocketGetFrameLength() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVWebSocketGetFrameLength'")

    for (x = 1; x <= length_array(WEBSOCKET_GETFRAMELENGTH_TEST_DATA); x++) {
        stack_var slong result

        result = NAVWebSocketGetFrameLength(WEBSOCKET_GETFRAMELENGTH_TEST_DATA[x])

        if (!NAVAssertSignedLongEqual('Frame length should match expected',
                                 WEBSOCKET_GETFRAMELENGTH_EXPECTED[x],
                                 result)) {
            NAVLogTestFailed(x,
                            itoa(WEBSOCKET_GETFRAMELENGTH_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVWebSocketGetFrameLength'")
}
