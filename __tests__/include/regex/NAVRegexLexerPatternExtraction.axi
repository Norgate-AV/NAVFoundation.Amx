PROGRAM_NAME='NAVRegexLexerPatternExtraction'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

/**
 * Test patterns for pattern/flags extraction.
 *
 * Tests verify that the lexer correctly extracts:
 * - Pattern content (between delimiters)
 * - Global flags (after closing delimiter)
 * - Handles various edge cases and formats
 */
constant char REGEX_LEXER_PATTERN_EXTRACTION_INPUT[][255] = {
    // Basic patterns
    '/abc/',                        // 1: Simple pattern, no flags
    '/abc/i',                       // 2: Simple pattern with flag
    '/abc/gi',                      // 3: Simple pattern with multiple flags
    '//',                           // 4: Empty pattern, no flags
    '//i',                          // 5: Empty pattern with flag

    // Patterns with special characters
    '/a.b/',                        // 6: Pattern with dot
    '/a\d+b/',                      // 7: Pattern with escape sequence
    '/[a-z]+/',                     // 8: Pattern with character class
    '/(abc)/',                      // 9: Pattern with group
    '/a|b/',                        // 10: Pattern with alternation

    // Patterns with escaped delimiters
    '/a\/b/',                       // 11: Escaped forward slash
    '/a\/b\/c/',                    // 12: Multiple escaped slashes
    '/\//',                         // 13: Just escaped slash
    '/\/\//i',                      // 14: Escaped slashes with flag

    // Complex patterns
    '/^https?:\/\/[\w.-]+\.\w{2,}$/',           // 15: URL pattern
    '/(?P<year>\d{4})-(?P<month>\d{2})/',       // 16: Named groups
    '/(?:(?:https?):)?\/\//',                   // 17: Nested non-capturing groups
    '/\b\w+@\w+\.\w+\b/i',                      // 18: Email-like with boundaries

    // Patterns with all flag types
    '/test/g',                      // 19: Global flag
    '/test/i',                      // 20: Case-insensitive flag
    '/test/m',                      // 21: Multiline flag
    '/test/s',                      // 22: Dotall flag
    '/test/x',                      // 23: Extended flag
    '/test/gims',                   // 24: All flags combined
    '/test/gimsxx',                 // 25: Duplicate flags (lexer doesn't validate)

    // Edge cases with whitespace in pattern
    '/a b c/',                      // 26: Pattern with spaces
    '/\s+/',                        // 27: Whitespace pattern
    '/ /',                          // 28: Single space
    '/\t\n\r/',                     // 29: Escape sequences for whitespace

    // Patterns with quantifiers
    '/a+/',                         // 30: Plus quantifier
    '/a*/',                         // 31: Star quantifier
    '/a?/',                         // 32: Question mark quantifier
    '/a{3}/',                       // 33: Exact count
    '/a{3,}/',                      // 34: Min count
    '/a{3,5}/',                     // 35: Range count

    // Patterns with anchors
    '/^abc/',                       // 36: Start anchor
    '/abc$/',                       // 37: End anchor
    '/^abc$/',                      // 38: Both anchors
    '/\Aabc\z/',                    // 39: String anchors

    // Patterns with character classes
    '/[abc]/',                      // 40: Simple class
    '/[^abc]/',                     // 41: Negated class
    '/[a-z]/',                      // 42: Range class
    '/[a-zA-Z0-9_]/',               // 43: Multiple ranges
    '/[\d\w\s]/',                   // 44: Predefined classes

    // Uppercase flags (lexer doesn't lowercase)
    '/test/I',                      // 45: Uppercase I
    '/test/GM',                     // 46: Uppercase GM
    '/test/GIMS',                   // 47: All uppercase

    // Mixed case flags
    '/test/Gi',                     // 48: Mixed case
    '/test/gIMs',                   // 49: Mixed case multiple

    // Long patterns
    '/abcdefghijklmnopqrstuvwxyz/',                 // 50: Long literal
    '/\d+\.\d+\.\d+\.\d+/',                         // 51: IP-like pattern
    '/(?:(?:[01]?\d\d?|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d\d?|2[0-4]\d|25[0-5])/',  // 52: Full IP validation
    '',                             // 53: Empty input
    '/',                             // 54: Only opening delimiter

    // Edge case: only delimiters
    // Currently a warning is printed saying "invalid global flag '/'".
    // This case should ideally fail lexing with unescaped delimiter error??
    '///',                           // 55: Only delimiters (What should happen? Should fail but what error should be printed???)
    '/a/b/'                        // 56: Unescaped delimiter in pattern (should error)
}

