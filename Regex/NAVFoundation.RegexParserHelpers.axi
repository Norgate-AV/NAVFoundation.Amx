PROGRAM_NAME='NAVFoundation.RegexParserHelpers'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_PARSER_HELPERS__
#DEFINE __NAV_FOUNDATION_REGEX_PARSER_HELPERS__ 'NAVFoundation.RegexParserHelpers'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.RegexParser.h.axi'


// ============================================================================
// STATE MANAGEMENT HELPERS
// ============================================================================

/**
 * @function NAVRegexParserCanAddState
 * @private
 * @description Check if a new state can be added to the parser.
 *
 * @param {_NAVRegexParserState} parser - The parser state structure
 *
 * @returns {char} True (1) if state can be added, False (0) if limit reached
 */
define_function char NAVRegexParserCanAddState(_NAVRegexParserState parser) {
    return parser.stateCount < MAX_REGEX_NFA_STATES
}


/**
 * @function NAVRegexParserAddState
 * @private
 * @description Add a new state to the parser's state array.
 *
 * Checks capacity, increments state count, and initializes the state structure
 * to default values. Logs an error if the maximum state limit has been reached.
 *
 * @param {_NAVRegexParserState} parser - The parser state structure
 * @param {integer} type - Type of NFA state to create (NFA_STATE_LITERAL, etc.)
 *
 * @returns {integer} State ID (index) if successful, 0 if limit reached
 */
define_function integer NAVRegexParserAddState(_NAVRegexParserState parser, integer type) {
    stack_var integer id
    stack_var integer i

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserAddState ]: ENTRY - stateCount=', itoa(parser.stateCount), ', type=', itoa(type)")
    #END_IF

    if (!NAVRegexParserCanAddState(parser)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserAddState',
                                    "'State limit exceeded: ', itoa(MAX_REGEX_NFA_STATES)")
        parser.hasError = true
        parser.errorMessage = 'Pattern too complex - state limit exceeded'
        return 0
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserAddState ]: Before stateCount++'")
    #END_IF

    parser.stateCount++
    id = parser.stateCount

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserAddState ]: After stateCount++ - new count=', itoa(parser.stateCount), ', id=', itoa(id)")
    NAVLog("'[ ParserAddState ]: About to call set_length_array with length=', itoa(parser.stateCount)")
    #END_IF

    set_length_array(parser.states, parser.stateCount)

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserAddState ]: After set_length_array'")
    #END_IF

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserAddState ]: Created state ', itoa(id), ' (type=', itoa(type), ')'")
    #END_IF

    // Initialize state fields
    parser.states[id].id = id
    parser.states[id].type = type
    parser.states[id].transitionCount = 0
    parser.states[id].matchChar = 0
    parser.states[id].groupNumber = 0
    parser.states[id].isNegated = false
    parser.states[id].sourceTokenIndex = parser.currentToken

    // Initialize character class
    parser.states[id].charClass.rangeCount = 0

    // Clear all transitions
    for (i = 1; i <= MAX_REGEX_STATE_TRANSITIONS; i++) {
        parser.states[id].transitions[i].targetState = 0
        parser.states[id].transitions[i].isEpsilon = false
    }

    return id
}


/**
 * @function NAVRegexParserCreateState
 * @private
 * @description Create a new NFA state in the parser's state array.
 *
 * This is a convenience wrapper around NAVRegexParserAddState that provides
 * backward compatibility. New code should prefer using NAVRegexParserAddState directly.
 * On success, the new state is accessible at parser.states[returned_id].
 *
 * @param {_NAVRegexParserState} parser - The parser state structure
 * @param {integer} stateType - Type of NFA state to create (NFA_STATE_LITERAL, etc.)
 *
 * @returns {integer} State ID (index) if successful, 0 if limit reached
 */
define_function integer NAVRegexParserCreateState(_NAVRegexParserState parser,
                                                integer stateType) {
    return NAVRegexParserAddState(parser, stateType)
}


// ============================================================================
// TRANSITION MANAGEMENT HELPERS
// ============================================================================

/**
 * @function NAVRegexParserCanAddTransition
 * @private
 * @description Check if a new transition can be added to a state.
 *
 * @param {_NAVRegexParserState} parser - The parser state structure
 * @param {integer} stateId - State ID to check
 *
 * @returns {char} True (1) if transition can be added, False (0) if limit reached
 */
define_function char NAVRegexParserCanAddTransition(_NAVRegexParserState parser, integer stateId) {
    return parser.states[stateId].transitionCount < MAX_REGEX_STATE_TRANSITIONS
}


/**
 * @function NAVRegexParserAddTransition
 * @private
 * @description Add a transition from one state to another.
 *
 * Creates an edge between two NFA states. Transitions can be epsilon
 * (no input consumed) or normal (input consumed based on state type).
 * Includes validation of state IDs and transition limits.
 *
 * @param {_NAVRegexParserState} parser - The parser state structure
 * @param {integer} fromState - Source state ID
 * @param {integer} toState - Target state ID
 * @param {char} isEpsilon - True for epsilon transition, False for normal
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserAddTransition(_NAVRegexParserState parser,
                                                  integer fromState,
                                                  integer toState,
                                                  char isEpsilon) {
    stack_var integer transCount

    // Validate state IDs
    if (fromState < 1 || fromState > parser.stateCount) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserAddTransition',
                                    "'Invalid fromState: ', itoa(fromState)")
        return false
    }

    if (toState < 1 || toState > parser.stateCount) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserAddTransition',
                                    "'Invalid toState: ', itoa(toState)")
        return false
    }

    // Check transition limit
    if (!NAVRegexParserCanAddTransition(parser, fromState)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserAddTransition',
                                    "'Transition limit exceeded for state ', itoa(fromState), ': ', itoa(MAX_REGEX_STATE_TRANSITIONS)")
        parser.hasError = true
        parser.errorMessage = 'Pattern too complex - transition limit exceeded'
        return false
    }

    // Add transition
    transCount = parser.states[fromState].transitionCount
    transCount++
    parser.states[fromState].transitions[transCount].targetState = toState
    parser.states[fromState].transitions[transCount].isEpsilon = isEpsilon
    parser.states[fromState].transitionCount = transCount
    set_length_array(parser.states[fromState].transitions, transCount)

    #IF_DEFINED REGEX_PARSER_DEBUG
    if (isEpsilon) {
        NAVLog("'[ ParserAddTransition ]: state ', itoa(fromState), ' --epsilon--> state ', itoa(toState)")
    }
    else {
        NAVLog("'[ ParserAddTransition ]: state ', itoa(fromState), ' --------> state ', itoa(toState)")
    }
    #END_IF

    return true
}


/**
 * @function NAVRegexParserSwapTransitions
 * @private
 * @description Swap two transitions of a state to change their priority.
 *
 * This is used for lazy quantifiers where we need the skip path to be
 * tried before the match path. By swapping transitions[1] and transitions[2],
 * we change which path the matcher tries first.
 *
 * @param {_NAVRegexParserState} parser - The parser state structure
 * @param {integer} stateId - State ID whose transitions to swap
 * @param {integer} index1 - First transition index (1-based)
 * @param {integer} index2 - Second transition index (1-based)
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserSwapTransitions(_NAVRegexParserState parser,
                                                    integer stateId,
                                                    integer index1,
                                                    integer index2) {
    stack_var _NAVRegexNFATransition temp

    // Validate state
    if (stateId < 1 || stateId > parser.stateCount) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserSwapTransitions',
                                    "'Invalid stateId: ', itoa(stateId)")
        return false
    }

    // Validate indices
    if (index1 < 1 || index1 > parser.states[stateId].transitionCount ||
        index2 < 1 || index2 > parser.states[stateId].transitionCount) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserSwapTransitions',
                                    "'Invalid transition indices: ', itoa(index1), ', ', itoa(index2)")
        return false
    }

    // Swap
    temp = parser.states[stateId].transitions[index1]
    parser.states[stateId].transitions[index1] = parser.states[stateId].transitions[index2]
    parser.states[stateId].transitions[index2] = temp

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserSwapTransitions ]: Swapped transitions[', itoa(index1), '] and [', itoa(index2), '] of state ', itoa(stateId)")
    #END_IF

    return true
}


/**
 * @function NAVRegexParserPatchFragment
 * @private
 * @description Patch all dangling output states of a fragment to a target state.
 *
 * Adds epsilon transitions from each out state in the fragment to the
 * specified target state. This is the core operation for connecting NFA
 * fragments together during Thompson's Construction.
 *
 * @param {_NAVRegexParserState} parser - The parser state structure
 * @param {_NAVRegexNFAFragment} fragment - Fragment with dangling out states
 * @param {integer} targetState - State ID to connect all out states to
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserPatchFragment(_NAVRegexParserState parser,
                                                  _NAVRegexNFAFragment fragment,
                                                  integer targetState) {
    stack_var integer i
    stack_var integer outState

    // Validate fragment has out states
    if (fragment.outCount == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserPatchFragment',
                                    'Fragment has no out states')
        return false
    }

    if (fragment.outCount > MAX_REGEX_STATE_TRANSITIONS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserPatchFragment',
                                    "'Invalid outCount: ', itoa(fragment.outCount)")
        return false
    }

    // Validate target state
    if (targetState < 1 || targetState > parser.stateCount) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserPatchFragment',
                                    "'Invalid targetState: ', itoa(targetState)")
        return false
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserPatchFragment ]: Patching ', itoa(fragment.outCount), ' out states to target ', itoa(targetState)")
    #END_IF

    // Add epsilon transition from each out state to target
    for (i = 1; i <= fragment.outCount; i++) {
        outState = fragment.outStates[i]

        if (outState < 1 || outState > parser.stateCount) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserPatchFragment',
                                        "'Invalid outState: ', itoa(outState)")
            return false
        }

        // Check if this is a SPLIT state with a placeholder transition
        // Placeholder transitions point to state 1 (initial EPSILON) and are used for lazy quantifiers
        if (parser.states[outState].type == NFA_STATE_SPLIT &&
            parser.states[outState].transitionCount >= 1 &&
            parser.states[outState].transitions[1].targetState == 1 &&
            parser.states[outState].transitions[1].isEpsilon) {

            // This is a lazy quantifier - update the placeholder transition instead of adding new
            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[DEBUG] ParserPatchFragment: Updating placeholder in SPLIT state ', itoa(outState), ' from state 1 to ', itoa(targetState)")
            NAVLog("'[DEBUG]   Before: transitions[1]=', itoa(parser.states[outState].transitions[1].targetState), ', transitions[2]=', itoa(parser.states[outState].transitions[2].targetState)")
            #END_IF

            parser.states[outState].transitions[1].targetState = targetState

            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[DEBUG]   After: transitions[1]=', itoa(parser.states[outState].transitions[1].targetState), ', transitions[2]=', itoa(parser.states[outState].transitions[2].targetState)")
            #END_IF
        }
        else {
            // Normal case - add new transition
            if (!NAVRegexParserAddTransition(parser, outState, targetState, true)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                            'NAVRegexParserPatchFragment',
                                            "'Failed to add transition from ', itoa(outState), ' to ', itoa(targetState)")
                return false
            }
        }
    }

    return true
}


/**
 * @function NAVRegexParserIsFragmentBoundary
 * @private
 * @description Checks if a state is a boundary state of a fragment.
 *
 * Boundary states are those in the fragment's outStates array. These states
 * should be cloned but their outward transitions should not be followed
 * during deep cloning (they point outside the fragment).
 *
 * @param {integer} stateId - State ID to check
 * @param {_NAVRegexNFAFragment} fragment - Fragment to check against
 * @returns {char} true if state is a boundary state, false otherwise
 */
define_function char NAVRegexParserIsFragmentBoundary(integer stateId,
                                                        _NAVRegexNFAFragment fragment) {
    stack_var integer i

    for (i = 1; i <= fragment.outCount; i++) {
        if (fragment.outStates[i] == stateId) {
            return true
        }
    }

    return false
}


