PROGRAM_NAME='NAVFoundation.RegexParser'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_PARSER__
#DEFINE __NAV_FOUNDATION_REGEX_PARSER__ 'NAVFoundation.RegexParser'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.RegexParser.h.axi'
#include 'NAVFoundation.RegexParserHelpers.axi'


/**
 * @function NAVRegexParserInit
 * @public
 * @description Initialize the parser state structure with a token stream.
 *
 * Resets all counters, initializes flags, and creates the initial start state
 * for the NFA. The token count is determined automatically from the array.
 *
 * @param {_NAVRegexParserState} parser - The parser state structure to initialize
 * @param {_NAVRegexToken[]} tokens - Array of tokens from the lexer
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParserInit(_NAVRegexParserState parser,
                                        _NAVRegexToken tokens[]) {
    stack_var integer i
    stack_var integer tokenCount

    // Determine token count from array
    tokenCount = length_array(tokens)

    if (!tokenCount) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER__,
                                    'NAVRegexParserInit',
                                    'No tokens provided')
        return false
    }

    if (tokenCount > MAX_REGEX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER__,
                                    'NAVRegexParserInit',
                                    "'Token count exceeds maximum: ', itoa(MAX_REGEX_TOKENS)")
        return false
    }

    // Copy token stream
    parser.tokens = tokens
    parser.tokenCount = tokenCount

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserInit ]: Token count: ', itoa(tokenCount)")
    #END_IF

    // Reset counters
    parser.stateCount = 0
    parser.currentToken = 1
    parser.currentGroup = 0
    parser.groupDepth = 0          // Initialize recursion depth counter

    // Initialize flag stack
    parser.flagStackDepth = 0
    parser.activeFlags = PARSER_FLAG_NONE

    // Reset error tracking
    parser.hasError = false
    parser.errorMessage = ''
    parser.errorTokenIndex = 0

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserInit ]: Creating start state'")
    #END_IF

    // Create placeholder start state (epsilon state for NFA entry)
    if (!NAVRegexParserCreateState(parser, NFA_STATE_EPSILON)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER__,
                                    'NAVRegexParserInit',
                                    'Failed to create start state')
        return false
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ParserInit ]: Parser initialized successfully (stateCount=', itoa(parser.stateCount), ')'")
    #END_IF

    return true
}


/**
 * @function NAVRegexParserProcessGlobalFlags
 * @private
 * @description Process global flags from the lexer and apply them to parser state and NFA.
 *
 * Interprets the global flag string (e.g., "gi", "ims") and sets the appropriate
 * parser flags and NFA properties.
 *
 * Supported flags:
 * - i: Case-insensitive matching (PARSER_FLAG_CASE_INSENSITIVE)
 * - m: Multiline mode (PARSER_FLAG_MULTILINE)
 * - s: Dotall mode (PARSER_FLAG_DOTALL)
 * - g: Global matching (nfa.isGlobal)
 *
 * @param {_NAVRegexParserState} parser - Parser state to update
 * @param {_NAVRegexNFA} nfa - NFA to update with global flag
 * @param {char[]} globalFlags - Global flags string from lexer
 *
 * @returns {char} True (1) on success, False (0) if invalid flag encountered
 */
define_function char NAVRegexParserProcessGlobalFlags(_NAVRegexParserState parser,
                                                      _NAVRegexNFA nfa,
                                                      char globalFlags[]) {
    stack_var integer x
    stack_var char flagChar

    if (!length_array(globalFlags)) {
        // No flags to process
        return true
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ ProcessGlobalFlags ]: Processing flags: "', globalFlags, '"'")
    #END_IF

    for (x = 1; x <= length_array(globalFlags); x++) {
        flagChar = NAVCharCodeAt(lower_string(globalFlags), x)

        switch (flagChar) {
            case 'i': {
                // Case-insensitive matching
                parser.activeFlags = parser.activeFlags bor PARSER_FLAG_CASE_INSENSITIVE
                #IF_DEFINED REGEX_PARSER_DEBUG
                NAVLog("'[ ProcessGlobalFlags ]: Enabled CASE_INSENSITIVE flag'")
                #END_IF
            }
            case 'm': {
                // Multiline mode (^ and $ match line boundaries)
                parser.activeFlags = parser.activeFlags bor PARSER_FLAG_MULTILINE
                #IF_DEFINED REGEX_PARSER_DEBUG
                NAVLog("'[ ProcessGlobalFlags ]: Enabled MULTILINE flag'")
                #END_IF
            }
            case 's': {
                // Dotall mode (. matches newlines)
                parser.activeFlags = parser.activeFlags bor PARSER_FLAG_DOTALL
                #IF_DEFINED REGEX_PARSER_DEBUG
                NAVLog("'[ ProcessGlobalFlags ]: Enabled DOTALL flag'")
                #END_IF
            }
            case 'g': {
                // Global flag - stored in NFA for matcher to use
                // Doesn't affect NFA construction
                nfa.isGlobal = true
                #IF_DEFINED REGEX_PARSER_DEBUG
                NAVLog("'[ ProcessGlobalFlags ]: Enabled GLOBAL flag'")
                #END_IF
            }
            case 'x': {
                // Extended mode - NOT IMPLEMENTED
                // Flag is accepted but has no effect (whitespace/comments not processed)
                // Inline (?x) is also lexed but ignored during parsing
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                            __NAV_FOUNDATION_REGEX_PARSER__,
                                            'NAVRegexParserProcessGlobalFlags',
                                            "'Extended mode flag (x) is not supported and will have no effect'")
                #IF_DEFINED REGEX_PARSER_DEBUG
                NAVLog("'[ ProcessGlobalFlags ]: Extended flag (x) - NO-OP (not implemented)'")
                #END_IF
            }
            default: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                            __NAV_FOUNDATION_REGEX_PARSER__,
                                            'NAVRegexParserProcessGlobalFlags',
                                            "'Unknown global flag: ', flagChar")
                // Continue processing other flags despite warning
            }
        }
    }

    return true
}


