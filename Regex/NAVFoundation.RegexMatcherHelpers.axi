PROGRAM_NAME='NAVFoundation.RegexMatcherHelpers'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_MATCHER_HELPERS__
#DEFINE __NAV_FOUNDATION_REGEX_MATCHER_HELPERS__ 'NAVFoundation.RegexMatcherHelpers'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.RegexMatcher.h.axi'


/**
 * @function NAVRegexMatcherGetLiteralPrefix
 * @private
 * @description Extract a literal string prefix from the NFA pattern.
 *
 * Analyzes the NFA states starting from the start state and extracts
 * consecutive LITERAL states to build a literal string prefix. This prefix
 * can be used with NAVIndexOf() to quickly skip to positions where the
 * pattern might match, providing 100-1000x speedup for literal patterns.
 *
 * The function stops extracting when it encounters:
 * - A non-literal state (character class, quantifier, etc.)
 * - A SPLIT state (indicating alternation or optional content)
 * - Multiple outgoing transitions (ambiguous path)
 * - End of pattern
 *
 * Examples:
 * - Pattern /test/      → Returns "test"
 * - Pattern /abc\d+/    → Returns "abc"
 * - Pattern /hello.*\/   → Returns "hello"
 * - Pattern /[abc]/     → Returns "" (no literal prefix)
 * - Pattern /(cat|dog)/ → Returns "" (alternation, no single prefix)
 *
 * @param {_NAVRegexNFA} nfa - The compiled NFA to analyze
 * @param {char[]} prefix - Output: the extracted literal prefix (empty if none)
 *
 * @returns {integer} Length of the extracted prefix (0 if no literal prefix)
 */
define_function integer NAVRegexMatcherGetLiteralPrefix(_NAVRegexNFA nfa,
                                                         char prefix[]) {
    stack_var integer stateId
    stack_var _NAVRegexNFAState state
    stack_var integer prefixLen

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ GetLiteralPrefix ]: Analyzing NFA for literal prefix'")
    #END_IF

    prefix = ''
    prefixLen = 0

    if (nfa.stateCount == 0) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ GetLiteralPrefix ]: Empty NFA, no prefix'")
        #END_IF
        return 0
    }

    stateId = nfa.startState

    // Follow states, building literal string
    while (stateId > 0 && stateId <= nfa.stateCount && prefixLen < 255) {
        state = nfa.states[stateId]

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ GetLiteralPrefix ]: State ', itoa(stateId), ' type: ', itoa(state.type)")
        #END_IF

        select {
            // Extract literal character
            active (state.type == NFA_STATE_LITERAL): {
                prefix = "prefix, state.matchChar"
                prefixLen++

                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ GetLiteralPrefix ]: Added literal: ', state.matchChar, ' (prefix now: "', prefix, '")'")
                #END_IF

                // Move to next state (if only one transition)
                if (state.transitionCount == 1) {
                    stateId = state.transitions[1].targetState
                }
                else if (state.transitionCount == 0) {
                    // No more transitions, done
                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ GetLiteralPrefix ]: No more transitions, stopping'")
                    #END_IF
                    break
                }
                else {
                    // Multiple paths, stop here (can't determine single path)
                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ GetLiteralPrefix ]: Multiple transitions (', itoa(state.transitionCount), '), stopping'")
                    #END_IF
                    break
                }
            }

            // Skip epsilon/capture states (they don't consume input)
            active (state.type == NFA_STATE_EPSILON ||
                    state.type == NFA_STATE_CAPTURE_START ||
                    state.type == NFA_STATE_CAPTURE_END): {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ GetLiteralPrefix ]: Skipping epsilon/capture state'")
                #END_IF

                if (state.transitionCount == 1) {
                    stateId = state.transitions[1].targetState
                }
                else {
                    // Multiple paths or no path, stop
                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ GetLiteralPrefix ]: Multiple/no transitions from epsilon, stopping'")
                    #END_IF
                    break
                }
            }

            // SPLIT indicates alternation or quantifier - can't extract reliable prefix
            active (state.type == NFA_STATE_SPLIT): {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ GetLiteralPrefix ]: SPLIT state encountered, stopping'")
                #END_IF
                break
            }

            // Any other state type = can't extract literal prefix
            active (1): {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ GetLiteralPrefix ]: Non-literal state type ', itoa(state.type), ', stopping'")
                #END_IF
                break
            }
        }
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ GetLiteralPrefix ]: Final prefix: "', prefix, '" (length: ', itoa(prefixLen), ')'")
    #END_IF

    return prefixLen
}


// ============================================================================
// MATCH COLLECTION MANAGEMENT
// ============================================================================

/**
 * @function NAVRegexMatchCollectionInit
 * @public
 * @description Initialize a match collection to default state.
 *
 * Sets status to NO_MATCH, clears count and error message.
 * Should be called before populating a collection structure.
 *
 * This helper function centralizes collection initialization logic,
 * ensuring consistent setup across all match functions.
 *
 * @param {_NAVRegexMatchCollection} collection - Collection to initialize
 *
 * @returns {void}
 */
define_function NAVRegexMatchCollectionInit(_NAVRegexMatchCollection collection) {
    collection.status = MATCH_STATUS_NO_MATCH
    collection.count = 0
    collection.errorMessage = ''
}


// ============================================================================
// THREAD MANAGEMENT
// ============================================================================

/**
 * @function NAVRegexThreadInit
 * @public
 * @description Initialize a thread with a given NFA state.
 *
 * Sets the thread to execute at the specified NFA state and clears all
 * capture group positions. The priority is reset to 0. This prepares
 * a thread for use in the NFA simulation.
 *
 * @param {_NAVRegexThread} thread - The thread structure to initialize
 * @param {integer} stateId - The NFA state ID where this thread will execute
 *
 * @returns {void}
 */
define_function NAVRegexThreadInit(_NAVRegexThread thread, integer stateId) {
    stack_var integer i

    thread.stateId = stateId
    thread.priority = 0
    thread.positionOffset = 0

    // Clear all capture positions (0 = not captured)
    for (i = 1; i <= MAX_REGEX_GROUPS; i++) {
        thread.captureStarts[i] = 0
        thread.captureEnds[i] = 0
    }
}


/**
 * @function NAVRegexThreadCopy
 * @public
 * @description Copy a thread, preserving all state including capture positions.
 *
 * Creates a complete copy of a thread including its state ID, priority,
 * and all captured group positions. Used when spawning new execution
 * paths during NFA simulation.
 *
 * @param {_NAVRegexThread} dest - The destination thread to copy into
 * @param {_NAVRegexThread} src - The source thread to copy from
 *
 * @returns {void}
 */
define_function NAVRegexThreadCopy(_NAVRegexThread dest, _NAVRegexThread src) {
    stack_var integer i

    dest.stateId = src.stateId
    dest.priority = src.priority
    dest.positionOffset = src.positionOffset

    // Copy all capture positions
    for (i = 1; i <= MAX_REGEX_GROUPS; i++) {
        dest.captureStarts[i] = src.captureStarts[i]
        dest.captureEnds[i] = src.captureEnds[i]
    }
}


/**
 * @function NAVRegexThreadListInit
 * @public
 * @description Initialize a thread list structure.
 *
 * Prepares a thread list for use by setting the count to 0, initializing
 * the generation counter to 1, and clearing the visited state array.
 * Must be called before using a thread list.
 *
 * @param {_NAVRegexThreadList} list - The thread list structure to initialize
 *
 * @returns {void}
 */
define_function NAVRegexThreadListInit(_NAVRegexThreadList list) {
    stack_var integer i

    list.count = 0
    list.generation = 1

    // Clear visited array
    for (i = 1; i <= MAX_REGEX_MATCHER_STATES; i++) {
        list.visited[i] = 0
    }
}


/**
 * @function NAVRegexThreadListClear
 * @public
 * @description Clear a thread list for reuse.
 *
 * Resets the thread count to 0 and increments the generation counter.
 * The generation counter is used for efficient duplicate detection -
 * no need to actually clear the visited array, as any state with
 * visited[stateId] != current generation is considered unvisited.
 *
 * @param {_NAVRegexThreadList} list - The thread list to clear
 *
 * @returns {void}
 */
define_function NAVRegexThreadListClear(_NAVRegexThreadList list) {
    list.count = 0
    list.generation++

    // No need to clear visited array - generation counter handles it
    // Any visited[stateId] != current generation is considered unvisited
}


/**
 * @function NAVRegexThreadListIsVisited
 * @public
 * @description Check if a state has been visited in the current generation.
 *
 * Uses the generation counter for efficient duplicate detection. A state
 * is considered visited if visited[stateId] equals the current generation.
 * This prevents processing the same NFA state multiple times in a single step.
 *
 * @param {_NAVRegexThreadList} list - The thread list to check
 * @param {integer} stateId - The NFA state ID to check (1-based)
 *
 * @returns {char} True (1) if visited in current generation, False (0) otherwise
 */
define_function char NAVRegexThreadListIsVisited(_NAVRegexThreadList list,
                                                  integer stateId) {
    if (stateId < 1 || stateId > MAX_REGEX_MATCHER_STATES) {
        return false
    }

    return (list.visited[stateId] == list.generation)
}


/**
 * @function NAVRegexThreadListMarkVisited
 * @public
 * @description Mark a state as visited in the current generation.
 *
 * Sets visited[stateId] to the current generation counter, marking this
 * state as processed for this step of the NFA simulation. This prevents
 * duplicate threads from being created for the same state.
 *
 * @param {_NAVRegexThreadList} list - The thread list
 * @param {integer} stateId - The NFA state ID to mark as visited (1-based)
 *
 * @returns {void}
 */
define_function NAVRegexThreadListMarkVisited(_NAVRegexThreadList list,
                                               integer stateId) {
    if (stateId < 1 || stateId > MAX_REGEX_MATCHER_STATES) {
        return
    }

    list.visited[stateId] = list.generation
}


/**
 * @function NAVRegexThreadListAdd
 * @public
 * @description Add a thread to a thread list with duplicate detection.
 *
 * Adds the thread to the list only if its state has not been visited in
 * the current generation. This implements the key optimization in Thompson's
 * NFA simulation - preventing duplicate execution paths for the same state.
 *
 * If the state has already been visited, or if the list is full, the thread
 * is not added and the function returns False.
 *
 * @param {_NAVRegexThreadList} list - The thread list to add to
 * @param {_NAVRegexThread} thread - The thread to add
 *
 * @returns {char} True (1) if thread was added, False (0) if duplicate or list full
 */
