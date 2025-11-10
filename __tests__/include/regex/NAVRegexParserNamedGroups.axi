PROGRAM_NAME='NAVRegexParserNamedGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexParserTestHelpers.axi'

DEFINE_CONSTANT

// Test type constants for named group validation
constant integer NAMED_GROUP_TEST_BASIC         = 1
constant integer NAMED_GROUP_TEST_MULTIPLE      = 2
constant integer NAMED_GROUP_TEST_NESTED        = 3
constant integer NAMED_GROUP_TEST_MIXED         = 4

// Test patterns for named group validation
constant char REGEX_PARSER_NAMED_GROUPS_PATTERN[][255] = {
    '/(?P<name>a)/',                                    // 1: Single Python-style named group
    '/(?<name>a)/',                                     // 2: Single .NET-style named group
    '/(?P<first>a)(?P<second>b)/',                      // 3: Two Python-style named groups
    '/(?<first>a)(?<second>b)/',                        // 4: Two .NET-style named groups
    '/(?P<outer>a(?P<inner>b))/',                       // 5: Nested Python-style named groups
    '/(?<outer>a(?<inner>b))/',                         // 6: Nested .NET-style named groups
    '/(?P<one>a)(b)/',                                  // 7: Mixed named and unnamed (Python)
    '/(?<one>a)(b)/',                                   // 8: Mixed named and unnamed (.NET)
    '/(a)(?P<two>b)/',                                  // 9: Unnamed then named (Python)
    '/(a)(?<two>b)/',                                   // 10: Unnamed then named (.NET)
    '/(?P<first>a)(b)(?P<third>c)/',                    // 11: Alternating named/unnamed (Python)
    '/(?<first>a)(b)(?<third>c)/',                      // 12: Alternating named/unnamed (.NET)
    '/(?P<word>\w+)/',                                  // 13: Named group with character class
    '/(?<digits>\d+)/',                                 // 14: Named group with digit class
    '/(?P<letters>[a-z]+)/',                            // 15: Named group with range
    '/(?P<optional>a?)/',                               // 16: Named group with ? quantifier
    '/(?P<star>a*)/',                                   // 17: Named group with * quantifier
    '/(?P<plus>a+)/',                                   // 18: Named group with + quantifier
    '/(?P<exact>a{3})/',                                // 19: Named group with exact quantifier
    '/(?P<range>a{2,4})/',                              // 20: Named group with range quantifier
    '/(?P<choice>a|b)/',                                // 21: Named group with alternation
    '/(?P<first>a|b)(?P<second>c|d)/',                  // 22: Multiple named groups with alternation
    '/(?P<outer>(?P<inner>a)|b)/',                      // 23: Nested named with alternation
    '/(?P<tag><[^>]+>)/',                               // 24: Named group for HTML tags
    '/(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})/',    // 25: Date pattern with named groups
    '/(?P<key>\w+)=(?P<value>[^,]+)/',                  // 26: Key-value pair pattern
    '/(?P<protocol>https?):\/\/(?P<domain>[^\/]+)/',    // 27: URL parts pattern (escaped slashes)
    '/(?P<a>a)(?P<b>b)(?P<c>c)(?P<d>d)(?P<e>e)/',       // 28: Five sequential named groups
    '/(?P<L1>(?P<L2>(?P<L3>(?P<L4>(?P<L5>a)))))/',     // 29: Deep nesting (5 levels)
    '/(?P<g1>a)(?:b)(?P<g2>c)/'                         // 30: Named with non-capturing in between
}

// Expected group count for each pattern
constant integer REGEX_PARSER_NAMED_GROUPS_COUNT[] = {
    1,      // 1: Single named
    1,      // 2: Single named
    2,      // 3: Two named
    2,      // 4: Two named
    2,      // 5: Nested = 2 groups
    2,      // 6: Nested = 2 groups
    2,      // 7: Mixed = 2 groups
    2,      // 8: Mixed = 2 groups
    2,      // 9: Mixed = 2 groups
    2,      // 10: Mixed = 2 groups
    3,      // 11: Three groups
    3,      // 12: Three groups
    1,      // 13: Single with class
    1,      // 14: Single with class
    1,      // 15: Single with range
    1,      // 16: With ? quantifier
    1,      // 17: With * quantifier
    1,      // 18: With + quantifier
    1,      // 19: With exact quantifier
    1,      // 20: With range quantifier
    1,      // 21: With alternation
    2,      // 22: Two with alternation
    2,      // 23: Nested with alternation
    1,      // 24: HTML tag
    3,      // 25: Date pattern
    2,      // 26: Key-value
    2,      // 27: URL parts
    5,      // 28: Five groups
    5,      // 29: Deep nesting
    2       // 30: With non-capturing
}