/**
 * @function NAVRegexParserDeepCloneFragment
 * @private
 * @description Performs deep cloning of an NFA fragment with full subgraph traversal.
 *
 * This function clones ALL states reachable from the fragment's start state,
 * including capturing group states, inner literal states, and boundary states.
 * This is essential for quantifying capturing groups like /(ab){2}/ where
 * shallow cloning would cause shared states and infinite loops.
 *
 * Uses BFS traversal to find all states within the fragment boundary, then
 * clones each state and remaps all transitions to use the new cloned states.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} original - Fragment to deep clone
 * @param {_NAVRegexNFAFragment} clone - Output cloned fragment
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserDeepCloneFragment(_NAVRegexParserState parser,
                                                       _NAVRegexNFAFragment original,
                                                       _NAVRegexNFAFragment clone) {
    stack_var integer stateMap[MAX_REGEX_NFA_STATES]  // Maps old state ID to new state ID
    stack_var integer queue[MAX_REGEX_NFA_STATES]     // BFS queue for traversal
    stack_var integer queueHead, queueTail
    stack_var integer oldStateId, newStateId
    stack_var _NAVRegexNFAState oldState
    stack_var char isBoundary
    stack_var integer i, j
    stack_var integer oldTarget, newTarget

    // Initialize
    for (i = 1; i <= MAX_REGEX_NFA_STATES; i++) {
        stateMap[i] = 0
        queue[i] = 0
    }
    queueHead = 0
    queueTail = 0

    // Start BFS from fragment start state
    queueTail++
    queue[queueTail] = original.startState

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ DeepClone ]: Starting BFS from state ', itoa(original.startState)")
    #END_IF

    // Phase 1: BFS traversal to clone all states
    while (queueHead < queueTail) {
        queueHead++
        oldStateId = queue[queueHead]

        // Skip if already cloned
        if (stateMap[oldStateId] != 0) {
            continue
        }

        oldState = parser.states[oldStateId]

        // Clone the state
        if (!NAVRegexParserAddState(parser, oldState.type)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserDeepCloneFragment',
                                        "'Failed to clone state ', itoa(oldStateId)")
            return false
        }

        newStateId = parser.stateCount
        stateMap[oldStateId] = newStateId

        // Copy state properties
        parser.states[newStateId].matchChar = oldState.matchChar
        parser.states[newStateId].groupNumber = oldState.groupNumber
        parser.states[newStateId].isNegated = oldState.isNegated
        parser.states[newStateId].charClass = oldState.charClass

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ DeepClone ]: Cloned state ', itoa(oldStateId), ' (type=', itoa(oldState.type), ') -> ', itoa(newStateId)")
        #END_IF

        // Check if this is a boundary state (in outStates)
        isBoundary = NAVRegexParserIsFragmentBoundary(oldStateId, original)

        // Queue transitions for cloning (but don't traverse beyond boundary states' outputs)
        if (!isBoundary) {
            for (i = 1; i <= oldState.transitionCount; i++) {
                oldTarget = oldState.transitions[i].targetState
                if (stateMap[oldTarget] == 0) {
                    // Not yet queued, add to queue
                    queueTail++
                    queue[queueTail] = oldTarget
                    #IF_DEFINED REGEX_PARSER_DEBUG
                    NAVLog("'[ DeepClone ]: Queued state ', itoa(oldTarget), ' for cloning'")
                    #END_IF
                }
            }
        }
        else {
            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[ DeepClone ]: State ', itoa(oldStateId), ' is boundary, not following its transitions'")
            #END_IF
        }
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ DeepClone ]: Phase 1 complete, cloned ', itoa(queueHead), ' states'")
    #END_IF

    // Phase 2: Remap all transitions
    for (i = 1; i <= MAX_REGEX_NFA_STATES; i++) {
        if (stateMap[i] == 0) {
            continue  // State not cloned
        }

        oldStateId = i
        newStateId = stateMap[i]
        oldState = parser.states[oldStateId]

        // Copy transitions, remapping targets
        for (j = 1; j <= oldState.transitionCount; j++) {
            oldTarget = oldState.transitions[j].targetState

            // If target was cloned, use cloned version; else use original (boundary crossing)
            if (stateMap[oldTarget] != 0) {
                newTarget = stateMap[oldTarget]
            } else {
                newTarget = oldTarget  // Transition outside fragment
            }

            if (!NAVRegexParserAddTransition(parser, newStateId, newTarget,
                                             oldState.transitions[j].isEpsilon)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                            'NAVRegexParserDeepCloneFragment',
                                            "'Failed to add transition for state ', itoa(newStateId)")
                return false
            }

            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[ DeepClone ]: Added transition: ', itoa(newStateId), ' -> ', itoa(newTarget),
                   ' (eps=', itoa(oldState.transitions[j].isEpsilon), ')'")
            #END_IF
        }
    }

    // Build result fragment with remapped outStates
    clone.startState = stateMap[original.startState]
    clone.outCount = original.outCount
    set_length_array(clone.outStates, original.outCount)

    for (i = 1; i <= original.outCount; i++) {
        if (stateMap[original.outStates[i]] != 0) {
            clone.outStates[i] = stateMap[original.outStates[i]]
        } else {
            clone.outStates[i] = original.outStates[i]  // Shouldn't happen but safe fallback
        }
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ DeepClone ]: Complete - old start=', itoa(original.startState),
           ', new start=', itoa(clone.startState), ', outs=', itoa(clone.outCount)")
    #END_IF

    return true
}


/**
 * @function NAVRegexParserCloneFragment
 * @private
 * @description Creates a deep copy of an NFA fragment with new state IDs.
 *
 * This is essential for bounded quantifiers like {n,m} where the same
 * pattern needs to be repeated multiple times. Without cloning, reusing
 * the same fragment causes states to accumulate too many transitions.
 *
 * The function creates brand new states that are copies of the original
 * fragment's states, maintaining the same structure but with different IDs.
 *
 * For simple fragments (literals, dots, character classes), performs shallow
 * cloning for performance. For capturing groups, delegates to deep clone
 * to avoid shared state bugs.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} original - Fragment to clone (pass by reference)
 * @param {_NAVRegexNFAFragment} clone - Output cloned fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserCloneFragment(_NAVRegexParserState parser,
                                                   _NAVRegexNFAFragment original,
                                                   _NAVRegexNFAFragment clone) {
    stack_var _NAVRegexNFAState startState
    stack_var integer stateMap[MAX_REGEX_NFA_STATES]  // Maps old state ID to new state ID
    stack_var integer i, j
    stack_var integer oldStateId, newStateId
    stack_var _NAVRegexNFAState originalState
    stack_var integer oldTargetState, newTargetState

    // Validate fragment
    if (original.startState == 0 || original.outCount == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserCloneFragment',
                                    'Invalid fragment to clone')
        return false
    }

    // Check if we need deep cloning
    startState = parser.states[original.startState]

    // Use deep clone for capturing groups to avoid shared state bugs
    if (startState.type == NFA_STATE_CAPTURE_START ||
        startState.type == NFA_STATE_CAPTURE_END) {
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ CloneFragment ]: Detected capturing group, using deep clone'")
        #END_IF
        return NAVRegexParserDeepCloneFragment(parser, original, clone)
    }    // Use deep clone for complex fragments (multiple out states)
    if (original.outCount > 1) {
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ CloneFragment ]: Detected complex fragment (', itoa(original.outCount), ' outs), using deep clone'")
        #END_IF
        return NAVRegexParserDeepCloneFragment(parser, original, clone)
    }

    // For simple single-state fragments, use shallow clone (performance optimization)
    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ CloneFragment ]: Using shallow clone for simple fragment'")
    #END_IF

    oldStateId = original.startState
    originalState = parser.states[oldStateId]

    // Create new state with same type
    if (!NAVRegexParserAddState(parser, originalState.type)) {
        return false
    }

    newStateId = parser.stateCount
    stateMap[oldStateId] = newStateId

    // Copy state properties
    parser.states[newStateId].matchChar = originalState.matchChar
    parser.states[newStateId].groupNumber = originalState.groupNumber
    parser.states[newStateId].isNegated = originalState.isNegated
    parser.states[newStateId].charClass = originalState.charClass

    // Clone transitions
    for (i = 1; i <= originalState.transitionCount; i++) {
        oldTargetState = originalState.transitions[i].targetState

        // If target state hasn't been cloned yet and is part of this fragment, clone it
        if (stateMap[oldTargetState] == 0) {
            // For simple fragments, transitions usually point outside the fragment
            // Use the original target (don't clone it)
            newTargetState = oldTargetState
        }
        else {
            newTargetState = stateMap[oldTargetState]
        }

        if (!NAVRegexParserAddTransition(parser, newStateId, newTargetState, originalState.transitions[i].isEpsilon)) {
            return false
        }
    }

    // Build cloned fragment
    clone.startState = newStateId
    clone.outCount = original.outCount
    set_length_array(clone.outStates, original.outCount)

    for (i = 1; i <= original.outCount; i++) {
        oldStateId = original.outStates[i]
        if (stateMap[oldStateId] != 0) {
            clone.outStates[i] = stateMap[oldStateId]
        }
        else {
            clone.outStates[i] = oldStateId
        }
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserCloneFragment ]: Cloned fragment (old start=', itoa(original.startState), ', new start=', itoa(clone.startState), ')'")
    #END_IF

    return true
}


// ============================================================================
// FLAG MANAGEMENT
// ============================================================================

/**
 * @function NAVRegexParserPushFlags
 * @private
 * @description Push current flags onto the flag stack for scoped flags.
 *
 * Used when entering a scoped flag group like (?i:pattern).
 * The current flags are saved so they can be restored when exiting the scope.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 *
 * @returns {char} True (1) if successful, False (0) if stack overflow
 */
define_function char NAVRegexParserPushFlags(_NAVRegexParserState parser) {
    if (parser.flagStackDepth >= MAX_REGEX_PARSER_DEPTH) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserPushFlags',
                                    "'Flag stack overflow (max: ', itoa(MAX_REGEX_PARSER_DEPTH), ')'")
        parser.hasError = true
        parser.errorMessage = 'Flag nesting too deep'
        return false
    }

    parser.flagStackDepth++
    parser.flagStack[parser.flagStackDepth] = parser.activeFlags

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserPushFlags ]: Pushed flags $', format('%02X', parser.activeFlags), ' (depth=', itoa(parser.flagStackDepth), ')'")
    #END_IF

    return true
}


/**
 * @function NAVRegexParserPopFlags
 * @private
 * @description Pop flags from the flag stack to restore previous scope.
 *
 * Used when exiting a scoped flag group like (?i:pattern).
 * Restores the flags that were active before entering the scope.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 *
 * @returns {char} True (1) if successful, False (0) if stack underflow
 */
define_function char NAVRegexParserPopFlags(_NAVRegexParserState parser) {
    if (parser.flagStackDepth <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserPopFlags',
                                    'Flag stack underflow')
        parser.hasError = true
        parser.errorMessage = 'Internal error: flag stack underflow'
        return false
    }

    parser.activeFlags = parser.flagStack[parser.flagStackDepth]
    parser.flagStackDepth--

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserPopFlags ]: Popped flags $', format('%02X', parser.activeFlags), ' (depth=', itoa(parser.flagStackDepth), ')'")
    #END_IF

    return true
}


/**
 * @function NAVRegexParserSetFlag
 * @private
 * @description Enable or disable a specific parser flag.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} flag - Flag constant (PARSER_FLAG_CASE_INSENSITIVE, etc.)
 * @param {char} enabled - True to enable, False to disable
 */
define_function NAVRegexParserSetFlag(_NAVRegexParserState parser, integer flag, char enabled) {
    if (enabled) {
        // Set bit using OR
        parser.activeFlags = parser.activeFlags bor flag

        // Warn if extended mode flag is being enabled (not supported)
        if (flag == PARSER_FLAG_EXTENDED) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserSetFlag',
                                        "'Extended mode flag (?x) is not supported and will have no effect'")
        }
    }
    else {
        // Clear bit using AND NOT
        parser.activeFlags = parser.activeFlags band (bnot flag)
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    if (enabled) {
        NAVLog("'[ ParserSetFlag ]: Flag $', format('%02X', flag), ' enabled (active=$', format('%02X', parser.activeFlags), ')'")
    }
    else {
        NAVLog("'[ ParserSetFlag ]: Flag $', format('%02X', flag), ' disabled (active=$', format('%02X', parser.activeFlags), ')'")
    }
    #END_IF
}


/**
 * @function NAVRegexParserHasFlag
 * @private
 * @description Check if a specific flag is currently active.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} flag - Flag constant to check
 *
 * @returns {char} True (1) if flag is active, False (0) otherwise
 */
define_function char NAVRegexParserHasFlag(_NAVRegexParserState parser, integer flag) {
    return (parser.activeFlags band flag) != 0
}


/**
 * @function NAVRegexParserOctalToChar
 * @private
 * @description Convert an octal string to a character value.
 *
 * Converts octal escape sequences like "7" (\7), "100" (\100), "377" (\377)
 * to their corresponding ASCII/byte values.
 *
 * Octal escapes:
 * - \0-\7: Single octal digit (0-7)
 * - \10-\77: Two octal digits (8-63 decimal)
 * - \100-\377: Three octal digits (64-255 decimal)
 *
 * @param {char[]} octalStr - Octal string (without the backslash)
 *
 * @returns {char} Character value (0-255)
 */
define_function char NAVRegexParserOctalToChar(char octalStr[]) {
    stack_var char result
    stack_var integer i
    stack_var integer length
    stack_var char digit

    result = 0
    length = length_array(octalStr)

    // Convert octal string to decimal
    for (i = 1; i <= length; i++) {
        digit = NAVCharCodeAt(octalStr, i) - '0'

        // Validate octal digit (0-7)
        if (digit < 0 || digit > 7) {
            // Invalid octal digit - return as-is (shouldn't happen if lexer is correct)
            return NAVCharCodeAt(octalStr, 1)
        }

        result = (result * 8) + digit
    }

    // Ensure result fits in a byte (0-255)
    if (result > 255) {
        result = result band $FF  // Mask to 8 bits
    }

    return result
}


// ============================================================================
// FLAG APPLICATION TO STATES
// ============================================================================