define_function char NAVRegexThreadListAdd(_NAVRegexThreadList list,
                                           _NAVRegexThread thread) {
    // Check if state already visited
    if (NAVRegexThreadListIsVisited(list, thread.stateId)) {
        return false  // Duplicate - don't add
    }

    // Check if list is full
    if (list.count >= MAX_REGEX_MATCHER_STATES) {
        return false  // List full
    }

    // Add thread
    list.count++
    NAVRegexThreadCopy(list.threads[list.count], thread)

    // Mark state as visited
    NAVRegexThreadListMarkVisited(list, thread.stateId)

    return true
}


/**
 * @function NAVRegexThreadListGet
 * @public
 * @description Get a thread from a thread list by index.
 *
 * Retrieves a copy of the thread at the specified index in the list.
 * The index is 1-based following NetLinx conventions. If the index is
 * out of bounds, the function returns False and the thread parameter
 * is not modified.
 *
 * @param {_NAVRegexThreadList} list - The thread list to retrieve from
 * @param {integer} index - The index of the thread to retrieve (1-based)
 * @param {_NAVRegexThread} thread - Output parameter: receives copy of the thread
 *
 * @returns {char} True (1) if index valid and thread retrieved, False (0) otherwise
 */
define_function char NAVRegexThreadListGet(_NAVRegexThreadList list,
                                           integer index,
                                           _NAVRegexThread thread) {
    if (index < 1 || index > list.count) {
        return false
    }

    NAVRegexThreadCopy(thread, list.threads[index])
    return true
}


// ============================================================================
// CHARACTER MATCHING
// ============================================================================

/**
 * @function NAVRegexToUpper
 * @private
 * @description Convert a single character to uppercase.
 *
 * Helper function for case-insensitive matching. Converts lowercase
 * letters (a-z) to uppercase (A-Z), leaves all other characters unchanged.
 *
 * @param {char} c - The character to convert
 *
 * @returns {char} The uppercase version of the character
 */
define_function char NAVRegexToUpper(char c) {
    if (c >= 'a' && c <= 'z') {
        return c - 32  // Convert to uppercase by ASCII offset
    }
    return c
}


/**
 * @function NAVRegexMatchLiteral
 * @public
 * @description Match a literal character against input.
 *
 * Performs case-sensitive or case-insensitive comparison depending on
 * the MATCH_OPTION_CASE_INSENSITIVE flag. Used for NFA_STATE_LITERAL states.
 *
 * @param {_NAVRegexNFAState} state - The NFA state containing the character to match
 * @param {char} c - The input character to test
 * @param {integer} flags - Matching flags (bitfield of MATCH_OPTION_* constants)
 *
 * @returns {char} True (1) if character matches, False (0) otherwise
 */
define_function char NAVRegexMatchLiteral(_NAVRegexNFAState state, char c, integer flags) {
    stack_var char result

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchLiteral ]: c=', itoa(c), ' (char: ''', c, '''), matchChar=', itoa(state.matchChar), ' (char: ''', state.matchChar, ''')'")
    #END_IF

    if (flags & MATCH_OPTION_CASE_INSENSITIVE) {
        result = (NAVRegexToUpper(c) == NAVRegexToUpper(state.matchChar))
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchLiteral ]: Case-insensitive comparison result: ', itoa(result)")
        #END_IF
        return result
    }

    result = (c == state.matchChar)
    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchLiteral ]: Case-sensitive comparison result: ', itoa(result)")
    #END_IF
    return result
}


/**
 * @function NAVRegexMatchDot
 * @public
 * @description Match any character (dot metacharacter).
 *
 * By default, dot matches any character except newline (\n).
 * With the MATCH_OPTION_DOTALL flag, dot also matches newline.
 *
 * @param {_NAVRegexNFAState} state - The NFA state (type must be NFA_STATE_DOT)
 * @param {char} c - The input character to test
 * @param {integer} flags - Matching flags (bitfield of MATCH_OPTION_* constants)
 *
 * @returns {char} True (1) if character matches dot semantics, False (0) otherwise
 */
define_function char NAVRegexMatchDot(_NAVRegexNFAState state, char c, integer flags) {
    // Check if we should match newlines (DOTALL mode or state-specific flag)
    if (flags & MATCH_OPTION_DOTALL || state.matchesNewline) {
        return true  // Dot matches everything including newline
    }

    // Default: dot matches everything except newline
    return (c != $0A)  // $0A = \n (line feed)
}


/**
 * @function NAVRegexMatchCharClass
 * @public
 * @description Match a character against a character class.
 *
 * Tests if the character falls within any of the ranges defined in the
 * character class. Supports both positive [abc] and negated [^abc] classes.
 * Case-insensitive matching is applied if the flag is set.
 *
 * @param {_NAVRegexNFAState} state - The NFA state containing the character class
 * @param {char} c - The input character to test
 * @param {integer} flags - Matching flags (bitfield of MATCH_OPTION_* constants)
 *
 * @returns {char} True (1) if character matches class, False (0) otherwise
 */
define_function char NAVRegexMatchCharClass(_NAVRegexNFAState state, char c, integer flags) {
    stack_var integer i
    stack_var char testChar
    stack_var char rangeStart
    stack_var char rangeEnd
    stack_var char matched

    matched = false
    testChar = c

    // Apply case-insensitive conversion if needed
    if (flags & MATCH_OPTION_CASE_INSENSITIVE) {
        testChar = NAVRegexToUpper(c)
    }

    // Check predefined character classes first
    if (!matched && state.charClass.hasDigits) {
        if (NAVRegexMatchDigit(c)) {
            matched = true
        }
    }

    if (!matched && state.charClass.hasNonDigits) {
        if (!NAVRegexMatchDigit(c)) {
            matched = true
        }
    }

    if (!matched && state.charClass.hasWordChars) {
        if (NAVRegexMatchWord(c)) {
            matched = true
        }
    }

    if (!matched && state.charClass.hasNonWordChars) {
        if (!NAVRegexMatchWord(c)) {
            matched = true
        }
    }

    if (!matched && state.charClass.hasWhitespace) {
        if (NAVRegexMatchWhitespace(c)) {
            matched = true
        }
    }

    if (!matched && state.charClass.hasNonWhitespace) {
        if (!NAVRegexMatchWhitespace(c)) {
            matched = true
        }
    }

    // Check each range in the character class
    if (!matched) {
        for (i = 1; i <= state.charClass.rangeCount; i++) {
            rangeStart = state.charClass.ranges[i].start
            rangeEnd = state.charClass.ranges[i].end

            // Apply case-insensitive to ranges if needed
            if (flags & MATCH_OPTION_CASE_INSENSITIVE) {
                rangeStart = NAVRegexToUpper(rangeStart)
                rangeEnd = NAVRegexToUpper(rangeEnd)
            }

            // Check if character falls in this range
            if (testChar >= rangeStart && testChar <= rangeEnd) {
                matched = true
                break
            }
        }
    }

    // Apply negation if this is a negated class [^...]
    if (state.isNegated) {
        return !matched
    }

    return matched
}
/**
 * @function NAVRegexMatchDigit
 * @public
 * @description Match a decimal digit character (0-9).
 *
 * Used for \d pattern matching. Tests if character is in range '0' to '9'.
 *
 * @param {char} c - The input character to test
 *
 * @returns {char} True (1) if character is a digit, False (0) otherwise
 */
define_function char NAVRegexMatchDigit(char c) {
    return (c >= '0' && c <= '9')
}


/**
 * @function NAVRegexMatchWord
 * @public
 * @description Match a word character (alphanumeric or underscore).
 *
 * Used for \w pattern matching. Matches [a-zA-Z0-9_].
 *
 * @param {char} c - The input character to test
 *
 * @returns {char} True (1) if character is a word character, False (0) otherwise
 */
