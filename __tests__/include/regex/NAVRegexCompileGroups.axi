PROGRAM_NAME='NAVRegexCompileGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_COMPILE_GROUPS_PATTERN_TEST[][255] = {
    '/(\d+)/',                                           // 1: Single capturing group
    '/(\d+)-(\w+)/',                                     // 2: Multiple capturing groups
    '/(\d{3})/',                                         // 3: Group with quantifier inside
    '/([a-z]+)/',                                        // 4: Group with character class
    '/(\w+)@(\w+)\.(\w+)/',                             // 5: Multiple groups with metacharacters
    '/(abc)def/',                                        // 6: Group at start
    '/abc(def)/',                                        // 7: Group at end
    '/abc(\d+)def/',                                     // 8: Group in middle
    '/()/',                                              // 9: Empty group
    '/^(\d+)$/',                                         // 10: Group with anchor
    '/(\d)(\w)(\s)/',                                    // 11: Multiple adjacent groups
    '/(.+)/',                                            // 12: Group with dot wildcard
    '/(a*)b/',                                           // 13: Group with star quantifier
    '/(hello)-(world)/',                                 // 14: Multiple groups with literals between
    '/\b(\w+)\b/',                                       // 15: Group with word boundary
    '/^(test)/',                                         // 16: Group at beginning with anchor
    '/(test)$/',                                         // 17: Group at end with anchor
    '/(\.)/',                                            // 18: Group with escaped dot
    '/([0-9]+)/',                                        // 19: Group with plus on character class
    '/(\d+)\.(\d*)/',                                    // 20: Multiple groups with different quantifiers
    '/(https?)/',                                        // 21: Group with question mark
    '/()abc/',                                           // 22: Empty group at start
    '/abc()/',                                           // 23: Empty group at end
    '/([^a-z]+)/',                                       // 24: Group with negated character class
    '/^(\w+):(\d+)$/',                                   // 25: Multiple groups with anchors
    '/(\d)?/',                                           // 26: Group with optional quantifier
    '/([a-zA-Z0-9]+)@([a-zA-Z0-9]+)\.([a-z]{2,})/',     // 27: Complex email-like pattern
    '/([\d\w]+)/',                                       // 28: Group with multiple character classes
    '/(\\\()/',                                          // 29: Group with escaped parenthesis inside
    '/(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/',     // 30: IPv4-like pattern with groups
    '/(https?):\/\/(\w+)/',                              // 31: URL-like pattern
    '/(\s+)/',                                           // 32: Group with whitespace
    '/()()()/',                                          // 33: Multiple empty groups
    '/\b(\d+)\b/',                                       // 34: Group with boundaries
    '/^(.*)$/'                                           // 35: Group with begin and end
}

