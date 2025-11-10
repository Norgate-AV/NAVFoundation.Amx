PROGRAM_NAME='NAVFoundation.RegexLexer'

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

/**
 * Regex Lexer - Tokenization Phase
 *
 * Converts a regex pattern string into a stream of tokens.
 * This is the first phase of regex compilation (lexing).
 *
 * The lexer:
 * - Scans the pattern character by character
 * - Recognizes regex special characters and constructs
 * - Produces tokens for later parsing into NFA
 * - Validates basic syntax (balanced parentheses, valid escapes, etc.)
 */


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_LEXER__
#DEFINE __NAV_FOUNDATION_REGEX_LEXER__ 'NAVFoundation.RegexLexer'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.RegexLexer.h.axi'
#include 'NAVFoundation.RegexLexerHelpers.axi'


// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * @function NAVRegexLexerValidatePatternStructure
 * @private
 * @description Validate all balanced constructs and syntax in a regex pattern.
 *
 * Performs comprehensive structural validation in a single pass:
 * - Escape sequences (no trailing backslash)
 * - Character classes [...] (must be closed)
 * - Parentheses () (must be balanced)
 * - Curly braces {} (must be balanced)
 * - Delimiter slashes / (must be paired/even count)
 *
 * Character class awareness: /, (, ), { and } inside [...] are literal characters.
 *
 * Error Detection (in priority order):
 * 1. Incomplete escape sequence (trailing backslash)
 * 2. Unterminated character class (missing ']')
 * 3. Unmatched closing parenthesis ')'
 * 4. Unmatched closing brace '}'
 * 5. Unclosed parenthesis (missing ')')
 * 6. Unclosed curly brace (missing '}')
 * 7. Unescaped '/' in pattern (odd slash count)
 *
 * This function only validates - it does not find delimiter positions.
 * Use NAVRegexLexerFindClosingDelimiter to locate the closing delimiter.
 *
 * @param {char[]} pattern - The full pattern string with delimiters
 *
 * @returns {char} True if pattern structure is valid, False on error
 *
 * @example
 * "/abc/"       → returns true
 * "/a\/b/"      → returns true (escaped slash)
 * "/[a/b]/"     → returns true (slash in char class)
 * "/(ab)/"      → returns true (balanced parens)
 * "/a{2,3}/"    → returns true (balanced braces)
 * "/abc\"       → returns false (trailing backslash)
 * "/[abc/"      → returns false (unclosed char class)
 * "/abc)/"      → returns false (unmatched closing paren)
 * "/(abc/"      → returns false (unclosed paren)
 * "/a{2/"       → returns false (unclosed brace)
 * "/a/b/"       → returns false (odd slash count - unescaped /)
 */
