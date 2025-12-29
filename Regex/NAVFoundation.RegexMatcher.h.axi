PROGRAM_NAME='NAVFoundation.RegexMatcher.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_MATCHER_H__
#DEFINE __NAV_FOUNDATION_REGEX_MATCHER_H__ 'NAVFoundation.RegexMatcher.h'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.RegexParser.h.axi'


DEFINE_CONSTANT

// ============================================================================
// MATCHER CONSTANTS
// ============================================================================

/**
 * Maximum number of NFA states that can be active simultaneously during matching.
 *
 * In Thompson's NFA simulation, we maintain two state sets:
 * - Current set: States active at current input position
 * - Next set: States that will be active after consuming next character
 *
 * The maximum size needed equals the total number of states in the NFA,
 * since in the worst case (many parallel paths via SPLIT states and epsilon
 * transitions), all states could theoretically be active at once.
 *
 * This should match MAX_REGEX_NFA_STATES from parser.
 */
#IF_NOT_DEFINED MAX_REGEX_MATCHER_STATES
constant integer MAX_REGEX_MATCHER_STATES = 1024
#END_IF

/**
 * Maximum depth of lookaround assertion nesting.
 *
 * Lookahead/lookbehind assertions can be nested:
 * - /a(?=b(?=c))/      -> depth 2
 * - /(?<=a(?<=b))/     -> depth 2
 *
 * Each lookaround requires a separate match attempt with its own state,
 * so we need to limit nesting to prevent stack issues.
 */
#IF_NOT_DEFINED MAX_REGEX_LOOKAROUND_DEPTH
constant integer MAX_REGEX_LOOKAROUND_DEPTH = 8
#END_IF

/**
 * Maximum number of backtracking positions to track.
 *
 * For patterns with backreferences or complex quantifiers, we may need
 * to backtrack to previous match positions. This limits how many
 * backtracking points we store.
 *
 * In practice, most patterns don't require deep backtracking.
 */
#IF_NOT_DEFINED MAX_REGEX_BACKTRACK_DEPTH
constant integer MAX_REGEX_BACKTRACK_DEPTH = 64
#END_IF


// ============================================================================
// MATCH RESULT FLAGS
// ============================================================================

/**
 * Match result status flags
 */
constant integer MATCH_STATUS_SUCCESS       = 0   // Match succeeded
constant integer MATCH_STATUS_NO_MATCH      = 1   // No match found
constant integer MATCH_STATUS_ERROR         = 2   // Error during matching
constant integer MATCH_STATUS_TIMEOUT       = 3   // Matching timeout (future)


// ============================================================================
// MATCHER OPTIONS
// ============================================================================

/**
 * Matching behavior flags (bitfield)
 *
 * NOTE: Shared flags (CASE_INSENSITIVE, MULTILINE, DOTALL) use the same bit
 * positions as PARSER_FLAG_* constants to allow direct bitwise combination
 * without conversion overhead.
 */
constant integer MATCH_OPTION_NONE          = $00
constant integer MATCH_OPTION_ANCHORED      = $01 // Only match at start of string (matcher-only)
constant integer MATCH_OPTION_GLOBAL        = $02 // Find all matches (matcher-only, for replace/findAll)
constant integer MATCH_OPTION_CASE_INSENSITIVE = $10 // Case-insensitive matching (matches PARSER_FLAG_CASE_INSENSITIVE)
constant integer MATCH_OPTION_MULTILINE     = $20 // ^ and $ match line boundaries (matches PARSER_FLAG_MULTILINE)
constant integer MATCH_OPTION_DOTALL        = $40 // . matches newline (matches PARSER_FLAG_DOTALL)


/**
 * Maximum number of matches that can be stored in a collection.
 *
 * Used for global matching, findAll, and when patterns include the /g flag.
 * 64 matches covers most real-world use cases without excessive memory usage.
 */
#IF_NOT_DEFINED MAX_REGEX_MATCHES
constant integer MAX_REGEX_MATCHES = 64
#END_IF


DEFINE_TYPE

// ============================================================================
// CAPTURE GROUP
// ============================================================================

/**
 * @struct _NAVRegexGroup
 * @description Information about a captured group (named or numbered).
 *
 * Stores the position, content, and metadata of a capturing group match.
 * Groups are numbered starting from 1 (group 1, group 2, etc.).
 *
 * Position is 1-based (NetLinx convention):
 * - start: Index of first character (1-based)
 * - end: Index of last character (1-based, inclusive)
 * - length: end - start + 1
 *
 * Example: "Hello World" with pattern /H(?<vowel>e)(?<consonants>l+)o/
 * - Group 1: number=1, name="vowel", text="e"
 * - Group 2: number=2, name="consonants", text="ll"
 *
 * Note: The full match is stored separately in _NAVRegexMatchResult.fullMatch,
 * not in the groups[] array. This ensures groups[i] always corresponds to
 * group number i, respecting NetLinx's 1-based array indexing.
 */
