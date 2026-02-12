PROGRAM_NAME='NAVTomlParserUnescapeString'

#include 'NAVFoundation.TomlParser.axi'


DEFINE_VARIABLE

volatile char TOML_PARSER_UNESCAPE_STRING_TEST[26][255]
volatile char TOML_PARSER_UNESCAPE_STRING_EXPECTED[26][255]


define_function InitializeTomlParserUnescapeStringTestData() {
    // Test 1: Simple quoted string
    TOML_PARSER_UNESCAPE_STRING_TEST[1] = '"hello"'

    // Test 2: Empty string
    TOML_PARSER_UNESCAPE_STRING_TEST[2] = '""'

    // Test 3: String with escaped quote
    TOML_PARSER_UNESCAPE_STRING_TEST[3] = '"say \"hello\""'

    // Test 4: String with escaped backslash
    TOML_PARSER_UNESCAPE_STRING_TEST[4] = '"path\\to\\file"'

    // Test 5: String with backspace
    TOML_PARSER_UNESCAPE_STRING_TEST[5] = '"before\bafter"'

    // Test 6: String with form feed
    TOML_PARSER_UNESCAPE_STRING_TEST[6] = '"before\fafter"'

    // Test 7: String with newline
    TOML_PARSER_UNESCAPE_STRING_TEST[7] = '"line1\nline2"'

    // Test 8: String with carriage return
    TOML_PARSER_UNESCAPE_STRING_TEST[8] = '"before\rafter"'

    // Test 9: String with tab
    TOML_PARSER_UNESCAPE_STRING_TEST[9] = '"before\tafter"'

    // Test 10: String with multiple escapes
    TOML_PARSER_UNESCAPE_STRING_TEST[10] = '"quote: \" slash: \\ newline: \n"'

    // Test 11: String with unicode escape (4 digit)
    TOML_PARSER_UNESCAPE_STRING_TEST[11] = '"\u263A"'

    // Test 12: String with unicode escape (8 digit)
    TOML_PARSER_UNESCAPE_STRING_TEST[12] = '"\U0001F600"'

    // Test 13: String with multiple unicode escapes
    TOML_PARSER_UNESCAPE_STRING_TEST[13] = '"\u0041\u0042\u0043"'

    // Test 14: String without quotes (edge case)
    TOML_PARSER_UNESCAPE_STRING_TEST[14] = 'noquotes'

   // Test 15: String with all basic escapes
    TOML_PARSER_UNESCAPE_STRING_TEST[15] = '"\"\\\b\f\n\r\t"'

    // Test 16: String with text before and after escape
    TOML_PARSER_UNESCAPE_STRING_TEST[16] = '"Hello\nWorld"'

    // Test 17: String with escaped quote at start
    TOML_PARSER_UNESCAPE_STRING_TEST[17] = '"\"quoted\""'

    // Test 18: String with escaped backslash at end
    TOML_PARSER_UNESCAPE_STRING_TEST[18] = '"ends with\\"'

    // Test 19: Complex mixed string
    TOML_PARSER_UNESCAPE_STRING_TEST[19] = '"Path: C:\\Users\\test\nFile: \"data.toml\"\tSize: 1024"'

    // Test 20: Literal string (single quotes - no escapes in TOML literals)
    TOML_PARSER_UNESCAPE_STRING_TEST[20] = "'C:\Users\test\n'"

    // Test 21: TOML 1.1.0 - Escape character \e
    TOML_PARSER_UNESCAPE_STRING_TEST[21] = '"\e"'

    // Test 22: TOML 1.1.0 - Hex byte escape \x00 (null)
    TOML_PARSER_UNESCAPE_STRING_TEST[22] = '"\x00"'

    // Test 23: TOML 1.1.0 - Hex byte escape \x61 (letter 'a')
    TOML_PARSER_UNESCAPE_STRING_TEST[23] = '"\x61"'

    // Test 24: TOML 1.1.0 - Hex byte escape \xFF (max value)
    TOML_PARSER_UNESCAPE_STRING_TEST[24] = '"\xFF"'

    // Test 25: TOML 1.1.0 - Multiple hex escapes (Hello)
    TOML_PARSER_UNESCAPE_STRING_TEST[25] = '"\x48\x65\x6C\x6C\x6F"'

    // Test 26: TOML 1.1.0 - Mixed \e and \xHH with other escapes
    TOML_PARSER_UNESCAPE_STRING_TEST[26] = '"\e[31m\x48\x69\n"'

    set_length_array(TOML_PARSER_UNESCAPE_STRING_TEST, 26)

    TOML_PARSER_UNESCAPE_STRING_EXPECTED[1] = 'hello'                                                    // Test 1
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[2] = ''                                                         // Test 2
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[3] = 'say "hello"'                                              // Test 3
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[4] = 'path\to\file'                                             // Test 4
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[5] = "'before', $08, 'after'"                                   // Test 5
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[6] = "'before', $0C, 'after'"                                   // Test 6
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[7] = "'line1', $0A, 'line2'"                                    // Test 7
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[8] = "'before', $0D, 'after'"                                   // Test 8
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[9] = "'before', $09, 'after'"                                   // Test 9
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[10] = "'quote: " slash: \ newline: ', $0A"       // Test 10
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[11] = '\u263A'                                                   // Test 11 (unicode - escape returned as-is)
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[12] = '\U0001F600'                                               // Test 12 (unicode - escape returned as-is)
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[13] = '\u0041\u0042\u0043'                                              // Test 13 (unicode - escapes returned as-is)
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[14] = 'noquotes'                                                 // Test 14
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[15] = "'"\', $08, $0C, $0A, $0D, $09"                        // Test 15
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[16] = "'Hello', $0A, 'World'"                                    // Test 16
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[17] = "'"quoted"'"                                       // Test 17
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[18] = "'ends with\'"                                         // Test 18
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[19] = "'Path: C:\Users\test', $0A, 'File: "data.toml"', $09, 'Size: 1024'" // Test 19
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[20] = "'C:\Users\test\n'"                                // Test 20 (literal - no escape processing)
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[21] = "$1B"                                                      // Test 21 - Escape character (ESC = 0x1B)
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[22] = "$00"                                                      // Test 22 - Null byte
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[23] = "'a'"                                                      // Test 23 - Letter 'a' from \x61
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[24] = "$FF"                                                      // Test 24 - Max byte value
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[25] = "'Hello'"                                                  // Test 25 - "Hello" from hex escapes
    TOML_PARSER_UNESCAPE_STRING_EXPECTED[26] = "$1B, '[31mHi', $0A"                                       // Test 26 - Mixed escapes

    set_length_array(TOML_PARSER_UNESCAPE_STRING_EXPECTED, 26)
}

define_function TestNAVTomlParserUnescapeString() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlParserUnescapeString'")

    InitializeTomlParserUnescapeStringTestData()

    for (x = 1; x <= length_array(TOML_PARSER_UNESCAPE_STRING_TEST); x++) {
        stack_var char result[255]

        result = NAVTomlParserUnescapeString(TOML_PARSER_UNESCAPE_STRING_TEST[x], NAV_TOML_TOKEN_TYPE_STRING)

        if (!NAVAssertStringEqual('NAVTomlParserUnescapeString',
                                  TOML_PARSER_UNESCAPE_STRING_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            TOML_PARSER_UNESCAPE_STRING_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlParserUnescapeString'")
}
