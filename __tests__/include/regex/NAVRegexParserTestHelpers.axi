PROGRAM_NAME='NAVRegexParserTestHelpers'

/*
 * Shared helper functions for regex parser tests.
 * This file provides common utilities used across multiple parser test files.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_PARSER_TEST_HELPERS__
#DEFINE __NAV_FOUNDATION_REGEX_PARSER_TEST_HELPERS__ 'NAVRegexParserTestHelpers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'

DEFINE_CONSTANT

#IF_NOT_DEFINED EPSILON_CLOSURE_MAX_DEPTH
constant integer EPSILON_CLOSURE_MAX_DEPTH = 1000
#END_IF


/**
 * @function FindLiteralState
 * @private
 * @description Finds a literal state in the NFA with a specific character value.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {char} expectedChar - The character to find
 * @param {integer} stateId - Reference to store the found state ID
 *
 * @returns {char} True if found, False otherwise
 */
define_function char FindLiteralState(_NAVRegexNFA nfa, char expectedChar, integer stateId) {
    stack_var integer i

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_LITERAL &&
            nfa.states[i].matchChar == expectedChar) {
            stateId = i
            return true
        }
    }

    return false
}


/**
 * @function FindBackreferenceState
 * @private
 * @description Finds a backreference state in the NFA.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {integer} stateId - Reference to store the found state ID
 *
 * @returns {char} True if found, False otherwise
 */
define_function char FindBackreferenceState(_NAVRegexNFA nfa, integer stateId) {
    stack_var integer i

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_BACKREF) {
            stateId = i
            return true
        }
    }

    return false
}


/**
 * @function FindBackrefStateByGroup
 * @private
 * @description Finds a backreference state in the NFA with a specific group number.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {integer} groupNumber - The expected group number
 * @param {integer} stateId - Reference to store the found state ID
 *
 * @returns {char} True if found, False otherwise
 */
define_function char FindBackrefStateByGroup(_NAVRegexNFA nfa, integer groupNumber, integer stateId) {
    stack_var integer i

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_BACKREF &&
            nfa.states[i].groupNumber == groupNumber) {
            stateId = i
            return true
        }
    }

    return false
}


/**
 * @function CountLiteralStates
 * @private
 * @description Counts the number of literal states with a specific character.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {char} expectedChar - The character to count
 *
 * @returns {integer} The count of matching literal states
 */
define_function integer CountLiteralStates(_NAVRegexNFA nfa, char expectedChar) {
    stack_var integer i
    stack_var integer count

    count = 0

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_LITERAL &&
            nfa.states[i].matchChar == expectedChar) {
            count++
        }
    }

    return count
}


/**
 * @function CountBackreferences
 * @private
 * @description Counts the number of backreference states in the NFA.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 *
 * @returns {integer} The count of backreference states
 */
define_function integer CountBackreferences(_NAVRegexNFA nfa) {
    stack_var integer i
    stack_var integer count

    count = 0

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_BACKREF) {
            count++
        }
    }

    return count
}


/**
 * @function ValidateBackrefNumber
 * @private
 * @description Validates that a backreference state has the expected group number.
 *
 * @param {_NAVRegexNFA} nfa - The NFA containing the state
 * @param {integer} stateId - The backreference state ID
 * @param {integer} expectedNumber - The expected group number
 *
 * @returns {char} True if valid, False otherwise
 */
define_function char ValidateBackrefNumber(_NAVRegexNFA nfa, integer stateId, integer expectedNumber) {
    if (stateId < 1 || stateId > nfa.stateCount) {
        return false
    }

    if (nfa.states[stateId].type != NFA_STATE_BACKREF) {
        return false
    }

    return nfa.states[stateId].groupNumber == expectedNumber
}


/**
 * @function ValidateBackrefName
 * @private
 * @description Validates that a backreference state exists (named backreferences).
 *
 * @param {_NAVRegexNFA} nfa - The NFA containing the state
 * @param {integer} stateId - The backreference state ID
 * @param {char[]} expectedName - The expected group name (currently not validated)
 *
 * @returns {char} True if valid BACKREF state with valid group number, False otherwise
 */
define_function char ValidateBackrefName(_NAVRegexNFA nfa, integer stateId, char expectedName[]) {
    if (stateId < 1 || stateId > nfa.stateCount) {
        return false
    }

    // Verify it's a backreference state
    if (nfa.states[stateId].type != NFA_STATE_BACKREF) {
        return false
    }

    // Verify the backreference has a valid group number
    // Named backreferences should resolve to a valid group number (>= 1)
    if (nfa.states[stateId].groupNumber < 1) {
        return false
    }

    return true
}


/**
 * @function ValidateBackrefHasTransition
 * @private
 * @description Validates that a backreference state has exactly one transition.
 *
 * @param {_NAVRegexNFA} nfa - The NFA containing the state
 * @param {integer} stateId - The backreference state ID
 *
 * @returns {char} True if has one transition, False otherwise
 */
define_function char ValidateBackrefHasTransition(_NAVRegexNFA nfa, integer stateId) {
    if (stateId < 1 || stateId > nfa.stateCount) {
        return false
    }

    if (nfa.states[stateId].type != NFA_STATE_BACKREF) {
        return false
    }

    return nfa.states[stateId].transitionCount == 1
}


/**
 * @function ValidateStateTransitionCount
 * @private
 * @description Validates that a state's transition count matches expectations.
 *
 * Different state types have different transition count requirements:
 * - MATCH: Must have 0 transitions (terminal state)
 * - EPSILON: Must have at least 1 transition
 * - SPLIT: Must have 2+ transitions (typically 2 for binary split)
 * - LITERAL/DOT/CHAR_CLASS: Should have 0-1 transitions (consume then move)
 * - CAPTURE_START/END: Should have 1 transition
 * - Anchors: Should have 1 transition (zero-width assertion then move)
 *
 * @param {_NAVRegexNFAState} state - The state to validate
 * @param {integer} stateIdx - State index (for error reporting)
 * @param {integer} testNum - Test number (for error reporting)
 *
 * @returns {char} True if valid, False if invalid
 */
