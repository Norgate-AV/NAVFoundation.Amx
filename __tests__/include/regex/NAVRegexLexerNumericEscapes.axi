PROGRAM_NAME='NAVRegexLexerNumericEscapes'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Numeric escapes (\0-\9, \10-\377) are ambiguous at the lexer level
// They could be:
// - Octal escape sequences (e.g., \101 = 'A', \012 = newline)
// - Backreferences to capturing groups (e.g., \1 = group 1)
// The lexer creates NUMERIC_ESCAPE tokens with metadata
// The parser will disambiguate based on:
// - Leading zero (\0xxx always octal)
// - Number of capturing groups (if value <= group count, it's a backref)
// - Otherwise, treat as octal if valid

constant char REGEX_LEXER_NUMERIC_ESCAPES_PATTERN_TEST[][255] = {
    // === Basic numeric escapes ===
    '/\0/',             // 1: Null character (leading zero)
    '/\1/',             // 2: Could be backref 1 or octal 1
    '/\2/',             // 3: Could be backref 2 or octal 2
    '/\9/',             // 4: Could be backref 9 or octal 9

    // === Two-digit numeric escapes ===
    '/\00/',            // 5: Octal 00 (leading zero)
    '/\01/',            // 6: Octal 01 (leading zero)
    '/\07/',            // 7: Octal 07 (leading zero)
    '/\10/',            // 8: Could be backref 10 or octal 10 (decimal 8)
    '/\77/',            // 9: Could be backref 77 or octal 77 (decimal 63)
    '/\99/',            // 10: Could be backref 99 (not valid octal)

    // === Three-digit numeric escapes ===
    '/\000/',           // 11: Octal 000 (leading zero)
    '/\011/',           // 12: Octal 011 = tab (leading zero)
    '/\012/',           // 13: Octal 012 = newline (leading zero)
    '/\015/',           // 14: Octal 015 = CR (leading zero)
    '/\040/',           // 15: Octal 040 = space (leading zero)
    '/\101/',           // 16: Could be backref 101 or octal 101 = 'A' (decimal 65)
    '/\141/',           // 17: Could be backref 141 or octal 141 = 'a' (decimal 97)
    '/\255/',           // 18: Could be backref 255 or octal 255 (decimal 173)
    '/\377/',           // 19: Could be backref 377 or octal 377 (max = decimal 255)
    '/\400/',           // 20: Would be backref 400 (exceeds octal max 377)

    // === Numeric escapes followed by other digits ===
    '/\08/',            // 21: \0 followed by '8' (8 is not octal digit)
    '/\09/',            // 22: \0 followed by '9' (9 is not octal digit)
    '/\108/',           // 23: \10 followed by '8' (stops at valid value)
    '/\109/',           // 24: \10 followed by '9' (stops at valid value)
    '/\258/',           // 25: \25 followed by '8' (stops at valid value)

    // === Multiple numeric escapes ===
    '/\1\2/',           // 26: Two single-digit escapes
    '/\01\02/',         // 27: Two double-digit octals (leading zeros)
    '/\101\102/',       // 28: Two three-digit escapes (AB in octal)
    '/\1\2\3/',         // 29: Three single-digit escapes

    // === Numeric escapes with quantifiers ===
    '/\1+/',            // 30: With plus
    '/\1*/',            // 31: With star
    '/\1?/',            // 32: With question mark
    '/\1{2}/',          // 33: With bounded quantifier
    '/\101+/',          // 34: Three-digit with plus

    // === Numeric escapes with other tokens ===
    '/test\377/',       // 35: At end of pattern
    '/\377test/',       // 36: At start of pattern
    '/\1\d+/',          // 37: With digit class
    '/\w+\040\w+/',     // 38: Space between words (octal)

    // === Numeric escapes in groups ===
    '/(\1)/',           // 39: In capturing group
    '/(?:\1)/',         // 40: In non-capturing group
    '/(test)\1/',       // 41: Group with potential backreference
    '/(a)(b)\1\2/',     // 42: Two groups with potential backrefs

    // === Numeric escapes with anchors ===
    '/^\1/',            // 43: With start anchor
    '/\1$/',            // 44: With end anchor
    '/^\101$/',         // 45: Three-digit with both anchors

    // === Edge cases ===
    '/\256/',           // 46: Exceeds 255, stops at \25
    '/\999/',           // 47: Very high number
    '/\0\0\0/'          // 48: Multiple nulls
}

