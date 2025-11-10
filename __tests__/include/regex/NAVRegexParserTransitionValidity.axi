PROGRAM_NAME='NAVRegexParserTransitionValidity'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test patterns that create various NFA topologies
constant char REGEX_PARSER_TRANSITION_VALIDITY_PATTERN[][255] = {
    '/a/',              // 1: Single literal (simple chain)
    '/abc/',            // 2: Linear chain of literals
    '/abcde/',          // 3: Longer chain
    '/a|b/',            // 4: Simple alternation (single SPLIT)
    '/a|b|c/',          // 5: Three-way alternation (multiple SPLITs)
    '/a|b|c|d|e/',      // 6: Five-way alternation
    '/(a)/',            // 7: Single capturing group
    '/(a)(b)/',         // 8: Multiple capturing groups
    '/(a)(b)(c)/',      // 9: Three capturing groups
    '/((a))/',          // 10: Nested capturing groups
    '/((a)(b))/',       // 11: Nested with siblings
    '/a*/',             // 12: Zero-or-more quantifier
    '/a+/',             // 13: One-or-more quantifier
    '/a?/',             // 14: Zero-or-one quantifier
    '/a{3}/',           // 15: Exact repetition
    '/a{2,5}/',         // 16: Bounded repetition
    '/a{3,}/',          // 17: Unbounded repetition
    '/a*b*/',           // 18: Multiple quantifiers
    '/a*b+c?/',         // 19: Mixed quantifiers
    '/(a|b)*/',         // 20: Alternation in quantifier
    '/a(b|c)d/',        // 21: Alternation in middle
    '/(a|b)(c|d)/',     // 22: Multiple alternations
    '/^a/',             // 23: Start anchor
    '/a$/',             // 24: End anchor
    '/^a$/',            // 25: Both anchors
    '/\ba/',            // 26: Word boundary
    '/[abc]/',          // 27: Character class
    '/[^abc]/',         // 28: Negated character class
    '/\d+/',            // 29: Predefined class with quantifier
    '/(a*)*/',          // 30: Nested quantifiers (epsilon loop risk)
    '/(a+)*/',          // 31: Nested quantifiers variation
    '/(a|b)*c/',        // 32: Alternation in quantifier with concat
    '/a(b(c(d)))/',     // 33: Deep nesting
    '/(a|b|c)(d|e|f)/', // 34: Multiple multi-way alternations
    '/a{10}/',          // 35: Large repetition count
    '/(?:a|b)*/'        // 36: Non-capturing group with quantifier
}


/**
 * @function TestNAVRegexParserTransitionValidity
 * @public
 * @description Validates that all NFA transitions point to valid states.
 *
 * This test catches critical NFA structural bugs that could cause crashes
 * when the matcher tries to follow transitions. It verifies:
 * - All transition targetState values are within valid range (1 to stateCount)
 * - No transitions point to non-existent states (out-of-bounds)
 * - No unintentional self-loops (state transitioning to itself on epsilon)
 * - Transition counts are reasonable (not exceeding MAX_REGEX_STATE_TRANSITIONS)
 *
 * Why this matters:
 * - Invalid transition = array index out-of-bounds = immediate crash
 * - Self-loops on epsilon = infinite loop in epsilon-closure
 * - The matcher relies on being able to safely access nfa.states[targetState]
 *
 * This test was identified as Priority 1 in the gap analysis because the
 * matcher has no safety checks when following transitions - it assumes
 * the parser created a valid NFA structure.
 */
define_function TestNAVRegexParserTransitionValidity() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Transition Validity *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_TRANSITION_VALIDITY_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer stateIdx
        stack_var integer transIdx
        stack_var integer targetState
        stack_var integer sourceStateType
        stack_var char allTransitionsValid

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_TRANSITION_VALIDITY_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Verify NFA has states
        if (!NAVAssertTrue('NFA should have states', nfa.stateCount > 0)) {
            NAVLogTestFailed(x, '>0 states', itoa(nfa.stateCount))
            continue
        }

        // Check all transitions in all states
        allTransitionsValid = true

        for (stateIdx = 1; stateIdx <= nfa.stateCount; stateIdx++) {
            sourceStateType = nfa.states[stateIdx].type

            // Verify transition count is within bounds
            if (nfa.states[stateIdx].transitionCount > MAX_REGEX_STATE_TRANSITIONS) {
                NAVLogTestFailed(x,
                    "'State ', itoa(stateIdx), ' transition count <= ', itoa(MAX_REGEX_STATE_TRANSITIONS)",
                    "'State ', itoa(stateIdx), ' transition count = ', itoa(nfa.states[stateIdx].transitionCount)")
                allTransitionsValid = false
                break
            }

            // Check each transition from this state
            for (transIdx = 1; transIdx <= nfa.states[stateIdx].transitionCount; transIdx++) {
                targetState = nfa.states[stateIdx].transitions[transIdx].targetState

                // CRITICAL: Verify target state is within valid range
                if (targetState < 1 || targetState > nfa.stateCount) {
                    NAVLogTestFailed(x,
                        "'State ', itoa(stateIdx), ' transition[', itoa(transIdx), '] points to valid state'",
                        "'State ', itoa(stateIdx), ' transition[', itoa(transIdx), '] points to invalid state ', itoa(targetState), ' (valid range: 1-', itoa(nfa.stateCount), ')'")
                    allTransitionsValid = false
                    break
                }

                // Check for unintentional self-loops on epsilon transitions
                // Note: Self-loops are only valid for certain patterns (e.g., backreferences)
                // For most states, epsilon self-loop = infinite loop bug
                if (targetState == stateIdx && nfa.states[stateIdx].transitions[transIdx].isEpsilon) {
                    // Only SPLIT states might legitimately point back to themselves in some edge cases
                    // But even then, it's suspicious and worth checking
                    if (sourceStateType != NFA_STATE_SPLIT) {
                        NAVLogTestFailed(x,
                            "'State ', itoa(stateIdx), ' (type ', itoa(sourceStateType), ') should not have epsilon self-loop'",
                            "'State ', itoa(stateIdx), ' has epsilon transition to itself'")
                        allTransitionsValid = false
                        break
                    }
                }
            }

            if (!allTransitionsValid) {
                break
            }
        }

        if (!NAVAssertTrue('All transitions should be valid', allTransitionsValid)) {
            // Error already logged above with specifics
            continue
        }

        NAVLogTestPassed(x)
    }
}