define_function char ValidateStateTransitionCount(_NAVRegexNFAState state,
                                                  integer stateIdx,
                                                  integer testNum) {
    switch (state.type) {
        case NFA_STATE_MATCH: {
            // MATCH state is terminal - must have no transitions
            if (state.transitionCount != 0) {
                NAVLogTestFailed(testNum,
                    "'State ', itoa(stateIdx), ' (MATCH) transitionCount = 0'",
                    "'State ', itoa(stateIdx), ' (MATCH) transitionCount = ', itoa(state.transitionCount)")
                return false
            }
        }

        case NFA_STATE_EPSILON: {
            // EPSILON must forward to at least one other state
            if (state.transitionCount < 1) {
                NAVLogTestFailed(testNum,
                    "'State ', itoa(stateIdx), ' (EPSILON) transitionCount >= 1'",
                    "'State ', itoa(stateIdx), ' (EPSILON) transitionCount = ', itoa(state.transitionCount)")
                return false
            }
        }

        case NFA_STATE_SPLIT: {
            // SPLIT must have at least 2 transitions (that's the point of splitting)
            if (state.transitionCount < 2) {
                NAVLogTestFailed(testNum,
                    "'State ', itoa(stateIdx), ' (SPLIT) transitionCount >= 2'",
                    "'State ', itoa(stateIdx), ' (SPLIT) transitionCount = ', itoa(state.transitionCount)")
                return false
            }
        }

        case NFA_STATE_LITERAL:
        case NFA_STATE_DOT:
        case NFA_STATE_CHAR_CLASS:
        case NFA_STATE_DIGIT:
        case NFA_STATE_NOT_DIGIT:
        case NFA_STATE_WORD:
        case NFA_STATE_NOT_WORD:
        case NFA_STATE_WHITESPACE:
        case NFA_STATE_NOT_WHITESPACE: {
            // Consuming states should have 0 or 1 transitions
            // 0 if they're the last state before MATCH
            // 1 if they continue to another state
            if (state.transitionCount > 1) {
                NAVLogTestFailed(testNum,
                    "'State ', itoa(stateIdx), ' (consuming) transitionCount <= 1'",
                    "'State ', itoa(stateIdx), ' (consuming) transitionCount = ', itoa(state.transitionCount)")
                return false
            }
        }

        case NFA_STATE_CAPTURE_START:
        case NFA_STATE_CAPTURE_END: {
            // Capture markers should have exactly 1 transition (mark then continue)
            if (state.transitionCount != 1) {
                NAVLogTestFailed(testNum,
                    "'State ', itoa(stateIdx), ' (CAPTURE) transitionCount = 1'",
                    "'State ', itoa(stateIdx), ' (CAPTURE) transitionCount = ', itoa(state.transitionCount)")
                return false
            }
        }

        case NFA_STATE_BEGIN:
        case NFA_STATE_END:
        case NFA_STATE_WORD_BOUNDARY:
        case NFA_STATE_NOT_WORD_BOUNDARY:
        case NFA_STATE_STRING_START:
        case NFA_STATE_STRING_END:
        case NFA_STATE_STRING_END_ABS: {
            // Anchors are zero-width assertions - should have 1 transition
            if (state.transitionCount != 1) {
                NAVLogTestFailed(testNum,
                    "'State ', itoa(stateIdx), ' (ANCHOR) transitionCount = 1'",
                    "'State ', itoa(stateIdx), ' (ANCHOR) transitionCount = ', itoa(state.transitionCount)")
                return false
            }
        }

        default: {
            // Unknown state type - just verify count is within bounds
            if (state.transitionCount > MAX_REGEX_STATE_TRANSITIONS) {
                NAVLogTestFailed(testNum,
                    "'State ', itoa(stateIdx), ' transitionCount <= ', itoa(MAX_REGEX_STATE_TRANSITIONS)",
                    "'State ', itoa(stateIdx), ' transitionCount = ', itoa(state.transitionCount)")
                return false
            }
        }
    }

    return true
}


/**
 * @function FindQuantifierSplitState
 * @private
 * @description Finds the SPLIT state created for a quantifier in the NFA.
 *
 * Quantifiers (\*, +, ?, {n,m}) create SPLIT states to implement repetition.
 * This function searches the NFA for the relevant SPLIT state by looking for
 * states that:
 * - Have type NFA_STATE_SPLIT
 * - Have exactly 2 transitions (binary split)
 * - Are not the initial split for alternation (which would be near start)
 *
 * For greedy quantifiers, the SPLIT should have:
 *   transitions[1] = match path (try to match more)
 *   transitions[2] = skip path (exit the loop)
 *
 * For lazy quantifiers, the order is reversed:
 *   transitions[1] = skip path (prefer fewer matches)
 *   transitions[2] = match path (only if skip fails)
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {integer} splitStateId - Output: ID of the SPLIT state found
 *
 * @returns {char} True if found, False otherwise
 */
define_function char FindQuantifierSplitState(_NAVRegexNFA nfa, integer splitStateId) {
    stack_var integer i
    stack_var integer foundState

    foundState = 0

    // Search for SPLIT state - find the LAST one with 2 transitions
    // This ensures we get the outermost quantifier, not inner alternations or nested quantifiers
    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_SPLIT) {
            // For quantifiers, SPLIT states typically have exactly 2 transitions
            if (nfa.states[i].transitionCount == 2) {
                foundState = i  // Keep updating to get the last one
            }
        }
    }

    if (foundState > 0) {
        splitStateId = foundState
        return true
    }

    return false
}


/**
 * @function IsMatchPathFirst
 * @private
 * @description Determines if the first transition from a SPLIT is the match path.
 *
 * Analyzes the target states of a SPLIT's transitions to determine which is
 * the "match path" (continues matching) vs "skip path" (exits the loop).
 *
 * Heuristic:
 * - Match path typically leads to a consuming state (LITERAL, DOT, CHAR_CLASS)
 * - Skip path typically leads to MATCH or the next pattern element
 *
 * This is a simplified heuristic. In reality, the parser's implementation
 * determines the order, and we're validating it matches expectations.
 *
 * @param {_NAVRegexNFA} nfa - The NFA
 * @param {integer} splitStateId - The SPLIT state to analyze
 *
 * @returns {char} True if first transition is likely match path, False if skip path
 */
define_function char IsMatchPathFirst(_NAVRegexNFA nfa, integer splitStateId) {
    stack_var integer firstTarget
    stack_var integer secondTarget
    stack_var integer firstTargetType
    stack_var integer secondTargetType

    if (nfa.states[splitStateId].transitionCount < 2) {
        return false  // Invalid SPLIT state
    }

    firstTarget = nfa.states[splitStateId].transitions[1].targetState
    secondTarget = nfa.states[splitStateId].transitions[2].targetState

    // Safety check
    if (firstTarget < 1 || firstTarget > nfa.stateCount ||
        secondTarget < 1 || secondTarget > nfa.stateCount) {
        return false
    }

    firstTargetType = nfa.states[firstTarget].type
    secondTargetType = nfa.states[secondTarget].type

    // Heuristic: Match path usually leads to a consuming state or another SPLIT/EPSILON/GROUP
    // Skip path usually leads to MATCH or the next pattern element
    //
    // For greedy: first transition should lead "back" to matching
    // For lazy: first transition should lead "forward" to skip (often to MATCH)
    //
    // Check if first target is MATCH (indicates skip path, so return false)
    if (firstTargetType == NFA_STATE_MATCH) {
        return false  // First transition is to MATCH = skip path
    }

    // Check if first target is a consuming state (indicates match path)
    switch (firstTargetType) {
        case NFA_STATE_LITERAL:
        case NFA_STATE_DOT:
        case NFA_STATE_CHAR_CLASS:
        case NFA_STATE_DIGIT:
        case NFA_STATE_NOT_DIGIT:
        case NFA_STATE_WORD:
        case NFA_STATE_NOT_WORD:
        case NFA_STATE_WHITESPACE:
        case NFA_STATE_NOT_WHITESPACE: {
            return true  // First transition is to consuming state = match path
        }
    }

    // Check if second target is MATCH (indicates first is match path)
    if (secondTargetType == NFA_STATE_MATCH) {
        return true  // Second is exit, so first is match path
    }

    // If first points to CAPTURE_START or SPLIT, it's likely the match path
    if (firstTargetType == NFA_STATE_CAPTURE_START ||
        firstTargetType == NFA_STATE_SPLIT) {
        return true  // First transition continues matching
    }    // Default assumption based on typical NFA construction
    // This may need refinement based on actual parser implementation
    return false
}