define_function char NAVRegexLexerValidatePatternStructure(char pattern[]) {
    stack_var integer i
    stack_var char currentChar
    stack_var char isEscaped
    stack_var char inCharClass
    stack_var integer slashCount
    stack_var integer parenDepth
    stack_var integer braceDepth
    stack_var integer patternLen

    isEscaped = false
    inCharClass = false
    slashCount = 0
    parenDepth = 0
    braceDepth = 0
    patternLen = length_array(pattern)

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ ValidatePatternStructure ]: Validating pattern: "', pattern, '" (length=', itoa(patternLen), ')'")
    #END_IF

    // Single pass: validate all balanced constructs and count slashes
    for (i = 1; i <= patternLen; i++) {
        currentChar = pattern[i]

        if (isEscaped) {
            isEscaped = false
            continue
        }

        if (currentChar == '\') {
            isEscaped = true
            continue
        }

        if (currentChar == '[' && !inCharClass) {
            inCharClass = true
            continue
        }

        if (currentChar == ']' && inCharClass) {
            inCharClass = false
            continue
        }

        // Track constructs only outside character classes
        if (!inCharClass) {
            if (currentChar == '/') {
                slashCount++
                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ ValidatePatternStructure ]: Found unescaped slash at position ', itoa(i), ', count now: ', itoa(slashCount)")
                #END_IF
            }
            else if (currentChar == '(') {
                parenDepth++
            }
            else if (currentChar == ')') {
                parenDepth--
                // Check for unmatched closing paren
                if (parenDepth < 0) {
                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ ValidatePatternStructure ]: ERROR - Unmatched closing parenthesis at position ', itoa(i)")
                    #END_IF
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER__,
                                                'NAVRegexLexerValidatePatternStructure',
                                                "'Unmatched closing parenthesis ")"'")
                    return false
                }
            }
            else if (currentChar == '{') {
                braceDepth++
            }
            else if (currentChar == '}') {
                braceDepth--
                // Check for unmatched closing brace
                if (braceDepth < 0) {
                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ ValidatePatternStructure ]: ERROR - Unmatched closing brace at position ', itoa(i)")
                    #END_IF
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER__,
                                                'NAVRegexLexerValidatePatternStructure',
                                                "'Unmatched closing brace "}"'")
                    return false
                }
            }
        }
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ ValidatePatternStructure ]: Scan complete. Slashes: ', itoa(slashCount), ', Parens: ', itoa(parenDepth), ', Braces: ', itoa(braceDepth)")
    #END_IF

    // Check for structural errors in priority order
    if (isEscaped) {
        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ ValidatePatternStructure ]: ERROR - Incomplete escape sequence'")
        #END_IF
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerValidatePatternStructure',
                                    "'Incomplete escape sequence (trailing backslash)'")
        return false
    }

    if (inCharClass) {
        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ ValidatePatternStructure ]: ERROR - Unterminated character class'")
        #END_IF
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerValidatePatternStructure',
                                    "'Unterminated character class (missing "]")'")
        return false
    }

    if (parenDepth > 0) {
        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ ValidatePatternStructure ]: ERROR - Unclosed parentheses, depth: ', itoa(parenDepth)")
        #END_IF
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerValidatePatternStructure',
                                    "'Unclosed parenthesis (missing ")")'")
        return false
    }

    if (braceDepth > 0) {
        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ ValidatePatternStructure ]: ERROR - Unclosed curly braces, depth: ', itoa(braceDepth)")
        #END_IF
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerValidatePatternStructure',
                                    "'Unclosed curly brace (missing "}")'")
        return false
    }

    if ((slashCount % 2) != 0) {
        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ ValidatePatternStructure ]: ERROR - Odd slash count detected (', itoa(slashCount), ')'")
        #END_IF
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerValidatePatternStructure',
                                    "'Unescaped "/" in pattern (use \/ to match literal slash)'")
        return false
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ ValidatePatternStructure ]: Validation passed - all constructs balanced'")
    #END_IF

    return true
}


/**
 * @function NAVRegexLexerFindClosingDelimiter
 * @private
 * @description Find the position of the closing delimiter ('/') in a regex pattern.
 *
 * Scans through the pattern starting from startPos to find the first unescaped
 * forward slash outside of character classes. This is the closing delimiter.
 *
 * IMPORTANT: This function assumes the pattern has already been validated with
 * NAVRegexLexerValidatePatternStructure(). It does NOT perform validation.
 *
 * @param {char[]} pattern - The full pattern string with delimiters (must be validated)
 * @param {integer} startPos - Position to start searching (typically 2, after opening /)
 * @param {integer} closingDelimiter - Output: position of closing delimiter
 *
 * @returns {char} True if closing delimiter found, False if not found
 *
 * @example
 * "/abc/", 2, pos      → returns true, pos=5
 * "/a\/b/", 2, pos     → returns true, pos=7 (escaped slash skipped)
 * "/[a/b]/", 2, pos    → returns true, pos=8 (slash in char class skipped)
 */
