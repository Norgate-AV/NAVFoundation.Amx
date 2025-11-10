PROGRAM_NAME='NAVRegexParserCaptureGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test type constants for capture group validation
constant integer CAPTURE_TEST_BASIC             = 1
constant integer CAPTURE_TEST_NESTED            = 2
constant integer CAPTURE_TEST_SEQUENTIAL        = 3
constant integer CAPTURE_TEST_NON_CAPTURING     = 4
constant integer CAPTURE_TEST_MIXED             = 5

// Test patterns for capture group validation
constant char REGEX_PARSER_CAPTURE_GROUPS_PATTERN[][255] = {
    '/(a)/',                    // 1: Single capture group
    '/(a)(b)/',                 // 2: Two sequential groups
    '/(a)(b)(c)/',              // 3: Three sequential groups
    '/((a))/',                  // 4: Nested groups (2 levels)
    '/(a(b))/',                 // 5: Nested groups with content
    '/(a(b(c)))/',              // 6: Deep nesting (3 levels)
    '/(a)(b(c))/',              // 7: Mix of sequential and nested
    '/(?:a)/',                  // 8: Non-capturing group only
    '/(a)(?:b)(c)/',            // 9: Mixed capturing and non-capturing
    '/(?:a(?:b))/',             // 10: Nested non-capturing
    '/(a|b)/',                  // 11: Capturing with alternation
    '/(a)|(b)/',                // 12: Multiple captures with alternation
    '/((a)|(b))/',              // 13: Nested captures with alternation
    '/(a*)/',                   // 14: Capture with quantifier
    '/((a+)(b*))/',             // 15: Nested captures with quantifiers
    '/(a)(b)*/',                // 16: Sequential with quantifier
    '/(a(?:b)c)/',              // 17: Non-capturing inside capturing
    '/(?:(a)b)/',               // 18: Capturing inside non-capturing
    '/(a)(b)(c)(d)(e)/',        // 19: Five sequential groups
    '/(((((a)))))/'             // 20: Deep nesting (5 levels)
}

constant integer REGEX_PARSER_CAPTURE_GROUPS_COUNT[] = {
    1,      // 1: Single group
    2,      // 2: Two groups
    3,      // 3: Three groups
    2,      // 4: Nested = 2 groups (outer + inner)
    2,      // 5: Nested with content = 2 groups
    3,      // 6: Deep nesting = 3 groups
    3,      // 7: Mix = 3 groups
    0,      // 8: Non-capturing = 0 groups
    2,      // 9: Mixed = 2 capturing groups
    0,      // 10: Nested non-capturing = 0 groups
    1,      // 11: With alternation = 1 group
    2,      // 12: Multiple with alternation = 2 groups
    3,      // 13: Nested with alternation = 3 groups (outer + 2 inner)
    1,      // 14: With quantifier = 1 group
    3,      // 15: Nested with quantifiers = 3 groups
    2,      // 16: Sequential with quantifier = 2 groups
    1,      // 17: Non-capturing inside = 1 group
    1,      // 18: Capturing inside non-capturing = 1 group
    5,      // 19: Five groups
    5       // 20: Deep nesting = 5 groups
}

constant integer REGEX_PARSER_CAPTURE_GROUPS_TYPE[] = {
    CAPTURE_TEST_BASIC,             // 1
    CAPTURE_TEST_SEQUENTIAL,        // 2
    CAPTURE_TEST_SEQUENTIAL,        // 3
    CAPTURE_TEST_NESTED,            // 4
    CAPTURE_TEST_NESTED,            // 5
    CAPTURE_TEST_NESTED,            // 6
    CAPTURE_TEST_MIXED,             // 7
    CAPTURE_TEST_NON_CAPTURING,     // 8
    CAPTURE_TEST_MIXED,             // 9
    CAPTURE_TEST_NON_CAPTURING,     // 10
    CAPTURE_TEST_BASIC,             // 11
    CAPTURE_TEST_SEQUENTIAL,        // 12
    CAPTURE_TEST_MIXED,             // 13
    CAPTURE_TEST_BASIC,             // 14
    CAPTURE_TEST_NESTED,            // 15
    CAPTURE_TEST_SEQUENTIAL,        // 16
    CAPTURE_TEST_MIXED,             // 17
    CAPTURE_TEST_MIXED,             // 18
    CAPTURE_TEST_SEQUENTIAL,        // 19
    CAPTURE_TEST_NESTED             // 20
}


/**
 * @function TestNAVRegexParserCaptureGroups
 * @public
 * @description Validates capture group structure in NFAs.
 *
 * Critical properties for matcher:
 * 1. Each CAPTURE_START has matching CAPTURE_END with same group number
 * 2. Group numbers are sequential starting from 1 (no gaps)
 * 3. Nested groups have correct parent-child relationships
 * 4. Non-capturing groups don't create CAPTURE states
 * 5. Group count in NFA matches actual capture states
 *
 * Why this matters:
 * - Matcher relies on group numbers to extract submatches
 * - Mismatched START/END will cause incorrect or missing captures
 * - Non-sequential numbering breaks group indexing
 * - Overlapping groups cause undefined behavior
 *
 * Example: /(a(b)c)/ should have:
 * - Group 1: outer group (abc)
 * - Group 2: inner group (b)
 * - Sequential numbering: 1, 2
 * - Proper nesting: START1, START2, END2, END1
 */
define_function TestNAVRegexParserCaptureGroups() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Capture Group Structure *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_CAPTURE_GROUPS_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer expectedGroupCount
        stack_var integer testType
        stack_var integer i

        expectedGroupCount = REGEX_PARSER_CAPTURE_GROUPS_COUNT[x]
        testType = REGEX_PARSER_CAPTURE_GROUPS_TYPE[x]

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_CAPTURE_GROUPS_PATTERN[x], lexer))) {
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

        // Test 2: Verify each group has proper START/END pairing
        for (i = 1; i <= expectedGroupCount; i++) {
            if (!NAVAssertTrue('Each group should have matching START/END', ValidateCaptureGroupPairing(nfa, i))) {
                NAVLogTestFailed(x, "'Group ', itoa(i), ' properly paired'", "'Group ', itoa(i), ' pairing failed'")
                continue
            }
        }

        // Test 3: Verify sequential numbering
        if (!NAVAssertTrue('Groups should be numbered sequentially', ValidateCaptureGroupNumbering(nfa))) {
            NAVLogTestFailed(x, 'sequential numbering', 'numbering gaps or mismatch')
            continue
        }

        // Test 4: Verify proper nesting (no overlapping groups)
        if (!NAVAssertTrue('Groups should nest properly', ValidateCaptureGroupNesting(nfa))) {
            NAVLogTestFailed(x, 'proper nesting', 'overlapping or mismatched groups')
            continue
        }

        // Test 5: For patterns with non-capturing groups, verify count is correct
        if (!NAVAssertTrue('Non-capturing groups should not create CAPTURE states', ValidateNonCapturingGroups(nfa, expectedGroupCount))) {
            NAVLogTestFailed(x, "itoa(expectedGroupCount), ' capture states'", 'incorrect capture state count')
            continue
        }

        NAVLogTestPassed(x)
    }
}