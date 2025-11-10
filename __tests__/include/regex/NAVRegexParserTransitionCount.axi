PROGRAM_NAME='NAVRegexParserTransitionCount'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test patterns covering various state types and topologies
constant char REGEX_PARSER_TRANSITION_COUNT_PATTERN[][255] = {
    '/a/',              // 1: Single literal
    '/abc/',            // 2: Multiple literals
    '/./',              // 3: Dot
    '/\d/',             // 4: Predefined class
    '/[abc]/',          // 5: Character class
    '/^a/',             // 6: Anchor + literal
    '/a$/',             // 7: Literal + anchor
    '/a|b/',            // 8: Alternation (SPLIT)
    '/a|b|c/',          // 9: Three-way alternation
    '/(a)/',            // 10: Capturing group
    '/a*/',             // 11: Zero-or-more (SPLIT)
    '/a+/',             // 12: One-or-more (SPLIT)
    '/a?/',             // 13: Zero-or-one (SPLIT)
    '/a{3}/',           // 14: Exact repetition
    '/a{2,5}/',         // 15: Bounded quantifier
    '/(a|b)*/',         // 16: Alternation in quantifier
    '/a*b*/',           // 17: Sequential quantifiers
    '/(?:a)/',          // 18: Non-capturing group
    '/\ba/',            // 19: Word boundary
    '/a\B/',            // 20: NOT word boundary
    '/\A/',             // 21: String start anchor
    '/\Z/',             // 22: String end anchor
    '/(a)(b)/',         // 23: Multiple captures
    '/((a))/',          // 24: Nested captures
    '/a|b|c|d/',        // 25: Four-way alternation
    '/a{10}/'           // 26: Large exact repetition
}


/**
 * @function TestNAVRegexParserTransitionCount
 * @public
 * @description Validates that state transition counts match state types.
 *
 * This test ensures the parser correctly sets transitionCount for each state.
 * The matcher relies on this count when iterating through transitions in
 * epsilon-closure and state matching:
 *
 * for (i = 1; i <= state.transitionCount; i++) {
 *     targetState = state.transitions[i].targetState
 *     // process transition
 * }
 *
 * If transitionCount is wrong:
 * - Too high: reads uninitialized transitions (garbage data)
 * - Too low: skips valid transitions (incorrect matching)
 *
 * State-specific requirements:
 * - MATCH: 0 transitions (terminal)
 * - EPSILON: 1+ transitions (must forward)
 * - SPLIT: 2+ transitions (must split execution)
 * - Consuming states: 0-1 transitions
 * - CAPTURE: 1 transition (mark then continue)
 * - Anchors: 1 transition (assert then continue)
 *
 * This complements the transition validity test by checking counts rather
 * than target state IDs.
 */
define_function TestNAVRegexParserTransitionCount() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Transition Count Validation *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_TRANSITION_COUNT_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer stateIdx
        stack_var char allCountsValid

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_TRANSITION_COUNT_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Validate transition count for every state
        allCountsValid = true

        for (stateIdx = 1; stateIdx <= nfa.stateCount; stateIdx++) {
            if (!ValidateStateTransitionCount(nfa.states[stateIdx], stateIdx, x)) {
                allCountsValid = false
                break
            }

            // Additional check: verify count doesn't exceed maximum
            if (nfa.states[stateIdx].transitionCount > MAX_REGEX_STATE_TRANSITIONS) {
                NAVLogTestFailed(x,
                    "'State ', itoa(stateIdx), ' transitionCount <= ', itoa(MAX_REGEX_STATE_TRANSITIONS)",
                    "'State ', itoa(stateIdx), ' transitionCount = ', itoa(nfa.states[stateIdx].transitionCount)")
                allCountsValid = false
                break
            }

            // Additional check: verify we can't access transitions beyond the count
            // (this would be reading uninitialized memory)
            if (nfa.states[stateIdx].transitionCount > 0) {
                stack_var integer lastValidIdx
                lastValidIdx = nfa.states[stateIdx].transitionCount

                // The last valid transition should have a valid target state
                if (lastValidIdx <= MAX_REGEX_STATE_TRANSITIONS) {
                    stack_var integer lastTarget
                    lastTarget = nfa.states[stateIdx].transitions[lastValidIdx].targetState

                    if (lastTarget < 1 || lastTarget > nfa.stateCount) {
                        NAVLogTestFailed(x,
                            "'State ', itoa(stateIdx), ' last transition should be valid'",
                            "'State ', itoa(stateIdx), ' transition[', itoa(lastValidIdx), '] points to invalid state ', itoa(lastTarget)")
                        allCountsValid = false
                        break
                    }
                }
            }
        }

        if (!NAVAssertTrue('All state transition counts should be valid', allCountsValid)) {
            // Error already logged in ValidateStateTransitionCount
            continue
        }

        NAVLogTestPassed(x)
    }
}