// Test type for each pattern
constant integer REGEX_PARSER_NAMED_GROUPS_TYPE[] = {
    NAMED_GROUP_TEST_BASIC,         // 1
    NAMED_GROUP_TEST_BASIC,         // 2
    NAMED_GROUP_TEST_MULTIPLE,      // 3
    NAMED_GROUP_TEST_MULTIPLE,      // 4
    NAMED_GROUP_TEST_NESTED,        // 5
    NAMED_GROUP_TEST_NESTED,        // 6
    NAMED_GROUP_TEST_MIXED,         // 7
    NAMED_GROUP_TEST_MIXED,         // 8
    NAMED_GROUP_TEST_MIXED,         // 9
    NAMED_GROUP_TEST_MIXED,         // 10
    NAMED_GROUP_TEST_MIXED,         // 11
    NAMED_GROUP_TEST_MIXED,         // 12
    NAMED_GROUP_TEST_BASIC,         // 13
    NAMED_GROUP_TEST_BASIC,         // 14
    NAMED_GROUP_TEST_BASIC,         // 15
    NAMED_GROUP_TEST_BASIC,         // 16
    NAMED_GROUP_TEST_BASIC,         // 17
    NAMED_GROUP_TEST_BASIC,         // 18
    NAMED_GROUP_TEST_BASIC,         // 19
    NAMED_GROUP_TEST_BASIC,         // 20
    NAMED_GROUP_TEST_BASIC,         // 21
    NAMED_GROUP_TEST_MULTIPLE,      // 22
    NAMED_GROUP_TEST_NESTED,        // 23
    NAMED_GROUP_TEST_BASIC,         // 24
    NAMED_GROUP_TEST_MULTIPLE,      // 25
    NAMED_GROUP_TEST_MULTIPLE,      // 26
    NAMED_GROUP_TEST_MULTIPLE,      // 27
    NAMED_GROUP_TEST_MULTIPLE,      // 28
    NAMED_GROUP_TEST_NESTED,        // 29
    NAMED_GROUP_TEST_MIXED          // 30
}

// Expected group names for each test
// Format: [test_index][group_number] = name
// Empty string means the group at that position is unnamed
constant char REGEX_PARSER_NAMED_GROUPS_EXPECTED_NAMES[][5][50] = {
    { 'name', '', '', '', '' },                             // 1: group 1 = "name"
    { 'name', '', '', '', '' },                             // 2: group 1 = "name"
    { 'first', 'second', '', '', '' },                      // 3: group 1 = "first", group 2 = "second"
    { 'first', 'second', '', '', '' },                      // 4: group 1 = "first", group 2 = "second"
    { 'outer', 'inner', '', '', '' },                       // 5: group 1 = "outer", group 2 = "inner"
    { 'outer', 'inner', '', '', '' },                       // 6: group 1 = "outer", group 2 = "inner"
    { 'one', '', '', '', '' },                              // 7: group 1 = "one", group 2 unnamed
    { 'one', '', '', '', '' },                              // 8: group 1 = "one", group 2 unnamed
    { '', 'two', '', '', '' },                              // 9: group 1 unnamed, group 2 = "two"
    { '', 'two', '', '', '' },                              // 10: group 1 unnamed, group 2 = "two"
    { 'first', '', 'third', '', '' },                       // 11: group 1 = "first", group 2 unnamed, group 3 = "third"
    { 'first', '', 'third', '', '' },                       // 12: group 1 = "first", group 2 unnamed, group 3 = "third"
    { 'word', '', '', '', '' },                             // 13: group 1 = "word"
    { 'digits', '', '', '', '' },                           // 14: group 1 = "digits"
    { 'letters', '', '', '', '' },                          // 15: group 1 = "letters"
    { 'optional', '', '', '', '' },                         // 16: group 1 = "optional"
    { 'star', '', '', '', '' },                             // 17: group 1 = "star"
    { 'plus', '', '', '', '' },                             // 18: group 1 = "plus"
    { 'exact', '', '', '', '' },                            // 19: group 1 = "exact"
    { 'range', '', '', '', '' },                            // 20: group 1 = "range"
    { 'choice', '', '', '', '' },                           // 21: group 1 = "choice"
    { 'first', 'second', '', '', '' },                      // 22: group 1 = "first", group 2 = "second"
    { 'outer', 'inner', '', '', '' },                       // 23: group 1 = "outer", group 2 = "inner"
    { 'tag', '', '', '', '' },                              // 24: group 1 = "tag"
    { 'year', 'month', 'day', '', '' },                     // 25: group 1 = "year", group 2 = "month", group 3 = "day"
    { 'key', 'value', '', '', '' },                         // 26: group 1 = "key", group 2 = "value"
    { 'protocol', 'domain', '', '', '' },                   // 27: group 1 = "protocol", group 2 = "domain"
    { 'a', 'b', 'c', 'd', 'e' },                            // 28: all five groups named
    { 'L1', 'L2', 'L3', 'L4', 'L5' },                       // 29: all five levels named
    { 'g1', 'g2', '', '', '' }                              // 30: group 1 = "g1", group 2 = "g2"
}