constant integer REGEX_COMPILE_GROUPS_EXPECTED_TOKENS[][] = {
    {
        // Test 1: /(\d+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 2: /(\d+)-(\w+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(-), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 3: /(\d{3})/ -> GROUP_START, DIGIT, QUANTIFIER, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 4: /([a-z]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 5: /(\w+)@(\w+)\.(\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(@), GROUP_START, WORD, PLUS, GROUP_END, CHAR(.), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 6: /(abc)def/ -> GROUP_START, CHAR(a), CHAR(b), CHAR(c), GROUP_END, CHAR(d), CHAR(e), CHAR(f)
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 7: /abc(def)/ -> CHAR(a), CHAR(b), CHAR(c), GROUP_START, CHAR(d), CHAR(e), CHAR(f), GROUP_END
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 8: /abc(\d+)def/ -> CHAR(a), CHAR(b), CHAR(c), GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(d), CHAR(e), CHAR(f)
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 9: /()/ -> GROUP_START, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 10: /^(\d+)$/ -> BEGIN, GROUP_START, DIGIT, PLUS, GROUP_END, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_END
    },
    {
        // Test 11: /(\d)(\w)(\s)/ -> GROUP_START, DIGIT, GROUP_END, GROUP_START, WORD, GROUP_END, GROUP_START, WHITESPACE, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 12: /(.+)/ -> GROUP_START, DOT, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DOT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 13: /(a*)b/ -> GROUP_START, CHAR, STAR, GROUP_END, CHAR
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_STAR,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR
    },
    {
        // Test 14: /(hello)-(world)/ -> GROUP_START, 5xCHAR, GROUP_END, CHAR(-), GROUP_START, 5xCHAR, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 15: /\b(\w+)\b/ -> WORD_BOUNDARY, GROUP_START, WORD, PLUS, GROUP_END, WORD_BOUNDARY
        REGEX_TYPE_WORD_BOUNDARY,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_WORD_BOUNDARY
    },
    {
        // Test 16: /^(test)/ -> BEGIN, GROUP_START, 4xCHAR, GROUP_END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 17: /(test)$/ -> GROUP_START, 4xCHAR, GROUP_END, END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_END
    },
    {
        // Test 18: /(\.)/ -> GROUP_START, CHAR(.), GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 19: /([0-9]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 20: /(\d+)\.(\d*)/ -> GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(.), GROUP_START, DIGIT, STAR, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_STAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 21: /(https?)/ -> GROUP_START, 5xCHAR(https), QUESTIONMARK, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 22: /()abc/ -> GROUP_START, GROUP_END, 3xCHAR
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 23: /abc()/ -> 3xCHAR, GROUP_START, GROUP_END
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 24: /([^a-z]+)/ -> GROUP_START, INV_CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_INV_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 25: /^(\w+):(\d+)$/ -> BEGIN, GROUP_START, WORD, PLUS, GROUP_END, CHAR(:), GROUP_START, DIGIT, PLUS, GROUP_END, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_END
    },
    {
        // Test 26: /(\d)?/ -> GROUP_START, DIGIT, GROUP_END, QUESTIONMARK
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_QUESTIONMARK
    },
    {
        // Test 27: /([a-zA-Z0-9]+)@([a-zA-Z0-9]+)\.([a-z]{2,})/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END, CHAR(@), GROUP_START, CHAR_CLASS, PLUS, GROUP_END, CHAR(.), GROUP_START, CHAR_CLASS, QUANTIFIER, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 28: /([\d\w]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 29: /(\\\()/ -> GROUP_START, CHAR(\\), CHAR(\(), GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 30: /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/ -> 4x(GROUP_START, DIGIT, QUANTIFIER, GROUP_END) + 3xCHAR(.)
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 31: /(https?):\/\/(\w+)/ -> GROUP_START, 5xCHAR(https), QUESTIONMARK, GROUP_END, CHAR(:), 2xCHAR(/), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 32: /(\s+)/ -> GROUP_START, WHITESPACE, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 33: /()()()/ -> GROUP_START, GROUP_END, GROUP_START, GROUP_END, GROUP_START, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 34: /\b(\d+)\b/ -> WORD_BOUNDARY, GROUP_START, DIGIT, PLUS, GROUP_END, WORD_BOUNDARY
        REGEX_TYPE_WORD_BOUNDARY,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_WORD_BOUNDARY
    },
    {
        // Test 35: /^(.*)$/ -> BEGIN, GROUP_START, DOT, STAR, GROUP_END, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DOT,
        REGEX_TYPE_STAR,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_END
    }
}


define_function TestNAVRegexCompileGroups() {
    stack_var integer x

    NAVLog("'***************** NAVRegexCompile - Capturing Groups *****************'")

    for (x = 1; x <= length_array(REGEX_COMPILE_GROUPS_PATTERN_TEST); x++) {
        stack_var _NAVRegexParser parser
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should compile successfully', NAVRegexCompile(REGEX_COMPILE_GROUPS_PATTERN_TEST[x], parser))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_COMPILE_GROUPS_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should compile to correct amount of tokens', expectedTokenCount, parser.count)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(parser.count))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= parser.count; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_COMPILE_GROUPS_EXPECTED_TOKENS[x][y], parser.state[y].type)) {
                    NAVLogTestFailed(x, NAVRegexGetTokenType(REGEX_COMPILE_GROUPS_EXPECTED_TOKENS[x][y]), NAVRegexGetTokenType(parser.state[y].type))
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