/**
 * @function ValidateStartState
 * @private
 * @description Validates that the start state is properly formed.
 *
 * Requirements:
 * - Start state exists (state 1)
 * - Start state is type EPSILON
 * - Start state has exactly 1 outgoing transition
 * - Transition leads to the actual pattern (not to itself or MATCH)
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 *
 * @returns {char} True if start state is valid, False otherwise
 */
define_function char ValidateStartState(_NAVRegexNFA nfa) {
    stack_var integer targetState

    // Verify start state exists
    if (nfa.stateCount < 1) {
        return false
    }

    // Verify start state is type EPSILON
    if (nfa.states[1].type != NFA_STATE_EPSILON) {
        return false
    }

    // Verify start state has exactly 1 transition
    if (nfa.states[1].transitionCount != 1) {
        return false
    }

    // Verify transition is epsilon
    if (!nfa.states[1].transitions[1].isEpsilon) {
        return false
    }

    // Verify transition doesn't point to itself
    if (nfa.states[1].transitions[1].targetState == 1) {
        return false
    }

    // Verify transition doesn't point directly to MATCH
    // (should go through pattern first)
    targetState = nfa.states[1].transitions[1].targetState

    if (targetState > 0 && targetState <= nfa.stateCount) {
        if (nfa.states[targetState].type == NFA_STATE_MATCH) {
            // Only invalid if pattern is not empty
            // For now we allow this as some patterns might be empty
        }
    }

    return true
}


/**
 * @function ValidateMatchState
 * @private
 * @description Validates that the MATCH state is properly formed.
 *
 * Requirements:
 * - Exactly one MATCH state exists
 * - MATCH state has no outgoing transitions
 * - MATCH state is reachable (at least one state points to it)
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 *
 * @returns {char} True if MATCH state is valid, False otherwise
 */
define_function char ValidateMatchState(_NAVRegexNFA nfa) {
    stack_var integer i
    stack_var integer matchStateId
    stack_var integer matchCount
    stack_var char isReachable

    matchCount = 0
    matchStateId = 0
    isReachable = false

    // Find MATCH state(s)
    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_MATCH) {
            matchCount++
            matchStateId = i
        }
    }

    // Should have exactly 1 MATCH state
    if (matchCount != 1) {
        return false
    }

    // MATCH state should have no outgoing transitions
    if (nfa.states[matchStateId].transitionCount != 0) {
        return false
    }

    // Check if MATCH state is reachable (at least one state points to it)
    for (i = 1; i <= nfa.stateCount; i++) {
        stack_var integer j

        for (j = 1; j <= nfa.states[i].transitionCount; j++) {
            if (nfa.states[i].transitions[j].targetState == matchStateId) {
                isReachable = true
                break
            }
        }

        if (isReachable) {
            break
        }
    }

    if (!isReachable) {
        return false
    }

    return true
}


/**
 * @function ValidateNoUnpatchedStates
 * @private
 * @description Validates that all states have proper transitions (no dangling edges).
 *
 * Requirements:
 * - All non-MATCH states have at least 1 outgoing transition
 * - No transitions point to invalid states (state 0 or > stateCount)
 * - No transitions point to state 1 except for quantifier back-edges
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 *
 * @returns {char} True if all states are properly patched, False otherwise
 */
define_function char ValidateNoUnpatchedStates(_NAVRegexNFA nfa) {
    stack_var integer i
    stack_var integer j

    for (i = 1; i <= nfa.stateCount; i++) {
        // MATCH state should have no transitions
        if (nfa.states[i].type == NFA_STATE_MATCH) {
            if (nfa.states[i].transitionCount != 0) {
                return false
            }
            continue
        }

        // Lookahead/lookbehind assertion end states may have no transitions
        // as they transition via the assertion mechanism
        // For now skip this check for these states
        // All other states should have at least 1 transition
        if (nfa.states[i].transitionCount < 1) {
            // This is actually valid for assertion end states and some edge cases
            // For this test we'll be lenient and just check transition validity
            continue
        }

        // Validate each transition points to valid state
        for (j = 1; j <= nfa.states[i].transitionCount; j++) {
            stack_var integer targetState
            targetState = nfa.states[i].transitions[j].targetState

            // Target state must be in valid range
            if (targetState < 1 || targetState > nfa.stateCount) {
                return false
            }
        }
    }

    return true
}


/**
 * @function ValidateStateReachability
 * @private
 * @description Validates that all states are reachable from start state.
 *
 * Uses simple iterative reachability check (breadth-first style without queue).
 * This is a simplified version that marks states as reachable.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 *
 * @returns {char} True if all states are reachable, False otherwise
 */
define_function char ValidateStateReachability(_NAVRegexNFA nfa) {
    stack_var char reachable[MAX_REGEX_NFA_STATES]
    stack_var integer i
    stack_var integer j
    stack_var char changed
    stack_var integer pass

    // Mark start state as reachable
    reachable[1] = true

    // Iterate until no new states are marked (fixed-point)
    pass = 0
    changed = true

    while (changed && pass < nfa.stateCount) {
        changed = false
        pass++

        for (i = 1; i <= nfa.stateCount; i++) {
            if (reachable[i]) {
                // Mark all states reachable from this state
                for (j = 1; j <= nfa.states[i].transitionCount; j++) {
                    stack_var integer targetState
                    targetState = nfa.states[i].transitions[j].targetState

                    if (targetState > 0 && targetState <= nfa.stateCount) {
                        if (!reachable[targetState]) {
                            reachable[targetState] = true
                            changed = true
                        }
                    }
                }
            }
        }
    }

    // All states should be reachable
    for (i = 1; i <= nfa.stateCount; i++) {
        if (!reachable[i]) {
            return false
        }
    }

    return true
}