define_function char NAVRegexMatchWord(char c) {
    return ((c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z') ||
            (c >= '0' && c <= '9') ||
            (c == '_'))
}


/**
 * @function NAVRegexMatchWhitespace
 * @public
 * @description Match a whitespace character.
 *
 * Used for \s pattern matching. Matches space, tab, newline, carriage return,
 * form feed, and vertical tab.
 *
 * @param {char} c - The input character to test
 *
 * @returns {char} True (1) if character is whitespace, False (0) otherwise
 */
define_function char NAVRegexMatchWhitespace(char c) {
    return (c == ' ' ||   // Space
            c == $09 ||   // Tab (\t)
            c == $0A ||   // Line feed (\n)
            c == $0D ||   // Carriage return (\r)
            c == $0C ||   // Form feed (\f)
            c == $0B)     // Vertical tab (\v)
}


/**
 * @function NAVRegexMatchBegin
 * @public
 * @description Match the begin anchor (^).
 *
 * In default mode, matches only at the start of the string (position 1).
 * In MULTILINE mode, also matches after any newline character.
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state containing position and input
 * @param {integer} flags - Matching flags (bitfield of MATCH_OPTION_* constants)
 *
 * @returns {char} True (1) if at valid begin anchor position, False (0) otherwise
 */
define_function char NAVRegexMatchBegin(_NAVRegexMatcherState matcher, integer flags) {
    // Always match at start of string
    if (matcher.currentPosition == 1) {
        return true
    }

    // In MULTILINE mode, also match after newline
    if (flags & MATCH_OPTION_MULTILINE) {
        // Check if previous character(s) were a line ending
        if (matcher.currentPosition > 1) {
            stack_var char prevChar
            stack_var char prevPrevChar

            prevChar = matcher.inputString[matcher.currentPosition - 1]

            // Check for LF (Unix) or LF after CRLF (Windows)
            if (prevChar == $0A) {
                return true
            }

            // Check for standalone CR (Mac) - but NOT if it's part of CRLF
            if (prevChar == $0D) {
                // Make sure this CR is not followed by LF (CRLF sequence)
                if (matcher.currentPosition <= matcher.inputLength) {
                    if (matcher.inputString[matcher.currentPosition] != $0A) {
                        // Standalone CR
                        return true
                    }
                }
                else {
                    // CR at end of string
                    return true
                }
            }
        }
    }

    return false
}


/**
 * @function NAVRegexMatchEnd
 * @public
 * @description Match the end anchor ($).
 *
 * In default mode, matches after the last character of the string:
 * - At position (inputLength + 1) - after consuming all characters
 * - For empty strings (length=0), matches at position 1
 *
 * In MULTILINE mode, also matches before any newline character.
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state containing position and input
 * @param {integer} flags - Matching flags (bitfield of MATCH_OPTION_* constants)
 *
 * @returns {char} True (1) if at valid end anchor position, False (0) otherwise
 */
define_function char NAVRegexMatchEnd(_NAVRegexMatcherState matcher, integer flags) {
    // Match after the last character (position > inputLength)
    // For empty string (length=0), this means position 1
    // For non-empty string, this means position (length+1)
    if (matcher.currentPosition > matcher.inputLength) {
        return true
    }

    // In MULTILINE mode, also match before newline
    if (flags & MATCH_OPTION_MULTILINE) {
        // Check if current character is a line ending
        if (matcher.currentPosition <= matcher.inputLength) {
            stack_var char currChar
            currChar = matcher.inputString[matcher.currentPosition]

            // Unix LF, Mac CR, or Windows CRLF (first char of pair)
            if (currChar == $0A || currChar == $0D) {
                return true
            }
        }
    }

    return false
}


/**
 * @function NAVRegexMatchWordBoundary
 * @public
 * @description Match a word boundary (\b).
 *
 * A word boundary occurs when:
 * - Previous character is a word char XOR current character is a word char
 * - At the start/end of string with a word char adjacent
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state containing position and input
 *
 * @returns {char} True (1) if at word boundary, False (0) otherwise
 */
define_function char NAVRegexMatchWordBoundary(_NAVRegexMatcherState matcher) {
    stack_var char prevIsWord
    stack_var char currIsWord

    // Check previous character
    if (matcher.currentPosition == 1) {
        prevIsWord = false  // Before start of string
    } else {
        prevIsWord = NAVRegexMatchWord(matcher.inputString[matcher.currentPosition - 1])
    }

    // Check current character
    if (matcher.currentPosition > matcher.inputLength) {
        currIsWord = false  // After end of string
    } else {
        currIsWord = NAVRegexMatchWord(matcher.inputString[matcher.currentPosition])
    }

    // Boundary exists if exactly one is a word character (XOR)
    return (prevIsWord != currIsWord)
}


// ============================================================================
// EPSILON-CLOSURE
// ============================================================================

/**
 * @function NAVRegexAddThread
 * @public
 * @description Add a thread to a list with epsilon-closure.
 *
 * This is the core of Thompson's NFA simulation. When adding a thread,
 * we must follow all epsilon (non-consuming) transitions to find all
 * reachable states before the next input character is consumed.
 *
 * The function recursively follows:
 * - EPSILON transitions (direct jumps)
 * - SPLIT transitions (alternation, creates multiple paths)
 * - CAPTURE_START/END (records group positions)
 *
 * Duplicate detection via visited tracking prevents infinite loops.
 *
 * Algorithm:
 * 1. Check if state already visited (prevent duplicates/loops)
 * 2. Mark state as visited
 * 3. Handle epsilon transitions (EPSILON, SPLIT, CAPTURE_START/END)
 * 4. For actual matching states, add thread to list
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state with NFA
 * @param {_NAVRegexThreadList} list - The thread list to add to
 * @param {_NAVRegexThread} thread - The thread to add (with captures)
 *
 * @returns {char} True (1) if thread added successfully, False (0) otherwise
 */
define_function char NAVRegexAddThread(_NAVRegexMatcherState matcher,
                                       _NAVRegexThreadList list,
                                       _NAVRegexThread thread) {
    stack_var _NAVRegexNFAState state
    stack_var _NAVRegexThread newThread
    stack_var integer i

    // Bounds check
    if (thread.stateId < 1 || thread.stateId > matcher.nfa.stateCount) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ AddThread ]: ERROR - Invalid state ID: ', itoa(thread.stateId)")
        #END_IF
        return false
    }

    // Check if already visited (duplicate detection)
    if (NAVRegexThreadListIsVisited(list, thread.stateId)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ AddThread ]: State ', itoa(thread.stateId), ' already visited, skipping'")
        #END_IF
        return false  // Already processed this state
    }

    // Get the state
    state = matcher.nfa.states[thread.stateId]

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ AddThread ]: Processing state ', itoa(thread.stateId), ', type: ', itoa(state.type)")
    #END_IF

    // Handle epsilon transitions (don't consume input)
    switch (state.type) {
        case NFA_STATE_MATCH: {
            // Accept state - record match immediately
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ AddThread ]: MATCH state reached during epsilon-closure at effective position ', itoa(matcher.currentPosition + thread.positionOffset)")
            #END_IF

            // CRITICAL: Skip match processing if we're inside a lookaround sub-expression.
            // In lookaround context, MATCH states mark the end of the sub-expression,
            // not the main pattern. The mini-matcher loop will detect these via
            // dangling out states (transitionCount == 0).
            if (matcher.lookaroundDepth > 0) {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ AddThread ]: Inside lookaround (depth=', itoa(matcher.lookaroundDepth), '), skipping MATCH state processing'")
                #END_IF
                return false  // Don't process MATCH state or add thread
            }

            if (!matcher.hasMatch) {
                // First match found - record current position as end
                // NOTE: If adding to nextList (after character match), currentPosition
                // has been temporarily incremented to check anchors at the correct position.
                // The actual match end is the position BEFORE that increment.
                // If adding to currentList (initial epsilon-closure or anchor-only matches),
                // currentPosition is already correct and shouldn't be adjusted.
                //
                // ALSO: Use effective position (currentPosition + positionOffset) to account
                // for threads that consumed multiple characters (e.g., backreferences)
                stack_var integer effectivePosition

                effectivePosition = matcher.currentPosition + thread.positionOffset
                matcher.hasMatch = true
                NAVRegexThreadCopy(matcher.bestThread, thread)

                // Check if we're adding to nextList (post-character-match phase)
                if (list.generation == matcher.nextList.generation) {
                    // Post-character match: currentPosition was incremented, so subtract 1
                    matcher.bestMatchEnd = effectivePosition - 1
                } else {
                    // Initial/current list: currentPosition is correct as-is
                    matcher.bestMatchEnd = effectivePosition
                }

                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ AddThread ]: First match recorded, end position: ', itoa(matcher.bestMatchEnd)")
                #END_IF
            }
            else {
                // Compare with previous best match using these priorities:
                // 1. Leftmost match (lower start position)
                // 2. Longest match (higher end position)
                // 3. Non-empty over empty (when positions equal)
                // 4. Lower priority value (for lazy vs greedy quantifiers)
                stack_var integer matchEnd
                stack_var integer matchStart
                stack_var char shouldReplace
                stack_var integer effectivePosition

                // Use effective position (currentPosition + positionOffset)
                effectivePosition = matcher.currentPosition + thread.positionOffset

                // Determine correct match end based on which list we're adding to
                if (list.generation == matcher.nextList.generation) {
                    matchEnd = effectivePosition - 1
                } else {
                    matchEnd = effectivePosition
                }

                matchStart = matcher.startPosition
                shouldReplace = false

                // Rule 1 & 2: Leftmost-longest
                if (matchEnd > matcher.bestMatchEnd) {
                    shouldReplace = true
                }
                // Rule 3: If same end position, prefer non-empty over empty
                else if (matchEnd == matcher.bestMatchEnd) {
                    stack_var integer currentMatchLength
                    stack_var integer bestMatchLength

                    currentMatchLength = matchEnd - matchStart + 1
                    bestMatchLength = matcher.bestMatchEnd - matcher.startPosition + 1

                    if (currentMatchLength > bestMatchLength) {
                        // Current match is longer (non-empty vs empty)
                        shouldReplace = true
                    }
                    // Rule 4: If same length, use thread priority (lower is better)
                    else if (currentMatchLength == bestMatchLength && thread.priority < matcher.bestThread.priority) {
                        shouldReplace = true
                    }
                }

                if (shouldReplace) {
                    NAVRegexThreadCopy(matcher.bestThread, thread)
                    matcher.bestMatchEnd = matchEnd
                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ AddThread ]: Better match found, new end: ', itoa(matcher.bestMatchEnd), ', priority: ', itoa(thread.priority)")
                    #END_IF
                }
            }

            return true
        }

        case NFA_STATE_EPSILON: {
            // Mark as visited for epsilon-closure
            NAVRegexThreadListMarkVisited(list, thread.stateId)

            // Follow all epsilon transitions
            for (i = 1; i <= state.transitionCount; i++) {
                NAVRegexThreadCopy(newThread, thread)
                newThread.stateId = state.transitions[i].targetState
                NAVRegexAddThread(matcher, list, newThread)
            }
            return true
        }

        case NFA_STATE_SPLIT: {
            // Mark as visited for epsilon-closure
            NAVRegexThreadListMarkVisited(list, thread.stateId)

            // Follow all split branches (creates multiple execution paths)
            // Order matters: first transition is preferred path for greedy matching
            for (i = 1; i <= state.transitionCount; i++) {
                NAVRegexThreadCopy(newThread, thread)
                newThread.stateId = state.transitions[i].targetState
                newThread.priority = thread.priority + (i - 1)  // Lower priority for later branches
                NAVRegexAddThread(matcher, list, newThread)
            }
            return true
        }

        case NFA_STATE_CAPTURE_START: {
            // Mark as visited for epsilon-closure
            NAVRegexThreadListMarkVisited(list, thread.stateId)

            // Record capture group start position
            NAVRegexThreadCopy(newThread, thread)

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ AddThread ]: CAPTURE_START for group ', itoa(state.groupNumber), ' at effective position ', itoa(matcher.currentPosition + thread.positionOffset)")
            #END_IF

            if (state.groupNumber >= 1 && state.groupNumber <= MAX_REGEX_GROUPS) {
                // Use effective position: currentPosition + positionOffset
                // This ensures correct position tracking for threads that consumed multiple characters
                newThread.captureStarts[state.groupNumber] = type_cast(matcher.currentPosition + thread.positionOffset)
            }

            // Follow transition
            if (state.transitionCount > 0) {
                newThread.stateId = state.transitions[1].targetState
                NAVRegexAddThread(matcher, list, newThread)
            }
            return true
        }

        case NFA_STATE_CAPTURE_END: {
            // Mark as visited for epsilon-closure
            NAVRegexThreadListMarkVisited(list, thread.stateId)

            // Record capture group end position
            NAVRegexThreadCopy(newThread, thread)

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ AddThread ]: CAPTURE_END for group ', itoa(state.groupNumber), ' at effective position ', itoa(matcher.currentPosition + thread.positionOffset - 1)")
            #END_IF

            if (state.groupNumber >= 1 && state.groupNumber <= MAX_REGEX_GROUPS) {
                // Use effective position: currentPosition + positionOffset - 1
                // -1 because capture end is inclusive (last character of capture)
                newThread.captureEnds[state.groupNumber] = type_cast(matcher.currentPosition + thread.positionOffset - 1)
            }

            // Follow transition
            if (state.transitionCount > 0) {
                newThread.stateId = state.transitions[1].targetState
                NAVRegexAddThread(matcher, list, newThread)
            }
            return true
        }

        // Anchor states (zero-width assertions) - handle during epsilon-closure
        case NFA_STATE_BEGIN:
        case NFA_STATE_END:
        case NFA_STATE_WORD_BOUNDARY:
        case NFA_STATE_NOT_WORD_BOUNDARY:
        case NFA_STATE_STRING_START:
        case NFA_STATE_STRING_END:
        case NFA_STATE_STRING_END_ABS: {
            // Check if anchor matches at effective position (currentPosition + thread.positionOffset)
            if (NAVRegexMatchStateAnchor(matcher, state, thread)) {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ AddThread ]: Anchor state ', itoa(state.type), ' matched, following transitions'")
                #END_IF
                // Anchor matched - follow transitions
                if (state.transitionCount > 0) {
                    // Mark as visited for epsilon-closure (prevents loops when following transitions)
                    NAVRegexThreadListMarkVisited(list, thread.stateId)

                    for (i = 1; i <= state.transitionCount; i++) {
                        NAVRegexThreadCopy(newThread, thread)
                        newThread.stateId = state.transitions[i].targetState
                        NAVRegexAddThread(matcher, list, newThread)
                    }
                }
                else {
                    // Anchor matched but has no transitions (dangling out state)
                    // Add it to the list as an accept state WITHOUT marking as visited first
                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ AddThread ]: Anchor state has no transitions, adding as accept state'")
                    #END_IF
                    NAVRegexThreadListAdd(list, thread)
                }
            }
            else {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ AddThread ]: Anchor state ', itoa(state.type), ' did not match, thread dies'")
                #END_IF
                // Anchor did not match - this thread dies
            }
            return true
        }

        // Lookaround assertions (zero-width - handle during epsilon-closure)
        case NFA_STATE_LOOKAHEAD_POS:
        case NFA_STATE_LOOKAHEAD_NEG:
        case NFA_STATE_LOOKBEHIND_POS:
        case NFA_STATE_LOOKBEHIND_NEG: {
            stack_var char isLookbehind
            stack_var char lookaroundMatched

            // Mark as visited for epsilon-closure
            NAVRegexThreadListMarkVisited(list, thread.stateId)

            isLookbehind = (state.type == NFA_STATE_LOOKBEHIND_POS || state.type == NFA_STATE_LOOKBEHIND_NEG)

            // Test lookaround assertion
            lookaroundMatched = NAVRegexMatchLookaround(matcher, state, thread, isLookbehind)

            if (lookaroundMatched) {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ AddThread ]: Lookaround assertion passed, following transitions'")
                #END_IF
                // Lookaround matched - follow transitions
                for (i = 1; i <= state.transitionCount; i++) {
                    NAVRegexThreadCopy(newThread, thread)
                    newThread.stateId = state.transitions[i].targetState
                    NAVRegexAddThread(matcher, list, newThread)
                }
            }
            else {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ AddThread ]: Lookaround assertion failed, thread dies'")
                #END_IF
                // Lookaround did not match - this thread dies
            }
            return true
        }

        default: {
            // Non-epsilon state (actual matching state)
            // Add this thread to the list (NAVRegexThreadListAdd will mark as visited)
            return NAVRegexThreadListAdd(list, thread)
        }
    }

    return false
}


