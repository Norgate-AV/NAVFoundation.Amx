PROGRAM_NAME='NAVRegexParserAlternationIntegration'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexParserTestHelpers.axi'

DEFINE_CONSTANT

// Test patterns for alternation (|) operator
constant char REGEX_PARSER_ALTERNATION_PATTERN_TEST[][255] = {
    // Simple alternation
    '/a|b/',                    // 1: Two single characters
    '/x|y/',                    // 2: Different characters
    '/ab|cd/',                  // 3: Two sequences
    '/abc|def/',                // 4: Longer sequences
    '/hello|world/',            // 5: Words

    // Multiple alternation (3+ branches)
    '/a|b|c/',                  // 6: Three characters
    '/x|y|z/',                  // 7: Three different
    '/red|green|blue/',         // 8: Three words
    '/1|2|3|4/',                // 9: Four alternatives
    '/a|b|c|d|e/',              // 10: Five alternatives

    // Alternation with character classes
    '/[a-z]|[0-9]/',            // 11: Letters or digits
    '/[abc]|[xyz]/',            // 12: Two char classes
    '/[^a-z]|[0-9]/',           // 13: Negated class or digits

    // Alternation with predefined classes
    '/\d|\w/',                  // 14: Digit or word
    '/\s|\d/',                  // 15: Whitespace or digit
    '/\D|\W/',                  // 16: Not digit or not word
    '/\w|[0-9]/',               // 17: Word or digit class

    // Alternation with quantifiers
    '/a*|b+/',                  // 18: Zero or more a, or one or more b
    '/x+|y*/',                  // 19: One or more x, or zero or more y
    '/\d+|\w*/',                // 20: Digits or words with quantifiers
    '/[a-z]{2,4}|[0-9]{3}/',    // 21: Bounded quantifiers
    '/a?|b?/',                  // 22: Optional on both sides
    '/ab*|cd+/',                // 23: Quantifier on second char
    '/a+b|c*d/',                // 24: Quantifiers in sequences

    // Alternation with anchors
    '/^a|b$/',                  // 25: Start anchor or end anchor
    '/^abc|xyz$/',              // 26: Anchored alternatives
    '/\ba|\b/',                 // 27: Word boundaries
    '/^start|end$/',            // 28: Full words with anchors

    // Alternation with dot
    '/.|a/',                    // 29: Dot or literal
    '/a.|.b/',                  // 30: Dot in sequences
    '/.+|a*/',                  // 31: Dot with quantifiers

    // Complex alternation combinations
    '/\d{2,4}|[a-z]+/',         // 32: Quantified digit or letters
    '/^[A-Z]|[a-z]$/',          // 33: Uppercase start or lowercase end
    '/\w+@|\d+#/',              // 34: Word at-sign or digit hash
    '/[0-9]{3}|[a-z]{3}/',      // 35: Three digits or three letters

    // Edge cases
    '/a|/',                     // 36: Empty right branch
    '/|b/',                     // 37: Empty left branch
    '/||/',                     // 38: Multiple empty branches
    '/abc|abc/',                // 39: Duplicate alternatives
    '/a|a|a/'                   // 40: Same alternative multiple times
}

