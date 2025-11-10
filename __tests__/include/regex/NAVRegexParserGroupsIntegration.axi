PROGRAM_NAME='NAVRegexParserGroupsIntegration'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexParserTestHelpers.axi'

DEFINE_CONSTANT

// Test patterns for groups (capturing and non-capturing) and groups with alternation
constant char REGEX_PARSER_GROUPS_PATTERN_TEST[][255] = {
    // Simple capturing groups
    '/(a)/',                        // 1: Single character
    '/(abc)/',                      // 2: Multiple characters
    '/(hello)/',                    // 3: Word
    '/(ab)(cd)/',                   // 4: Two groups
    '/(a)(b)(c)/',                  // 5: Three groups

    // Nested capturing groups
    '/((a))/',                      // 6: Double nested
    '/((ab))/',                     // 7: Double nested sequence
    '/(((a)))/',                    // 8: Triple nested
    '/((a)(b))/',                   // 9: Nested with siblings
    '/(a(b)c)/',                    // 10: Group with nested group

    // Non-capturing groups
    '/(?:a)/',                      // 11: Single character
    '/(?:abc)/',                    // 12: Multiple characters
    '/(?:ab)(?:cd)/',               // 13: Two non-capturing groups
    '/(?:(?:a))/',                  // 14: Nested non-capturing

    // Mixed capturing and non-capturing
    '/(a)(?:b)/',                   // 15: Capturing then non-capturing
    '/(?:a)(b)/',                   // 16: Non-capturing then capturing
    '/(a(?:b)c)/',                  // 17: Capturing with nested non-capturing
    '/(?:a(b)c)/',                  // 18: Non-capturing with nested capturing

    // Groups with alternation
    '/(a|b)/',                      // 19: Simple alternation in group
    '/(x|y|z)/',                    // 20: Multiple alternation in group
    '/((a|b))/',                    // 21: Nested group with alternation
    '/(ab|cd)/',                    // 22: Alternating sequences
    '/(abc|def|ghi)/',              // 23: Multiple sequence alternation

    // Groups with quantifiers
    '/(a)+/',                       // 24: One or more group
    '/(ab)*/',                      // 25: Zero or more group
    '/(abc)?/',                     // 26: Optional group
    '/(a){3}/',                     // 27: Exactly 3 repetitions
    '/(ab){2,4}/',                  // 28: Between 2 and 4 repetitions

    // Groups with character classes
    '/([a-z])/',                    // 29: Char class in group
    '/([0-9]+)/',                   // 30: Quantified char class in group
    '/([\d]+)/',                    // 31: Predefined class in group
    '/([a-z]|[0-9])/',              // 32: Alternating char classes in group

    // Complex nested patterns
    '/((a|b)(c|d))/',               // 33: Nested groups with alternation
    '/(((a|b)))/',                  // 34: Triple nested with alternation
    '/((ab)|(cd))/',                // 35: Nested alternation of groups
    '/(a(b|c)d)/',                  // 36: Group with nested alternation

    // Groups with anchors
    '/(^a)/',                       // 37: Start anchor in group
    '/(a$)/',                       // 38: End anchor in group
    '/^(abc)$/',                    // 39: Anchors outside group
    '/(^a|b$)/',                    // 40: Anchored alternation in group

    // Groups with dots and predefined classes
    '/(.)/',                        // 41: Dot in group
    '/(\d+)/',                      // 42: Digit class in group
    '/(\w*)/',                      // 43: Word class in group
    '/(.+|a*)/',                    // 44: Alternation with dot and literal

    // Complex combinations
    '/(a+b*)(c|d)/',                // 45: Quantified group then alternation group
    '/((a|b)+)/',                   // 46: Quantified nested alternation
    '/(a)(b|c)(d)/',                // 47: Three groups, middle has alternation
    '/(?:(a)|b)/',                  // 48: Nested capturing in non-capturing
    '/((?:a|b)c)/',                 // 49: Capturing with nested non-capturing alternation

    // Edge cases
    '/()/',                         // 50: Empty group
    '/(?:)/',                       // 51: Empty non-capturing group
    '/(())/',                       // 52: Nested empty groups
    '/(a|)/',                       // 53: Group with empty alternation branch
    '/(|b)/'                        // 54: Group with empty left branch
}