/**
 * @function NAVRegexParse
 * @public
 * @description Main entry point for parsing a regex token stream into an NFA.
 *
 * This function:
 * 1. Processes global flags from the lexer
 * 2. Initializes the parser state
 * 3. Parses the entire token stream
 * 4. Creates the final accept state
 * 5. Connects the NFA and sets metadata
 *
 * @param {_NAVRegexLexer} lexer - Lexer containing tokens and global flags
 * @param {_NAVRegexNFA} nfa - Output NFA structure to populate
 *
 * @returns {char} True (1) on success, False (0) on failure
 */
define_function char NAVRegexParse(_NAVRegexLexer lexer,
                                   _NAVRegexNFA nfa) {
    stack_var _NAVRegexParserState parser
    stack_var _NAVRegexNFAFragment result
    stack_var integer acceptState
    stack_var integer i
    stack_var integer x
    stack_var char flagChar

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ NAVRegexParse ]: Starting parse with ', itoa(lexer.tokenCount), ' tokens'")
    #END_IF

    // Initialize parser
    if (!NAVRegexParserInit(parser, lexer.tokens)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER__,
                                    'NAVRegexParse',
                                    'Parser initialization failed')
        return false
    }

    // Process global flags from lexer (e.g., /pattern/gi)
    if (!NAVRegexParserProcessGlobalFlags(parser, nfa, lexer.globalFlags)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER__,
                                    'NAVRegexParse',
                                    'Failed to process global flags')
        return false
    }

    // Parse the entire token stream
    if (!NAVRegexParserParseExpression(parser, 1, parser.tokenCount, result)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER__,
                                    'NAVRegexParse',
                                    'Parse expression failed')
        return false
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ NAVRegexParse ]: Parse successful, creating accept state'")
    #END_IF

    // Create final accept state
    acceptState = NAVRegexParserAddState(parser, NFA_STATE_MATCH)
    if (!acceptState) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER__,
                                    'NAVRegexParse',
                                    'Failed to create accept state')
        return false
    }

    // Patch the result fragment to the accept state
    if (!NAVRegexParserPatchFragment(parser, result, acceptState)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER__,
                                    'NAVRegexParse',
                                    'Failed to patch final fragment')
        return false
    }

    // Connect the initial EPSILON state (State 1) to the parsed fragment
    // State 1 was created during parser initialization as the NFA entry point
    if (!NAVRegexParserAddTransition(parser, 1, result.startState, true)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_PARSER__,
                                    'NAVRegexParse',
                                    'Failed to connect start state to fragment')
        return false
    }

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ NAVRegexParse ]: Copying NFA (', itoa(parser.stateCount), ' states)'")
    #END_IF

    // Copy states to output NFA
    nfa.stateCount = parser.stateCount
    for (i = 1; i <= parser.stateCount; i++) {
        nfa.states[i] = parser.states[i]
    }

    // Set start state to the initial EPSILON state (State 1)
    nfa.startState = 1

    // Set metadata
    nfa.captureGroupCount = parser.currentGroup
    nfa.hasLookaround = false  // Will be set by matching engine if needed
    nfa.isAnchored = false  // Will be optimized later
    nfa.hasScopedFlags = parser.hasScopedFlags  // Copy from parser state

    // Check if pattern contains backreferences
    nfa.hasBackreferences = false
    for (x = 1; x <= nfa.stateCount; x++) {
        if (nfa.states[x].type == NFA_STATE_BACKREF) {
            nfa.hasBackreferences = true
            break
        }
    }

    // Copy active flags from parser to NFA
    nfa.flags = parser.activeFlags

    #IF_DEFINED REGEX_PARSER_DEBUG
    NAVLog("'[ NAVRegexParse ]: Parse complete - ', itoa(nfa.stateCount), ' states, ', itoa(nfa.captureGroupCount), ' groups, backrefs=', itoa(nfa.hasBackreferences), ', flags=', itoa(nfa.flags)")
    #END_IF

    return true
}


#END_IF // __NAV_FOUNDATION_REGEX_PARSER__
