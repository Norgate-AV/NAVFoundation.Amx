PROGRAM_NAME='NAVRegexLexerCharClasses'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexLexerTestHelpers.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_CHARCLASSES_PATTERN_TEST[][255] = {
    '/^...$/',              // 1: Multiple dots with anchors
    '/\d\w\s/',             // 2: Mixed metacharacters
    '/a?b*c+/',             // 3: All quantifiers together
    '/\.\*\+\?/',           // 4: Escaped special characters
    '/[a-zA-Z]/',           // 5: Character class with multiple ranges
    '/[^0-9]/',             // 6: Inverted character class
    '/[abc123]/',           // 7: Character class with literals
    '/^\d+$/',              // 8: Mixed anchors and metacharacters
    '/\bword\b/',           // 9: Word boundaries
    '/\w+@\w+\.\w+/',       // 10: Complex email-like pattern
    '/\d*\w+\s*/',          // 11: Multiple consecutive quantifiers
    '/\D\W\S/',             // 12: Negated metacharacters
    '/[a-z-]/',             // 13: Character class with dash
    '/.*\..*/',             // 14: Dot with quantifiers
    '/[abc][def][ghi]/',    // 15: Multiple character classes
    '/\d\d?\d?/',           // 16: Mixed optional and required
    '/^test/',              // 17: Start anchor only
    '/test$/',              // 18: End anchor only
    '/[\d\w\s]/',           // 19: Character class with backslash escapes
    '/[]/',                 // 20: Empty character class edge case
    '/x/',                  // 21: Single character
    '/hello/',              // 22: Multiple literal characters
    '/[a-z]+[0-9]*/',       // 23: Quantifiers on character classes
    '/\Btest\B/',           // 24: NOT word boundary
    '/\t/',                 // 25: Tab character
    '/\n/',                 // 26: Newline character
    '/\r/',                 // 27: Return character
    '/\t\n\r/'              // 28: Mixed special characters
}

constant integer REGEX_LEXER_CHARCLASSES_EXPECTED_TOKENS[][] = {
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
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
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_DIGIT,
        REGEX_TOKEN_NOT_ALPHA,
        REGEX_TOKEN_NOT_WHITESPACE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_END,
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
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NOT_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_NOT_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_TAB,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_NEWLINE,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_RETURN,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_TAB,
        REGEX_TOKEN_NEWLINE,
        REGEX_TOKEN_RETURN,
        REGEX_TOKEN_EOF
    }
}


