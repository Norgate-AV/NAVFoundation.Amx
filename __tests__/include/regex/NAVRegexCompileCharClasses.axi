PROGRAM_NAME='NAVRegexCompileCharClasses'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_COMPILE_CHARCLASSES_PATTERN_TEST[][255] = {
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

constant integer REGEX_COMPILE_CHARCLASSES_EXPECTED_TOKENS[][] = {
    {
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_DOT,
        REGEX_TYPE_DOT,
        REGEX_TYPE_DOT,
        REGEX_TYPE_END
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_WHITESPACE
    },
    {
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_STAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        REGEX_TYPE_CHAR_CLASS
    },
    {
        REGEX_TYPE_INV_CHAR_CLASS
    },
    {
        REGEX_TYPE_CHAR_CLASS
    },
    {
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_END
    },
    {
        REGEX_TYPE_WORD_BOUNDARY,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_WORD_BOUNDARY
    },
    {
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_STAR,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_NOT_ALPHA,
        REGEX_TYPE_NOT_WHITESPACE
    },
    {
        REGEX_TYPE_CHAR_CLASS
    },
    {
        REGEX_TYPE_DOT,
        REGEX_TYPE_STAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DOT,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_CHAR_CLASS
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK
    },
    {
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_END
    },
    {
        REGEX_TYPE_CHAR_CLASS
    },
    {
        REGEX_TYPE_CHAR_CLASS
    },
    {
        REGEX_TYPE_CHAR
    },
    {
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_NOT_WORD_BOUNDARY,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_NOT_WORD_BOUNDARY
    },
    {
        REGEX_TYPE_TAB
    },
    {
        REGEX_TYPE_NEWLINE
    },
    {
        REGEX_TYPE_RETURN
    },
    {
        REGEX_TYPE_TAB,
        REGEX_TYPE_NEWLINE,
        REGEX_TYPE_RETURN
    }
}


define_function TestNAVRegexCompileCharClasses() {
    stack_var integer x

    NAVLog("'***************** NAVRegexCompile - Character Classes *****************'")

    for (x = 1; x <= length_array(REGEX_COMPILE_CHARCLASSES_PATTERN_TEST); x++) {
        stack_var _NAVRegexParser parser
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should compile successfully', NAVRegexCompile(REGEX_COMPILE_CHARCLASSES_PATTERN_TEST[x], parser))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_COMPILE_CHARCLASSES_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should compile to correct amount of tokens', expectedTokenCount, parser.count)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(parser.count))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= parser.count; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_COMPILE_CHARCLASSES_EXPECTED_TOKENS[x][y], parser.state[y].type)) {
                    NAVLogTestFailed(x, NAVRegexGetTokenType(REGEX_COMPILE_CHARCLASSES_EXPECTED_TOKENS[x][y]), NAVRegexGetTokenType(parser.state[y].type))
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