/**
 * @function NAVRegexParserApplyFlagsToLiteral
 * @private
 * @description Apply active flags to a literal character state.
 *
 * Primary purpose: Apply case-insensitive flag to make literal match both cases.
 * Sets the stateFlags field to indicate case-insensitive matching should be used.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} stateId - ID of the LITERAL state to modify
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexParserApplyFlagsToLiteral(_NAVRegexParserState parser,
                                                         integer stateId) {
    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserApplyFlagsToLiteral ]: ENTRY - stateId=', itoa(stateId), ', stateCount=', itoa(parser.stateCount)")
    #END_IF

    // Validate state ID
    if (stateId <= 0 || stateId > parser.stateCount) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserApplyFlagsToLiteral',
                                    "'Invalid stateId: ', itoa(stateId)")
        return false
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserApplyFlagsToLiteral ]: After stateId validation'")
    #END_IF

    // Validate state type
    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserApplyFlagsToLiteral ]: About to check state type for state ', itoa(stateId)")
    #END_IF
    if (parser.states[stateId].type != NFA_STATE_LITERAL) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserApplyFlagsToLiteral',
                                    "'State is not LITERAL type: ', itoa(parser.states[stateId].type)")
        return false
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserApplyFlagsToLiteral ]: After state type validation'")
    #END_IF

    // Store active flags on the state
    // This will be used during matching to apply case-insensitive comparison
    parser.states[stateId].stateFlags = parser.activeFlags

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserApplyFlagsToLiteral ]: After setting stateFlags'")
    #END_IF

    #IF_DEFINED REGEX_PARSER_DEBUG
    if (NAVRegexParserHasFlag(parser, PARSER_FLAG_CASE_INSENSITIVE)) {
        NAVLog("'[ ParserApplyFlags ]: Case-insensitive flag applied to literal ''', parser.states[stateId].matchChar, ''' (state=', itoa(stateId), ')'")
    }
    #END_IF

    return true
}


/**
 * @function NAVRegexParserApplyFlagsToDot
 * @private
 * @description Apply active flags to a DOT (.) wildcard state.
 *
 * Primary purpose: Apply DOTALL flag to make dot match newlines.
 * By default, DOT doesn't match \n, but with (?s) flag it should.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} stateId - ID of the ANY state to modify
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexParserApplyFlagsToDot(_NAVRegexParserState parser,
                                                     integer stateId) {
    // Validate state ID
    if (stateId <= 0 || stateId > parser.stateCount) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserApplyFlagsToDot',
                                    "'Invalid stateId: ', itoa(stateId)")
        return false
    }

    // Validate state type
    if (parser.states[stateId].type != NFA_STATE_DOT) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserApplyFlagsToDot',
                                    "'State is not DOT type: ', itoa(parser.states[stateId].type)")
        return false
    }

    // Check if DOTALL flag is active
    if (NAVRegexParserHasFlag(parser, PARSER_FLAG_DOTALL)) {
        // Set flag on state to indicate it should match newlines
        parser.states[stateId].matchesNewline = true

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserApplyFlags ]: DOTALL flag applied to state ', itoa(stateId)")
        #END_IF
    }

    return true
}


/**
 * @function NAVRegexParserApplyFlagsToCharClass
 * @private
 * @description Apply active flags to a character class state ([a-z], [^0-9], etc).
 *
 * Primary purpose: Apply CASE_INSENSITIVE flag to enable case folding in character classes.
 * Sets the stateFlags field so the matcher can apply case-insensitive matching.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} stateId - ID of the CHAR_CLASS state to modify
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexParserApplyFlagsToCharClass(_NAVRegexParserState parser,
                                                          integer stateId) {
    // Validate state ID
    if (stateId <= 0 || stateId > parser.stateCount) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserApplyFlagsToCharClass',
                                    "'Invalid stateId: ', itoa(stateId)")
        return false
    }

    // Validate state type
    if (parser.states[stateId].type != NFA_STATE_CHAR_CLASS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserApplyFlagsToCharClass',
                                    "'State is not CHAR_CLASS type: ', itoa(parser.states[stateId].type)")
        return false
    }

    // Store active flags on the state
    // This will be used during matching to apply case-insensitive comparison
    parser.states[stateId].stateFlags = parser.activeFlags

    #IF_DEFINED REGEX_PARSER_DEBUG
    if (NAVRegexParserHasFlag(parser, PARSER_FLAG_CASE_INSENSITIVE)) {
        NAVLog("'[ ParserApplyFlags ]: Case-insensitive flag applied to char class (state=', itoa(stateId), ')'")
    }
    #END_IF

    return true
}


/**
 * @function NAVRegexParserApplyFlagsToAnchor
 * @private
 * @description Apply active flags to an anchor state (^, $, etc).
 *
 * Primary purpose: Apply MULTILINE flag to anchors to make ^ and $ match line boundaries.
 * Sets the stateFlags field so the matcher can check multiline mode per-state.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} stateId - ID of the anchor state to modify
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexParserApplyFlagsToAnchor(_NAVRegexParserState parser,
                                                        integer stateId) {
    // Validate state ID
    if (stateId <= 0 || stateId > parser.stateCount) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserApplyFlagsToAnchor',
                                    "'Invalid stateId: ', itoa(stateId)")
        return false
    }

    // Validate state type is an anchor type
    switch (parser.states[stateId].type) {
        case NFA_STATE_BEGIN:
        case NFA_STATE_END:
        case NFA_STATE_WORD_BOUNDARY:
        case NFA_STATE_NOT_WORD_BOUNDARY:
        case NFA_STATE_STRING_START:
        case NFA_STATE_STRING_END:
        case NFA_STATE_STRING_END_ABS: {
            // Valid anchor types
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserApplyFlagsToAnchor',
                                        "'State is not an anchor type: ', itoa(parser.states[stateId].type)")
            return false
        }
    }

    // Store active flags on the anchor state
    // This will be used during matching to apply multiline mode to ^ and $
    parser.states[stateId].stateFlags = parser.activeFlags

    #IF_DEFINED REGEX_PARSER_DEBUG
    if (NAVRegexParserHasFlag(parser, PARSER_FLAG_MULTILINE)) {
        NAVLog("'[ ParserApplyFlags ]: MULTILINE flag applied to anchor state ', itoa(stateId), ' (type=', itoa(parser.states[stateId].type), ')'")
    }
    #END_IF

    return true
}


// ============================================================================
// LITERAL CHARACTER FRAGMENT
// ============================================================================

/**
 * @function NAVRegexParserBuildLiteral
 * @private
 * @description Build NFA fragment for a literal character match.
 *
 * Creates a single LITERAL state that matches a specific character.
 *
 * Example:
 *   Input: 'a'
 *   NFA: [LITERAL 'a'] ---> (out)
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {char} ch - Character to match
 * @param {_NAVRegexNFAFragment} fragment - Output fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildLiteral(_NAVRegexParserState parser,
                                                  char ch,
                                                  _NAVRegexNFAFragment fragment) {
    stack_var integer stateId

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildLiteral ]: ENTRY - char=''', ch, ''', depth=', itoa(parser.groupDepth)")
    NAVLog("'[ ParserBuildLiteral ]: Before AddState - stateCount=', itoa(parser.stateCount)")
    #END_IF

    // Create LITERAL state
    if (!NAVRegexParserAddState(parser, NFA_STATE_LITERAL)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildLiteral',
                                    'Failed to create LITERAL state')
        return false
    }

    stateId = parser.stateCount

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildLiteral ]: After AddState - stateId=', itoa(stateId)")
    #END_IF

    // Set match character
    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildLiteral ]: About to set matchChar for state ', itoa(stateId), ', ch value=', itoa(ch)")
    #END_IF
    parser.states[stateId].matchChar = ch

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildLiteral ]: After setting matchChar, stored value=', itoa(parser.states[stateId].matchChar)")
    #END_IF

    // Apply flags (e.g., case-insensitive)
    if (!NAVRegexParserApplyFlagsToLiteral(parser, stateId)) {
        return false
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildLiteral ]: After ApplyFlags'")
    #END_IF

    // Build fragment: start=stateId, one out state
    fragment.startState = stateId
    fragment.outCount = 1
    set_length_array(fragment.outStates, 1)
    fragment.outStates[1] = stateId

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildLiteral ]: Created fragment for char ''', ch, ''' (state=', itoa(stateId), ')'")
    #END_IF

    return true
}


// ============================================================================
// DOT (ANY CHARACTER) FRAGMENT
// ============================================================================

/**
 * @function NAVRegexParserBuildDot
 * @private
 * @description Build NFA fragment for dot (.) wildcard.
 *
 * Creates a single DOT state that matches any character except newline
 * (unless in DOTALL mode, handled during matching).
 *
 * Example:
 *   Input: .
 *   NFA: [DOT] ---> (out)
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} fragment - Output fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildDot(_NAVRegexParserState parser,
                                             _NAVRegexNFAFragment fragment) {
    stack_var integer stateId

    // Create DOT state
    if (!NAVRegexParserAddState(parser, NFA_STATE_DOT)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildDot',
                                    'Failed to create DOT state')
        return false
    }

    stateId = parser.stateCount

    // Apply flags (e.g., DOTALL to match newlines)
    if (!NAVRegexParserApplyFlagsToDot(parser, stateId)) {
        return false
    }

    // Build fragment
    fragment.startState = stateId
    fragment.outCount = 1
    set_length_array(fragment.outStates, 1)
    fragment.outStates[1] = stateId

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildDot ]: Created fragment for dot (state=', itoa(stateId), ')'")
    #END_IF

    return true
}


// ============================================================================
// CHARACTER CLASS FRAGMENT
// ============================================================================

/**
 * @function NAVRegexParserBuildCharClass
 * @private
 * @description Build NFA fragment for character class [abc], [a-z], [^abc], etc.
 *
 * Creates a CHAR_CLASS state with the parsed character class data.
 * The lexer has already parsed ranges and predefined classes.
 *
 * Examples:
 *   Input: [abc]      -> CHAR_CLASS with ranges [a-a, b-b, c-c]
 *   Input: [a-z0-9]   -> CHAR_CLASS with ranges [a-z, 0-9]
 *   Input: [^abc]     -> CHAR_CLASS with ranges [a-a, b-b, c-c], negated
 *   Input: [\d\w]     -> CHAR_CLASS with hasDigits=true, hasWordChars=true
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexCharClass} charClass - Character class from token
 * @param {char} isNegated - True for [^...], false for [...]
 * @param {_NAVRegexNFAFragment} fragment - Output fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildCharClass(_NAVRegexParserState parser,
                                                    _NAVRegexCharClass charClass,
                                                    char isNegated,
                                                    _NAVRegexNFAFragment fragment) {
    stack_var integer stateId

    // Create CHAR_CLASS state
    if (!NAVRegexParserAddState(parser, NFA_STATE_CHAR_CLASS)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildCharClass',
                                    'Failed to create CHAR_CLASS state')
        return false
    }

    stateId = parser.stateCount

    // Copy character class data to state
    parser.states[stateId].charClass = charClass
    // Set the state-level isNegated flag
    parser.states[stateId].isNegated = isNegated

    // Apply flags (e.g., case-insensitive)
    if (!NAVRegexParserApplyFlagsToCharClass(parser, stateId)) {
        return false
    }

    // Build fragment
    fragment.startState = stateId
    fragment.outCount = 1
    set_length_array(fragment.outStates, 1)
    fragment.outStates[1] = stateId

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildCharClass ]: Created fragment for char class (state=', itoa(stateId), ', negated=', itoa(isNegated), ', ranges=', itoa(charClass.rangeCount), ')'")
    #END_IF

    return true
}


// ============================================================================
// PREDEFINED CHARACTER CLASS FRAGMENTS
// ============================================================================

/**
 * @function NAVRegexParserBuildPredefinedClass
 * @private
 * @description Build NFA fragment for predefined character classes (\d, \w, \s, etc.).
 *
 * Creates appropriate state type based on token type.
 *
 * Supported classes:
 *   \d -> NFA_STATE_DIGIT
 *   \D -> NFA_STATE_NOT_DIGIT
 *   \w -> NFA_STATE_WORD
 *   \W -> NFA_STATE_NOT_WORD
 *   \s -> NFA_STATE_WHITESPACE
 *   \S -> NFA_STATE_NOT_WHITESPACE
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} tokenType - Token type (REGEX_TOKEN_DIGIT, REGEX_TOKEN_ALPHA, etc.)
 * @param {_NAVRegexNFAFragment} fragment - Output fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildPredefinedClass(_NAVRegexParserState parser,
                                                          integer tokenType,
                                                          _NAVRegexNFAFragment fragment) {
    stack_var integer stateId
    stack_var integer stateType

    // Map token type to NFA state type
    switch (tokenType) {
        case REGEX_TOKEN_DIGIT:             stateType = NFA_STATE_DIGIT
        case REGEX_TOKEN_NOT_DIGIT:         stateType = NFA_STATE_NOT_DIGIT
        case REGEX_TOKEN_ALPHA:             stateType = NFA_STATE_WORD
        case REGEX_TOKEN_NOT_ALPHA:         stateType = NFA_STATE_NOT_WORD
        case REGEX_TOKEN_WHITESPACE:        stateType = NFA_STATE_WHITESPACE
        case REGEX_TOKEN_NOT_WHITESPACE:    stateType = NFA_STATE_NOT_WHITESPACE
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildPredefinedClass',
                                        "'Invalid token type: ', itoa(tokenType)")
            return false
        }
    }

    // Create state
    if (!NAVRegexParserAddState(parser, stateType)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildPredefinedClass',
                                    'Failed to create predefined class state')
        return false
    }

    stateId = parser.stateCount

    // Build fragment
    fragment.startState = stateId
    fragment.outCount = 1
    set_length_array(fragment.outStates, 1)
    fragment.outStates[1] = stateId

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildPredefinedClass ]: Created fragment for predefined class (token=', itoa(tokenType), ', state=', itoa(stateId), ')'")
    #END_IF

    return true
}


// ============================================================================
// ANCHOR FRAGMENTS
// ============================================================================

/**
 * @function NAVRegexParserBuildAnchor
 * @private
 * @description Build NFA fragment for anchors (^, $, \b, \B, \A, \Z, \z).
 *
 * Anchors are zero-width assertions that don't consume input but test
 * position constraints.
 *
 * Supported anchors:
 *   ^   -> NFA_STATE_BEGIN (line/string start)
 *   $   -> NFA_STATE_END (line/string end)
 *   \b  -> NFA_STATE_WORD_BOUNDARY
 *   \B  -> NFA_STATE_NOT_WORD_BOUNDARY
 *   \A  -> NFA_STATE_STRING_START
 *   \Z  -> NFA_STATE_STRING_END
 *   \z  -> NFA_STATE_STRING_END_ABS
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} tokenType - Token type (REGEX_TOKEN_BEGIN, REGEX_TOKEN_END, etc.)
 * @param {_NAVRegexNFAFragment} fragment - Output fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildAnchor(_NAVRegexParserState parser,
                                                 integer tokenType,
                                                 _NAVRegexNFAFragment fragment) {
    stack_var integer stateId
    stack_var integer stateType

    // Map token type to NFA state type
    switch (tokenType) {
        case REGEX_TOKEN_BEGIN:                 stateType = NFA_STATE_BEGIN
        case REGEX_TOKEN_END:                   stateType = NFA_STATE_END
        case REGEX_TOKEN_WORD_BOUNDARY:         stateType = NFA_STATE_WORD_BOUNDARY
        case REGEX_TOKEN_NOT_WORD_BOUNDARY:     stateType = NFA_STATE_NOT_WORD_BOUNDARY
        case REGEX_TOKEN_STRING_START:          stateType = NFA_STATE_STRING_START
        case REGEX_TOKEN_STRING_END:            stateType = NFA_STATE_STRING_END
        case REGEX_TOKEN_STRING_END_ABSOLUTE:   stateType = NFA_STATE_STRING_END_ABS
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildAnchor',
                                        "'Invalid anchor token type: ', itoa(tokenType)")
            return false
        }
    }

    // Create anchor state
    if (!NAVRegexParserAddState(parser, stateType)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildAnchor',
                                    'Failed to create anchor state')
        return false
    }

    stateId = parser.stateCount

    // Apply active flags to anchor state (for multiline mode on ^ and $)
    if (!NAVRegexParserApplyFlagsToAnchor(parser, stateId)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildAnchor',
                                    'Failed to apply flags to anchor state')
        return false
    }

    // Build fragment
    fragment.startState = stateId
    fragment.outCount = 1
    set_length_array(fragment.outStates, 1)
    fragment.outStates[1] = stateId

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildAnchor ]: Created fragment for anchor (token=', itoa(tokenType), ', state=', itoa(stateId), ')'")
    #END_IF

    return true
}


/**
 * @function NAVRegexParserBuildBackreference
 * @private
 * @description Build NFA fragment for a backreference (\1, \2, etc. or \k<name>).
 *
 * Creates a single BACKREF state that will match the text captured by a previous
 * capturing group. The backreference state stores the group number it refers to.
 *
 * Thompson's Construction for Backreferences:
 *   - Create single NFA_STATE_BACKREF state
 *   - Store group number in state.groupNumber
 *   - Fragment has one out state (the BACKREF state itself)
 *   - Matcher will handle validation and matching at runtime
 *
 * Example:
 *   Pattern: /(a)\1/
 *   - Group 1 captures "a"
 *   - Backreference \1 matches another "a"
 *
 * Note: Backreferences make the language non-regular and require backtracking
 * during matching. The NFA construction is simple but matching is complex.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} groupNumber - Group number being referenced (1-based)
 * @param {_NAVRegexNFAFragment} fragment - Output fragment (pass by reference)
 *
 * @returns {char} True on success, False on failure
 */
define_function char NAVRegexParserBuildBackreference(_NAVRegexParserState parser,
                                                        integer groupNumber,
                                                        _NAVRegexNFAFragment fragment) {
    stack_var integer stateId

    // Validate group number
    if (groupNumber < 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildBackreference',
                                    "'Invalid backreference group number: ', itoa(groupNumber)")
        return false
    }

    // Validate that the group exists (has been defined before this backreference)
    // Note: Forward references are not allowed in most regex engines
    if (groupNumber > parser.currentGroup) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildBackreference',
                                    "'Backreference \', itoa(groupNumber), ' refers to non-existent or forward group (current group: ', itoa(parser.currentGroup), ')'")
        return false
    }

    // Create BACKREF state
    if (!NAVRegexParserAddState(parser, NFA_STATE_BACKREF)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildBackreference',
                                    'Failed to create BACKREF state')
        return false
    }

    stateId = parser.stateCount

    // Set the group number this backreference refers to
    parser.states[stateId].groupNumber = groupNumber

    // Build fragment
    // BACKREF states have one out transition (to continue matching after the backreference)
    fragment.startState = stateId
    fragment.outCount = 1
    set_length_array(fragment.outStates, 1)
    fragment.outStates[1] = stateId

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildBackreference ]: Created fragment for backreference \', itoa(groupNumber), ' (state=', itoa(stateId), ')'")
    #END_IF

    return true
}


// ============================================================================
// CONCATENATION
// ============================================================================

