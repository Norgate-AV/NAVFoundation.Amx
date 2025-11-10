PROGRAM_NAME='NAVRegexLexerStringAnchors'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_STRING_ANCHORS_PATTERN_TEST[][255] = {
    // String start anchor \A
    '/\A/',             // 1: Simple string start
    '/\Atest/',         // 2: String start with text
    '/\A\w+/',          // 3: String start with word chars
    '/\A\d+/',          // 4: String start with digits
    '/\A[a-z]+/',       // 5: String start with char class

    // String end anchor \Z (before optional final newline)
    '/\Z/',             // 6: Simple string end
    '/test\Z/',         // 7: Text with string end
    '/\w+\Z/',          // 8: Word chars with string end
    '/\d+\Z/',          // 9: Digits with string end
    '/[a-z]+\Z/',       // 10: Char class with string end

    // String end absolute anchor \z
    '/\z/',             // 11: Simple absolute end
    '/test\z/',         // 12: Text with absolute end
    '/\w+\z/',          // 13: Word chars with absolute end
    '/\d+\z/',          // 14: Digits with absolute end
    '/[a-z]+\z/',       // 15: Char class with absolute end

    // Combined string anchors
    '/\A.*\Z/',         // 16: String start to end (before newline)
    '/\A.*\z/',         // 17: String start to absolute end
    '/\A\w+\Z/',        // 18: Word from start to end
    '/\A\w+\z/',        // 19: Word from start to absolute end

    // String anchors with groups
    '/\A(test)/',       // 20: String start with capturing group
    '/\A(?:test)/',     // 21: String start with non-capturing group
    '/(test)\Z/',       // 22: String end with capturing group
    '/(test)\z/',       // 23: Absolute end with capturing group

    // String anchors with quantifiers
    '/\Atest+/',        // 24: String start with quantifier
    '/test+\Z/',        // 25: String end with quantifier
    '/\Atest*\z/',      // 26: String start to absolute end with quantifier
    '/\Atest{2,5}\Z/',  // 27: String start to end with bounded quantifier

    // String anchors with alternation
    '/\Aone|\Atwo/',    // 28: Alternation with string starts
    '/one\Z|two\Z/',    // 29: Alternation with string ends

    // Multiple string anchors (edge cases)
    '/\A\A/',           // 30: Multiple string starts
    '/\Z\Z/',           // 31: Multiple string ends
    '/\z\z/',           // 32: Multiple absolute ends

    // String anchors vs line anchors
    '/^\A/',            // 33: Line start with string start
    '/\Z$/',            // 34: String end with line end
    '/^\A.*\Z$/'        // 35: Combined line and string anchors
}

constant integer REGEX_LEXER_STRING_ANCHORS_EXPECTED_TOKENS[][] = {
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // n
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_CHAR,   // n
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // w
        REGEX_TOKEN_CHAR,   // o
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_STRING_END_ABSOLUTE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    }
}


define_function TestNAVRegexLexerStringAnchors() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - String Anchors *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_STRING_ANCHORS_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_STRING_ANCHORS_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_STRING_ANCHORS_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_STRING_ANCHORS_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_STRING_ANCHORS_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
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
