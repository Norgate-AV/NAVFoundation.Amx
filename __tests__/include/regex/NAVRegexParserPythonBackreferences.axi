PROGRAM_NAME='NAVRegexParserPythonBackreferences'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexParserTestHelpers.axi'

DEFINE_CONSTANT

// Test type constants for Python-style backreference validation
constant integer PYTHON_BACKREF_TEST_BASIC          = 1
constant integer PYTHON_BACKREF_TEST_MULTIPLE       = 2
constant integer PYTHON_BACKREF_TEST_MIXED          = 3
constant integer PYTHON_BACKREF_TEST_COMPLEX        = 4

// Test patterns for Python-style named backreference validation
// Testing (?P=name) syntax specifically
constant char REGEX_PARSER_PYTHON_BACKREF_PATTERN[][255] = {
    '/(?P<word>a)(?P=word)/',                           // 1: Basic Python-style backref
    '/(?P<name>test)(?P=name)/',                        // 2: Multi-char with Python backref
    '/(?P<first>a)(?P<second>b)(?P=first)(?P=second)/', // 3: Multiple groups, two Python backrefs
    '/(?P<first>a)(?P<second>b)(?P=second)(?P=first)/', // 4: Multiple groups, two Python backrefs reversed
    '/(?P<a>x)(?P<b>y)(?P=a)(?P=b)/',                   // 5: Two Python backrefs
    '/(?P<word>a)(?P=word)(?P=word)/',                  // 6: Same Python backref multiple times
    '/(?P<outer>(?P<inner>a))(?P=inner)/',              // 7: Nested groups with Python backref to inner
    '/(?P<outer>(?P<inner>a))(?P=outer)/',              // 8: Nested groups with Python backref to outer
    '/(?P<char>\w)(?P=char)+/',                         // 9: Python backref with quantifier
    '/(?P<digit>\d)(?P=digit)*/',                       // 10: Python backref with * quantifier
    '/(?P<letter>[a-z])(?P=letter)/',                   // 11: Python backref with character class
    '/(?P<tag><\w+>).*?(?P=tag)/',                      // 12: Python backref for HTML-like tags
    '/(?P<quote>[''"]).*?(?P=quote)/',                    // 13: Python backref for quote matching
    '/(?P<word>\w+)\s+(?P=word)/',                      // 14: Python backref with whitespace
    '/(?P<a>.)(?P<b>.)(?P=b)(?P=a)/',                   // 15: Python palindrome pattern (abba)
    '/(?<word>a)(?P=word)/',                            // 16: PCRE group with Python backref
    '/(?''word''a)(?P=word)/',                            // 17: PCRE quote group with Python backref
    '/(?P<name>a)\k<name>(?P=name)/',                   // 18: Mixed PCRE and Python backrefs
    '/(a)(?P<named>b)(?P=named)\1/',                    // 19: Numbered and Python named backref
    '/(?P<first>a)(?P<second>b)(?P=first)(?P=second)/', // 20: Multiple different Python backrefs
    '/(?P<word>a)(?:(?P=word))/',                       // 21: Python backref in non-capturing group
    '/(?P<word>a)(?=(?P=word))/',                       // 22: Python backref in lookahead
    '/(?P<word>test)(?P=word){2}/',                     // 23: Python backref with bounded quantifier
    '/(?P<x>a|b)(?P=x)/',                               // 24: Python backref with alternation in group
    '/(?P<outer>(?P<inner>a)(?P=inner))(?P=outer)/'     // 25: Complex nested with multiple Python backrefs
}