struct _NAVRegexGroup {
    char isCaptured                 // True if this group participated in match
    integer number                  // Group number (1, 2, 3, ...)
    char name[50]                   // Group name (empty for unnamed groups)
    integer start                  // Start position in input string (1-based)
    integer end                    // End position in input string (1-based, inclusive)
    integer length                 // Length of captured text (end - start + 1)
    char text[NAV_MAX_BUFFER]       // Captured text (substring)
}


// ============================================================================
// MATCH RESULT
// ============================================================================

/**
 * @struct _NAVRegexMatchResult
 * @description Complete result of a single regex match operation.
 *
 * Contains all information about a successful (or failed) match:
 * - Match status
 * - Full matched text (dedicated field, not in groups array)
 * - Individual capture groups (1-based indexing)
 *
 * Design Decision: The fullMatch field contains the entire matched substring.
 * The groups[] array contains ONLY the explicit capture groups (1, 2, 3...).
 * This ensures groups[i] always corresponds to group number i, respecting
 * NetLinx's 1-based array indexing.
 *
 * Example: Pattern '(\d+)-(\d+)' matching '2025-10-22':
 * - fullMatch.text = '2025-10'
 * - groupCount = 2
 * - groups[1].text = '2025' (group 1)
 * - groups[2].text = '10'   (group 2)
 */
struct _NAVRegexMatchResult {
    // Match status
    integer status                  // MATCH_STATUS_* constant
    char hasMatch                   // True if pattern matched

    // Full match (the entire matched substring)
    _NAVRegexGroup fullMatch        // Complete match (not in groups[] array)

    // Capture groups (1-based, groups[1] = group 1, groups[2] = group 2, etc.)
    integer groupCount              // Number of capture groups (NOT including full match)
    _NAVRegexGroup groups[MAX_REGEX_GROUPS]  // Captured groups [1..groupCount]

    // Error information (if status == MATCH_STATUS_ERROR)
    char errorMessage[255]          // Error message if match failed
}


// ============================================================================
// MATCH COLLECTION (MULTIPLE MATCHES)
// ============================================================================

/**
 * @struct _NAVRegexMatchCollection
 * @description Collection of multiple regex match results.
 *
 * Used by NAVRegexMatch() (when pattern has /g flag) and NAVRegexMatchAll().
 * Provides a consistent return type across all matching functions.
 *
 * Design Decision: All match functions return _NAVRegexMatchCollection,
 * even for single matches (count = 1). This provides:
 * - API consistency: All functions use same result type
 * - Future-proof: Adding /g flag doesn't break API
 * - Natural semantics: NAVRegexMatch() respects /g flag, NAVRegexMatchAll() forces global
 *
 * Example: NAVRegexMatch('(\d+)', 'Prices: 123, 456') with no /g flag:
 * - status = MATCH_STATUS_SUCCESS
 * - count = 1
 * - matches[1].fullMatch.text = '123'
 *
 * Example: NAVRegexMatch('(\d+)/g', 'Prices: 123, 456') with /g flag:
 * - status = MATCH_STATUS_SUCCESS
 * - count = 2
 * - matches[1].fullMatch.text = '123'
 * - matches[2].fullMatch.text = '456'
 *
 * Example: NAVRegexMatchAll('(\d+)', 'Prices: 123, 456') always global:
 * - status = MATCH_STATUS_SUCCESS
 * - count = 2
 * - matches[1].fullMatch.text = '123'
 * - matches[2].fullMatch.text = '456'
 */
struct _NAVRegexMatchCollection {
    char status                                     // MATCH_STATUS_* constant
    integer count                                   // Number of matches found (0-N)
    _NAVRegexMatchResult matches[MAX_REGEX_MATCHES] // Array of individual matches
    char errorMessage[255]                          // Error message if status = ERROR
}


// ============================================================================
// THREAD (NFA STATE INSTANCE)
// ============================================================================

/**
 * @struct _NAVRegexThread
 * @description A single execution thread in the NFA simulation.
 *
 * Represents one possible execution path through the NFA. At any given
 * input position, multiple threads may be active (non-determinism).
 *
 * Each thread tracks:
 * - Which NFA state it's at
 * - What it has captured so far
 * - Priority for choosing between competing matches
 *
 * Threads are created when:
 * - Matching starts (thread at startState)
 * - SPLIT state is encountered (thread forks into 2+ paths)
 * - Epsilon transitions are followed
 */