/**
 * @function NAVRegexParserBuildConcatenation
 * @private
 * @description Build NFA fragment for concatenation of two fragments.
 *
 * Connects fragment1 to fragment2 in sequence by patching fragment1's
 * out states to fragment2's start state.
 *
 * Example:
 *   Input: fragment1=[a], fragment2=[b]
 *   Result: [a] --> [b]
 *
 * Thompson's Construction:
 *   fragment1.out --epsilon--> fragment2.start
 *   result.start = fragment1.start
 *   result.out = fragment2.out
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} fragment1 - First fragment (pass by reference)
 * @param {_NAVRegexNFAFragment} fragment2 - Second fragment (pass by reference)
 * @param {_NAVRegexNFAFragment} result - Output concatenated fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildConcatenation(_NAVRegexParserState parser,
                                                        _NAVRegexNFAFragment fragment1,
                                                        _NAVRegexNFAFragment fragment2,
                                                        _NAVRegexNFAFragment result) {
    // Validate fragments
    if (fragment1.startState == 0 || fragment2.startState == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildConcatenation',
                                    'Invalid fragment: startState is 0')
        return false
    }

    // Connect fragment1's out states to fragment2's start
    if (!NAVRegexParserPatchFragment(parser, fragment1, fragment2.startState)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildConcatenation',
                                    'Failed to patch fragment1 to fragment2')
        return false
    }

    // Build result fragment
    result.startState = fragment1.startState
    result.outCount = fragment2.outCount
    result.outStates = fragment2.outStates

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildConcatenation ]: Connected fragments (start=', itoa(result.startState), ', outs=', itoa(result.outCount), ')'")
    #END_IF

    return true
}


/**
 * @function NAVRegexParserConcatenateFragmentStack
 * @private
 * @description Concatenates all fragments currently on the fragment stack.
 *
 * Pops all fragments from the stack (which are in LIFO/reverse order),
 * then concatenates them in their original parse order (FIFO). This ensures
 * that patterns like /(a)(b)(c)/ build an NFA starting with group 1, not group 3.
 *
 * The function:
 *   1. Collects all fragments from stack into temporary array (reversing LIFO)
 *   2. Starts with the LAST popped fragment (which was FIRST pushed)
 *   3. Concatenates remaining fragments in correct order
 *
 * @param {_NAVRegexParserState} parser - Parser state (modified: stack emptied)
 * @param {_NAVRegexNFAFragment} result - Output concatenated fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserConcatenateFragmentStack(_NAVRegexParserState parser,
                                                             _NAVRegexNFAFragment result) {
    stack_var _NAVRegexNFAFragment fragments[MAX_REGEX_PARSER_DEPTH]
    stack_var integer fragmentCount
    stack_var integer i
    stack_var _NAVRegexNFAFragment currentFragment

    // Collect all fragments from stack (they're in reverse order)
    fragmentCount = 0
    while (parser.fragmentStackDepth > 0) {
        fragmentCount++
        if (!NAVRegexParserPopFragment(parser, fragments[fragmentCount])) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserConcatenateFragmentStack',
                                        'Failed to pop fragment from stack')
            return false
        }
    }

    // Start with the LAST popped (FIRST pushed) fragment
    result = fragments[fragmentCount]

    // Concatenate remaining fragments in correct order (first to last)
    for (i = fragmentCount - 1; i >= 1; i--) {
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserConcatenateFragmentStack ]: Concatenating fragment ', itoa(i), '/', itoa(fragmentCount)")
        #END_IF
        if (!NAVRegexParserBuildConcatenation(parser, result, fragments[i], currentFragment)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserConcatenateFragmentStack',
                                        'Failed to concatenate fragments')
            return false
        }
        result = currentFragment
    }

    return true
}


// ============================================================================
// ALTERNATION
// ============================================================================

/**
 * @function NAVRegexParserBuildAlternation
 * @private
 * @description Build NFA fragment for alternation (|) of two fragments.
 *
 * Creates a SPLIT state that branches to both fragments, then collects
 * their out states.
 *
 * Example:
 *   Input: fragment1=[a], fragment2=[b]
 *   Result: [SPLIT] --epsilon--> [a]
 *                   --epsilon--> [b]
 *
 * Thompson's Construction:
 *   Create SPLIT state
 *   SPLIT --epsilon--> fragment1.start
 *   SPLIT --epsilon--> fragment2.start
 *   result.start = SPLIT
 *   result.out = fragment1.out + fragment2.out
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} fragment1 - First alternative (pass by reference)
 * @param {_NAVRegexNFAFragment} fragment2 - Second alternative (pass by reference)
 * @param {_NAVRegexNFAFragment} result - Output alternation fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildAlternation(_NAVRegexParserState parser,
                                                      _NAVRegexNFAFragment fragment1,
                                                      _NAVRegexNFAFragment fragment2,
                                                      _NAVRegexNFAFragment result) {
    stack_var integer splitState
    stack_var integer i

    // Validate fragments
    if (fragment1.startState == 0 || fragment2.startState == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildAlternation',
                                    'Invalid fragment: startState is 0')
        return false
    }

    // Create SPLIT state
    if (!NAVRegexParserAddState(parser, NFA_STATE_SPLIT)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildAlternation',
                                    'Failed to create SPLIT state')
        return false
    }

    splitState = parser.stateCount

    // Add epsilon transitions to both alternatives
    if (!NAVRegexParserAddTransition(parser, splitState, fragment1.startState, true)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildAlternation',
                                    'Failed to add transition to fragment1')
        return false
    }

    if (!NAVRegexParserAddTransition(parser, splitState, fragment2.startState, true)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildAlternation',
                                    'Failed to add transition to fragment2')
        return false
    }

    // Combine out states from both fragments
    result.startState = splitState
    result.outCount = fragment1.outCount + fragment2.outCount

    // Validate combined out count doesn't exceed array size
    if (result.outCount > 8) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildAlternation',
                                    "'Too many out states: ', itoa(result.outCount)")
        return false
    }

    set_length_array(result.outStates, result.outCount)

    // Copy fragment1's out states
    for (i = 1; i <= fragment1.outCount; i++) {
        result.outStates[i] = fragment1.outStates[i]
    }

    // Copy fragment2's out states
    for (i = 1; i <= fragment2.outCount; i++) {
        result.outStates[fragment1.outCount + i] = fragment2.outStates[i]
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildAlternation ]: Created SPLIT state ', itoa(splitState), ' with ', itoa(result.outCount), ' out states'")
    #END_IF

    return true
}


// ============================================================================
// ZERO OR ONE (?)
// ============================================================================

/**
 * @function NAVRegexParserBuildZeroOrOne
 * @private
 * @description Build NFA fragment for zero-or-one quantifier (?).
 *
 * Creates a SPLIT state that can either match the fragment or skip it.
 *
 * Example:
 *   Input: fragment=[a], optional
 *   Result: [SPLIT] --epsilon--> [a] --> (out1)
 *                   --epsilon--> (out2, skip)
 *
 * Thompson's Construction:
 *   Create SPLIT state
 *   For greedy (?): SPLIT --epsilon--> fragment.start (first), skip (second)
 *   For lazy (??): SPLIT skip (first), --epsilon--> fragment.start (second)
 *   SPLIT --epsilon--> (new out state)
 *   result.start = SPLIT
 *   result.out = fragment.out + SPLIT (for skip path)
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} fragment - Fragment to make optional (pass by reference)
 * @param {char} isLazy - True for lazy/non-greedy quantifier (??)
 * @param {_NAVRegexNFAFragment} result - Output fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildZeroOrOne(_NAVRegexParserState parser,
                                                    _NAVRegexNFAFragment fragment,
                                                    char isLazy,
                                                    _NAVRegexNFAFragment result) {
    stack_var integer splitState
    stack_var integer i

    // Validate fragment
    if (fragment.startState == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildZeroOrOne',
                                    'Invalid fragment: startState is 0')
        return false
    }

    // Create SPLIT state
    if (!NAVRegexParserAddState(parser, NFA_STATE_SPLIT)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildZeroOrOne',
                                    'Failed to create SPLIT state')
        return false
    }

    splitState = parser.stateCount

    // Add transitions in correct order based on greediness
    if (isLazy) {
        // Lazy: Add placeholder for skip path first
        if (!NAVRegexParserAddTransition(parser, splitState, 1, true)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildZeroOrOne',
                                        'Failed to add placeholder skip transition')
            return false
        }

        // Add match path (becomes transitions[2])
        if (!NAVRegexParserAddTransition(parser, splitState, fragment.startState, true)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildZeroOrOne',
                                        'Failed to add transition to fragment')
            return false
        }
    }
    else {
        // Greedy: Add match path first (becomes transitions[1])
        if (!NAVRegexParserAddTransition(parser, splitState, fragment.startState, true)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildZeroOrOne',
                                        'Failed to add transition to fragment')
            return false
        }
        // Skip path will be added later as transitions[2] during patching
    }

    // Build result: start=SPLIT, outs=fragment.out + SPLIT (skip path)
    result.startState = splitState
    result.outCount = fragment.outCount + 1

    if (result.outCount > 8) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildZeroOrOne',
                                    "'Too many out states: ', itoa(result.outCount)")
        return false
    }

    set_length_array(result.outStates, result.outCount)

    // Copy fragment's out states
    for (i = 1; i <= fragment.outCount; i++) {
        result.outStates[i] = fragment.outStates[i]
    }

    // Add SPLIT as out state (skip path)
    result.outStates[result.outCount] = splitState

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildZeroOrOne ]: Created ? quantifier (split=', itoa(splitState), ', outs=', itoa(result.outCount), ', lazy=', itoa(isLazy), ')'")
    #END_IF

    return true
}


// ============================================================================
// ZERO OR MORE (\*\)
// ============================================================================

/**
 * @function NAVRegexParserBuildZeroOrMore
 * @private
 * @description Build NFA fragment for zero-or-more quantifier (\*\).
 *
 * Creates a SPLIT state that can repeat the fragment or skip it entirely.
 *
 * Example:
 *   Input: fragment=[a]
 *   Result: [SPLIT] --epsilon--> [a] --epsilon--> [SPLIT]
 *                   --epsilon--> (out, skip)
 *
 * Thompson's Construction:
 *   Create SPLIT state
 *   For greedy (\*\): SPLIT --epsilon--> fragment.start (first), SPLIT skip (second)
 *   For lazy (\*?): SPLIT skip (first), SPLIT --epsilon--> fragment.start (second)
 *   Patch fragment.out --epsilon--> SPLIT (loop back)
 *   result.start = SPLIT
 *   result.out = SPLIT (skip path)
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} fragment - Fragment to repeat (pass by reference)
 * @param {char} isLazy - True for lazy/non-greedy quantifier (\*?)
 * @param {_NAVRegexNFAFragment} result - Output fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildZeroOrMore(_NAVRegexParserState parser,
                                                     _NAVRegexNFAFragment fragment,
                                                     char isLazy,
                                                     _NAVRegexNFAFragment result) {
    stack_var integer splitState

    // Validate fragment
    if (fragment.startState == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildZeroOrMore',
                                    'Invalid fragment: startState is 0')
        return false
    }

    // Create SPLIT state
    if (!NAVRegexParserAddState(parser, NFA_STATE_SPLIT)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildZeroOrMore',
                                    'Failed to create SPLIT state')
        return false
    }

    splitState = parser.stateCount

    // Add epsilon transitions in the correct order based on greediness
    // For greedy: match path first, skip path second (added later during patching)
    // For lazy: skip path first (placeholder), match path second

    if (isLazy) {
        // Lazy: Add placeholder for skip path first (will be updated during patching)
        // We add a transition to state 1 (initial EPSILON) as a placeholder
        // This will be replaced/updated when the fragment is patched
        if (!NAVRegexParserAddTransition(parser, splitState, 1, true)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildZeroOrMore',
                                        'Failed to add placeholder skip transition')
            return false
        }

        // Now add match path (becomes transitions[2])
        if (!NAVRegexParserAddTransition(parser, splitState, fragment.startState, true)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildZeroOrMore',
                                        'Failed to add transition to fragment')
            return false
        }
    }
    else {
        // Greedy: Add match path first (becomes transitions[1])
        if (!NAVRegexParserAddTransition(parser, splitState, fragment.startState, true)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildZeroOrMore',
                                        'Failed to add transition to fragment')
            return false
        }
        // Skip path will be added later as transitions[2] during patching
    }

    // Patch fragment's out states back to SPLIT (loop)
    if (!NAVRegexParserPatchFragment(parser, fragment, splitState)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildZeroOrMore',
                                    'Failed to patch fragment back to SPLIT')
        return false
    }

    // Build result: start=SPLIT, out=SPLIT (skip path)
    result.startState = splitState
    result.outCount = 1
    set_length_array(result.outStates, 1)
    result.outStates[1] = splitState

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildZeroOrMore ]: Created * quantifier (split=', itoa(splitState), ', lazy=', itoa(isLazy), ')'")
    #END_IF

    return true
}


// ============================================================================
// ONE OR MORE (+)
// ============================================================================

/**
 * @function NAVRegexParserBuildOneOrMore
 * @private
 * @description Build NFA fragment for one-or-more quantifier (+).
 *
 * Requires at least one match, then can repeat.
 *
 * Example:
 *   Input: fragment=[a]
 *   Result: [a] --epsilon--> [SPLIT] --epsilon--> [a] (loop)
 *                            --epsilon--> (out)
 *
 * Thompson's Construction:
 *   Create SPLIT state
 *   Patch fragment.out --epsilon--> SPLIT
 *   For greedy (+): SPLIT --epsilon--> fragment.start (loop), then exit
 *   For lazy (+?): SPLIT exit first, then --epsilon--> fragment.start (loop)
 *   result.start = fragment.start
 *   result.out = SPLIT (exit path)
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} fragment - Fragment to repeat (pass by reference)
 * @param {char} isLazy - True for lazy/non-greedy quantifier (+?)
 * @param {_NAVRegexNFAFragment} result - Output fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildOneOrMore(_NAVRegexParserState parser,
                                                    _NAVRegexNFAFragment fragment,
                                                    char isLazy,
                                                    _NAVRegexNFAFragment result) {
    stack_var integer splitState

    // Validate fragment
    if (fragment.startState == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildOneOrMore',
                                    'Invalid fragment: startState is 0')
        return false
    }

    // Create SPLIT state
    if (!NAVRegexParserAddState(parser, NFA_STATE_SPLIT)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildOneOrMore',
                                    'Failed to create SPLIT state')
        return false
    }

    splitState = parser.stateCount

    // Patch fragment's out states to SPLIT
    if (!NAVRegexParserPatchFragment(parser, fragment, splitState)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildOneOrMore',
                                    'Failed to patch fragment to SPLIT')
        return false
    }

    // Add transitions in correct order based on greediness
    if (isLazy) {
        // Lazy: Add placeholder for exit first, then loop
        if (!NAVRegexParserAddTransition(parser, splitState, 1, true)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildOneOrMore',
                                        'Failed to add placeholder exit transition')
            return false
        }

        // Add loop transition (becomes transitions[2])
        if (!NAVRegexParserAddTransition(parser, splitState, fragment.startState, true)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildOneOrMore',
                                        'Failed to add loop transition')
            return false
        }
    }
    else {
        // Greedy: Add loop first (becomes transitions[1])
        if (!NAVRegexParserAddTransition(parser, splitState, fragment.startState, true)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildOneOrMore',
                                        'Failed to add loop transition')
            return false
        }
        // Exit will be added later as transitions[2] during patching
    }

    // Build result: start=fragment.start, out=SPLIT (exit path)
    result.startState = fragment.startState
    result.outCount = 1
    set_length_array(result.outStates, 1)
    result.outStates[1] = splitState

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildOneOrMore ]: Created + quantifier (split=', itoa(splitState), ', lazy=', itoa(isLazy), ')'")
    #END_IF

    return true
}


// ============================================================================
// BOUNDED QUANTIFIER {n,m}
// ============================================================================

/**
 * @function NAVRegexParserBuildBoundedQuantifier
 * @private
 * @description Build NFA fragment for bounded quantifier {n,m}.
 *
 * Creates n required copies followed by (m-n) optional copies.
 *
 * Examples:
 *   {3,5}: [a][a][a][a?][a?]
 *   {2,2}: [a][a]
 *   {0,3}: [a?][a?][a?]
 *   {3,}:  [a][a][a][a*] (handled by setting max=-1)
 *
 * Algorithm:
 *   1. Create n mandatory concatenated copies
 *   2. Create (m-n) optional copies with ZeroOrOne
 *   3. Concatenate all together
 *
 * Special cases:
 *   - {0,0}: Returns epsilon fragment
 *   - {n,n}: Exactly n copies (no optional)
 *   - {n,-1}: n required + unbounded (uses ZeroOrMore for tail)
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} fragment - Fragment to repeat (pass by reference)
 * @param {integer} min - Minimum repetitions
 * @param {sinteger} max - Maximum repetitions (-1 = unlimited)
 * @param {char} isLazy - True for lazy/non-greedy quantifier ({n,m}?)
 * @param {_NAVRegexNFAFragment} result - Output fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildBoundedQuantifier(_NAVRegexParserState parser,
                                                            _NAVRegexNFAFragment fragment,
                                                            integer min,
                                                            sinteger max,
                                                            char isLazy,
                                                            _NAVRegexNFAFragment result) {
    stack_var integer i
    stack_var _NAVRegexNFAFragment copy
    stack_var _NAVRegexNFAFragment temp
    stack_var _NAVRegexNFAFragment optional

    // Validate fragment
    if (fragment.startState == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildBoundedQuantifier',
                                    'Invalid fragment: startState is 0')
        return false
    }

    // Validate bounds
    if (max >= 0 && min > type_cast(max)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildBoundedQuantifier',
                                    "'Invalid bounds: min=', itoa(min), ', max=', itoa(max)")
        return false
    }

    // Special case: {0,0} - epsilon (match nothing)
    if (min == 0 && max == 0) {
        return NAVRegexParserCreateEpsilonFragment(parser, result)
    }

    // Build min required copies
    if (min > 0) {
        // Clone first copy (don't reuse original fragment directly)
        // This prevents the original from being modified during concatenation
        if (!NAVRegexParserCloneFragment(parser, fragment, result)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserBuildBoundedQuantifier',
                                        'Failed to clone required copy 1')
            return false
        }

        // Concatenate remaining min-1 copies (clone each one)
        for (i = 2; i <= min; i++) {
            if (!NAVRegexParserCloneFragment(parser, fragment, copy)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                            'NAVRegexParserBuildBoundedQuantifier',
                                            "'Failed to clone required copy ', itoa(i)")
                return false
            }
            if (!NAVRegexParserBuildConcatenation(parser, result, copy, temp)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                            'NAVRegexParserBuildBoundedQuantifier',
                                            "'Failed to concatenate required copy ', itoa(i)")
                return false
            }
            result = temp
        }
    }
    else {
        // min=0: Start with epsilon-like result
        result.startState = 0
        result.outCount = 0
    }

    // Handle optional copies (max - min) or unbounded
    if (max == -1) {
        // Unbounded: use ZeroOrMore for remaining
        if (min == 0) {
            // {0,} is equivalent to *
            return NAVRegexParserBuildZeroOrMore(parser, fragment, isLazy, result)
        }
        else {
            // {n,} = n required copies + *
            copy = fragment
            if (!NAVRegexParserBuildZeroOrMore(parser, copy, isLazy, temp)) {
                return false
            }
            if (!NAVRegexParserBuildConcatenation(parser, result, temp, copy)) {
                return false
            }
            result = copy
        }
    }
    else if (type_cast(max) > min) {
        // Add (max-min) optional copies (clone each one)
        for (i = 1; i <= (type_cast(max) - min); i++) {
            if (!NAVRegexParserCloneFragment(parser, fragment, copy)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                            'NAVRegexParserBuildBoundedQuantifier',
                                            "'Failed to clone optional copy ', itoa(i)")
                return false
            }
            if (!NAVRegexParserBuildZeroOrOne(parser, copy, isLazy, optional)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                            'NAVRegexParserBuildBoundedQuantifier',
                                            "'Failed to create optional copy ', itoa(i)")
                return false
            }

            if (min == 0 && i == 1) {
                // First optional when min=0
                result = optional
            }
            else {
                if (!NAVRegexParserBuildConcatenation(parser, result, optional, temp)) {
                    return false
                }
                result = temp
            }
        }
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildBoundedQuantifier ]: Created {', itoa(min), ',', itoa(max), '} quantifier'")
    #END_IF

    return true
}


// ============================================================================
// CAPTURING GROUPS
// ============================================================================

/**
 * @function NAVRegexParserBuildCapturingGroup
 * @private
 * @description Build NFA fragment for a capturing group (...).
 *
 * Capturing groups mark regions of the input that should be saved for
 * later retrieval (e.g., for extracting matched substrings or backreferences).
 *
 * Creates two CAPTURE states that wrap the group's content:
 * - CAPTURE_START: Marks the beginning of the group
 * - CAPTURE_END: Marks the end of the group
 *
 * Both states store the group number (1, 2, 3, etc.) and are connected
 * via epsilon transitions to the group's content.
 *
 * Example:
 *   Pattern: (abc)
 *   NFA: [CAPTURE_START #1] -> [a] -> [b] -> [c] -> [CAPTURE_END #1]
 *
 * Thompson's Construction:
 *   1. Create CAPTURE_START state with group number
 *   2. Add epsilon transition to group content
 *   3. Patch group content's outs to CAPTURE_END state
 *   4. Result: start=CAPTURE_START, out=CAPTURE_END
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} content - Group content fragment (pass by reference)
 * @param {integer} groupNumber - Capture group number (1-based)
 * @param {_NAVRegexNFAFragment} result - Output group fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildCapturingGroup(_NAVRegexParserState parser,
                                                         _NAVRegexNFAFragment content,
                                                         integer groupNumber,
                                                         char groupName[],
                                                         _NAVRegexNFAFragment result) {
    stack_var integer captureStartState
    stack_var integer captureEndState

    // Validate content fragment
    if (content.startState == 0 || content.outCount == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildCapturingGroup',
                                    'Invalid content fragment')
        return false
    }

    // Validate group number
    if (groupNumber < 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildCapturingGroup',
                                    "'Invalid group number: ', itoa(groupNumber)")
        return false
    }

    // Create CAPTURE_START state
    if (!NAVRegexParserAddState(parser, NFA_STATE_CAPTURE_START)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildCapturingGroup',
                                    'Failed to create CAPTURE_START state')
        return false
    }

    captureStartState = parser.stateCount
    parser.states[captureStartState].groupNumber = groupNumber
    parser.states[captureStartState].groupName = groupName

    // Add epsilon transition from CAPTURE_START to content
    if (!NAVRegexParserAddTransition(parser, captureStartState, content.startState, true)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildCapturingGroup',
                                    'Failed to add transition to content')
        return false
    }

    // Create CAPTURE_END state
    if (!NAVRegexParserAddState(parser, NFA_STATE_CAPTURE_END)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildCapturingGroup',
                                    'Failed to create CAPTURE_END state')
        return false
    }

    captureEndState = parser.stateCount
    parser.states[captureEndState].groupNumber = groupNumber
    parser.states[captureEndState].groupName = groupName

    // Patch content's out states to CAPTURE_END
    if (!NAVRegexParserPatchFragment(parser, content, captureEndState)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildCapturingGroup',
                                    'Failed to patch content to CAPTURE_END')
        return false
    }

    // Build result fragment
    result.startState = captureStartState
    result.outCount = 1
    set_length_array(result.outStates, 1)
    result.outStates[1] = captureEndState

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildCapturingGroup ]: Created group #', itoa(groupNumber), ' (start=', itoa(captureStartState), ', end=', itoa(captureEndState), ')'")
    #END_IF

    return true
}


// ============================================================================
// NON-CAPTURING GROUPS
// ============================================================================

/**
 * @function NAVRegexParserBuildNonCapturingGroup
 * @private
 * @description Build NFA fragment for a non-capturing group (?:...).
 *
 * Non-capturing groups provide grouping for precedence and quantifiers
 * without creating a capture group. They are simply pass-through wrappers
 * around the content.
 *
 * Since non-capturing groups don't need special state markers, the result
 * is just the content fragment itself.
 *
 * Example:
 *   Pattern: (?:abc)
 *   NFA: [a] -> [b] -> [c]  (no capture states)
 *
 * Implementation:
 *   Simply returns the content fragment as-is, no wrapper needed.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} content - Group content fragment (pass by reference)
 * @param {_NAVRegexNFAFragment} result - Output group fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildNonCapturingGroup(_NAVRegexParserState parser,
                                                            _NAVRegexNFAFragment content,
                                                            _NAVRegexNFAFragment result) {
    // Special case: Flag-only groups like (?i) or (?-i) return empty fragments
    // These have BOTH startState=0 and outCount=0 - this is valid for flag-only groups
    if (content.startState == 0 && content.outCount == 0) {
        // Flag-only group - create epsilon transition
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserBuildNonCapturingGroup ]: Flag-only group (empty fragment)'")
        #END_IF
        return NAVRegexParserCreateEpsilonFragment(parser, result)
    }

    // Validate content fragment for normal non-capturing groups
    if (content.startState == 0 || content.outCount == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildNonCapturingGroup',
                                    'Invalid content fragment')
        return false
    }

    // Non-capturing groups are pass-through - just return the content
    result = content

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserBuildNonCapturingGroup ]: Created non-capturing group (start=', itoa(result.startState), ')'")
    #END_IF

    return true
}


// ============================================================================
// LOOKAHEAD ASSERTIONS
// ============================================================================

/**
 * @function NAVRegexParserBuildLookahead
 * @private
 * @description Build NFA fragment for lookahead assertions (?=...) or (?!...).
 *
 * Lookahead assertions are zero-width assertions that check if a pattern
 * matches ahead of the current position without consuming input.
 *
 * - Positive lookahead (?=...): Succeeds if the pattern matches ahead
 * - Negative lookahead (?!...): Succeeds if the pattern does NOT match ahead
 *
 * Implementation:
 * Creates a single lookahead state that stores:
 * - The start state of the sub-expression NFA (in groupNumber field)
 * - Whether it's positive or negative (in isNegated field)
 *
 * The sub-expression is a complete NFA fragment that will be matched
 * during execution without advancing the input position.
 *
 * Example:
 *   Pattern: a(?=b)c
 *   Matches: "abc" (lookahead checks for 'b' without consuming it)
 *   NFA: [a] -> [LOOKAHEAD_POS->b] -> [c]
 *
 * Thompson's Construction:
 *   1. Create LOOKAHEAD state (positive or negative)
 *   2. Store sub-expression start state reference
 *   3. Result: start=LOOKAHEAD, out=LOOKAHEAD (single out state)
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} subExpr - Sub-expression fragment (pass by reference)
 * @param {char} isNegative - True for negative lookahead (?!...), false for positive (?=...)
 * @param {_NAVRegexNFAFragment} result - Output lookahead fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildLookahead(_NAVRegexParserState parser,
                                                    _NAVRegexNFAFragment subExpr,
                                                    char isNegative,
                                                    _NAVRegexNFAFragment result) {
    stack_var integer lookaheadState
    stack_var integer stateType

    // Validate sub-expression fragment
    if (subExpr.startState == 0 || subExpr.outCount == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildLookahead',
                                    'Invalid sub-expression fragment')
        return false
    }

    // Determine state type
    if (isNegative) {
        stateType = NFA_STATE_LOOKAHEAD_NEG
    }
    else {
        stateType = NFA_STATE_LOOKAHEAD_POS
    }

    // Create lookahead state
    if (!NAVRegexParserAddState(parser, stateType)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildLookahead',
                                    'Failed to create lookahead state')
        return false
    }

    lookaheadState = parser.stateCount

    // Store sub-expression start state in groupNumber field
    // (repurposing this field for lookaround assertions)
    parser.states[lookaheadState].groupNumber = subExpr.startState
    parser.states[lookaheadState].isNegated = isNegative

    // Build result fragment
    // Lookahead is zero-width, so it just has a single out state pointing to itself
    result.startState = lookaheadState
    result.outCount = 1
    set_length_array(result.outStates, 1)
    result.outStates[1] = lookaheadState

    #IF_DEFINED REGEX_PARSER_DEBUG
    if (isNegative) {
        NAVLog("'[ ParserBuildLookahead ]: Created negative lookahead (?!...) at state ', itoa(lookaheadState), ' (subExpr=', itoa(subExpr.startState), ')'")
    }
    else {
        NAVLog("'[ ParserBuildLookahead ]: Created positive lookahead (?=...) at state ', itoa(lookaheadState), ' (subExpr=', itoa(subExpr.startState), ')'")
    }
    #END_IF

    return true
}


// ============================================================================
// LOOKBEHIND ASSERTIONS
// ============================================================================

/**
 * @function NAVRegexParserBuildLookbehind
 * @private
 * @description Build NFA fragment for lookbehind assertions (?<=...) or (?<!...).
 *
 * Lookbehind assertions are zero-width assertions that check if a pattern
 * matches behind the current position without consuming input.
 *
 * - Positive lookbehind (?<=...): Succeeds if the pattern matches behind
 * - Negative lookbehind (?<!...): Succeeds if the pattern does NOT match behind
 *
 * Implementation:
 * Creates a single lookbehind state that stores:
 * - The start state of the sub-expression NFA (in groupNumber field)
 * - Whether it's positive or negative (in isNegated field)
 *
 * The sub-expression is a complete NFA fragment that will be matched
 * in reverse during execution without changing the input position.
 *
 * Example:
 *   Pattern: (?<=a)bc
 *   Matches: "abc" (lookbehind checks for 'a' before current position)
 *   NFA: [LOOKBEHIND_POS->a] -> [b] -> [c]
 *
 * Thompson's Construction:
 *   1. Create LOOKBEHIND state (positive or negative)
 *   2. Store sub-expression start state reference
 *   3. Result: start=LOOKBEHIND, out=LOOKBEHIND (single out state)
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} subExpr - Sub-expression fragment (pass by reference)
 * @param {char} isNegative - True for negative lookbehind (?<!...), false for positive (?<=...)
 * @param {_NAVRegexNFAFragment} result - Output lookbehind fragment (pass by reference)
 * @returns {char} true on success, false on failure
 */