// Expected minimum state counts
constant integer REGEX_PARSER_GROUPS_EXPECTED_MIN_STATES[] = {
    4,  // 1: (a) - CAPTURE_START + literal + CAPTURE_END + accept
    6,  // 2: (abc) - CAPTURE_START + 3 literals + CAPTURE_END + accept
    7,  // 3: (hello) - CAPTURE_START + 5 literals + CAPTURE_END + accept
    8,  // 4: (ab)(cd) - 2 groups each with 2 literals + accept
    9,  // 5: (a)(b)(c) - 3 groups each with 1 literal + accept

    6,  // 6: ((a)) - 2 CAPTURE_START + literal + 2 CAPTURE_END + accept
    8,  // 7: ((ab)) - 2 CAPTURE_START + 2 literals + 2 CAPTURE_END + accept
    8,  // 8: (((a))) - 3 CAPTURE_START + literal + 3 CAPTURE_END + accept
    10, // 9: ((a)(b)) - nested structure + accept
    8,  // 10: (a(b)c) - outer group + inner group + accept

    2,  // 11: (?:a) - just literal (non-capturing is pass-through) + accept
    4,  // 12: (?:abc) - 3 literals + accept
    6,  // 13: (?:ab)(?:cd) - 2+2 literals + accept
    2,  // 14: (?:(?:a)) - just literal + accept

    4,  // 15: (a)(?:b) - capturing group + literal + accept
    4,  // 16: (?:a)(b) - literal + capturing group + accept
    6,  // 17: (a(?:b)c) - capturing with nested content + accept
    6,  // 18: (?:a(b)c) - non-capturing with nested capturing + accept

    5,  // 19: (a|b) - CAPTURE_START + SPLIT + 2 branches + CAPTURE_END + accept
    6,  // 20: (x|y|z) - CAPTURE_START + splits + 3 branches + CAPTURE_END + accept
    7,  // 21: ((a|b)) - 2 capturing layers + alternation + accept
    7,  // 22: (ab|cd) - CAPTURE_START + SPLIT + 2 sequences + CAPTURE_END + accept
    9,  // 23: (abc|def|ghi) - capturing + splits + 3 sequences + accept

    5,  // 24: (a)+ - group + quantifier split + accept
    5,  // 25: (ab)* - group + quantifier split + accept
    5,  // 26: (abc)? - group + optional split + accept
    6,  // 27: (a){3} - group repeated + accept
    8,  // 28: (ab){2,4} - group with bounded quantifier + accept

    4,  // 29: ([a-z]) - CAPTURE_START + char class + CAPTURE_END + accept
    5,  // 30: ([0-9]+) - group + quantified class + accept
    5,  // 31: ([\d]+) - group + quantified predefined + accept
    6,  // 32: ([a-z]|[0-9]) - group + alternating classes + accept

    9,  // 33: ((a|b)(c|d)) - outer group + 2 inner alternation groups + accept
    7,  // 34: (((a|b))) - 3 capture layers + alternation + accept
    9,  // 35: ((ab)|(cd)) - outer group + alternation of 2 inner groups + accept
    8,  // 36: (a(b|c)d) - outer group with nested alternation + accept

    4,  // 37: (^a) - group + anchor + literal + accept
    4,  // 38: (a$) - group + literal + anchor + accept
    6,  // 39: ^(abc)$ - anchors + group + accept
    6,  // 40: (^a|b$) - group + alternation with anchors + accept

    4,  // 41: (.) - group + dot + accept
    5,  // 42: (\d+) - group + quantified digit + accept
    5,  // 43: (\w*) - group + quantified word + accept
    6,  // 44: (.+|a*) - group + alternation with quantifiers + accept

    9,  // 45: (a+b*)(c|d) - quantified group + alternation group + accept
    7,  // 46: ((a|b)+) - nested group + alternation + quantifier + accept
    11, // 47: (a)(b|c)(d) - 3 groups with middle alternation + accept
    6,  // 48: (?:(a)|b) - non-capturing + nested capturing + alternation + accept
    7,  // 49: ((?:a|b)c) - capturing with nested non-capturing alternation + accept

    3,  // 50: () - CAPTURE_START + epsilon + CAPTURE_END + accept
    2,  // 51: (?:) - epsilon (non-capturing pass-through) + accept
    5,  // 52: (()) - 2 capture layers + epsilon + accept
    5,  // 53: (a|) - group + alternation with empty branch + accept
    5   // 54: (|b) - group + alternation with empty left + accept
}