// Test type for each pattern
constant integer REGEX_PARSER_PYTHON_BACKREF_TYPE[] = {
    PYTHON_BACKREF_TEST_BASIC,          // 1
    PYTHON_BACKREF_TEST_BASIC,          // 2
    PYTHON_BACKREF_TEST_MULTIPLE,       // 3
    PYTHON_BACKREF_TEST_MULTIPLE,       // 4
    PYTHON_BACKREF_TEST_MULTIPLE,       // 5
    PYTHON_BACKREF_TEST_BASIC,          // 6
    PYTHON_BACKREF_TEST_COMPLEX,        // 7
    PYTHON_BACKREF_TEST_COMPLEX,        // 8
    PYTHON_BACKREF_TEST_BASIC,          // 9
    PYTHON_BACKREF_TEST_BASIC,          // 10
    PYTHON_BACKREF_TEST_BASIC,          // 11
    PYTHON_BACKREF_TEST_BASIC,          // 12
    PYTHON_BACKREF_TEST_BASIC,          // 13
    PYTHON_BACKREF_TEST_BASIC,          // 14
    PYTHON_BACKREF_TEST_MULTIPLE,       // 15
    PYTHON_BACKREF_TEST_MIXED,          // 16
    PYTHON_BACKREF_TEST_MIXED,          // 17
    PYTHON_BACKREF_TEST_MIXED,          // 18
    PYTHON_BACKREF_TEST_MIXED,          // 19
    PYTHON_BACKREF_TEST_MULTIPLE,       // 20
    PYTHON_BACKREF_TEST_BASIC,          // 21
    PYTHON_BACKREF_TEST_BASIC,          // 22
    PYTHON_BACKREF_TEST_BASIC,          // 23
    PYTHON_BACKREF_TEST_BASIC,          // 24
    PYTHON_BACKREF_TEST_COMPLEX         // 25
}

// Expected group numbers that Python backreferences should resolve to
// Format: [test_index][occurrence] = group_number
// For tests with single backref, only first element is used
constant integer REGEX_PARSER_PYTHON_BACKREF_EXPECTED_GROUP[][3] = {
    { 1, 0, 0 },        // 1: (?P=word) -> group 1
    { 1, 0, 0 },        // 2: (?P=name) -> group 1
    { 1, 2, 0 },        // 3: (?P=first) -> group 1, (?P=second) -> group 2
    { 2, 1, 0 },        // 4: (?P=second) -> group 2, (?P=first) -> group 1
    { 1, 2, 0 },        // 5: (?P=a) -> group 1, (?P=b) -> group 2
    { 1, 1, 0 },        // 6: (?P=word) twice -> group 1 both times
    { 2, 0, 0 },        // 7: (?P=inner) -> group 2
    { 1, 0, 0 },        // 8: (?P=outer) -> group 1
    { 1, 0, 0 },        // 9: (?P=char) -> group 1
    { 1, 0, 0 },        // 10: (?P=digit) -> group 1
    { 1, 0, 0 },        // 11: (?P=letter) -> group 1
    { 1, 0, 0 },        // 12: (?P=tag) -> group 1
    { 1, 0, 0 },        // 13: (?P=quote) -> group 1
    { 1, 0, 0 },        // 14: (?P=word) -> group 1
    { 2, 1, 0 },        // 15: (?P=b) -> group 2, (?P=a) -> group 1
    { 1, 0, 0 },        // 16: (?P=word) -> group 1
    { 1, 0, 0 },        // 17: (?P=word) -> group 1
    { 1, 1, 0 },        // 18: \k<name> and (?P=name) -> group 1
    { 2, 1, 0 },        // 19: (?P=named) -> group 2, \1 -> group 1
    { 1, 2, 0 },        // 20: (?P=first) -> 1, (?P=second) -> 2
    { 1, 0, 0 },        // 21: (?P=word) in non-capturing group -> group 1
    { 1, 0, 0 },        // 22: (?P=word) in lookahead -> group 1
    { 1, 0, 0 },        // 23: (?P=word) -> group 1
    { 1, 0, 0 },        // 24: (?P=x) -> group 1
    { 2, 1, 2 }         // 25: (?P=inner) -> 2, (?P=outer) -> 1, second (?P=inner) -> 2
}

