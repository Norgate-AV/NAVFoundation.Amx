PROGRAM_NAME='NAVRegexMatchEscapedChars'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_VARIABLE

// Using variables instead of constants to allow mixed hex/ascii strings
volatile char REGEX_MATCH_ESCAPED_CHARS_TEST[30][7][255]
volatile char REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[30]


define_function SetupNAVRegexMatchEscapedCharsTests() {
    stack_var integer idx

    idx = 0

    // Tab character tests (\t)
    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\t/'                           // Pattern
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "$09"                            // Test text (tab char)
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '1'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '2'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "$09"                            // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)


    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\t+/'                          // Pattern
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "$09, $09, $09"                      // Multiple tabs
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '3'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '4'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "$09, $09, $09"                      // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\w+\t\w+/'                     // Pattern with tab between words
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "'hello', $09, 'world'"                  // Text with tab
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '11'                             // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '12'                             // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "'hello', $09, 'world'"                  // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    // Newline character tests (\n)
    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\n/'                           // Pattern
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "$0A"                            // Test text (LF char)
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '1'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '2'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "$0A"                            // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/line1\nline2/'                 // Pattern
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "'line1', $0A, 'line2'"                  // Text with newline
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '11'                             // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '12'                             // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "'line1', $0A, 'line2'"                  // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\n+/'                          // Multiple newlines
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "$0A, $0A, $0A"                      // Three newlines
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '3'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '4'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "$0A, $0A, $0A"                      // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    // Carriage return character tests (\r)
    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\r/'                           // Pattern
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "$0D"                            // Test text (CR char)
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '1'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '2'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "$0D"                            // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\r\n/'                         // CRLF pair
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "$0D, $0A"                         // CR+LF
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '2'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '3'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "$0D, $0A"                         // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/text\r\nmore/'                 // Text with CRLF
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "'text', $0D, $0A, 'more'"                 // Text with CR+LF
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '10'                             // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '11'                             // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "'text', $0D, $0A, 'more'"                 // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    // Hex digit character class tests (\x)
    // NOTE: \x in this implementation matches hex digit characters [0-9A-Fa-f]
    //       It does NOT support \x41 style hex escape sequences
    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\x/'                           // Pattern - matches any hex digit
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = 'A'                              // Test text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '1'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '2'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = 'A'                              // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\x+/'                          // Pattern - multiple hex digits
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = 'ABC123'                         // Test text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '6'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '7'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = 'ABC123'                         // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/0x\x+/'                        // Pattern - hex prefix with digits
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = '0xDEADBEEF'                     // Test text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '10'                             // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '11'                             // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = '0xDEADBEEF'                     // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    // Mixed escaped character tests
    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\t\n\r/'                       // Tab, newline, return
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "$09, $0A, $0D"                      // All three chars
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '3'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '4'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "$09, $0A, $0D"                      // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                           // Debug flag - ENABLED FOR DEBUGGING
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    // Escaped characters in character classes
    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/[\t\n\r]+/'                    // Class with escaped chars
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "$09, $0A, $0D, $09"             // Mixed whitespace
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '4'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '1'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '5'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = "$09, $0A, $0D, $09"             // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = true
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    // Negative tests - should NOT match
    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\t/'                           // Pattern
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = ' '                              // Space, not tab
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '0'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '0'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '0'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = ''                               // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = false
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\n/'                           // Pattern
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "$0D"                            // CR not LF
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '0'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '0'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '0'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = ''                               // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = false
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\r/'                           // Pattern
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = "$0A"                            // LF not CR
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '0'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '0'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '0'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = ''                               // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = false
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    idx++
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][1] = '/\x/'                           // Pattern - hex digit
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][2] = 'G'                              // Not a hex digit
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][3] = '0'                              // Expected length
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][4] = '0'                              // Expected start
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][5] = '0'                              // Expected end
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][6] = ''                               // Expected match text
    REGEX_MATCH_ESCAPED_CHARS_TEST[idx][7] = 'false'                          // Debug flag
    REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[idx] = false
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST[idx], 7)

    set_length_array(REGEX_MATCH_ESCAPED_CHARS_TEST, idx)
    set_length_array(REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT, idx)
}


define_function TestNAVRegexMatchEscapedChars() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatch - Escaped Characters *****************'")

    // Initialize test data
    SetupNAVRegexMatchEscapedCharsTests()

    for (x = 1; x <= length_array(REGEX_MATCH_ESCAPED_CHARS_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char result
        stack_var char failed
        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatch expected

        pattern = REGEX_MATCH_ESCAPED_CHARS_TEST[x][1]
        text = REGEX_MATCH_ESCAPED_CHARS_TEST[x][2]

        expected.length = atoi(REGEX_MATCH_ESCAPED_CHARS_TEST[x][3])
        expected.start = atoi(REGEX_MATCH_ESCAPED_CHARS_TEST[x][4])
        expected.end = atoi(REGEX_MATCH_ESCAPED_CHARS_TEST[x][5])
        expected.text = REGEX_MATCH_ESCAPED_CHARS_TEST[x][6]

        // Set the debug flag
        match.debug = (REGEX_MATCH_ESCAPED_CHARS_TEST[x][7] == 'true')

        result = NAVRegexMatch(pattern, text, match)

        if (!NAVAssertBooleanEqual('Should return the expected result', REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!REGEX_MATCH_ESCAPED_CHARS_EXPECTED_RESULT[x]) {
            // If no match expected, skip further checks
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertIntegerEqual('Should match the correct length', match.matches[1].length, expected.length)) {
            NAVLogTestFailed(x, itoa(expected.length), itoa(match.matches[1].length))
            failed = true
        }

        if (!NAVAssertIntegerEqual('Should have the correct start position', match.matches[1].start, expected.start)) {
            NAVLogTestFailed(x, itoa(expected.start), itoa(match.matches[1].start))
            failed = true
        }

        if (!NAVAssertIntegerEqual('Should have the correct end position', match.matches[1].end, expected.end)) {
            NAVLogTestFailed(x, itoa(expected.end), itoa(match.matches[1].end))
            failed = true
        }

        if (!NAVAssertStringEqual('Should match the correct text', match.matches[1].text, expected.text)) {
            NAVLogTestFailed(x, expected.text, match.matches[1].text)
            failed = true
        }

        if (failed) {
            NAVLogTestFailed(x, '', '')
            continue
        }

        NAVLogTestPassed(x)
    }
}
