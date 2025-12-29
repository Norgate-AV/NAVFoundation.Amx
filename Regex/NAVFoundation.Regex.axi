PROGRAM_NAME='NAVFoundation.Regex'

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


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX__
#DEFINE __NAV_FOUNDATION_REGEX__ 'NAVFoundation.Regex'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Regex.h.axi'
#include 'NAVFoundation.RegexLexer.axi'
#include 'NAVFoundation.RegexParser.axi'
#include 'NAVFoundation.RegexMatcher.axi'
#include 'NAVFoundation.RegexHelpers.axi'
#include 'NAVFoundation.RegexTemplate.axi'


// ----------------------------------------------------------------------------
// ADVANCED API - Compilation Functions
// ----------------------------------------------------------------------------

/**
 * @function NAVRegexCompile
 * @public
 * @description Compile a regex pattern into an NFA for reuse.
 *
 * This is the first step of the Advanced API. Compile once, match many times.
 * Useful when the same pattern is used repeatedly against different inputs.
 *
 * @param {char[]} pattern - The regex pattern to compile
 * @param {_NAVRegexNFA} nfa - The NFA structure to populate
 *
 * @returns {char} TRUE if compilation succeeded, FALSE otherwise
 */
define_function char NAVRegexCompile(char pattern[], _NAVRegexNFA nfa) {
    stack_var _NAVRegexLexer lexer

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Compile ]: Compiling pattern: "', pattern, '"'")
    #END_IF

    // Tokenize the pattern
    if (!NAVRegexLexerTokenize(pattern, lexer)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Compile ]: ERROR - Tokenization failed'")
        #END_IF
        return false
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Compile ]: Tokenization succeeded, token count: ', itoa(lexer.tokenCount)")
    #END_IF

    // Parse tokens into NFA (lexer now passed to access global flags)
    if (!NAVRegexParse(lexer, nfa)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Compile ]: ERROR - Parsing failed'")
        #END_IF
        return false
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Compile ]: Parsing succeeded, NFA state count: ', itoa(nfa.stateCount)")
    NAVLog("'[ Compile ]: NFA start state: ', itoa(nfa.startState), ', accept state: ', itoa(nfa.acceptState)")
    #END_IF

    return true
}


// ----------------------------------------------------------------------------
// SIMPLE API - Test Function
// ----------------------------------------------------------------------------

/**
 * @function NAVRegexTest
 * @public
 * @description Quick test if a pattern matches an input string.
 *
 * Simple boolean test - no capture groups or match details returned.
 * Compiles pattern internally (not efficient for repeated use).
 *
 * @param {char[]} pattern - The regex pattern
 * @param {char[]} input - The input string to test
 *
 * @returns {char} TRUE if pattern matches, FALSE otherwise
 */
define_function char NAVRegexTest(char pattern[], char input[]) {
    stack_var _NAVRegexNFA nfa
    stack_var _NAVRegexMatchResult result

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Test ]: Testing pattern "', pattern, '" against input "', input, '"'")
    #END_IF

    // Compile pattern
    if (!NAVRegexCompile(pattern, nfa)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Test ]: Pattern compilation failed'")
        #END_IF
        return false
    }

    // Execute match
    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Test ]: Executing match'")
    #END_IF
    return NAVRegexMatchInternal(nfa, input, 1, result)
}


// ----------------------------------------------------------------------------
// SIMPLE API - Match Functions
// ----------------------------------------------------------------------------

/**
 * @function NAVRegexMatch
 * @public
 * @description Match a pattern against an input string.
 *
 * Dynamic behavior based on global flag:
 * - Without /g flag: Returns first match only (collection.count = 1)
 * - With /g flag: Returns all matches (collection.count = N)
 *
 * Compiles pattern internally (not efficient for repeated use).
 *
 * For forcing global behavior regardless of /g flag, use NAVRegexMatchAll.
 * For efficient repeated matching, use Advanced API (Compile + MatchCompiled).
 *
 * @param {char[]} pattern - The regex pattern (with or without /g flag)
 * @param {char[]} input - The input string to match against
 * @param {_NAVRegexMatchCollection} collection - Result structure to populate
 *
 * @returns {char} TRUE if at least one match found, FALSE otherwise
 */
