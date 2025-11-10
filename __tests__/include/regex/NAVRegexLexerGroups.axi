PROGRAM_NAME='NAVRegexLexerGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_GROUPS_PATTERN_TEST[][255] = {
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

constant integer REGEX_LEXER_GROUPS_EXPECTED_TOKENS[][] = {
    {
        // Test 1: /(\d+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 2: /(\d+)-(\w+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(-), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
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
        // Test 3: /(\d{3})/ -> GROUP_START, DIGIT, QUANTIFIER, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 4: /([a-z]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 5: /(\w+)@(\w+)\.(\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(@), GROUP_START, WORD, PLUS, GROUP_END, CHAR(.), GROUP_START, WORD, PLUS, GROUP_END
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
        // Test 6: /(abc)def/ -> GROUP_START, CHAR(a), CHAR(b), CHAR(c), GROUP_END, CHAR(d), CHAR(e), CHAR(f)
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 7: /abc(def)/ -> CHAR(a), CHAR(b), CHAR(c), GROUP_START, CHAR(d), CHAR(e), CHAR(f), GROUP_END
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 8: /abc(\d+)def/ -> CHAR(a), CHAR(b), CHAR(c), GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(d), CHAR(e), CHAR(f)
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 9: /()/ -> GROUP_START, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 10: /^(\d+)$/ -> BEGIN, GROUP_START, DIGIT, PLUS, GROUP_END, END
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 11: /(\d)(\w)(\s)/ -> GROUP_START, DIGIT, GROUP_END, GROUP_START, WORD, GROUP_END, GROUP_START, WHITESPACE, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 12: /(.+)/ -> GROUP_START, DOT, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 13: /(a*)b/ -> GROUP_START, CHAR, STAR, GROUP_END, CHAR
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 14: /(hello)-(world)/ -> GROUP_START, 5xCHAR, GROUP_END, CHAR(-), GROUP_START, 5xCHAR, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 15: /\b(\w+)\b/ -> WORD_BOUNDARY, GROUP_START, WORD, PLUS, GROUP_END, WORD_BOUNDARY
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        // Test 16: /^(test)/ -> BEGIN, GROUP_START, 4xCHAR, GROUP_END
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 17: /(test)$/ -> GROUP_START, 4xCHAR, GROUP_END, END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 18: /(\.)/ -> GROUP_START, CHAR(.), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 19: /([0-9]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 20: /(\d+)\.(\d*)/ -> GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(.), GROUP_START, DIGIT, STAR, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 21: /(https?)/ -> GROUP_START, 5xCHAR(https), QUESTIONMARK, GROUP_END
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
        // Test 22: /()abc/ -> GROUP_START, GROUP_END, 3xCHAR
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    {
        // Test 23: /abc()/ -> 3xCHAR, GROUP_START, GROUP_END
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 24: /([^a-z]+)/ -> GROUP_START, INV_CHAR_CLASS, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 25: /^(\w+):(\d+)$/ -> BEGIN, GROUP_START, WORD, PLUS, GROUP_END, CHAR(:), GROUP_START, DIGIT, PLUS, GROUP_END, END
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 26: /(\d)?/ -> GROUP_START, DIGIT, GROUP_END, QUESTIONMARK
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    {
        // Test 27: /([a-zA-Z0-9]+)@([a-zA-Z0-9]+)\.([a-z]{2,})/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END, CHAR(@), GROUP_START, CHAR_CLASS, PLUS, GROUP_END, CHAR(.), GROUP_START, CHAR_CLASS, QUANTIFIER, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 28: /([\d\w]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 29: /(\\\()/ -> GROUP_START, CHAR(\\), CHAR(\(), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 30: /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/ -> 4x(GROUP_START, DIGIT, QUANTIFIER, GROUP_END) + 3xCHAR(.)
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
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
        // Test 31: /(https?):\/\/(\w+)/ -> GROUP_START, 5xCHAR(https), QUESTIONMARK, GROUP_END, CHAR(:), 2xCHAR(/), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 32: /(\s+)/ -> GROUP_START, WHITESPACE, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 33: /()()()/ -> GROUP_START, GROUP_END, GROUP_START, GROUP_END, GROUP_START, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 34: /\b(\d+)\b/ -> WORD_BOUNDARY, GROUP_START, DIGIT, PLUS, GROUP_END, WORD_BOUNDARY
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        // Test 35: /^(.*)$/ -> BEGIN, GROUP_START, DOT, STAR, GROUP_END, END
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    }
}

// Expected group counts for each pattern
constant integer REGEX_LEXER_GROUPS_EXPECTED_GROUP_COUNT[] = {
    1,      // 1: /(\d+)/ - single group
    2,      // 2: /(\d+)-(\w+)/ - two groups
    1,      // 3: /(\d{3})/ - single group
    1,      // 4: /([a-z]+)/ - single group
    3,      // 5: /(\w+)@(\w+)\.(\w+)/ - three groups
    1,      // 6: /(abc)def/ - single group
    1,      // 7: /abc(def)/ - single group
    1,      // 8: /abc(\d+)def/ - single group
    1,      // 9: /()/ - single empty group
    1,      // 10: /^(\d+)$/ - single group
    3,      // 11: /(\d)(\w)(\s)/ - three groups
    1,      // 12: /(.+)/ - single group
    1,      // 13: /(a*)b/ - single group
    2,      // 14: /(hello)-(world)/ - two groups
    1,      // 15: /\b(\w+)\b/ - single group
    1,      // 16: /^(test)/ - single group
    1,      // 17: /(test)$/ - single group
    1,      // 18: /(\.)/ - single group
    1,      // 19: /([0-9]+)/ - single group
    2,      // 20: /(\d+)\.(\d*)/ - two groups
    1,      // 21: /(https?)/ - single group
    1,      // 22: /()abc/ - single empty group
    1,      // 23: /abc()/ - single empty group
    1,      // 24: /([^a-z]+)/ - single group
    2,      // 25: /^(\w+):(\d+)$/ - two groups
    1,      // 26: /(\d)?/ - single group
    3,      // 27: /([a-zA-Z0-9]+)@([a-zA-Z0-9]+)\.([a-z]{2,})/ - three groups
    1,      // 28: /([\d\w]+)/ - single group
    1,      // 29: /(\\\()/ - single group
    4,      // 30: /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/ - four groups
    2,      // 31: /(https?):\/\/(\w+)/ - two groups
    1,      // 32: /(\s+)/ - single group
    3,      // 33: /()()()/ - three empty groups
    1,      // 34: /\b(\d+)\b/ - single group
    1       // 35: /^(.*)$/ - single group
}

// Expected group numbers for each pattern (2D array - each test can have multiple groups)
constant integer REGEX_LEXER_GROUPS_EXPECTED_NUMBERS[][] = {
    { 1 },              // 1: Group 1
    { 1, 2 },           // 2: Groups 1, 2
    { 1 },              // 3: Group 1
    { 1 },              // 4: Group 1
    { 1, 2, 3 },        // 5: Groups 1, 2, 3
    { 1 },              // 6: Group 1
    { 1 },              // 7: Group 1
    { 1 },              // 8: Group 1
    { 1 },              // 9: Group 1
    { 1 },              // 10: Group 1
    { 1, 2, 3 },        // 11: Groups 1, 2, 3
    { 1 },              // 12: Group 1
    { 1 },              // 13: Group 1
    { 1, 2 },           // 14: Groups 1, 2
    { 1 },              // 15: Group 1
    { 1 },              // 16: Group 1
    { 1 },              // 17: Group 1
    { 1 },              // 18: Group 1
    { 1 },              // 19: Group 1
    { 1, 2 },           // 20: Groups 1, 2
    { 1 },              // 21: Group 1
    { 1 },              // 22: Group 1
    { 1 },              // 23: Group 1
    { 1 },              // 24: Group 1
    { 1, 2 },           // 25: Groups 1, 2
    { 1 },              // 26: Group 1
    { 1, 2, 3 },        // 27: Groups 1, 2, 3
    { 1 },              // 28: Group 1
    { 1 },              // 29: Group 1
    { 1, 2, 3, 4 },     // 30: Groups 1, 2, 3, 4
    { 1, 2 },           // 31: Groups 1, 2
    { 1 },              // 32: Group 1
    { 1, 2, 3 },        // 33: Groups 1, 2, 3
    { 1 },              // 34: Group 1
    { 1 }               // 35: Group 1
}


define_function TestNAVRegexLexerGroups() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Capturing Groups *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_GROUPS_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_GROUPS_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_GROUPS_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_GROUPS_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_GROUPS_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
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


/**
 * @function TestNAVRegexLexerGroupsMetadata
 * @public
 * @description Validates that group metadata is correctly populated in tokens.
 *
 * This test verifies that GROUP_START and GROUP_END tokens have correct
 * metadata stored in their groupInfo structure:
 * - Group numbers are sequential (1, 2, 3...)
 * - isCapturing flag is true for all regular groups
 * - isNamed flag is false for unnamed groups
 * - startToken and endToken indices are valid and match
 *
 * Example validations:
 * - /(\d+)/ → GROUP_START has groupInfo.number=1, isCapturing=true
 * - /(\d+)-(\w+)/ → Two groups with numbers 1 and 2
 * - /(\d)(\w)(\s)/ → Three groups with sequential numbers 1, 2, 3
 */
define_function TestNAVRegexLexerGroupsMetadata() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Capturing Groups Metadata *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_GROUPS_EXPECTED_GROUP_COUNT); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer groupCount
        stack_var integer groupIndex
        stack_var integer y

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_GROUPS_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'Tokenization success', "'Tokenization failed'")
            continue
        }

        // Count how many GROUP_START tokens we have
        groupCount = 0
        for (y = 1; y <= lexer.tokenCount; y++) {
            if (lexer.tokens[y].type == REGEX_TOKEN_GROUP_START) {
                groupCount++
            }
        }

        // Verify the group count matches expected
        if (!NAVAssertIntegerEqual('Should have correct number of groups',
                                   REGEX_LEXER_GROUPS_EXPECTED_GROUP_COUNT[x],
                                   groupCount)) {
            NAVLogTestFailed(x,
                            itoa(REGEX_LEXER_GROUPS_EXPECTED_GROUP_COUNT[x]),
                            itoa(groupCount))
            continue
        }

        // Now validate metadata for each group
        {
            stack_var char testFailed
            testFailed = false

            groupIndex = 0
            for (y = 1; y <= lexer.tokenCount; y++) {
                if (lexer.tokens[y].type == REGEX_TOKEN_GROUP_START) {
                    groupIndex++

                    // Validate group number is correct
                    if (!NAVAssertIntegerEqual("'Group ', itoa(groupIndex), ' number should be correct'",
                                              REGEX_LEXER_GROUPS_EXPECTED_NUMBERS[x][groupIndex],
                                              lexer.tokens[y].groupInfo.number)) {
                        NAVLogTestFailed(x,
                                        itoa(REGEX_LEXER_GROUPS_EXPECTED_NUMBERS[x][groupIndex]),
                                        itoa(lexer.tokens[y].groupInfo.number))
                        testFailed = true
                        break
                    }

                    // Validate isCapturing flag (should be true for all regular groups)
                    if (!NAVAssertTrue("'Group ', itoa(groupIndex), ' should be capturing'",
                                      lexer.tokens[y].groupInfo.isCapturing)) {
                        NAVLogTestFailed(x, 'true', 'false')
                        testFailed = true
                        break
                    }

                    // Validate isNamed flag (should be false for unnamed groups)
                    if (!NAVAssertFalse("'Group ', itoa(groupIndex), ' should not be named'",
                                       lexer.tokens[y].groupInfo.isNamed)) {
                        NAVLogTestFailed(x, 'false', 'true')
                        testFailed = true
                        break
                    }

                    // Validate name is empty for unnamed groups
                    if (!NAVAssertStringEqual("'Group ', itoa(groupIndex), ' name should be empty'",
                                             '',
                                             lexer.tokens[y].groupInfo.name)) {
                        NAVLogTestFailed(x, 'Empty group name', lexer.tokens[y].groupInfo.name)
                        testFailed = true
                        break
                    }

                    // Validate startToken index points to current token
                    if (!NAVAssertIntegerEqual("'Group ', itoa(groupIndex), ' startToken should point to GROUP_START'",
                                              y,
                                              lexer.tokens[y].groupInfo.startToken)) {
                        NAVLogTestFailed(x,
                                        itoa(y),
                                        itoa(lexer.tokens[y].groupInfo.startToken))
                        testFailed = true
                        break
                    }

                    // Validate endToken index is valid (greater than startToken, within bounds)
                    if (!NAVAssertTrue("'Group ', itoa(groupIndex), ' endToken should be > startToken'",
                                      lexer.tokens[y].groupInfo.endToken > lexer.tokens[y].groupInfo.startToken)) {
                        NAVLogTestFailed(x,
                                        "'endToken > ', itoa(y)",
                                        itoa(lexer.tokens[y].groupInfo.endToken))
                        testFailed = true
                        break
                    }

                    if (!NAVAssertTrue("'Group ', itoa(groupIndex), ' endToken should be <= tokenCount'",
                                      lexer.tokens[y].groupInfo.endToken <= lexer.tokenCount)) {
                        NAVLogTestFailed(x,
                                        "'endToken <= ', itoa(lexer.tokenCount)",
                                        itoa(lexer.tokens[y].groupInfo.endToken))
                        testFailed = true
                        break
                    }

                    // Validate the token at endToken index is actually GROUP_END
                    if (!NAVAssertIntegerEqual("'Group ', itoa(groupIndex), ' endToken should point to GROUP_END'",
                                              REGEX_TOKEN_GROUP_END,
                                              lexer.tokens[lexer.tokens[y].groupInfo.endToken].type)) {
                        NAVLogTestFailed(x,
                                        'GROUP_END',
                                        NAVRegexLexerGetTokenType(lexer.tokens[lexer.tokens[y].groupInfo.endToken].type))
                        testFailed = true
                        break
                    }

                    // Validate the GROUP_END token has matching groupInfo
                    if (!NAVAssertIntegerEqual("'Group ', itoa(groupIndex), ' GROUP_END should have matching group number'",
                                              lexer.tokens[y].groupInfo.number,
                                              lexer.tokens[lexer.tokens[y].groupInfo.endToken].groupInfo.number)) {
                        NAVLogTestFailed(x,
                                        itoa(lexer.tokens[y].groupInfo.number),
                                        itoa(lexer.tokens[lexer.tokens[y].groupInfo.endToken].groupInfo.number))
                        testFailed = true
                        break
                    }
                }
            }

            if (testFailed) {
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}