/**
 * @function NAVRegexEpsilonClosure
 * @public
 * @description Compute epsilon-closure for all threads in a list.
 *
 * Takes a source list of threads and computes the complete epsilon-closure
 * for all of them, storing the result in the destination list. This finds
 * all states reachable via epsilon transitions without consuming input.
 *
 * The destination list is cleared (generation incremented) before processing.
 * Each thread from the source list is expanded via NAVRegexAddThread, which
 * recursively follows epsilon transitions.
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state with NFA
 * @param {_NAVRegexThreadList} sourceList - Input thread list to expand
 * @param {_NAVRegexThreadList} destList - Output thread list (epsilon-closed)
 *
 * @returns {char} True (1) if successful, False (0) if error
 */
define_function char NAVRegexEpsilonClosure(_NAVRegexMatcherState matcher,
                                             _NAVRegexThreadList sourceList,
                                             _NAVRegexThreadList destList) {
    stack_var integer i
    stack_var _NAVRegexThread thread

    // Clear destination list (increment generation for fresh visited tracking)
    NAVRegexThreadListClear(destList)

    // Process each thread in source list
    for (i = 1; i <= sourceList.count; i++) {
        if (NAVRegexThreadListGet(sourceList, i, thread)) {
            // Add thread with epsilon-closure
            // This will recursively follow all epsilon transitions
            NAVRegexAddThread(matcher, destList, thread)
        }
    }

    return true
}


// ============================================================================
// BACKREFERENCES
// ============================================================================

/**
 * @function NAVRegexMatchBackref
 * @private
 * @description Test if a backreference matches at the current position.
 *
 * Backreferences (\1, \2, etc.) match the same text that was captured
 * by an earlier capturing group. This function:
 * 1. Gets the captured text from the thread's capture array
 * 2. Compares it with the input at the current position
 * 3. Returns the length of the match if successful
 *
 * Backreferences are unique in that they consume variable-length input,
 * unlike normal character states that always consume exactly 1 character.
 *
 * If the referenced group didn't participate in the match (wasn't captured),
 * the backreference fails.
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state
 * @param {_NAVRegexNFAState} state - The backreference state (contains group number)
 * @param {_NAVRegexThread} thread - The thread with capture information
 *
 * @returns {integer} Length of matched text (>= 0), or 0 if no match
 */
define_function integer NAVRegexMatchBackref(_NAVRegexMatcherState matcher,
                                              _NAVRegexNFAState state,
                                              _NAVRegexThread thread) {
    stack_var integer groupNum
    stack_var integer captureStart
    stack_var integer captureEnd
    stack_var integer captureLength
    stack_var char capturedText[NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer inputPos
    stack_var char capturedChar
    stack_var char inputChar
    stack_var char caseInsensitive

    groupNum = state.groupNumber

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchBackref ]: Testing backref \', itoa(groupNum), ' at position ', itoa(matcher.currentPosition)")
    #END_IF

    // Validate group number
    if (groupNum < 1 || groupNum > MAX_REGEX_GROUPS) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchBackref ]: Invalid group number: ', itoa(groupNum)")
        #END_IF
        return 0
    }

    // Get captured text from thread
    captureStart = thread.captureStarts[groupNum]
    captureEnd = thread.captureEnds[groupNum]

    // Check if group participated in match
    if (captureStart <= 0 || captureEnd <= 0 || captureEnd < captureStart) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchBackref ]: Group ', itoa(groupNum), ' did not participate in match'")
        #END_IF
        return 0  // Group didn't capture anything - backreference fails
    }

    // Calculate captured text length
    captureLength = captureEnd - captureStart + 1

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchBackref ]: Group ', itoa(groupNum), ' captured from ', itoa(captureStart), ' to ', itoa(captureEnd), ' (length ', itoa(captureLength), ')'")
    #END_IF

    // Check if we have enough input remaining
    if (matcher.currentPosition + captureLength - 1 > matcher.inputLength) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchBackref ]: Not enough input remaining (need ', itoa(captureLength), ' chars)'")
        #END_IF
        return 0  // Not enough input left
    }

    // Extract captured text for comparison
    capturedText = NAVStringSubstring(matcher.inputString,
                                     captureStart,
                                     captureLength)

    // Check if case-insensitive matching is enabled
    caseInsensitive = (matcher.options & MATCH_OPTION_CASE_INSENSITIVE) != 0

    // Compare captured text with current input position
    inputPos = matcher.currentPosition

    for (i = 1; i <= captureLength; i++) {
        capturedChar = capturedText[i]
        inputChar = matcher.inputString[inputPos]

        if (caseInsensitive) {
            // Case-insensitive comparison
            if (capturedChar >= 'A' && capturedChar <= 'Z') {
                capturedChar = capturedChar + ('a' - 'A')
            }
            if (inputChar >= 'A' && inputChar <= 'Z') {
                inputChar = inputChar + ('a' - 'A')
            }
        }

        if (capturedChar != inputChar) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchBackref ]: Mismatch at position ', itoa(inputPos), ': expected ''', capturedChar, ''' got ''', inputChar, ''''")
            #END_IF
            return 0  // Characters don't match
        }

        inputPos++
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchBackref ]: Match successful, length = ', itoa(captureLength)")
    #END_IF

    return captureLength  // Success - return length of matched text
}


/**
 * @function NAVRegexMatchLookaround
 * @private
 * @description Test if a lookaround assertion succeeds at the current position.
 *
 * Lookaround assertions are zero-width - they check if a pattern matches
 * without consuming input:
 * - Lookahead (?=...) and (?!...): Check pattern ahead of current position
 * - Lookbehind (?<=...) and (?<!...): Check pattern behind current position
 *
 * This function runs a mini-match of the sub-expression NFA:
 * - For lookahead: Match forward from current position
 * - For lookbehind: Match backward from current position
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state
 * @param {_NAVRegexNFAState} state - The lookaround state
 * @param {_NAVRegexThread} thread - The thread with capture information
 * @param {char} isLookbehind - True for lookbehind, false for lookahead
 *
 * @returns {char} True if assertion succeeds, false otherwise
 */
