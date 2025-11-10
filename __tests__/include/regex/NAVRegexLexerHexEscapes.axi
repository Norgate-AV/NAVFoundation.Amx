PROGRAM_NAME='NAVRegexLexerHexEscapes'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_HEX_ESCAPES_PATTERN_TEST[][255] = {
    // Valid hex escapes
    '/\x00/',           // 1: Null character
    '/\xFF/',           // 2: Max value (uppercase)
    '/\xff/',           // 3: Max value (lowercase)
    '/\x41/',           // 4: Letter 'A'
    '/\x61/',           // 5: Letter 'a'
    '/\xAf/',           // 6: Mixed case
    '/\xaF/',           // 7: Mixed case (different)
    '/\x20/',           // 8: Space character
    '/\x09/',           // 9: Tab character
    '/\x0A/',           // 10: Newline character
    '/\x0D/',           // 11: Carriage return

    // Multiple hex escapes
    '/\x41\x42/',       // 12: Two hex escapes (AB)
    '/\x41\x42\x43/',   // 13: Three hex escapes (ABC)

    // Hex escapes with other tokens
    '/test\xFF/',       // 14: At end of pattern
    '/\xFFtest/',       // 15: At start of pattern
    '/\x41+/',          // 16: With quantifier
    '/\x41*/',          // 17: With quantifier
    '/\x41?/',          // 18: With quantifier
    '/\x41{2}/',        // 19: With bounded quantifier
    '/\x41{2,5}/',      // 20: With bounded quantifier range

    // Hex escapes in groups
    '/(\x41)/',         // 21: In capturing group
    '/(?:\x41)/',       // 22: In non-capturing group

    // Hex escapes with anchors
    '/^\x41/',          // 23: With start anchor
    '/\x41$/',          // 24: With end anchor
    '/^\x41$/',         // 25: With both anchors

    // Hex escapes with alternation
    '/\x41|\x42/',      // 26: Alternation

    // Hex escapes with other escape sequences
    '/\x41\d+/',        // 27: With digit class
    '/\w+\x20\w+/',     // 28: Space between words
    '/\x0A\x0D/',       // 29: CRLF sequence
    '/\x09\x20/'        // 30: Tab and space
}

constant integer REGEX_LEXER_HEX_ESCAPES_EXPECTED_TOKENS[][] = {
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_HEX,
        REGEX_TOKEN_EOF
    }
}

constant integer REGEX_LEXER_HEX_ESCAPES_EXPECTED_VALUES[] = {
    $00,    // 1: \x00
    $FF,    // 2: \xFF
    $FF,    // 3: \xff
    $41,    // 4: \x41 (A)
    $61,    // 5: \x61 (a)
    $AF,    // 6: \xAf
    $AF,    // 7: \xaF
    $20,    // 8: \x20 (space)
    $09,    // 9: \x09 (tab)
    $0A,    // 10: \x0A (newline)
    $0D     // 11: \x0D (carriage return)
}

constant char REGEX_LEXER_HEX_ESCAPES_ERROR_PATTERN_TEST[][255] = {
    // Invalid hex escapes
    '/\x/',             // 1: Missing hex digits
    '/\xG/',            // 2: Invalid hex digit (first)
    '/\x1/',            // 3: Only one hex digit
    '/\x1G/',           // 4: Invalid hex digit (second)
    '/\xGG/',           // 5: Both digits invalid
    '/\xZ1/',           // 6: First digit invalid
    '/\x1Z/'            // 7: Second digit invalid
}


define_function TestNAVRegexLexerHexEscapes() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Hex Escapes *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_HEX_ESCAPES_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_HEX_ESCAPES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_HEX_ESCAPES_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_HEX_ESCAPES_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_HEX_ESCAPES_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
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


define_function TestNAVRegexLexerHexEscapesValues() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Hex Escapes Values *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_HEX_ESCAPES_EXPECTED_VALUES); x++) {
        stack_var _NAVRegexLexer lexer

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_HEX_ESCAPES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // First token should be HEX type
        if (!NAVAssertIntegerEqual('First token should be HEX', REGEX_TOKEN_HEX, lexer.tokens[1].type)) {
            NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_TOKEN_HEX), NAVRegexLexerGetTokenType(lexer.tokens[1].type))
            continue
        }

        // Verify the hex value was correctly parsed
        if (!NAVAssertIntegerEqual('Hex value should match expected', REGEX_LEXER_HEX_ESCAPES_EXPECTED_VALUES[x], lexer.tokens[1].value)) {
            NAVLogTestFailed(x, "itohex(REGEX_LEXER_HEX_ESCAPES_EXPECTED_VALUES[x])", "itohex(lexer.tokens[1].value)")
            continue
        }

        NAVLogTestPassed(x)
    }
}


define_function TestNAVRegexLexerHexEscapesErrors() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Hex Escapes Error Cases *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_HEX_ESCAPES_ERROR_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var char result

        result = NAVRegexLexerTokenize(REGEX_LEXER_HEX_ESCAPES_ERROR_PATTERN_TEST[x], lexer)

        if (!NAVAssertFalse('Should fail to tokenize', result)) {
            NAVLogTestFailed(x, 'false', 'true')
            continue
        }

        NAVLogTestPassed(x)
    }
}