define_function char NAVRegexMatch(char pattern[],
                                   char input[],
                                   _NAVRegexMatchCollection collection) {
    stack_var _NAVRegexNFA nfa

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Match ]: Pattern: "', pattern, '", Input: "', input, '"'")
    #END_IF

    // Initialize collection
    NAVRegexMatchCollectionInit(collection)

    // Compile pattern
    if (!NAVRegexCompile(pattern, nfa)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Match ]: ERROR - Pattern compilation failed'")
        #END_IF
        collection.status = MATCH_STATUS_ERROR
        collection.errorMessage = 'Pattern compilation failed'
        return false
    }

    // Check if global flag is set
    if (nfa.isGlobal) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Match ]: Global flag detected, finding all matches'")
        #END_IF

        // Use shared global matching implementation
        return NAVRegexMatchGlobalInternal(nfa, input, collection, 'NAVRegexMatch')
    }
    else {
        stack_var char literalPrefix[255]
        stack_var integer prefixLen
        stack_var integer foundPos
        stack_var integer nextPos

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Match ]: Executing single match'")
        #END_IF

        // OPTIMIZATION: Extract literal prefix from pattern (if possible)
        // NOTE: Disabled for patterns with scoped flags (?i:...) as the prefix
        // may appear after flag scope changes, leading to incorrect match starts
        prefixLen = NAVRegexMatcherGetLiteralPrefix(nfa, literalPrefix)

        #IF_DEFINED REGEX_MATCHER_DEBUG
        if (prefixLen > 0) {
            NAVLog("'[ Match ]: Literal prefix optimization enabled: "', literalPrefix, '" (', itoa(prefixLen), ' chars)'")
        }
        #END_IF

        nextPos = 1

        // OPTIMIZATION: Use NAVIndexOf (case-sensitive or insensitive) to find first potential match position
        // Skip optimization if pattern has scoped flags to avoid missing flag scope regions
        if (prefixLen > 0 && !nfa.hasScopedFlags) {
            if (nfa.flags band PARSER_FLAG_CASE_INSENSITIVE) {
                foundPos = NAVIndexOfCaseInsensitive(input, literalPrefix, nextPos)
            } else {
                foundPos = NAVIndexOf(input, literalPrefix, nextPos)
            }

            if (foundPos == 0) {
                #IF_DEFINED REGEX_MATCHER_DEBUG
                NAVLog("'[ Match ]: Literal prefix not found, no match possible'")
                #END_IF
                return false
            }

            nextPos = foundPos

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ Match ]: Prefix found at position ', itoa(nextPos)")
            #END_IF
        }

        // Execute single match from the optimized starting position
        if (NAVRegexMatchInternal(nfa, input, nextPos, collection.matches[1])) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ Match ]: Match found!'")
            #END_IF
            collection.status = MATCH_STATUS_SUCCESS
            collection.count = 1
            return true
        }

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Match ]: No match found'")
        #END_IF

        return false
    }
}


// ----------------------------------------------------------------------------
// SIMPLE API - Global Match Functions
// ----------------------------------------------------------------------------

/**
 * @function NAVRegexMatchAll
 * @public
 * @description Find all matches of a pattern in an input string.
 *
 * Always returns all non-overlapping matches from left to right,
 * regardless of whether /g flag is present in pattern.
 * Forces global matching behavior.
 *
 * Compiles pattern internally (not efficient for repeated use).
 *
 * For dynamic /g flag behavior, use NAVRegexMatch (respects /g flag).
 * For efficient repeated matching, use Advanced API (Compile + MatchAllCompiled).
 *
 * @param {char[]} pattern - The regex pattern (with or without /g flag)
 * @param {char[]} input - The input string to match against
 * @param {_NAVRegexMatchCollection} collection - Result structure to populate
 *
 * @returns {char} TRUE if at least one match found, FALSE otherwise
 */