define_function char NAVRegexLexerFindClosingDelimiter(char pattern[],
                                                            integer startPos,
                                                            integer closingDelimiter) {
    stack_var integer i
    stack_var char currentChar
    stack_var char isEscaped
    stack_var char inCharClass
    stack_var integer patternLen

    isEscaped = false
    inCharClass = false
    patternLen = length_array(pattern)

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ FindClosingDelimiter ]: Searching for closing delimiter in pattern: "', pattern, '"'")
    NAVLog("'[ FindClosingDelimiter ]: Pattern length: ', itoa(patternLen), ', startPos: ', itoa(startPos)")
    #END_IF

    // Find the closing delimiter (first unescaped / outside character classes)
    for (i = startPos; i <= patternLen; i++) {
        currentChar = pattern[i]

        if (isEscaped) {
            isEscaped = false
            continue
        }

        if (currentChar == '\') {
            isEscaped = true
            continue
        }

        if (currentChar == '[' && !inCharClass) {
            inCharClass = true
            #IF_DEFINED REGEX_LEXER_DEBUG
            NAVLog("'[ FindClosingDelimiter ]: Entering character class at position ', itoa(i)")
            #END_IF
            continue
        }

        if (currentChar == ']' && inCharClass) {
            inCharClass = false
            #IF_DEFINED REGEX_LEXER_DEBUG
            NAVLog("'[ FindClosingDelimiter ]: Exiting character class at position ', itoa(i)")
            #END_IF
            continue
        }

        if (currentChar == '/' && !inCharClass) {
            // Found the closing delimiter
            #IF_DEFINED REGEX_LEXER_DEBUG
            NAVLog("'[ FindClosingDelimiter ]: SUCCESS - Found closing delimiter at position ', itoa(i)")
            #END_IF
            closingDelimiter = i
            return true
        }
    }

    // No closing delimiter found
    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ FindClosingDelimiter ]: ERROR - No closing delimiter found'")
    #END_IF

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerFindClosingDelimiter',
                                    "'Missing closing delimiter "/"'")

    return false
}


/**
 * @function NAVRegexLexerExtractPattern
 * @private
 * @description Extract the regex pattern from between forward slash delimiters.
 *
 * Finds the opening and closing delimiters, respecting escape sequences,
 * and extracts the pattern content between them. The closing delimiter
 * position is returned via the closingDelimiterPos parameter.
 *
 * Validates:
 * - Pattern starts with /
 * - Pattern has a closing /
 * - Escaped slashes (\/) are properly handled
 *
 * @param {char[]} pattern - The full pattern string with delimiters
 * @param {char[]} extractedPattern - Output: the extracted pattern content
 * @param {integer} closingDelimiterPos - Output: position of closing delimiter
 *
 * @returns {char} True if extraction succeeded, False if invalid pattern
 *
 * @example
 * "/abc/" → extractedPattern="abc", closingDelimiterPos=5
 * "//" → extractedPattern="", closingDelimiterPos=2 (empty pattern is valid)
 * "/a\/b/" → extractedPattern="a\/b", closingDelimiterPos=7
 * "/a/b/" → extractedPattern="a", closingDelimiterPos=3 (warns about unescaped /)
 */
define_function char NAVRegexLexerExtractPattern(char pattern[],
                                                   char extractedPattern[],
                                                   integer closingDelimiterPos) {
    stack_var integer openingDelimiter

    if (length_array(pattern) < 2) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerExtractPattern',
                                    "'Invalid regular expression'")
        return false
    }

    if (pattern[1] != '/') {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerExtractPattern',
                                    "'Missing opening delimiter "/"'")
        return false
    }

    // Validate pattern structure first
    if (!NAVRegexLexerValidatePatternStructure(pattern)) {
        return false
    }

    // Find closing delimiter (pattern is now validated)
    if (!NAVRegexLexerFindClosingDelimiter(pattern,
                                            2,
                                            closingDelimiterPos)) {
        return false
    }

    // Extract pattern between delimiters
    // Note: For "//" with closingDelimiterPos=2
    //       NAVStringSlice(pattern, 2, 2) returns '' (empty pattern, which is valid)
    if (closingDelimiterPos == 2) {
        // Empty pattern (e.g., // or //g)
        extractedPattern = ''
    }
    else {
        // Extract from after opening delimiter to before closing delimiter
        extractedPattern = NAVStringSlice(pattern,
                                            2,
                                            closingDelimiterPos)
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ ExtractPattern ]: Input: "', pattern, '"'")
    NAVLog("'[ ExtractPattern ]: Extracted: "', extractedPattern, '" (length=', itoa(length_array(extractedPattern)), ')'")
    NAVLog("'[ ExtractPattern ]: Closing delimiter at position: ', itoa(closingDelimiterPos)")
    #END_IF

    return true
}