define_function char NAVRegexParserBuildLookbehind(_NAVRegexParserState parser,
                                                     _NAVRegexNFAFragment subExpr,
                                                     char isNegative,
                                                     _NAVRegexNFAFragment result) {
    stack_var integer lookbehindState
    stack_var integer stateType

    // Validate sub-expression fragment
    if (subExpr.startState == 0 || subExpr.outCount == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildLookbehind',
                                    'Invalid sub-expression fragment')
        return false
    }

    // Determine state type
    if (isNegative) {
        stateType = NFA_STATE_LOOKBEHIND_NEG
    }
    else {
        stateType = NFA_STATE_LOOKBEHIND_POS
    }

    // Create lookbehind state
    if (!NAVRegexParserAddState(parser, stateType)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserBuildLookbehind',
                                    'Failed to create lookbehind state')
        return false
    }

    lookbehindState = parser.stateCount

    // Store sub-expression start state in groupNumber field
    // (repurposing this field for lookaround assertions)
    parser.states[lookbehindState].groupNumber = subExpr.startState
    parser.states[lookbehindState].isNegated = isNegative

    // Build result fragment
    // Lookbehind is zero-width, so it just has a single out state pointing to itself
    result.startState = lookbehindState
    result.outCount = 1
    set_length_array(result.outStates, 1)
    result.outStates[1] = lookbehindState

    #IF_DEFINED REGEX_PARSER_DEBUG
    if (isNegative) {
        NAVLog("'[ ParserBuildLookbehind ]: Created negative lookbehind (?<!...) at state ', itoa(lookbehindState), ' (subExpr=', itoa(subExpr.startState), ')'")
    }
    else {
        NAVLog("'[ ParserBuildLookbehind ]: Created positive lookbehind (?<=...) at state ', itoa(lookbehindState), ' (subExpr=', itoa(subExpr.startState), ')'")
    }
    #END_IF

    return true
}


