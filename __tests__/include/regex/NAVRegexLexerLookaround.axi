PROGRAM_NAME='NAVRegexLexerLookaround'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_LOOKAROUND_PATTERN_TEST[][255] = {
    '/(?=a)/',                      // 1: Simple positive lookahead
    '/(?=abc)/',                    // 2: Positive lookahead with sequence
    '/(?!\d)/',                     // 3: Simple negative lookahead
    '/(?![0-9])/',                  // 4: Negative lookahead with char class
    '/a(?=b)c/',                    // 5: Positive lookahead in middle
    '/a(?!b)c/',                    // 6: Negative lookahead in middle
    '/(?<=a)b/',                    // 7: Simple positive lookbehind
    '/(?<=abc)d/',                  // 8: Positive lookbehind with sequence
    '/(?<!a)b/',                    // 9: Simple negative lookbehind
    '/(?<![0-9])a/',                // 10: Negative lookbehind with char class
    '/a(?<=b)c/',                   // 11: Positive lookbehind in middle
    '/a(?<!b)c/',                   // 12: Negative lookbehind in middle
    '/(?=\d+)/',                    // 13: Positive lookahead with quantifier
    '/(?!\w+)/',                    // 14: Negative lookahead with quantifier
    '/(?<=\d+)/',                   // 15: Positive lookbehind with quantifier
    '/(?<!\w+)/',                   // 16: Negative lookbehind with quantifier
    '/(?=a)(?=b)/',                 // 17: Multiple positive lookaheads
    '/(?!a)(?!b)/',                 // 18: Multiple negative lookaheads
    '/(?<=a)(?<=b)/',               // 19: Multiple positive lookbehinds
    '/(?<!a)(?<!b)/',               // 20: Multiple negative lookbehinds
    '/(?=a)(?!b)/',                 // 21: Mixed lookaheads
    '/(?<=a)(?<!b)/',               // 22: Mixed lookbehinds
    '/(?=(?:a|b))/',                // 23: Lookahead with non-capturing group
    '/(?!(?:a|b))/',                // 24: Negative lookahead with alternation
    '/(?=a|b)/',                    // 25: Lookahead with alternation
    '/(?!a|b)/',                    // 26: Negative lookahead with alternation
    '/(?=(a))/',                    // 27: Lookahead with capturing group
    '/(?!(a))/',                    // 28: Negative lookahead with capturing group
    '/(?<=^)/',                     // 29: Lookbehind with anchor
    '/(?=\$)/',                     // 30: Lookahead with escaped anchor
    '/(?=.)/',                      // 31: Lookahead with dot
    '/(?!.)/',                      // 32: Negative lookahead with dot
    '/(?<=.)/',                     // 33: Lookbehind with dot
    '/(?<!.)/',                     // 34: Negative lookbehind with dot
    '/(?=[a-z])/',                  // 35: Lookahead with char class range
    '/(?<=[A-Z])/'                  // 36: Lookbehind with char class range
}

