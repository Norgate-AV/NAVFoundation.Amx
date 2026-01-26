PROGRAM_NAME='NAVJsonParserUnescapeString'

#include 'NAVFoundation.JsonParser.axi'


DEFINE_VARIABLE

volatile char JSON_PARSER_UNESCAPE_STRING_TEST[20][255]
volatile char JSON_PARSER_UNESCAPE_STRING_EXPECTED[20][255]


define_function InitializeJsonParserUnescapeStringTestData() {
    // Test 1: Simple quoted string
    JSON_PARSER_UNESCAPE_STRING_TEST[1] = '"hello"'

    // Test 2: Empty string
    JSON_PARSER_UNESCAPE_STRING_TEST[2] = '""'

    // Test 3: String with escaped quote
    JSON_PARSER_UNESCAPE_STRING_TEST[3] = '"say \"hello\""'

    // Test 4: String with escaped backslash
    JSON_PARSER_UNESCAPE_STRING_TEST[4] = '"path\\to\\file"'

    // Test 5: String with escaped forward slash
    JSON_PARSER_UNESCAPE_STRING_TEST[5] = '"http:\/\/example.com"'

    // Test 6: String with backspace
    JSON_PARSER_UNESCAPE_STRING_TEST[6] = '"before\bafter"'

    // Test 7: String with form feed
    JSON_PARSER_UNESCAPE_STRING_TEST[7] = '"before\fafter"'

    // Test 8: String with newline
    JSON_PARSER_UNESCAPE_STRING_TEST[8] = '"line1\nline2"'

    // Test 9: String with carriage return
    JSON_PARSER_UNESCAPE_STRING_TEST[9] = '"before\rafter"'

    // Test 10: String with tab
    JSON_PARSER_UNESCAPE_STRING_TEST[10] = '"before\tafter"'

    // Test 11: String with multiple escapes
    JSON_PARSER_UNESCAPE_STRING_TEST[11] = '"quote: \" slash: \\ newline: \n"'

    // Test 12: String with unicode escape
    JSON_PARSER_UNESCAPE_STRING_TEST[12] = '"\u263A"'

    // Test 13: String with multiple unicode escapes
    JSON_PARSER_UNESCAPE_STRING_TEST[13] = '"\u0041\u0042\u0043"'

    // Test 14: String without quotes (edge case)
    JSON_PARSER_UNESCAPE_STRING_TEST[14] = 'noquotes'

    // Test 15: String with only opening quote
    JSON_PARSER_UNESCAPE_STRING_TEST[15] = '"incomplete'

    // Test 16: String with all basic escapes
    JSON_PARSER_UNESCAPE_STRING_TEST[16] = '"\"\\\b\f\n\r\t"'

    // Test 17: String with text before and after escape
    JSON_PARSER_UNESCAPE_STRING_TEST[17] = '"Hello\nWorld"'

    // Test 18: String with escaped quote at start
    JSON_PARSER_UNESCAPE_STRING_TEST[18] = '"\"quoted\""'

    // Test 19: String with escaped backslash at end
    JSON_PARSER_UNESCAPE_STRING_TEST[19] = '"ends with\\"'

    // Test 20: Complex mixed string
    JSON_PARSER_UNESCAPE_STRING_TEST[20] = '"Path: C:\\Users\\test\nFile: \"data.json\"\tSize: 1024"'

    set_length_array(JSON_PARSER_UNESCAPE_STRING_TEST, 20)

    JSON_PARSER_UNESCAPE_STRING_EXPECTED[1] = 'hello'                                                    // Test 1
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[2] = ''                                                         // Test 2
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[3] = 'say "hello"'                                              // Test 3
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[4] = 'path\to\file'                                             // Test 4
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[5] = 'http://example.com'                                       // Test 5
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[6] = "'before', $08, 'after'"                                   // Test 6
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[7] = "'before', $0C, 'after'"                                   // Test 7
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[8] = "'line1', $0A, 'line2'"                                    // Test 8
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[9] = "'before', $0D, 'after'"                                   // Test 9
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[10] = "'before', $09, 'after'"                                   // Test 10
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[11] = "'quote: " slash: \ newline: ', $0A"       // Test 11
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[12] = ''                                                         // Test 12 (unicode skipped)
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[13] = ''                                                         // Test 13 (unicode skipped)
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[14] = 'noquotes'                                                 // Test 14
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[15] = '"incomplete'                                             // Test 15 (keeps opening quote when no closing)
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[16] = "'"\', $08, $0C, $0A, $0D, $09"                        // Test 16
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[17] = "'Hello', $0A, 'World'"                                    // Test 17
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[18] = "'"quoted"'"                                       // Test 18
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[19] = "'ends with\'"                                         // Test 19
    JSON_PARSER_UNESCAPE_STRING_EXPECTED[20] = "'Path: C:\Users\test', $0A, 'File: "data.json"', $09, 'Size: 1024'" // Test 20

    set_length_array(JSON_PARSER_UNESCAPE_STRING_EXPECTED, 20)
}

define_function TestNAVJsonParserUnescapeString() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonParserUnescapeString'")

    InitializeJsonParserUnescapeStringTestData()

    for (x = 1; x <= length_array(JSON_PARSER_UNESCAPE_STRING_TEST); x++) {
        stack_var char result[NAV_JSON_PARSER_MAX_STRING_LENGTH]

        result = NAVJsonParserUnescapeString(JSON_PARSER_UNESCAPE_STRING_TEST[x])

        if (!NAVAssertStringEqual('Unescaped string should match expected',
                                   JSON_PARSER_UNESCAPE_STRING_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            JSON_PARSER_UNESCAPE_STRING_EXPECTED[x],
                            result)
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonParserUnescapeString'")
}