define_function char NAVRegexMatchAll(char pattern[],
                                      char input[],
                                      _NAVRegexMatchCollection collection) {
    stack_var _NAVRegexNFA nfa

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchAll ]: Pattern: "', pattern, '", Input: "', input, '"'")
    #END_IF

    // Initialize collection
    NAVRegexMatchCollectionInit(collection)

    // Compile pattern
    if (!NAVRegexCompile(pattern, nfa)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchAll ]: ERROR - Pattern compilation failed'")
        #END_IF
        collection.status = MATCH_STATUS_ERROR
        collection.errorMessage = 'Pattern compilation failed'
        return false
    }

    // Use shared global matching implementation
    return NAVRegexMatchGlobalInternal(nfa, input, collection, 'NAVRegexMatchAll')
}


// ----------------------------------------------------------------------------
// ADVANCED API - Match with Pre-compiled NFA
// ----------------------------------------------------------------------------

/**
 * @function NAVRegexMatchCompiled
 * @public
 * @description Match using a pre-compiled NFA.
 *
 * Dynamic behavior based on global flag in compiled NFA:
 * - NFA compiled without /g: Returns first match only (collection.count = 1)
 * - NFA compiled with /g: Returns all matches (collection.count = N)
 *
 * More efficient than NAVRegexMatch when the same pattern is used repeatedly.
 * First compile with NAVRegexCompile, then reuse the NFA many times.
 *
 * @param {_NAVRegexNFA} nfa - Pre-compiled NFA from NAVRegexCompile
 * @param {char[]} input - The input string to match against
 * @param {_NAVRegexMatchCollection} collection - Result structure to populate
 *
 * @returns {char} TRUE if at least one match found, FALSE otherwise
 */
define_function char NAVRegexMatchCompiled(_NAVRegexNFA nfa,
                                           char input[],
                                           _NAVRegexMatchCollection collection) {
    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchCompiled ]: Input: "', input, '"'")
    NAVLog("'[ MatchCompiled ]: NFA state count: ', itoa(nfa.stateCount)")
    #END_IF

    // Initialize collection
    NAVRegexMatchCollectionInit(collection)

    // Check if global flag is set
    if (nfa.isGlobal) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchCompiled ]: Global flag detected, finding all matches'")
        #END_IF

        // Use shared global matching implementation
        return NAVRegexMatchGlobalInternal(nfa, input, collection, 'NAVRegexMatchCompiled')
    }
    else {
        // Execute single match
        if (NAVRegexMatchInternal(nfa, input, 1, collection.matches[1])) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ MatchCompiled ]: Match found!'")
            #END_IF
            collection.status = MATCH_STATUS_SUCCESS
            collection.count = 1
            return true
        }

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ MatchCompiled ]: No match found'")
        #END_IF

        return false
    }
}


/**
 * @function NAVRegexMatchAllCompiled
 * @public
 * @description Find all matches using a pre-compiled NFA.
 *
 * Always returns all non-overlapping matches from left to right,
 * regardless of whether /g flag was present when NFA was compiled.
 * Forces global matching behavior.
 *
 * More efficient than NAVRegexMatchAll when the same pattern is used repeatedly.
 * First compile with NAVRegexCompile, then reuse the NFA many times.
 *
 * @param {_NAVRegexNFA} nfa - Pre-compiled NFA from NAVRegexCompile
 * @param {char[]} input - The input string to match against
 * @param {_NAVRegexMatchCollection} collection - Result structure to populate
 *
 * @returns {char} TRUE if at least one match found, FALSE otherwise
 */