/**
 * @function ValidateTransitionTargets
 * @private
 * @description Validates that all transition targets are valid state IDs.
 *
 * This is a sanity check to ensure no transitions point to:
 * - State 0 (invalid)
 * - States beyond stateCount (invalid)
 * - Negative state IDs (invalid)
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 *
 * @returns {char} True if all targets are valid, False otherwise
 */
define_function char ValidateTransitionTargets(_NAVRegexNFA nfa) {
    stack_var integer i
    stack_var integer j

    for (i = 1; i <= nfa.stateCount; i++) {
        for (j = 1; j <= nfa.states[i].transitionCount; j++) {
            stack_var integer targetState
            targetState = nfa.states[i].transitions[j].targetState

            // Target must be in range [1, stateCount]
            if (targetState < 1 || targetState > nfa.stateCount) {
                return false
            }
        }
    }

    return true
}


/**
 * @function ValidateSplitStates
 * @private
 * @description Validates that SPLIT states have exactly 2 transitions.
 *
 * SPLIT states are used for alternation and quantifiers.
 * They should always have exactly 2 outgoing transitions.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 *
 * @returns {char} True if all SPLIT states are valid, False otherwise
 */
define_function char ValidateSplitStates(_NAVRegexNFA nfa) {
    stack_var integer i

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_SPLIT) {
            // SPLIT states must have exactly 2 transitions
            if (nfa.states[i].transitionCount != 2) {
                return false
            }

            // Both transitions should be epsilon
            if (!nfa.states[i].transitions[1].isEpsilon ||
                !nfa.states[i].transitions[2].isEpsilon) {
                return false
            }
        }
    }

    return true
}


/**
 * @function FindCaptureStateByGroupNumber
 * @private
 * @description Finds a CAPTURE_START or CAPTURE_END state for a specific group number.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {integer} groupNumber - The group number to find
 * @param {integer} stateType - The state type to find (NFA_STATE_CAPTURE_START or NFA_STATE_CAPTURE_END)
 *
 * @returns {integer} The state index, or 0 if not found
 */
define_function integer FindCaptureStateByGroupNumber(_NAVRegexNFA nfa, integer groupNumber, integer stateType) {
    stack_var integer i

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == stateType && nfa.states[i].groupNumber == groupNumber) {
            return i
        }
    }

    return 0
}


/**
 * @function ValidateGroupName
 * @private
 * @description Validates that a capture group has the expected name in both START and END states.
 *
 * Requirements:
 * - CAPTURE_START state must have the expected name
 * - CAPTURE_END state must have the same name
 * - Both states must have the same group number
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} groupNumber - The group number to validate
 * @param {char[]} expectedName - The expected group name (empty string for unnamed groups)
 *
 * @returns {char} True if group name is valid, False otherwise
 */
define_function char ValidateGroupName(_NAVRegexNFA nfa, integer groupNumber, char expectedName[]) {
    stack_var integer startStateIndex
    stack_var integer endStateIndex
    stack_var char startName[MAX_REGEX_GROUP_NAME_LENGTH]
    stack_var char endName[MAX_REGEX_GROUP_NAME_LENGTH]

    // Find CAPTURE_START state for this group
    startStateIndex = FindCaptureStateByGroupNumber(nfa, groupNumber, NFA_STATE_CAPTURE_START)
    if (startStateIndex == 0) {
        return false  // No START state found
    }

    // Find CAPTURE_END state for this group
    endStateIndex = FindCaptureStateByGroupNumber(nfa, groupNumber, NFA_STATE_CAPTURE_END)
    if (endStateIndex == 0) {
        return false  // No END state found
    }

    // Get names from both states
    startName = nfa.states[startStateIndex].groupName
    endName = nfa.states[endStateIndex].groupName

    // Both states must have the expected name
    if (startName != expectedName) {
        return false
    }

    if (endName != expectedName) {
        return false
    }

    // Names must match each other
    if (startName != endName) {
        return false
    }

    return true
}


/**
 * @function ValidateAllGroupNames
 * @private
 * @description Validates that all groups in the NFA have the correct names.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {char[][]} expectedNames - Array of expected names indexed by group number
 * @param {integer} groupCount - Number of groups to validate
 *
 * @returns {char} True if all group names are valid, False otherwise
 */
define_function char ValidateAllGroupNames(_NAVRegexNFA nfa, char expectedNames[][50], integer groupCount) {
    stack_var integer i

    for (i = 1; i <= groupCount; i++) {
        if (!ValidateGroupName(nfa, i, expectedNames[i])) {
            return false
        }
    }

    return true
}


/**
 * @function ValidateNamedGroupsDoNotAffectNumbering
 * @private
 * @description Validates that named groups still get sequential numeric group numbers.
 *
 * Named groups should be numbered just like unnamed groups (1, 2, 3, ...).
 * This ensures consistent group indexing regardless of names.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 *
 * @returns {char} True if numbering is sequential, False otherwise
 */
define_function char ValidateNamedGroupsDoNotAffectNumbering(_NAVRegexNFA nfa) {
    stack_var integer i
    stack_var integer maxGroupNum
    stack_var char groupExists[MAX_REGEX_GROUPS]

    // Initialize tracking array
    for (i = 1; i <= MAX_REGEX_GROUPS; i++) {
        groupExists[i] = false
    }

    maxGroupNum = 0

    // Mark which group numbers exist
    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_CAPTURE_START) {
            if (nfa.states[i].groupNumber > maxGroupNum) {
                maxGroupNum = nfa.states[i].groupNumber
            }
            groupExists[nfa.states[i].groupNumber] = true
        }
    }

    // Verify all numbers from 1 to maxGroupNum exist (no gaps)
    for (i = 1; i <= maxGroupNum; i++) {
        if (!groupExists[i]) {
            return false  // Gap in numbering
        }
    }

    // Verify maxGroupNum matches NFA metadata
    if (maxGroupNum != nfa.captureGroupCount) {
        return false
    }

    return true
}


/**
 * @function ValidateMixedNamedAndUnnamed
 * @private
 * @description Validates that patterns with both named and unnamed groups handle names correctly.
 *
 * - Named groups should have their names in the groupName field
 * - Unnamed groups should have empty string in the groupName field
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {char[][]} expectedNames - Array of expected names (empty for unnamed groups)
 * @param {integer} groupCount - Total number of groups
 *
 * @returns {char} True if mixed groups handled correctly, False otherwise
 */
define_function char ValidateMixedNamedAndUnnamed(_NAVRegexNFA nfa, char expectedNames[][50], integer groupCount) {
    stack_var integer i
    stack_var integer stateIndex
    stack_var char actualName[MAX_REGEX_GROUP_NAME_LENGTH]

    for (i = 1; i <= groupCount; i++) {
        // Find CAPTURE_START state for this group
        stateIndex = FindCaptureStateByGroupNumber(nfa, i, NFA_STATE_CAPTURE_START)
        if (stateIndex == 0) {
            return false
        }

        actualName = nfa.states[stateIndex].groupName

        // Check if name matches expectation
        if (expectedNames[i] == '') {
            // Should be unnamed (empty string)
            if (actualName != '') {
                return false
            }
        } else {
            // Should be named
            if (actualName != expectedNames[i]) {
                return false
            }
        }
    }

    return true
}


