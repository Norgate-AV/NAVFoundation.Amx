PROGRAM_NAME='NAVFoundation.RegexMatcher'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

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

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_MATCHER__
#DEFINE __NAV_FOUNDATION_REGEX_MATCHER__ 'NAVFoundation.RegexMatcher'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.RegexMatcher.h.axi'
#include 'NAVFoundation.RegexMatcherHelpers.axi'


/**
 * @function NAVRegexMatcherInit
 * @private
 * @description Initialize the matcher state with an NFA and input string.
 *
 * Sets up the matcher for execution by copying the NFA reference, input string,
 * and initializing all internal state (thread lists, positions, flags).
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state to initialize
 * @param {_NAVRegexNFA} nfa - The compiled NFA to use for matching
 * @param {char[]} input - The input string to match against
 * @param {integer} startPos - Starting position in input (1-based)
 *
 * @returns {char} TRUE if initialization succeeded, FALSE otherwise
 */
define_function char NAVRegexMatcherInit(_NAVRegexMatcherState matcher,
                                         _NAVRegexNFA nfa,
                                         char input[],
                                         integer startPos) {
    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatcherInit ]: Input string: "', input, '" (length=', itoa(length_array(input)), ')'")
    NAVLog("'[ MatcherInit ]: Start position: ', itoa(startPos)")
    NAVLog("'[ MatcherInit ]: NFA state count: ', itoa(nfa.stateCount)")
    NAVLog("'[ MatcherInit ]: NFA start state: ', itoa(nfa.startState)")
    NAVLog("'[ MatcherInit ]: NFA accept state: ', itoa(nfa.acceptState)")
    NAVLog("'[ MatcherInit ]: NFA flags: 0x', format('%02X', nfa.flags)")
    #END_IF

    // Copy NFA reference
    matcher.nfa = nfa

    // Copy input string
    matcher.inputString = input
    matcher.inputLength = length_array(input)

    // Set positions
    matcher.startPosition = startPos
    matcher.currentPosition = startPos

    // Copy NFA flags directly to matcher options
    // Since PARSER_FLAG_* and MATCH_OPTION_* now share the same bit positions
    // for common flags, we can assign directly
    matcher.options = nfa.flags

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatcherInit ]: Match options: 0x', format('%02X', matcher.options)")
    #END_IF

    // Initialize thread lists
    NAVRegexThreadListInit(matcher.currentList)
    NAVRegexThreadListInit(matcher.nextList)

    // Clear best thread and match state
    NAVRegexThreadInit(matcher.bestThread, 0)
    matcher.hasMatch = false
    matcher.bestMatchEnd = 0

    // Clear error state
    matcher.hasError = false
    matcher.errorMessage = ''

    // Clear backtrack and lookaround state
    matcher.backtrackDepth = 0
    matcher.lookaroundDepth = 0

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatcherInit ]: Initialization complete'")
    #END_IF

    return true
}


/**
 * @function NAVRegexExecuteMatch
 * @private
 * @description Execute the NFA simulation to find a match.
 *
 * Implements Thompson's NFA algorithm:
 * 1. Create initial thread at NFA start state
 * 2. Apply epsilon-closure to follow non-consuming transitions
 * 3. Step through input character by character
 * 4. Maintain parallel threads for all possible paths
 * 5. Detect MATCH state and capture best (leftmost-longest) match
 *
 * Note: The match start position is tracked via matcher.startPosition,
 * and the match end is tracked in matcher.bestMatchEnd.
 *
 * @param {_NAVRegexMatcherState} matcher - The initialized matcher state
 *
 * @returns {char} TRUE if a match was found, FALSE otherwise
 */