define_function TestNAVRegexLexerCharClasses() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Character Classes *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_CHARCLASSES_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_CHARCLASSES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_CHARCLASSES_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_CHARCLASSES_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_CHARCLASSES_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        // Additional validation for specific test patterns
        select {
            // Test 5: /[a-zA-Z]/ - Should have 2 ranges: a-z and A-Z
            active (x == 5): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 2)) {
                    NAVLogTestFailed(x, '2 ranges', "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, 'a', 'z')) {
                    NAVLogTestFailed(x, 'Range 1: a-z', 'incorrect range')
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 2, 'A', 'Z')) {
                    NAVLogTestFailed(x, 'Range 2: A-Z', 'incorrect range')
                    continue
                }
            }

            // Test 6: /[^0-9]/ - Should be negated with 1 range: 0-9
            active (x == 6): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertTokenIsNegated(lexer.tokens[tokenIdx], true)) {
                    NAVLogTestFailed(x, 'negated', 'not negated')
                    continue
                }

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, '1 range', "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, '0', '9')) {
                    NAVLogTestFailed(x, 'Range 1: 0-9', 'incorrect range')
                    continue
                }
            }

            // Test 7: /[abc123]/ - Should have 6 single-character ranges
            active (x == 7): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 6)) {
                    NAVLogTestFailed(x, '6 ranges', "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, 'a', 'a')) {
                    NAVLogTestFailed(x, 'Range 1: a', 'incorrect')
                    continue
                }
                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 2, 'b', 'b')) {
                    NAVLogTestFailed(x, 'Range 2: b', 'incorrect')
                    continue
                }
                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 3, 'c', 'c')) {
                    NAVLogTestFailed(x, 'Range 3: c', 'incorrect')
                    continue
                }
                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 4, '1', '1')) {
                    NAVLogTestFailed(x, 'Range 4: 1', 'incorrect')
                    continue
                }
                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 5, '2', '2')) {
                    NAVLogTestFailed(x, 'Range 5: 2', 'incorrect')
                    continue
                }
                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 6, '3', '3')) {
                    NAVLogTestFailed(x, 'Range 6: 3', 'incorrect')
                    continue
                }
            }

            // Test 13: /[a-z-]/ - Should have 2 ranges: a-z and literal dash
            active (x == 13): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 2)) {
                    NAVLogTestFailed(x, '2 ranges', "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, 'a', 'z')) {
                    NAVLogTestFailed(x, 'Range 1: a-z', 'incorrect range')
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 2, '-', '-')) {
                    NAVLogTestFailed(x, 'Range 2: -', 'incorrect range')
                    continue
                }
            }

            // Test 15: /[abc][def][ghi]/ - Should have 3 character classes with correct ranges
            active (x == 15): {
                stack_var integer tokenIdx

                // First character class [abc]
                tokenIdx = NAVGetCharClassTokenIndexByPosition(lexer, 1)
                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 3)) {
                    NAVLogTestFailed(x, 'Class 1: 3 ranges', "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }
                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, 'a', 'a')) {
                    NAVLogTestFailed(x, 'Class 1 Range 1: a', 'incorrect')
                    continue
                }

                // Second character class [def]
                tokenIdx = NAVGetCharClassTokenIndexByPosition(lexer, 2)
                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 3)) {
                    NAVLogTestFailed(x, 'Class 2: 3 ranges', "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }
                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, 'd', 'd')) {
                    NAVLogTestFailed(x, 'Class 2 Range 1: d', 'incorrect')
                    continue
                }

                // Third character class [ghi]
                tokenIdx = NAVGetCharClassTokenIndexByPosition(lexer, 3)
                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 3)) {
                    NAVLogTestFailed(x, 'Class 3: 3 ranges', "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }
                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, 'g', 'g')) {
                    NAVLogTestFailed(x, 'Class 3 Range 1: g', 'incorrect')
                    continue
                }
            }

            // Test 19: /[\d\w\s]/ - Should have predefined class flags set
            active (x == 19): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassHasDigits(lexer.tokens[tokenIdx].charclass, true)) {
                    NAVLogTestFailed(x, 'hasDigits = true', 'false')
                    continue
                }

                if (!NAVAssertCharClassHasWordChars(lexer.tokens[tokenIdx].charclass, true)) {
                    NAVLogTestFailed(x, 'hasWordChars = true', 'false')
                    continue
                }

                if (!NAVAssertCharClassHasWhitespace(lexer.tokens[tokenIdx].charclass, true)) {
                    NAVLogTestFailed(x, 'hasWhitespace = true', 'false')
                    continue
                }

                // Should have 0 explicit ranges (all predefined)
                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 0)) {
                    NAVLogTestFailed(x, '0 explicit ranges', "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }
            }

            // Test 23: /[a-z]+[0-9]*/ - Should have correct ranges in both classes
            active (x == 23): {
                stack_var integer tokenIdx

                // First character class [a-z]
                tokenIdx = NAVGetCharClassTokenIndexByPosition(lexer, 1)
                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, 'Class 1: 1 range', "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }
                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, 'a', 'z')) {
                    NAVLogTestFailed(x, 'Class 1: a-z', 'incorrect range')
                    continue
                }

                // Second character class [0-9]
                tokenIdx = NAVGetCharClassTokenIndexByPosition(lexer, 2)
                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, 'Class 2: 1 range', "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }
                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, '0', '9')) {
                    NAVLogTestFailed(x, 'Class 2: 0-9', 'incorrect range')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}



