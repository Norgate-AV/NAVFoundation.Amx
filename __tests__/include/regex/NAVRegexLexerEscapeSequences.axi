PROGRAM_NAME='NAVRegexLexerEscapeSequences'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_ESCAPE_SEQUENCES_PATTERN_TEST[][255] = {
    // Form feed \f (ASCII 12)
    '/\f/',                 // 1: Single form feed
    '/test\f/',             // 2: At end of pattern
    '/\ftest/',             // 3: At start of pattern
    '/\f+/',                // 4: With quantifier
    '/\f*/',                // 5: With star quantifier
    '/\f?/',                // 6: With optional quantifier
    '/\f{2}/',              // 7: With bounded quantifier
    '/(\f)/',               // 8: In capturing group
    '/(?:\f)/',             // 9: In non-capturing group
    '/^\f/',                // 10: With start anchor
    '/\f$/',                // 11: With end anchor
    '/\f|\n/',              // 12: With alternation

    // Vertical tab \v (ASCII 11)
    '/\v/',                 // 13: Single vertical tab
    '/test\v/',             // 14: At end of pattern
    '/\vtest/',             // 15: At start of pattern
    '/\v+/',                // 16: With quantifier
    '/\v*/',                // 17: With star quantifier
    '/\v?/',                // 18: With optional quantifier
    '/\v{2}/',              // 19: With bounded quantifier
    '/(\v)/',               // 20: In capturing group
    '/(?:\v)/',             // 21: In non-capturing group
    '/^\v/',                // 22: With start anchor
    '/\v$/',                // 23: With end anchor
    '/\v|\r/',              // 24: With alternation

    // Bell \a (ASCII 7)
    '/\a/',                 // 25: Single bell
    '/test\a/',             // 26: At end of pattern
    '/\atest/',             // 27: At start of pattern
    '/\a+/',                // 28: With quantifier
    '/\a*/',                // 29: With star quantifier
    '/\a?/',                // 30: With optional quantifier
    '/\a{2}/',              // 31: With bounded quantifier
    '/(\a)/',               // 32: In capturing group
    '/(?:\a)/',             // 33: In non-capturing group
    '/^\a/',                // 34: With start anchor
    '/\a$/',                // 35: With end anchor
    '/\a|\t/',              // 36: With alternation

    // Escape \e (ASCII 27)
    '/\e/',                 // 37: Single escape
    '/test\e/',             // 38: At end of pattern
    '/\etest/',             // 39: At start of pattern
    '/\e+/',                // 40: With quantifier
    '/\e*/',                // 41: With star quantifier
    '/\e?/',                // 42: With optional quantifier
    '/\e{2}/',              // 43: With bounded quantifier
    '/(\e)/',               // 44: In capturing group
    '/(?:\e)/',             // 45: In non-capturing group
    '/^\e/',                // 46: With start anchor
    '/\e$/',                // 47: With end anchor
    '/\e|\f/',              // 48: With alternation

    // Mixed escape sequences
    '/\f\v\a\e/',           // 49: All four together
    '/\n\r\t\f/',           // 50: Mix with existing escapes
    '/\f\n\v\r/',           // 51: Alternating new and old
    '/\a+\e*/',             // 52: Multiple with quantifiers
    '/(\f\v)(\a\e)/',       // 53: In groups
    '/\f\f\f/',             // 54: Repeated same escape
    '/\f\v\a\e\n\r\t/',     // 55: All escape sequences
    '/[\f]/',               // 56: Form feed in character class
    '/[\v]/',               // 57: Vertical tab in character class
    '/[\a]/',               // 58: Bell in character class
    '/[\e]/',               // 59: Escape in character class
    '/[\f\v\a\e]/',         // 60: All four in character class
    '/[\n\r\t\f]/',         // 61: Mix with existing in character class
    '/[\v-\f]/',            // 62: As range in character class (\v=11 to \f=12)
    '/[a\f]/',              // 63: With literal in character class
    '/[\f\d]/',             // 64: With shorthand in character class
    '/[^\f]/',              // 65: Negated character class with \f
    '/[^\v\a]/',            // 66: Negated with multiple
    '/[\x0C]/',             // 67: Hex equivalent of \f
    '/[\x0B]/',             // 68: Hex equivalent of \v
    '/[\x07]/',             // 69: Hex equivalent of \a
    '/[\x1B]/'              // 70: Hex equivalent of \e
}

constant integer REGEX_LEXER_ESCAPE_SEQUENCES_EXPECTED_TOKENS[][] = {
    // Form feed tests
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_NEWLINE,
        REGEX_TOKEN_EOF
    },
    // Vertical tab tests
    {
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_RETURN,
        REGEX_TOKEN_EOF
    },
    // Bell tests
    {
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_TAB,
        REGEX_TOKEN_EOF
    },
    // Escape tests
    {
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_EOF
    },
    // Mixed escape sequences
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NEWLINE,
        REGEX_TOKEN_RETURN,
        REGEX_TOKEN_TAB,
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_NEWLINE,
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_RETURN,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_FORMFEED,
        REGEX_TOKEN_VTAB,
        REGEX_TOKEN_BELL,
        REGEX_TOKEN_ESC,
        REGEX_TOKEN_NEWLINE,
        REGEX_TOKEN_RETURN,
        REGEX_TOKEN_TAB,
        REGEX_TOKEN_EOF
    },
    // Character class tests
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    }
}