// Expected minimum state counts for alternation patterns
// Alternation creates a SPLIT state that branches to alternatives
constant integer REGEX_PARSER_ALTERNATION_EXPECTED_MIN_STATES[] = {
    4,  // 1: a|b - split + 2 literals + accept
    4,  // 2: x|y - split + 2 literals + accept
    6,  // 3: ab|cd - split + 2 per branch + accept
    8,  // 4: abc|def - split + 3 per branch + accept
    12, // 5: hello|world - split + 5 per branch + accept

    5,  // 6: a|b|c - 2 splits + 3 literals + accept
    5,  // 7: x|y|z - 2 splits + 3 literals + accept
    14, // 8: red|green|blue - splits + letters + accept
    7,  // 9: 1|2|3|4 - 3 splits + 4 literals + accept
    8,  // 10: a|b|c|d|e - 4 splits + 5 literals + accept

    4,  // 11: [a-z]|[0-9] - split + 2 classes + accept
    4,  // 12: [abc]|[xyz] - split + 2 classes + accept
    4,  // 13: [^a-z]|[0-9] - split + negated + class + accept

    4,  // 14: \d|\w - split + 2 classes + accept
    4,  // 15: \s|\d - split + 2 classes + accept
    4,  // 16: \D|\W - split + 2 classes + accept
    4,  // 17: \w|[0-9] - split + class + class + accept

    6,  // 18: a*|b+ - split + quantifiers + accept
    6,  // 19: x+|y* - split + quantifiers + accept
    6,  // 20: \d+|\w* - split + quantifiers + accept
    8,  // 21: [a-z]{2,4}|[0-9]{3} - split + bounded quantifiers + accept
    6,  // 22: a?|b? - split + optionals + accept
    7,  // 23: ab*|cd+ - split + sequences with quantifiers + accept
    8,  // 24: a+b|c*d - split + quantified sequences + accept

    5,  // 25: ^a|b$ - split + anchored alternatives + accept
    8,  // 26: ^abc|xyz$ - split + sequences with anchors + accept
    5,  // 27: \ba|\b - split + boundary + literal + accept
    12, // 28: ^start|end$ - split + words with anchors + accept

    4,  // 29: .|a - split + dot + literal + accept
    6,  // 30: a.|.b - split + sequences with dots + accept
    6,  // 31: .+|a* - split + quantified alternation + accept

    8,  // 32: \d{2,4}|[a-z]+ - split + complex quantifiers + accept
    5,  // 33: ^[A-Z]|[a-z]$ - split + anchored classes + accept
    8,  // 34: \w+@|\d+# - split + sequences with symbols + accept
    8,  // 35: [0-9]{3}|[a-z]{3} - split + bounded quantifiers + accept

    3,  // 36: a| - split + literal + epsilon + accept
    3,  // 37: |b - split + epsilon + literal + accept
    4,  // 38: || - splits + epsilons + accept
    6,  // 39: abc|abc - split + duplicate sequences + accept
    5   // 40: a|a|a - splits + same literal + accept
}


/**
 * @function TestNAVRegexParserAlternationIntegration
 * @public
 * @description Tests end-to-end alternation (|) operator parsing.
 *
 * Validates:
 * - Simple two-branch alternation works
 * - Multiple alternation (3+ branches) works
 * - Alternation combines with quantifiers, anchors, character classes
 * - Empty branches are handled
 * - NFA structure is correct (SPLIT states created)
 */
