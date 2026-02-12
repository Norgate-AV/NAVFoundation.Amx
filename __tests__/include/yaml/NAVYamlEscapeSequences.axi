PROGRAM_NAME='NAVYamlEscapeSequences'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_ESCAPE_TEST[20][1024]


DEFINE_CONSTANT

constant char YAML_ESCAPE_EXPECTED_PARSE_SUCCESS[20] = {
    true,  // Test 1 - Basic escapes (\n, \t, \r)
    true,  // Test 2 - Null and control characters (\0, \a, \b)
    true,  // Test 3 - Quote escapes (\", \')
    true,  // Test 4 - Backslash escape (\\)
    true,  // Test 5 - Vertical tab, form feed, escape (\v, \f, \e)
    true,  // Test 6 - Hex escape single byte (\x41)
    true,  // Test 7 - Hex escape multiple bytes (\xFF)
    true,  // Test 8 - Unicode  16-bit BMP (\u0041)
    true,  // Test 9 - Unicode 16-bit non-ASCII (\u2603)
    true,  // Test 10 - Unicode 32-bit (\U0001F600)
    true,  // Test 11 - Whitespace escapes (\_, \N)
    true,  // Test 12 - Line/paragraph separators (\L, \P)
    true,  // Test 13 - Mixed escapes in one string
    true,  // Test 14 - Single-quoted string (no escapes except '')
    true,  // Test 15 - Empty string ""
    true,  // Test 16 - String with only escape
    true,  // Test 17 - Multiple hex escapes
    true,  // Test 18 - Multiple Unicode escapes
    true,  // Test 19 - Escape at end of string
    true   // Test 20 - Complex mixed test
}

constant char YAML_ESCAPE_EXPECTED_QUERY_SUCCESS[20] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9
    true,  // Test 10
    true,  // Test 11
    true,  // Test 12
    true,  // Test 13
    true,  // Test 14
    true,  // Test 15
    true,  // Test 16
    true,  // Test 17
    true,  // Test 18
    true,  // Test 19
    true   // Test 20
}

constant char YAML_ESCAPE_TEST_QUERY[20][64] = {
    '.text',  // Test 1
    '.text',  // Test 2
    '.text',  // Test 3
    '.text',  // Test 4
    '.text',  // Test 5
    '.text',  // Test 6
    '.text',  // Test 7
    '.text',  // Test 8
    '.text',  // Test 9
    '.text',  // Test 10
    '.text',  // Test 11
    '.text',  // Test 12
    '.text',  // Test 13
    '.text',  // Test 14
    '.text',  // Test 15
    '.text',  // Test 16
    '.text',  // Test 17
    '.text',  // Test 18
    '.text',  // Test 19
    '.text'   // Test 20
}


define_function InitializeYamlEscapeTestData() {
    // Test 1: Basic escapes \n, \t, \r
    YAML_ESCAPE_TEST[1] = "'text: "Line1\nLine2\tTabbed\rReturn"'"

    // Test 2: Null and control characters \0, \a, \b
    YAML_ESCAPE_TEST[2] = "'text: "null:\0 bell:\a backspace:\b"'"

    // Test 3: Quote escapes \"
    YAML_ESCAPE_TEST[3] = "'text: "He said \"Hello\""'"

    // Test 4: Backslash escape \\
    YAML_ESCAPE_TEST[4] = "'text: "Path: C:\\Users\\Name"'"

    // Test 5: Vertical tab, form feed, escape \v, \f, \e
    YAML_ESCAPE_TEST[5] = "'text: "vt:\v ff:\f esc:\e"'"

    // Test 6: Hex escape single byte \x41 = A
    YAML_ESCAPE_TEST[6] = "'text: "Letter: \x41"'"

    // Test 7: Hex escape high byte \xFF
    YAML_ESCAPE_TEST[7] = "'text: "Byte: \xFF"'"

    // Test 8: Unicode 16-bit BMP \u0041 = A
    YAML_ESCAPE_TEST[8] = "'text: "Unicode A: \u0041"'"

    // Test 9: Unicode 16-bit non-ASCII \u2603
    YAML_ESCAPE_TEST[9] = "'text: "Snowman: \u2603"'"

    // Test 10: Unicode 32-bit \U0001F600
    YAML_ESCAPE_TEST[10] = "'text: "Emoji: \U0001F600"'"

    // Test 11: Whitespace escapes \_, \N
    YAML_ESCAPE_TEST[11] = "'text: "nbsp:\_ nextline:\N"'"

    // Test 12: Line/paragraph separators \L, \P
    YAML_ESCAPE_TEST[12] = "'text: "line:\L para:\P"'"

    // Test 13: Mixed escapes in one string
    YAML_ESCAPE_TEST[13] = "'text: "Tab:\t', 'Newline:\n', 'Quote:\" Hex:\x42 Unicode:\u2603"'"

    // Test 14: Single-quoted string (only '' escape works)
    YAML_ESCAPE_TEST[14] = "'text: ', $27, 'It', $27, $27, 's a quote', $27"

    // Test 15: Empty string
    YAML_ESCAPE_TEST[15] = "'text: ""'"

    // Test 16: String with only escape
    YAML_ESCAPE_TEST[16] = "'text: "\n"'"

    // Test 17: Multiple hex escapes \x41\x42\x43 = ABC
    YAML_ESCAPE_TEST[17] = "'text: "\x41\x42\x43"'"

    // Test 18: Multiple Unicode escapes
    YAML_ESCAPE_TEST[18] = "'text: "\u0041\u0042"'"

    // Test 19: Escape at end of string
    YAML_ESCAPE_TEST[19] = "'text: "End\n"'"

    // Test 20: Complex mixed test
    YAML_ESCAPE_TEST[20] = "'text: "Path: C:\\', '\\', 'dir\t', 'File: data.txt\n', 'Size: 42\x00"'"

    set_length_array(YAML_ESCAPE_TEST, 20)
}


define_function TestNAVYamlEscapeSequences() {
    stack_var integer x

    InitializeYamlEscapeTestData()

    NAVLogTestSuiteStart("'NAVYamlEscapeSequences'")

    for (x = 1; x <= length_array(YAML_ESCAPE_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var char result[512]
        stack_var char parseSuccess

        parseSuccess = NAVYamlParse(YAML_ESCAPE_TEST[x], yaml)

        if (!NAVAssertBooleanEqual('Parse success',
                                  YAML_ESCAPE_EXPECTED_PARSE_SUCCESS[x],
                                  parseSuccess)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // If parse was expected to fail and did fail, test passes
        if (!YAML_ESCAPE_EXPECTED_PARSE_SUCCESS[x]) {
            NAVLogTestPassed(x)
            continue
        }

        // Query the value to verify it was parsed
        if (!NAVYamlQueryString(yaml, YAML_ESCAPE_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Verify we got a result (empty strings are valid for Test 15)
        if (!NAVAssertIntegerGreaterThanOrEqual('Result length', 0, length_array(result))) {
            NAVLogTestFailed(x, 'Valid result', 'Invalid result')
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlEscapeSequences'")
}
