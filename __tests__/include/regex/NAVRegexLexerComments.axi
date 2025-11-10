PROGRAM_NAME='NAVRegexLexerComments'

DEFINE_CONSTANT

/**
 * Test patterns for comment tokenization.
 *
 * Comments in regex: (?#...)
 * - Can contain any text except )
 * - Are ignored by the regex engine
 * - Useful for documenting complex patterns
 */
constant char REGEX_LEXER_COMMENTS_PATTERN_TEST[][255] = {
    // Basic comments
    '/(?#)/',                       // 1: Empty comment
    '/(?#test)/',                   // 2: Simple comment
    '/(?#this is a comment)/',      // 3: Comment with spaces
    '/test(?#comment)abc/',         // 4: Comment between literals

    // Comments with special characters
    '/(?#!)/',                      // 5: Comment with exclamation
    '/(?#@#$%^&*)/',                // 6: Comment with special chars
    '/(?#[]{}<>)/',                 // 7: Comment with brackets
    '/(?#\n\t)/',                   // 8: Comment with escapes

    // Comments in various positions
    '/(?#start)test/',              // 9: Comment at start
    '/test(?#end)/',                // 10: Comment at end
    '/(?#)test(?#)/',               // 11: Comments at both ends
    '/te(?#mid)st/',                // 12: Comment in middle of literal

    // Comments with regex constructs
    '/(?#comment)[a-z]+/',          // 13: Comment before char class
    '/[a-z]+(?#comment)/',          // 14: Comment after char class
    '/(?#comment)(test)/',          // 15: Comment before group
    '/(test)(?#comment)/',          // 16: Comment after group
    '/(?#comment)^test$/',          // 17: Comment before anchors
    '/^test$(?#comment)/',          // 18: Comment after anchors

    // Multiple comments
    '/(?#one)(?#two)/',             // 19: Two consecutive comments
    '/(?#one)test(?#two)/',         // 20: Two comments with text between
    '/(?#a)(?#b)(?#c)/'             // 21: Three comments
}

constant integer REGEX_LEXER_COMMENTS_EXPECTED_TOKENS[][] = {
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_CHAR,   // a
        REGEX_TOKEN_CHAR,   // b
        REGEX_TOKEN_CHAR,   // c
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
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
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_END,
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_COMMENT,
        REGEX_TOKEN_EOF
    }
}


define_function TestNAVRegexLexerComments() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Comments *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_COMMENTS_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_COMMENTS_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_COMMENTS_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_COMMENTS_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_COMMENTS_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
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
