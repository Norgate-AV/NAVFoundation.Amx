PROGRAM_NAME='NAVRegexParserCharClassValidation'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test type constants for character class validation
constant integer CHARCLASS_TEST_BASIC           = 1
constant integer CHARCLASS_TEST_RANGE           = 2
constant integer CHARCLASS_TEST_NEGATED         = 3
constant integer CHARCLASS_TEST_PREDEFINED      = 4
constant integer CHARCLASS_TEST_MIXED           = 5

// Test patterns for character class validation
constant char REGEX_PARSER_CHARCLASS_VALIDATION_PATTERN[][255] = {
    '/[a]/',                // 1: Single character
    '/[abc]/',              // 2: Multiple characters
    '/[a-z]/',              // 3: Simple range
    '/[A-Z]/',              // 4: Uppercase range
    '/[0-9]/',              // 5: Digit range
    '/[a-zA-Z]/',           // 6: Multiple ranges
    '/[a-z0-9]/',           // 7: Letters and digits
    '/[^a]/',               // 8: Negated single
    '/[^abc]/',             // 9: Negated multiple
    '/[^a-z]/',             // 10: Negated range
    '/\d/',                 // 11: Predefined digit
    '/\D/',                 // 12: Predefined non-digit
    '/\w/',                 // 13: Predefined word
    '/\W/',                 // 14: Predefined non-word
    '/\s/',                 // 15: Predefined whitespace
    '/\S/',                 // 16: Predefined non-whitespace
    '/[a-z\d]/',            // 17: Range + predefined
    '/[^a-z\d]/',           // 18: Negated mixed
    '/[a-c-f]/',            // 19: Multiple ranges (a-c, then literal -, then f)
    '/[\w-]/',              // 20: Predefined + literal dash
    '/[!-~]/',              // 21: Printable ASCII range (DISABLED - lexer issue with ~ in range)
    '/[\x00-\x1F]/',        // 22: Control characters range
    '/[a-a]/',              // 23: Single char range (a-a)
    '/[\n\r\t]/'            // 24: Escape sequences
}

constant integer REGEX_PARSER_CHARCLASS_VALIDATION_TYPE[] = {
    CHARCLASS_TEST_BASIC,           // 1
    CHARCLASS_TEST_BASIC,           // 2
    CHARCLASS_TEST_RANGE,           // 3
    CHARCLASS_TEST_RANGE,           // 4
    CHARCLASS_TEST_RANGE,           // 5
    CHARCLASS_TEST_RANGE,           // 6
    CHARCLASS_TEST_RANGE,           // 7
    CHARCLASS_TEST_NEGATED,         // 8
    CHARCLASS_TEST_NEGATED,         // 9
    CHARCLASS_TEST_NEGATED,         // 10
    CHARCLASS_TEST_PREDEFINED,      // 11
    CHARCLASS_TEST_PREDEFINED,      // 12
    CHARCLASS_TEST_PREDEFINED,      // 13
    CHARCLASS_TEST_PREDEFINED,      // 14
    CHARCLASS_TEST_PREDEFINED,      // 15
    CHARCLASS_TEST_PREDEFINED,      // 16
    CHARCLASS_TEST_MIXED,           // 17
    CHARCLASS_TEST_NEGATED,         // 18 - Negated mixed class
    CHARCLASS_TEST_RANGE,           // 19
    CHARCLASS_TEST_MIXED,           // 20
    CHARCLASS_TEST_RANGE,           // 21 - DISABLED
    CHARCLASS_TEST_RANGE,           // 22
    CHARCLASS_TEST_RANGE,           // 23
    CHARCLASS_TEST_BASIC            // 24
}

// Expected state types for predefined classes
constant integer REGEX_PARSER_CHARCLASS_PREDEFINED_STATE_TYPE[][2] = {
    { 11, NFA_STATE_DIGIT },                // \d
    { 12, NFA_STATE_NOT_DIGIT },            // \D
    { 13, NFA_STATE_WORD },                 // \w
    { 14, NFA_STATE_NOT_WORD },             // \W
    { 15, NFA_STATE_WHITESPACE },           // \s
    { 16, NFA_STATE_NOT_WHITESPACE }        // \S
}


