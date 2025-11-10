PROGRAM_NAME='NAVRegexLexerBasic'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_BASIC_PATTERN_TEST[][255] = {
    // Basic metacharacters and quantifiers
    '/\d+/',            // 1: Digit with plus
    '/\w+/',            // 2: Word with plus
    '/\w*/',            // 3: Word with star
    '/\s/',             // 4: Single whitespace
    '/\s+/',            // 5: Whitespace with plus
    '/\s*/',            // 6: Whitespace with star
    '/\d\w?\s/',        // 7: Mixed with optional
    '/\d\w\s+/',        // 8: Mixed with plus
    '/\d?\w\s*/',       // 9: Optional digit
    '/\D+/',            // 10: Not digit with plus
    '/\D*/',            // 11: Not digit with star
    '/\D\s/',           // 12: Not digit and whitespace
    '/\W+/',            // 13: Not word with plus
    '/\S*/',            // 14: Not whitespace with star
    '/^[a-zA-Z0-9_]+$/',              // 15: Full anchors with char class
    '/^[Hh]ello,\s[Ww]orld!$/',       // 16: Complex greeting
    '/^"[^"]*"/',                      // 17: Quoted string
    '/.*/',                            // 18: Any characters
    '/\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/',  // 19: IP address pattern
    '/\d?/',            // 20: Single optional digit
    '/\d?\d?/',         // 21: Two optional digits
    '/\d?\d?\d/',       // 22: Three optional digits
    '/\//'              // 23: Escaped forward slash (literal / character)
}

constant integer REGEX_LEXER_BASIC_EXPECTED_TOKENS[][] = {
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_DIGIT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_DIGIT,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_WHITESPACE,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,  // Escaped forward slash becomes a CHAR token
        REGEX_TOKEN_EOF
    }
}


define_function TestNAVRegexLexerBasic() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Basic *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_BASIC_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_BASIC_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_BASIC_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_BASIC_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_BASIC_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
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




