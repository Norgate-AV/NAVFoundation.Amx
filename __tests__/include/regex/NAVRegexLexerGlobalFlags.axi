PROGRAM_NAME='NAVRegexLexerGlobalFlags'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

/**
 * Test patterns for global flags extraction.
 *
 * Global flags appear after the closing delimiter:
 * - i: Case-insensitive
 * - m: Multiline
 * - s: Dotall
 * - g: Global
 * - x: Extended (not yet implemented)
 *
 * Tests verify that the lexer correctly extracts the flags string
 * without interpreting it (interpretation is the parser's job).
 */
constant char REGEX_LEXER_GLOBAL_FLAGS_PATTERN_TEST[][255] = {
    // No flags
    '/abc/',                    // 1: No flags - empty string
    '/\d+/',                    // 2: No flags with escape sequence

    // Single flags
    '/abc/i',                   // 3: Case-insensitive flag
    '/abc/m',                   // 4: Multiline flag
    '/abc/s',                   // 5: Dotall flag
    '/abc/g',                   // 6: Global flag
    '/abc/x',                   // 7: Extended flag (future)

    // Multiple flags
    '/abc/gi',                  // 8: Global + case-insensitive
    '/abc/im',                  // 9: Case-insensitive + multiline
    '/abc/is',                  // 10: Case-insensitive + dotall
    '/abc/ms',                  // 11: Multiline + dotall
    '/abc/gim',                 // 12: Global + case-insensitive + multiline
    '/abc/ims',                 // 13: Case-insensitive + multiline + dotall
    '/abc/gims',                // 14: All four flags

    // Flags with complex patterns
    '/\d+/g',                   // 15: Flags with escape sequence
    '/[a-z]+/i',                // 16: Flags with character class
    '/(a|b)+/m',                // 17: Flags with alternation
    '/^test$/im',               // 18: Flags with anchors
    '/(?:abc)/s',               // 19: Flags with non-capturing group
    '/\w+\s+\d+/gim',           // 20: Complex pattern with multiple flags

    // Uppercase flags (should be lowercased)
    '/abc/I',                   // 21: Uppercase I
    '/abc/IM',                  // 22: Uppercase IM
    '/abc/GIMS',                // 23: All uppercase

    // Edge cases
    '//',                       // 24: Empty pattern, no flags
    '//g',                      // 25: Empty pattern, with flag
    '/a/',                      // 26: Single char, no flags
    '/a/i'                      // 27: Single char, with flag
}

constant char REGEX_LEXER_GLOBAL_FLAGS_EXPECTED[][10] = {
    '',         // 1: No flags
    '',         // 2: No flags

    'i',        // 3: i
    'm',        // 4: m
    's',        // 5: s
    'g',        // 6: g
    'x',        // 7: x

    'gi',       // 8: gi
    'im',       // 9: im
    'is',       // 10: is
    'ms',       // 11: ms
    'gim',      // 12: gim
    'ims',      // 13: ims
    'gims',     // 14: gims

    'g',        // 15: g
    'i',        // 16: i
    'm',        // 17: m
    'im',       // 18: im
    's',        // 19: s
    'gim',      // 20: gim

    'I',        // 21: I (lexer doesn't lowercase - parser does)
    'IM',       // 22: IM
    'GIMS',     // 23: GIMS

    '',         // 24: Empty pattern, no flags
    'g',        // 25: Empty pattern, with flag
    '',         // 26: Single char, no flags
    'i'         // 27: Single char, with flag
}


define_function TestNAVRegexLexerGlobalFlags() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Global Flags *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_GLOBAL_FLAGS_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_GLOBAL_FLAGS_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the global flags were extracted correctly
        if (!NAVAssertStringEqual('Should extract correct global flags',
                                  REGEX_LEXER_GLOBAL_FLAGS_EXPECTED[x],
                                  lexer.globalFlags)) {
            NAVLogTestFailed(x,
                           REGEX_LEXER_GLOBAL_FLAGS_EXPECTED[x],
                           lexer.globalFlags)
            continue
        }

        NAVLogTestPassed(x)
    }
}
