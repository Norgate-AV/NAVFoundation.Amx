PROGRAM_NAME='NAVJsonEscapeString'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_ESCAPE_STRING_TEST[20][256]


define_function InitializeJsonEscapeStringTestData() {
    // Test 1: Simple string without special characters
    JSON_ESCAPE_STRING_TEST[1] = 'Hello World'

    // Test 2: String with quotation marks
    JSON_ESCAPE_STRING_TEST[2] = 'Hello "World"'

    // Test 3: String with backslashes
    JSON_ESCAPE_STRING_TEST[3] = 'Path\to\file'

    // Test 4: String with forward slashes
    JSON_ESCAPE_STRING_TEST[4] = 'http://example.com/path'

    // Test 5: String with newline
    JSON_ESCAPE_STRING_TEST[5] = "'Line1', $0A, 'Line2'"

    // Test 6: String with carriage return
    JSON_ESCAPE_STRING_TEST[6] = "'Before', $0D, 'After'"

    // Test 7: String with tab
    JSON_ESCAPE_STRING_TEST[7] = "'Column1', $09, 'Column2'"

    // Test 8: String with backspace
    JSON_ESCAPE_STRING_TEST[8] = "'Text', $08, 'Back'"

    // Test 9: String with form feed
    JSON_ESCAPE_STRING_TEST[9] = "'Page1', $0C, 'Page2'"

    // Test 10: Multiple escape sequences
    JSON_ESCAPE_STRING_TEST[10] = "'Quote: "Hi"', $0A, 'Tab:', $09, 'End'"

    // Test 11: Empty string
    JSON_ESCAPE_STRING_TEST[11] = ''

    // Test 12: String with all basic escapes
    JSON_ESCAPE_STRING_TEST[12] = "'"\/', $08, $0C, $0A, $0D, $09"

    // Test 13: Control character (bell)
    JSON_ESCAPE_STRING_TEST[13] = "'Alert:', $07"

    // Test 14: Control character (null)
    JSON_ESCAPE_STRING_TEST[14] = "'Start', $00, 'End'"

    // Test 15: Control character (escape)
    JSON_ESCAPE_STRING_TEST[15] = "'Escape:', $1B"

    // Test 16: Mixed quotes and newlines
    JSON_ESCAPE_STRING_TEST[16] = "'She said "Hello"', $0A, 'He replied "Hi"'"

    // Test 17: Path with backslashes
    JSON_ESCAPE_STRING_TEST[17] = 'C:\Users\Documents\file.txt'

    // Test 18: JSON-like string
    JSON_ESCAPE_STRING_TEST[18] = '{"key":"value"}'

    // Test 19: Multiple consecutive escapes
    JSON_ESCAPE_STRING_TEST[19] = "$0A, $0D, $09"

    // Test 20: Unicode control character range
    JSON_ESCAPE_STRING_TEST[20] = "'Start', $01, $02, $03, 'End'"

    set_length_array(JSON_ESCAPE_STRING_TEST, 20)
}


DEFINE_CONSTANT

constant char JSON_ESCAPE_STRING_EXPECTED[20][512] = {
    'Hello World',                                      // Test 1
    'Hello \"World\"',                                  // Test 2
    'Path\\to\\file',                                   // Test 3
    'http:\/\/example.com\/path',                       // Test 4
    'Line1\nLine2',                                     // Test 5
    'Before\rAfter',                                    // Test 6
    'Column1\tColumn2',                                 // Test 7
    'Text\bBack',                                       // Test 8
    'Page1\fPage2',                                     // Test 9
    'Quote: \"Hi\"\nTab:\tEnd',                         // Test 10
    '',                                                 // Test 11 (empty)
    '\"\\\/\b\f\n\r\t',                              // Test 12
    'Alert:\u0007',                                     // Test 13
    'Start\u0000End',                                   // Test 14
    'Escape:\u001b',                                    // Test 15
    'She said \"Hello\"\nHe replied \"Hi\"',            // Test 16
    'C:\\Users\\Documents\\file.txt',                   // Test 17
    '{\"key\":\"value\"}',                              // Test 18
    '\n\r\t',                                           // Test 19
    'Start\u0001\u0002\u0003End'                        // Test 20
}


define_function TestNAVJsonEscapeString() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonEscapeString'")

    InitializeJsonEscapeStringTestData()

    for (x = 1; x <= length_array(JSON_ESCAPE_STRING_TEST); x++) {
        stack_var char result[512]

        result = NAVJsonEscapeString(JSON_ESCAPE_STRING_TEST[x])

        if (!NAVAssertStringEqual('NAVJsonEscapeString result',
                                  JSON_ESCAPE_STRING_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            JSON_ESCAPE_STRING_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonEscapeString'")
}
