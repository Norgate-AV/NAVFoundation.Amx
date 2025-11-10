PROGRAM_NAME='NAVFoundation.RegexTemplate.h'

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
 * Regex Template Parser - Replacement String Processing
 *
 * This module handles parsing and processing of replacement templates
 * used in regex replace operations. It tokenizes replacement strings
 * containing capture group references and other substitution patterns.
 *
 * Supported replacement syntax:
 * - $1, $2, $3... = Numbered capture groups (1-99)
 * - $0 or $& = Full match text
 * - ${name} = Named capture group (brace syntax)
 * - $<name> = Named capture group (angle bracket syntax)
 * - $$ = Literal dollar sign
 * - Regular text = Literal text (no substitution)
 *
 * Examples:
 * - "Hello $1 World"        -> Literal + CaptureRef(1) + Literal
 * - "Price: $$$&"           -> Literal + Dollar + FullMatch
 * - "${year}-${month}"      -> NamedRef(year) + Literal + NamedRef(month)
 * - "Swap $2 and $1"        -> Literal + CaptureRef(2) + Literal + CaptureRef(1)
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_TEMPLATE_H__
#DEFINE __NAV_FOUNDATION_REGEX_TEMPLATE_H__ 'NAVFoundation.RegexTemplate.h'

#include 'NAVFoundation.Core.h.axi'


DEFINE_CONSTANT

// ============================================================================
// TEMPLATE CONSTANTS
// ============================================================================

/**
 * Maximum number of template parts (tokens) in a replacement string.
 *
 * Each part represents either a literal text segment or a substitution
 * reference ($1, $&, ${name}, etc.). A complex template like:
 * "Before $1 middle $2 after" would have 5 parts.
 *
 * Value of 100 allows for very complex replacement templates.
 */
#IF_NOT_DEFINED MAX_REGEX_TEMPLATE_PARTS
constant integer MAX_REGEX_TEMPLATE_PARTS = 100
#END_IF

/**
 * Maximum length of a literal text segment in a template.
 *
 * This is the maximum length of continuous text between substitutions.
 * For example, in "Hello World $1", "Hello World " is one literal part.
 */
#IF_NOT_DEFINED MAX_REGEX_TEMPLATE_LITERAL_LENGTH
constant integer MAX_REGEX_TEMPLATE_LITERAL_LENGTH = 200
#END_IF

/**
 * Maximum length of a named capture group identifier.
 *
 * Used for ${name} and $<name> syntax. Controls the maximum length
 * of the group name identifier.
 */
#IF_NOT_DEFINED MAX_REGEX_TEMPLATE_NAME_LENGTH
constant integer MAX_REGEX_TEMPLATE_NAME_LENGTH = 50
#END_IF


// ============================================================================
// TEMPLATE PART TYPES
// ============================================================================

/**
 * Template part type constants.
 *
 * These define the different types of components that can appear in
 * a replacement template after parsing.
 */

constant integer REGEX_TEMPLATE_NONE            = 0   // No part / Not set
constant integer REGEX_TEMPLATE_LITERAL         = 1   // Literal text (no substitution)
constant integer REGEX_TEMPLATE_CAPTURE_REF     = 2   // $1, $2, $3... (numbered capture)
constant integer REGEX_TEMPLATE_FULL_MATCH      = 3   // $0 or $& (full match text)
constant integer REGEX_TEMPLATE_NAMED_REF       = 4   // ${name} or $<name> (named capture)
constant integer REGEX_TEMPLATE_DOLLAR          = 5   // $$ (literal dollar sign)


// ============================================================================
// TEMPLATE DATA STRUCTURES
// ============================================================================

/**
 * Represents a single part (token) of a parsed replacement template.
 *
 * After parsing a template like "Hello $1 and ${name}", we get:
 * - Part 1: type=LITERAL, value="Hello "
 * - Part 2: type=CAPTURE_REF, captureIndex=1
 * - Part 3: type=LITERAL, value=" and "
 * - Part 4: type=NAMED_REF, name="name"
 */
DEFINE_TYPE

struct _NAVRegexTemplatePart {
    integer type                                        // Part type (REGEX_TEMPLATE_*)

    // For LITERAL and DOLLAR types
    char value[MAX_REGEX_TEMPLATE_LITERAL_LENGTH]      // Literal text content

    // For CAPTURE_REF type
    integer captureIndex                                // Capture group number (1-99)

    // For NAMED_REF type
    char name[MAX_REGEX_TEMPLATE_NAME_LENGTH]          // Named group identifier
}


/**
 * Represents a fully parsed replacement template.
 *
 * Contains an array of template parts that can be processed to
 * construct the final replacement string given match results.
 */
struct _NAVRegexTemplate {
    _NAVRegexTemplatePart parts[MAX_REGEX_TEMPLATE_PARTS]  // Array of template parts
    integer partCount                                        // Number of parts in template
}


#END_IF // __NAV_FOUNDATION_REGEX_TEMPLATE_H__