define_function char NAVRegexMatchLookaround(_NAVRegexMatcherState matcher,
                                              _NAVRegexNFAState state,
                                              _NAVRegexThread thread,
                                              char isLookbehind) {
    stack_var integer subExprStart
    stack_var char isNegative
    stack_var char matched
    stack_var _NAVRegexThreadList miniCurrentList
    stack_var _NAVRegexThreadList miniNextList
    stack_var _NAVRegexThread miniThread
    stack_var integer startPos
    stack_var integer endPos
    stack_var integer pos
    stack_var integer i, j
    stack_var _NAVRegexNFAState subState
    stack_var char c
    stack_var char hasMatch
    stack_var integer effectivePosition
    stack_var integer savedCurrentPosition

    subExprStart = state.groupNumber  // Sub-expression start state stored here
    isNegative = state.isNegated

    // Calculate effective position for this thread
    effectivePosition = matcher.currentPosition + thread.positionOffset

    #IF_DEFINED REGEX_MATCHER_DEBUG
    if (isLookbehind) {
        if (isNegative) {
            NAVLog("'[ MatchLookaround ]: Testing negative lookbehind (?<!...) at effective position ', itoa(effectivePosition)")
        } else {
            NAVLog("'[ MatchLookaround ]: Testing positive lookbehind (?<=...) at effective position ', itoa(effectivePosition)")
        }
    } else {
        if (isNegative) {
            NAVLog("'[ MatchLookaround ]: Testing negative lookahead (?!...) at effective position ', itoa(effectivePosition)")
        } else {
            NAVLog("'[ MatchLookaround ]: Testing positive lookahead (?=...) at effective position ', itoa(effectivePosition)")
        }
    }
    #END_IF

    // Save current position - it may have been temporarily incremented by MatchStep
    // We need to restore it so that the lookaround mini-matcher's epsilon-closure
    // (which calls NAVRegexAddThread recursively) uses the correct position
    savedCurrentPosition = matcher.currentPosition
    matcher.currentPosition = effectivePosition

    // Increment lookaround depth to prevent MATCH state processing in epsilon-closure
    matcher.lookaroundDepth++

    // Initialize mini thread lists for sub-expression matching
    NAVRegexThreadListClear(miniCurrentList)
    NAVRegexThreadListClear(miniNextList)

    // Determine match range using effective position
    if (isLookbehind) {
        // Match backward from effective position
        // We'll match from (effectivePosition - maxLen) to (effectivePosition - 1)
        endPos = effectivePosition - 1
        startPos = 1  // Could optimize with max lookbehind length
    } else {
        // Match forward from effective position
        startPos = effectivePosition
        endPos = matcher.inputLength
    }

    // Create initial thread at sub-expression start
    miniThread.stateId = subExprStart
    miniThread.priority = 0
    miniThread.positionOffset = 0  // Initialize offset for lookaround sub-expression

    // Add epsilon-closure by calling NAVRegexAddThread on initial state
    // Note: miniCurrentList and miniNextList have their own visited arrays,
    // separate from the outer matcher's lists, so no interference
    NAVRegexThreadListClear(miniCurrentList)
    NAVRegexAddThread(matcher, miniCurrentList, miniThread)

    hasMatch = false

    // For lookahead: try to match forward
    if (!isLookbehind) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchLookaround ]: Mini-matcher loop starting, startPos=', itoa(startPos), ', endPos=', itoa(endPos), ', initial threads=', itoa(miniCurrentList.count)")
        #END_IF

        // Check if we're already at end-of-string
        if (startPos > endPos) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchLookaround ]: At end-of-string, checking for immediate accept'")
            #END_IF
            // Don't run the loop, just check if initial state is an accept state
            // This will be handled by the final check below
        } else {
            for (pos = startPos; pos <= endPos; pos++) {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ MatchLookaround ]: Loop iteration pos=', itoa(pos), ', miniCurrentList.count=', itoa(miniCurrentList.count)")
                #END_IF

                // Update matcher's current position for anchor checks in epsilon-closure
                matcher.currentPosition = pos

                if (miniCurrentList.count == 0) {
                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ MatchLookaround ]: No active threads, breaking'")
                    #END_IF
                    break  // No active threads
                }

                // Get current character
                if (pos <= matcher.inputLength) {
                    c = matcher.inputString[pos]
                } else {
                    c = 0
                }

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchLookaround ]: Matching char at pos=', itoa(pos), ', c=', itoa(c)")
            #END_IF

            // Process current threads
            for (i = 1; i <= miniCurrentList.count; i++) {
                if (NAVRegexThreadListGet(miniCurrentList, i, miniThread)) {
                    subState = matcher.nfa.states[miniThread.stateId]

                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ MatchLookaround ]: Thread ', itoa(i), ' at state ', itoa(miniThread.stateId), ', type=', itoa(subState.type)")
                    #END_IF

                    // Match character if state consumes input
                    matched = false
                    if (c != 0 && subState.type != NFA_STATE_EPSILON &&
                        subState.type != NFA_STATE_SPLIT) {
                        matched = NAVRegexMatchStateChar(matcher, subState, c)
                        #IF_DEFINED REGEX_MATCHER_DEBUG
                        NAVLog("'[ MatchLookaround ]: Match result: ', itoa(matched)")
                        #END_IF
                    }

                    // Check if this is an accept state after matching
                    // For lookaround sub-expressions, accept if:
                    // 1. We matched the character, AND
                    // 2. This is a dangling "out state" (transitionCount == 0)
                    if (matched && subState.transitionCount == 0) {
                        hasMatch = true
                        #IF_DEFINED REGEX_MATCHER_DEBUG
                        NAVLog("'[ MatchLookaround ]: Accept state reached after match at position ', itoa(pos), ' (state ', itoa(miniThread.stateId), ', transitions=0)'")
                        #END_IF
                        break  // Found match, exit inner loop
                    }

                    // Follow transitions on match
                    if (matched) {
                        #IF_DEFINED REGEX_MATCHER_DEBUG
                        NAVLog("'[ MatchLookaround ]: Following ', itoa(subState.transitionCount), ' transitions'")
                        #END_IF
                        // Update position for epsilon-closure (anchors checked at next position after consuming character)
                        matcher.currentPosition = pos + 1
                        for (j = 1; j <= subState.transitionCount; j++) {
                            miniThread.stateId = subState.transitions[j].targetState
                            NAVRegexAddThread(matcher, miniNextList, miniThread)
                        }
                        // Restore position for next iteration
                        matcher.currentPosition = pos
                    }
                }
            }

            // If we found a match during character processing, exit position loop
            if (hasMatch) {
                break
            }

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchLookaround ]: After processing, miniNextList.count=', itoa(miniNextList.count)")
            #END_IF

            // Swap lists - use NAVRegexAddThread to perform epsilon-closure
            // Update position for epsilon-closure (anchor checks happen at next position)
            matcher.currentPosition = pos + 1

            NAVRegexThreadListClear(miniCurrentList)
            for (i = 1; i <= miniNextList.count; i++) {
                if (NAVRegexThreadListGet(miniNextList, i, miniThread)) {
                    NAVRegexAddThread(matcher, miniCurrentList, miniThread)
                }
            }
            NAVRegexThreadListClear(miniNextList)

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchLookaround ]: After swap, miniCurrentList.count=', itoa(miniCurrentList.count)")
            #END_IF

            // Check for accept state AFTER processing the character
            // For lookaround sub-expressions, accept states are:
            // 1. NFA_STATE_MATCH (if present)
            // 2. States with no transitions (dangling "out states" from the sub-expression fragment)
            for (i = 1; i <= miniCurrentList.count; i++) {
                if (NAVRegexThreadListGet(miniCurrentList, i, miniThread)) {
                    subState = matcher.nfa.states[miniThread.stateId]

                    if (subState.type == NFA_STATE_MATCH || subState.transitionCount == 0) {
                        hasMatch = true
                        #IF_DEFINED REGEX_MATCHER_DEBUG
                        NAVLog("'[ MatchLookaround ]: Lookahead matched at position ', itoa(pos), ' (state ', itoa(miniThread.stateId), ', type=', itoa(subState.type), ', transitions=', itoa(subState.transitionCount), ')'")
                        #END_IF
                        break
                    }
                }
            }

                if (hasMatch) {
                    break
                }
            }
        }

        // Final check for accept state
        // For lookaround sub-expressions, accept if we're at a MATCH state or a dangling "out state"
        // However, dangling out states only count if we actually matched something (not at start position)
        if (!hasMatch) {
            for (i = 1; i <= miniCurrentList.count; i++) {
                if (NAVRegexThreadListGet(miniCurrentList, i, miniThread)) {
                    subState = matcher.nfa.states[miniThread.stateId]

                    // Accept if we reached a MATCH state, or if we have a dangling out state
                    // but only if we're not at the start position (meaning we matched at least one character)
                    if (subState.type == NFA_STATE_MATCH ||
                        (subState.transitionCount == 0 && startPos <= endPos)) {
                        hasMatch = true
                        #IF_DEFINED REGEX_MATCHER_DEBUG
                        NAVLog("'[ MatchLookaround ]: Final check - lookahead matched (state ', itoa(miniThread.stateId), ', type=', itoa(subState.type), ', transitions=', itoa(subState.transitionCount), ')'")
                        #END_IF
                        break
                    }
                }
            }
        }
    }
    // For lookbehind: try to match the pattern ending at current position
    else {
        // Lookbehind matching: check if the sub-expression pattern matches
        // ending exactly at the current position (effectivePosition - 1)
        // We use the mini-matcher to try all possible starting positions
        // and check if any match ends at exactlythe position before current
        stack_var integer matchEndPos
        stack_var integer testStartPos

        // We need to find if there's ANY starting position where the pattern
        // matches and ends at (effectivePosition - 1)
        // Try from startPos (usually 1) up to endPos (effectivePosition - 1)
        for (testStartPos = startPos; testStartPos <= endPos; testStartPos++) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchLookaround ]: Lookbehind trying testStartPos=', itoa(testStartPos), ' to endPos=', itoa(endPos)")
            #END_IF

            NAVRegexThreadListClear(miniCurrentList)
            NAVRegexThreadListClear(miniNextList)

            // Reset thread to sub-expression start for this attempt
            miniThread.stateId = subExprStart
            miniThread.priority = 0
            miniThread.positionOffset = 0
            NAVRegexAddThread(matcher, miniCurrentList, miniThread)

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchLookaround ]: Initial threads after epsilon-closure: ', itoa(miniCurrentList.count)")
            #END_IF

            matchEndPos = 0

            // Try to match from testStartPos to endPos
            for (pos = testStartPos; pos <= endPos; pos++) {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ MatchLookaround ]: Lookbehind loop iteration pos=', itoa(pos), ', miniCurrentList.count=', itoa(miniCurrentList.count)")
                #END_IF

                // Update matcher's current position for anchor checks in epsilon-closure
                matcher.currentPosition = pos

                if (miniCurrentList.count == 0) {
                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ MatchLookaround ]: No active threads, breaking'")
                    #END_IF
                    break
                }

                c = matcher.inputString[pos]

                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ MatchLookaround ]: Matching char at pos=', itoa(pos), ', c=', itoa(c), ' (', c, ')'")
                #END_IF

                // Process threads (similar to lookahead)
                for (i = 1; i <= miniCurrentList.count; i++) {
                    if (NAVRegexThreadListGet(miniCurrentList, i, miniThread)) {
                        subState = matcher.nfa.states[miniThread.stateId]

                        #IF_DEFINED REGEX_MATCHER_DEBUG
                        NAVLog("'[ MatchLookaround ]: Thread ', itoa(i), ' at state ', itoa(miniThread.stateId), ', type=', itoa(subState.type)")
                        #END_IF

                        matched = false
                        if (c != 0 && subState.type != NFA_STATE_EPSILON &&
                            subState.type != NFA_STATE_SPLIT) {
                            matched = NAVRegexMatchStateChar(matcher, subState, c)
                            #IF_DEFINED REGEX_MATCHER_DEBUG
                            NAVLog("'[ MatchLookaround ]: Match result: ', itoa(matched)")
                            #END_IF
                        }

                        // Check if this is an accept state after matching (for lookbehind)
                        // Accept if we matched and this is a dangling out state
                        if (matched && subState.transitionCount == 0) {
                            // For lookbehind, we need to check if we're at the right position
                            // We want matches that end at (effectivePosition - 1)
                            if (pos == endPos) {
                                hasMatch = true
                                #IF_DEFINED REGEX_MATCHER_DEBUG
                                NAVLog("'[ MatchLookaround ]: Lookbehind accept state reached at correct position ', itoa(pos), ' (state ', itoa(miniThread.stateId), ')'")
                                #END_IF
                                break  // Found match, exit inner loop
                            }
                        }

                        if (matched) {
                            #IF_DEFINED REGEX_MATCHER_DEBUG
                            NAVLog("'[ MatchLookaround ]: Following ', itoa(subState.transitionCount), ' transitions'")
                            #END_IF
                            if (subState.transitionCount > 0) {
                                // Update position for epsilon-closure (anchors checked at next position after consuming character)
                                matcher.currentPosition = pos + 1
                                for (j = 1; j <= subState.transitionCount; j++) {
                                    miniThread.stateId = subState.transitions[j].targetState
                                    NAVRegexAddThread(matcher, miniNextList, miniThread)
                                }
                                // Restore position for next iteration
                                matcher.currentPosition = pos
                            }
                        }
                    }
                }

                // If we found a match during character processing, exit position loop
                if (hasMatch) {
                    break
                }

                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ MatchLookaround ]: After processing, miniNextList.count=', itoa(miniNextList.count)")
                #END_IF

                // Swap lists - update position for epsilon-closure (anchor checks happen at next position)
                matcher.currentPosition = pos + 1

                NAVRegexThreadListClear(miniCurrentList)
                for (i = 1; i <= miniNextList.count; i++) {
                    if (NAVRegexThreadListGet(miniNextList, i, miniThread)) {
                        NAVRegexAddThread(matcher, miniCurrentList, miniThread)
                    }
                }
                NAVRegexThreadListClear(miniNextList)

                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ MatchLookaround ]: After swap, miniCurrentList.count=', itoa(miniCurrentList.count)")
                #END_IF

                if (hasMatch) {
                    break
                }
            }

            // After loop: Check if we reached end position with an accept state
            // We check miniCurrentList which now contains threads after matching up to endPos
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchLookaround ]: After matching loop, checking for accept state. miniCurrentList.count=', itoa(miniCurrentList.count)")
            #END_IF

            if (!hasMatch) {
                for (i = 1; i <= miniCurrentList.count; i++) {
                    if (NAVRegexThreadListGet(miniCurrentList, i, miniThread)) {
                        subState = matcher.nfa.states[miniThread.stateId]
                        #IF_DEFINED REGEX_MATCHER_DEBUG
                        NAVLog("'[ MatchLookaround ]: Checking thread ', itoa(i), ': state ', itoa(miniThread.stateId), ', type=', itoa(subState.type), ', transitions=', itoa(subState.transitionCount)")
                        #END_IF
                        if (subState.type == NFA_STATE_MATCH || subState.transitionCount == 0) {
                            hasMatch = true
                            #IF_DEFINED REGEX_MATCHER_DEBUG
                            NAVLog("'[ MatchLookaround ]: Accept state found! testStartPos=', itoa(testStartPos), ' matched pattern ending at ', itoa(endPos)")
                            #END_IF
                            break
                        }
                    }
                }
            }

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchLookaround ]: testStartPos=', itoa(testStartPos), ' result: hasMatch=', itoa(hasMatch)")
            #END_IF

            if (hasMatch) {
                break  // Found a match, no need to try other start positions
            }
        }
    }

    // Apply negation if needed
    if (isNegative) {
        hasMatch = !hasMatch
    }

    // Restore matcher's current position
    matcher.currentPosition = savedCurrentPosition

    // Decrement lookaround depth
    matcher.lookaroundDepth--

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchLookaround ]: Result: ', itoa(hasMatch)")
    #END_IF

    return hasMatch
}


