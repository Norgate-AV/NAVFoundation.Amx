PROGRAM_NAME='NAVFoundation.RegexTemplate'

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

/**
 * Regex Template Parser Implementation
 *
 * This module implements the parsing and processing of replacement templates
 * for regex replace operations. It provides a mini-lexer/parser specifically
 * designed to handle substitution syntax in replacement strings.
 *
 * The parser operates in a single pass through the template string, identifying
 * literal text segments and substitution markers, building a structured
 * representation that can be efficiently processed during replacement.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_TEMPLATE__
#DEFINE __NAV_FOUNDATION_REGEX_TEMPLATE__ 'NAVFoundation.RegexTemplate'

#include 'NAVFoundation.RegexTemplate.h.axi'
#include 'NAVFoundation.RegexHelpers.axi'
#include 'NAVFoundation.StringUtils.axi'


// ============================================================================
// HELPER FUNCTIONS - Internal Utilities
// ============================================================================

/**
 * Check if a character is a valid digit (0-9).
 *
 * @param {char} c - The character to check
 * @returns {char} TRUE if character is a digit, FALSE otherwise
 */
define_function char NAVRegexTemplateIsDigit(char c) {
    return (c >= '0' && c <= '9')
}


/**
 * Check if a character is valid for starting an identifier.
 *
 * Valid starting characters for named group identifiers:
 * - Letters: a-z, A-Z
 * - Underscore: _
 *
 * @param {char} c - The character to check
 * @returns {char} TRUE if valid identifier start, FALSE otherwise
 */
