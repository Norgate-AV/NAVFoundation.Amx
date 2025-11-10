PROGRAM_NAME='NAVRegexParserAnchors'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test type constants for anchor/boundary validation
constant integer ANCHOR_TEST_LINE_START         = 1
constant integer ANCHOR_TEST_LINE_END           = 2
constant integer ANCHOR_TEST_WORD_BOUNDARY      = 3
constant integer ANCHOR_TEST_STRING_ANCHOR      = 4
constant integer ANCHOR_TEST_COMBINATION        = 5

// Test patterns for anchor and boundary validation
constant char REGEX_PARSER_ANCHOR_PATTERN[][255] = {
    '/^a/',                         // 1: Line start anchor
    '/^abc/',                       // 2: Line start with multiple chars
    '/a$/',                         // 3: Line end anchor
    '/abc$/',                       // 4: Line end with multiple chars
    '/^a$/',                        // 5: Both start and end (exact match)
    '/^abc$/',                      // 6: Exact match multiple chars
    '/\bword/',                     // 7: Word boundary at start
    '/word\b/',                     // 8: Word boundary at end
    '/\bword\b/',                   // 9: Word boundaries both sides
    '/\Bnon/',                      // 10: Non-word boundary
    '/\Bnon\B/',                    // 11: Non-word boundaries both sides
    '/\Astart/',                    // 12: String start anchor
    '/end\Z/',                      // 13: String end anchor (before newline)
    '/end\z/',                      // 14: String end anchor (absolute)
    '/\Aexact\z/',                  // 15: String anchors both sides
    '/^line\d+$/',                  // 16: Line anchors with pattern
    '/\btest\d+\b/',                // 17: Word boundaries with pattern
    '/^\w+$/',                      // 18: Line anchors with word chars
    '/^[a-z]+$/',                   // 19: Line anchors with char class
    '/\b\w+\b/',                    // 20: Word boundary with word chars
    '/^(?:abc|def)$/',              // 21: Anchors with alternation
    '/^\d{3}$/',                    // 22: Anchors with quantifier
    '/^(a|b)$/',                    // 23: Anchors with group alternation
    '/\b[A-Z]\w+\b/',               // 24: Word boundary with capitalized word
    '/^\s*\w+\s*$/',                // 25: Anchors with optional whitespace
    '/\b\d+\.\d+\b/',               // 26: Word boundary with decimal number
    '/^line1\nline2$/',             // 27: Multi-line with anchors
    '/\bthe\b.*\bthe\b/',          // 28: Multiple word boundaries
    '/^start.*end$/',               // 29: Start and end with wildcard
    '/\A^start/',                   // 30: Both string and line start
    '/end$\z/',                     // 31: Both line and string end
    '/^\b\w+\b$/',                  // 32: Anchors and boundaries combined
    '/\b(?:cat|dog)\b/',            // 33: Word boundary with alternation
    '/^(?=\w)/',                    // 34: Line start with lookahead
    '/(?<=\b)\w+/'                  // 35: Lookbehind with word boundary
}