struct _NAVRegexThread {
    integer stateId                 // Current NFA state index
    integer priority                // Thread priority (lower = higher priority, for greedy vs lazy)
    integer positionOffset          // Number of positions ahead of current iteration (for multi-char consumption)

    // Capture group positions (for this thread's path)
    // Each group has a start and end position
    integer captureStarts[MAX_REGEX_GROUPS]  // Start positions (1-based)
    integer captureEnds[MAX_REGEX_GROUPS]    // End positions (1-based, inclusive)
}


// ============================================================================
// THREAD LIST (STATE SET)
// ============================================================================

/**
 * @struct _NAVRegexThreadList
 * @description A set of active threads at a given input position.
 *
 * During NFA simulation, we maintain two thread lists:
 * - clist (current): Threads active at current input position
 * - nlist (next): Threads that will be active after consuming next character
 *
 * This is the core data structure for Thompson's NFA simulation algorithm.
 *
 * We use a simple array + count approach. More sophisticated implementations
 * might use bit vectors for visited states, but array is simpler for AMX.
 *
 * The 'visited' array prevents adding the same state multiple times in one
 * epsilon-closure computation (important for handling epsilon cycles).
 */
struct _NAVRegexThreadList {
    _NAVRegexThread threads[MAX_REGEX_MATCHER_STATES]  // Active threads
    integer count                   // Number of active threads

    // Visited tracking (for epsilon-closure)
    // visited[stateId] = current generation number if state visited this round
    integer visited[MAX_REGEX_MATCHER_STATES]
    integer generation              // Current generation counter (incremented each step)
}


// ============================================================================
// BACKTRACKING STATE
// ============================================================================

/**
 * @struct _NAVRegexBacktrackState
 * @description Saved state for backtracking (used for backreferences).
 *
 * When matching patterns with backreferences (\1, \2, etc.), we may need
 * to backtrack if a later part of the pattern fails to match.
 *
 * This structure saves enough state to restore matching to a previous point.
 *
 * Note: This is primarily for backreferences. Regular Thompson NFA matching
 * doesn't require explicit backtracking due to its parallel simulation approach.
 */
struct _NAVRegexBacktrackState {
    integer inputPosition           // Position in input string (1-based)
    integer captureStarts[MAX_REGEX_GROUPS]  // Saved capture starts
    integer captureEnds[MAX_REGEX_GROUPS]    // Saved capture ends
    integer stateId                 // NFA state to resume from
}


// ============================================================================
// MATCHER STATE
// ============================================================================

/**
 * @struct _NAVRegexMatcherState
 * @description Main matcher state for NFA execution.
 *
 * This is the "machine" that executes the NFA against an input string.
 * Contains all runtime state needed for matching:
 * - The NFA to execute
 * - The input string being matched
 * - Current and next thread lists
 * - Capture group state
 * - Match options
 *
 * Lifecycle:
 * 1. Initialize matcher with NFA and input string
 * 2. Start matching from position 1 (or specified offset)
 * 3. Simulate NFA step by step through input
 * 4. Return result when match succeeds or all possibilities exhausted
 */
struct _NAVRegexMatcherState {
    // Input
    _NAVRegexNFA nfa                     // The compiled NFA to execute
    char inputString[MAX_REGEX_INPUT_LENGTH] // The string to match against
    integer inputLength                  // Length of input string
    integer startPosition                // Where to start matching (1-based)
    integer currentPosition              // Current position in input (1-based)

    // Matching options
    integer options                 // Bitfield of MATCH_OPTION_* flags

    // Thread lists (double-buffered)
    _NAVRegexThreadList currentList // Threads active at current position
    _NAVRegexThreadList nextList    // Threads active at next position

    // Best match found so far
    char hasMatch                   // True if we found at least one match
    _NAVRegexThread bestThread      // The winning thread (if hasMatch)
    integer bestMatchEnd            // End position of best match (for choosing longest match)

    // Backtracking support (for backreferences)
    _NAVRegexBacktrackState backtrackStack[MAX_REGEX_BACKTRACK_DEPTH]
    integer backtrackDepth          // Current backtrack stack depth

    // Lookaround nesting (for assertions)
    integer lookaroundDepth         // Current lookaround nesting level

    // Error tracking
    char hasError                   // True if error occurred
    char errorMessage[255]          // Error message
}


#END_IF // __NAV_FOUNDATION_REGEX_MATCHER_H__