/**
 * @function TestNAVRegexParserGroupsIntegration
 * @public
 * @description Tests group (capturing and non-capturing) parsing with alternation.
 *
 * Validates:
 * - Simple capturing groups work
 * - Nested capturing groups work
 * - Non-capturing groups work
 * - Mixed capturing/non-capturing work
 * - Groups with alternation work
 * - Groups with quantifiers work
 * - Complex nested patterns work
 * - NFA structure is correct (CAPTURE states for capturing groups)
 */
define_function TestNAVRegexParserGroupsIntegration() {
    stack_var integer x
    stack_var integer i
    stack_var char hasCaptureState
    stack_var _NAVRegexLexer lexer
    stack_var _NAVRegexNFA nfa

    NAVLog("'***************** NAVRegexParser - Groups Integration *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_GROUPS_PATTERN_TEST); x++) {
        // Tokenize the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_GROUPS_PATTERN_TEST[x], lexer))) {
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
        if (!NAVAssertTrue('NFA should have minimum states', nfa.stateCount >= REGEX_PARSER_GROUPS_EXPECTED_MIN_STATES[x])) {
            NAVLogTestFailed(x, itoa(REGEX_PARSER_GROUPS_EXPECTED_MIN_STATES[x]), itoa(nfa.stateCount))
            continue
        }

        // Verify NFA has a match state
        if (nfa.stateCount > 0) {
            if (!NAVAssertIntegerEqual('Last state should be MATCH state', NFA_STATE_MATCH, nfa.states[nfa.stateCount].type)) {
                NAVLogTestFailed(x, 'MATCH state', itoa(nfa.states[nfa.stateCount].type))
                continue
            }
        }

        // For capturing group patterns (not non-capturing), verify CAPTURE states exist
        // Tests 1-10, 15-18, 19-23, 24-28, 29-32, 33-40, 41-44, 45-49, 50, 52-54 have capturing groups
        // Tests 11-14 are only non-capturing, test 51 is empty non-capturing
        if (x != 11 && x != 12 && x != 13 && x != 14 && x != 51) {
            hasCaptureState = false
            for (i = 1; i <= nfa.stateCount; i++) {
                if (nfa.states[i].type == NFA_STATE_CAPTURE_START || nfa.states[i].type == NFA_STATE_CAPTURE_END) {
                    hasCaptureState = true
                    break
                }
            }

            if (!NAVAssertTrue('Capturing group should create CAPTURE states', hasCaptureState)) {
                NAVLogTestFailed(x, 'has CAPTURE state', 'no CAPTURE state found')
                continue
            }
        }

        // ========================================================================
        // THOMPSON CONSTRUCTION VALIDATION
        // Verify NFA structure follows Thompson's construction for key patterns
        // ========================================================================

        // Test 4: /(ab)(cd)/ - Two sequential groups
        // Expected: EPSILON (State 1) -> CAPTURE_START(#1) -> 'a' -> 'b' -> CAPTURE_END(#1) ->
        //           CAPTURE_START(#2) -> 'c' -> 'd' -> CAPTURE_END(#2) -> MATCH
        if (x == 4) {
            stack_var integer startState
            stack_var integer captureStartState
            stack_var integer nextState

            startState = nfa.startState

            // NFA start should be EPSILON (State 1)
            if (!NAVAssertIntegerEqual('Start should be EPSILON', NFA_STATE_EPSILON, nfa.states[startState].type)) {
                NAVLogTestFailed(x, 'EPSILON at start', itoa(nfa.states[startState].type))
                continue
            }

            // Follow epsilon transition to first group's CAPTURE_START
            if (nfa.states[startState].transitionCount < 1) {
                NAVLogTestFailed(x, 'EPSILON should have transition', '0 transitions')
                continue
            }

            captureStartState = nfa.states[startState].transitions[1].targetState

            // Should point to first group's CAPTURE_START
            if (!NAVAssertIntegerEqual('After EPSILON should be CAPTURE_START', NFA_STATE_CAPTURE_START, nfa.states[captureStartState].type)) {
                NAVLogTestFailed(x, 'CAPTURE_START after EPSILON', itoa(nfa.states[captureStartState].type))
                continue
            }

            if (!NAVAssertIntegerEqual('First CAPTURE_START should be group 1', 1, nfa.states[captureStartState].groupNumber)) {
                NAVLogTestFailed(x, 'group 1', itoa(nfa.states[captureStartState].groupNumber))
                continue
            }

            // Follow epsilon transition to first literal
            if (nfa.states[captureStartState].transitionCount < 1) {
                NAVLogTestFailed(x, 'CAPTURE_START should have transition', '0 transitions')
                continue
            }

            nextState = nfa.states[captureStartState].transitions[1].targetState

            // Should be literal 'a'
            if (!NAVAssertIntegerEqual('First literal should be LITERAL', NFA_STATE_LITERAL, nfa.states[nextState].type)) {
                NAVLogTestFailed(x, 'LITERAL after CAPTURE_START', itoa(nfa.states[nextState].type))
                continue
            }

            if (!NAVAssertIntegerEqual('First literal should be ''a''', 'a', nfa.states[nextState].matchChar)) {
                NAVLogTestFailed(x, '''a''', nfa.states[nextState].matchChar)
                continue
            }
        }

        // Test 5: /(a)(b)(c)/ - Three sequential groups
        // Expected: EPSILON (State 1) -> CAPTURE_START(#1) -> 'a' -> CAPTURE_END(#1) ->
        //           CAPTURE_START(#2) -> 'b' -> CAPTURE_END(#2) ->
        //           CAPTURE_START(#3) -> 'c' -> CAPTURE_END(#3) -> MATCH
        if (x == 5) {
            stack_var integer startState
            stack_var integer captureStartState
            stack_var integer state2, state3, state4, state5, state6

            startState = nfa.startState

            // NFA start should be EPSILON (State 1)
            if (!NAVAssertIntegerEqual('Start should be EPSILON', NFA_STATE_EPSILON, nfa.states[startState].type)) {
                NAVLogTestFailed(x, 'EPSILON', itoa(nfa.states[startState].type))
                continue
            }

            // Follow epsilon transition to first group's CAPTURE_START
            if (nfa.states[startState].transitionCount < 1) {
                NAVLogTestFailed(x, 'EPSILON should have transition', '0 transitions')
                continue
            }

            captureStartState = nfa.states[startState].transitions[1].targetState

            // Verify first group's CAPTURE_START
            if (!NAVAssertIntegerEqual('After EPSILON should be CAPTURE_START #1', NFA_STATE_CAPTURE_START, nfa.states[captureStartState].type)) {
                NAVLogTestFailed(x, 'CAPTURE_START', itoa(nfa.states[captureStartState].type))
                continue
            }

            if (!NAVAssertIntegerEqual('First group should be #1', 1, nfa.states[captureStartState].groupNumber)) {
                NAVLogTestFailed(x, 'group 1', itoa(nfa.states[captureStartState].groupNumber))
                continue
            }

            // Follow to literal 'a'
            state2 = nfa.states[captureStartState].transitions[1].targetState
            if (!NAVAssertIntegerEqual('First literal should be ''a''', 'a', nfa.states[state2].matchChar)) {
                NAVLogTestFailed(x, '''a''', nfa.states[state2].matchChar)
                continue
            }

            // Follow to CAPTURE_END(#1)
            state3 = nfa.states[state2].transitions[1].targetState
            if (!NAVAssertIntegerEqual('After ''a'' should be CAPTURE_END #1', NFA_STATE_CAPTURE_END, nfa.states[state3].type)) {
                NAVLogTestFailed(x, 'CAPTURE_END', itoa(nfa.states[state3].type))
                continue
            }

            if (!NAVAssertIntegerEqual('CAPTURE_END should be group #1', 1, nfa.states[state3].groupNumber)) {
                NAVLogTestFailed(x, 'group 1', itoa(nfa.states[state3].groupNumber))
                continue
            }

            // Follow to CAPTURE_START(#2)
            state4 = nfa.states[state3].transitions[1].targetState
            if (!NAVAssertIntegerEqual('After group 1 should be CAPTURE_START #2', NFA_STATE_CAPTURE_START, nfa.states[state4].type)) {
                NAVLogTestFailed(x, 'CAPTURE_START #2', itoa(nfa.states[state4].type))
                continue
            }

            if (!NAVAssertIntegerEqual('Second group should be #2', 2, nfa.states[state4].groupNumber)) {
                NAVLogTestFailed(x, 'group 2', itoa(nfa.states[state4].groupNumber))
                continue
            }

            // Follow to literal 'b'
            state2 = nfa.states[state4].transitions[1].targetState
            if (!NAVAssertIntegerEqual('Second literal should be ''b''', 'b', nfa.states[state2].matchChar)) {
                NAVLogTestFailed(x, '''b''', nfa.states[state2].matchChar)
                continue
            }

            // Follow to CAPTURE_END(#2)
            state3 = nfa.states[state2].transitions[1].targetState
            if (!NAVAssertIntegerEqual('After ''b'' should be CAPTURE_END #2', NFA_STATE_CAPTURE_END, nfa.states[state3].type)) {
                NAVLogTestFailed(x, 'CAPTURE_END #2', itoa(nfa.states[state3].type))
                continue
            }

            // Follow to CAPTURE_START(#3)
            state5 = nfa.states[state3].transitions[1].targetState
            if (!NAVAssertIntegerEqual('After group 2 should be CAPTURE_START #3', NFA_STATE_CAPTURE_START, nfa.states[state5].type)) {
                NAVLogTestFailed(x, 'CAPTURE_START #3', itoa(nfa.states[state5].type))
                continue
            }

            if (!NAVAssertIntegerEqual('Third group should be #3', 3, nfa.states[state5].groupNumber)) {
                NAVLogTestFailed(x, 'group 3', itoa(nfa.states[state5].groupNumber))
                continue
            }

            // Follow to literal 'c'
            state6 = nfa.states[state5].transitions[1].targetState
            if (!NAVAssertIntegerEqual('Third literal should be ''c''', 'c', nfa.states[state6].matchChar)) {
                NAVLogTestFailed(x, '''c''', nfa.states[state6].matchChar)
                continue
            }
        }

        // Test 1: /(a)/ - Simple capturing group
        if (x == 1) {
            // Should have CAPTURE_START(#1) → LITERAL(a) → CAPTURE_END(#1)
            if (!NAVAssertTrue('Should have valid capture group pairing', ValidateCaptureGroupPairing(nfa, 1))) {
                NAVLogTestFailed(x, 'valid CAPTURE_START/END pairing', 'pairing validation failed')
                continue
            }
            if (!NAVAssertTrue('Should have LITERAL(a)', FindStateByTypeAndValue(nfa, NFA_STATE_LITERAL, 'a') > 0)) {
                NAVLogTestFailed(x, 'LITERAL(a)', 'not found')
                continue
            }
        }

        // Test 2: /(abc)/ - Group with sequence
        if (x == 2) {
            // Should have CAPTURE_START(#1) → LITERAL(a) → LITERAL(b) → LITERAL(c) → CAPTURE_END(#1)
            if (!NAVAssertTrue('Should have valid capture group pairing', ValidateCaptureGroupPairing(nfa, 1))) {
                NAVLogTestFailed(x, 'valid CAPTURE_START/END pairing', 'pairing validation failed')
                continue
            }
            if (!NAVAssertTrue('Should have 3 LITERAL states', ValidateStateCount(nfa, NFA_STATE_LITERAL, 3))) {
                NAVLogTestFailed(x, '3 LITERAL states', 'incorrect count')
                continue
            }
        }

        // Test 6: /((a))/ - Double nested groups
        if (x == 6) {
            // Should have two capture groups (#1 outer, #2 inner)
            if (!NAVAssertTrue('Should have valid outer group pairing', ValidateCaptureGroupPairing(nfa, 1))) {
                NAVLogTestFailed(x, 'valid group #1 pairing', 'pairing validation failed')
                continue
            }
            if (!NAVAssertTrue('Should have valid inner group pairing', ValidateCaptureGroupPairing(nfa, 2))) {
                NAVLogTestFailed(x, 'valid group #2 pairing', 'pairing validation failed')
                continue
            }
        }

        // Test 19: /(a|b)/ - Group with alternation
        if (x == 19) {
            // Should have CAPTURE_START → SPLIT → branches → CAPTURE_END
            if (!NAVAssertTrue('Should have valid capture group pairing', ValidateCaptureGroupPairing(nfa, 1))) {
                NAVLogTestFailed(x, 'valid CAPTURE_START/END pairing', 'pairing validation failed')
                continue
            }
            if (!NAVAssertTrue('Should have SPLIT state for alternation', CountStatesByType(nfa, NFA_STATE_SPLIT) >= 1)) {
                NAVLogTestFailed(x, 'SPLIT state', 'not found')
                continue
            }
        }

        // Test 24: /(a)+/ - Quantified group
        if (x == 24) {
            // Should have CAPTURE group with quantifier structure
            if (!NAVAssertTrue('Should have valid capture group pairing', ValidateCaptureGroupPairing(nfa, 1))) {
                NAVLogTestFailed(x, 'valid CAPTURE_START/END pairing', 'pairing validation failed')
                continue
            }
            if (!NAVAssertTrue('Should have quantifier structure', ValidateQuantifierStructure(nfa, false, true))) {
                NAVLogTestFailed(x, 'valid quantifier structure', 'invalid structure')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
