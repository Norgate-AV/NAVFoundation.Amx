PROGRAM_NAME='NAVFoundation.Regex.h'

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
 * Regex Shared Constants
 *
 * This header file contains constants that are shared across multiple
 * components of the regex engine (Lexer, Parser, and Matcher).
 * These constants define fundamental limits and configurations that
 * affect all three phases of regex compilation and execution.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_H__
#DEFINE __NAV_FOUNDATION_REGEX_H__ 'NAVFoundation.Regex.h'


DEFINE_CONSTANT

// ============================================================================
// SHARED REGEX CONSTANTS
// ============================================================================

/**
 * Maximum length of regex pattern string.
 *
 * This defines the maximum size for:
 * - Pattern strings passed to regex functions
 * - The originalPattern field stored in compiled NFA
 *
 * Value of 255 is sufficient for typical real-world patterns:
 * - Email validation: ~100 characters
 * - URL validation: ~150 characters
 * - Date/time formats: ~50 characters
 * - Complex validation patterns: ~200 characters
 *
 * Keeps memory footprint minimal while supporting realistic use cases.
 */
#IF_NOT_DEFINED MAX_REGEX_PATTERN_LENGTH
constant integer MAX_REGEX_PATTERN_LENGTH = 255
#END_IF

/**
 * Maximum length of input strings to match against.
 *
 * This defines the maximum size for:
 * - Input strings passed to regex matching functions
 * - The inputString field stored in matcher state
 *
 * Set to 65535 (NetLinx maximum string length) to support:
 * - Large text processing
 * - File content matching
 * - Multi-line text matching
 * - Large data validation
 *
 * WARNING: Large buffers increase memory usage. Each matcher state
 * will allocate this much memory for input string storage.
 */
#IF_NOT_DEFINED MAX_REGEX_INPUT_LENGTH
constant integer MAX_REGEX_INPUT_LENGTH = 65535
#END_IF

/**
 * Maximum number of character ranges in a character class.
 *
 * This constant is shared between:
 * - Lexer: Defines the size of the ranges array in _NAVRegexCharClass structure
 * - Parser: Defines the size of the ranges array in _NAVNfaState for char class states
 * - Matcher: Used when evaluating character class matches
 *
 * Each range represents a min-max pair (e.g., 'a'-'z' is one range).
 * Most practical character classes use far fewer than 64 ranges.
 *
 * Examples:
 *   [a-z]           = 1 range
 *   [a-zA-Z0-9]     = 3 ranges
 *   [!-~]           = 1 range (all printable ASCII)
 *   [a-zA-Z0-9_-]   = 4 ranges
 */
#IF_NOT_DEFINED MAX_REGEX_CHAR_RANGES
constant integer MAX_REGEX_CHAR_RANGES = 64
#END_IF

/**
 * Maximum number of groups (capturing and non-capturing).
 *
 * This limits how many parenthesized groups (both capturing and
 * non-capturing) can appear in a single pattern.
 *
 * 32 groups is more than sufficient for virtually all practical regex use cases.
 */
#IF_NOT_DEFINED MAX_REGEX_GROUPS
constant integer MAX_REGEX_GROUPS = 32
#END_IF

/**
 * Maximum length of group names and backreference names.
 *
 * This constant is shared between:
 * - Lexer: Defines buffer sizes when parsing named groups and backreferences
 * - Parser: Defines the name field size in group tracking structures
 * - Matcher: Used when resolving named backreferences during matching
 *
 * This limits the length of:
 *   (?P<name>...)     Python-style named capturing group
 *   (?<name>...)      .NET-style named capturing group
 *   \k<name>          Named backreference
 *   \k'name'          Alternative named backreference syntax
 */
#IF_NOT_DEFINED MAX_REGEX_GROUP_NAME_LENGTH
constant integer MAX_REGEX_GROUP_NAME_LENGTH = 50
#END_IF

#END_IF // __NAV_FOUNDATION_REGEX_H__