define_function TestNAVRegexParserAlternationIntegration() {
    stack_var integer x
    stack_var integer i
    stack_var char hasSplitState
    stack_var integer splitStateId
    stack_var _NAVRegexLexer lexer
    stack_var _NAVRegexNFA nfa

    NAVLog("'***************** NAVRegexParser - Alternation Integration *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_ALTERNATION_PATTERN_TEST); x++) {

        // Tokenize the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_ALTERNATION_PATTERN_TEST[x], lexer))) {
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

        // Verify NFA has valid start state
        if (!NAVAssertTrue('NFA should have valid start state', nfa.startState > 0 && nfa.startState <= nfa.stateCount)) {
            NAVLogTestFailed(x, 'valid start state', itoa(nfa.startState))
            continue
        }

        // Verify state count is at least the minimum expected
        if (!NAVAssertTrue('NFA should have minimum states', nfa.stateCount >= REGEX_PARSER_ALTERNATION_EXPECTED_MIN_STATES[x])) {
            NAVLogTestFailed(x, itoa(REGEX_PARSER_ALTERNATION_EXPECTED_MIN_STATES[x]), itoa(nfa.stateCount))
            continue
        }

        // Verify NFA has a match state
        if (nfa.stateCount > 0) {
            if (!NAVAssertIntegerEqual('Last state should be MATCH state', NFA_STATE_MATCH, nfa.states[nfa.stateCount].type)) {
                NAVLogTestFailed(x, 'MATCH state', itoa(nfa.states[nfa.stateCount].type))
                continue
            }
        }

        // Verify that alternation creates SPLIT states
        // Check that at least one SPLIT state exists (alternation must create splits)
        hasSplitState = false
        for (i = 1; i <= nfa.stateCount; i++) {
            if (nfa.states[i].type == NFA_STATE_SPLIT) {
                hasSplitState = true
                splitStateId = i
                break
            }
        }

        if (!NAVAssertTrue('Alternation should create SPLIT state', hasSplitState)) {
            NAVLogTestFailed(x, 'has SPLIT state', 'no SPLIT state found')
            continue
        }

        // Additional topology validation for key alternation patterns
        select {
            // Test 1: /a|b/ - Simple two-branch alternation
            active (x == 1): {
                // Should have SPLIT state with two transitions
                if (!NAVAssertTrue('SPLIT state should have two branches', ValidateAlternationBranches(nfa, splitStateId))) {
                    NAVLogTestFailed(x, 'two valid branches', 'invalid branch structure')
                    continue
                }
                // Should have two LITERAL states (one for each branch)
                if (!NAVAssertTrue('Should have LITERAL(a)', FindStateByTypeAndValue(nfa, NFA_STATE_LITERAL, 'a') > 0)) {
                    NAVLogTestFailed(x, 'LITERAL(a)', 'not found')
                    continue
                }
                if (!NAVAssertTrue('Should have LITERAL(b)', FindStateByTypeAndValue(nfa, NFA_STATE_LITERAL, 'b') > 0)) {
                    NAVLogTestFailed(x, 'LITERAL(b)', 'not found')
                    continue
                }
            }

            // Test 3: /ab|cd/ - Sequence alternation
            active (x == 3): {
                // Should have SPLIT state with valid branches
                if (!NAVAssertTrue('SPLIT state should have two branches', ValidateAlternationBranches(nfa, splitStateId))) {
                    NAVLogTestFailed(x, 'two valid branches', 'invalid branch structure')
                    continue
                }
                // Should have literals for both branches
                if (!NAVAssertTrue('Should have LITERAL(a)', FindStateByTypeAndValue(nfa, NFA_STATE_LITERAL, 'a') > 0)) {
                    NAVLogTestFailed(x, 'LITERAL(a)', 'not found')
                    continue
                }
                if (!NAVAssertTrue('Should have LITERAL(c)', FindStateByTypeAndValue(nfa, NFA_STATE_LITERAL, 'c') > 0)) {
                    NAVLogTestFailed(x, 'LITERAL(c)', 'not found')
                    continue
                }
            }

            // Test 6: /a|b|c/ - Three-branch alternation
            active (x == 6): {
                // Should have at least 2 SPLIT states (for 3 branches)
                stack_var integer splitCount
                splitCount = CountStatesByType(nfa, NFA_STATE_SPLIT)
                if (!NAVAssertTrue('Should have at least 2 SPLIT states for 3 branches', splitCount >= 2)) {
                    NAVLogTestFailed(x, 'at least 2 SPLIT states', "'splitCount = ', itoa(splitCount)")
                    continue
                }
            }

            // Test 11: /[a-z]|[0-9]/ - Character class alternation
            active (x == 11): {
                // Should have SPLIT state and two CHAR_CLASS states
                if (!NAVAssertTrue('SPLIT state should have two branches', ValidateAlternationBranches(nfa, splitStateId))) {
                    NAVLogTestFailed(x, 'two valid branches', 'invalid branch structure')
                    continue
                }
                if (!NAVAssertTrue('Should have 2 CHAR_CLASS states', ValidateStateCount(nfa, NFA_STATE_CHAR_CLASS, 2))) {
                    NAVLogTestFailed(x, '2 CHAR_CLASS states', 'incorrect count')
                    continue
                }
            }

            // Test 18: /a*|b+/ - Alternation with quantifiers
            active (x == 18): {
                // Should have SPLIT for alternation plus splits for quantifiers
                stack_var integer splitCount
                splitCount = CountStatesByType(nfa, NFA_STATE_SPLIT)
                if (!NAVAssertTrue('Should have multiple SPLIT states (alternation + quantifiers)', splitCount >= 2)) {
                    NAVLogTestFailed(x, 'at least 2 SPLIT states', "'splitCount = ', itoa(splitCount)")
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
