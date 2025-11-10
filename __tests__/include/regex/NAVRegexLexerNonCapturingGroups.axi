PROGRAM_NAME='NAVRegexLexerNonCapturingGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_NON_CAPTURING_GROUPS_PATTERN_TEST[][255] = {
    '/(?:\d+)/',                                         // 1: Simple non-capturing group
    '/(?:\w+)@(\w+)/',                                   // 2: Mix of non-capturing and capturing
    '/(?:abc)/',                                         // 3: Non-capturing with literal
    '/(?:\d{2,4})/',                                     // 4: Non-capturing with quantifier
    '/(?:[a-z]+)/',                                      // 5: Non-capturing with character class
    '/(?:https?):\/\/(\w+)/',                           // 6: Non-capturing protocol, capturing domain
    '/(?:\d+)-(?:\d+)/',                                 // 7: Multiple non-capturing groups
    '/(?:(?:\d+))/',                                     // 8: Nested non-capturing groups
    '/(?:)/',                                            // 9: Empty non-capturing group
    '/(?:\w+):(\d+)/',                                   // 10: Non-capturing key, capturing value
    '/^(?:\w+)$/',                                       // 11: Non-capturing with anchors
    '/(?:.+)/',                                          // 12: Non-capturing with wildcard
    '/(?:\d)(?:\d)(?:\d)/',                             // 13: Multiple adjacent non-capturing
    '/(?:test)/',                                        // 14: Simple literal non-capturing
    '/(?:\s+)/',                                         // 15: Non-capturing whitespace
    '/(?:[0-9]+)/',                                      // 16: Non-capturing digit range
    '/(?:[A-Z])/',                                       // 17: Non-capturing uppercase
    '/(?:(?:inner))/',                                   // 18: Nested non-capturing
    '/(\w+)(?:@)(\w+)/'                                 // 19: Capturing around non-capturing
}

constant integer REGEX_LEXER_NON_CAPTURING_GROUPS_EXPECTED_TOKENS[][] = {
    {
        // Test 1: /(?:\d+)/ -> NON_CAPTURE_GROUP_START, DIGIT, PLUS, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 2: /(?:\w+)@(\w+)/ -> NON_CAPTURE_GROUP_START, WORD, PLUS, NON_CAPTURE_GROUP_END, CHAR(@), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 3: /(?:abc)/ -> NON_CAPTURE_GROUP_START, CHAR(a), CHAR(b), CHAR(c), NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 4: /(?:\d{2,4})/ -> NON_CAPTURE_GROUP_START, DIGIT, QUANTIFIER, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 5: /(?:[a-z]+)/ -> NON_CAPTURE_GROUP_START, CHAR_CLASS, PLUS, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 6: /(?:https?):\/\/(\w+)/ -> NON_CAPTURE_GROUP_START, CHAR(h), CHAR(t), CHAR(t), CHAR(p), CHAR(s), QUESTIONMARK, NON_CAPTURE_GROUP_END, CHAR(:), CHAR(/), CHAR(/), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 7: /(?:\d+)-(?:\d+)/ -> NON_CAPTURE_GROUP_START, DIGIT, PLUS, NON_CAPTURE_GROUP_END, CHAR(-), NON_CAPTURE_GROUP_START, DIGIT, PLUS, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 8: /(?:(?:\d+))/ -> NON_CAPTURE_GROUP_START, NON_CAPTURE_GROUP_START, DIGIT, PLUS, NON_CAPTURE_GROUP_END, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 9: /(?:)/ -> NON_CAPTURE_GROUP_START, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 10: /(?:\w+):(\d+)/ -> NON_CAPTURE_GROUP_START, WORD, PLUS, NON_CAPTURE_GROUP_END, CHAR(:), GROUP_START, DIGIT, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 11: /^(?:\w+)$/ -> BEGIN, NON_CAPTURE_GROUP_START, WORD, PLUS, NON_CAPTURE_GROUP_END, END
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 12: /(?:.+)/ -> NON_CAPTURE_GROUP_START, DOT, PLUS, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 13: /(?:\d)(?:\d)(?:\d)/ -> NON_CAPTURE_GROUP_START, DIGIT, NON_CAPTURE_GROUP_END, NON_CAPTURE_GROUP_START, DIGIT, NON_CAPTURE_GROUP_END, NON_CAPTURE_GROUP_START, DIGIT, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 14: /(?:test)/ -> NON_CAPTURE_GROUP_START, CHAR(t), CHAR(e), CHAR(s), CHAR(t), NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 15: /(?:\s+)/ -> NON_CAPTURE_GROUP_START, WHITESPACE, PLUS, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 16: /(?:[0-9]+)/ -> NON_CAPTURE_GROUP_START, CHAR_CLASS, PLUS, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 17: /(?:[A-Z])/ -> NON_CAPTURE_GROUP_START, CHAR_CLASS, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 18: /(?:(?:inner))/ -> NON_CAPTURE_GROUP_START, NON_CAPTURE_GROUP_START, CHAR(i), CHAR(n), CHAR(n), CHAR(e), CHAR(r), NON_CAPTURE_GROUP_END, NON_CAPTURE_GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 19: /(\w+)(?:@)(\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, NON_CAPTURE_GROUP_START, CHAR(@), NON_CAPTURE_GROUP_END, GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    }
}

DEFINE_FUNCTION TestNAVRegexLexerNonCapturingGroups() {
    stack_var integer i

    NAVLog("'***************** NAVRegexLexer - Non-Capturing Groups *****************'")

    for (i = 1; i <= length_array(REGEX_LEXER_NON_CAPTURING_GROUPS_PATTERN_TEST); i++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_NON_CAPTURING_GROUPS_PATTERN_TEST[i], lexer))) {
            NAVLogTestFailed(i, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_NON_CAPTURING_GROUPS_EXPECTED_TOKENS[i])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(i, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer j
            stack_var char failed

            for (j = 1; j <= lexer.tokenCount; j++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(j), ' should be correct'", REGEX_LEXER_NON_CAPTURING_GROUPS_EXPECTED_TOKENS[i][j], lexer.tokens[j].type)) {
                    NAVLogTestFailed(i, NAVRegexLexerGetTokenType(REGEX_LEXER_NON_CAPTURING_GROUPS_EXPECTED_TOKENS[i][j]), NAVRegexLexerGetTokenType(lexer.tokens[j].type))
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        NAVLogTestPassed(i)
    }
}






