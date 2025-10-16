PROGRAM_NAME='NAVRegexCompileNamedGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_COMPILE_NAMED_GROUPS_PATTERN_TEST[][255] = {
    '/(?P<year>\d{4})/',                                 // 1: Python-style named group
    '/(?<month>\w+)/',                                   // 2: .NET-style named group
    '/(?P<name>\w+)@(?P<domain>\w+)/',                  // 3: Multiple Python-style named groups
    '/(?<protocol>https?)/',                             // 4: .NET-style named group with quantifier
    '/(?P<hour>\d{2}):(?P<minute>\d{2})/',              // 5: Time-like pattern with named groups
    '/(?P<first>[a-z]+)-(?P<second>[0-9]+)/',           // 6: Named groups with character classes
    '/(?<user>\w+)@(?<domain>\w+)\.(?<tld>\w+)/',       // 7: Email-like with .NET-style named groups
    '/(?P<a>\d)(?P<b>\d)(?P<c>\d)/',                    // 8: Multiple adjacent named groups
    '/^(?P<start>\w+)$/',                                // 9: Named group with anchors
    '/(?P<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/',     // 10: Complex pattern in named group
    '/(?P<word>\w+)/',                                   // 11: Simple word capture
    '/(?<digits>\d+)/',                                  // 12: .NET-style digit capture
    '/(?P<alpha>[a-zA-Z]+)/',                            // 13: Named group with letter class
    '/(?<num>[0-9]+)/',                                  // 14: .NET-style number range
    '/(?P<test>abc)/',                                   // 15: Named group with literal
    '/(?<empty>)/',                                      // 16: Empty named group
    '/(?P<value>.+)/',                                   // 17: Named group with wildcard
    '/(?<key>\w+):(?<val>\w+)/',                        // 18: Key-value with .NET-style
    '/(?P<phone>\d{3}-\d{4})/',                         // 19: Phone-like pattern
    '/(?<code>[A-Z]{3})/'                               // 20: Uppercase letters in named group
}

constant integer REGEX_COMPILE_NAMED_GROUPS_EXPECTED_TOKENS[][] = {
    {
        // Test 1: /(?P<year>\d{4})/ -> GROUP_START, DIGIT, QUANTIFIER, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 2: /(?<month>\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 3: /(?P<name>\w+)@(?P<domain>\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(@), GROUP_START, WORD, PLUS, GROUP_END
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
        // Test 4: /(?<protocol>https?)/ -> GROUP_START, CHAR(h), CHAR(t), CHAR(t), CHAR(p), CHAR(s), QUESTIONMARK, GROUP_END
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
        // Test 5: /(?P<hour>\d{2}):(?P<minute>\d{2})/ -> GROUP_START, DIGIT, QUANTIFIER, GROUP_END, CHAR(:), GROUP_START, DIGIT, QUANTIFIER, GROUP_END
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
        // Test 6: /(?P<first>[a-z]+)-(?P<second>[0-9]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END, CHAR(-), GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 7: /(?<user>\w+)@(?<domain>\w+)\.(?<tld>\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(@), GROUP_START, WORD, PLUS, GROUP_END, CHAR(.), GROUP_START, WORD, PLUS, GROUP_END
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
        // Test 8: /(?P<a>\d)(?P<b>\d)(?P<c>\d)/ -> GROUP_START, DIGIT, GROUP_END, GROUP_START, DIGIT, GROUP_END, GROUP_START, DIGIT, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 9: /^(?P<start>\w+)$/ -> BEGIN, GROUP_START, WORD, PLUS, GROUP_END, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_END
    },
    {
        // Test 10: /(?P<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/ -> GROUP_START, DIGIT, QUANTIFIER, CHAR(.), DIGIT, QUANTIFIER, CHAR(.), DIGIT, QUANTIFIER, CHAR(.), DIGIT, QUANTIFIER, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 11: /(?P<word>\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 12: /(?<digits>\d+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 13: /(?P<alpha>[a-zA-Z]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 14: /(?<num>[0-9]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 15: /(?P<test>abc)/ -> GROUP_START, CHAR(a), CHAR(b), CHAR(c), GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 16: /(?<empty>)/ -> GROUP_START, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 17: /(?P<value>.+)/ -> GROUP_START, DOT, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DOT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 18: /(?<key>\w+):(?<val>\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(:), GROUP_START, WORD, PLUS, GROUP_END
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
        // Test 19: /(?P<phone>\d{3}-\d{4})/ -> GROUP_START, DIGIT, QUANTIFIER, CHAR(-), DIGIT, QUANTIFIER, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 20: /(?<code>[A-Z]{3})/ -> GROUP_START, CHAR_CLASS, QUANTIFIER, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END
    }
}

DEFINE_FUNCTION TestNAVRegexCompileNamedGroups() {
    stack_var integer i

    NAVLog("'***************** NAVRegexCompile - Named Groups *****************'")

    for (i = 1; i <= length_array(REGEX_COMPILE_NAMED_GROUPS_PATTERN_TEST); i++) {
        stack_var _NAVRegexParser parser
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should compile successfully', NAVRegexCompile(REGEX_COMPILE_NAMED_GROUPS_PATTERN_TEST[i], parser))) {
            NAVLogTestFailed(i, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_COMPILE_NAMED_GROUPS_EXPECTED_TOKENS[i])
        if (!NAVAssertIntegerEqual('Should compile to correct amount of tokens', expectedTokenCount, parser.count)) {
            NAVLogTestFailed(i, itoa(expectedTokenCount), itoa(parser.count))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer j
            stack_var char failed

            for (j = 1; j <= parser.count; j++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(j), ' should be correct'", REGEX_COMPILE_NAMED_GROUPS_EXPECTED_TOKENS[i][j], parser.state[j].type)) {
                    NAVLogTestFailed(i, NAVRegexGetTokenType(REGEX_COMPILE_NAMED_GROUPS_EXPECTED_TOKENS[i][j]), NAVRegexGetTokenType(parser.state[j].type))
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
