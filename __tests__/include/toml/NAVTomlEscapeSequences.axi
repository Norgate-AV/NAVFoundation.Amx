PROGRAM_NAME='NAVTomlEscapeSequences'

#include 'NAVFoundation.Toml.axi'

DEFINE_VARIABLE

volatile char TOML_ESCAPE_TEST[26][1024]
volatile char TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[26]
volatile char TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[26]
volatile char TOML_ESCAPE_TEST_QUERY[26][64]


define_function InitializeTomlEscapeTestData() {
    // Test 1: Tab escape
    TOML_ESCAPE_TEST[1] = 'key = "before	after"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[1] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[1] = true
    TOML_ESCAPE_TEST_QUERY[1] = '.key'

    // Test 2: Newline escape
    TOML_ESCAPE_TEST[2] = 'key = "before\nafter"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[2] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[2] = true
    TOML_ESCAPE_TEST_QUERY[2] = '.key'

    // Test 3: Carriage return escape
    TOML_ESCAPE_TEST[3] = 'key = "before\rafter"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[3] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[3] = true
    TOML_ESCAPE_TEST_QUERY[3] = '.key'

    // Test 4: Double quote escape
    TOML_ESCAPE_TEST[4] = 'key = "He said \"Hello\""'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[4] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[4] = true
    TOML_ESCAPE_TEST_QUERY[4] = '.key'

    // Test 5: Backslash escape
    TOML_ESCAPE_TEST[5] = 'key = "path\\to\\file"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[5] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[5] = true
    TOML_ESCAPE_TEST_QUERY[5] = '.key'

    // Test 6: Backspace escape
    TOML_ESCAPE_TEST[6] = 'key = "before\bafter"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[6] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[6] = true
    TOML_ESCAPE_TEST_QUERY[6] = '.key'

    // Test 7: Form feed escape
    TOML_ESCAPE_TEST[7] = 'key = "before\fafter"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[7] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[7] = true
    TOML_ESCAPE_TEST_QUERY[7] = '.key'

    // Test 8: Unicode 4-digit escape (BMP)
    TOML_ESCAPE_TEST[8] = 'key = "Hello \u0057orld"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[8] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[8] = true
    TOML_ESCAPE_TEST_QUERY[8] = '.key'

    // Test 9: Unicode 8-digit escape (supplementary plane)
    TOML_ESCAPE_TEST[9] = 'key = "\U0001F600"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[9] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[9] = true
    TOML_ESCAPE_TEST_QUERY[9] = '.key'

    // Test 10: Multiple escapes in one string
    TOML_ESCAPE_TEST[10] = "'key = ', $22, 'Tab:', 92, 't', 'Quote:', 92, $22, 'Newline:', 92, 'n', $22"
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[10] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[10] = true
    TOML_ESCAPE_TEST_QUERY[10] = '.key'

    // Test 11: Empty string with escapes
    TOML_ESCAPE_TEST[11] = 'key = ""'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[11] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[11] = true
    TOML_ESCAPE_TEST_QUERY[11] = '.key'

    // Test 12: Escape at start of string
    TOML_ESCAPE_TEST[12] = 'key = "\nstart"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[12] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[12] = true
    TOML_ESCAPE_TEST_QUERY[12] = '.key'

    // Test 13: Escape at end of string
    TOML_ESCAPE_TEST[13] = 'key = "end\n"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[13] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[13] = true
    TOML_ESCAPE_TEST_QUERY[13] = '.key'

    // Test 14: Literal string (no escape processing)
    TOML_ESCAPE_TEST[14] = "'key = ''C:', 92, 'path', 92, 'to', 92, 'file'''"
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[14] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[14] = true
    TOML_ESCAPE_TEST_QUERY[14] = '.key'

    // Test 15: Multiline basic string with escapes
    TOML_ESCAPE_TEST[15] = "'key = ""', 34, 'Line 1', 10, 'Line 2""', 34"
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[15] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[15] = true
    TOML_ESCAPE_TEST_QUERY[15] = '.key'

    // Test 16: Multiline literal string (no escapes)
    TOML_ESCAPE_TEST[16] = "'key = ', 39, 39, 39, 'Line 1', 10, 'Line 2', 39, 39, 39"
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[16] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[16] = true
    TOML_ESCAPE_TEST_QUERY[16] = '.key'

    // Test 17: Unicode null character
    TOML_ESCAPE_TEST[17] = 'key = "\u0000"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[17] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[17] = true
    TOML_ESCAPE_TEST_QUERY[17] = '.key'

    // Test 18: Complex Unicode (emoji)
    TOML_ESCAPE_TEST[18] = 'key = "\U0001F4A9"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[18] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[18] = true
    TOML_ESCAPE_TEST_QUERY[18] = '.key'

    // Test 19: All basic escapes
    TOML_ESCAPE_TEST[19] = 'key = "\t\n\r\"\\\b\f"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[19] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[19] = true
    TOML_ESCAPE_TEST_QUERY[19] = '.key'

    // Test 20: Escaped backslash before quote
    TOML_ESCAPE_TEST[20] = 'key = "path\\\"file\""'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[20] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[20] = true
    TOML_ESCAPE_TEST_QUERY[20] = '.key'

    // Test 21: TOML 1.1.0 - Escape character \e
    TOML_ESCAPE_TEST[21] = 'key = "\e[31m"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[21] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[21] = true
    TOML_ESCAPE_TEST_QUERY[21] = '.key'

    // Test 22: TOML 1.1.0 - Hex byte escape \x00 (null byte)
    TOML_ESCAPE_TEST[22] = 'key = "\x00"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[22] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[22] = true
    TOML_ESCAPE_TEST_QUERY[22] = '.key'

    // Test 23: TOML 1.1.0 - Hex byte escape \x61 (letter 'a')
    TOML_ESCAPE_TEST[23] = 'key = "\x61bc"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[23] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[23] = true
    TOML_ESCAPE_TEST_QUERY[23] = '.key'

    // Test 24: TOML 1.1.0 - Hex byte escape \xFF (max value 255)
    TOML_ESCAPE_TEST[24] = 'key = "\xFF"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[24] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[24] = true
    TOML_ESCAPE_TEST_QUERY[24] = '.key'

    // Test 25: TOML 1.1.0 - Multiple hex escapes
    TOML_ESCAPE_TEST[25] = 'key = "\x48\x65\x6C\x6C\x6F"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[25] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[25] = true
    TOML_ESCAPE_TEST_QUERY[25] = '.key'

    // Test 26: TOML 1.1.0 - Escape char mixed with other escapes
    TOML_ESCAPE_TEST[26] = 'key = "CSI: \e[, newline: \n, tab: \t"'
    TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[26] = true
    TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[26] = true
    TOML_ESCAPE_TEST_QUERY[26] = '.key'

    set_length_array(TOML_ESCAPE_TEST, 26)
    set_length_array(TOML_ESCAPE_EXPECTED_PARSE_SUCCESS, 26)
    set_length_array(TOML_ESCAPE_EXPECTED_QUERY_SUCCESS, 26)
    set_length_array(TOML_ESCAPE_TEST_QUERY, 26)
}


