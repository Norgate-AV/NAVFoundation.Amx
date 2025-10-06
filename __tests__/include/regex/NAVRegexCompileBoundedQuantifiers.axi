PROGRAM_NAME='NAVRegexCompileBoundedQuantifiers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_COMPILE_BOUNDED_QUANTIFIERS_PATTERN_TEST[][255] = {
    '/a{3}/',           // 1: Bounded quantifier - exact count
    '/\d{5}/',          // 2: Bounded quantifier - exact count with metacharacter
    '/b{2,4}/',         // 3: Bounded quantifier - range
    '/\w{1,10}/',       // 4: Bounded quantifier - range with metacharacter
    '/c{1,}/',          // 5: Bounded quantifier - unlimited (one or more)
    '/\s{0,}/',         // 6: Bounded quantifier - unlimited (zero or more)
    '/d{0}/',           // 7: Bounded quantifier - zero occurrences
    '/e{100}/',         // 8: Bounded quantifier - large count
    '/\d{3}\.\d{3}/',   // 9: Bounded quantifier with literal character
    '/[a-z]{2,5}/',     // 10: Bounded quantifier with character class
    '/^\w{3,}$/'        // 11: Bounded quantifier with anchors
}

constant integer REGEX_COMPILE_BOUNDED_QUANTIFIERS_EXPECTED_TOKENS[][] = {
    {
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUANTIFIER
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER
    },
    {
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUANTIFIER
    },
    {
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_QUANTIFIER
    },
    {
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUANTIFIER
    },
    {
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_QUANTIFIER
    },
    {
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUANTIFIER
    },
    {
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUANTIFIER
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER
    },
    {
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_QUANTIFIER
    },
    {
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_END
    }
}


define_function TestNAVRegexCompileBoundedQuantifiers() {
    stack_var integer x

    NAVLog("'***************** NAVRegexCompile - Bounded Quantifiers *****************'")

    for (x = 1; x <= length_array(REGEX_COMPILE_BOUNDED_QUANTIFIERS_PATTERN_TEST); x++) {
        stack_var _NAVRegexParser parser
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should compile successfully', NAVRegexCompile(REGEX_COMPILE_BOUNDED_QUANTIFIERS_PATTERN_TEST[x], parser))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_COMPILE_BOUNDED_QUANTIFIERS_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should compile to correct amount of tokens', expectedTokenCount, parser.count)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(parser.count))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= parser.count; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_COMPILE_BOUNDED_QUANTIFIERS_EXPECTED_TOKENS[x][y], parser.state[y].type)) {
                    NAVLogTestFailed(x, NAVRegexGetTokenType(REGEX_COMPILE_BOUNDED_QUANTIFIERS_EXPECTED_TOKENS[x][y]), NAVRegexGetTokenType(parser.state[y].type))
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
