PROGRAM_NAME='NAVTomlLexerEdgeCases'

DEFINE_VARIABLE

volatile char TOML_LEXER_EDGE_CASE_TEST[40][2048]

define_function InitializeTomlLexerEdgeCaseTestData() {
    // =========================================================================
    // LEADING ZERO TESTS (Should FAIL)
    // =========================================================================

    // Test 1: Leading zero on integer
    TOML_LEXER_EDGE_CASE_TEST[1] = 'key = 01'

    // Test 2: Multiple leading zeros
    TOML_LEXER_EDGE_CASE_TEST[2] = 'key = 007'

    // Test 3: Leading zero on float
    TOML_LEXER_EDGE_CASE_TEST[3] = 'key = 00.5'

    // =========================================================================
    // UNDERSCORE PLACEMENT TESTS (Should FAIL)
    // =========================================================================

    // Test 4: Consecutive underscores in decimal
    TOML_LEXER_EDGE_CASE_TEST[4] = 'key = 1__000'

    // Test 5: Negative float without digits
    TOML_LEXER_EDGE_CASE_TEST[5] = 'key = -.5'

    // Test 6: Trailing underscore in decimal
    TOML_LEXER_EDGE_CASE_TEST[6] = 'key = 100_'

    // Test 7: Leading underscore after hex prefix
    TOML_LEXER_EDGE_CASE_TEST[7] = 'key = 0x_DEAD'

    // Test 8: Trailing underscore in hex
    TOML_LEXER_EDGE_CASE_TEST[8] = 'key = 0xDEAD_'

    // Test 9: Consecutive underscores in hex
    TOML_LEXER_EDGE_CASE_TEST[9] = 'key = 0xDE__AD'

    // Test 10: Leading underscore in binary
    TOML_LEXER_EDGE_CASE_TEST[10] = 'key = 0b_1010'

    // Test 11: Trailing underscore in octal
    TOML_LEXER_EDGE_CASE_TEST[11] = 'key = 0o755_'

    // Test 12: Underscore before decimal point
    TOML_LEXER_EDGE_CASE_TEST[12] = 'key = 3_.14'

    // Test 13: Underscore after decimal point
    TOML_LEXER_EDGE_CASE_TEST[13] = 'key = 3._14'

    // Test 14: Trailing underscore in fractional part
    TOML_LEXER_EDGE_CASE_TEST[14] = 'key = 3.14_'

    // Test 15: Leading underscore in exponent
    TOML_LEXER_EDGE_CASE_TEST[15] = 'key = 1e_10'

    // Test 16: Trailing underscore in exponent
    TOML_LEXER_EDGE_CASE_TEST[16] = 'key = 1e10_'

    // =========================================================================
    // VALID EDGE CASES (Should PASS)
    // =========================================================================

    // Test 17: Valid single zero
    TOML_LEXER_EDGE_CASE_TEST[17] = 'key = 0'

    // Test 18: Valid zero with decimal
    TOML_LEXER_EDGE_CASE_TEST[18] = 'key = 0.0'

    // Test 19: Valid underscores in number
    TOML_LEXER_EDGE_CASE_TEST[19] = 'key = 1_000_000'

    // Test 20: Valid underscores in hex
    TOML_LEXER_EDGE_CASE_TEST[20] = 'key = 0xDE_AD_BE_EF'

    // Test 21: Valid underscores in binary
    TOML_LEXER_EDGE_CASE_TEST[21] = 'key = 0b1010_1010'

    // Test 22: Valid underscores in octal
    TOML_LEXER_EDGE_CASE_TEST[22] = 'key = 0o755_644'

    // Test 23: Valid underscores in float
    TOML_LEXER_EDGE_CASE_TEST[23] = 'key = 3.141_592_653'

    // Test 24: Valid underscores in exponent
    TOML_LEXER_EDGE_CASE_TEST[24] = 'key = 1e1_000'

    // Test 25: Empty string key (valid in TOML!)
    TOML_LEXER_EDGE_CASE_TEST[25] = '"" = "blank"'

    // Test 26: Quoted key with spaces
    TOML_LEXER_EDGE_CASE_TEST[26] = '"key with spaces" = "value"'

    // Test 27: Quoted key with special chars
    TOML_LEXER_EDGE_CASE_TEST[27] = '"127.0.0.1" = "localhost"'

    // Test 28: Positive infinity (lowercase required by TOML spec)
    TOML_LEXER_EDGE_CASE_TEST[28] = 'key = +inf'

    // Test 29: All valid escape sequences
    TOML_LEXER_EDGE_CASE_TEST[29] = "'key = "tab:\t newline:\n\r backslash:\\ quote:\" bell:\b formfeed:\f"'"

    // Test 30: Zero float with exponent
    TOML_LEXER_EDGE_CASE_TEST[30] = 'key = 0e0'

    // =========================================================================
    // CONTROL CHARACTER TESTS (Should FAIL - except tab)
    // =========================================================================

    // Test 31: Null character in string (0x00)
TOML_LEXER_EDGE_CASE_TEST[31] = "'key = "test', $00, 'string"'"

    // Test 32: Bell character in string (0x07)
    TOML_LEXER_EDGE_CASE_TEST[32] = "'key = "test', $07, 'string"'"

    // Test 33: Backspace in string (0x08)
    TOML_LEXER_EDGE_CASE_TEST[33] = "'key = "test', $08, 'string"'"

    // Test 34: DEL character in string (0x7F)
    TOML_LEXER_EDGE_CASE_TEST[34] = "'key = "test', $7F, 'string"'"

    // Test 35: Tab in string (0x09) - Should PASS
    TOML_LEXER_EDGE_CASE_TEST[35] = "'key = "test', $09, 'string"'"

    // Test 36: Line feed in string (0x0A) - Should FAIL
    TOML_LEXER_EDGE_CASE_TEST[36] = "'key = "test', $0A, 'string"'"

    // =========================================================================
    // FRACTIONAL SECONDS TESTS
    // =========================================================================

    // Test 37: Fractional seconds without digits - Should FAIL
    TOML_LEXER_EDGE_CASE_TEST[37] = 'time = 12:34:56.'

    // Test 38: Valid fractional seconds (1 digit) - Should PASS
    TOML_LEXER_EDGE_CASE_TEST[38] = 'time = 12:34:56.1'

    // Test 39: Valid fractional seconds (multiple digits) - Should PASS
    TOML_LEXER_EDGE_CASE_TEST[39] = 'time = 12:34:56.123456'

    // Test 40: Valid datetime with fractional seconds - Should PASS
    TOML_LEXER_EDGE_CASE_TEST[40] = 'datetime = 2026-01-01T12:34:56.789Z'

    set_length_array(TOML_LEXER_EDGE_CASE_TEST, 40)
}