/**
 * @function TestNAVRegexParserNamedGroups
 * @public
 * @description Validates named group handling in parser.
 *
 * Critical properties for named groups:
 * 1. Group names are stored in CAPTURE_START and CAPTURE_END states
 * 2. Both START and END states have the same name for a group
 * 3. Named groups still get sequential numeric group numbers (1, 2, 3, ...)
 * 4. Unnamed groups have empty string as group name
 * 5. Mixed patterns (named + unnamed) handle both correctly
 * 6. Both Python (?P<name>...) and .NET (?<name>...) syntax work
 * 7. Nested named groups maintain proper names at each level
 * 8. Names are preserved through quantifiers and alternation
 *
 * Why this matters:
 * - Matcher needs group names to return named capture results
 * - Both START and END must have same name for consistency
 * - Sequential numbering ensures group[1] always means group 1
 * - Mixed patterns are common in real-world regex
 *
 * Example: /(?P<first>a)(b)(?P<third>c)/ should have:
 * - Group 1: number=1, name="first"
 * - Group 2: number=2, name="" (unnamed)
 * - Group 3: number=3, name="third"
 */
define_function TestNAVRegexParserNamedGroups() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Named Group Handling *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_NAMED_GROUPS_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer expectedGroupCount
        stack_var integer testType
        stack_var integer i

        expectedGroupCount = REGEX_PARSER_NAMED_GROUPS_COUNT[x]
        testType = REGEX_PARSER_NAMED_GROUPS_TYPE[x]

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_NAMED_GROUPS_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Test 1: Verify group count matches expected
        if (!NAVAssertIntegerEqual('Group count should match expected', expectedGroupCount, nfa.captureGroupCount)) {
            NAVLogTestFailed(x, "itoa(expectedGroupCount), ' groups'", "itoa(nfa.captureGroupCount), ' groups'")
            continue
        }

        // Test 2: Verify each group has the correct name in both START and END states
        if (!NAVAssertTrue('All groups should have correct names', ValidateAllGroupNames(nfa, REGEX_PARSER_NAMED_GROUPS_EXPECTED_NAMES[x], expectedGroupCount))) {
            NAVLogTestFailed(x, 'correct group names', 'incorrect or missing group names')
            continue
        }

        // Test 3: Verify named groups still get sequential numeric group numbers
        if (!NAVAssertTrue('Named groups should not affect sequential numbering', ValidateNamedGroupsDoNotAffectNumbering(nfa))) {
            NAVLogTestFailed(x, 'sequential numbering', 'gaps or non-sequential numbers')
            continue
        }

        // Test 4: For mixed patterns, verify both named and unnamed groups handled correctly
        if (testType == NAMED_GROUP_TEST_MIXED) {
            if (!NAVAssertTrue('Mixed named/unnamed groups should be handled correctly', ValidateMixedNamedAndUnnamed(nfa, REGEX_PARSER_NAMED_GROUPS_EXPECTED_NAMES[x], expectedGroupCount))) {
                NAVLogTestFailed(x, 'correct handling of mixed groups', 'incorrect names for mixed groups')
                continue
            }
        }

        // Test 5: Verify that group names match between START and END states
        for (i = 1; i <= expectedGroupCount; i++) {
            stack_var integer startState
            stack_var integer endState

            startState = FindCaptureStateByGroupNumber(nfa, i, NFA_STATE_CAPTURE_START)
            endState = FindCaptureStateByGroupNumber(nfa, i, NFA_STATE_CAPTURE_END)

            if (startState > 0 && endState > 0) {
                if (!NAVAssertStringEqual('START and END states should have matching names', nfa.states[startState].groupName, nfa.states[endState].groupName)) {
                    NAVLogTestFailed(x, "'Group ', itoa(i), ' START/END name match'", "'Group ', itoa(i), ' name mismatch'")
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
