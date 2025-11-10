PROGRAM_NAME='NAVRegexParserIntegration'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexParserTestHelpers.axi'

DEFINE_CONSTANT

// Test patterns for end-to-end parsing (lexer + parser)
constant char REGEX_PARSER_INTEGRATION_PATTERN_TEST[][255] = {
    // Simple literals
    '/a/',              // 1: Single character
    '/abc/',            // 2: Multiple characters
    '/hello/',          // 3: Word

    // Predefined classes
    '/\d/',             // 4: Digit
    '/\w/',             // 5: Word character
    '/\s/',             // 6: Whitespace
    '/\D/',             // 7: Not digit
    '/\W/',             // 8: Not word
    '/\S/',             // 9: Not whitespace

    // Dot
    '/./',              // 10: Single dot
    '/.../',            // 11: Multiple dots

    // Anchors
    '/^a/',             // 12: Start anchor
    '/a$/',             // 13: End anchor
    '/^abc$/',          // 14: Both anchors
    '/\ba/',            // 15: Word boundary
    '/a\b/',            // 16: Word boundary at end

    // Quantifiers
    '/a*/',             // 17: Zero or more
    '/a+/',             // 18: One or more
    '/a?/',             // 19: Zero or one
    '/a{3}/',           // 20: Exactly 3
    '/a{2,5}/',         // 21: Between 2 and 5
    '/a{3,}/',          // 22: At least 3

    // Character classes
    '/[abc]/',          // 23: Simple class
    '/[a-z]/',          // 24: Range
    '/[^abc]/',         // 25: Negated class
    '/[a-zA-Z]/',       // 26: Multiple ranges

    // Combinations
    '/\d+/',            // 27: Digit one or more
    '/\w*/',            // 28: Word zero or more
    '/[a-z]+/',         // 29: Lowercase letters one or more
    '/^\d{3}$/'         // 30: Exactly 3 digits with anchors
}

// Expected minimum state counts (states created for each pattern)
constant integer REGEX_PARSER_INTEGRATION_EXPECTED_MIN_STATES[] = {
    2,  // 1: a - 1 literal + 1 start
    4,  // 2: abc - 3 literals + 1 start
    6,  // 3: hello - 5 literals + 1 start

    2,  // 4: \d - 1 digit state + 1 start
    2,  // 5: \w - 1 word state + 1 start
    2,  // 6: \s - 1 whitespace + 1 start
    2,  // 7: \D - 1 not digit + 1 start
    2,  // 8: \W - 1 not word + 1 start
    2,  // 9: \S - 1 not whitespace + 1 start

    2,  // 10: . - 1 dot + 1 start
    4,  // 11: ... - 3 dots + 1 start

    3,  // 12: ^a - 1 anchor + 1 literal + 1 start
    3,  // 13: a$ - 1 literal + 1 anchor + 1 start
    5,  // 14: ^abc$ - 1 anchor + 3 literals + 1 anchor + 1 start (approx)
    3,  // 15: \ba - 1 boundary + 1 literal + 1 start
    3,  // 16: a\b - 1 literal + 1 boundary + 1 start

    3,  // 17: a* - creates split state + literal + merge
    3,  // 18: a+ - literal + split state + merge
    3,  // 19: a? - creates split state + literal + merge
    4,  // 20: a{3} - 3 copies of literal + 1 start
    6,  // 21: a{2,5} - multiple states for bounded quantifier
    4,  // 22: a{3,} - at least 3 copies + loop structure

    2,  // 23: [abc] - 1 char class + 1 start
    2,  // 24: [a-z] - 1 char class + 1 start
    2,  // 25: [^abc] - 1 negated class + 1 start
    2,  // 26: [a-zA-Z] - 1 char class + 1 start

    3,  // 27: \d+ - digit + quantifier states
    3,  // 28: \w* - word + quantifier states
    3,  // 29: [a-z]+ - char class + quantifier states
    5   // 30: ^\d{3}$ - anchor + 3 digits + anchor + start
}


/**
 * @function TestNAVRegexParserIntegration
 * @public
 * @description Tests end-to-end parsing from pattern string to NFA.
 *
 * Validates:
 * - Pattern can be tokenized by lexer
 * - Tokens can be parsed into NFA
 * - NFA has valid structure (start state, states, transitions)
 * - State count is reasonable for the pattern
 */
