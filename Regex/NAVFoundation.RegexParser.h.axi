PROGRAM_NAME='NAVFoundation.RegexParser.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_PARSER_H__
#DEFINE __NAV_FOUNDATION_REGEX_PARSER_H__ 'NAVFoundation.RegexParser.h'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.Regex.h.axi'
#include 'NAVFoundation.RegexLexer.h.axi'


DEFINE_CONSTANT

// ============================================================================
// PARSER CONSTANTS
// ============================================================================

/**
 * Maximum number of NFA states that can be created during parsing.
 * Each state represents a node in the finite automaton.
 *
 * State count estimation (Thompson's Construction):
 * - Simple literal: 'abc'                    -> ~3 states
 * - Simple alternation: 'a|b|c'              -> ~6 states
 * - Email pattern: '^[a-z]+@[a-z]+\.[a-z]+$' -> ~15 states
 * - URL validation: 'https?://...'           -> ~40 states
 * - Complex nested: '((a+|b*\){2,5}|c{3,})+' -> ~50 states
 * - Bounded quantifier: 'a{50,100}'          -> ~200 states (unrolled)
 * - Pathological: nested quantifiers {10,20} -> ~300+ states
 *
 * Increased from 512 to 1024 to handle:
 * - Large bounded quantifiers (e.g., {20,50})
 * - Deeply nested groups with quantifiers
 * - Complex real-world validation patterns
 * - Future-proofing for unicode property classes
 */
#IF_NOT_DEFINED MAX_REGEX_NFA_STATES
constant integer MAX_REGEX_NFA_STATES = 1024
#END_IF

/**
 * Maximum number of transitions (edges) from a single NFA state.
 *
 * Transition count by state type:
 * - LITERAL, DOT, CHAR_CLASS, etc.: 1 transition (to next state)
 * - SPLIT (for alternation/quantifiers): 2 transitions (typically)
 * - Complex split with multiple branches: Could need more
 * - EPSILON placeholder: 1 transition (gets patched)
 *
 * Value of 8 provides headroom for:
 * - Future optimization (multiple alternation branches from one SPLIT)
 * - Complex character class expansions
 * - Debug/trace transitions
 *
 * In practice, >99% of states use 1-2 transitions.
 */
#IF_NOT_DEFINED MAX_REGEX_STATE_TRANSITIONS
constant integer MAX_REGEX_STATE_TRANSITIONS = 8
#END_IF

/**
 * Maximum nesting depth of constructs during parsing.
 * Tracks groups, alternations, quantifiers, etc.
 *
 * Examples:
 * - ((a|b)|c)         -> depth 2
 * - (a(b(c(d))))      -> depth 4
 * - ((a|b)|(c|d))*    -> depth 2
 */
#IF_NOT_DEFINED MAX_REGEX_PARSER_DEPTH
constant integer MAX_REGEX_PARSER_DEPTH = 40
#END_IF

/**
 * Quantifier type identifiers.
 * Used internally by the parser to apply quantifiers to NFA fragments.
 * These constants replace string literals for better performance and reduced memory usage.
 */
constant integer REGEX_QUANTIFIER_TYPE_ZERO_OR_MORE = 1  // * quantifier
constant integer REGEX_QUANTIFIER_TYPE_ONE_OR_MORE  = 2  // + quantifier
constant integer REGEX_QUANTIFIER_TYPE_ZERO_OR_ONE  = 3  // ? quantifier


// ============================================================================
// NFA STATE TYPES
// ============================================================================

/**
 * NFA state types define the behavior of each state in the automaton.
 * Based on Thompson's Construction algorithm.
 */