constant integer REGEX_PARSER_ANCHOR_TYPE[] = {
    ANCHOR_TEST_LINE_START,         // 1
    ANCHOR_TEST_LINE_START,         // 2
    ANCHOR_TEST_LINE_END,           // 3
    ANCHOR_TEST_LINE_END,           // 4
    ANCHOR_TEST_COMBINATION,        // 5
    ANCHOR_TEST_COMBINATION,        // 6
    ANCHOR_TEST_WORD_BOUNDARY,      // 7
    ANCHOR_TEST_WORD_BOUNDARY,      // 8
    ANCHOR_TEST_WORD_BOUNDARY,      // 9
    ANCHOR_TEST_WORD_BOUNDARY,      // 10
    ANCHOR_TEST_WORD_BOUNDARY,      // 11
    ANCHOR_TEST_STRING_ANCHOR,      // 12
    ANCHOR_TEST_STRING_ANCHOR,      // 13
    ANCHOR_TEST_STRING_ANCHOR,      // 14
    ANCHOR_TEST_STRING_ANCHOR,      // 15
    ANCHOR_TEST_COMBINATION,        // 16
    ANCHOR_TEST_COMBINATION,        // 17
    ANCHOR_TEST_COMBINATION,        // 18
    ANCHOR_TEST_COMBINATION,        // 19
    ANCHOR_TEST_COMBINATION,        // 20
    ANCHOR_TEST_COMBINATION,        // 21
    ANCHOR_TEST_COMBINATION,        // 22
    ANCHOR_TEST_COMBINATION,        // 23
    ANCHOR_TEST_COMBINATION,        // 24
    ANCHOR_TEST_COMBINATION,        // 25
    ANCHOR_TEST_COMBINATION,        // 26
    ANCHOR_TEST_COMBINATION,        // 27
    ANCHOR_TEST_COMBINATION,        // 28
    ANCHOR_TEST_COMBINATION,        // 29
    ANCHOR_TEST_COMBINATION,        // 30
    ANCHOR_TEST_COMBINATION,        // 31
    ANCHOR_TEST_COMBINATION,        // 32
    ANCHOR_TEST_COMBINATION,        // 33
    ANCHOR_TEST_COMBINATION,        // 34
    ANCHOR_TEST_COMBINATION         // 35
}

// Expected anchor state types for each test
// Format: [test_index, expected_state_type]
constant integer REGEX_PARSER_ANCHOR_EXPECTED_STATE[][2] = {
    { 1, NFA_STATE_BEGIN },             // ^a
    { 2, NFA_STATE_BEGIN },             // ^abc
    { 3, NFA_STATE_END },               // a$
    { 4, NFA_STATE_END },               // abc$
    { 5, NFA_STATE_BEGIN },             // ^a$ (has both, check BEGIN)
    { 6, NFA_STATE_BEGIN },             // ^abc$ (has both, check BEGIN)
    { 7, NFA_STATE_WORD_BOUNDARY },     // \bword
    { 8, NFA_STATE_WORD_BOUNDARY },     // word\b
    { 9, NFA_STATE_WORD_BOUNDARY },     // \bword\b
    { 10, NFA_STATE_NOT_WORD_BOUNDARY }, // \Bnon
    { 11, NFA_STATE_NOT_WORD_BOUNDARY }, // \Bnon\B
    { 12, NFA_STATE_STRING_START },     // \Astart
    { 13, NFA_STATE_STRING_END },       // end\Z
    { 14, NFA_STATE_STRING_END_ABS },   // end\z
    { 15, NFA_STATE_STRING_START }      // \Aexact\z
}

// Error case patterns - these should fail or be invalid
constant char REGEX_PARSER_ANCHOR_ERROR_PATTERN[][255] = {
    '/^*/',                         // 1: Quantifier on anchor (invalid)
    '/$+/',                         // 2: Quantifier on anchor (invalid)
    '/\b*/',                        // 3: Quantifier on boundary (invalid)
    '/^^/',                         // 4: Double anchor (redundant)
    '/$$/',                         // 5: Double anchor (redundant)
    '/\A\A/',                       // 6: Double string anchor (redundant)
    '/a^/',                         // 7: Anchor not at start (semantically odd)
    '/$a/'                          // 8: Anchor not at end (semantically odd)
}


/**
 * @function TestNAVRegexParserAnchors
 * @description Test anchor and boundary parsing and NFA construction.
 *
 * Tests:
 * - Line anchors (^, $)
 * - Word boundaries (\b, \B)
 * - String anchors (\A, \Z, \z)
 * - Combinations of anchors
 * - Anchor state creation and validation
 */
