PROGRAM_NAME='NAVRegexLexerNamedGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_NAMED_GROUPS_PATTERN_TEST[][255] = {
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
    '/(?<code>[A-Z]{3})/',                              // 20: Uppercase letters in named group
    '/(?''letter''a)/',                                   // 21: .NET single-quote style named group
    '/(?''user''\w+)@(?''domain''\w+)/',                  // 22: Multiple single-quote named groups
    '/(?''value''\d+)/'                                   // 23: Single-quote with digit pattern
}

constant integer REGEX_LEXER_NAMED_GROUPS_EXPECTED_TOKENS[][] = {
    {
        // Test 1: /(?P<year>\d{4})/ -> GROUP_START, DIGIT, QUANTIFIER, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 2: /(?<month>\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 3: /(?P<name>\w+)@(?P<domain>\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(@), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 4: /(?<protocol>https?)/ -> GROUP_START, CHAR(h), CHAR(t), CHAR(t), CHAR(p), CHAR(s), QUESTIONMARK, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 5: /(?P<hour>\d{2}):(?P<minute>\d{2})/ -> GROUP_START, DIGIT, QUANTIFIER, GROUP_END, CHAR(:), GROUP_START, DIGIT, QUANTIFIER, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 6: /(?P<first>[a-z]+)-(?P<second>[0-9]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END, CHAR(-), GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 7: /(?<user>\w+)@(?<domain>\w+)\.(?<tld>\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(@), GROUP_START, WORD, PLUS, GROUP_END, CHAR(.), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 8: /(?P<a>\d)(?P<b>\d)(?P<c>\d)/ -> GROUP_START, DIGIT, GROUP_END, GROUP_START, DIGIT, GROUP_END, GROUP_START, DIGIT, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 9: /^(?P<start>\w+)$/ -> BEGIN, GROUP_START, WORD, PLUS, GROUP_END, END
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 10: /(?P<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/ -> GROUP_START, DIGIT, QUANTIFIER, CHAR(.), DIGIT, QUANTIFIER, CHAR(.), DIGIT, QUANTIFIER, CHAR(.), DIGIT, QUANTIFIER, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 11: /(?P<word>\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 12: /(?<digits>\d+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 13: /(?P<alpha>[a-zA-Z]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 14: /(?<num>[0-9]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 15: /(?P<test>abc)/ -> GROUP_START, CHAR(a), CHAR(b), CHAR(c), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 16: /(?<empty>)/ -> GROUP_START, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 17: /(?P<value>.+)/ -> GROUP_START, DOT, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 18: /(?<key>\w+):(?<val>\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(:), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 19: /(?P<phone>\d{3}-\d{4})/ -> GROUP_START, DIGIT, QUANTIFIER, CHAR(-), DIGIT, QUANTIFIER, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 20: /(?<code>[A-Z]{3})/ -> GROUP_START, CHAR_CLASS, QUANTIFIER, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 21: /(?'letter'a)/ -> GROUP_START, CHAR, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 22: /(?'user'\w+)@(?'domain'\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(@), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 23: /(?'value'\d+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    }
}

constant integer REGEX_LEXER_NAMED_GROUPS_EXPECTED_GROUP_COUNT[] = {
    1,      // 1: /(?P<year>\d{4})/ - single named group
    1,      // 2: /(?<month>\w+)/ - single named group
    2,      // 3: /(?P<name>\w+)@(?P<domain>\w+)/ - two named groups
    1,      // 4: /(?<protocol>https?)/ - single named group
    2,      // 5: /(?P<hour>\d{2}):(?P<minute>\d{2})/ - two named groups
    2,      // 6: /(?P<first>[a-z]+)-(?P<second>[0-9]+)/ - two named groups
    3,      // 7: /(?<user>\w+)@(?<domain>\w+)\.(?<tld>\w+)/ - three named groups
    3,      // 8: /(?P<a>\d)(?P<b>\d)(?P<c>\d)/ - three named groups
    1,      // 9: /^(?P<start>\w+)$/ - single named group
    1,      // 10: /(?P<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/ - single complex named group
    1,      // 11: /(?P<word>\w+)/ - single named group
    1,      // 12: /(?<digits>\d+)/ - single named group
    1,      // 13: /(?P<alpha>[a-zA-Z]+)/ - single named group
    1,      // 14: /(?<num>[0-9]+)/ - single named group
    1,      // 15: /(?P<test>abc)/ - single named group
    1,      // 16: /(?<empty>)/ - single empty named group
    1,      // 17: /(?P<value>.+)/ - single named group
    2,      // 18: /(?<key>\w+):(?<val>\w+)/ - two named groups
    1,      // 19: /(?P<phone>\d{3}-\d{4})/ - single named group
    1,      // 20: /(?<code>[A-Z]{3})/ - single named group
    1,      // 21: /(?'letter'a)/ - single named group (single-quote style)
    2,      // 22: /(?'user'\w+)@(?'domain'\w+)/ - two named groups (single-quote style)
    1       // 23: /(?'value'\d+)/ - single named group (single-quote style)
}

constant char REGEX_LEXER_NAMED_GROUPS_EXPECTED_NAMES[23][3][MAX_REGEX_GROUP_NAME_LENGTH] = {
    { 'year' },                         // 1
    { 'month' },                        // 2
    { 'name', 'domain' },               // 3
    { 'protocol' },                     // 4
    { 'hour', 'minute' },               // 5
    { 'first', 'second' },              // 6
    { 'user', 'domain', 'tld' },        // 7
    { 'a', 'b', 'c' },                  // 8
    { 'start' },                        // 9
    { 'ip' },                           // 10
    { 'word' },                         // 11
    { 'digits' },                       // 12
    { 'alpha' },                        // 13
    { 'num' },                          // 14
    { 'test' },                         // 15
    { 'empty' },                        // 16
    { 'value' },                        // 17
    { 'key', 'val' },                   // 18
    { 'phone' },                        // 19
    { 'code' },                         // 20
    { 'letter' },                       // 21
    { 'user', 'domain' },               // 22
    { 'value' }                         // 23
}

DEFINE_FUNCTION TestNAVRegexLexerNamedGroups() {
    stack_var integer i

    NAVLog("'***************** NAVRegexLexer - Named Groups *****************'")

    for (i = 1; i <= length_array(REGEX_LEXER_NAMED_GROUPS_PATTERN_TEST); i++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_NAMED_GROUPS_PATTERN_TEST[i], lexer))) {
            NAVLogTestFailed(i, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_NAMED_GROUPS_EXPECTED_TOKENS[i])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(i, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer j
            stack_var char failed

            for (j = 1; j <= lexer.tokenCount; j++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(j), ' should be correct'", REGEX_LEXER_NAMED_GROUPS_EXPECTED_TOKENS[i][j], lexer.tokens[j].type)) {
                    NAVLogTestFailed(i, NAVRegexLexerGetTokenType(REGEX_LEXER_NAMED_GROUPS_EXPECTED_TOKENS[i][j]), NAVRegexLexerGetTokenType(lexer.tokens[j].type))
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

define_function TestNAVRegexLexerNamedGroupsMetadata() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Named Groups Metadata *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_NAMED_GROUPS_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer y
        stack_var integer groupCount
        stack_var integer groupIndex

        if (!NAVAssertTrue("'Test ', itoa(x), ': Should tokenize successfully'", NAVRegexLexerTokenize(REGEX_LEXER_NAMED_GROUPS_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        groupCount = 0
        groupIndex = 1

        // Count and validate groups
        {
            stack_var char testFailed
            testFailed = false

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (lexer.tokens[y].type == REGEX_TOKEN_GROUP_START) {
                    groupCount++

                    // Validate group number is sequential
                    if (!NAVAssertIntegerEqual("'Test ', itoa(x), ', Group ', itoa(groupIndex), ': number should be sequential'",
                        groupIndex, lexer.tokens[y].groupInfo.number)) {
                        NAVLogTestFailed(x, itoa(groupIndex), itoa(lexer.tokens[y].groupInfo.number))
                        testFailed = true
                        break
                    }

                    // Validate isCapturing flag (all named groups should be capturing)
                    if (!NAVAssertTrue("'Test ', itoa(x), ', Group ', itoa(groupIndex), ': should be capturing'",
                        lexer.tokens[y].groupInfo.isCapturing)) {
                        NAVLogTestFailed(x, 'true', 'false')
                        testFailed = true
                        break
                    }

                    // Validate isNamed flag (all groups in this test should be named)
                    if (!NAVAssertTrue("'Test ', itoa(x), ', Group ', itoa(groupIndex), ': should be named'",
                        lexer.tokens[y].groupInfo.isNamed)) {
                        NAVLogTestFailed(x, 'true', 'false')
                        testFailed = true
                        break
                    }

                    // Validate group name matches expected
                    if (!NAVAssertStringEqual("'Test ', itoa(x), ', Group ', itoa(groupIndex), ': name should match expected'",
                        REGEX_LEXER_NAMED_GROUPS_EXPECTED_NAMES[x][groupIndex], lexer.tokens[y].groupInfo.name)) {
                        NAVLogTestFailed(x, REGEX_LEXER_NAMED_GROUPS_EXPECTED_NAMES[x][groupIndex], lexer.tokens[y].groupInfo.name)
                        testFailed = true
                        break
                    }

                    // Validate startToken points to this GROUP_START token
                    if (!NAVAssertIntegerEqual("'Test ', itoa(x), ', Group ', itoa(groupIndex), ': startToken should point to GROUP_START'",
                        y, lexer.tokens[y].groupInfo.startToken)) {
                        NAVLogTestFailed(x, itoa(y), itoa(lexer.tokens[y].groupInfo.startToken))
                        testFailed = true
                        break
                    }

                    // Validate endToken is valid
                    if (!NAVAssertTrue("'Test ', itoa(x), ', Group ', itoa(groupIndex), ': endToken should be > startToken'",
                        lexer.tokens[y].groupInfo.endToken > lexer.tokens[y].groupInfo.startToken)) {
                        NAVLogTestFailed(x, "'endToken > startToken'", "'endToken <= startToken'")
                        testFailed = true
                        break
                    }

                    if (!NAVAssertTrue("'Test ', itoa(x), ', Group ', itoa(groupIndex), ': endToken should be <= tokenCount'",
                        lexer.tokens[y].groupInfo.endToken <= lexer.tokenCount)) {
                        NAVLogTestFailed(x, "'endToken <= tokenCount'", "'endToken > tokenCount'")
                        testFailed = true
                        break
                    }

                    // Validate that the endToken actually points to a GROUP_END token
                    if (!NAVAssertIntegerEqual("'Test ', itoa(x), ', Group ', itoa(groupIndex), ': endToken should point to GROUP_END'",
                        REGEX_TOKEN_GROUP_END,
                        lexer.tokens[lexer.tokens[y].groupInfo.endToken].type)) {
                        NAVLogTestFailed(x, 'GROUP_END', NAVRegexLexerGetTokenType(lexer.tokens[lexer.tokens[y].groupInfo.endToken].type))
                        testFailed = true
                        break
                    }

                    // Validate that the GROUP_END has the same group number
                    if (!NAVAssertIntegerEqual("'Test ', itoa(x), ', Group ', itoa(groupIndex), ': GROUP_END should have matching group number'",
                        lexer.tokens[y].groupInfo.number,
                        lexer.tokens[lexer.tokens[y].groupInfo.endToken].groupInfo.number)) {
                        NAVLogTestFailed(x, itoa(lexer.tokens[y].groupInfo.number), itoa(lexer.tokens[lexer.tokens[y].groupInfo.endToken].groupInfo.number))
                        testFailed = true
                        break
                    }

                    groupIndex++
                }
            }

            if (testFailed) {
                continue
            }
        }

        // Verify we found the expected number of groups
        if (!NAVAssertIntegerEqual("'Test ', itoa(x), ': Should have correct number of groups'",
            REGEX_LEXER_NAMED_GROUPS_EXPECTED_GROUP_COUNT[x], groupCount)) {
            NAVLogTestFailed(x, itoa(REGEX_LEXER_NAMED_GROUPS_EXPECTED_GROUP_COUNT[x]), itoa(groupCount))
            continue
        }

        NAVLogTestPassed(x)
    }
}