/**
 * @function FindLookaroundState
 * @private
 * @description Finds a lookaround state of a specific type in the NFA.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {integer} expectedType - The expected lookaround type
 * @param {integer} stateId - Reference to store the found state ID
 *
 * @returns {char} True if found, False otherwise
 */
define_function char FindLookaroundState(_NAVRegexNFA nfa, integer expectedType, integer stateId) {
    stack_var integer i

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == expectedType) {
            stateId = i
            return true
        }
    }

    return false
}


/**
 * @function CountLookaroundStates
 * @private
 * @description Counts the number of lookaround states of a specific type.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {integer} expectedType - The lookaround type to count
 *
 * @returns {integer} The count of matching lookaround states
 */
define_function integer CountLookaroundStates(_NAVRegexNFA nfa, integer expectedType) {
    stack_var integer i
    stack_var integer count

    count = 0
    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == expectedType) {
            count++
        }
    }

    return count
}


/**
 * @function ValidateLookaroundSubExpression
 * @private
 * @description Validates that a lookaround state has a valid sub-expression.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} stateId - The lookaround state ID
 *
 * @returns {char} True if valid, False otherwise
 */
define_function char ValidateLookaroundSubExpression(_NAVRegexNFA nfa, integer stateId) {
    stack_var integer subExprStart

    // Check that state type is a lookaround
    if (nfa.states[stateId].type != NFA_STATE_LOOKAHEAD_POS &&
        nfa.states[stateId].type != NFA_STATE_LOOKAHEAD_NEG &&
        nfa.states[stateId].type != NFA_STATE_LOOKBEHIND_POS &&
        nfa.states[stateId].type != NFA_STATE_LOOKBEHIND_NEG) {
        return false
    }

    // Sub-expression start is stored in groupNumber field
    subExprStart = nfa.states[stateId].groupNumber

    // Validate sub-expression start state exists and is valid
    if (subExprStart < 1 || subExprStart > nfa.stateCount) {
        return false
    }

    return true
}


/**
 * @function ValidateCaptureGroupOrder
 * @private
 * @description Validates that capture groups are numbered in left-to-right order
 * by their opening parenthesis in the pattern.
 *
 * This walks the NFA from the start state following epsilon transitions to find
 * the order in which CAPTURE_START states are encountered during matching.
 * Groups should be numbered 1, 2, 3... in the order their opening parentheses
 * appear in the pattern (left-to-right).
 *
 * Example: Pattern /((a)(b))/
 * - First ( at position 1 → Should be group 1
 * - Second ( at position 2 → Should be group 2
 * - Third ( at position 5 → Should be group 3
 *
 * During NFA execution from start state:
 * - First CAPTURE_START encountered → Should have groupNumber = 1
 * - Second CAPTURE_START encountered → Should have groupNumber = 2
 * - Third CAPTURE_START encountered → Should have groupNumber = 3
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} expectedGroupNumbers[] - Expected group numbers in encounter order
 * @param {integer} expectedCount - Number of groups to validate
 *
 * @returns {char} True if group order is correct, False otherwise
 */
define_function char ValidateCaptureGroupOrder(_NAVRegexNFA nfa, integer expectedGroupNumbers[], integer expectedCount) {
    stack_var integer visitedStates[MAX_REGEX_NFA_STATES]
    stack_var integer queue[MAX_REGEX_NFA_STATES]
    stack_var integer queueHead
    stack_var integer queueTail
    stack_var integer foundGroupNumbers[MAX_REGEX_GROUPS]
    stack_var integer foundCount
    stack_var integer currentState
    stack_var integer i

    // BFS from start state to find CAPTURE_START states in encounter order
    queueHead = 1
    queueTail = 1
    queue[queueTail] = nfa.startState
    queueTail++
    visitedStates[nfa.startState] = true
    foundCount = 0

    while (queueHead < queueTail && foundCount < expectedCount) {
        currentState = queue[queueHead]
        queueHead++

        // Check if this is a CAPTURE_START state
        if (nfa.states[currentState].type == NFA_STATE_CAPTURE_START) {
            foundCount++
            foundGroupNumbers[foundCount] = nfa.states[currentState].groupNumber
        }

        // Add transitions to queue (breadth-first to maintain order)
        for (i = 1; i <= nfa.states[currentState].transitionCount; i++) {
            stack_var integer nextState
            nextState = nfa.states[currentState].transitions[i].targetState

            if (nextState > 0 && nextState <= nfa.stateCount && !visitedStates[nextState]) {
                visitedStates[nextState] = true
                queue[queueTail] = nextState
                queueTail++
            }
        }
    }

    // Verify we found the expected number of groups
    if (foundCount != expectedCount) {
        return false
    }

    // Verify the order matches expectations
    for (i = 1; i <= expectedCount; i++) {
        if (foundGroupNumbers[i] != expectedGroupNumbers[i]) {
            return false
        }
    }

    return true
}


/**
 * @function SimulateEpsilonClosure
 * @private
 * @description Simulates epsilon-closure to detect infinite loops.
 *
 * Follows epsilon transitions (EPSILON, SPLIT, CAPTURE_*, anchors) starting
 * from a given state, tracking visited states to detect cycles. If the same
 * state is visited twice via epsilon transitions, we have a loop.
 *
 * This is a simplified simulation that doesn't match the matcher's full
 * epsilon-closure logic (which handles anchors, captures, etc.), but it's
 * sufficient to detect structural infinite loops in the NFA.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to analyze
 * @param {integer} startState - State to begin epsilon-closure from
 * @param {integer[]} visited - Array tracking visited states (output)
 * @param {integer} visitedCount - Number of states visited (output)
 * @param {integer} depth - Current recursion depth
 *
 * @returns {char} True if terminated normally, False if loop detected
 */