define_function char NAVRegexMatchAllCompiled(_NAVRegexNFA nfa,
                                              char input[],
                                              _NAVRegexMatchCollection collection) {
    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ MatchAllCompiled ]: Input: "', input, '"'")
    NAVLog("'[ MatchAllCompiled ]: NFA state count: ', itoa(nfa.stateCount)")
    #END_IF

    // Initialize collection
    NAVRegexMatchCollectionInit(collection)

    // Use shared global matching implementation
    return NAVRegexMatchGlobalInternal(nfa, input, collection, 'NAVRegexMatchAllCompiled')
}


// ----------------------------------------------------------------------------
// SIMPLE API - Replace Functions
// ----------------------------------------------------------------------------

/**
 * @function NAVRegexBuildReplacementOutput
 * @private
 * @description Build output string by applying template replacements to matches.
 *
 * Core replacement logic shared by NAVRegexReplace and NAVRegexReplaceAll.
 * Iterates through matches, interleaving unchanged portions with replacement text.
 *
 * @param {_NAVRegexMatchCollection} matches - Collection of pattern matches
 * @param {char[]} input - Original input string
 * @param {_NAVRegexTemplate} template - Parsed replacement template
 * @param {char[]} output - Result string (input with replacements made)
 *
 * @returns {char} TRUE on success, FALSE if template application fails
 */
define_function char NAVRegexBuildReplacementOutput(_NAVRegexMatchCollection matches,
                                                      char input[],
                                                      _NAVRegexTemplate template,
                                                      char output[]) {
    stack_var integer i
    stack_var integer inputPos
    stack_var char replacementText[NAV_MAX_BUFFER]

    // Build output string by interleaving unchanged portions with replacements
    inputPos = 1

    for (i = 1; i <= matches.count; i++) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ BuildReplacementOutput ]: Processing match ', itoa(i),
               ' at position ', itoa(matches.matches[i].fullMatch.start)")
        #END_IF

        // Append unchanged portion before this match
        if (type_cast(matches.matches[i].fullMatch.start) > inputPos) {
            output = "output, NAVStringSubstring(input, inputPos,
                                                 type_cast(matches.matches[i].fullMatch.start) - inputPos)"

            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ BuildReplacementOutput ]:   Added unchanged text from ', itoa(inputPos),
                   ' to ', itoa(matches.matches[i].fullMatch.start - 1)")
            #END_IF
        }

        // Apply template to this match to generate replacement text
        if (!NAVRegexTemplateApply(template, matches.matches[i], replacementText)) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ BuildReplacementOutput ]: ERROR - Template application failed'")
            #END_IF
            return false
        }

        // Append the replacement text
        output = "output, replacementText"

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ BuildReplacementOutput ]:   Added replacement: "', replacementText, '"'")
        #END_IF

        // Move input position past this match
        inputPos = type_cast(matches.matches[i].fullMatch.end) + 1
    }

    // Append any remaining input after the last match
    if (inputPos <= length_array(input)) {
        output = "output, NAVStringSubstring(input, inputPos, length_array(input) - inputPos + 1)"

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ BuildReplacementOutput ]:   Added remaining text from ', itoa(inputPos), ' to end'")
        #END_IF
    }

    return true
}


/**
 * @function NAVRegexReplace
 * @public
 * @description Replace pattern matches in a string with replacement text.
 *
 * Dynamic behavior based on global flag:
 * - Without /g flag: Replace first match only
 * - With /g flag: Replace all matches
 *
 * Supports capture group substitution in replacement text:
 * - $1, $2, $3... = Numbered capture groups
 * - $0 or $& = Full match text
 * - ${name} or $<name> = Named capture groups
 * - $$ = Literal dollar sign
 *
 * Returns TRUE even if no match (output = input unchanged).
 * Returns FALSE only if pattern compilation fails (output = '').
 *
 * @param {char[]} pattern - The regex pattern (with or without /g flag)
 * @param {char[]} input - The input string to search in
 * @param {char[]} replacement - Replacement text with optional $1, $2, etc.
 * @param {char[]} output - Result string (input with replacements made)
 *
 * @returns {char} TRUE if pattern compiled (even if no match), FALSE on error
 */