define_function TestNAVRegexParserIntegration() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Integration (Lexer + Parser) *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_INTEGRATION_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa

        // Tokenize the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_INTEGRATION_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        // Parse tokens into NFA
        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Verify NFA has states
        if (!NAVAssertTrue('NFA should have states', nfa.stateCount > 0)) {
            NAVLogTestFailed(x, '>0 states', itoa(nfa.stateCount))
            continue
        }

        // Verify NFA has start state
        if (!NAVAssertTrue('NFA should have valid start state', nfa.startState > 0 && nfa.startState <= nfa.stateCount)) {
            NAVLogTestFailed(x, 'valid start state', itoa(nfa.startState))
            continue
        }

        // Verify state count is at least the minimum expected
        if (!NAVAssertTrue('NFA should have minimum states', nfa.stateCount >= REGEX_PARSER_INTEGRATION_EXPECTED_MIN_STATES[x])) {
            NAVLogTestFailed(x, itoa(REGEX_PARSER_INTEGRATION_EXPECTED_MIN_STATES[x]), itoa(nfa.stateCount))
            continue
        }

        // Verify NFA has a match state (last state created should be accept/match)
        // The accept state is created at the end of parsing
        if (nfa.stateCount > 0) {
            if (!NAVAssertIntegerEqual('Last state should be MATCH state', NFA_STATE_MATCH, nfa.states[nfa.stateCount].type)) {
                NAVLogTestFailed(x, 'MATCH state', itoa(nfa.states[nfa.stateCount].type))
                continue
            }
        }

        // Additional topology validation for key patterns
        select {
            // Test 1: /a/ - Simple literal
            active (x == 1): {
                // Should have: BEGIN → LITERAL(a) → MATCH
                if (!NAVAssertTrue('Should have exactly 1 LITERAL state', ValidateStateCount(nfa, NFA_STATE_LITERAL, 1))) {
                    NAVLogTestFailed(x, '1 LITERAL state', 'incorrect count')
                    continue
                }
                if (!NAVAssertTrue('Should have LITERAL state with value a', FindStateByTypeAndValue(nfa, NFA_STATE_LITERAL, 'a') > 0)) {
                    NAVLogTestFailed(x, 'LITERAL(a) state', 'not found')
                    continue
                }
            }

            // Test 2: /abc/ - Multiple literals
            active (x == 2): {
                // Should have: BEGIN → LITERAL(a) → LITERAL(b) → LITERAL(c) → MATCH
                if (!NAVAssertTrue('Should have exactly 3 LITERAL states', ValidateStateCount(nfa, NFA_STATE_LITERAL, 3))) {
                    NAVLogTestFailed(x, '3 LITERAL states', 'incorrect count')
                    continue
                }
                if (!NAVAssertTrue('Should have LITERAL(a)', FindStateByTypeAndValue(nfa, NFA_STATE_LITERAL, 'a') > 0)) {
                    NAVLogTestFailed(x, 'LITERAL(a)', 'not found')
                    continue
                }
                if (!NAVAssertTrue('Should have LITERAL(b)', FindStateByTypeAndValue(nfa, NFA_STATE_LITERAL, 'b') > 0)) {
                    NAVLogTestFailed(x, 'LITERAL(b)', 'not found')
                    continue
                }
                if (!NAVAssertTrue('Should have LITERAL(c)', FindStateByTypeAndValue(nfa, NFA_STATE_LITERAL, 'c') > 0)) {
                    NAVLogTestFailed(x, 'LITERAL(c)', 'not found')
                    continue
                }
            }

            // Test 17: /a*/ - Zero or more
            active (x == 17): {
                // Should have SPLIT state for optional/repeating structure
                if (!NAVAssertTrue('Should have at least 1 SPLIT state', CountStatesByType(nfa, NFA_STATE_SPLIT) >= 1)) {
                    NAVLogTestFailed(x, 'SPLIT state for *', 'not found')
                    continue
                }
                if (!NAVAssertTrue('Should have quantifier structure', ValidateQuantifierStructure(nfa, true, true))) {
                    NAVLogTestFailed(x, 'valid quantifier structure', 'invalid structure')
                    continue
                }
            }

            // Test 18: /a+/ - One or more
            active (x == 18): {
                // Should have SPLIT state for repeating structure
                if (!NAVAssertTrue('Should have quantifier structure', ValidateQuantifierStructure(nfa, false, true))) {
                    NAVLogTestFailed(x, 'valid quantifier structure', 'invalid structure')
                    continue
                }
            }

            // Test 19: /a?/ - Zero or one
            active (x == 19): {
                // Should have SPLIT state for optional structure
                if (!NAVAssertTrue('Should have at least 1 SPLIT state', CountStatesByType(nfa, NFA_STATE_SPLIT) >= 1)) {
                    NAVLogTestFailed(x, 'SPLIT state for ?', 'not found')
                    continue
                }
                if (!NAVAssertTrue('Should have quantifier structure', ValidateQuantifierStructure(nfa, true, false))) {
                    NAVLogTestFailed(x, 'valid quantifier structure', 'invalid structure')
                    continue
                }
            }

            // Test 23: /[abc]/ - Character class
            active (x == 23): {
                // Should have CHAR_CLASS state
                if (!NAVAssertTrue('Should have exactly 1 CHAR_CLASS state', ValidateStateCount(nfa, NFA_STATE_CHAR_CLASS, 1))) {
                    NAVLogTestFailed(x, '1 CHAR_CLASS state', 'incorrect count')
                    continue
                }
            }

            // Test 25: /[^abc]/ - Negated character class
            active (x == 25): {
                // Should have CHAR_CLASS state with negation flag
                if (!NAVAssertTrue('Should have exactly 1 CHAR_CLASS state', ValidateStateCount(nfa, NFA_STATE_CHAR_CLASS, 1))) {
                    NAVLogTestFailed(x, '1 CHAR_CLASS state', 'incorrect count')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