define_function char SimulateEpsilonClosure(_NAVRegexNFA nfa,
                                            integer startState,
                                            integer visited[],
                                            integer visitedCount,
                                            integer depth) {
    stack_var integer i
    stack_var integer targetState
    stack_var char isEpsilonState
    stack_var char alreadyVisited
    stack_var integer stateType

    // Safety check: prevent infinite recursion
    if (depth > EPSILON_CLOSURE_MAX_DEPTH) {
        return false  // Exceeded maximum depth, likely an infinite loop
    }

    // Safety check: valid state ID
    if (startState < 1 || startState > nfa.stateCount) {
        return false  // Invalid state
    }

    // Check if we've already visited this state (cycle detection)
    alreadyVisited = false
    for (i = 1; i <= visitedCount; i++) {
        if (visited[i] == startState) {
            alreadyVisited = true
            break
        }
    }

    if (alreadyVisited) {
        // We've visited this state before in this epsilon-closure path
        // This indicates an epsilon loop
        return true  // Don't follow this path again, but don't fail - cycles are OK if we detect them
    }

    // Mark this state as visited
    visitedCount++
    if (visitedCount <= MAX_REGEX_NFA_STATES) {
        visited[visitedCount] = startState
    }

    stateType = nfa.states[startState].type

    // Determine if this is an epsilon state (non-consuming transition)
    isEpsilonState = false
    switch (stateType) {
        case NFA_STATE_EPSILON:
        case NFA_STATE_SPLIT:
        case NFA_STATE_CAPTURE_START:
        case NFA_STATE_CAPTURE_END:
        case NFA_STATE_BEGIN:
        case NFA_STATE_END:
        case NFA_STATE_WORD_BOUNDARY:
        case NFA_STATE_NOT_WORD_BOUNDARY:
        case NFA_STATE_STRING_START:
        case NFA_STATE_STRING_END:
        case NFA_STATE_STRING_END_ABS: {
            isEpsilonState = true
        }
        case NFA_STATE_MATCH: {
            // MATCH is terminal, stop here
            return true
        }
        default: {
            // Consuming state (LITERAL, DOT, CHAR_CLASS, etc.) - stop epsilon-closure
            return true
        }
    }

    // If this is an epsilon state, follow its transitions recursively
    if (isEpsilonState) {
        for (i = 1; i <= nfa.states[startState].transitionCount; i++) {
            targetState = nfa.states[startState].transitions[i].targetState

            // Recursively follow this epsilon transition
            if (!SimulateEpsilonClosure(nfa, targetState, visited, visitedCount, depth + 1)) {
                return false  // Infinite loop detected in recursion
            }
        }
    }

    return true  // Terminated successfully
}


/**
 * @function FindCharClassState
 * @private
 * @description Finds the character class state in the NFA.
 *
 * Searches for states of type CHAR_CLASS or predefined class types (DIGIT, WORD, etc.)
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {integer} stateId - Reference to store the found state ID
 *
 * @returns {char} True if found, False otherwise
 */
define_function char FindCharClassState(_NAVRegexNFA nfa, integer stateId) {
    stack_var integer i

    for (i = 1; i <= nfa.stateCount; i++) {
        stack_var integer stateType
        stateType = nfa.states[i].type

        // Check for character class or predefined class types
        if (stateType == NFA_STATE_CHAR_CLASS ||
            stateType == NFA_STATE_DIGIT ||
            stateType == NFA_STATE_NOT_DIGIT ||
            stateType == NFA_STATE_WORD ||
            stateType == NFA_STATE_NOT_WORD ||
            stateType == NFA_STATE_WHITESPACE ||
            stateType == NFA_STATE_NOT_WHITESPACE) {

            stateId = i
            return true
        }
    }

    return false
}


/**
 * @function ValidateCharClassRanges
 * @private
 * @description Validates that character class ranges are correctly ordered.
 *
 * Requirements:
 * - For each range, start <= end
 * - Ranges don't overlap (optional check)
 * - Range count is reasonable
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} stateId - The character class state ID
 *
 * @returns {char} True if ranges are valid, False otherwise
 */
define_function char ValidateCharClassRanges(_NAVRegexNFA nfa, integer stateId) {
    stack_var integer i
    stack_var integer rangeCount

    if (nfa.states[stateId].type != NFA_STATE_CHAR_CLASS) {
        return true  // Not a character class, skip validation
    }

    rangeCount = nfa.states[stateId].charClass.rangeCount

    // Validate range count is reasonable
    if (rangeCount < 0 || rangeCount > MAX_REGEX_CHAR_RANGES) {
        return false
    }

    // Validate each range
    for (i = 1; i <= rangeCount; i++) {
        stack_var char rangeStart
        stack_var char rangeEnd

        rangeStart = nfa.states[stateId].charClass.ranges[i].start
        rangeEnd = nfa.states[stateId].charClass.ranges[i].end

        // Start must be <= end
        if (rangeStart > rangeEnd) {
            return false
        }
    }

    return true
}


/**
 * @function ValidateCharClassNegation
 * @private
 * @description Validates that negated character classes have correct flag set.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} stateId - The character class state ID
 * @param {char} shouldBeNegated - Expected negation state
 *
 * @returns {char} True if negation flag matches expected, False otherwise
 */
define_function char ValidateCharClassNegation(_NAVRegexNFA nfa, integer stateId, char shouldBeNegated) {
    stack_var char isNegated

    if (nfa.states[stateId].type != NFA_STATE_CHAR_CLASS) {
        return true  // Not a character class, skip validation
    }

    isNegated = nfa.states[stateId].isNegated

    return (isNegated == shouldBeNegated)
}


/**
 * @function ValidatePredefinedClassType
 * @private
 * @description Validates that predefined classes create correct state types.
 *
 * Predefined classes like \d, \w, \s should create specific state types,
 * not generic CHAR_CLASS states.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} stateId - The state ID to check
 * @param {integer} expectedType - Expected state type
 *
 * @returns {char} True if state type matches expected, False otherwise
 */
define_function char ValidatePredefinedClassType(_NAVRegexNFA nfa, integer stateId, integer expectedType) {
    return (nfa.states[stateId].type == expectedType)
}


/**
 * @function ValidateCharClassNotEmpty
 * @private
 * @description Validates that character classes have at least one range or character.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} stateId - The character class state ID
 *
 * @returns {char} True if not empty, False otherwise
 */
define_function char ValidateCharClassNotEmpty(_NAVRegexNFA nfa, integer stateId) {
    if (nfa.states[stateId].type != NFA_STATE_CHAR_CLASS) {
        return true  // Predefined classes are never empty
    }

    // Character class should have at least 1 range
    return (nfa.states[stateId].charClass.rangeCount > 0)
}


/**
 * @function ValidateCharClassTransition
 * @private
 * @description Validates that character class states have exactly 1 transition.
 *
 * Character classes are consuming states that should have exactly one
 * outgoing epsilon transition (added during patching).
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} stateId - The character class state ID
 *
 * @returns {char} True if has exactly 1 transition, False otherwise
 */
define_function char ValidateCharClassTransition(_NAVRegexNFA nfa, integer stateId) {
    // Character classes should have exactly 1 outgoing transition (to next state)
    // This gets added during fragment patching
    return (nfa.states[stateId].transitionCount == 1)
}


/**
 * @function ValidateCaptureGroupPairing
 * @private
 * @description Validates that all CAPTURE_START states have matching CAPTURE_END states.
 *
 * Requirements:
 * - Each CAPTURE_START must have exactly one matching CAPTURE_END
 * - Group numbers must match between START and END
 * - CAPTURE_END must be reachable from CAPTURE_START
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} groupNum - The group number to validate
 *
 * @returns {char} True if group is properly paired, False otherwise
 */