/**
 * @function NAVRegexParserParseExpression
 * @public
 * @description Main token dispatcher that parses a range of tokens into an NFA fragment.
 *
 * This function implements the core parsing logic with operator precedence:
 * - Quantifiers (\*, +, ?, {n,m}) bind tightest (applied immediately)
 * - Concatenation is implicit (sequential fragments are joined)
 * - Alternation (|) has lowest precedence (splits into branches)
 *
 * Algorithm:
 * 1. Loop through tokens in the given range
 * 2. For each token, dispatch to appropriate builder function
 * 3. Apply quantifiers immediately to the last fragment
 * 4. Concatenate sequential fragments
 * 5. Handle alternation by splitting into branches
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} startToken - First token index (1-based)
 * @param {integer} endToken - Last token index (inclusive)
 * @param {_NAVRegexNFAFragment} result - Output fragment
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserParseExpression(_NAVRegexParserState parser,
                                                     integer startToken,
                                                     integer endToken,
                                                     _NAVRegexNFAFragment result) {
    stack_var integer i
    stack_var _NAVRegexNFAFragment currentFragment
    stack_var _NAVRegexNFAFragment temp
    stack_var integer alternationStart
    stack_var char hasAlternation
    stack_var integer initialStackDepth

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserParseExpression ]: Parsing tokens ', itoa(startToken), ' to ', itoa(endToken)")
    #END_IF

    // === BASE CASE: Empty token range ===
    if (startToken > endToken) {
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: BASE CASE - empty range, creating epsilon'")
        #END_IF

        // Create epsilon fragment
        if (!NAVRegexParserCreateEpsilonFragment(parser, result)) {
            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[ ParserParseExpression ]: BASE CASE - CreateEpsilonFragment failed'")
            #END_IF
            return false
        }

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: BASE CASE - returning true'")
        #END_IF

        return true
    }

    // Save the initial stack depth so we only concatenate fragments added during THIS parse call
    initialStackDepth = parser.fragmentStackDepth

    hasAlternation = false
    alternationStart = 0

    // FIRST PASS: Check if there's any alternation at this level (not inside groups/lookarounds)
    // If there is, skip the main token processing loop and go directly to ProcessAlternation
    for (i = startToken; i <= endToken; i++) {
        if (parser.tokens[i].type == REGEX_TOKEN_ALTERNATION) {
            hasAlternation = true
            if (alternationStart == 0) {
                alternationStart = i
            }
        }
        // Skip tokens inside groups/lookarounds - they don't count as top-level alternation
        else if (parser.tokens[i].type == REGEX_TOKEN_GROUP_START ||
                 parser.tokens[i].type == REGEX_TOKEN_LOOKAHEAD_POSITIVE ||
                 parser.tokens[i].type == REGEX_TOKEN_LOOKAHEAD_NEGATIVE ||
                 parser.tokens[i].type == REGEX_TOKEN_LOOKBEHIND_POSITIVE ||
                 parser.tokens[i].type == REGEX_TOKEN_LOOKBEHIND_NEGATIVE) {
            stack_var integer groupEnd
            groupEnd = NAVRegexParserFindMatchingGroupEnd(parser, i, parser.tokenCount - 1)
            if (groupEnd > 0) {
                i = groupEnd  // Skip to GROUP_END
            }
        }
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    if (hasAlternation) {
        NAVLog("'[ ParserParseExpression ]: Alternation detected, skipping token loop and using ProcessAlternation'")
    } else {
        NAVLog("'[ ParserParseExpression ]: No alternation, using normal token loop'")
    }
    #END_IF

    // If there's alternation, skip the main loop entirely
    if (hasAlternation) {
        // Jump directly to the alternation handling code below
    } else {
        // No alternation - process tokens normally
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Starting token loop, depth=', itoa(parser.groupDepth), ', initialStackDepth=', itoa(initialStackDepth), ', fragmentStackDepth=', itoa(parser.fragmentStackDepth)")
        #END_IF    // Process each token

        for (i = startToken; i <= endToken; i++) {
            stack_var sinteger tokenResult

            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[ ParserParseExpression ]: Processing token ', itoa(i), ' type=', itoa(parser.tokens[i].type), ' depth=', itoa(parser.groupDepth)")
            #END_IF

            // Try to process as a simple token (literals, classes, anchors, quantifiers, flags, alternation)
            tokenResult = NAVRegexParserProcessSimpleToken(parser, parser.tokens[i], hasAlternation, alternationStart, i)

            if (tokenResult == 0) {
                // Error occurred
                return false
            } else if (tokenResult == 1) {
                // Successfully processed
                // If alternation was detected, stop processing and let ProcessAlternation handle all tokens
                if (hasAlternation) {
                    #IF_DEFINED REGEX_PARSER_DEBUG
                    NAVLog("'[ ParserParseExpression ]: Alternation detected, breaking out of token loop'")
                    #END_IF
                    break
                }
                continue
            }
            // tokenResult == -1 means not a simple token, fall through to handle groups

            select {
                // === GROUPS ===
                active (parser.tokens[i].type == REGEX_TOKEN_GROUP_START): {
                    stack_var integer groupEnd
                    stack_var char groupResult

                    // === RECURSION SAFETY: Check depth before entering group ===
                    parser.groupDepth++

                    #IF_DEFINED REGEX_PARSER_DEBUG
                    NAVLog("'[ DEPTH ] Entering group: depth now ', itoa(parser.groupDepth), ' (group #', itoa(parser.currentGroup + 1), ')'")
                    #END_IF

                    if (parser.groupDepth > MAX_REGEX_PARSER_DEPTH) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                                    'NAVRegexParserParseExpression',
                                                    "'Maximum nesting depth (', itoa(MAX_REGEX_PARSER_DEPTH), ') exceeded'")
                        parser.hasError = true
                        parser.errorMessage = 'Maximum nesting depth exceeded'
                        parser.groupDepth--
                        return false
                    }

                    // Process group using helper (finds GROUP_END, parses contents, builds fragment)
                    // WORKAROUND: NetLinx has trouble evaluating function return values in if statements
                    // at deep recursion (depth 15+). Store in local variable first.
                    groupResult = NAVRegexParserProcessGroup(parser, i, endToken, groupEnd, currentFragment)

                    if (!groupResult) {
                        // Helper failed - decrement depth and return
                        #IF_DEFINED REGEX_PARSER_DEBUG
                        NAVLog("'[ DEPTH ] ProcessGroup failed, decrementing: depth now ', itoa(parser.groupDepth - 1)")
                        #END_IF
                        parser.groupDepth--
                        return false
                    }

                    // Decrement depth after successful group processing
                    #IF_DEFINED REGEX_PARSER_DEBUG
                    NAVLog("'[ DEPTH ] Exiting group: depth was ', itoa(parser.groupDepth), ', decrementing to ', itoa(parser.groupDepth - 1)")
                    #END_IF
                    parser.groupDepth--

                    // Push group fragment onto stack
                    #IF_DEFINED REGEX_PARSER_DEBUG
                    NAVLog("'[ ParserParseExpression ]: Pushing group fragment onto stack'")
                    #END_IF
                    if (!NAVRegexParserPushFragment(parser, currentFragment)) {
                        return false
                    }

                    // Skip to after GROUP_END
                    i = groupEnd
                }

                // === LOOKAROUND ASSERTIONS ===
                active (parser.tokens[i].type == REGEX_TOKEN_LOOKAHEAD_POSITIVE ||
                        parser.tokens[i].type == REGEX_TOKEN_LOOKAHEAD_NEGATIVE ||
                        parser.tokens[i].type == REGEX_TOKEN_LOOKBEHIND_POSITIVE ||
                        parser.tokens[i].type == REGEX_TOKEN_LOOKBEHIND_NEGATIVE): {
                    stack_var integer groupEnd
                    stack_var char isNegative
                    stack_var char isLookbehind
                    stack_var _NAVRegexNFAFragment subExpr
                    stack_var char lookaroundResult

                    // Determine lookaround type
                    isNegative = (parser.tokens[i].type == REGEX_TOKEN_LOOKAHEAD_NEGATIVE ||
                                parser.tokens[i].type == REGEX_TOKEN_LOOKBEHIND_NEGATIVE)
                    isLookbehind = (parser.tokens[i].type == REGEX_TOKEN_LOOKBEHIND_POSITIVE ||
                                    parser.tokens[i].type == REGEX_TOKEN_LOOKBEHIND_NEGATIVE)

                    // === RECURSION SAFETY: Check depth before entering lookaround ===
                    parser.groupDepth++

                    #IF_DEFINED REGEX_PARSER_DEBUG
                    if (isLookbehind) {
                        if (isNegative) {
                            NAVLog("'[ DEPTH ] Entering negative lookbehind: depth now ', itoa(parser.groupDepth)")
                        } else {
                            NAVLog("'[ DEPTH ] Entering positive lookbehind: depth now ', itoa(parser.groupDepth)")
                        }
                    } else {
                        if (isNegative) {
                            NAVLog("'[ DEPTH ] Entering negative lookahead: depth now ', itoa(parser.groupDepth)")
                        } else {
                            NAVLog("'[ DEPTH ] Entering positive lookahead: depth now ', itoa(parser.groupDepth)")
                        }
                    }
                    #END_IF

                    if (parser.groupDepth > MAX_REGEX_PARSER_DEPTH) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                                    'NAVRegexParserParseExpression',
                                                    "'Maximum nesting depth (', itoa(MAX_REGEX_PARSER_DEPTH), ') exceeded in lookaround'")
                        parser.hasError = true
                        parser.errorMessage = 'Maximum nesting depth exceeded'
                        parser.groupDepth--
                        return false
                    }

                    // Find matching GROUP_END (lookarounds use same closing token)
                    groupEnd = NAVRegexParserFindMatchingGroupEnd(parser, i, endToken)
                    if (groupEnd == 0) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                                    'NAVRegexParserParseExpression',
                                                    "'Unmatched lookaround at token ', itoa(i)")
                        parser.groupDepth--
                        return false
                    }

                    // Parse lookaround sub-expression
                    if (i + 1 <= groupEnd - 1) {
                        stack_var char recursionResult
                        stack_var integer savedStackDepth

                        savedStackDepth = parser.fragmentStackDepth

                        #IF_DEFINED REGEX_PARSER_DEBUG
                        NAVLog("'[ ParserParseExpression ]: Parsing lookaround sub-expression - tokens ', itoa(i + 1), ' to ', itoa(groupEnd - 1)")
                        #END_IF

                        recursionResult = NAVRegexParserParseExpression(parser, i + 1, groupEnd - 1, subExpr)
                        parser.fragmentStackDepth = savedStackDepth

                        if (!recursionResult) {
                            parser.groupDepth--
                            return false
                        }
                    } else {
                        // Empty lookaround - this is an error
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                                    'NAVRegexParserParseExpression',
                                                    'Empty lookaround assertion')
                        parser.groupDepth--
                        return false
                    }

                    // Build lookaround NFA fragment
                    if (isLookbehind) {
                        lookaroundResult = NAVRegexParserBuildLookbehind(parser, subExpr, isNegative, currentFragment)
                    } else {
                        lookaroundResult = NAVRegexParserBuildLookahead(parser, subExpr, isNegative, currentFragment)
                    }

                    if (!lookaroundResult) {
                        parser.groupDepth--
                        return false
                    }

                    // Decrement depth after successful lookaround processing
                    #IF_DEFINED REGEX_PARSER_DEBUG
                    NAVLog("'[ DEPTH ] Exiting lookaround: depth was ', itoa(parser.groupDepth), ', decrementing to ', itoa(parser.groupDepth - 1)")
                    #END_IF
                    parser.groupDepth--

                    // Mark that this pattern uses lookarounds
                    parser.hasLookaround = true

                    // Push lookaround fragment onto stack
                    #IF_DEFINED REGEX_PARSER_DEBUG
                    NAVLog("'[ ParserParseExpression ]: Pushing lookaround fragment onto stack'")
                    #END_IF
                    if (!NAVRegexParserPushFragment(parser, currentFragment)) {
                        return false
                    }

                    // Skip to after GROUP_END
                    i = groupEnd
                }
            }
        }
    }  // End of else block (no alternation case)

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserParseExpression ]: Fragment stack depth: ', itoa(parser.fragmentStackDepth)")
    #END_IF

    // Handle alternation if present
    if (hasAlternation) {
        stack_var integer alternationPositions[MAX_REGEX_PARSER_DEPTH]
        stack_var integer alternationCount
        stack_var _NAVRegexNFAFragment branches[MAX_REGEX_PARSER_DEPTH]
        stack_var integer branchCount
        stack_var integer branchStart
        stack_var integer branchEnd
        stack_var integer j

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Processing alternation'")
        #END_IF

        // Find all alternation positions at THIS level (not inside nested groups/lookarounds)
        alternationCount = 0
        for (i = startToken; i <= endToken; i++) {
            if (parser.tokens[i].type == REGEX_TOKEN_ALTERNATION) {
                alternationCount++
                alternationPositions[alternationCount] = i
            }
            // Skip tokens inside groups/lookarounds - they don't count as alternation at this level
            else if (parser.tokens[i].type == REGEX_TOKEN_GROUP_START ||
                     parser.tokens[i].type == REGEX_TOKEN_LOOKAHEAD_POSITIVE ||
                     parser.tokens[i].type == REGEX_TOKEN_LOOKAHEAD_NEGATIVE ||
                     parser.tokens[i].type == REGEX_TOKEN_LOOKBEHIND_POSITIVE ||
                     parser.tokens[i].type == REGEX_TOKEN_LOOKBEHIND_NEGATIVE) {
                stack_var integer groupEnd
                groupEnd = NAVRegexParserFindMatchingGroupEnd(parser, i, parser.tokenCount - 1)
                if (groupEnd > 0) {
                    i = groupEnd  // Skip to GROUP_END
                }
            }
        }

        // Parse each branch
        branchCount = 0
        branchStart = startToken

        for (i = 1; i <= alternationCount; i++) {
            branchEnd = alternationPositions[i] - 1

            // Process this branch
            if (!NAVRegexParserProcessBranch(parser, branchStart, branchEnd, branches[branchCount + 1])) {
                return false
            }

            branchCount++
            branchStart = alternationPositions[i] + 1
        }

        // Parse final branch (after last alternation)
        branchEnd = endToken
        if (!NAVRegexParserProcessBranch(parser, branchStart, branchEnd, branches[branchCount + 1])) {
            parser.groupDepth--
            return false
        }
        branchCount++

        // Build alternation from all branches
        if (branchCount < 2) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserParseExpression',
                                        "'Invalid alternation: only ', itoa(branchCount), ' branches'")
            return false
        }

        // Start with first two branches
        if (!NAVRegexParserBuildAlternation(parser, branches[1], branches[2], result)) {
            return false
        }

        // Add remaining branches iteratively
        for (i = 3; i <= branchCount; i++) {
            if (!NAVRegexParserBuildAlternation(parser, result, branches[i], currentFragment)) {
                parser.groupDepth--
                return false
            }
            result = currentFragment
        }

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Alternation complete with ', itoa(branchCount), ' branches'")
        #END_IF

        return true
    }

    // Concatenate all fragments on the stack
    if (parser.fragmentStackDepth == 0) {
        // Empty expression - create epsilon fragment
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Empty expression, creating epsilon'")
        #END_IF
        if (!NAVRegexParserCreateEpsilonFragment(parser, result)) {
            return false
        }
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Empty expression complete, returning'")
        #END_IF
        return true
    }

    // Concatenate only the fragments added during THIS parse call
    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserParseExpression ]: Starting concatenation, stack depth=', itoa(parser.fragmentStackDepth), ', initialStackDepth=', itoa(initialStackDepth)")
    #END_IF

    if (parser.fragmentStackDepth > initialStackDepth) {
        stack_var _NAVRegexNFAFragment fragments[MAX_REGEX_PARSER_DEPTH]
        stack_var integer fragmentCount
        stack_var integer j
        stack_var _NAVRegexNFAFragment concatFragment

        // Collect only the NEW fragments (from initialStackDepth+1 to current depth)
        fragmentCount = 0
        while (parser.fragmentStackDepth > initialStackDepth) {
            fragmentCount++
            if (!NAVRegexParserPopFragment(parser, fragments[fragmentCount])) {
                return false
            }
        }

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Concatenating ', itoa(fragmentCount), ' new fragments'")
        #END_IF

        // Start with the LAST popped (FIRST pushed of the new ones) fragment
        result = fragments[fragmentCount]

        // Concatenate remaining fragments in correct order (first to last)
        for (j = fragmentCount - 1; j >= 1; j--) {
            if (!NAVRegexParserBuildConcatenation(parser, result, fragments[j], concatFragment)) {
                return false
            }
            result = concatFragment
        }
    } else {
        // No new fragments added (shouldn't happen in normal parsing)
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: No new fragments to concatenate'")
        #END_IF
        result.startState = 0
        result.outCount = 0
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserParseExpression ]: Complete - result fragment (start=', itoa(result.startState), ', outs=', itoa(result.outCount), ')'")
    NAVLog("'[ ParserParseExpression ]: About to return TRUE'")
    #END_IF

    return true
}


/**
 * @function NAVRegexParserCreateEpsilonFragment
 * @private
 * @description Create an epsilon (empty transition) fragment.
 *
 * Helper function to reduce code duplication when creating epsilon fragments
 * for empty expressions, empty groups, or empty alternation branches.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} result - Output fragment (pass by reference)
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserCreateEpsilonFragment(_NAVRegexParserState parser,
                                                          _NAVRegexNFAFragment result) {
    if (!NAVRegexParserAddState(parser, NFA_STATE_EPSILON)) {
        return false
    }

    result.startState = parser.stateCount
    result.outCount = 1
    set_length_array(result.outStates, 1)
    result.outStates[1] = result.startState

    return true
}


/**
 * @function NAVRegexParserBuildAndPushLiteral
 * @private
 * @description Build a literal fragment and push it onto the stack.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {char} value - Character to match
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserBuildAndPushLiteral(_NAVRegexParserState parser, char value) {
    stack_var _NAVRegexNFAFragment fragment

    if (!NAVRegexParserBuildLiteral(parser, value, fragment)) {
        return false
    }
    return NAVRegexParserPushFragment(parser, fragment)
}


/**
 * @function NAVRegexParserBuildAndPushCharClass
 * @private
 * @description Build a character class fragment and push it onto the stack.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexCharClass} charClass - Character class specification
 * @param {char} isNegated - True for [^...], false for [...]
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserBuildAndPushCharClass(_NAVRegexParserState parser,
                                                          _NAVRegexCharClass charClass,
                                                          char isNegated) {
    stack_var _NAVRegexNFAFragment fragment

    if (!NAVRegexParserBuildCharClass(parser, charClass, isNegated, fragment)) {
        return false
    }
    return NAVRegexParserPushFragment(parser, fragment)
}


/**
 * @function NAVRegexParserBuildAndPushPredefinedClass
 * @private
 * @description Build a predefined class fragment and push it onto the stack.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} tokenType - Token type (DIGIT, ALPHA, WHITESPACE, etc.)
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserBuildAndPushPredefinedClass(_NAVRegexParserState parser,
                                                                integer tokenType) {
    stack_var _NAVRegexNFAFragment fragment

    if (!NAVRegexParserBuildPredefinedClass(parser, tokenType, fragment)) {
        return false
    }
    return NAVRegexParserPushFragment(parser, fragment)
}


/**
 * @function NAVRegexParserBuildAndPushDot
 * @private
 * @description Build a dot (match-any) fragment and push it onto the stack.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserBuildAndPushDot(_NAVRegexParserState parser) {
    stack_var _NAVRegexNFAFragment fragment

    if (!NAVRegexParserBuildDot(parser, fragment)) {
        return false
    }
    return NAVRegexParserPushFragment(parser, fragment)
}


/**
 * @function NAVRegexParserBuildAndPushAnchor
 * @private
 * @description Build an anchor fragment and push it onto the stack.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} tokenType - Anchor token type (BEGIN, END, WORD_BOUNDARY, etc.)
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserBuildAndPushAnchor(_NAVRegexParserState parser, integer tokenType) {
    stack_var _NAVRegexNFAFragment fragment

    if (!NAVRegexParserBuildAnchor(parser, tokenType, fragment)) {
        return false
    }
    return NAVRegexParserPushFragment(parser, fragment)
}


/**
 * @function NAVRegexParserBuildAndPushBackreference
 * @private
 * @description Build a backreference fragment and push it onto the stack.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} groupNumber - Group number to reference (1-based)
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserBuildAndPushBackreference(_NAVRegexParserState parser, integer groupNumber) {
    stack_var _NAVRegexNFAFragment fragment

    if (!NAVRegexParserBuildBackreference(parser, groupNumber, fragment)) {
        return false
    }
    return NAVRegexParserPushFragment(parser, fragment)
}


/**
 * @function NAVRegexParserProcessSimpleToken
 * @private
 * @description Process a single simple token (literals, classes, anchors, quantifiers, flags, alternation).
 *
 * This function handles all token types EXCEPT GROUP_START/GROUP_END which require special
 * handling with loop index manipulation and recursion in the calling context.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexToken} token - Token to process
 * @param {char} hasAlternation - Reference to alternation flag (modified if alternation found)
 * @param {integer} alternationStart - Reference to alternation start position (modified if first alternation)
 * @param {integer} tokenIndex - Current token index (for alternation tracking)
 *
 * @returns {sinteger} Result code: 1=success, 0=error, -1=skip (not a simple token)
 */
