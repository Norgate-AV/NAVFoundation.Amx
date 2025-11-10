PROGRAM_NAME='NAVRegexParserBackreferences'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexParserTestHelpers.axi'

DEFINE_CONSTANT

// Test type constants for backreference validation
constant integer BACKREF_TEST_NUMBERED          = 1
constant integer BACKREF_TEST_NAMED             = 2
constant integer BACKREF_TEST_MULTIPLE          = 3
constant integer BACKREF_TEST_NESTED            = 4
constant integer BACKREF_TEST_ERROR             = 5

// Test patterns for backreference validation
constant char REGEX_PARSER_BACKREF_PATTERN[][255] = {
    '/(a)\1/',                      // 1: Simple numbered backreference
    '/(ab)\1/',                     // 2: Multi-char numbered backreference
    '/(a)(b)\1/',                   // 3: Multiple groups, backref to first
    '/(a)(b)\2/',                   // 4: Multiple groups, backref to second
    '/(a)(b)\1\2/',                 // 5: Multiple backreferences
    '/(a)(b)\2\1/',                 // 6: Backreferences in different order
    '/((a)b)\1/',                   // 7: Nested groups with backreference
    '/((a)b)\2/',                   // 8: Nested groups, backref to inner
    '/(a)\1\1/',                    // 9: Same backreference multiple times
    '/(?P<word>a)\k<word>/',        // 10: Python-style named backreference
    '/(?<word>a)\k<word>/',         // 11: .NET-style named backreference
    '/(?P<first>a)(?P<second>b)\k<first>/',     // 12: Named backref to first
    '/(?P<first>a)(?P<second>b)\k<second>/',    // 13: Named backref to second
    '/(?P<word>a)\k<word>\k<word>/',            // 14: Same named backref multiple times
    '/(a)(b)(c)\1\2\3/',            // 15: Three groups, three backrefs
    '/((a)(b))\1\2\3/',             // 16: Nested with multiple backrefs
    '/(?:(a)|(b))\1/',              // 17: Alternation with backreference
    '/(a+)\1/',                     // 18: Backreference with quantifier in group
    '/(a*)\1/',                     // 19: Zero-or-more with backreference
    '/(a?)\1/',                     // 20: Optional with backreference
    '/([a-z])\1/',                  // 21: Character class with backreference
    '/(\d)\1/',                     // 22: Digit class with backreference
    '/(\w+)\s+\1/',                 // 23: Word repeat with whitespace
    '/(?P<tag><\w+>).*?\k<tag>/',   // 24: Named group for HTML-like tags
    '/(.)(.)\2\1/'                  // 25: Palindrome pattern (abba)
}

constant integer REGEX_PARSER_BACKREF_TYPE[] = {
    BACKREF_TEST_NUMBERED,          // 1
    BACKREF_TEST_NUMBERED,          // 2
    BACKREF_TEST_MULTIPLE,          // 3
    BACKREF_TEST_MULTIPLE,          // 4
    BACKREF_TEST_MULTIPLE,          // 5
    BACKREF_TEST_MULTIPLE,          // 6
    BACKREF_TEST_NESTED,            // 7
    BACKREF_TEST_NESTED,            // 8
    BACKREF_TEST_NUMBERED,          // 9
    BACKREF_TEST_NAMED,             // 10
    BACKREF_TEST_NAMED,             // 11
    BACKREF_TEST_NAMED,             // 12
    BACKREF_TEST_NAMED,             // 13
    BACKREF_TEST_NAMED,             // 14
    BACKREF_TEST_MULTIPLE,          // 15
    BACKREF_TEST_NESTED,            // 16
    BACKREF_TEST_NUMBERED,          // 17
    BACKREF_TEST_NUMBERED,          // 18
    BACKREF_TEST_NUMBERED,          // 19
    BACKREF_TEST_NUMBERED,          // 20
    BACKREF_TEST_NUMBERED,          // 21
    BACKREF_TEST_NUMBERED,          // 22
    BACKREF_TEST_NUMBERED,          // 23
    BACKREF_TEST_NAMED,             // 24
    BACKREF_TEST_MULTIPLE           // 25
}

// Expected backreference numbers for numbered backreferences
// Format: [test_index, expected_backref_number]
constant integer REGEX_PARSER_BACKREF_EXPECTED_NUMBER[][2] = {
    { 1, 1 },       // \1 in test 1
    { 2, 1 },       // \1 in test 2
    { 3, 1 },       // \1 in test 3
    { 4, 2 },       // \2 in test 4
    { 7, 1 },       // \1 in test 7
    { 8, 2 },       // \2 in test 8
    { 9, 1 },       // \1 in test 9
    { 16, 1 },      // \1 in test 16 (first backref in nested groups)
    { 17, 1 },      // \1 in test 17
    { 18, 1 },      // \1 in test 18
    { 19, 1 },      // \1 in test 19
    { 20, 1 },      // \1 in test 20
    { 21, 1 },      // \1 in test 21
    { 22, 1 },      // \1 in test 22
    { 23, 1 }       // \1 in test 23
}