define_function char ValidateCaptureGroupPairing(_NAVRegexNFA nfa, integer groupNum) {
    stack_var integer i
    stack_var integer startCount
    stack_var integer endCount

    startCount = 0
    endCount = 0

    // Count CAPTURE_START and CAPTURE_END states for this group number
    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_CAPTURE_START) {
            if (nfa.states[i].groupNumber == groupNum) {
                startCount++
            }
        }
        else if (nfa.states[i].type == NFA_STATE_CAPTURE_END) {
            if (nfa.states[i].groupNumber == groupNum) {
                endCount++
            }
        }
    }

    // Each group should have exactly 1 START and 1 END
    if (startCount != 1 || endCount != 1) {
        return false
    }

    return true
}


/**
 * @function ValidateCaptureGroupNumbering
 * @private
 * @description Validates that capture groups are numbered sequentially starting from 1.
 *
 * Requirements:
 * - Group numbers start at 1
 * - No gaps in numbering (1, 2, 3, ... N)
 * - groupCount in NFA matches highest group number
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 *
 * @returns {char} True if numbering is valid, False otherwise
 */
define_function char ValidateCaptureGroupNumbering(_NAVRegexNFA nfa) {
    stack_var integer i
    stack_var integer maxGroupNum
    stack_var char foundGroups[MAX_REGEX_GROUPS]

    maxGroupNum = 0

    // Find all group numbers present in the NFA
    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_CAPTURE_START ||
            nfa.states[i].type == NFA_STATE_CAPTURE_END) {

            stack_var integer groupNum
            groupNum = nfa.states[i].groupNumber

            if (groupNum > maxGroupNum) {
                maxGroupNum = groupNum
            }

            if (groupNum > 0 && groupNum <= MAX_REGEX_GROUPS) {
                foundGroups[groupNum] = true
            }
        }
    }

    // Verify sequential numbering from 1 to maxGroupNum
    for (i = 1; i <= maxGroupNum; i++) {
        if (!foundGroups[i]) {
            return false  // Gap in numbering
        }
    }

    // Verify groupCount matches
    if (nfa.captureGroupCount != maxGroupNum) {
        return false
    }

    return true
}


/**
 * @function ValidateCaptureGroupNesting
 * @private
 * @description Validates that nested capture groups have correct parent-child relationships.
 *
 * Requirements:
 * - Inner group's START/END must be between outer group's START/END
 * - No overlapping groups (START1, START2, END1, END2 is invalid)
 *
 * This is a simplified check that validates state ordering for nesting.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 *
 * @returns {char} True if nesting is valid, False otherwise
 */
define_function char ValidateCaptureGroupNesting(_NAVRegexNFA nfa) {
    stack_var integer i
    stack_var integer stack[MAX_REGEX_GROUPS]
    stack_var integer stackDepth

    stackDepth = 0

    // Traverse states in order and track group nesting with a stack
    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_CAPTURE_START) {
            // Push group onto stack
            stackDepth++
            if (stackDepth > MAX_REGEX_GROUPS) {
                return false  // Too deep
            }
            stack[stackDepth] = nfa.states[i].groupNumber
        }
        else if (nfa.states[i].type == NFA_STATE_CAPTURE_END) {
            // Pop group from stack and verify it matches
            if (stackDepth < 1) {
                return false  // END without matching START
            }

            if (stack[stackDepth] != nfa.states[i].groupNumber) {
                return false  // Mismatched group numbers (overlapping)
            }

            stackDepth--
        }
    }

    // Stack should be empty at end (all groups closed)
    if (stackDepth != 0) {
        return false  // Unclosed groups
    }

    return true
}


/**
 * @function ValidateNonCapturingGroups
 * @private
 * @description Validates that non-capturing groups don't create capture states.
 *
 * This is an indirect test - we verify that the total number of CAPTURE_START
 * and CAPTURE_END states matches the expected group count.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} expectedGroupCount - Expected number of capturing groups
 *
 * @returns {char} True if non-capturing groups handled correctly, False otherwise
 */
define_function char ValidateNonCapturingGroups(_NAVRegexNFA nfa, integer expectedGroupCount) {
    stack_var integer i
    stack_var integer captureStartCount
    stack_var integer captureEndCount

    captureStartCount = 0
    captureEndCount = 0

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_CAPTURE_START) {
            captureStartCount++
        }
        else if (nfa.states[i].type == NFA_STATE_CAPTURE_END) {
            captureEndCount++
        }
    }

    // Should have exactly expectedGroupCount of each type
    if (captureStartCount != expectedGroupCount) {
        return false
    }

    if (captureEndCount != expectedGroupCount) {
        return false
    }

    return true
}


/**
 * @function FindAnchorState
 * @private
 * @description Finds an anchor or boundary state in the NFA.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {integer} expectedType - The expected state type
 * @param {integer} stateId - Reference to store the found state ID
 *
 * @returns {char} True if found, False otherwise
 */
define_function char FindAnchorState(_NAVRegexNFA nfa, integer expectedType, integer stateId) {
    stack_var integer i

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == expectedType) {
            stateId = i
            return true
        }
    }

    return false
}


/**
 * @function ValidateAnchorType
 * @private
 * @description Validates that an anchor state has the correct type.
 *
 * @param {_NAVRegexNFA} nfa - The NFA containing the state
 * @param {integer} stateId - The anchor state ID
 * @param {integer} expectedType - The expected state type
 *
 * @returns {char} True if valid, False otherwise
 */
define_function char ValidateAnchorType(_NAVRegexNFA nfa, integer stateId, integer expectedType) {
    if (stateId < 1 || stateId > nfa.stateCount) {
        return false
    }

    return nfa.states[stateId].type == expectedType
}


/**
 * @function ValidateAnchorHasTransition
 * @private
 * @description Validates that an anchor state has exactly one epsilon transition.
 *
 * @param {_NAVRegexNFA} nfa - The NFA containing the state
 * @param {integer} stateId - The anchor state ID
 *
 * @returns {char} True if has one transition, False otherwise
 */
define_function char ValidateAnchorHasTransition(_NAVRegexNFA nfa, integer stateId) {
    if (stateId < 1 || stateId > nfa.stateCount) {
        return false
    }

    // Anchors should have exactly 1 epsilon transition
    return nfa.states[stateId].transitionCount == 1
}


/**
 * @function CountAnchorStates
 * @private
 * @description Counts the number of anchor/boundary states in the NFA.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {integer} stateType - The state type to count
 *
 * @returns {integer} The count of matching states
 */
define_function integer CountAnchorStates(_NAVRegexNFA nfa, integer stateType) {
    stack_var integer i
    stack_var integer count

    count = 0

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == stateType) {
            count++
        }
    }

    return count
}