/**
 * @function NAVRegexLexerExtractGlobalFlags
 * @private
 * @description Extract global flags from a regex pattern string.
 *
 * Extracts the flags portion after the closing delimiter.
 * e.g., "/pattern/gi" → returns "gi" (with closingDelimiter at position of last /)
 *       "/pattern/" → returns ""
 *
 * The lexer does NOT interpret the flags - it only extracts them.
 * Flag interpretation is the parser's responsibility.
 *
 * @param {char[]} pattern - The full pattern string with delimiters
 * @param {integer} closingDelimiter - Position of the closing / delimiter
 *
 * @returns {char[]} The extracted flags string (empty if no flags)
 */
define_function char[10] NAVRegexLexerExtractGlobalFlags(char pattern[], integer closingDelimiter) {
    stack_var char flags[10]

    // If there's content after the closing delimiter, it's the flags
    if (closingDelimiter > 0 && closingDelimiter < length_array(pattern)) {
        flags = NAVStringSubstring(pattern, closingDelimiter + 1, 0)

        #IF_DEFINED REGEX_LEXER_DEBUG
        if (length_array(flags) > 0) {
            NAVLog("'[ ExtractGlobalFlags ]: Found flags: "', flags, '"'")
        }
        #END_IF

        return flags
    }

    // No flags found
    return ''
}


/**
 * @function NAVRegexLexerInit
 * @public
 * @description Initialize a lexer structure with a regex pattern.
 *
 * Extracts the pattern from between forward slashes (/pattern/flags),
 * extracts any global flags, and initializes internal state.
 *
 * Pattern Delimiter Behavior:
 * - Uses FIRST forward slash as opening delimiter
 * - Finds FIRST UNESCAPED forward slash after opening as closing delimiter
 * - Everything between opening and closing delimiters is the pattern
 * - Content after closing delimiter is treated as flags
 * - Empty patterns are allowed: // or //g
 * - Forward slashes in patterns MUST be escaped: /a\/b/ not /a/b/
 * - Unescaped slashes will prematurely close the pattern
 *
 * Examples:
 * - "/abc/" → pattern: "abc", flags: ""
 * - "/abc/gi" → pattern: "abc", flags: "gi"
 * - "/a\/b/" → pattern: "a\/b", flags: ""
 * - "/a/b/" → pattern: "a", flags: "b/" (ERROR: unescaped slash)
 *
 * The lexer extracts but does NOT interpret flags - that's the parser's job.
 * Global flags are stored as a string for the parser to process.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure to initialize
 * @param {char[]} pattern - The regex pattern string (e.g., "/abc/gi")
 *
 * @returns {char} True (1) if initialization succeeded, False (0) if failed
 */
define_function char NAVRegexLexerInit(_NAVRegexLexer lexer, char pattern[]) {
    stack_var char trimmedPattern[MAX_REGEX_PATTERN_LENGTH]
    stack_var integer closingDelimiter

    if (length_array(pattern) > MAX_REGEX_PATTERN_LENGTH) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerInit',
                                    "'Regular expression exceeds maximum length (', itoa(MAX_REGEX_PATTERN_LENGTH), ')'")
        return false
    }

    trimmedPattern = NAVTrimString(pattern)

    // Extract the pattern content from between the delimiters
    if (!NAVRegexLexerExtractPattern(trimmedPattern,
                                     lexer.pattern.value,
                                     closingDelimiter)) {
        return false
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ LexerInit ]: Input pattern: "', pattern, '" (length=', itoa(length_array(pattern)), ')'")
    NAVLog("'[ LexerInit ]: Extracted pattern: "', lexer.pattern.value, '" (length=', itoa(length_array(lexer.pattern.value)), ')'")
    #END_IF

    lexer.pattern.length = length_array(lexer.pattern.value)
    lexer.pattern.cursor = 0

    // Extract global flags using the closing delimiter position
    // e.g., "/pattern/gi" with closingDelimiter at position of second / → "gi"
    lexer.globalFlags = NAVRegexLexerExtractGlobalFlags(trimmedPattern, closingDelimiter)

    // Initialize token array
    lexer.tokenCount = 0

    // Initialize group tracking
    lexer.groupCount = 0
    lexer.groupTotal = 0
    lexer.groupDepth = 0

    return true
}