// Expected backreference names for named backreferences
// Format: [test_index, name]
constant char REGEX_PARSER_BACKREF_EXPECTED_NAME[][2][50] = {
    { '10', 'word' },       // \k<word> in test 10
    { '11', 'word' },       // \k<word> in test 11
    { '12', 'first' },      // \k<first> in test 12
    { '13', 'second' },     // \k<second> in test 13
    { '14', 'word' },       // \k<word> in test 14
    { '24', 'tag' }         // \k<tag> in test 24
}

// Error case patterns - these should fail to parse
// NOTE: Per specification, \1-\9 with no matching group becomes octal escape (valid)
// Therefore only invalid named backreferences should fail
constant char REGEX_PARSER_BACKREF_ERROR_PATTERN[][255] = {
    '/\k<missing>/',                // 1: Named backreference with no matching group
    '/(?P<name>a)\k<other>/'        // 2: Named backreference to wrong name
}


/**
 * @function TestNAVRegexParserBackreferences
 * @description Test backreference parsing and NFA construction.
 *
 * Tests:
 * - Numbered backreferences (\1, \2, etc.)
 * - Named backreferences (\k<name>)
 * - Multiple backreferences in one pattern
 * - Nested groups with backreferences
 * - Backreference state creation and validation
 */
define_function TestNAVRegexParserBackreferences() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Backreferences *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_BACKREF_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer testType
        stack_var integer backrefStateId
        stack_var char foundBackref

        testType = REGEX_PARSER_BACKREF_TYPE[x]

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_BACKREF_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Test 1: Find backreference state
        foundBackref = FindBackreferenceState(nfa, backrefStateId)
        if (!NAVAssertTrue('Should find backreference state', foundBackref)) {
            NAVLogTestFailed(x, 'backreference state found', 'no backreference state')
            continue
        }

        // Test 2: Validate numbered backreferences
        if (testType == BACKREF_TEST_NUMBERED || testType == BACKREF_TEST_MULTIPLE || testType == BACKREF_TEST_NESTED) {
            stack_var integer i
            stack_var char foundExpected

            foundExpected = false

            for (i = 1; i <= length_array(REGEX_PARSER_BACKREF_EXPECTED_NUMBER); i++) {
                if (REGEX_PARSER_BACKREF_EXPECTED_NUMBER[i][1] == x) {
                    stack_var integer expectedNumber
                    expectedNumber = REGEX_PARSER_BACKREF_EXPECTED_NUMBER[i][2]

                    if (!NAVAssertTrue('Backreference should have correct number', ValidateBackrefNumber(nfa, backrefStateId, expectedNumber))) {
                        NAVLogTestFailed(x, "'backref group ', itoa(expectedNumber)", "'backref group ', itoa(nfa.states[backrefStateId].groupNumber)")
                        foundExpected = true
                        break
                    }

                    foundExpected = true
                    break
                }
            }

            if (!foundExpected && testType != BACKREF_TEST_MULTIPLE) {
                NAVLogTestFailed(x, 'expected number found', 'no expected number defined')
                continue
            }
        }

        // Test 3: Validate named backreferences
        if (testType == BACKREF_TEST_NAMED) {
            stack_var integer i
            stack_var char foundExpected

            foundExpected = false

            for (i = 1; i <= length_array(REGEX_PARSER_BACKREF_EXPECTED_NAME); i++) {
                if (atoi(REGEX_PARSER_BACKREF_EXPECTED_NAME[i][1]) == x) {
                    stack_var char expectedName[50]
                    expectedName = REGEX_PARSER_BACKREF_EXPECTED_NAME[i][2]

                    if (!NAVAssertTrue('Named backreference should have correct name', ValidateBackrefName(nfa, backrefStateId, expectedName))) {
                        NAVLogTestFailed(x, "'backref name ', expectedName", 'backref state exists')
                        foundExpected = true
                        break
                    }

                    foundExpected = true
                    break
                }
            }

            if (!foundExpected) {
                NAVLogTestFailed(x, 'expected name found', 'no expected name defined')
                continue
            }
        }

        // Test 4: Validate backreference has transition
        if (!NAVAssertTrue('Backreference should have one transition', ValidateBackrefHasTransition(nfa, backrefStateId))) {
            NAVLogTestFailed(x, 'transitionCount = 1', "'transitionCount = ', itoa(nfa.states[backrefStateId].transitionCount)")
            continue
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserBackreferenceErrors
 * @description Test backreference error cases.
 *
 * Tests patterns that should fail to parse due to invalid backreferences:
 * - Backreferences with no corresponding group
 * - Backreferences to non-existent group numbers
 * - Named backreferences to non-existent group names
 * - Zero backreferences (invalid)
 */
define_function TestNAVRegexParserBackreferenceErrors() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Backreference Errors *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_BACKREF_ERROR_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var char shouldFail

        shouldFail = false

        // Tokenize should succeed
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_BACKREF_ERROR_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        // Parse should fail for invalid backreferences
        if (!NAVAssertFalse('Should fail to parse invalid backreference', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse failure', 'parse succeeded (should have failed)')
            continue
        }

        NAVLogTestPassed(x)
    }
}