define_function char NAVRegexExecuteMatch(_NAVRegexMatcherState matcher) {
    stack_var _NAVRegexThread initialThread
    stack_var integer i
    stack_var char currentChar
    stack_var char hasThreads

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ ExecuteMatch ]: Starting NFA execution'")
    NAVLog("'[ ExecuteMatch ]: Input length: ', itoa(matcher.inputLength)")
    NAVLog("'[ ExecuteMatch ]: Start position: ', itoa(matcher.startPosition)")
    #END_IF

    // Create initial thread at NFA start state
    NAVRegexThreadInit(initialThread, matcher.nfa.startState)

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ ExecuteMatch ]: Initial thread created at state ', itoa(initialThread.stateId)")
    #END_IF

    // Add to current list with epsilon-closure
    NAVRegexAddThread(matcher, matcher.currentList, initialThread)

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ ExecuteMatch ]: After epsilon-closure, thread count: ', itoa(matcher.currentList.count)")
    #END_IF

    // Check if MATCH was reached during initial epsilon-closure (zero-length match)
    if (matcher.hasMatch) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ ExecuteMatch ]: Zero-length match found during initial epsilon-closure'")
        #END_IF
        // Zero-length match found, but don't stop yet - continue to see if we can
        // find a better (non-empty) match. The match selection logic will prefer
        // non-empty matches over empty ones when positions are equal.
        // Adjust end position to indicate no characters consumed so far
        matcher.bestMatchEnd = matcher.startPosition - 1
        // Continue execution to try to find non-empty match
    }

    // Check if start state is already a MATCH (empty pattern case)
    if (matcher.nfa.states[matcher.nfa.startState].type == NFA_STATE_MATCH) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ ExecuteMatch ]: Start state is MATCH (empty pattern)'")
        #END_IF
        matcher.bestThread = initialThread
        matcher.hasMatch = true
        matcher.bestMatchEnd = matcher.startPosition - 1  // Empty match
        return true
    }

    // Step through input characters
    for (i = matcher.startPosition; i <= matcher.inputLength; i++) {
        if (matcher.currentList.count == 0) {
            // No threads left, match failed
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ ExecuteMatch ]: No threads at position ', itoa(i), ', match failed'")
            #END_IF
            break
        }

        currentChar = matcher.inputString[i]
        matcher.currentPosition = i

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ ExecuteMatch ]: Position ', itoa(i), ', char: ', currentChar, ' (ASCII: ', itoa(type_cast(currentChar)), '), threads: ', itoa(matcher.currentList.count)")
        #END_IF

        // Process one step (updates currentList/nextList internally)
        // NAVRegexMatchStep will set hasMatch and bestThread if MATCH state found
        hasThreads = NAVRegexMatchStep(matcher, currentChar)

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ ExecuteMatch ]: After step, hasMatch: ', itoa(matcher.hasMatch), ', hasThreads: ', itoa(hasThreads)")
        #END_IF

        // For lazy quantifiers: If we have a match and there are still threads,
        // check if any remaining thread has higher priority than our best match.
        // This indicates a lazy quantifier where we should stop at the minimal match.
        //
        // Example: Pattern /(a+?)/ on "aaa"
        // - After first 'a': SPLIT creates thread-A (exit, priority=0) and thread-B (loop, priority=1)
        // - Thread-A reaches MATCH immediately (bestThread.priority=0, bestMatchEnd=1)
        // - Thread-B is still active in nextList (priority=1)
        // - We should stop here, not continue with thread-B
        if (matcher.hasMatch && hasThreads) {
            stack_var integer threadIdx
            stack_var _NAVRegexThread currentThread
            stack_var char hasHigherPriorityThread

            hasHigherPriorityThread = false

            // Check if any active thread has higher priority (larger number = lower preference)
            for (threadIdx = 1; threadIdx <= matcher.currentList.count; threadIdx++) {
                if (NAVRegexThreadListGet(matcher.currentList, threadIdx, currentThread)) {
                    if (currentThread.priority > matcher.bestThread.priority) {
                        hasHigherPriorityThread = true
                        break
                    }
                }
            }

            if (hasHigherPriorityThread) {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ ExecuteMatch ]: Lazy quantifier detected (match priority=', itoa(matcher.bestThread.priority), ', remaining threads have higher priority), stopping'")
                #END_IF
                return true
            }
        }

        if (!hasThreads && !matcher.hasMatch) {
            // No match found and no threads to continue
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ ExecuteMatch ]: No threads and no match, stopping'")
            #END_IF
            break
        }

        if (!hasThreads && matcher.hasMatch) {
            // Found match, no more threads
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ ExecuteMatch ]: Match found, stopping'")
            #END_IF
            return true
        }
    }

    // Final epsilon-closure for end-of-input anchor evaluation
    // Position is already at inputLength + 1 from the loop
    // This allows end anchors ($, \z, \Z) to match via epsilon-closure
    if (matcher.currentList.count > 0) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ ExecuteMatch ]: Performing final epsilon-closure'")
        #END_IF
        // Note: currentPosition is already inputLength + 1 from loop
        // (For empty strings, it's 1; for non-empty, it's length + 1)
        matcher.currentPosition = matcher.inputLength + 1
        if (!NAVRegexFinalEpsilonClosure(matcher)) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ ExecuteMatch ]: ERROR - Final epsilon-closure failed'")
            #END_IF
            return false
        }
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ ExecuteMatch ]: Final result - hasMatch: ', itoa(matcher.hasMatch)")
    if (matcher.hasMatch) {
        NAVLog("'[ ExecuteMatch ]: Match end position: ', itoa(matcher.bestMatchEnd)")
    }
    #END_IF

    // Return true if we found any match
    return matcher.hasMatch
}