// ============================================================================
// MAIN TOKENIZATION FUNCTION
// ============================================================================

/**
 * @function NAVRegexLexerTokenize
 * @public
 * @description Tokenize a regex pattern into a stream of tokens.
 *
 * This is the main entry point for the lexer. It:
 * - Initializes the lexer with the pattern
 * - Scans through the pattern character by character
 * - Generates tokens for all regex constructs
 * - Validates syntax (balanced parentheses, valid escapes, etc.)
 *
 * @param {char[]} pattern - The regex pattern to tokenize (e.g., "/ab+c/i")
 * @param {_NAVRegexLexer} lexer - Output: the populated lexer structure
 *
 * @returns {char} True (1) if tokenization succeeded, False (0) if errors occurred
 */
define_function char NAVRegexLexerTokenize(char pattern[], _NAVRegexLexer lexer) {
    stack_var char c

    if (!NAVRegexLexerInit(lexer, pattern)) {
        return false
    }

    while (NAVRegexLexerHasMoreChars(lexer)) {
        if (!NAVRegexLexerAdvanceCursor(lexer)) {
            return false
        }

        c = NAVRegexLexerGetCurrentChar(lexer)

        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ Lexer ]: cursor=', itoa(lexer.pattern.cursor), ' char=', c, ' (', itoa(type_cast(c)), ')'")
        #END_IF

        switch (c) {
            case '^': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_BEGIN, c)) {
                    return false
                }
            }
            case '$': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_END, c)) {
                    return false
                }
            }
            case '.': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_DOT, c)) {
                    return false
                }
            }

            // Quantifiers
            case '*': {
                stack_var char shouldContinue

                // Validate that we can quantify
                if (!NAVRegexLexerCanQuantify(lexer)) {
                    return false
                }

                // Check for lazy modifier (*?)
                if (!NAVRegexLexerHandleLazyModifier(lexer,
                                                     REGEX_TOKEN_STAR,
                                                     c,
                                                     shouldContinue)) {
                    return false
                }

                if (shouldContinue) {
                    continue
                }
            }
            case '+': {
                stack_var char shouldContinue

                // Validate that we can quantify
                if (!NAVRegexLexerCanQuantify(lexer)) {
                    return false
                }

                // Check for lazy modifier (+?)
                if (!NAVRegexLexerHandleLazyModifier(lexer,
                                                     REGEX_TOKEN_PLUS,
                                                     c,
                                                     shouldContinue)) {
                    return false
                }

                if (shouldContinue) {
                    continue
                }
            }
            case '?': {
                stack_var char shouldContinue

                // Check if the following character is '?' (lazy quantifier ??)
                if (NAVRegexLexerPeekNextChar(lexer) == '?') {
                    // Validate that we can quantify
                    if (!NAVRegexLexerCanQuantify(lexer)) {
                        return false
                    }

                    // Add the base quantifier token
                    if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_QUESTIONMARK, c)) {
                        return false
                    }

                    // Skip the second ?
                    if (!NAVRegexLexerAdvanceCursor(lexer)) {
                        return false
                    }

                    // Mark it as lazy
                    lexer.tokens[lexer.tokenCount].isLazy = true

                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Lazy questionmark quantifier ?? detected'")
                    #END_IF

                    continue
                }

                // Validate that we can quantify
                if (!NAVRegexLexerCanQuantify(lexer)) {
                    return false
                }

                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_QUESTIONMARK, c)) {
                    return false
                }
            }

            case '|': {
                // Tokenize alternation/union operator
                // Parser will validate if this feature is supported
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_ALTERNATION, c)) {
                    return false
                }
            }

            case '\': {
                // Handle escape sequences
                if (!NAVRegexLexerConsumeEscape(lexer, c)) {
                    return false
                }
            }

            case '{': {
                // Validate that we can quantify
                if (!NAVRegexLexerCanQuantify(lexer)) {
                    return false
                }

                if (!NAVRegexLexerConsumeBoundedQuantifier(lexer)) {
                    return false
                }

                // Check for lazy modifier ({n,m}?)
                if ((lexer.pattern.cursor + 1) <= lexer.pattern.length) {
                    if (NAVRegexLexerPeekNextChar(lexer) == '?') {
                        // Skip the ?
                        if (!NAVRegexLexerAdvanceCursor(lexer)) {
                            return false
                        }

                        // Mark the last QUANTIFIER token as lazy
                        if (lexer.tokens[lexer.tokenCount].type == REGEX_TOKEN_QUANTIFIER) {
                            lexer.tokens[lexer.tokenCount].isLazy = true

                            #IF_DEFINED REGEX_LEXER_DEBUG
                            NAVLog("'[ Lexer ]: Lazy bounded quantifier detected'")
                            #END_IF
                        }
                    }
                }
            }

            case '(': {
                // Handle group start (capturing, non-capturing, special groups)
                if (!NAVRegexLexerConsumeGroup(lexer, c)) {
                    return false
                }
            }

            case ')': {
                // Handle group end (capturing or non-capturing)
                if (!NAVRegexLexerConsumeGroupEnd(lexer, c)) {
                    return false
                }
            }

            case '[': {
                if (!NAVRegexLexerConsumeCharacterClass(lexer)) {
                    return false
                }
            }

            default: {
                // Regular character
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_CHAR, c)) {
                    return false
                }
            }
        }
    }

    // Validate that all groups are closed
    if (lexer.groupDepth != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerTokenize',
                                    "'Unclosed capturing group - missing `)` in pattern'")
        return false
    }

    if (lexer.tokenCount >= MAX_REGEX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER__,
                                    'NAVRegexLexerTokenize',
                                    "'Pattern too complex - exceeded maximum number of tokens (', itoa(MAX_REGEX_TOKENS), ')'")
        return false
    }

    // Add EOF marker after last token
    if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_EOF, 0)) {
        return false
    }

    // Reset the pattern cursor to 0
    lexer.pattern.cursor = 0

    #IF_DEFINED REGEX_LEXER_DEBUG
    if (lexer.groupTotal > 0) {
        stack_var integer namedCount
        stack_var integer nonCapturingCount
        stack_var integer x

        namedCount = 0
        nonCapturingCount = 0

        // Scan tokens to count named and non-capturing groups
        for (x = 1; x <= lexer.tokenCount; x++) {
            if (lexer.tokens[x].type == REGEX_TOKEN_GROUP_START) {
                if (lexer.tokens[x].groupInfo.isNamed) {
                    namedCount++
                }
                if (!lexer.tokens[x].groupInfo.isCapturing) {
                    nonCapturingCount++
                }
            }
        }

        NAVLog("'[ Lexer ]: Pattern contains ', itoa(lexer.groupCount), ' capturing group(s)'")
        if (namedCount > 0) {
            NAVLog("'[ Lexer ]:   - ', itoa(namedCount), ' named group(s)'")
        }

        if (nonCapturingCount > 0) {
            NAVLog("'[ Lexer ]:   - ', itoa(nonCapturingCount), ' non-capturing group(s)'")
        }

        NAVLog("'[ Lexer ]:   Total groups: ', itoa(lexer.groupTotal)")
    }
    #END_IF

    #IF_DEFINED REGEX_LEXER_DEBUG
    // Dump all tokens
    NAVLog("'[ Lexer ]: Tokenization complete. Total tokens: ', itoa(lexer.tokenCount)")
    NAVRegexLexerPrintTokens(lexer)
    #END_IF

    return true
}


#END_IF // __NAV_FOUNDATION_REGEX_LEXER__