constant integer NFA_STATE_EPSILON          = 0   // ε-transition (no input consumed)
constant integer NFA_STATE_LITERAL          = 1   // Match single literal character
constant integer NFA_STATE_DOT              = 2   // Match any character (.)
constant integer NFA_STATE_CHAR_CLASS       = 3   // Match character from class [abc]
constant integer NFA_STATE_DIGIT            = 4   // Match digit \d
constant integer NFA_STATE_NOT_DIGIT        = 5   // Match non-digit \D
constant integer NFA_STATE_WORD             = 6   // Match word character \w
constant integer NFA_STATE_NOT_WORD         = 7   // Match non-word character \W
constant integer NFA_STATE_WHITESPACE       = 8   // Match whitespace \s
constant integer NFA_STATE_NOT_WHITESPACE   = 9   // Match non-whitespace \S

// Anchor states (zero-width assertions)
constant integer NFA_STATE_BEGIN            = 10  // Match start of line/string ^
constant integer NFA_STATE_END              = 11  // Match end of line/string $
constant integer NFA_STATE_WORD_BOUNDARY    = 12  // Match word boundary \b
constant integer NFA_STATE_NOT_WORD_BOUNDARY = 13 // Match non-word boundary \B
constant integer NFA_STATE_STRING_START     = 14  // Match string start \A
constant integer NFA_STATE_STRING_END       = 15  // Match string end \Z
constant integer NFA_STATE_STRING_END_ABS   = 16  // Match absolute string end \z

// Special control states
constant integer NFA_STATE_SPLIT            = 17  // Split execution (for alternation |)
constant integer NFA_STATE_MATCH            = 18  // Accept state (pattern matched)
constant integer NFA_STATE_CAPTURE_START    = 19  // Mark start of capturing group
constant integer NFA_STATE_CAPTURE_END      = 20  // Mark end of capturing group
constant integer NFA_STATE_BACKREF          = 21  // Match backreference \1, \2, etc.

// Lookaround states (zero-width assertions with sub-expressions)
constant integer NFA_STATE_LOOKAHEAD_POS    = 22  // Positive lookahead (?=...)
constant integer NFA_STATE_LOOKAHEAD_NEG    = 23  // Negative lookahead (?!...)
constant integer NFA_STATE_LOOKBEHIND_POS   = 24  // Positive lookbehind (?<=...)
constant integer NFA_STATE_LOOKBEHIND_NEG   = 25  // Negative lookbehind (?<!...)


// ============================================================================
// PARSER FLAGS
// ============================================================================

/**
 * Parser flag bitfield constants.
 * Tracks active regex flags during parsing and NFA construction.
 *
 * NOTE: Shared flags (CASE_INSENSITIVE, MULTILINE, DOTALL) use the same bit
 * positions as MATCH_OPTION_* constants to allow direct bitwise combination
 * without conversion overhead.
 */

constant integer PARSER_FLAG_NONE               = $00  // No flags
constant integer PARSER_FLAG_CASE_INSENSITIVE   = $10  // (?i) - ignore case (matches MATCH_OPTION_CASE_INSENSITIVE)
constant integer PARSER_FLAG_MULTILINE          = $20  // (?m) - ^ and $ match line boundaries (matches MATCH_OPTION_MULTILINE)
constant integer PARSER_FLAG_DOTALL             = $40  // (?s) - . matches newlines (matches MATCH_OPTION_DOTALL)
constant integer PARSER_FLAG_EXTENDED           = $80  // (?x) - ignore whitespace, allow comments (parser-only)


DEFINE_TYPE

// ============================================================================
// NFA TRANSITION
// ============================================================================

/**
 * @struct _NAVRegexNFATransition
 * @description A transition (edge) from one NFA state to another.
 *
 * Represents a single outgoing edge from an NFA state. Each transition
 * specifies the target state and (for non-epsilon transitions) may carry
 * additional matching data.
 */
struct _NAVRegexNFATransition {
    integer targetState             // Index of target state in NFA states array
    char isEpsilon                  // True if this is an ε-transition (no input consumed)
}


// ============================================================================
// NFA STATE
// ============================================================================