/**
 * @function NAVRegexFinalEpsilonClosure
 * @private
 * @description Perform final epsilon-closure for end-of-input anchor evaluation.
 *
 * After processing all input characters, this function performs a final
 * epsilon-closure at position (inputLength + 1) to allow end anchors
 * ($, \z, \Z) to be evaluated.
 *
 * The epsilon-closure will:
 * - Evaluate end anchors ($, \z, \Z) at end-of-input
 * - Detect MATCH states via epsilon transitions
 * - Handle zero-width assertions at end of input
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state
 *
 * @return {char} true on success, false on error
 */
define_function char NAVRegexFinalEpsilonClosure(_NAVRegexMatcherState matcher) {
    stack_var integer i
    stack_var _NAVRegexThread thread

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ FinalEpsilonClosure ]: Performing final epsilon-closure at position ', itoa(matcher.currentPosition)")
    NAVLog("'[ FinalEpsilonClosure ]: Current thread count: ', itoa(matcher.currentList.count)")
    #END_IF

    // Position is already at inputLength + 1 from the main loop
    // Perform epsilon-closure to check end anchors and MATCH states
    if (!NAVRegexEpsilonClosure(matcher, matcher.currentList, matcher.nextList)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ FinalEpsilonClosure ]: ERROR - Epsilon-closure failed'")
        #END_IF
        return false
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ FinalEpsilonClosure ]: After epsilon-closure, thread count: ', itoa(matcher.nextList.count)")
    #END_IF

    // Swap lists to make results active
    NAVRegexThreadListClear(matcher.currentList)
    for (i = 1; i <= matcher.nextList.count; i++) {
        if (!NAVRegexThreadListGet(matcher.nextList, i, thread)) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ FinalEpsilonClosure ]: ERROR - Failed to get thread at index ', itoa(i)")
            #END_IF
            return false
        }

        if (!NAVRegexThreadListAdd(matcher.currentList, thread)) {
            // Note: Add can fail if list is full or state already visited
            // For duplicates, this is expected and not an error
            // For full list, this could indicate a problem but we continue
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ FinalEpsilonClosure ]: WARNING - Failed to add thread (may be duplicate or list full)'")
            #END_IF
        }
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ FinalEpsilonClosure ]: Final thread count: ', itoa(matcher.currentList.count)")
    if (matcher.hasMatch) {
        NAVLog("'[ FinalEpsilonClosure ]: Match found during final closure'")
    }
    #END_IF

    return true
}


/**
 * @function NAVRegexMatchInternal
 * @private
 * @description Internal matching function that executes NFA and builds result.
 *
 * This is the core matching engine that:
 * 1. Initializes the matcher with NFA and input
 * 2. Executes the NFA simulation
 * 3. Extracts match results and capture groups
 * 4. Returns a single match result
 *
 * Used by all public API functions (Simple and Advanced).
 *
 * @param {_NAVRegexNFA} nfa - The compiled NFA
 * @param {char[]} input - Input string to match against
 * @param {integer} startPos - Starting position (1-based)
 * @param {_NAVRegexMatchResult} result - Result structure to populate
 *
 * @returns {char} TRUE if match found, FALSE otherwise
 */