// Group names for validation
constant char REGEX_PARSER_PYTHON_BACKREF_GROUP_NAMES[][3][50] = {
    { 'word', '', '' },                 // 1
    { 'name', '', '' },                 // 2
    { 'first', 'second', '' },          // 3
    { 'first', 'second', '' },          // 4
    { 'a', 'b', '' },                   // 5
    { 'word', '', '' },                 // 6
    { 'outer', 'inner', '' },           // 7
    { 'outer', 'inner', '' },           // 8
    { 'char', '', '' },                 // 9
    { 'digit', '', '' },                // 10
    { 'letter', '', '' },               // 11
    { 'tag', '', '' },                  // 12
    { 'quote', '', '' },                // 13
    { 'word', '', '' },                 // 14
    { 'a', 'b', '' },                   // 15
    { 'word', '', '' },                 // 16
    { 'word', '', '' },                 // 17
    { 'name', '', '' },                 // 18
    { '', 'named', '' },                // 19: group 1 unnamed, group 2 named
    { 'first', 'second', '' },          // 20
    { 'word', '', '' },                 // 21
    { 'word', '', '' },                 // 22
    { 'word', '', '' },                 // 23
    { 'x', '', '' },                    // 24
    { 'outer', 'inner', '' }            // 25
}


/**
 * @function TestNAVRegexParserPythonBackreferences
 * @public
 * @description Validates Python-style named backreference (?P=name) handling in parser.
 *
 * Critical properties for Python-style backreferences:
 * 1. (?P=name) syntax is recognized and tokenized as REGEX_TOKEN_BACKREF_NAMED
 * 2. Parser resolves (?P=name) to the correct group number
 * 3. NFA contains NFA_STATE_BACKREF with correct groupNumber
 * 4. Works with (?P<name>...) groups (Python-style)
 * 5. Works with (?<name>...) groups (PCRE-style)
 * 6. Works with (?'name'...) groups (PCRE quotes-style)
 * 7. Can mix (?P=name) with \k<name> syntax in same pattern
 * 8. Can mix with numbered backreferences
 * 9. Multiple (?P=name) backreferences in one pattern work correctly
 * 10. Nested groups with Python backreferences maintain correct resolution
 *
 * Why this matters:
 * - Provides Python regex compatibility
 * - Same backend as \k<name> (REGEX_TOKEN_BACKREF_NAMED)
 * - Must resolve names to group numbers for matcher
 * - Common in Python-based systems migrating patterns
 *
 * Example: /(?P<word>test)(?P=word)/ should:
 * - Create capture group 1 named "word"
 * - Create backreference state referencing group 1
 * - Matcher will compare captured content from group 1
 */