define_function char NAVRegexTemplateIsIdentifierStart(char c) {
    return ((c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z') ||
            c == '_')
}


/**
 * Check if a character is valid for continuing an identifier.
 *
 * Valid continuation characters for named group identifiers:
 * - Letters: a-z, A-Z
 * - Digits: 0-9
 * - Underscore: _
 *
 * @param {char} c - The character to check
 * @returns {char} TRUE if valid identifier continuation, FALSE otherwise
 */
define_function char NAVRegexTemplateIsIdentifierChar(char c) {
    return ((c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z') ||
            (c >= '0' && c <= '9') ||
            c == '_')
}


/**
 * Parse a decimal number from a string starting at given position.
 *
 * Extracts consecutive digits and converts to integer.
 * Advances position to character after the last digit.
 *
 * @param {char[]} str - The source string
 * @param {integer} pos - Starting position (1-based, modified by reference)
 * @returns {integer} The parsed number, or 0 if no digits found
 */
define_function integer NAVRegexTemplateParseNumber(char str[], integer pos) {
    stack_var integer result
    stack_var integer len
    stack_var char c

    result = 0
    len = length_array(str)

    while (pos <= len) {
        c = str[pos]

        if (!NAVRegexTemplateIsDigit(c)) {
            break
        }

        result = result * 10 + (c - '0')
        pos++
    }

    return result
}


/**
 * Extract an identifier from a string starting at given position.
 *
 * Reads characters that form a valid identifier (letters, digits, underscore)
 * and advances position to character after the identifier.
 *
 * @param {char[]} str - The source string
 * @param {integer} pos - Starting position (1-based, modified by reference)
 * @param {char[]} identifier - Output buffer for the identifier
 * @returns {char} TRUE if identifier extracted, FALSE otherwise
 */
define_function char NAVRegexTemplateExtractIdentifier(char str[], integer pos,
                                                         char identifier[]) {
    stack_var integer len
    stack_var integer startPos
    stack_var char c

    identifier = ''
    len = length_array(str)

    if (pos > len) {
        return false
    }

    // First character must be valid identifier start
    c = str[pos]
    if (!NAVRegexTemplateIsIdentifierStart(c)) {
        return false
    }

    startPos = pos
    pos++

    // Subsequent characters can be letters, digits, or underscore
    while (pos <= len) {
        c = str[pos]

        if (!NAVRegexTemplateIsIdentifierChar(c)) {
            break
        }

        pos++
    }

    // Extract the identifier substring
    identifier = NAVStringSubstring(str, startPos, pos - startPos)

    return (length_array(identifier) > 0)
}


// ============================================================================
// CORE TEMPLATE PARSING FUNCTIONS
// ============================================================================

/**
 * Add a literal text part to the template.
 *
 * @param {_NAVRegexTemplate} template - The template being built
 * @param {char[]} text - The literal text to add
 * @returns {char} TRUE if part added successfully, FALSE if template full
 */
define_function char NAVRegexTemplateAddLiteral(_NAVRegexTemplate template,
                                                  char text[]) {
    if (template.partCount >= MAX_REGEX_TEMPLATE_PARTS) {
        return false
    }

    if (length_array(text) == 0) {
        return true  // Empty literal, nothing to add
    }

    template.partCount++
    template.parts[template.partCount].type = REGEX_TEMPLATE_LITERAL
    template.parts[template.partCount].value = text
    template.parts[template.partCount].captureIndex = 0
    template.parts[template.partCount].name = ''
    set_length_array(template.parts, template.partCount)

    return true
}


/**
 * Add a capture group reference part to the template.
 *
 * @param {_NAVRegexTemplate} template - The template being built
 * @param {integer} index - The capture group index (1-99, or 0 for full match)
 * @returns {char} TRUE if part added successfully, FALSE if template full
 */
define_function char NAVRegexTemplateAddCaptureRef(_NAVRegexTemplate template,
                                                     integer index) {
    if (template.partCount >= MAX_REGEX_TEMPLATE_PARTS) {
        return false
    }

    template.partCount++

    if (index == 0) {
        // $0 is treated as full match reference
        template.parts[template.partCount].type = REGEX_TEMPLATE_FULL_MATCH
    }
    else {
        template.parts[template.partCount].type = REGEX_TEMPLATE_CAPTURE_REF
    }

    template.parts[template.partCount].value = ''
    template.parts[template.partCount].captureIndex = index
    template.parts[template.partCount].name = ''
    set_length_array(template.parts, template.partCount)

    return true
}


/**
 * Add a full match reference part to the template ($&).
 *
 * @param {_NAVRegexTemplate} template - The template being built
 * @returns {char} TRUE if part added successfully, FALSE if template full
 */
define_function char NAVRegexTemplateAddFullMatch(_NAVRegexTemplate template) {
    if (template.partCount >= MAX_REGEX_TEMPLATE_PARTS) {
        return false
    }

    template.partCount++
    template.parts[template.partCount].type = REGEX_TEMPLATE_FULL_MATCH
    template.parts[template.partCount].value = ''
    template.parts[template.partCount].captureIndex = 0
    template.parts[template.partCount].name = ''
    set_length_array(template.parts, template.partCount)

    return true
}


/**
 * Add a named capture group reference part to the template.
 *
 * @param {_NAVRegexTemplate} template - The template being built
 * @param {char[]} name - The named group identifier
 * @returns {char} TRUE if part added successfully, FALSE if template full
 */
define_function char NAVRegexTemplateAddNamedRef(_NAVRegexTemplate template,
                                                   char name[]) {
    if (template.partCount >= MAX_REGEX_TEMPLATE_PARTS) {
        return false
    }

    template.partCount++
    template.parts[template.partCount].type = REGEX_TEMPLATE_NAMED_REF
    template.parts[template.partCount].value = ''
    template.parts[template.partCount].captureIndex = 0
    template.parts[template.partCount].name = name
    set_length_array(template.parts, template.partCount)

    return true
}


/**
 * Add a literal dollar sign part to the template ($$).
 *
 * @param {_NAVRegexTemplate} template - The template being built
 * @returns {char} TRUE if part added successfully, FALSE if template full
 */
define_function char NAVRegexTemplateAddDollar(_NAVRegexTemplate template) {
    if (template.partCount >= MAX_REGEX_TEMPLATE_PARTS) {
        return false
    }

    template.partCount++
    template.parts[template.partCount].type = REGEX_TEMPLATE_DOLLAR
    template.parts[template.partCount].value = '$'
    template.parts[template.partCount].captureIndex = 0
    template.parts[template.partCount].name = ''
    set_length_array(template.parts, template.partCount)

    return true
}


// ============================================================================
// MAIN TEMPLATE PARSER
// ============================================================================

/**
 * Parse a replacement template string into structured parts.
 *
 * This is the main entry point for template parsing. It processes the
 * template string character by character, identifying substitution markers
 * and literal text segments.
 *
 * Supported syntax:
 * - $1, $2, $3, ... $99 : Numbered capture groups
 * - $0, $& : Full match text
 * - ${name} : Named capture group (brace syntax)
 * - $<name> : Named capture group (angle bracket syntax)
 * - $$ : Literal dollar sign
 * - Regular text : Literal text (copied as-is)
 *
 * Invalid syntax ($ not followed by valid marker) is treated as literal $.
 *
 * @param {char[]} templateStr - The replacement template string to parse
 * @param {_NAVRegexTemplate} template - Output structure to populate
 * @returns {char} TRUE if parsing succeeded, FALSE on error
 */
define_function char NAVRegexTemplateParse(char templateStr[],
                                            _NAVRegexTemplate template) {
    stack_var integer pos
    stack_var integer len
    stack_var char c
    stack_var char nextChar
    stack_var char literalBuffer[MAX_REGEX_TEMPLATE_LITERAL_LENGTH]
    stack_var integer captureNum
    stack_var char identifier[MAX_REGEX_TEMPLATE_NAME_LENGTH]
    stack_var integer startPos

    // Initialize template
    template.partCount = 0
    literalBuffer = ''

    len = length_array(templateStr)
    pos = 1

    while (pos <= len) {
        c = templateStr[pos]

        if (c == '$') {
            // Found a substitution marker

            // Save any accumulated literal text first
            if (length_array(literalBuffer) > 0) {
                if (!NAVRegexTemplateAddLiteral(template, literalBuffer)) {
                    return false  // Template full
                }
                literalBuffer = ''
            }

            pos++  // Move past $

            if (pos > len) {
                // $ at end of string - treat as literal
                literalBuffer = '$'
                break
            }

            nextChar = templateStr[pos]

            // Process substitution type
            select {
                // $$ - Literal dollar sign
                active (nextChar == '$'): {
                    if (!NAVRegexTemplateAddDollar(template)) {
                        return false
                    }
                    pos++
                }

                // $& - Full match reference
                active (nextChar == '&'): {
                    if (!NAVRegexTemplateAddFullMatch(template)) {
                        return false
                    }
                    pos++
                }

                // $0-$99 - Numbered capture group
                active (NAVRegexTemplateIsDigit(nextChar)): {
                    startPos = pos
                    captureNum = NAVRegexTemplateParseNumber(templateStr, pos)

                    if (captureNum >= 0 && captureNum <= 99) {
                        if (!NAVRegexTemplateAddCaptureRef(template, captureNum)) {
                            return false
                        }
                    }
                    else {
                        // Invalid number, treat as literal
                        literalBuffer = "'$', NAVStringSubstring(templateStr, startPos, pos - startPos)"
                    }
                }

                // ${name} - Named group (brace syntax)
                active (nextChar == '{'): {
                    stack_var integer closeBracePos
                    stack_var char foundClose

                    pos++  // Move past {
                    startPos = pos

                    // Extract identifier
                    if (NAVRegexTemplateExtractIdentifier(templateStr, pos, identifier)) {
                        // Check for closing brace
                        if (pos <= len && templateStr[pos] == '}') {
                            if (!NAVRegexTemplateAddNamedRef(template, identifier)) {
                                return false
                            }
                            pos++  // Move past }
                        }
                        else {
                            // No closing brace, treat as literal
                            literalBuffer = "'$', NAVStringSubstring(templateStr, startPos - 2, pos - startPos + 2)"
                        }
                    }
                    else {
                        // Invalid identifier, treat as literal
                        literalBuffer = "'${'"
                    }
                }

                // $<name> - Named group (angle bracket syntax)
                active (nextChar == '<'): {
                    pos++  // Move past <
                    startPos = pos

                    // Extract identifier
                    if (NAVRegexTemplateExtractIdentifier(templateStr, pos, identifier)) {
                        // Check for closing angle bracket
                        if (pos <= len && templateStr[pos] == '>') {
                            if (!NAVRegexTemplateAddNamedRef(template, identifier)) {
                                return false
                            }
                            pos++  // Move past >
                        }
                        else {
                            // No closing bracket, treat as literal
                            literalBuffer = "'$', NAVStringSubstring(templateStr, startPos - 2, pos - startPos + 2)"
                        }
                    }
                    else {
                        // Invalid identifier, treat as literal
                        literalBuffer = "'$<'"
                    }
                }

                // Unknown escape - treat $ as literal
                active (1): {
                    literalBuffer = "'$', nextChar"
                    pos++
                }
            }
        }
        else {
            // Regular character - add to literal buffer
            literalBuffer = "literalBuffer, c"
            pos++
        }
    }

    // Add any remaining literal text
    if (length_array(literalBuffer) > 0) {
        if (!NAVRegexTemplateAddLiteral(template, literalBuffer)) {
            return false
        }
    }

    return true
}


// ============================================================================
// TEMPLATE APPLICATION
// ============================================================================

/**
 * Apply a parsed template to a match result, producing the replacement text.
 *
 * This function takes a parsed template and a match result, then substitutes
 * all capture group references with their actual captured text to produce
 * the final replacement string.
 *
 * Substitution behavior:
 * - LITERAL: Text copied as-is
 * - DOLLAR: Literal '$' character
 * - FULL_MATCH: Full matched text from match.fullMatch.text
 * - CAPTURE_REF: Numbered group text from match.groups[index].text
 * - NAMED_REF: Named group text (looked up by name)
 *
 * Invalid references (non-existent groups) are replaced with empty string.
 *
 * @param {_NAVRegexTemplate} template - The parsed template
 * @param {_NAVRegexMatchResult} match - The match result with captures
 * @param {char[]} output - Output buffer for the replacement text
 *
 * @returns {char} TRUE if successful, FALSE if output buffer overflow
 */
define_function char NAVRegexTemplateApply(_NAVRegexTemplate template,
                                            _NAVRegexMatchResult match,
                                            char output[]) {
    stack_var integer i
    stack_var _NAVRegexTemplatePart part
    stack_var _NAVRegexGroup namedGroup

    #IF_DEFINED REGEX_TEMPLATE_DEBUG
    NAVLog("'[ Template Apply ]: Applying template with ', itoa(template.partCount), ' parts'")
    NAVLog("'[ Template Apply ]: Match has ', itoa(match.groupCount), ' capture groups'")
    #END_IF

    output = ''

    // Process each template part
    for (i = 1; i <= template.partCount; i++) {
        part = template.parts[i]

        #IF_DEFINED REGEX_TEMPLATE_DEBUG
        NAVLog("'[ Template Apply ]: Processing part ', itoa(i), ': ',
               NAVRegexTemplatePartTypeName(part.type)")
        #END_IF

        select {
            // Literal text - copy as-is
            active (part.type == REGEX_TEMPLATE_LITERAL): {
                output = "output, part.value"

                #IF_DEFINED REGEX_TEMPLATE_DEBUG
                NAVLog("'[ Template Apply ]:   Added literal: "', part.value, '"'")
                #END_IF
            }

            // Literal dollar sign - append $
            active (part.type == REGEX_TEMPLATE_DOLLAR): {
                output = "output, '$'"

                #IF_DEFINED REGEX_TEMPLATE_DEBUG
                NAVLog("'[ Template Apply ]:   Added dollar: $'")
                #END_IF
            }

            // Full match reference - append entire match
            active (part.type == REGEX_TEMPLATE_FULL_MATCH): {
                output = "output, match.fullMatch.text"

                #IF_DEFINED REGEX_TEMPLATE_DEBUG
                NAVLog("'[ Template Apply ]:   Added full match: "', match.fullMatch.text, '"'")
                #END_IF
            }

            // Numbered capture group reference
            active (part.type == REGEX_TEMPLATE_CAPTURE_REF): {
                // Validate group exists and was captured
                if (part.captureIndex > 0 &&
                    part.captureIndex <= match.groupCount &&
                    match.groups[part.captureIndex].isCaptured) {

                    output = "output, match.groups[part.captureIndex].text"

                    #IF_DEFINED REGEX_TEMPLATE_DEBUG
                    NAVLog("'[ Template Apply ]:   Added capture group ', itoa(part.captureIndex),
                           ': "', match.groups[part.captureIndex].text, '"'")
                    #END_IF
                }
                else {
                    // Group doesn't exist or wasn't captured - substitute empty string
                    #IF_DEFINED REGEX_TEMPLATE_DEBUG
                    NAVLog("'[ Template Apply ]:   Capture group ', itoa(part.captureIndex),
                           ' not found - substituting empty string'")
                    #END_IF
                }
            }

            // Named capture group reference
            active (part.type == REGEX_TEMPLATE_NAMED_REF): {
                // Use existing helper to find named group
                // NOTE: This function is defined in NAVFoundation.Regex.axi
                // We'll need to make sure it's accessible or move it
                if (NAVRegexGetNamedGroupFromMatch(match, part.name, namedGroup)) {
                    output = "output, namedGroup.text"

                    #IF_DEFINED REGEX_TEMPLATE_DEBUG
                    NAVLog("'[ Template Apply ]:   Added named group "', part.name,
                           '": "', namedGroup.text, '"'")
                    #END_IF
                }
                else {
                    // Named group not found - substitute empty string
                    #IF_DEFINED REGEX_TEMPLATE_DEBUG
                    NAVLog("'[ Template Apply ]:   Named group "', part.name,
                           '" not found - substituting empty string'")
                    #END_IF
                }
            }
        }
    }

    #IF_DEFINED REGEX_TEMPLATE_DEBUG
    NAVLog("'[ Template Apply ]: Final output: "', output, '"'")
    #END_IF

    return true
}


// ============================================================================
// TEMPLATE DEBUGGING AND UTILITIES
// ============================================================================

/**
 * Get a string representation of a template part type.
 *
 * @param {integer} type - The part type constant
 * @returns {char[]} String name of the type
 */
define_function char[30] NAVRegexTemplatePartTypeName(integer type) {
    select {
        active (type == REGEX_TEMPLATE_LITERAL):        return 'LITERAL'
        active (type == REGEX_TEMPLATE_CAPTURE_REF):    return 'CAPTURE_REF'
        active (type == REGEX_TEMPLATE_FULL_MATCH):     return 'FULL_MATCH'
        active (type == REGEX_TEMPLATE_NAMED_REF):      return 'NAMED_REF'
        active (type == REGEX_TEMPLATE_DOLLAR):         return 'DOLLAR'
        active (1):                                      return 'UNKNOWN'
    }
}


/**
 * Print debug information about a parsed template.
 *
 * @param {_NAVRegexTemplate} template - The template to debug
 */
define_function NAVRegexTemplatePrintDebug(_NAVRegexTemplate template) {
    stack_var integer i
    stack_var _NAVRegexTemplatePart part

    NAVLog("'[ Template Debug ]: Part count: ', itoa(template.partCount)")

    for (i = 1; i <= template.partCount; i++) {
        part = template.parts[i]

        NAVLog("'[ Template Debug ]: Part ', itoa(i), ': ',
               NAVRegexTemplatePartTypeName(part.type)")

        select {
            active (part.type == REGEX_TEMPLATE_LITERAL): {
                NAVLog("'    Value: "', part.value, '"'")
            }
            active (part.type == REGEX_TEMPLATE_CAPTURE_REF): {
                NAVLog("'    Capture Index: ', itoa(part.captureIndex)")
            }
            active (part.type == REGEX_TEMPLATE_NAMED_REF): {
                NAVLog("'    Name: "', part.name, '"'")
            }
            active (part.type == REGEX_TEMPLATE_DOLLAR): {
                NAVLog("'    Dollar: $$'")
            }
        }
    }
}


#END_IF // __NAV_FOUNDATION_REGEX_TEMPLATE__