constant integer REGEX_LEXER_LOOKAROUND_EXPECTED_TOKENS[][] = {
    {
        // Test 1: /(?=a)/ -> LOOKAHEAD_POSITIVE, CHAR(a), GROUP_END
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 2: /(?=abc)/ -> LOOKAHEAD_POSITIVE, CHAR(a), CHAR(b), CHAR(c), GROUP_END
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 3: /(?!\d)/ -> LOOKAHEAD_NEGATIVE, DIGIT, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 4: /(?![0-9])/ -> LOOKAHEAD_NEGATIVE, CHAR_CLASS, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 5: /a(?=b)c/ -> CHAR(a), LOOKAHEAD_POSITIVE, CHAR(b), GROUP_END, CHAR(c)
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 6: /a(?!b)c/ -> CHAR(a), LOOKAHEAD_NEGATIVE, CHAR(b), GROUP_END, CHAR(c)
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 7: /(?<=a)b/ -> LOOKBEHIND_POSITIVE, CHAR(a), GROUP_END, CHAR(b)
        REGEX_TOKEN_LOOKBEHIND_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 8: /(?<=abc)d/ -> LOOKBEHIND_POSITIVE, CHAR(a), CHAR(b), CHAR(c), GROUP_END, CHAR(d)
        REGEX_TOKEN_LOOKBEHIND_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 9: /(?<!a)b/ -> LOOKBEHIND_NEGATIVE, CHAR(a), GROUP_END, CHAR(b)
        REGEX_TOKEN_LOOKBEHIND_NEGATIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 10: /(?<![0-9])a/ -> LOOKBEHIND_NEGATIVE, CHAR_CLASS, GROUP_END, CHAR(a)
        REGEX_TOKEN_LOOKBEHIND_NEGATIVE,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 11: /a(?<=b)c/ -> CHAR(a), LOOKBEHIND_POSITIVE, CHAR(b), GROUP_END, CHAR(c)
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_LOOKBEHIND_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 12: /a(?<!b)c/ -> CHAR(a), LOOKBEHIND_NEGATIVE, CHAR(b), GROUP_END, CHAR(c)
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_LOOKBEHIND_NEGATIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 13: /(?=\d+)/ -> LOOKAHEAD_POSITIVE, DIGIT, PLUS, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 14: /(?!\w+)/ -> LOOKAHEAD_NEGATIVE, ALPHA, PLUS, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 15: /(?<=\d+)/ -> LOOKBEHIND_POSITIVE, DIGIT, PLUS, GROUP_END
        REGEX_TOKEN_LOOKBEHIND_POSITIVE,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 16: /(?<!\w+)/ -> LOOKBEHIND_NEGATIVE, ALPHA, PLUS, GROUP_END
        REGEX_TOKEN_LOOKBEHIND_NEGATIVE,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 17: /(?=a)(?=b)/ -> LOOKAHEAD_POSITIVE, CHAR(a), GROUP_END, LOOKAHEAD_POSITIVE, CHAR(b), GROUP_END
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 18: /(?!a)(?!b)/ -> LOOKAHEAD_NEGATIVE, CHAR(a), GROUP_END, LOOKAHEAD_NEGATIVE, CHAR(b), GROUP_END
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 19: /(?<=a)(?<=b)/ -> LOOKBEHIND_POSITIVE, CHAR(a), GROUP_END, LOOKBEHIND_POSITIVE, CHAR(b), GROUP_END
        REGEX_TOKEN_LOOKBEHIND_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_LOOKBEHIND_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 20: /(?<!a)(?<!b)/ -> LOOKBEHIND_NEGATIVE, CHAR(a), GROUP_END, LOOKBEHIND_NEGATIVE, CHAR(b), GROUP_END
        REGEX_TOKEN_LOOKBEHIND_NEGATIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_LOOKBEHIND_NEGATIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 21: /(?=a)(?!b)/ -> LOOKAHEAD_POSITIVE, CHAR(a), GROUP_END, LOOKAHEAD_NEGATIVE, CHAR(b), GROUP_END
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 22: /(?<=a)(?<!b)/ -> LOOKBEHIND_POSITIVE, CHAR(a), GROUP_END, LOOKBEHIND_NEGATIVE, CHAR(b), GROUP_END
        REGEX_TOKEN_LOOKBEHIND_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_LOOKBEHIND_NEGATIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 23: /(?=(?:a|b))/ -> LOOKAHEAD_POSITIVE, GROUP_START, CHAR(a), ALTERNATION, CHAR(b), GROUP_END, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 24: /(?!(?:a|b))/ -> LOOKAHEAD_NEGATIVE, GROUP_START, CHAR(a), ALTERNATION, CHAR(b), GROUP_END, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 25: /(?=a|b)/ -> LOOKAHEAD_POSITIVE, CHAR(a), ALTERNATION, CHAR(b), GROUP_END
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 26: /(?!a|b)/ -> LOOKAHEAD_NEGATIVE, CHAR(a), ALTERNATION, CHAR(b), GROUP_END
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 27: /(?=(a))/ -> LOOKAHEAD_POSITIVE, GROUP_START, CHAR(a), GROUP_END, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 28: /(?!(a))/ -> LOOKAHEAD_NEGATIVE, GROUP_START, CHAR(a), GROUP_END, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 29: /(?<=^)/ -> LOOKBEHIND_POSITIVE, BEGIN, GROUP_END
        REGEX_TOKEN_LOOKBEHIND_POSITIVE,
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 30: /(?=\$)/ -> LOOKAHEAD_POSITIVE, CHAR($), GROUP_END (escaped $ is literal)
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 31: /(?=.)/ -> LOOKAHEAD_POSITIVE, DOT, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 32: /(?!.)/ -> LOOKAHEAD_NEGATIVE, DOT, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 33: /(?<=.)/ -> LOOKBEHIND_POSITIVE, DOT, GROUP_END
        REGEX_TOKEN_LOOKBEHIND_POSITIVE,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 34: /(?<!.)/ -> LOOKBEHIND_NEGATIVE, DOT, GROUP_END
        REGEX_TOKEN_LOOKBEHIND_NEGATIVE,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 35: /(?=[a-z])/ -> LOOKAHEAD_POSITIVE, CHAR_CLASS, GROUP_END
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 36: /(?<=[A-Z])/ -> LOOKBEHIND_POSITIVE, CHAR_CLASS, GROUP_END
        REGEX_TOKEN_LOOKBEHIND_POSITIVE,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    }
}


/**
 * @function TestNAVRegexLexerLookaround
 * @public
 * @description Tests lexer tokenization of lookaround assertions.
 *
 * Validates:
 * - Positive lookahead (?=...)
 * - Negative lookahead (?!...)
 * - Positive lookbehind (?<=...)
 * - Negative lookbehind (?<!...)
 * - Lookaround with various content (chars, classes, quantifiers)
 * - Multiple lookarounds in sequence
 * - Nested groups within lookarounds
 */
define_function TestNAVRegexLexerLookaround() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Lookaround Assertions *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_LOOKAROUND_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer y

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_LOOKAROUND_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVAssertIntegerEqual('Token count should match', length_array(REGEX_LEXER_LOOKAROUND_EXPECTED_TOKENS[x]), lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_LEXER_LOOKAROUND_EXPECTED_TOKENS[x])), itoa(lexer.tokenCount))
            continue
        }

        for (y = 1; y <= lexer.tokenCount; y++) {
            if (!NAVAssertIntegerEqual('Token type should match', REGEX_LEXER_LOOKAROUND_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                NAVLogTestFailed(x, itoa(REGEX_LEXER_LOOKAROUND_EXPECTED_TOKENS[x][y]), itoa(lexer.tokens[y].type))
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