define_function TestNAVRegexParserPythonBackreferences() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Python-Style Backreferences (?P=name) *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_PYTHON_BACKREF_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer testType
        stack_var integer backrefStateId
        stack_var char foundBackref
        stack_var integer backrefCount
        stack_var integer i

        testType = REGEX_PARSER_PYTHON_BACKREF_TYPE[x]

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_PYTHON_BACKREF_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Test 1: Find backreference state(s)
        backrefCount = CountBackreferences(nfa)
        if (!NAVAssertTrue('Should find at least one backreference state', backrefCount > 0)) {
            NAVLogTestFailed(x, 'backreference state found', 'no backreference state')
            continue
        }

        // Test 2: For basic tests, validate the backreference resolves to correct group
        if (testType == PYTHON_BACKREF_TEST_BASIC) {
            stack_var integer expectedGroup

            expectedGroup = REGEX_PARSER_PYTHON_BACKREF_EXPECTED_GROUP[x][1]

            if (expectedGroup > 0) {
                foundBackref = FindBackreferenceState(nfa, backrefStateId)

                if (!NAVAssertTrue('Should find backreference state', foundBackref)) {
                    NAVLogTestFailed(x, 'backreference state found', 'no backreference state')
                    continue
                }

                if (!NAVAssertIntegerEqual('Backreference should resolve to correct group number', expectedGroup, nfa.states[backrefStateId].groupNumber)) {
                    NAVLogTestFailed(x, "'Python backref resolves to group ', itoa(expectedGroup)", "'resolves to group ', itoa(nfa.states[backrefStateId].groupNumber)")
                    continue
                }
            }
        }

        // Test 3: For multiple backrefs, validate all resolve correctly
        if (testType == PYTHON_BACKREF_TEST_MULTIPLE) {
            stack_var integer backrefStates[10]
            stack_var integer backrefStateCount
            stack_var integer j
            stack_var char allValid

            backrefStateCount = 0

            // Find all backreference states
            for (j = 1; j <= nfa.stateCount; j++) {
                if (nfa.states[j].type == NFA_STATE_BACKREF) {
                    backrefStateCount++
                    if (backrefStateCount <= 10) {
                        backrefStates[backrefStateCount] = j
                    }
                }
            }

            if (!NAVAssertTrue('Should find multiple backreference states', backrefStateCount >= 2)) {
                NAVLogTestFailed(x, 'multiple backref states', "itoa(backrefStateCount), ' backref state(s)'")
                continue
            }

            // Validate each backreference
            allValid = true
            for (j = 1; j <= backrefStateCount; j++) {
                if (j <= 3 && REGEX_PARSER_PYTHON_BACKREF_EXPECTED_GROUP[x][j] > 0) {
                    if (!NAVAssertIntegerEqual("'Backreference ', itoa(j), ' should resolve to group ', itoa(REGEX_PARSER_PYTHON_BACKREF_EXPECTED_GROUP[x][j])", REGEX_PARSER_PYTHON_BACKREF_EXPECTED_GROUP[x][j], nfa.states[backrefStates[j]].groupNumber)) {
                        NAVLogTestFailed(x, "'backref ', itoa(j), ' to group ', itoa(REGEX_PARSER_PYTHON_BACKREF_EXPECTED_GROUP[x][j])", "'backref ', itoa(j), ' to group ', itoa(nfa.states[backrefStates[j]].groupNumber)")
                        allValid = false
                        break
                    }
                }
            }

            if (!allValid) {
                continue
            }
        }

        // Test 4: For mixed tests, verify Python backref works with other group styles
        if (testType == PYTHON_BACKREF_TEST_MIXED) {
            foundBackref = FindBackreferenceState(nfa, backrefStateId)

            if (!NAVAssertTrue('Should find backreference state in mixed pattern', foundBackref)) {
                NAVLogTestFailed(x, 'backreference state found', 'no backreference state')
                continue
            }

            // Verify backreference has valid group number (>= 1)
            if (!NAVAssertTrue('Mixed pattern backreference should have valid group number', nfa.states[backrefStateId].groupNumber >= 1)) {
                NAVLogTestFailed(x, 'valid group number (>= 1)', "itoa(nfa.states[backrefStateId].groupNumber)")
                continue
            }

            // Verify group number is within capture group count
            if (!NAVAssertTrue('Group number should be within capture group count', nfa.states[backrefStateId].groupNumber <= nfa.captureGroupCount)) {
                NAVLogTestFailed(x, "'group <= ', itoa(nfa.captureGroupCount)", "'group = ', itoa(nfa.states[backrefStateId].groupNumber)")
                continue
            }
        }

        // Test 5: Verify group names are preserved (not affected by backreferences)
        for (i = 1; i <= nfa.captureGroupCount; i++) {
            stack_var char expectedName[50]

            expectedName = REGEX_PARSER_PYTHON_BACKREF_GROUP_NAMES[x][i]

            if (expectedName != '') {
                if (!NAVAssertTrue('Named groups should preserve names', ValidateGroupName(nfa, i, expectedName))) {
                    NAVLogTestFailed(x, "'group ', itoa(i), ' name=', expectedName", 'incorrect or missing name')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