DEFINE_CONSTANT

constant char TOML_LEXER_EDGE_CASE_EXPECTED_RESULT[] = {
    false,  // Test 1: Leading zero (01) - should fail
    false,  // Test 2: Multiple leading zeros (007) - should fail
    false,  // Test 3: Leading zero on float (00.5) - should fail
    false,  // Test 4: Consecutive underscores - should fail
    false,  // Test 5: Negative float without leading zero - should fail
    false,  // Test 6: Trailing underscore - should fail
    false,  // Test 7: Leading underscore after hex prefix - should fail
    false,  // Test 8: Trailing underscore in hex - should fail
    false,  // Test 9: Consecutive underscores in hex - should fail
    false,  // Test 10: Leading underscore in binary - should fail
    false,  // Test 11: Trailing underscore in octal - should fail
    false,  // Test 12: Underscore before decimal point - should fail
    false,  // Test 13: Underscore after decimal point - should fail
    false,  // Test 14: Trailing underscore in fractional part - should fail
    false,  // Test 15: Leading underscore in exponent - should fail
    false,  // Test 16: Trailing underscore in exponent - should fail
    true,   // Test 17: Valid single zero - should pass
    true,   // Test 18: Valid zero with decimal - should pass
    true,   // Test 19: Valid underscores in number - should pass
    true,   // Test 20: Valid underscores in hex - should pass
    true,   // Test 21: Valid underscores in binary - should pass
    true,   // Test 22: Valid underscores in octal - should pass
    true,   // Test 23: Valid underscores in float - should pass
    true,   // Test 24: Valid underscores in exponent - should pass
    true,   // Test 25: Empty string key - should pass
    true,   // Test 26: Quoted key with spaces - should pass
    true,   // Test 27: Quoted key with special chars - should pass
    true,   // Test 28: Positive infinity (lowercase) - should pass
    true,   // Test 29: All valid escape sequences - should pass
    true,   // Test 30: Zero float with exponent - should pass
    false,  // Test 31: Null character (0x00) - should fail
    false,  // Test 32: Bell character (0x07) - should fail
    false,  // Test 33: Backspace (0x08) - should fail
    false,  // Test 34: DEL character (0x7F) - should fail
    true,   // Test 35: Tab (0x09) - should pass (allowed)
    false,  // Test 36: Line feed (0x0A) - should fail
    false,  // Test 37: Fractional seconds without digits - should fail
    true,   // Test 38: Valid fractional seconds (1 digit) - should pass
    true,   // Test 39: Valid fractional seconds (multiple digits) - should pass
    true    // Test 40: Valid datetime with fractional seconds - should pass
}


define_function TestNAVTomlLexerEdgeCases() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlLexerEdgeCases'")

    InitializeTomlLexerEdgeCaseTestData()

    for (x = 1; x <= length_array(TOML_LEXER_EDGE_CASE_TEST); x++) {
        stack_var char result
        stack_var _NAVTomlLexer lexer

        result = NAVTomlLexerTokenize(lexer, TOML_LEXER_EDGE_CASE_TEST[x])

        // Assert tokenize result matches expectation
        if (!NAVAssertBooleanEqual('Edge case result should match expectation',
                                    TOML_LEXER_EDGE_CASE_EXPECTED_RESULT[x],
                                    result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_LEXER_EDGE_CASE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))

            // Print the lexer error for failing cases
            if (lexer.hasError) {
                NAVLog("'Test ', itoa(x), ' error: ', lexer.error")
            }

            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlLexerEdgeCases'")
}