/**
 * @struct _NAVRegexNFAState
 * @description A single state in the NFA (Non-deterministic Finite Automaton).
 *
 * Each state represents a node in the automaton with:
 * - A type defining its matching behavior
 * - Matching data (character, class, group number, etc.)
 * - Outgoing transitions to other states
 *
 * The NFA is constructed during parsing using Thompson's Construction,
 * where each regex construct is converted into a small NFA fragment
 * that is then combined with other fragments.
 */
struct _NAVRegexNFAState {
    // State identification
    integer id                      // Unique state ID (index in NFA array)
    integer type                    // State type (NFA_STATE_* constants)

    // Matching data (varies by state type)
    char matchChar                  // Literal character to match (for NFA_STATE_LITERAL)
    _NAVRegexCharClass charClass    // Character class data (for NFA_STATE_CHAR_CLASS)
    integer groupNumber             // Group number (for CAPTURE_START/END, BACKREF)
    char groupName[MAX_REGEX_GROUP_NAME_LENGTH]  // Group name (for named CAPTURE_START/END states)
    char isNegated                  // True for negated classes/lookarounds

    // Flags affecting state behavior
    char matchesNewline             // True if DOT state should match newlines (DOTALL flag)
    integer stateFlags              // Bitfield of PARSER_FLAG_* constants active when state was created

    // Transitions to other states
    // Note: For SPLIT states, order matters for greedy vs lazy matching
    // - Greedy: preferred path first (e.g., match before skip for a*)
    // - Lazy: skip path first (e.g., skip before match for a*?)
    integer transitionCount         // Number of outgoing transitions
    _NAVRegexNFATransition transitions[MAX_REGEX_STATE_TRANSITIONS]

    // Source tracking (for debugging and error reporting)
    integer sourceTokenIndex        // Index of token that created this state
}


// ============================================================================
// NFA FRAGMENT
// ============================================================================

/**
 * @struct _NAVRegexNFAFragment
 * @description A partial NFA fragment with entry and exit points.
 *
 * During parsing, regex constructs are built as NFA fragments that can be
 * connected together. Each fragment has:
 * - startState: The entry state
 * - outStates: Array of "dangling" exit states that need to be patched to the next fragment
 * - outCount: Number of valid exit states in the outStates array
 *
 * This is the core data structure for Thompson's Construction algorithm.
 *
 * The outStates array tracks all transitions that need to be patched when connecting
 * fragments. For example:
 * - Literal 'a': 1 out state (the epsilon transition after matching 'a')
 * - Alternation 'a|b': 2 out states (end of 'a' path and end of 'b' path)
 * - Quantifier 'a*': Multiple out states (skip path and exit-after-match paths)
 *
 * When concatenating fragments, we patch all out states of fragment1 to point to
 * the startState of fragment2.
 *
 * Example fragments:
 * - Literal 'a': startState=1, outStates=[2], outCount=1
 * - Alternation 'a|b': startState=1 (SPLIT), outStates=[5,9], outCount=2
 * - Quantifier 'a*': startState=1 (SPLIT), outStates=[7], outCount=1
 */
struct _NAVRegexNFAFragment {
    integer startState              // Index of entry state (where fragment begins)
    integer outStates[MAX_REGEX_STATE_TRANSITIONS]  // Array of dangling exit states needing patching
    integer outCount                // Number of valid out states (0 to MAX_REGEX_STATE_TRANSITIONS)
}


// ============================================================================
// PARSER HELPERS
// ============================================================================

/**
 * @struct _NAVRegexQuantifierInfo
 * @description Quantifier parameters extracted from tokens during parsing.
 *
 * This is a parser-local structure used to pass quantifier information
 * when building NFA fragments. The quantifier behavior is encoded into
 * the NFA structure (via SPLIT states and transition order), not stored
 * as metadata in states.
 *
 * Usage:
 * 1. Extract quantifier info from token
 * 2. Pass to fragment builder (e.g., BuildZeroOrMoreFragment)
 * 3. Builder creates appropriate NFA topology
 * 4. Structure is discarded (not stored in final NFA)
 */
