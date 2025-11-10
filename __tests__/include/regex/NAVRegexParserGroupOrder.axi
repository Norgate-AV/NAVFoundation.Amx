PROGRAM_NAME='NAVRegexParserGroupOrder'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.ArrayUtils.axi'

DEFINE_CONSTANT

// Test patterns specifically for validating left-to-right group numbering order
constant char REGEX_PARSER_GROUP_ORDER_PATTERN[][255] = {
    '/(a)/',                        // 1: Single group → [1]
    '/(a)(b)/',                     // 2: Two sequential → [1, 2]
    '/((a))/',                      // 3: Nested (outer first) → [1, 2]
    '/((a)(b))/',                   // 4: Nested with siblings → [1, 2, 3]
    '/(a(b))/',                     // 5: Nested (parent then child) → [1, 2]
    '/(a)(b)(c)/',                  // 6: Three sequential → [1, 2, 3]
    '/(a(b(c)))/',                  // 7: Deep nesting → [1, 2, 3]
    '/(a(b)c)/',                    // 8: Parent-child-parent → [1, 2]
    '/(a)(b(c))/',                  // 9: Sequential then nested → [1, 2, 3]
    '/((a)b)((c)d)/',               // 10: Two nested groups → [1, 2, 3, 4]
    '/(((a)))/',                    // 11: Triple nesting → [1, 2, 3]
    '/(a)|(b)/',                    // 12: Alternation → [1, 2]
    '/((a)|(b))/',                  // 13: Nested alternation → [1, 2, 3]
    '/(a(b|c))/',                   // 14: Parent with alternation → [1, 2, 3]
    '/(a)(b)(c)(d)(e)/'             // 15: Five sequential → [1, 2, 3, 4, 5]
}

// Expected group numbers in the order CAPTURE_START states are encountered
// Format: For pattern N, this is the sequence of group numbers expected
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_1[] = { 1 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_2[] = { 1, 2 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_3[] = { 1, 2 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_4[] = { 1, 2, 3 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_5[] = { 1, 2 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_6[] = { 1, 2, 3 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_7[] = { 1, 2, 3 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_8[] = { 1, 2 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_9[] = { 1, 2, 3 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_10[] = { 1, 2, 3, 4 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_11[] = { 1, 2, 3 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_12[] = { 1, 2 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_13[] = { 1, 2, 3 }
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_14[] = { 1, 2 }  // (a(b|c)) has 2 groups: outer and inner, no groups for b or c
constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_15[] = { 1, 2, 3, 4, 5 }

constant integer REGEX_PARSER_GROUP_ORDER_EXPECTED_COUNT[] = {
    1,      // 1
    2,      // 2
    2,      // 3
    3,      // 4
    2,      // 5
    3,      // 6
    3,      // 7
    2,      // 8
    3,      // 9
    4,      // 10
    3,      // 11
    2,      // 12
    3,      // 13
    2,      // 14 - Fixed: (a(b|c)) has 2 groups, not 3
    5       // 15
}


/**
 * @function TestNAVRegexParserGroupNumberingOrder
 * @public
 * @description Validates that capture groups are numbered in left-to-right order
 * by their opening parenthesis in the source pattern.
 *
 * This is critical for matcher correctness:
 * - Groups must be numbered 1, 2, 3... in the order they open, not the order they're processed
 * - Nested groups: outer group gets lower number than inner groups
 * - Example: /((a)(b))/ → Group 1 is outer, Group 2 is (a), Group 3 is (b)
 *
 * This test walks the NFA from start state and verifies CAPTURE_START states are
 * encountered in the correct group number order (1, 2, 3...).
 *
 * Why this matters:
 * - User expectations: Group 1 in /((a)(b))/ should be the full "ab", not just "a"
 * - Consistency with other regex engines (PCRE, JavaScript, Python, etc.)
 * - Backreferences rely on correct group numbering
 *
 * Failure modes caught:
 * - Inside-out numbering (processing order instead of appearance order)
 * - Incorrect group assignment during parser recursion
 * - Missing groups in alternations
 */
define_function TestNAVRegexParserGroupNumberingOrder() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Group Numbering Order *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_GROUP_ORDER_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer expectedGroupNumbers[MAX_REGEX_GROUPS]
        stack_var integer expectedCount
        stack_var integer i

        expectedCount = REGEX_PARSER_GROUP_ORDER_EXPECTED_COUNT[x]

        // Load expected group number sequence for this test
        switch (x) {
            case 1:  for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_1[i]
            case 2:  for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_2[i]
            case 3:  for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_3[i]
            case 4:  for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_4[i]
            case 5:  for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_5[i]
            case 6:  for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_6[i]
            case 7:  for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_7[i]
            case 8:  for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_8[i]
            case 9:  for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_9[i]
            case 10: for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_10[i]
            case 11: for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_11[i]
            case 12: for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_12[i]
            case 13: for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_13[i]
            case 14: for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_14[i]
            case 15: for (i = 1; i <= expectedCount; i++) expectedGroupNumbers[i] = REGEX_PARSER_GROUP_ORDER_EXPECTED_15[i]
        }

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_GROUP_ORDER_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            NAVLog("'  Pattern: ', REGEX_PARSER_GROUP_ORDER_PATTERN[x]")
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            NAVLog("'  Pattern: ', REGEX_PARSER_GROUP_ORDER_PATTERN[x]")
            continue
        }

        // Verify group count matches expected
        if (!NAVAssertIntegerEqual('Group count should match expected', expectedCount, nfa.captureGroupCount)) {
            NAVLogTestFailed(x, "itoa(expectedCount), ' groups'", "itoa(nfa.captureGroupCount), ' groups'")
            NAVLog("'  Pattern: ', REGEX_PARSER_GROUP_ORDER_PATTERN[x]")
            continue
        }

        // Verify groups are numbered in left-to-right order
        if (!NAVAssertTrue('Groups should be numbered in left-to-right order', ValidateCaptureGroupOrder(nfa, expectedGroupNumbers, expectedCount))) {
            stack_var integer foundNumbers[MAX_REGEX_GROUPS]
            stack_var integer foundCount
            stack_var integer stateIdx
            stack_var integer expectedForDisplay[20]

            NAVLogTestFailed(x, 'left-to-right group numbering', 'incorrect group number sequence')
            NAVLog("'  Pattern: ', REGEX_PARSER_GROUP_ORDER_PATTERN[x]")

            // Copy expected numbers to properly sized array for formatting
            set_length_array(expectedForDisplay, expectedCount)
            for (stateIdx = 1; stateIdx <= expectedCount; stateIdx++) {
                expectedForDisplay[stateIdx] = expectedGroupNumbers[stateIdx]
            }
            NAVLog("'  Expected order: ', NAVFormatArrayInteger(expectedForDisplay)")

            // Collect actual group numbers found
            foundCount = 0
            for (stateIdx = 1; stateIdx <= nfa.stateCount; stateIdx++) {
                if (nfa.states[stateIdx].type == NFA_STATE_CAPTURE_START) {
                    foundCount++
                    foundNumbers[foundCount] = nfa.states[stateIdx].groupNumber
                }
            }
            set_length_array(foundNumbers, foundCount)
            NAVLog("'  Actual order:   ', NAVFormatArrayInteger(foundNumbers)")
            continue
        }

        NAVLogTestPassed(x)
    }
}