constant char REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_PATTERN[][255] = {
    'abc',                          // 1
    'abc',                          // 2
    'abc',                          // 3
    '',                             // 4
    '',                             // 5
    'a.b',                          // 6
    'a\d+b',                        // 7
    '[a-z]+',                       // 8
    '(abc)',                        // 9
    'a|b',                          // 10
    'a\/b',                         // 11
    'a\/b\/c',                      // 12
    '\/',                           // 13
    '\/\/',                         // 14
    '^https?:\/\/[\w.-]+\.\w{2,}$', // 15
    '(?P<year>\d{4})-(?P<month>\d{2})', // 16
    '(?:(?:https?):)?\/\/',         // 17
    '\b\w+@\w+\.\w+\b',             // 18
    'test',                         // 19
    'test',                         // 20
    'test',                         // 21
    'test',                         // 22
    'test',                         // 23
    'test',                         // 24
    'test',                         // 25
    'a b c',                        // 26
    '\s+',                          // 27
    ' ',                            // 28
    '\t\n\r',                       // 29
    'a+',                           // 30
    'a*',                           // 31
    'a?',                           // 32
    'a{3}',                         // 33
    'a{3,}',                        // 34
    'a{3,5}',                       // 35
    '^abc',                         // 36
    'abc$',                         // 37
    '^abc$',                        // 38
    '\Aabc\z',                      // 39
    '[abc]',                        // 40
    '[^abc]',                       // 41
    '[a-z]',                        // 42
    '[a-zA-Z0-9_]',                 // 43
    '[\d\w\s]',                     // 44
    'test',                         // 45
    'test',                         // 46
    'test',                         // 47
    'test',                         // 48
    'test',                         // 49
    'abcdefghijklmnopqrstuvwxyz',   // 50
    '\d+\.\d+\.\d+\.\d+',           // 51
    '(?:(?:[01]?\d\d?|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d\d?|2[0-4]\d|25[0-5])', // 52
    '',                             // 53
    '',                              // 54
    '',                            // 55
    ''                           // 56
}

constant char REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_FLAGS[][10] = {
    '',                             // 1
    'i',                            // 2
    'gi',                           // 3
    '',                             // 4
    'i',                            // 5
    '',                             // 6
    '',                             // 7
    '',                             // 8
    '',                             // 9
    '',                             // 10
    '',                             // 11
    '',                             // 12
    '',                             // 13
    'i',                            // 14
    '',                             // 15
    '',                             // 16
    '',                             // 17
    'i',                            // 18
    'g',                            // 19
    'i',                            // 20
    'm',                            // 21
    's',                            // 22
    'x',                            // 23
    'gims',                         // 24
    'gimsxx',                       // 25
    '',                             // 26
    '',                             // 27
    '',                             // 28
    '',                             // 29
    '',                             // 30
    '',                             // 31
    '',                             // 32
    '',                             // 33
    '',                             // 34
    '',                             // 35
    '',                             // 36
    '',                             // 37
    '',                             // 38
    '',                             // 39
    '',                             // 40
    '',                             // 41
    '',                             // 42
    '',                             // 43
    '',                             // 44
    'I',                            // 45
    'GM',                           // 46
    'GIMS',                         // 47
    'Gi',                           // 48
    'gIMs',                         // 49
    '',                             // 50
    '',                             // 51
    '',                              // 52
    '',                             // 53
    '',                              // 54
    '',                              // 55
    ''                              // 56
}

constant char REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_RESULT[] = {
    true,   // 1
    true,   // 2
    true,   // 3
    true,   // 4
    true,   // 5
    true,   // 6
    true,   // 7
    true,   // 8
    true,   // 9
    true,   // 10
    true,   // 11
    true,   // 12
    true,   // 13
    true,   // 14
    true,   // 15
    true,   // 16
    true,   // 17
    true,   // 18
    true,   // 19
    true,   // 20
    true,   // 21
    true,   // 22
    true,   // 23
    true,   // 24
    true,   // 25
    true,   // 26
    true,   // 27
    true,   // 28
    true,   // 29
    true,   // 30
    true,   // 31
    true,   // 32
    true,   // 33
    true,   // 34
    true,   // 35
    true,   // 36
    true,   // 37
    true,   // 38
    true,   // 39
    true,   // 40
    true,   // 41
    true,   // 42
    true,   // 43
    true,   // 44
    true,   // 45
    true,   // 46
    true,   // 47
    true,   // 48
    true,   // 49
    true,   // 50
    true,   // 51
    true,   // 52
    false,  // 53
    false,   // 54
    false,   // 55
    false   // 56
}


define_function TestNAVRegexLexerPatternExtraction() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Pattern Extraction *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_PATTERN_EXTRACTION_INPUT); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var char result

        result = NAVRegexLexerTokenize(REGEX_LEXER_PATTERN_EXTRACTION_INPUT[x], lexer)

        if (!NAVAssertBooleanEqual('Should tokenize',
                                    REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_RESULT[x],
                                    result)) {
            NAVLogTestFailed(x, NAVBooleanToString(REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_RESULT[x]) {
            // Expected failure case, skip further checks
            NAVLogTestPassed(x)
            continue
        }

        // Verify the pattern was extracted correctly
        if (!NAVAssertStringEqual('Should extract correct pattern',
                                  REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_PATTERN[x],
                                  lexer.pattern.value)) {
            NAVLogTestFailed(x,
                           REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_PATTERN[x],
                           lexer.pattern.value)
            continue
        }

        // Verify the global flags were extracted correctly
        if (!NAVAssertStringEqual('Should extract correct flags',
                                  REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_FLAGS[x],
                                  lexer.globalFlags)) {
            NAVLogTestFailed(x,
                           REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_FLAGS[x],
                           lexer.globalFlags)
            continue
        }

        // Verify the pattern length matches the extracted pattern
        if (!NAVAssertIntegerEqual('Should have correct pattern length',
                                   length_array(REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_PATTERN[x]),
                                   lexer.pattern.length)) {
            NAVLogTestFailed(x,
                           itoa(length_array(REGEX_LEXER_PATTERN_EXTRACTION_EXPECTED_PATTERN[x])),
                           itoa(lexer.pattern.length))
            continue
        }

        NAVLogTestPassed(x)
    }
}