struct _NAVRegexQuantifierInfo {
    sinteger min                    // Minimum repetitions (0 for *, 1 for +, n for {n,m})
    sinteger max                    // Maximum repetitions (-1 for unlimited, m for {n,m})
    char isLazy                     // True for non-greedy (*?, +?, ??, {n,m}?)
}


// ============================================================================
// PARSER STATE
// ============================================================================

/**
 * @struct _NAVRegexParserState
 * @description Main parser state tracking structure.
 *
 * Maintains all state needed during parsing:
 * - Token stream from lexer
 * - NFA being constructed
 * - Active flags and scopes
 * - Parsing position and depth
 */
struct _NAVRegexParserState {
    // Input: Token stream from lexer
    _NAVRegexToken tokens[MAX_REGEX_TOKENS]
    integer tokenCount              // Total number of tokens
    integer currentToken            // Current token index being parsed

    // Output: NFA being constructed
    _NAVRegexNFAState states[MAX_REGEX_NFA_STATES]
    integer stateCount              // Number of states created so far
    integer startState              // Index of NFA start state (entry point)
    integer acceptState             // Index of NFA accept state (match)

    // Parser flags (bitfield of PARSER_FLAG_* constants)
    integer activeFlags             // Currently active flags (from (?i), (?m), etc.)

    // Flag scope stack (for scoped flags like (?i:pattern))
    integer flagStack[MAX_REGEX_PARSER_DEPTH]  // Stack of flag states
    integer flagStackDepth          // Current depth of flag stack

    // Group tracking
    integer currentGroup            // Current group number (for capturing groups)
    integer groupDepth              // Current nesting depth of groups

    // Fragment stack (for building complex expressions)
    _NAVRegexNFAFragment fragmentStack[MAX_REGEX_PARSER_DEPTH]
    integer fragmentStackDepth      // Current depth of fragment stack

    // Error tracking
    char hasError                   // True if parsing error occurred
    char errorMessage[255]          // Human-readable error message
    integer errorTokenIndex         // Token index where error occurred

    // Pattern features (for optimization hints)
    char hasLookaround              // True if pattern contains lookahead/lookbehind
    char hasScopedFlags             // True if pattern contains any inline flag groups (scoped or global)
}


// ============================================================================
// COMPILED NFA
// ============================================================================

/**
 * @struct _NAVRegexNFA
 * @description The final compiled NFA ready for pattern matching.
 *
 * Contains the complete NFA with all states and transitions, plus
 * metadata needed for efficient matching.
 */
struct _NAVRegexNFA {
    // NFA states
    _NAVRegexNFAState states[MAX_REGEX_NFA_STATES]
    integer stateCount              // Total number of states

    // Entry and accept states
    integer startState              // Index of start state (where matching begins)
    integer acceptState             // Index of accept state (successful match)

    // Pattern metadata
    char originalPattern[MAX_REGEX_PATTERN_LENGTH]       // Original regex pattern string
    integer captureGroupCount       // Number of capturing groups in pattern

    // Compilation flags (preserved from parsing)
    integer flags                   // Bitfield of PARSER_FLAG_* constants

    // Global flags (from /pattern/flags syntax)
    char isGlobal                   // True if 'g' flag present (find all matches, not just first)

    // Optimization hints (for matcher)
    char isAnchored                 // True if pattern starts with ^
    char requiresAnchoring          // True if pattern starts with \A
    char hasBackreferences          // True if pattern contains \1, \2, etc.
    char hasLookaround              // True if pattern contains lookahead/lookbehind
    char hasScopedFlags             // True if pattern contains any inline flag groups (scoped or global)
}


#END_IF // __NAV_FOUNDATION_REGEX_PARSER_H__