define_function char NAVRegexMatchInternal(_NAVRegexNFA nfa,
                                           char input[],
                                           integer startPos,
                                           _NAVRegexMatchResult result) {
    stack_var _NAVRegexMatcherState matcher
    stack_var char matched
    stack_var integer tryPos
    stack_var integer inputLen
    stack_var integer maxTryPos

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchInternal ]: Called with input: "', input, '", startPos: ', itoa(startPos)")
    #END_IF

    // Initialize result to NO_MATCH
    NAVRegexResultInit(result)

    // Validate inputs
    inputLen = length_array(input)
    if (startPos < 1 || startPos > inputLen + 1) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchInternal ]: ERROR - Invalid start position: ', itoa(startPos)")
        #END_IF
        NAVRegexResultSetError(result, 'Invalid start position')
        return false
    }

    if (nfa.stateCount == 0) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchInternal ]: ERROR - Invalid NFA: no states'")
        #END_IF
        NAVRegexResultSetError(result, 'Invalid NFA: no states')
        return false
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchInternal ]: Validation passed, searching for match'")
    #END_IF

    // Thompson algorithm: Try matching from each position starting at startPos
    // This implements the "search" behavior (find pattern anywhere in string)
    // For "validate" behavior (pattern must match from start), caller passes startPos=1
    //
    // For empty strings (inputLen=0), we still need to try matching at position 1
    // to handle patterns like /^$/ which match empty strings.
    // The loop runs: for (tryPos = startPos; tryPos <= max(inputLen, startPos); tryPos++)
    maxTryPos = inputLen
    if (startPos > maxTryPos) {
        maxTryPos = startPos  // Allow at least one attempt at startPos (for empty strings)
    }

    for (tryPos = startPos; tryPos <= maxTryPos; tryPos++) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchInternal ]: Trying match from position ', itoa(tryPos)")
        #END_IF

        // Initialize matcher for this starting position
        if (!NAVRegexMatcherInit(matcher, nfa, input, tryPos)) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchInternal ]: ERROR - Matcher initialization failed'")
            #END_IF
            NAVRegexResultSetError(result, 'Matcher initialization failed')
            return false
        }

        // Execute NFA simulation from this position
        matched = NAVRegexExecuteMatch(matcher)

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchInternal ]: Position ', itoa(tryPos), ' result: ', itoa(matched)")
        #END_IF

        // If match found, build result and return success
        if (matched) {
            // Match found: extract captures from bestThread
            // Match starts at tryPos and ends at matcher.bestMatchEnd
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchInternal ]: Match found! Building result from ', itoa(tryPos), ' to ', itoa(matcher.bestMatchEnd)")
            #END_IF
            NAVRegexResultSetMatch(result,
                                   matcher,
                                   matcher.bestThread,
                                   tryPos,
                                   matcher.bestMatchEnd)
            return true
        }
    }

    // No match found from any position
    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchInternal ]: No match found from any position'")
    #END_IF
    NAVRegexResultSetNoMatch(result)
    return false
}


/**
 * @function NAVRegexMatchGlobalInternal
 * @private
 * @description Find all non-overlapping matches using compiled NFA.
 *
 * Core implementation for global matching logic. Searches entire input string
 * from left to right, collecting all non-overlapping matches up to MAX_REGEX_MATCHES.
 *
 * Uses literal prefix optimization when available to skip positions where the
 * pattern cannot possibly match (100-1000x speedup for literal patterns).
 *
 * Algorithm:
 * 1. Extract literal prefix from NFA (if possible)
 * 2. For each position in input:
 *    a. If prefix exists, use NAVIndexOf to jump to next prefix occurrence
 *    b. Try matching from that position using NAVRegexMatchInternal
 *    c. On match: store result, advance past match end
 *    d. On no match: advance to next position
 * 3. Stop when: no more input, no more prefix occurrences, or MAX_REGEX_MATCHES reached
 *
 * This function centralizes the global matching loop that was previously
 * duplicated across 4 different API functions, reducing code duplication
 * and maintenance burden.
 *
 * @param {_NAVRegexNFA} nfa - The compiled NFA to execute
 * @param {char[]} input - Input string to search in
 * @param {_NAVRegexMatchCollection} collection - Result structure to populate
 * @param {char[]} callerName - Name of calling function (for logging/warnings)
 *
 * @returns {char} TRUE if at least one match found, FALSE otherwise
 */