define_function TestNAVTomlEscapeSequences() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlEscapeSequences'")

    InitializeTomlEscapeTestData()

    for (x = 1; x <= length_array(TOML_ESCAPE_TEST); x++) {
        stack_var _NAVToml toml
        stack_var char parseSuccess
        stack_var _NAVTomlNode result
        stack_var char querySuccess

        parseSuccess = NAVTomlParse(TOML_ESCAPE_TEST[x], toml)

        if (!NAVAssertBooleanEqual('Parse success',
                                   TOML_ESCAPE_EXPECTED_PARSE_SUCCESS[x],
                                   parseSuccess)) {
            NAVLogTestFailed(x,
                           "'Expected parse success'",
                           "'Parse failed'")
            continue
        }

        if (!parseSuccess) {
            NAVLogTestPassed(x)
            continue
        }

        querySuccess = NAVTomlQuery(toml, TOML_ESCAPE_TEST_QUERY[x], result)

        if (!NAVAssertBooleanEqual('Query success',
                                   TOML_ESCAPE_EXPECTED_QUERY_SUCCESS[x],
                                   querySuccess)) {
            NAVLogTestFailed(x,
                           "'Expected query success'",
                           "'Query failed'")
            continue
        }

        if (querySuccess && x != 11) {  // Test 11 is for empty string
            if (!NAVAssertIntegerGreaterThan('Result length',
                                            0,
                                            length_array(result.value))) {
                NAVLogTestFailed(x,
                               "'Expected non-empty result'",
                               "'Empty result'")
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlEscapeSequences'")
}
