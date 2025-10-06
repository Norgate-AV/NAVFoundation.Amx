PROGRAM_NAME='NAVRegexCompileBasic'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_COMPILE_BASIC_PATTERN_TEST[][255] = {
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
    '/\d?\d?\d/'        // 22: Three optional digits
}

constant integer REGEX_COMPILE_BASIC_EXPECTED_TOKENS[][] = {
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_WHITESPACE
    },
    {
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_WHITESPACE
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_WHITESPACE
    },
    {
        REGEX_TYPE_NOT_ALPHA,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_NOT_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_END
    },
    {
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_END
    },
    {
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_STAR,
        REGEX_TYPE_CHAR
    },
    {
        REGEX_TYPE_DOT,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT
    }
}


define_function TestNAVRegexCompileBasic() {
    stack_var integer x

    NAVLog("'***************** NAVRegexCompile - Basic *****************'")

    for (x = 1; x <= length_array(REGEX_COMPILE_BASIC_PATTERN_TEST); x++) {
        stack_var _NAVRegexParser parser
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should compile successfully', NAVRegexCompile(REGEX_COMPILE_BASIC_PATTERN_TEST[x], parser))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_COMPILE_BASIC_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should compile to correct amount of tokens', expectedTokenCount, parser.count)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(parser.count))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= parser.count; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_COMPILE_BASIC_EXPECTED_TOKENS[x][y], parser.state[y].type)) {
                    NAVLogTestFailed(x, NAVRegexGetTokenType(REGEX_COMPILE_BASIC_EXPECTED_TOKENS[x][y]), NAVRegexGetTokenType(parser.state[y].type))
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