define_function char NAVRegexMatchGlobalInternal(_NAVRegexNFA nfa,
                                                   char input[],
                                                   _NAVRegexMatchCollection collection,
                                                   char callerName[]) {
    stack_var integer nextPos
    stack_var integer matchIndex
    stack_var char literalPrefix[255]
    stack_var integer prefixLen
    stack_var integer foundPos

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchGlobalInternal (', callerName, ') ]: Starting global match'")
    #END_IF

    // Initialize collection
    NAVRegexMatchCollectionInit(collection)

    // OPTIMIZATION: Extract literal prefix from pattern (if possible)
    // This allows us to use NAVIndexOf to skip to positions where the pattern
    // might match, providing significant speedup for literal patterns.
    prefixLen = NAVRegexMatcherGetLiteralPrefix(nfa, literalPrefix)

    #IF_DEFINED REGEX_MATCHER_DEBUG
    if (prefixLen > 0) {
        NAVLog("'[ MatchGlobalInternal ]: Literal prefix optimization enabled: "', literalPrefix, '" (', itoa(prefixLen), ' chars)'")
    }
    else {
        NAVLog("'[ MatchGlobalInternal ]: No literal prefix, using standard search'")
    }
    #END_IF

    // Find all matches
    nextPos = 1
    matchIndex = 1

    while (nextPos <= length_array(input) && matchIndex <= MAX_REGEX_MATCHES) {
        // OPTIMIZATION: Use NAVIndexOf (case-sensitive or insensitive) to skip to next potential match position
        // This avoids running expensive NFA simulations at positions where the
        // literal prefix doesn't even exist in the input string.
        if (prefixLen > 0) {
            if (nfa.flags band PARSER_FLAG_CASE_INSENSITIVE) {
                foundPos = NAVIndexOfCaseInsensitive(input, literalPrefix, nextPos)
            } else {
                foundPos = NAVIndexOf(input, literalPrefix, nextPos)
            }

            if (foundPos == 0) {
                // No more occurrences of literal prefix in remaining input
                // No point trying any more positions - exit loop immediately
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ MatchGlobalInternal ]: Literal prefix not found from position ', itoa(nextPos), ', ending search'")
                #END_IF
                break
            }

            // Jump directly to the position where prefix was found
            nextPos = foundPos

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchGlobalInternal ]: Prefix found at position ', itoa(nextPos), ', attempting match'")
            #END_IF
        }
        else {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchGlobalInternal ]: Attempting match at position ', itoa(nextPos)")
            #END_IF
        }

        // Try matching from this position
        if (NAVRegexMatchInternal(nfa, input, nextPos, collection.matches[matchIndex])) {
            collection.count++
            matchIndex++

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchGlobalInternal ]: Match found! Total matches: ', itoa(collection.count)")
            #END_IF

            // Move to position after this match
            nextPos = collection.matches[matchIndex - 1].fullMatch.end + 1

            // Prevent infinite loop on zero-width matches
            if (collection.matches[matchIndex - 1].fullMatch.length == 0) {
                nextPos++
            }
        }
        else {
            // No match at this position, try next position
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchGlobalInternal ]: No match at position ', itoa(nextPos), ', trying next'")
            #END_IF
            nextPos++
        }
    }

    // Check if we stopped due to reaching the match limit
    if (collection.count == MAX_REGEX_MATCHES && nextPos <= length_array(input)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_REGEX_MATCHER__,
                                'NAVRegexMatchGlobalInternal',
                                "'Match limit reached (', itoa(MAX_REGEX_MATCHES), ' matches) in ', callerName, '. Additional matches may exist but were not captured.'")
    }

    if (collection.count > 0) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchGlobalInternal ]: Completed with ', itoa(collection.count), ' matches'")
        #END_IF
        collection.status = MATCH_STATUS_SUCCESS
        return true
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchGlobalInternal ]: No matches found'")
    #END_IF

    return false
}


#END_IF // __NAV_FOUNDATION_REGEX_MATCHER__