// ============================================================================
// CORE MATCHING LOOP
// ============================================================================

/**
 * @function NAVRegexMatchStateChar
 * @private
 * @description Test if a state matches the current input character.
 *
 * Dispatches to the appropriate character matching function based on
 * the state type. This is the core character matching logic used by
 * the NFA simulation step function.
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state
 * @param {_NAVRegexNFAState} state - The NFA state to test
 * @param {char} c - The input character to match
 *
 * @returns {char} True (1) if state matches character, False (0) otherwise
 */
define_function char NAVRegexMatchStateChar(_NAVRegexMatcherState matcher,
                                            _NAVRegexNFAState state,
                                            char c) {
    stack_var integer effectiveFlags

    // State flags are authoritative - they represent the exact flags that should
    // apply to this state, including scoped flag modifications. We use state flags
    // directly rather than combining with global options, because scoped flags that
    // disable a flag (e.g., (?-i:...)) would be overridden by global options if we OR'd them.
    effectiveFlags = state.stateFlags

    #IF_DEFINED REGEX_MATCHER_DEBUG
    if (state.type == NFA_STATE_LITERAL) {
        NAVLog("'[ MatchStateChar ]: state.stateFlags=0x', format('%02X', state.stateFlags), ', matcher.options=0x', format('%02X', matcher.options), ', effectiveFlags=0x', format('%02X', effectiveFlags)")
    }
    #END_IF

    switch (state.type) {
        case NFA_STATE_LITERAL: {
            return NAVRegexMatchLiteral(state, c, effectiveFlags)
        }

        case NFA_STATE_DOT: {
            return NAVRegexMatchDot(state, c, effectiveFlags)
        }

        case NFA_STATE_CHAR_CLASS: {
            return NAVRegexMatchCharClass(state, c, effectiveFlags)
        }

        case NFA_STATE_DIGIT: {
            return NAVRegexMatchDigit(c)
        }

        case NFA_STATE_NOT_DIGIT: {
            return !NAVRegexMatchDigit(c)
        }

        case NFA_STATE_WORD: {
            return NAVRegexMatchWord(c)
        }

        case NFA_STATE_NOT_WORD: {
            return !NAVRegexMatchWord(c)
        }

        case NFA_STATE_WHITESPACE: {
            return NAVRegexMatchWhitespace(c)
        }

        case NFA_STATE_NOT_WHITESPACE: {
            return !NAVRegexMatchWhitespace(c)
        }

        default: {
            return false
        }
    }
}


/**
 * @function NAVRegexMatchStateAnchor
 * @private
 * @description Test if an anchor state matches at the current position.
 *
 * Anchors are zero-width assertions that don't consume input but
 * check properties of the current position (start of line, end of line,
 * word boundary, etc.).
 *
 * For threads with positionOffset > 0, the effective position is used:
 * effectivePosition = currentPosition + thread.positionOffset
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state
 * @param {_NAVRegexNFAState} state - The NFA state to test
 * @param {_NAVRegexThread} thread - The thread being processed (for positionOffset)
 *
 * @returns {char} True (1) if anchor matches at effective position, False (0) otherwise
 */
define_function char NAVRegexMatchStateAnchor(_NAVRegexMatcherState matcher,
                                               _NAVRegexNFAState state,
                                               _NAVRegexThread thread) {
    stack_var integer effectivePosition
    stack_var integer savedPosition
    stack_var char result

    // Calculate effective position for this thread
    effectivePosition = matcher.currentPosition + thread.positionOffset

    // Temporarily set currentPosition to effective position for anchor checks
    savedPosition = matcher.currentPosition
    matcher.currentPosition = effectivePosition

    switch (state.type) {
        case NFA_STATE_BEGIN: {
            result = NAVRegexMatchBegin(matcher, state.stateFlags)
        }

        case NFA_STATE_END: {
            result = NAVRegexMatchEnd(matcher, state.stateFlags)
        }

        case NFA_STATE_WORD_BOUNDARY: {
            result = NAVRegexMatchWordBoundary(matcher)
        }

        case NFA_STATE_NOT_WORD_BOUNDARY: {
            result = !NAVRegexMatchWordBoundary(matcher)
        }

        case NFA_STATE_STRING_START: {
            // String start \A always matches at position 1
            result = (effectivePosition == 1)
        }

        case NFA_STATE_STRING_END: {
            // String end \Z matches at the end of string OR before a final newline
            // First check if we're after the last character
            if (effectivePosition > matcher.inputLength) {
                result = true
            }
            // Check if we're before a final newline (\r\n or \n at end of string)
            else if (effectivePosition == matcher.inputLength) {
                // Check for \n at current position
                if (matcher.inputString[effectivePosition] == $0A) {
                    result = true
                }
                // Check for \r\n sequence
                else if (matcher.inputString[effectivePosition] == $0D &&
                         effectivePosition + 1 <= matcher.inputLength &&
                         matcher.inputString[effectivePosition + 1] == $0A) {
                    result = true
                }
                else {
                    result = false
                }
            }
            else if (effectivePosition == matcher.inputLength - 1) {
                // Check for \r\n at the end (we're at \r position)
                if (matcher.inputString[effectivePosition] == $0D &&
                    effectivePosition + 1 == matcher.inputLength &&
                    matcher.inputString[effectivePosition + 1] == $0A) {
                    result = true
                }
                else {
                    result = false
                }
            }
            else {
                result = false
            }
        }

        case NFA_STATE_STRING_END_ABS: {
            // Absolute string end \z matches only after the last character
            result = (effectivePosition > matcher.inputLength)
        }

        default: {
            result = false
        }
    }

    // Restore original position
    matcher.currentPosition = savedPosition

    return result
}


/**
 * @function NAVRegexMatchStep
 * @public
 * @description Execute one step of NFA simulation.
 *
 * Processes all active threads at the current input position. For each thread:
 * 1. Get the NFA state it's at
 * 2. Try to match current input character (or anchor)
 * 3. If match succeeds, create new thread at next state
 * 4. Add new thread to next list with epsilon-closure
 *
 * Special handling for MATCH state: records successful match and saves
 * the winning thread for later extraction of captures.
 *
 * After processing all threads, swaps current and next lists, preparing
 * for the next input character.
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state
 * @param {char} c - The input character to match (or 0 for anchors only)
 *
 * @returns {char} True (1) if matching can continue, False (0) if no threads left
 */