define_function sinteger NAVRegexParserProcessSimpleToken(_NAVRegexParserState parser,
                                                           _NAVRegexToken token,
                                                           char hasAlternation,
                                                           integer alternationStart,
                                                           integer tokenIndex) {
    select {
        // === LITERALS AND CHARACTER CLASSES ===
        active (token.type == REGEX_TOKEN_CHAR ||
                token.type == REGEX_TOKEN_HEX ||
                token.type == REGEX_TOKEN_NEWLINE ||
                token.type == REGEX_TOKEN_TAB ||
                token.type == REGEX_TOKEN_RETURN ||
                token.type == REGEX_TOKEN_FORMFEED ||
                token.type == REGEX_TOKEN_VTAB ||
                token.type == REGEX_TOKEN_BELL ||
                token.type == REGEX_TOKEN_ESC): {
            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[ ProcessSimpleToken ]: Processing literal token, type=', itoa(token.type), ', value=', itoa(token.value)")
            #END_IF
            if (!NAVRegexParserBuildAndPushLiteral(parser, token.value)) {
                return 0
            }
            return 1
        }

        active (token.type == REGEX_TOKEN_CHAR_CLASS ||
                token.type == REGEX_TOKEN_INV_CHAR_CLASS): {
            if (!NAVRegexParserBuildAndPushCharClass(parser, token.charClass, token.isNegated)) {
                return 0
            }
            return 1
        }

        active (token.type == REGEX_TOKEN_DIGIT ||
                token.type == REGEX_TOKEN_NOT_DIGIT ||
                token.type == REGEX_TOKEN_ALPHA ||
                token.type == REGEX_TOKEN_NOT_ALPHA ||
                token.type == REGEX_TOKEN_WHITESPACE ||
                token.type == REGEX_TOKEN_NOT_WHITESPACE): {
            if (!NAVRegexParserBuildAndPushPredefinedClass(parser, token.type)) {
                return 0
            }
            return 1
        }

        active (token.type == REGEX_TOKEN_DOT): {
            if (!NAVRegexParserBuildAndPushDot(parser)) {
                return 0
            }
            return 1
        }

        // === ANCHORS ===
        active (token.type == REGEX_TOKEN_BEGIN ||
                token.type == REGEX_TOKEN_END ||
                token.type == REGEX_TOKEN_WORD_BOUNDARY ||
                token.type == REGEX_TOKEN_NOT_WORD_BOUNDARY ||
                token.type == REGEX_TOKEN_STRING_START ||
                token.type == REGEX_TOKEN_STRING_END ||
                token.type == REGEX_TOKEN_STRING_END_ABSOLUTE): {
            if (!NAVRegexParserBuildAndPushAnchor(parser, token.type)) {
                return 0
            }
            return 1
        }

        // === BACKREFERENCES ===
        active (token.type == REGEX_TOKEN_NUMERIC_ESCAPE): {
            // Numeric escapes \1-\999 disambiguation per specification:
            //
            // Key Rules for Backreference vs Octal Escape Distinction
            //
            // \1 through \9:
            //   - If group exists → backreference
            //   - If group doesn't exist → octal escape (legacy, deprecated in Unicode mode)
            //
            // \10 through \99:
            //   - If that many groups exist → backreference
            //   - If fewer groups → interpreted as backreference to single digit + literal digit
            //   - Example: (a)\17 with only 1 group = backreference \1 + literal 7 = matches "aa7"
            //
            // \100 and above:
            //   - Always octal escape (never backreference)

            stack_var integer groupNum
            stack_var char octalValue
            stack_var integer numDigits

            groupNum = atoi(token.numericEscapeDigits)
            numDigits = length_array(token.numericEscapeDigits)

            // Special case: \0 is always the NUL character (0x00)
            if (groupNum == 0) {
                octalValue = 0
                if (!NAVRegexParserBuildAndPushLiteral(parser, octalValue)) {
                    return 0
                }
                return 1
            }

            // Rule 3: \100 and above are always octal escapes (never backreference)
            if (groupNum >= 100) {
                octalValue = NAVRegexParserOctalToChar(token.numericEscapeDigits)
                if (!NAVRegexParserBuildAndPushLiteral(parser, octalValue)) {
                    return 0
                }
                return 1
            }

            // Rule 1: \1 through \9
            // If group exists → backreference; If group doesn't exist → octal escape
            if (groupNum >= 1 && groupNum <= 9) {
                if (groupNum <= parser.currentGroup) {
                    // Group exists - valid backreference
                    if (!NAVRegexParserBuildAndPushBackreference(parser, groupNum)) {
                        return 0
                    }
                    return 1
                } else {
                    // Group doesn't exist - treat as octal escape
                    octalValue = type_cast(groupNum)
                    if (!NAVRegexParserBuildAndPushLiteral(parser, octalValue)) {
                        return 0
                    }
                    return 1
                }
            }

            // Rule 2: \10 through \99
            // If that many groups exist → backreference
            // If fewer groups → interpreted as backreference to single digit + literal digit
            // Example: (a)\17 with only 1 group = backreference \1 + literal 7 = matches "aa7"
            // Special case: If NO groups exist at all, always treat as octal escape
            if (numDigits == 2) {
                stack_var char secondChar
                stack_var integer firstDigit

                // If no groups exist at all, two-digit sequences are always octal escapes
                if (parser.currentGroup == 0) {
                    octalValue = NAVRegexParserOctalToChar(token.numericEscapeDigits)
                    if (!NAVRegexParserBuildAndPushLiteral(parser, octalValue)) {
                        return 0
                    }
                    return 1
                }

                secondChar = NAVCharCodeAt(token.numericEscapeDigits, 2)
                firstDigit = atoi(mid_string(token.numericEscapeDigits, 1, 1))

                // Check if we have enough groups for the full number
                if (groupNum <= parser.currentGroup) {
                    // Enough groups - full backreference
                    if (!NAVRegexParserBuildAndPushBackreference(parser, groupNum)) {
                        return 0
                    }
                    return 1
                }

                // Fewer groups than the full number - always split into first digit + second digit
                // The first digit (\1-\9) will be handled by Rule 1:
                //   - If group exists → backreference
                //   - If group doesn't exist → octal escape
                // The second digit is always a literal character

                // Process first digit as \1-\9 (will be backref or octal per Rule 1)
                if (firstDigit <= parser.currentGroup) {
                    // First digit is a valid group number - backreference
                    if (!NAVRegexParserBuildAndPushBackreference(parser, firstDigit)) {
                        return 0
                    }
                } else {
                    // First digit is NOT a valid group - treat as octal escape per Rule 1
                    octalValue = type_cast(firstDigit)
                    if (!NAVRegexParserBuildAndPushLiteral(parser, octalValue)) {
                        return 0
                    }
                }

                // Second digit is always a literal character
                if (!NAVRegexParserBuildAndPushLiteral(parser, secondChar)) {
                    return 0
                }

                #IF_DEFINED REGEX_PARSER_DEBUG
                NAVLog("'[ Parser ]: Split \', token.numericEscapeDigits, ' into \', itoa(firstDigit), ' + literal ', secondChar")
                #END_IF
                return 1
            }

            // Fallback: shouldn't reach here for valid patterns
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserProcessSimpleToken',
                                        "'Unexpected numeric escape \', token.numericEscapeDigits, ' - invalid pattern'")
            return 0
        }

        active (token.type == REGEX_TOKEN_BACKREF_NAMED): {
            // Named backreferences \k<name>
            // Scan tokens to find the named group and get its number
            stack_var integer groupNum
            stack_var integer i
            stack_var char found

            groupNum = 0
            found = false

            // Search through tokens for a GROUP_START with matching name
            for (i = 1; i <= parser.tokenCount; i++) {
                if (parser.tokens[i].type == REGEX_TOKEN_GROUP_START) {
                    if (parser.tokens[i].groupInfo.isNamed) {
                        if (parser.tokens[i].groupInfo.name == token.name) {
                            groupNum = parser.tokens[i].groupInfo.number
                            found = true
                            break
                        }
                    }
                }
            }

            if (found && groupNum >= 1) {
                // Valid named backreference - build backreference to the group number
                if (!NAVRegexParserBuildAndPushBackreference(parser, groupNum)) {
                    return 0
                }
                #IF_DEFINED REGEX_PARSER_DEBUG
                NAVLog("'[ Parser ]: Named backreference \k<', token.name, '> resolved to group #', itoa(groupNum)")
                #END_IF
                return 1
            } else {
                // Invalid named backreference - group not found
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                            'NAVRegexParserProcessSimpleToken',
                                            "'Named backreference \k<', token.name, '> refers to non-existent group'")
                return 0
            }
        }

        // === QUANTIFIERS ===
        active (token.type == REGEX_TOKEN_STAR): {
            if (!NAVRegexParserApplyQuantifier(parser, REGEX_QUANTIFIER_TYPE_ZERO_OR_MORE, token.isLazy)) {
                return 0
            }
            return 1
        }

        active (token.type == REGEX_TOKEN_PLUS): {
            if (!NAVRegexParserApplyQuantifier(parser, REGEX_QUANTIFIER_TYPE_ONE_OR_MORE, token.isLazy)) {
                return 0
            }
            return 1
        }

        active (token.type == REGEX_TOKEN_QUESTIONMARK): {
            if (!NAVRegexParserApplyQuantifier(parser, REGEX_QUANTIFIER_TYPE_ZERO_OR_ONE, token.isLazy)) {
                return 0
            }
            return 1
        }

        active (token.type == REGEX_TOKEN_QUANTIFIER): {
            if (!NAVRegexParserApplyBoundedQuantifier(parser, type_cast(token.min), type_cast(token.max), token.isLazy)) {
                return 0
            }
            return 1
        }

        // === ALTERNATION ===
        active (token.type == REGEX_TOKEN_ALTERNATION): {
            // Mark that we have alternation - will be processed at the end
            // NetLinx passes by reference, so these modifications affect the caller's variables
            hasAlternation = true
            if (alternationStart == 0) {
                alternationStart = tokenIndex
            }
            return 1
        }

        // === FLAGS ===
        active (token.type == REGEX_TOKEN_FLAG_CASE_INSENSITIVE): {
            NAVRegexParserSetFlag(parser, PARSER_FLAG_CASE_INSENSITIVE, token.flagEnabled)
            return 1
        }

        active (token.type == REGEX_TOKEN_FLAG_MULTILINE): {
            NAVRegexParserSetFlag(parser, PARSER_FLAG_MULTILINE, token.flagEnabled)
            return 1
        }

        active (token.type == REGEX_TOKEN_FLAG_DOTALL): {
            NAVRegexParserSetFlag(parser, PARSER_FLAG_DOTALL, token.flagEnabled)
            return 1
        }

        active (token.type == REGEX_TOKEN_FLAG_EXTENDED): {
            NAVRegexParserSetFlag(parser, PARSER_FLAG_EXTENDED, token.flagEnabled)
            return 1
        }

        // === NOT A SIMPLE TOKEN (GROUP_START, GROUP_END, or unknown) ===
        active (1): {
            // Return -1 to indicate this token was not handled (caller should handle it)
            return -1
        }
    }
}


/**
 * @function NAVRegexParserApplyQuantifier
 * @private
 * @description Apply a quantifier (\*, +, ?) to the last fragment on the stack.
 *
 * Pops the last fragment, applies the quantifier, and pushes the result back.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} quantifierType - Type: REGEX_QUANTIFIER_TYPE_ZERO_OR_MORE, REGEX_QUANTIFIER_TYPE_ONE_OR_MORE, REGEX_QUANTIFIER_TYPE_ZERO_OR_ONE
 * @param {char} isLazy - True for lazy/non-greedy quantifiers (\*?, +?, ??)
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserApplyQuantifier(_NAVRegexParserState parser, integer quantifierType, char isLazy) {
    stack_var _NAVRegexNFAFragment temp
    stack_var _NAVRegexNFAFragment result

    if (!NAVRegexParserPopFragment(parser, temp)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserApplyQuantifier',
                                    'Quantifier with no preceding expression')
        return false
    }

    select {
        active (quantifierType == REGEX_QUANTIFIER_TYPE_ZERO_OR_MORE): {
            if (!NAVRegexParserBuildZeroOrMore(parser, temp, isLazy, result)) {
                return false
            }
        }
        active (quantifierType == REGEX_QUANTIFIER_TYPE_ONE_OR_MORE): {
            if (!NAVRegexParserBuildOneOrMore(parser, temp, isLazy, result)) {
                return false
            }
        }
        active (quantifierType == REGEX_QUANTIFIER_TYPE_ZERO_OR_ONE): {
            if (!NAVRegexParserBuildZeroOrOne(parser, temp, isLazy, result)) {
                return false
            }
        }
    }

    return NAVRegexParserPushFragment(parser, result)
}


/**
 * @function NAVRegexParserFindMatchingGroupEnd
 * @private
 * @description Find the matching GROUP_END token for a GROUP_START or lookaround token.
 *
 * Handles nested groups by tracking nesting depth.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} tokenIndex - Index of the GROUP_START or lookaround token
 * @param {integer} endToken - Last token index to search
 *
 * @returns {integer} Index of matching GROUP_END, or 0 if not found
 */
define_function integer NAVRegexParserFindMatchingGroupEnd(_NAVRegexParserState parser,
                                                             integer tokenIndex,
                                                             integer endToken) {
    stack_var integer nestingDepth
    stack_var integer j

    nestingDepth = 1

    for (j = tokenIndex + 1; j <= endToken; j++) {
        // Count opening tokens (all group types including lookarounds)
        if (parser.tokens[j].type == REGEX_TOKEN_GROUP_START ||
            parser.tokens[j].type == REGEX_TOKEN_LOOKAHEAD_POSITIVE ||
            parser.tokens[j].type == REGEX_TOKEN_LOOKAHEAD_NEGATIVE ||
            parser.tokens[j].type == REGEX_TOKEN_LOOKBEHIND_POSITIVE ||
            parser.tokens[j].type == REGEX_TOKEN_LOOKBEHIND_NEGATIVE) {
            nestingDepth++
        } else if (parser.tokens[j].type == REGEX_TOKEN_GROUP_END) {
            nestingDepth--
            if (nestingDepth == 0) {
                return j  // Found matching end
            }
        }
    }

    return 0  // No matching end found
}