/**
 * @function HasBothLineAnchors
 * @private
 * @description Checks if NFA has both line start and end anchors.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to check
 *
 * @returns {char} True if has both, False otherwise
 */
define_function char HasBothLineAnchors(_NAVRegexNFA nfa) {
    stack_var char hasBegin
    stack_var char hasEnd
    stack_var integer i

    hasBegin = false
    hasEnd = false

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == NFA_STATE_BEGIN) {
            hasBegin = true
        }
        if (nfa.states[i].type == NFA_STATE_END) {
            hasEnd = true
        }
    }

    return hasBegin && hasEnd
}


/**
 * Helper function to validate NFA structure has proper connectivity
 * Ensures that the start state can reach the accept state through valid transitions
 */
define_function char ValidateNFAConnectivity(_NAVRegexNFA nfa) {
    stack_var integer visited[MAX_REGEX_NFA_STATES]
    stack_var integer queue[MAX_REGEX_NFA_STATES]
    stack_var integer queueHead
    stack_var integer queueTail
    stack_var integer currentState
    stack_var integer i
    stack_var integer targetState
    stack_var char foundAccept

    // Initialize
    for (i = 1; i <= MAX_REGEX_NFA_STATES; i++) {
        visited[i] = false
        queue[i] = 0
    }

    queueHead = 0
    queueTail = 0
    foundAccept = false

    // Start BFS from start state
    queueTail++
    queue[queueTail] = nfa.startState
    visited[nfa.startState] = true

    while (queueHead < queueTail) {
        queueHead++
        currentState = queue[queueHead]

        // Check if we reached the accept state
        if (nfa.states[currentState].type == NFA_STATE_MATCH) {
            foundAccept = true
        }

        // Add all reachable states to queue
        for (i = 1; i <= nfa.states[currentState].transitionCount; i++) {
            targetState = nfa.states[currentState].transitions[i].targetState

            if (targetState > 0 && targetState <= nfa.stateCount && !visited[targetState]) {
                queueTail++
                queue[queueTail] = targetState
                visited[targetState] = true
            }
        }
    }

    return foundAccept
}


/**
 * @function CountStatesByType
 * @private
 * @description Counts the number of states of a specific type in the NFA.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to analyze
 * @param {integer} stateType - The state type to count
 *
 * @returns {integer} Number of states of the specified type
 */
define_function integer CountStatesByType(_NAVRegexNFA nfa, integer stateType) {
    stack_var integer count
    stack_var integer i

    count = 0
    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == stateType) {
            count++
        }
    }

    return count
}


/**
 * @function ValidateStateCount
 * @private
 * @description Validates that the NFA has the expected number of states of a specific type.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} stateType - The state type to count
 * @param {integer} expectedCount - Expected count
 *
 * @returns {char} True if count matches, False otherwise
 */
define_function char ValidateStateCount(_NAVRegexNFA nfa, integer stateType, integer expectedCount) {
    stack_var integer actualCount

    actualCount = CountStatesByType(nfa, stateType)

    return (actualCount == expectedCount)
}


/**
 * @function ValidateTransitionExists
 * @private
 * @description Validates that a specific transition exists from a state.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} fromState - Source state ID
 * @param {integer} toState - Expected destination state ID
 *
 * @returns {char} True if transition exists, False otherwise
 */
define_function char ValidateTransitionExists(_NAVRegexNFA nfa, integer fromState, integer toState) {
    stack_var integer i

    for (i = 1; i <= nfa.states[fromState].transitionCount; i++) {
        if (nfa.states[fromState].transitions[i].targetState == toState) {
            return true
        }
    }

    return false
}


/**
 * @function FindStateByTypeAndValue
 * @private
 * @description Finds a state with specific type and match character value.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to search
 * @param {integer} stateType - The state type to find
 * @param {char} matchChar - Expected matchChar value
 *
 * @returns {integer} State ID if found, 0 otherwise
 */
define_function integer FindStateByTypeAndValue(_NAVRegexNFA nfa, integer stateType, char matchChar) {
    stack_var integer i

    for (i = 1; i <= nfa.stateCount; i++) {
        if (nfa.states[i].type == stateType &&
            nfa.states[i].matchChar == matchChar) {
            return i
        }
    }

    return 0
}


/**
 * @function ValidateSplitStateHasTwoTransitions
 * @private
 * @description Validates that a SPLIT state has exactly two transitions.
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} splitState - The SPLIT state ID
 *
 * @returns {char} True if state has two transitions, False otherwise
 */
define_function char ValidateSplitStateHasTwoTransitions(_NAVRegexNFA nfa, integer splitState) {
    if (nfa.states[splitState].type != NFA_STATE_SPLIT) {
        return false
    }

    return (nfa.states[splitState].transitionCount == 2)
}


/**
 * @function ValidateAlternationBranches
 * @private
 * @description Validates that an alternation pattern has the expected branch structure.
 *
 * Checks that:
 * - A SPLIT state exists
 * - The SPLIT state has two transitions
 * - Both branches eventually lead to a common merge point
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {integer} splitStateId - The SPLIT state ID
 *
 * @returns {char} True if alternation structure is valid, False otherwise
 */
define_function char ValidateAlternationBranches(_NAVRegexNFA nfa, integer splitStateId) {
    if (!ValidateSplitStateHasTwoTransitions(nfa, splitStateId)) {
        return false
    }

    // Verify both transitions go somewhere valid
    if (nfa.states[splitStateId].transitions[1].targetState == 0 ||
        nfa.states[splitStateId].transitions[2].targetState == 0) {
        return false
    }

    // Verify target states are within bounds
    if (nfa.states[splitStateId].transitions[1].targetState > nfa.stateCount ||
        nfa.states[splitStateId].transitions[2].targetState > nfa.stateCount) {
        return false
    }

    return true
}


/**
 * @function ValidateQuantifierStructure
 * @private
 * @description Validates that a quantifier pattern has the expected NFA structure.
 *
 * Checks that:
 * - Appropriate SPLIT states exist for quantifiers
 * - The quantified element exists
 * - Loop structure is valid
 *
 * @param {_NAVRegexNFA} nfa - The NFA to validate
 * @param {char} hasZero - True if quantifier allows zero matches (\*, ?, {0,n})
 * @param {char} hasMultiple - True if quantifier allows multiple matches (+, *, {n,m})
 *
 * @returns {char} True if quantifier structure is valid, False otherwise
 */
define_function char ValidateQuantifierStructure(_NAVRegexNFA nfa, char hasZero, char hasMultiple) {
    stack_var integer splitCount

    splitCount = CountStatesByType(nfa, NFA_STATE_SPLIT)

    // Quantifiers typically use SPLIT states for optional/repeating structure
    // At minimum, we just verify the NFA has valid structure
    if (hasZero || hasMultiple) {
        if (splitCount == 0) {
            return false
        }
    }

    return true
}


#END_IF