define_function char NAVRegexMatchStep(_NAVRegexMatcherState matcher, char c) {
    stack_var integer i
    stack_var integer j
    stack_var _NAVRegexThread thread
    stack_var _NAVRegexThread newThread
    stack_var _NAVRegexNFAState state
    stack_var char matched

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchStep ]: Processing char ASCII: ', itoa(type_cast(c)), ', thread count: ', itoa(matcher.currentList.count)")
    #END_IF

    // Clear next list for this step
    NAVRegexThreadListClear(matcher.nextList)

    // Process each active thread
    for (i = 1; i <= matcher.currentList.count; i++) {
        if (!NAVRegexThreadListGet(matcher.currentList, i, thread)) {
            continue
        }

        // Handle position offset for multi-character consumption (e.g., backreferences)
        // Threads with offset > 0 are "waiting" to become active at a future position
        if (thread.positionOffset > 0) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchStep ]: Thread at state ', itoa(thread.stateId), ' has offset=', itoa(thread.positionOffset), ', decrementing and passing to nextList'")
            #END_IF

            // Decrement offset and move to nextList
            NAVRegexThreadCopy(newThread, thread)
            newThread.positionOffset = thread.positionOffset - 1

            // IMPORTANT: Use NAVRegexThreadListAdd (direct add) NOT NAVRegexAddThread
            // We don't want epsilon-closure yet - the thread is still "waiting"
            NAVRegexThreadListAdd(matcher.nextList, newThread)
            continue  // Skip normal processing for this thread
        }

        // When offset reaches 0, check if this is an anchor/zero-width state or SPLIT state
        // If so, it needs epsilon-closure processing, not character matching
        if (thread.positionOffset == 0 && thread.stateId >= 1 && thread.stateId <= matcher.nfa.stateCount) {
            state = matcher.nfa.states[thread.stateId]

            if (state.type == NFA_STATE_BEGIN ||
                state.type == NFA_STATE_END ||
                state.type == NFA_STATE_WORD_BOUNDARY ||
                state.type == NFA_STATE_NOT_WORD_BOUNDARY ||
                state.type == NFA_STATE_STRING_START ||
                state.type == NFA_STATE_STRING_END ||
                state.type == NFA_STATE_STRING_END_ABS ||
                state.type == NFA_STATE_SPLIT ||
                state.type == NFA_STATE_CAPTURE_START ||
                state.type == NFA_STATE_CAPTURE_END) {

                #IF_DEFINED REGEX_MATCHER_DEBUG
                if (state.type == NFA_STATE_SPLIT) {
                    NAVLog("'[ MatchStep ]: Thread at SPLIT state ', itoa(thread.stateId), ' (offset reached 0), processing epsilon transitions'")
                }
                else if (state.type == NFA_STATE_CAPTURE_START || state.type == NFA_STATE_CAPTURE_END) {
                    NAVLog("'[ MatchStep ]: Thread at CAPTURE state ', itoa(thread.stateId), ' (offset reached 0), processing epsilon transitions'")
                }
                else {
                    NAVLog("'[ MatchStep ]: Thread at anchor state ', itoa(thread.stateId), ' (offset reached 0), processing anchor'")
                }
                #END_IF

                // For CAPTURE states, record capture and follow transition directly
                // For SPLIT states and anchors, follow transitions directly
                if (state.type == NFA_STATE_CAPTURE_START || state.type == NFA_STATE_CAPTURE_END) {
                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ MatchStep ]: CAPTURE state ', itoa(thread.stateId), ', recording capture and following transition'")
                    #END_IF

                    // Record the capture position directly
                    NAVRegexThreadCopy(newThread, thread)

                    if (state.type == NFA_STATE_CAPTURE_START) {
                        if (state.groupNumber >= 1 && state.groupNumber <= MAX_REGEX_GROUPS) {
                            newThread.captureStarts[state.groupNumber] = type_cast(matcher.currentPosition + thread.positionOffset)
                            #IF_DEFINED REGEX_MATCHER_DEBUG
                            NAVLog("'[ MatchStep ]: CAPTURE_START for group ', itoa(state.groupNumber), ' at position ', itoa(matcher.currentPosition + thread.positionOffset)")
                            #END_IF
                        }
                    }
                    else {  // CAPTURE_END
                        if (state.groupNumber >= 1 && state.groupNumber <= MAX_REGEX_GROUPS) {
                            newThread.captureEnds[state.groupNumber] = type_cast(matcher.currentPosition + thread.positionOffset - 1)
                            #IF_DEFINED REGEX_MATCHER_DEBUG
                            NAVLog("'[ MatchStep ]: CAPTURE_END for group ', itoa(state.groupNumber), ' at position ', itoa(matcher.currentPosition + thread.positionOffset - 1)")
                            #END_IF
                        }
                    }

                    // Follow the transition directly (CAPTURE states always have exactly 1 transition)
                    if (state.transitionCount > 0) {
                        newThread.stateId = state.transitions[1].targetState
                        newThread.positionOffset = 0
                        NAVRegexAddThread(matcher, matcher.currentList, newThread)
                    }
                }
                else if (state.type == NFA_STATE_SPLIT || NAVRegexMatchStateAnchor(matcher, state, thread)) {
                    stack_var integer savedPosition
                    stack_var _NAVRegexNFAState successorState

                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    if (state.type == NFA_STATE_SPLIT) {
                        NAVLog("'[ MatchStep ]: SPLIT state, following ', itoa(state.transitionCount), ' epsilon transitions'")
                    }
                    else {
                        NAVLog("'[ MatchStep ]: Anchor matched, following ', itoa(state.transitionCount), ' transitions'")
                    }
                    #END_IF

                    // Anchor matched or SPLIT - follow transitions directly
                    for (j = 1; j <= state.transitionCount; j++) {
                        NAVRegexThreadCopy(newThread, thread)
                        newThread.stateId = state.transitions[j].targetState
                        newThread.positionOffset = 0

                        // Check if successor is a MATCH state
                        if (newThread.stateId >= 1 && newThread.stateId <= matcher.nfa.stateCount) {
                            successorState = matcher.nfa.states[newThread.stateId]

                            if (successorState.type == NFA_STATE_MATCH) {
                                // CRITICAL: We're at position N checking an anchor, but the match
                                // actually ended at position N-1. Temporarily decrement currentPosition
                                // so AddThread records the correct match end.
                                savedPosition = matcher.currentPosition
                                matcher.currentPosition = matcher.currentPosition - 1

                                NAVRegexAddThread(matcher, matcher.currentList, newThread)

                                matcher.currentPosition = savedPosition
                            }
                            else {
                                // Non-MATCH successor - add normally
                                NAVRegexAddThread(matcher, matcher.currentList, newThread)
                            }
                        }
                        else {
                            // Invalid state ID - add anyway to let error handling deal with it
                            NAVRegexAddThread(matcher, matcher.currentList, newThread)
                        }
                    }
                }
                else {
                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ MatchStep ]: Anchor did not match, thread dies'")
                    #END_IF
                    // Anchor didn't match - thread dies
                }

                continue  // Skip normal character matching
            }
        }

        // Bounds check
        if (thread.stateId < 1 || thread.stateId > matcher.nfa.stateCount) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchStep ]: ERROR - Invalid thread state: ', itoa(thread.stateId)")
            #END_IF
            continue
        }

        // Get the state
        state = matcher.nfa.states[thread.stateId]

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchStep ]: Thread ', itoa(i), ' at state ', itoa(thread.stateId), ', type: ', itoa(state.type)")
        #END_IF

        // Check for MATCH state (successful match found!)
        if (state.type == NFA_STATE_MATCH) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchStep ]: MATCH state reached at position ', itoa(matcher.currentPosition)")
            #END_IF
            // Record this as a successful match
            if (!matcher.hasMatch) {
                // First match found
                matcher.hasMatch = true
                NAVRegexThreadCopy(matcher.bestThread, thread)
                matcher.bestMatchEnd = matcher.currentPosition
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ MatchStep ]: First match recorded, end position: ', itoa(matcher.bestMatchEnd)")
                #END_IF
            }
            else {
                // Compare with previous best match using these priorities:
                // 1. Leftmost match (lower start position)
                // 2. Longest match (higher end position)
                // 3. Non-empty over empty (when positions equal)
                // 4. Lower priority value (for lazy vs greedy quantifiers)
                stack_var char shouldReplace
                stack_var integer currentMatchLength
                stack_var integer bestMatchLength

                shouldReplace = false

                // Rule 1 & 2: Leftmost-longest
                if (matcher.currentPosition > matcher.bestMatchEnd) {
                    shouldReplace = true
                }
                // Rule 3 & 4: Same end position - check length and priority
                else if (matcher.currentPosition == matcher.bestMatchEnd) {
                    currentMatchLength = matcher.currentPosition - matcher.startPosition + 1
                    bestMatchLength = matcher.bestMatchEnd - matcher.startPosition + 1

                    if (currentMatchLength > bestMatchLength) {
                        // Current match is longer (non-empty vs empty)
                        shouldReplace = true
                    }
                    // If same length, use thread priority (lower is better)
                    else if (currentMatchLength == bestMatchLength && thread.priority < matcher.bestThread.priority) {
                        shouldReplace = true
                    }
                }

                if (shouldReplace) {
                    NAVRegexThreadCopy(matcher.bestThread, thread)
                    matcher.bestMatchEnd = matcher.currentPosition
                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ MatchStep ]: Better match found, new end: ', itoa(matcher.bestMatchEnd), ', priority: ', itoa(thread.priority)")
                    #END_IF
                }
            }
            continue  // MATCH state has no transitions
        }

        matched = false

        // Anchor states should never reach here (handled in epsilon-closure)
        if (state.type == NFA_STATE_BEGIN ||
            state.type == NFA_STATE_END ||
            state.type == NFA_STATE_WORD_BOUNDARY ||
            state.type == NFA_STATE_NOT_WORD_BOUNDARY ||
            state.type == NFA_STATE_STRING_START ||
            state.type == NFA_STATE_STRING_END ||
            state.type == NFA_STATE_STRING_END_ABS) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchStep ]: WARNING - Anchor state in MatchStep, should be in epsilon-closure'")
            #END_IF
            continue  // Skip anchor states in character matching phase
        }

        // Backreference states (special handling - variable length!)
        //
        // Backreferences are unique: they consume a variable number of characters
        // (whatever was captured by the referenced group). The standard Pike NFA
        // simulation processes one character at a time, so we need special handling.
        //
        // SOLUTION: positionOffset field in thread structure
        //
        // When a backref matches N characters at position i:
        // - The successor threads need to be "active" at position i+N
        // - But nextList is processed at position i+1
        // - So we set successor.positionOffset = N - 1
        //
        // When MatchStep processes threads:
        // - Threads with positionOffset > 0 skip character matching
        // - Offset is decremented and thread moves to nextList
        // - When offset reaches 0, thread processes normally
        //
        // This allows backreferences to consume multiple characters atomically
        // while maintaining Pike VM's one-char-per-iteration architecture.
        //
        if (state.type == NFA_STATE_BACKREF) {
            stack_var integer backrefLength

            backrefLength = NAVRegexMatchBackref(matcher, state, thread)

            if (backrefLength > 0) {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ MatchStep ]: Backreference \', itoa(state.groupNumber), ' matched length ', itoa(backrefLength)")
                #END_IF

                // Follow transitions - successors will be added to nextList with positionOffset
                for (j = 1; j <= state.transitionCount; j++) {
                    NAVRegexThreadCopy(newThread, thread)
                    newThread.stateId = state.transitions[j].targetState

                    // Set offset = backrefLength - 1
                    // The thread will "wait" backrefLength-1 iterations before epsilon-closure
                    // This ensures the thread becomes active at the correct position
                    newThread.positionOffset = backrefLength - 1

                    #IF_DEFINED REGEX_MATCHER_DEBUG
                    NAVLog("'[ MatchStep ]: Adding successor state ', itoa(newThread.stateId), ' with positionOffset=', itoa(newThread.positionOffset), ' will be active at position ', itoa(matcher.currentPosition + backrefLength)")
                    #END_IF

                    // Add directly to nextList WITHOUT epsilon-closure
                    // Epsilon-closure will happen naturally when offset reaches 0
                    NAVRegexThreadListAdd(matcher.nextList, newThread)
                }
            }
            else {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ MatchStep ]: Backreference \', itoa(state.groupNumber), ' did not match'")
                #END_IF
            }

            continue  // Don't process as normal character state
        }

        // Lookaround states should never reach here (handled in epsilon-closure)
        if (state.type == NFA_STATE_LOOKAHEAD_POS ||
            state.type == NFA_STATE_LOOKAHEAD_NEG ||
            state.type == NFA_STATE_LOOKBEHIND_POS ||
            state.type == NFA_STATE_LOOKBEHIND_NEG) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchStep ]: WARNING - Lookaround state in MatchStep, should be in epsilon-closure'")
            #END_IF
            continue  // Skip lookaround states in character matching phase
        }

        // Character-consuming states
        // Attempt to match the current input character
        else {
            matched = NAVRegexMatchStateChar(matcher, state, c)
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchStep ]: Character match result: ', itoa(matched)")
            #END_IF
        }

        // If matched, follow transitions to create new threads
        if (matched) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchStep ]: Match successful, following ', itoa(state.transitionCount), ' transitions'")
            #END_IF

            // Temporarily advance position for epsilon-closure of next states
            // This ensures anchors (like \b) are checked at the position AFTER
            // consuming the matched character
            matcher.currentPosition++

            for (j = 1; j <= state.transitionCount; j++) {
                NAVRegexThreadCopy(newThread, thread)
                newThread.stateId = state.transitions[j].targetState

                // Add to next list with epsilon-closure
                NAVRegexAddThread(matcher, matcher.nextList, newThread)
            }

            // Restore position (will be set correctly by ExecuteMatch loop)
            matcher.currentPosition--
        }
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchStep ]: After processing, nextList count: ', itoa(matcher.nextList.count)")
    #END_IF

    // Swap current and next lists for next iteration
    // Note: We do this by swapping counts and generation counters
    // The actual thread arrays stay in place, we just swap which one is "current"
    NAVRegexThreadListClear(matcher.currentList)

    // Copy nextList to currentList
    for (i = 1; i <= matcher.nextList.count; i++) {
        if (NAVRegexThreadListGet(matcher.nextList, i, thread)) {
            NAVRegexThreadListAdd(matcher.currentList, thread)
        }
    }

    // Return true if we still have active threads
    return (matcher.currentList.count > 0)
}