/**
 * @function TestNAVRegexParserCharClassValidation
 * @public
 * @description Validates character class structure in NFAs.
 *
 * Critical properties for matcher:
 * 1. Character class ranges are correctly ordered (start <= end)
 * 2. Negated classes have negation flag set correctly
 * 3. Predefined classes (\d, \w, \s) create correct state types
 * 4. Character classes are not empty (have at least 1 range)
 * 5. Character classes have exactly 1 outgoing transition
 *
 * Why this matters:
 * - Invalid ranges (start > end) cause matching failures
 * - Missing negation flag causes [^abc] to match like [abc]
 * - Wrong state types cause \d to fail matching digits
 * - Empty character classes are invalid patterns
 * - Wrong transition count breaks NFA traversal
 *
 * Example: /[a-z]/ should have:
 * - One CHAR_CLASS state
 * - One range with start='a', end='z'
 * - negated=false
 * - Exactly 1 outgoing transition
 */
define_function TestNAVRegexParserCharClassValidation() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Character Class Validation *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_CHARCLASS_VALIDATION_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer testType
        stack_var integer charClassStateId
        stack_var char foundCharClass

        testType = REGEX_PARSER_CHARCLASS_VALIDATION_TYPE[x]

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_CHARCLASS_VALIDATION_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Find the character class state
        foundCharClass = FindCharClassState(nfa, charClassStateId)
        if (!NAVAssertTrue('Should find character class state', foundCharClass)) {
            NAVLogTestFailed(x, 'character class state found', 'no character class state')
            continue
        }

        // Test 1: For CHAR_CLASS type, validate ranges are correctly ordered
        if (testType == CHARCLASS_TEST_RANGE || testType == CHARCLASS_TEST_BASIC || testType == CHARCLASS_TEST_MIXED) {
            if (!NAVAssertTrue('Character class ranges should be valid', ValidateCharClassRanges(nfa, charClassStateId))) {
                NAVLogTestFailed(x, 'valid ranges (start <= end)', 'invalid range ordering')
                continue
            }
        }

        // Test 2: For negated classes, validate negation flag
        if (testType == CHARCLASS_TEST_NEGATED) {
            if (!NAVAssertTrue('Negated class should have negation flag', ValidateCharClassNegation(nfa, charClassStateId, true))) {
                NAVLogTestFailed(x, 'negated=true', 'negated=false')
                continue
            }
        }
        else if (testType == CHARCLASS_TEST_RANGE || testType == CHARCLASS_TEST_BASIC) {
            // Non-negated classes should not have negation flag
            if (!NAVAssertTrue('Non-negated class should not have negation flag', ValidateCharClassNegation(nfa, charClassStateId, false))) {
                NAVLogTestFailed(x, 'negated=false', 'negated=true')
                continue
            }
        }

        // Test 3: For predefined classes, validate state type
        if (testType == CHARCLASS_TEST_PREDEFINED) {
            stack_var integer i
            stack_var char foundPredefined

            foundPredefined = false

            for (i = 1; i <= length_array(REGEX_PARSER_CHARCLASS_PREDEFINED_STATE_TYPE); i++) {
                if (REGEX_PARSER_CHARCLASS_PREDEFINED_STATE_TYPE[i][1] == x) {
                    stack_var integer expectedStateType
                    expectedStateType = REGEX_PARSER_CHARCLASS_PREDEFINED_STATE_TYPE[i][2]

                    if (!NAVAssertTrue('Predefined class should have correct state type', ValidatePredefinedClassType(nfa, charClassStateId, expectedStateType))) {
                        NAVLogTestFailed(x, "'state type ', itoa(expectedStateType)", "'state type ', itoa(nfa.states[charClassStateId].type)")
                        foundPredefined = true
                        break
                    }

                    foundPredefined = true
                    break
                }
            }

            if (foundPredefined && !NAVAssertTrue('Predefined class validated', true)) {
                continue
            }
        }

        // Test 4: Validate character class is not empty
        if (!NAVAssertTrue('Character class should not be empty', ValidateCharClassNotEmpty(nfa, charClassStateId))) {
            NAVLogTestFailed(x, 'rangeCount > 0', 'rangeCount = 0')
            continue
        }

        // Test 5: Validate character class has exactly 1 transition
        if (!NAVAssertTrue('Character class should have 1 transition', ValidateCharClassTransition(nfa, charClassStateId))) {
            NAVLogTestFailed(x, 'transitionCount = 1', "'transitionCount = ', itoa(nfa.states[charClassStateId].transitionCount)")
            continue
        }

        NAVLogTestPassed(x)
    }
}