constant integer REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_TOKENS[][] = {
    // 1: \0
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 2: \1
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 3: \2
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 4: \9
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 5: \00
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 6: \01
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 7: \07
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 8: \10
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 9: \77
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 10: \99
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 11: \000
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 12: \011
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 13: \012
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 14: \015
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 15: \040
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 16: \101
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 17: \141
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 18: \255
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 19: \377
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 20: \400 (lexer consumes all digits, parser validates later)
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 21: \08 (lexer consumes all digits, parser validates later)
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 22: \09 (lexer consumes all digits, parser validates later)
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 23: \108 (lexer consumes all digits, parser validates later)
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 24: \109 (lexer consumes all digits, parser validates later)
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 25: \258 (lexer consumes all digits, parser validates later)
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 26: \1\2
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 27: \01\02
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 28: \101\102
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 29: \1\2\3
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 30: \1+
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    // 31: \1*
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    // 32: \1?
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    // 33: \1{2}
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    // 34: \101+
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    // 35: test\377
    {
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 36: \377test
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    // 37: \1\d+
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    // 38: \w+\040\w+
    {
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    // 39: (\1)
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // 40: (?:\1)
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // 41: (test)\1
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 42: (a)(b)\1\2
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 43: ^\1
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 44: \1$
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    // 45: ^\101$
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    // 46: \256 (lexer consumes all digits, parser validates later)
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 47: \999 (lexer consumes all digits, parser validates later)
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    },
    // 48: \0\0\0
    {
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_NUMERIC_ESCAPE,
        REGEX_TOKEN_EOF
    }
}

// Expected digit strings for numeric escapes
// These are the raw digit strings stored without interpretation
constant char REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_DIGITS[][4] = {
    '0',      // 1: \0
    '1',      // 2: \1
    '2',      // 3: \2
    '9',      // 4: \9
    '00',     // 5: \00
    '01',     // 6: \01
    '07',     // 7: \07
    '10',     // 8: \10
    '77',     // 9: \77
    '99',     // 10: \99
    '000',    // 11: \000
    '011',    // 12: \011
    '012',    // 13: \012
    '015',    // 14: \015
    '040',    // 15: \040
    '101',    // 16: \101
    '141',    // 17: \141
    '255',    // 18: \255
    '377'     // 19: \377
}

// Expected leadingZero flags
constant char REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_LEADING_ZERO[] = {
    true,   // 1: \0
    false,  // 2: \1
    false,  // 3: \2
    false,  // 4: \9
    true,   // 5: \00
    true,   // 6: \01
    true,   // 7: \07
    false,  // 8: \10
    false,  // 9: \77
    false,  // 10: \99
    true,   // 11: \000
    true,   // 12: \011
    true,   // 13: \012
    true,   // 14: \015
    true,   // 15: \040
    false,  // 16: \101
    false,  // 17: \141
    false,  // 18: \255
    false   // 19: \377
}


define_function TestNAVRegexLexerNumericEscapes() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Numeric Escapes *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_NUMERIC_ESCAPES_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_NUMERIC_ESCAPES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        // Verify each token type matches
        {
            stack_var integer y
            stack_var char failed

            failed = false
            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
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


define_function TestNAVRegexLexerNumericEscapesDigits() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Numeric Escapes Digit Strings *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_DIGITS); x++) {
        stack_var _NAVRegexLexer lexer

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_NUMERIC_ESCAPES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // First token should be NUMERIC_ESCAPE type
        if (!NAVAssertIntegerEqual('First token should be NUMERIC_ESCAPE', REGEX_TOKEN_NUMERIC_ESCAPE, lexer.tokens[1].type)) {
            NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_TOKEN_NUMERIC_ESCAPE), NAVRegexLexerGetTokenType(lexer.tokens[1].type))
            continue
        }

        // Verify the digit string was stored correctly (no interpretation)
        if (!NAVAssertStringEqual('Digit string should match expected', REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_DIGITS[x], lexer.tokens[1].numericEscapeDigits)) {
            NAVLogTestFailed(x, REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_DIGITS[x], lexer.tokens[1].numericEscapeDigits)
            continue
        }

        NAVLogTestPassed(x)
    }
}


define_function TestNAVRegexLexerNumericEscapesLeadingZero() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Numeric Escapes Leading Zero *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_LEADING_ZERO); x++) {
        stack_var _NAVRegexLexer lexer

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_NUMERIC_ESCAPES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // First token should be NUMERIC_ESCAPE type
        if (!NAVAssertIntegerEqual('First token should be NUMERIC_ESCAPE', REGEX_TOKEN_NUMERIC_ESCAPE, lexer.tokens[1].type)) {
            NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_TOKEN_NUMERIC_ESCAPE), NAVRegexLexerGetTokenType(lexer.tokens[1].type))
            continue
        }

        // Verify the leading zero flag
        if (!NAVAssertIntegerEqual('Leading zero flag should match expected', REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_LEADING_ZERO[x], lexer.tokens[1].numericEscapeLeadingZero)) {
            NAVLogTestFailed(x, itoa(REGEX_LEXER_NUMERIC_ESCAPES_EXPECTED_LEADING_ZERO[x]), itoa(lexer.tokens[1].numericEscapeLeadingZero))
            continue
        }

        NAVLogTestPassed(x)
    }
}