// ============================================================================
// MATCH RESULT BUILDING
// ============================================================================

/**
 * @function NAVRegexResultInit
 * @public
 * @description Initialize a match result structure to default state.
 *
 * Sets status to NO_MATCH, clears all flags and fields. Must be called
 * before populating a result structure.
 *
 * @param {_NAVRegexMatchResult} result - The result structure to initialize
 *
 * @returns {void}
 */
define_function NAVRegexResultInit(_NAVRegexMatchResult result) {
    stack_var integer i

    result.status = MATCH_STATUS_NO_MATCH
    result.hasMatch = false

    // Clear full match
    result.fullMatch.isCaptured = false
    result.fullMatch.number = 0
    result.fullMatch.name = ''
    result.fullMatch.start = 0
    result.fullMatch.end = 0
    result.fullMatch.length = 0
    result.fullMatch.text = ''

    // Clear all capture groups
    result.groupCount = 0
    for (i = 1; i <= MAX_REGEX_GROUPS; i++) {
        result.groups[i].isCaptured = false
        result.groups[i].number = 0
        result.groups[i].name = ''
        result.groups[i].start = 0
        result.groups[i].end = 0
        result.groups[i].length = 0
        result.groups[i].text = ''
    }

    result.errorMessage = ''
}


/**
 * @function NAVRegexGetGroupName
 * @description Get the name of a capture group from the NFA states.
 *
 * Searches through the NFA states to find a CAPTURE_START or CAPTURE_END state
 * with the specified group number, then returns its group name.
 *
 * @param {_NAVRegexNFA} nfa - The compiled NFA
 * @param {integer} groupNumber - The group number to look up
 *
 * @returns {char[]} The group name, or empty string if not found or unnamed
 */
define_function char[MAX_REGEX_GROUP_NAME_LENGTH] NAVRegexGetGroupName(_NAVRegexNFA nfa, integer groupNumber) {
    stack_var integer i

    // Search through all states to find a CAPTURE state with this group number
    for (i = 1; i <= nfa.stateCount; i++) {
        if ((nfa.states[i].type == NFA_STATE_CAPTURE_START ||
             nfa.states[i].type == NFA_STATE_CAPTURE_END) &&
            nfa.states[i].groupNumber == groupNumber) {
            return nfa.states[i].groupName
        }
    }

    return ''
}


/**
 * @function NAVRegexExtractCaptures
 * @public
 * @description Extract capture groups from a winning thread.
 *
 * Takes the capture positions stored in the thread and extracts the
 * corresponding substrings from the input. Populates the result structure
 * with all captured groups.
 *
 * Note: Uses 1-based indexing. groups[1] = capture group 1, etc.
 * The full match is stored separately in result.fullMatch.
 *
 * @param {_NAVRegexMatcherState} matcher - The matcher state with input string
 * @param {_NAVRegexThread} thread - The winning thread with capture positions
 * @param {_NAVRegexMatchResult} result - The result structure to populate
 * @param {integer} matchStart - Start position of full match (1-based)
 * @param {integer} matchEnd - End position of full match (1-based, inclusive)
 *
 * @returns {void}
 */
define_function NAVRegexExtractCaptures(_NAVRegexMatcherState matcher,
                                        _NAVRegexThread thread,
                                        _NAVRegexMatchResult result,
                                        integer matchStart,
                                        integer matchEnd) {
    stack_var integer i
    stack_var integer captureStart
    stack_var integer captureEnd
    stack_var integer captureLength
    stack_var integer groupNum

    // Extract full match (group 0 equivalent, but stored separately)
    result.fullMatch.isCaptured = true
    result.fullMatch.number = 0
    result.fullMatch.name = ''
    result.fullMatch.start = matchStart
    result.fullMatch.end = matchEnd

    // Calculate length - handle zero-length matches
    if (matchEnd < matchStart) {
        // Zero-length match (e.g., /a*/ on "bbb")
        result.fullMatch.length = 0
        result.fullMatch.text = ''
    }
    else {
        result.fullMatch.length = matchEnd - matchStart + 1
        // Extract full match text using StringUtils (handles bounds checking)
        result.fullMatch.text = NAVStringSubstring(matcher.inputString,
                                                   matchStart,
                                                   result.fullMatch.length)
    }

    // Set total group count from NFA metadata (not just captured groups)
    // This ensures groupCount reflects total groups in pattern, even if some didn't participate
    result.groupCount = matcher.nfa.captureGroupCount

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ ExtractCaptures ]: Extracting captures from thread:'")
    for (i = 1; i <= matcher.nfa.captureGroupCount; i++) {
        NAVLog("'[ ExtractCaptures ]:   Group ', itoa(i), ': start=', itoa(thread.captureStarts[i]), ', end=', itoa(thread.captureEnds[i])")
    }
    #END_IF

    // Extract individual capture groups
    for (i = 1; i <= MAX_REGEX_GROUPS; i++) {
        captureStart = thread.captureStarts[i]
        captureEnd = thread.captureEnds[i]

        // Check if this group was captured (both start and end set)
        if (captureStart > 0 && captureEnd > 0 && captureEnd >= captureStart) {
            groupNum = i

            result.groups[groupNum].isCaptured = true
            result.groups[groupNum].number = groupNum
            result.groups[groupNum].name = NAVRegexGetGroupName(matcher.nfa, groupNum)
            result.groups[groupNum].start = captureStart
            result.groups[groupNum].end = captureEnd

            captureLength = captureEnd - captureStart + 1
            result.groups[groupNum].length = captureLength

            // Extract substring using StringUtils (handles bounds checking)
            result.groups[groupNum].text = NAVStringSubstring(matcher.inputString,
                                                              captureStart,
                                                              captureLength)

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ ExtractCaptures ]:   Group ', itoa(groupNum), ' captured: "', result.groups[groupNum].text, '" (', itoa(captureStart), '-', itoa(captureEnd), ')'")
            #END_IF
        }
        else {
            // Group did not participate in match
            result.groups[i].isCaptured = false
            result.groups[i].number = i
            result.groups[i].name = NAVRegexGetGroupName(matcher.nfa, i)
            result.groups[i].start = 0
            result.groups[i].end = 0
            result.groups[i].length = 0
            result.groups[i].text = ''
        }
    }
}


/**
 * @function NAVRegexResultSetMatch
 * @public
 * @description Set result structure for a successful match.
 *
 * Populates the result with success status and extracts all capture groups
 * from the winning thread.
 *
 * @param {_NAVRegexMatchResult} result - The result structure to populate
 * @param {_NAVRegexMatcherState} matcher - The matcher state
 * @param {_NAVRegexThread} thread - The winning thread
 * @param {integer} matchStart - Start position of match (1-based)
 * @param {integer} matchEnd - End position of match (1-based, inclusive)
 *
 * @returns {void}
 */
define_function NAVRegexResultSetMatch(_NAVRegexMatchResult result,
                                       _NAVRegexMatcherState matcher,
                                       _NAVRegexThread thread,
                                       integer matchStart,
                                       integer matchEnd) {
    result.status = MATCH_STATUS_SUCCESS
    result.hasMatch = true

    // Extract captures from thread
    NAVRegexExtractCaptures(matcher, thread, result, matchStart, matchEnd)
}


/**
 * @function NAVRegexResultSetNoMatch
 * @public
 * @description Set result structure for no match found.
 *
 * Sets status to NO_MATCH and clears match flag.
 *
 * @param {_NAVRegexMatchResult} result - The result structure to set
 *
 * @returns {void}
 */
define_function NAVRegexResultSetNoMatch(_NAVRegexMatchResult result) {
    result.status = MATCH_STATUS_NO_MATCH
    result.hasMatch = false
    result.errorMessage = ''
}


/**
 * @function NAVRegexResultSetError
 * @public
 * @description Set result structure for an error condition.
 *
 * Sets status to ERROR and records the error message.
 *
 * @param {_NAVRegexMatchResult} result - The result structure to set
 * @param {char[]} message - The error message
 *
 * @returns {void}
 */
define_function NAVRegexResultSetError(_NAVRegexMatchResult result, char message[]) {
    result.status = MATCH_STATUS_ERROR
    result.hasMatch = false
    result.errorMessage = message
}


#END_IF // __NAV_FOUNDATION_REGEX_MATCHER_HELPERS__