constant integer REGEX_LEXER_ESCAPE_SEQUENCES_EXPECTED_VALUES[] = {
    12,     // 1: \f = ASCII 12
    12,     // 2: \f at end
    12,     // 3: \f at start
    12,     // 4: \f with +
    12,     // 5: \f with *
    12,     // 6: \f with ?
    12,     // 7: \f with {2}
    12,     // 8: \f in ()
    12,     // 9: \f in (?:)
    12,     // 10: \f with ^
    12,     // 11: \f with $
    12,     // 12: \f with |
    11,     // 13: \v = ASCII 11
    11,     // 14: \v at end
    11,     // 15: \v at start
    11,     // 16: \v with +
    11,     // 17: \v with *
    11,     // 18: \v with ?
    11,     // 19: \v with {2}
    11,     // 20: \v in ()
    11,     // 21: \v in (?:)
    11,     // 22: \v with ^
    11,     // 23: \v with $
    11,     // 24: \v with |
    7,      // 25: \a = ASCII 7
    7,      // 26: \a at end
    7,      // 27: \a at start
    7,      // 28: \a with +
    7,      // 29: \a with *
    7,      // 30: \a with ?
    7,      // 31: \a with {2}
    7,      // 32: \a in ()
    7,      // 33: \a in (?:)
    7,      // 34: \a with ^
    7,      // 35: \a with $
    7,      // 36: \a with |
    27,     // 37: \e = ASCII 27
    27,     // 38: \e at end
    27,     // 39: \e at start
    27,     // 40: \e with +
    27,     // 41: \e with *
    27,     // 42: \e with ?
    27,     // 43: \e with {2}
    27,     // 44: \e in ()
    27,     // 45: \e in (?:)
    27,     // 46: \e with ^
    27,     // 47: \e with $
    27      // 48: \e with |
}


define_function TestNAVRegexLexerEscapeSequences() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Escape Sequences *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_ESCAPE_SEQUENCES_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_ESCAPE_SEQUENCES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_ESCAPE_SEQUENCES_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_ESCAPE_SEQUENCES_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_ESCAPE_SEQUENCES_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
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


define_function TestNAVRegexLexerEscapeSequencesValues() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Escape Sequences Values *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_ESCAPE_SEQUENCES_EXPECTED_VALUES); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer tokenType
        stack_var integer tokenIndex
        stack_var integer y

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_ESCAPE_SEQUENCES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Determine which token type we're expecting based on pattern
        select {
            active (x <= 12):  tokenType = REGEX_TOKEN_FORMFEED
            active (x <= 24):  tokenType = REGEX_TOKEN_VTAB
            active (x <= 36):  tokenType = REGEX_TOKEN_BELL
            active (x <= 48):  tokenType = REGEX_TOKEN_ESC
        }

        // Find the escape token (may not be first token in pattern)
        tokenIndex = 0
        for (y = 1; y <= lexer.tokenCount; y++) {
            if (lexer.tokens[y].type == tokenType) {
                tokenIndex = y
                break
            }
        }

        // Should have found the expected escape token
        if (!NAVAssertTrue('Should contain escape token', tokenIndex > 0)) {
            NAVLogTestFailed(x, "'Found escape token'", "'Not found'")
            continue
        }

        // Verify the value was correctly parsed
        if (!NAVAssertIntegerEqual('Escape value should match expected', REGEX_LEXER_ESCAPE_SEQUENCES_EXPECTED_VALUES[x], lexer.tokens[tokenIndex].value)) {
            NAVLogTestFailed(x, itoa(REGEX_LEXER_ESCAPE_SEQUENCES_EXPECTED_VALUES[x]), itoa(lexer.tokens[tokenIndex].value))
            continue
        }

        NAVLogTestPassed(x)
    }
}