/**
 * @function NAVRegexParserProcessGroup
 * @private
 * @description Process a GROUP_START token by finding the matching GROUP_END,
 * recursively parsing the group contents, and building the appropriate group fragment.
 *
 * NOTE: The caller (NAVRegexParserParseExpression) is responsible for managing
 * parser.groupDepth increment/decrement and depth limit checking. This function
 * only handles the mechanical work of finding GROUP_END, parsing contents, and
 * building the fragment.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} tokenIndex - Index of the GROUP_START token
 * @param {integer} endToken - Last token index in current expression
 * @param {integer} groupEndIndex - Output: index of the matching GROUP_END token
 * @param {_NAVRegexNFAFragment} result - Output fragment for this group
 *
 * @returns {char} True (1) on success, False (0) on error
 */
define_function char NAVRegexParserProcessGroup(_NAVRegexParserState parser,
                                                 integer tokenIndex,
                                                 integer endToken,
                                                 integer groupEndIndex,
                                                 _NAVRegexNFAFragment result) {
    stack_var integer groupEnd
    stack_var _NAVRegexNFAFragment groupContent
    stack_var char isScopedFlagGroup

    // Find matching GROUP_END using helper function
    groupEnd = NAVRegexParserFindMatchingGroupEnd(parser, tokenIndex, endToken)

    // Validate matching GROUP_END found
    if (groupEnd == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserProcessGroup',
                                    "'Unmatched GROUP_START at token ', itoa(tokenIndex)")
        return false
    }

    // Return the group end index to caller (so it can skip past it)
    groupEndIndex = groupEnd

    // Check if this is a scoped flag group using lexer metadata
    // Scoped flag groups (?i:...) have flags that apply only within the group
    // Global flag groups (?i) have flags that apply from that point forward
    isScopedFlagGroup = parser.tokens[tokenIndex].groupInfo.isScopedFlagGroup

    if (isScopedFlagGroup) {
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserProcessGroup ]: Scoped flag group detected, pushing flags (current=0x', format('%02X', parser.activeFlags), ')'")
        #END_IF

        // Mark parser as having scoped flags (will be copied to NFA after parsing)
        parser.hasScopedFlags = true

        // Push current flags before processing scoped flag group
        if (!NAVRegexParserPushFlags(parser)) {
            return false
        }
    }
    else if (parser.tokens[tokenIndex].groupInfo.isGlobalFlagGroup) {
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserProcessGroup ]: Global flag group detected (no scope push needed)'")
        #END_IF

        // Mark parser as having flag changes (affects literal prefix optimization)
        parser.hasScopedFlags = true
    }

    // Recursively parse group contents
    if (tokenIndex + 1 <= groupEnd - 1) {
        stack_var char recursionResult
        stack_var integer savedStackDepth

        // Save fragment stack depth before recursion
        savedStackDepth = parser.fragmentStackDepth

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: About to recurse - tokens ', itoa(tokenIndex + 1), ' to ', itoa(groupEnd - 1), ', depth=', itoa(parser.groupDepth), ', savedStackDepth=', itoa(savedStackDepth)")
        #END_IF

        // WORKAROUND: NetLinx has trouble evaluating recursive function return values
        // in if statements at deep recursion (depth 15+). Store in local variable first.
        recursionResult = NAVRegexParserParseExpression(parser, tokenIndex + 1, groupEnd - 1, groupContent)

        // Restore fragment stack depth after recursion
        parser.fragmentStackDepth = savedStackDepth

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Returned from recursion - result=', itoa(recursionResult), ', depth=', itoa(parser.groupDepth), ', restoredStackDepth=', itoa(parser.fragmentStackDepth)")
        #END_IF

        if (!recursionResult) {
            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[ ParserParseExpression ]: Recursion failed'")
            #END_IF

            // Pop flags if we pushed them
            if (isScopedFlagGroup) {
                NAVRegexParserPopFlags(parser)
            }
            return false
        }

        // Pop flags after processing scoped flag group
        if (isScopedFlagGroup) {
            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[ ParserProcessGroup ]: Scoped flag group complete, popping flags (was=0x', format('%02X', parser.activeFlags), ')'")
            #END_IF

            if (!NAVRegexParserPopFlags(parser)) {
                return false
            }

            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[ ParserProcessGroup ]: Flags restored (now=0x', format('%02X', parser.activeFlags), ')'")
            #END_IF
        }

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Recursion succeeded, continuing...'")
        #END_IF
    } else {
        // Empty group - create epsilon
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Empty group, creating epsilon'")
        #END_IF
        if (!NAVRegexParserCreateEpsilonFragment(parser, groupContent)) {
            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'[ ParserParseExpression ]: AddState failed for epsilon'")
            #END_IF
            return false
        }
    }

    // Build capturing or non-capturing group
    if (parser.tokens[tokenIndex].groupInfo.isCapturing) {
        // Capturing group - use group number from lexer (already assigned in left-to-right order)
        stack_var integer groupNumber
        groupNumber = parser.tokens[tokenIndex].groupInfo.number

        // Track the highest group number seen (for NFA metadata)
        if (groupNumber > parser.currentGroup) {
            parser.currentGroup = groupNumber
        }

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Building capturing group #', itoa(groupNumber)")
        if (parser.tokens[tokenIndex].groupInfo.isNamed) {
            NAVLog("'[ ParserParseExpression ]:   Named group: ', parser.tokens[tokenIndex].groupInfo.name")
        }
        #END_IF

        if (!NAVRegexParserBuildCapturingGroup(parser, groupContent, groupNumber,
                                                parser.tokens[tokenIndex].groupInfo.name, result)) {
            return false
        }

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Capturing group built successfully'")
        #END_IF
    } else {
        // Non-capturing group - just pass through content
        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'[ ParserParseExpression ]: Building non-capturing group'")
        #END_IF
        if (!NAVRegexParserBuildNonCapturingGroup(parser, groupContent, result)) {
            return false
        }
    }

    return true
}


/**
 * @function NAVRegexParserProcessBranch
 * @private
 * @description Process a single alternation branch, parsing all tokens and producing a fragment.
 *
 * Handles empty branches by creating epsilon fragments. For non-empty branches, processes
 * all tokens in the range and concatenates the resulting fragments.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} startToken - First token index in branch
 * @param {integer} endToken - Last token index in branch
 * @param {_NAVRegexNFAFragment} result - Output fragment for this branch
 *
 * @returns {char} True (1) on success, False (0) on error
 */
define_function char NAVRegexParserProcessBranch(_NAVRegexParserState parser,
                                                   integer startToken,
                                                   integer endToken,
                                                   _NAVRegexNFAFragment result) {
    stack_var integer j
    stack_var integer savedStackDepth

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'ProcessBranch: startToken=', itoa(startToken), ' endToken=', itoa(endToken)")
    #END_IF

    // Check for empty branch
    if (startToken > endToken) {
        // Empty branch - create epsilon fragment
        return NAVRegexParserCreateEpsilonFragment(parser, result)
    }

    // Save fragment stack depth before processing this branch
    // (must restore after to prevent corruption of parent context)
    // Note: Unlike groups, branches MUST NOT reset the stack depth to 0,
    // as that would cause branch fragments to overwrite parent fragments.
    // Instead, we save the depth and let the branch build on top of it,
    // then restore after concatenation.
    savedStackDepth = parser.fragmentStackDepth

    // DO NOT reset parser.fragmentStackDepth = 0 here!
    // That was the bug - it caused branches to overwrite parent fragments.
    // The branch will build its fragments starting at depth+1, and after
    // concatenation, we restore the depth to isolate the branch result.

    // Process all tokens in this branch
    for (j = startToken; j <= endToken; j++) {
        stack_var sinteger tokenResult
        stack_var char dummyHasAlternation
        stack_var integer dummyAlternationStart

        #IF_DEFINED REGEX_PARSER_DEBUG
        NAVLog("'  ProcessBranch: j=', itoa(j), ' tokenType=', itoa(parser.tokens[j].type)")
        #END_IF

        // Skip EOF token - it's a sentinel, not part of the pattern
        if (parser.tokens[j].type == REGEX_TOKEN_EOF) {
            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'  ProcessBranch: Encountered EOF token, stopping'")
            #END_IF
            break
        }

        // Try to process as a simple token
        tokenResult = NAVRegexParserProcessSimpleToken(parser, parser.tokens[j], dummyHasAlternation, dummyAlternationStart, j)

        if (tokenResult == 0) {
            // Error occurred - restore fragment stack depth before returning
            parser.fragmentStackDepth = savedStackDepth
            return false
        } else if (tokenResult == 1) {
            // Successfully processed - continue to next token
            continue
        }

        // tokenResult == -1 means not a simple token - could be a group or lookaround
        if (parser.tokens[j].type == REGEX_TOKEN_GROUP_START ||
            parser.tokens[j].type == REGEX_TOKEN_LOOKAHEAD_POSITIVE ||
            parser.tokens[j].type == REGEX_TOKEN_LOOKAHEAD_NEGATIVE ||
            parser.tokens[j].type == REGEX_TOKEN_LOOKBEHIND_POSITIVE ||
            parser.tokens[j].type == REGEX_TOKEN_LOOKBEHIND_NEGATIVE) {
            stack_var integer groupEnd
            stack_var char groupResult
            stack_var _NAVRegexNFAFragment groupFragment

            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'    ProcessBranch: Found GROUP_START or LOOKAROUND at ', itoa(j), ', type=', itoa(parser.tokens[j].type)")
            #END_IF

            // Process group/lookaround using helper (finds GROUP_END, parses contents, builds fragment)
            // Note: Use parser.tokenCount - 1 as search limit, not endToken, because the GROUP_END
            // might be beyond the current branch boundary (e.g., lookarounds containing alternation)
            groupResult = NAVRegexParserProcessGroup(parser, j, parser.tokenCount - 1, groupEnd, groupFragment)

            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'    ProcessBranch: ProcessGroup returned groupEnd=', itoa(groupEnd)")
            #END_IF

            if (!groupResult) {
                // Restore fragment stack depth before returning on error
                parser.fragmentStackDepth = savedStackDepth
                return false
            }

            // Push group fragment onto stack
            if (!NAVRegexParserPushFragment(parser, groupFragment)) {
                // Restore fragment stack depth before returning on error
                parser.fragmentStackDepth = savedStackDepth
                return false
            }

            #IF_DEFINED REGEX_PARSER_DEBUG
            NAVLog("'    ProcessBranch: Setting j=', itoa(groupEnd), ' and continuing'")
            #END_IF

            // Move to the GROUP_END token
            j = groupEnd

            // Continue loop - the loop condition and EOF check will handle boundaries correctly
            continue
        }

        // tokenResult == -1 but not a GROUP_START - could be GROUP_END (which shouldn't be here)
        if (parser.tokens[j].type == REGEX_TOKEN_GROUP_END) {
            // GROUP_END in a branch means we've hit the end boundary - shouldn't process it
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                        'NAVRegexParserProcessBranch',
                                        "'Unexpected GROUP_END token at position ', itoa(j), ' in alternation branch'")
            // Restore fragment stack depth before returning on error
            parser.fragmentStackDepth = savedStackDepth
            return false
        }

        // Unknown token type in branch - this shouldn't happen
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserProcessBranch',
                                    "'Unexpected token type ', itoa(parser.tokens[j].type), ' in alternation branch'")
        // Restore fragment stack depth before returning on error
        parser.fragmentStackDepth = savedStackDepth
        return false
    }

    // Concatenate all fragments added by this branch (not parent's fragments)
    if (parser.fragmentStackDepth == savedStackDepth) {
        // Branch produced no NEW fragments - create epsilon
        stack_var char epsilonResult
        epsilonResult = NAVRegexParserCreateEpsilonFragment(parser, result)

        // Stack depth already matches saved value, no need to restore

        return epsilonResult
    } else {
        // Concatenate fragments added by this branch only
        // We need to pop only the fragments above savedStackDepth
        stack_var _NAVRegexNFAFragment fragments[MAX_REGEX_PARSER_DEPTH]
        stack_var integer fragmentCount
        stack_var integer i
        stack_var _NAVRegexNFAFragment currentFragment

        // Collect branch fragments (those pushed after savedStackDepth)
        fragmentCount = 0
        while (parser.fragmentStackDepth > savedStackDepth) {
            fragmentCount++
            if (!NAVRegexParserPopFragment(parser, fragments[fragmentCount])) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                            'NAVRegexParserProcessBranch',
                                            'Failed to pop branch fragment from stack')
                return false
            }
        }

        // Start with the LAST popped (FIRST pushed by branch) fragment
        result = fragments[fragmentCount]

        // Concatenate remaining branch fragments in correct order (first to last)
        for (i = fragmentCount - 1; i >= 1; i--) {
            if (!NAVRegexParserBuildConcatenation(parser, result, fragments[i], currentFragment)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                            'NAVRegexParserProcessBranch',
                                            'Failed to concatenate branch fragments')
                return false
            }
            result = currentFragment
        }

        // Stack depth has been restored to savedStackDepth by the pops above
        return true
    }
}


/**
 * @function NAVRegexParserApplyBoundedQuantifier
 * @private
 * @description Apply a bounded quantifier {n,m} to the last fragment on the stack.
 *
 * Pops the last fragment, applies the bounded quantifier, and pushes the result back.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {integer} min - Minimum repetitions
 * @param {integer} max - Maximum repetitions (-1 for unbounded)
 * @param {char} isLazy - True for lazy/non-greedy quantifier ({n,m}?)
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserApplyBoundedQuantifier(_NAVRegexParserState parser,
                                                           integer min,
                                                           integer max,
                                                           char isLazy) {
    stack_var _NAVRegexNFAFragment temp
    stack_var _NAVRegexNFAFragment result

    if (!NAVRegexParserPopFragment(parser, temp)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserApplyBoundedQuantifier',
                                    'Bounded quantifier with no preceding expression')
        return false
    }

    if (!NAVRegexParserBuildBoundedQuantifier(parser, temp, min, type_cast(max), isLazy, result)) {
        return false
    }

    return NAVRegexParserPushFragment(parser, result)
}


/**
 * @function NAVRegexParserPushFragment
 * @public
 * @description Push a fragment onto the parser's fragment stack.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} fragment - Fragment to push
 *
 * @returns {char} True (1) on success, False (0) if stack is full
 */
define_function char NAVRegexParserPushFragment(_NAVRegexParserState parser,
                                                 _NAVRegexNFAFragment fragment) {
    if (parser.fragmentStackDepth >= MAX_REGEX_PARSER_DEPTH) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserPushFragment',
                                    "'Fragment stack overflow: ', itoa(MAX_REGEX_PARSER_DEPTH)")
        return false
    }

    parser.fragmentStackDepth++
    parser.fragmentStack[parser.fragmentStackDepth] = fragment

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserPushFragment ]: Pushed fragment (depth=', itoa(parser.fragmentStackDepth), ', start=', itoa(fragment.startState), ')'")
    #END_IF

    return true
}


/**
 * @function NAVRegexParserPopFragment
 * @public
 * @description Pop a fragment from the parser's fragment stack.
 *
 * @param {_NAVRegexParserState} parser - Parser state
 * @param {_NAVRegexNFAFragment} fragment - Output fragment
 *
 * @returns {char} True (1) on success, False (0) if stack is empty
 */
define_function char NAVRegexParserPopFragment(_NAVRegexParserState parser,
                                                _NAVRegexNFAFragment fragment) {
    if (parser.fragmentStackDepth == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER_HELPERS__,
                                    'NAVRegexParserPopFragment',
                                    'Fragment stack underflow')
        return false
    }

    fragment = parser.fragmentStack[parser.fragmentStackDepth]
    parser.fragmentStackDepth--

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserPopFragment ]: Popped fragment (depth=', itoa(parser.fragmentStackDepth), ', start=', itoa(fragment.startState), ')'")
    #END_IF

    return true
}


#END_IF // __NAV_FOUNDATION_REGEX_PARSER_HELPERS__