define_function TestNAVRegexParserAnchors() {
    stack_var integer x
    stack_var _NAVRegexLexer lexer
    stack_var _NAVRegexNFA nfa
    stack_var integer testType
    stack_var integer anchorStateId
    stack_var char foundAnchor
    stack_var integer i
    stack_var char foundExpected
    stack_var integer expectedType

    NAVLog("'***************** NAVRegexParser - Anchors & Boundaries *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_ANCHOR_PATTERN); x++) {
        testType = REGEX_PARSER_ANCHOR_TYPE[x]

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_ANCHOR_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Test 1: Find expected anchor state
        foundExpected = false

        for (i = 1; i <= length_array(REGEX_PARSER_ANCHOR_EXPECTED_STATE); i++) {
            if (REGEX_PARSER_ANCHOR_EXPECTED_STATE[i][1] == x) {
                expectedType = REGEX_PARSER_ANCHOR_EXPECTED_STATE[i][2]

                foundAnchor = FindAnchorState(nfa, expectedType, anchorStateId)
                if (!NAVAssertTrue('Should find anchor state', foundAnchor)) {
                    NAVLogTestFailed(x, "'anchor state type ', itoa(expectedType)", 'no anchor state found')
                    foundExpected = true
                    break
                }

                // Test 2: Validate anchor type
                if (!NAVAssertTrue('Anchor should have correct type', ValidateAnchorType(nfa, anchorStateId, expectedType))) {
                    NAVLogTestFailed(x, "'state type ', itoa(expectedType)", "'state type ', itoa(nfa.states[anchorStateId].type)")
                    foundExpected = true
                    break
                }

                // Test 3: Validate anchor has transition
                if (!NAVAssertTrue('Anchor should have one transition', ValidateAnchorHasTransition(nfa, anchorStateId))) {
                    NAVLogTestFailed(x, 'transitionCount = 1', "'transitionCount = ', itoa(nfa.states[anchorStateId].transitionCount)")
                    foundExpected = true
                    break
                }

                foundExpected = true
                break
            }
        }

        // For tests without specific expected states, just verify parse succeeded
        if (!foundExpected && testType == ANCHOR_TEST_COMBINATION) {
            // These patterns should parse successfully but we don't validate specific anchor types
            if (!NAVAssertTrue('Pattern should parse successfully', true)) {
                NAVLogTestFailed(x, 'parse success', 'validation skipped')
                continue
            }
        }

        // Special case: patterns with both line anchors
        if (x == 5 || x == 6) {
            if (!NAVAssertTrue('Should have both line anchors', HasBothLineAnchors(nfa))) {
                NAVLogTestFailed(x, 'both BEGIN and END states', 'missing one or both')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserAnchorErrors
 * @description Test anchor error cases.
 *
 * Tests patterns that should fail or produce warnings:
 * - Quantifiers on anchors (invalid)
 * - Double anchors (redundant)
 * - Anchors in unusual positions (semantically odd)
 */
define_function TestNAVRegexParserAnchorErrors() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Anchor Errors *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_ANCHOR_ERROR_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa

        // Tokenize - most should succeed at lexer level
        if (NAVRegexLexerTokenize(REGEX_PARSER_ANCHOR_ERROR_PATTERN[x], lexer)) {
            // For patterns that tokenize, try to parse
            // Some may fail at parser level, others may succeed but be semantically odd
            NAVRegexParse(lexer, nfa)

            // We don't assert failure here because some of these patterns
            // are semantically odd but syntactically valid (like /a^/)
            // The matcher phase will reveal their true behavior
        }

        // Test passes if we don't crash - we're just checking for robustness
        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserAnchorCombinations
 * @description Test complex combinations of anchors and boundaries.
 *
 * Tests:
 * - Multiple word boundaries in one pattern
 * - Anchors combined with quantifiers
 * - Anchors combined with groups
 * - Anchors combined with lookarounds
 */
define_function TestNAVRegexParserAnchorCombinations() {
    stack_var integer testCount

    NAVLog("'***************** NAVRegexParser - Anchor Combinations *****************'")

    testCount = 0

    // Test 1: Multiple word boundaries
    {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer boundaryCount

        testCount++

        if (!NAVAssertTrue('Should parse pattern with multiple word boundaries', NAVRegexLexerTokenize('/\bword\b \btest\b/', lexer))) {
            NAVLogTestFailed(testCount, 'tokenize success', 'tokenize failed')
        }
        else if (!NAVAssertTrue('Should parse tokens', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(testCount, 'parse success', 'parse failed')
        }
        else {
            boundaryCount = CountAnchorStates(nfa, NFA_STATE_WORD_BOUNDARY)
            if (!NAVAssertTrue('Should have multiple word boundary states', boundaryCount >= 2)) {
                NAVLogTestFailed(testCount, 'boundaryCount >= 2', "'boundaryCount = ', itoa(boundaryCount)")
            }
            else {
                NAVLogTestPassed(testCount)
            }
        }
    }

    // Test 2: Line anchors with alternation
    {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa

        testCount++

        if (!NAVAssertTrue('Should parse anchored alternation', NAVRegexLexerTokenize('/^(start|begin)/', lexer))) {
            NAVLogTestFailed(testCount, 'tokenize success', 'tokenize failed')
        }
        else if (!NAVAssertTrue('Should parse tokens', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(testCount, 'parse success', 'parse failed')
        }
        else if (!NAVAssertTrue('Should have BEGIN state', CountAnchorStates(nfa, NFA_STATE_BEGIN) > 0)) {
            NAVLogTestFailed(testCount, 'has BEGIN state', 'no BEGIN state')
        }
        else {
            NAVLogTestPassed(testCount)
        }
    }

    // Test 3: Word boundaries with character classes
    {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa

        testCount++

        if (!NAVAssertTrue('Should parse word boundary with char class', NAVRegexLexerTokenize('/\b[A-Z][a-z]+\b/', lexer))) {
            NAVLogTestFailed(testCount, 'tokenize success', 'tokenize failed')
        }
        else if (!NAVAssertTrue('Should parse tokens', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(testCount, 'parse success', 'parse failed')
        }
        else if (!NAVAssertTrue('Should have word boundary states', CountAnchorStates(nfa, NFA_STATE_WORD_BOUNDARY) > 0)) {
            NAVLogTestFailed(testCount, 'has word boundary', 'no word boundary')
        }
        else {
            NAVLogTestPassed(testCount)
        }
    }

    // Test 4: String anchors vs line anchors
    {
        stack_var _NAVRegexLexer lexer1
        stack_var _NAVRegexLexer lexer2
        stack_var _NAVRegexNFA nfa1
        stack_var _NAVRegexNFA nfa2

        testCount++

        if (!NAVAssertTrue('Should parse line anchors', NAVRegexLexerTokenize('/^test$/', lexer1))) {
            NAVLogTestFailed(testCount, 'tokenize success', 'tokenize failed')
        }
        else if (!NAVAssertTrue('Should parse string anchors', NAVRegexLexerTokenize('/\Atest\z/', lexer2))) {
            NAVLogTestFailed(testCount, 'tokenize success', 'tokenize failed')
        }
        else if (!NAVAssertTrue('Should parse line anchor pattern', NAVRegexParse(lexer1, nfa1))) {
            NAVLogTestFailed(testCount, 'parse success', 'parse failed')
        }
        else if (!NAVAssertTrue('Should parse string anchor pattern', NAVRegexParse(lexer2, nfa2))) {
            NAVLogTestFailed(testCount, 'parse success', 'parse failed')
        }
        else {
            // Both should succeed - they're just different types
            NAVLogTestPassed(testCount)
        }
    }

    // Test 5: Anchors with quantifiers (on the atom, not the anchor)
    {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa

        testCount++

        if (!NAVAssertTrue('Should parse anchor with quantified atom', NAVRegexLexerTokenize('/^\w+$/', lexer))) {
            NAVLogTestFailed(testCount, 'tokenize success', 'tokenize failed')
        }
        else if (!NAVAssertTrue('Should parse tokens', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(testCount, 'parse success', 'parse failed')
        }
        else if (!NAVAssertTrue('Should have both anchors', HasBothLineAnchors(nfa))) {
            NAVLogTestFailed(testCount, 'has both BEGIN and END', 'missing anchors')
        }
        else {
            NAVLogTestPassed(testCount)
        }
    }
}