define_function char NAVRegexReplace(char pattern[], char input[],
                                      char replacement[], char output[]) {
    stack_var _NAVRegexTemplate template
    stack_var _NAVRegexMatchCollection matches

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Replace ]: Pattern: "', pattern, '", Input: "', input, '", Replacement: "', replacement, '"'")
    #END_IF

    // Initialize output
    output = ''

    // Find matches first (respects /g flag in pattern)
    if (!NAVRegexMatch(pattern, input, matches)) {
        // Check if it was an error vs no match
        if (matches.status == MATCH_STATUS_ERROR) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ Replace ]: ERROR - Pattern matching failed: ', matches.errorMessage")
            #END_IF
            return false
        }

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Replace ]: No matches found, returning input unchanged'")
        #END_IF

        // No match found - return original input unchanged
        // This is still considered success
        output = input
        return true
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Replace ]: Found ', itoa(matches.count), ' match(es)'")
    #END_IF

    // Parse replacement template only if we have matches
    if (!NAVRegexTemplateParse(replacement, template)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Replace ]: ERROR - Template parsing failed'")
        #END_IF
        return false
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Replace ]: Template parsed successfully, ', itoa(template.partCount), ' parts'")
    #END_IF

    // Build output string by applying replacements to all matches
    if (!NAVRegexBuildReplacementOutput(matches, input, template, output)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Replace ]: ERROR - Replacement output build failed'")
        #END_IF
        return false
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Replace ]: Final output: "', output, '"'")
    #END_IF

    return true
}

/**
 * @function NAVRegexReplaceAll
 * @public
 * @description Replace all pattern matches, forcing global behavior.
 *
 * Always replaces all non-overlapping matches from left to right,
 * regardless of whether /g flag is present in pattern.
 *
 * Supports same replacement syntax as NAVRegexReplace:
 * - $1, $2, $3... = Numbered capture groups
 * - $0 or $& = Full match text
 * - ${name} or $<name> = Named capture groups
 * - $$ = Literal dollar sign
 *
 * @param {char[]} pattern - The regex pattern (with or without /g flag)
 * @param {char[]} input - The input string to search in
 * @param {char[]} replacement - Replacement text with optional $1, $2, etc.
 * @param {char[]} output - Result string (input with all replacements made)
 *
 * @returns {char} TRUE if pattern compiled (even if no match), FALSE on error
 */
define_function char NAVRegexReplaceAll(char pattern[], char input[],
                                         char replacement[], char output[]) {
    stack_var _NAVRegexTemplate template
    stack_var _NAVRegexMatchCollection matches

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ ReplaceAll ]: Pattern: "', pattern, '", Input: "', input, '", Replacement: "', replacement, '"'")
    #END_IF

    // Initialize output
    output = ''

    // Find ALL matches first (ignores /g flag, always global)
    if (!NAVRegexMatchAll(pattern, input, matches)) {
        // Check if it was an error vs no match
        if (matches.status == MATCH_STATUS_ERROR) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ ReplaceAll ]: ERROR - Pattern matching failed: ', matches.errorMessage")
            #END_IF
            return false
        }

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ ReplaceAll ]: No matches found, returning input unchanged'")
        #END_IF

        // No match found - return original input unchanged
        // This is still considered success
        output = input
        return true
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ ReplaceAll ]: Found ', itoa(matches.count), ' match(es)'")
    #END_IF

    // Parse replacement template only if we have matches
    if (!NAVRegexTemplateParse(replacement, template)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ ReplaceAll ]: ERROR - Template parsing failed'")
        #END_IF
        return false
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ ReplaceAll ]: Template parsed successfully, ', itoa(template.partCount), ' parts'")
    #END_IF

    // Build output string by applying replacements to all matches
    if (!NAVRegexBuildReplacementOutput(matches, input, template, output)) {
        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ ReplaceAll ]: ERROR - Replacement output build failed'")
        #END_IF
        return false
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ ReplaceAll ]: Final output: "', output, '"'")
    #END_IF

    return true
}


