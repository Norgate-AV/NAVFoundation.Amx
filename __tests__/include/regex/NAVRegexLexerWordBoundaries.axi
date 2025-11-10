PROGRAM_NAME='NAVRegexLexerWordBoundaries'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_WORD_BOUNDARIES_PATTERN_TEST[][255] = {
    // Word boundary \b
    '/\b/',             // 1: Simple word boundary
    '/\bword/',         // 2: Word boundary at start
    '/word\b/',         // 3: Word boundary at end
    '/\bword\b/',       // 4: Word boundaries at both ends
    '/\b\w+\b/',        // 5: Word boundary with word chars

    // Not word boundary \B
    '/\B/',             // 6: Simple not word boundary
    '/\Bword/',         // 7: Not word boundary before word
    '/word\B/',         // 8: Not word boundary after word
    '/\B\w+\B/',        // 9: Not word boundary with word chars

    // Combined word boundaries
    '/\b\w+\B/',        // 10: \b at start, \B at end
    '/\B\w+\b/',        // 11: \B at start, \b at end
    '/\b.*\b/',         // 12: Word boundaries with any chars

    // Word boundaries with other tokens
    '/^\bword/',        // 13: With start anchor
    '/word\b$/',        // 14: With end anchor
    '/^\bword\b$/',     // 15: With both anchors
    '/\b(word)/',       // 16: With capturing group
    '/\b(?:word)/',     // 17: With non-capturing group
    '/\bword+/',        // 18: With quantifier
    '/\bword*/',        // 19: With quantifier
    '/\bword?/',        // 20: With quantifier
    '/\bword{2}/',      // 21: With bounded quantifier
    '/\b[a-z]+\b/',     // 22: With character class
    '/\bone\b|\btwo\b/',    // 23: With alternation

    // Multiple word boundaries
    '/\b\w+\b\s+\b\w+\b/',  // 24: Multiple word boundaries
    '/\b\b\b/',         // 25: Multiple consecutive boundaries

    // Word boundaries with escapes
    '/\b\d+\b/',        // 26: With digit class
    '/\b\w+\s+\w+\b/'   // 27: Word boundaries with whitespace
}

constant integer REGEX_LEXER_WORD_BOUNDARIES_EXPECTED_TOKENS[][] = {
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_NOT_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_WORD_BOUNDARY,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_NOT_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_NOT_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_WORD_BOUNDARY,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // n
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    }
}


define_function TestNAVRegexLexerWordBoundaries() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Word Boundaries *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_WORD_BOUNDARIES_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_WORD_BOUNDARIES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_WORD_BOUNDARIES_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_WORD_BOUNDARIES_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_WORD_BOUNDARIES_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