define_function TestNAVRegexLexerEscapeSequencesCharClasses() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Escape Sequences in Character Classes *****************'")

    // Test patterns 56-70 (character class tests)
    for (x = 56; x <= 70; x++) {
        stack_var _NAVRegexLexer lexer

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_ESCAPE_SEQUENCES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Should produce CHAR_CLASS or INV_CHAR_CLASS token
        if (x == 65 || x == 66) {
            // Negated character classes
            if (!NAVAssertIntegerEqual('Should produce INV_CHAR_CLASS token', REGEX_TOKEN_INV_CHAR_CLASS, lexer.tokens[1].type)) {
                NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_TOKEN_INV_CHAR_CLASS), NAVRegexLexerGetTokenType(lexer.tokens[1].type))
                continue
            }
        }
        else {
            // Regular character classes
            if (!NAVAssertIntegerEqual('Should produce CHAR_CLASS token', REGEX_TOKEN_CHAR_CLASS, lexer.tokens[1].type)) {
                NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_TOKEN_CHAR_CLASS), NAVRegexLexerGetTokenType(lexer.tokens[1].type))
                continue
            }
        }

        // Verify character class contains the escape sequence as a range
        select {
            active (x == 56 || x == 61 || x == 63 || x == 64 || x == 67):  {
                stack_var char found
                stack_var integer y

                // Contains \f (ASCII 12)
                if (lexer.tokens[1].charclass.rangeCount < 1) {
                    NAVLogTestFailed(x, 'rangeCount >= 1', "itoa(lexer.tokens[1].charclass.rangeCount)")
                    continue
                }
                // Check if any range contains ASCII 12
                found = false
                for (y = 1; y <= lexer.tokens[1].charclass.rangeCount; y++) {
                    if (lexer.tokens[1].charclass.ranges[y].start == 12 &&
                        lexer.tokens[1].charclass.ranges[y].end == 12) {
                        found = true
                        break
                    }
                }
                if (!found) {
                    NAVLogTestFailed(x, 'Contains \\f (12)', 'Not found in ranges')
                    continue
                }
            }
            active (x == 57 || x == 68):  {
                stack_var char found
                stack_var integer y
                // Contains \v (ASCII 11)
                if (lexer.tokens[1].charclass.rangeCount < 1) {
                    NAVLogTestFailed(x, 'rangeCount >= 1', "itoa(lexer.tokens[1].charclass.rangeCount)")
                    continue
                }
                found = false
                for (y = 1; y <= lexer.tokens[1].charclass.rangeCount; y++) {
                    if (lexer.tokens[1].charclass.ranges[y].start == 11 &&
                        lexer.tokens[1].charclass.ranges[y].end == 11) {
                        found = true
                        break
                    }
                }
                if (!found) {
                    NAVLogTestFailed(x, 'Contains \\v (11)', 'Not found in ranges')
                    continue
                }
            }
            active (x == 58 || x == 66 || x == 69):  {
                stack_var char found
                stack_var integer y
                // Contains \a (ASCII 7)
                if (lexer.tokens[1].charclass.rangeCount < 1) {
                    NAVLogTestFailed(x, 'rangeCount >= 1', "itoa(lexer.tokens[1].charclass.rangeCount)")
                    continue
                }
                found = false
                for (y = 1; y <= lexer.tokens[1].charclass.rangeCount; y++) {
                    if (lexer.tokens[1].charclass.ranges[y].start == 7 &&
                        lexer.tokens[1].charclass.ranges[y].end == 7) {
                        found = true
                        break
                    }
                }
                if (!found) {
                    NAVLogTestFailed(x, 'Contains \\a (7)', 'Not found in ranges')
                    continue
                }
            }
            active (x == 59 || x == 70):  {
                stack_var char found
                stack_var integer y
                // Contains \e (ASCII 27)
                if (lexer.tokens[1].charclass.rangeCount < 1) {
                    NAVLogTestFailed(x, 'rangeCount >= 1', "itoa(lexer.tokens[1].charclass.rangeCount)")
                    continue
                }
                found = false
                for (y = 1; y <= lexer.tokens[1].charclass.rangeCount; y++) {
                    if (lexer.tokens[1].charclass.ranges[y].start == 27 &&
                        lexer.tokens[1].charclass.ranges[y].end == 27) {
                        found = true
                        break
                    }
                }
                if (!found) {
                    NAVLogTestFailed(x, 'Contains \\e (27)', 'Not found in ranges')
                    continue
                }
            }
            active (x == 60):  {
                // Contains all four: \f, \v, \a, \e
                if (lexer.tokens[1].charclass.rangeCount < 4) {
                    NAVLogTestFailed(x, 'rangeCount >= 4', "itoa(lexer.tokens[1].charclass.rangeCount)")
                    continue
                }
            }
            active (x == 62):  {
                stack_var char found
                stack_var integer y
                // Range [\v-\f] = ASCII 11-12
                if (lexer.tokens[1].charclass.rangeCount < 1) {
                    NAVLogTestFailed(x, 'rangeCount >= 1', "itoa(lexer.tokens[1].charclass.rangeCount)")
                    continue
                }
                // Should have a range from 11 to 12
                found = false
                for (y = 1; y <= lexer.tokens[1].charclass.rangeCount; y++) {
                    if (lexer.tokens[1].charclass.ranges[y].start == 11 &&
                        lexer.tokens[1].charclass.ranges[y].end == 12) {
                        found = true
                        break
                    }
                }
                if (!found) {
                    NAVLogTestFailed(x, 'Contains range \\v-\\f (11-12)', 'Not found')
                    continue
                }
            }
            active (x == 65):  {
                // Negated [^\f]
                if (lexer.tokens[1].charclass.rangeCount < 1) {
                    NAVLogTestFailed(x, 'rangeCount >= 1', "itoa(lexer.tokens[1].charclass.rangeCount)")
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}