// ----------------------------------------------------------------------------
// SIMPLE API - Split Functions
// ----------------------------------------------------------------------------

/**
 * @function NAVRegexSplit
 * @public
 * @description Split a string using pattern matches as delimiters.
 *
 * Pattern matches are removed (used as delimiters only).
 * Always splits on all matches (ignores /g flag).
 * Empty strings are preserved (e.g., ',a,,b,' -> ['', 'a', '', 'b', '']).
 *
 * If pattern doesn't match, returns entire input as single part (count = 1).
 * If array too small, fills what it can - compare count vs array size to detect truncation.
 *
 * @param {char[]} pattern - The regex pattern for delimiters
 * @param {char[]} input - The input string to split
 * @param {char[][]} parts - Array to populate with split parts
 * @param {integer} count - Output: number of parts found (may exceed array size)
 *
 * @returns {char} TRUE if pattern compiled (even if no split), FALSE on error
 */
define_function char NAVRegexSplit(char pattern[],
                                   char input[],
                                   char parts[][],
                                   integer count) {
    stack_var _NAVRegexMatchCollection matches
    stack_var integer currentPos
    stack_var integer partIndex
    stack_var integer i
    stack_var integer maxParts

    // Initialize
    count = 0
    partIndex = 1
    maxParts = max_length_array(parts)
    set_length_array(parts, 0)

    // Handle empty input
    if (!length_array(input)) {
        if (maxParts > 0) {
            parts[1] = ''
        }

        count = 1
        set_length_array(parts, count)

        return true
    }

    // Find all delimiter matches
    if (!NAVRegexMatchAll(pattern, input, matches)) {
        // Check if it was an error vs no match
        if (matches.status == MATCH_STATUS_ERROR) {
            #IF_DEFINED REGEX_MATCHER_DEBUG
            NAVLog("'[ Split ]: ERROR - Pattern matching failed: ', matches.errorMessage")
            #END_IF
            return false
        }

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVLog("'[ Split ]: No matches found, returning entire input as single part'")
        #END_IF

        // No matches - entire input is one part
        if (maxParts > 0) {
            parts[1] = input
        }

        count = 1
        set_length_array(parts, count)

        return true
    }

    // Extract parts between matches
    currentPos = 1

    for (i = 1; i <= matches.count; i++) {
        // Extract part before this delimiter
        if (partIndex <= maxParts) {
            if (type_cast(matches.matches[i].fullMatch.start) > currentPos) {
                // Non-empty part before delimiter
                parts[partIndex] = NAVStringSlice(input,
                                                  currentPos,
                                                  type_cast(matches.matches[i].fullMatch.start))
            }
            else {
                // Empty part (consecutive delimiters or starts with delimiter)
                parts[partIndex] = ''
            }

            set_length_array(parts, partIndex)
        }

        count++
        partIndex++

        // Move position to after this delimiter
        currentPos = type_cast(matches.matches[i].fullMatch.end) + 1
    }

    // Add final part after last delimiter
    if (currentPos <= length_array(input)) {
        // There's text after the last delimiter
        if (partIndex <= maxParts) {
            // NAVStringSlice: end=0 means "to end of string"
            parts[partIndex] = NAVStringSlice(input, currentPos, 0)
            set_length_array(parts, partIndex)
        }

        count++
    }
    else {
        // Input ends exactly at delimiter (or delimiter is zero-width at end)
        // Add empty final part
        if (partIndex <= maxParts) {
            parts[partIndex] = ''
            set_length_array(parts, partIndex)
        }

        count++
    }

    return true
}


#END_IF // __NAV_FOUNDATION_REGEX__
