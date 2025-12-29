PROGRAM_NAME='NAVFoundation.RegexLexer.h'

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
 * Regex Lexer - Tokenization Phase
 *
 * Converts a regex pattern string into a stream of tokens.
 * This is the first phase of regex compilation.
 */


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_LEXER_H__
#DEFINE __NAV_FOUNDATION_REGEX_LEXER_H__ 'NAVFoundation.RegexLexer.h'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.Regex.h.axi'


DEFINE_CONSTANT

/**
 * Maximum number of tokens that can be generated from a pattern.
 *
 * This limits the complexity of regex patterns. Each character, operator,
 * group, quantifier, etc. generates one or more tokens.
 */
#IF_NOT_DEFINED MAX_REGEX_TOKENS
constant integer MAX_REGEX_TOKENS = 200
#END_IF

/**
 * Maximum length of character class content (e.g., [a-zA-Z0-9]).
 *
 * NOTE: This constant is maintained for backward compatibility with
 * legacy regex code. The new lexer uses a ranges-based structure
 * (max 50 ranges per character class) instead of raw string storage.
 */
#IF_NOT_DEFINED MAX_CHAR_CLASS_LENGTH
constant integer MAX_CHAR_CLASS_LENGTH = 40
#END_IF


// ============================================================================
// TOKEN TYPES
// ============================================================================
/**
 * Token type constants for the regex lexer.
 *
 * These represent all the different types of tokens the lexer can produce
 * during the tokenization phase. Each regex construct (character, operator,
 * group, quantifier, etc.) is represented by a unique token type.
 */

constant integer REGEX_TOKEN_NONE                       = 0   // No token / Not set
constant integer REGEX_TOKEN_EOF                        = 1   // End of token stream
constant integer REGEX_TOKEN_DOT                        = 2   // .
constant integer REGEX_TOKEN_BEGIN                      = 3   // ^
constant integer REGEX_TOKEN_END                        = 4   // $
constant integer REGEX_TOKEN_QUESTIONMARK               = 5   // ?
constant integer REGEX_TOKEN_STAR                       = 6   // *
constant integer REGEX_TOKEN_PLUS                       = 7   // +
constant integer REGEX_TOKEN_CHAR                       = 8   // Literal character
constant integer REGEX_TOKEN_CHAR_CLASS                 = 9   // [abc]
constant integer REGEX_TOKEN_INV_CHAR_CLASS             = 10  // [^abc]
constant integer REGEX_TOKEN_DIGIT                      = 11  // \d
constant integer REGEX_TOKEN_NOT_DIGIT                  = 12  // \D
constant integer REGEX_TOKEN_ALPHA                      = 13  // \w (word char)
constant integer REGEX_TOKEN_NOT_ALPHA                  = 14  // \W
constant integer REGEX_TOKEN_WHITESPACE                 = 15  // \s
constant integer REGEX_TOKEN_NOT_WHITESPACE             = 16  // \S
constant integer REGEX_TOKEN_ALTERNATION                = 17  // | (or/union operator)
constant integer REGEX_TOKEN_GROUP                      = 18  // (deprecated)
constant integer REGEX_TOKEN_QUANTIFIER                 = 19  // {n,m}
constant integer REGEX_TOKEN_ESCAPE                     = 20  // \ (deprecated)
constant integer REGEX_TOKEN_EPSILON                    = 21  // Empty
constant integer REGEX_TOKEN_WORD_BOUNDARY              = 22  // \b
constant integer REGEX_TOKEN_NOT_WORD_BOUNDARY          = 23  // \B
constant integer REGEX_TOKEN_HEX                        = 24  // \x
constant integer REGEX_TOKEN_NEWLINE                    = 25  // \n
constant integer REGEX_TOKEN_RETURN                     = 26  // \r
constant integer REGEX_TOKEN_TAB                        = 27  // \t
constant integer REGEX_TOKEN_FORMFEED                   = 28  // \f
constant integer REGEX_TOKEN_VTAB                       = 29  // \v
constant integer REGEX_TOKEN_BELL                       = 30  // \a
constant integer REGEX_TOKEN_ESC                        = 31  // \e
constant integer REGEX_TOKEN_GROUP_START                = 32  // (
constant integer REGEX_TOKEN_GROUP_END                  = 33  // )
constant integer REGEX_TOKEN_LOOKAHEAD_POSITIVE         = 34  // (?=...)
constant integer REGEX_TOKEN_LOOKAHEAD_NEGATIVE         = 35  // (?!...)
constant integer REGEX_TOKEN_LOOKBEHIND_POSITIVE        = 36  // (?<=...)
constant integer REGEX_TOKEN_LOOKBEHIND_NEGATIVE        = 37  // (?<!...)
constant integer REGEX_TOKEN_BACKREF_NAMED              = 38  // \k<name> (named backreference)
constant integer REGEX_TOKEN_NUMERIC_ESCAPE             = 39  // \1-\999 (ambiguous: could be octal or backref - parser decides)

/**
 * String anchor tokens.
 *
 * More precise than ^ and $ anchors:
 * - \A: Always matches at start of string (not affected by multiline mode)
 * - \Z: Matches before final newline or at end of string
 * - \z: Matches only at absolute end of string
 */
constant integer REGEX_TOKEN_STRING_START               = 40  // \A (always start of string)
constant integer REGEX_TOKEN_STRING_END                 = 41  // \Z (before final newline)
constant integer REGEX_TOKEN_STRING_END_ABSOLUTE        = 42  // \z (absolute end)

/**
 * Inline flag/modifier tokens.
 *
 * These enable or disable matching modes within the pattern:
 * - (?i): Case-insensitive matching
 * - (?m): Multiline mode (^ and $ match line boundaries)
 * - (?s): Dotall mode (. matches newlines)
 * - (?x): Extended mode (ignore whitespace, allow comments)
 */
constant integer REGEX_TOKEN_FLAG_CASE_INSENSITIVE      = 43  // (?i) or (?-i)
constant integer REGEX_TOKEN_FLAG_MULTILINE             = 44  // (?m) or (?-m)
constant integer REGEX_TOKEN_FLAG_DOTALL                = 45  // (?s) or (?-s)
constant integer REGEX_TOKEN_FLAG_EXTENDED              = 46  // (?x) or (?-x)

/**
 * Other special tokens.
 */
constant integer REGEX_TOKEN_COMMENT                    = 47  // (?#comment)


DEFINE_TYPE

// ============================================================================
// CHARACTER CLASS
// ============================================================================
/**
 * @struct _NAVRegexCharClassRange
 * @description A single character range within a character class.
 *
 * Represents either a single character or a range of characters.
 *
 * Examples:
 * - Single char 'a': start='a', end='a'
 * - Range 'a-z': start='a', end='z'
 * - Range '0-9': start='0', end='9'
 */
struct _NAVRegexCharClassRange {
    char start          // Start of range (inclusive)
    char end            // End of range (inclusive)
}

/**
 * @struct _NAVRegexCharClass
 * @description Fully parsed character class ready for NFA construction.
 *
 * Character classes define sets of characters to match. The lexer fully
 * parses them into ranges and predefined character classes so the parser
 * can directly build NFA transitions without re-parsing.
 *
 * Examples:
 * - [abc]: rangeCount=3, ranges=[a-a, b-b, c-c]
 * - [a-z0-9]: rangeCount=2, ranges=[a-z, 0-9]
 * - [a-z\d]: rangeCount=1, ranges=[a-z], hasDigits=true
 * - [\w\s]: hasWordChars=true, hasWhitespace=true
 * - [^abc]: token.isNegated=true, rangeCount=3, ranges=[a-a, b-b, c-c]
 *
 * Note: Negation is stored in token.isNegated, not in the charclass struct.
 */
struct _NAVRegexCharClass {
    // Explicit character ranges
    integer rangeCount
    _NAVRegexCharClassRange ranges[50]  // Explicit ranges like a-z, 0-9, or single chars

    // Predefined character classes (can be combined with ranges)
    char hasDigits              // Contains \d (digits: 0-9)
    char hasNonDigits           // Contains \D (non-digits: anything except 0-9)
    char hasWordChars           // Contains \w (word characters: a-z, A-Z, 0-9, _)
    char hasNonWordChars        // Contains \W (non-word characters)
    char hasWhitespace          // Contains \s (whitespace: space, tab, newline, etc.)
    char hasNonWhitespace       // Contains \S (non-whitespace)
}


// ============================================================================
// GROUP INFORMATION
// ============================================================================
/**
 * @struct _NAVRegexGroupInfo
 * @description Metadata about groups (capturing and non-capturing).
 *
 * Groups are created with parentheses in patterns:
 * - Capturing group: (pattern) - captures matched text
 * - Non-capturing group: (?:pattern) - groups without capturing
 * - Named group: (?P<name>pattern) or (?<name>pattern)
 * - Global flag group: (?i), (?im), etc. - flags apply from this point forward
 * - Scoped flag group: (?i:pattern), (?im:pattern) - flags apply only within group
 */
struct _NAVRegexGroupInfo {
    integer number          // Group number (1, 2, 3...) - only for capturing groups
    char name[MAX_REGEX_GROUP_NAME_LENGTH]          // Group name (empty for unnamed/non-capturing groups)
    char isNamed           // Boolean: is this a named group?
    char isCapturing       // Boolean: true for (), false for (?:)
    integer startToken     // Token index where group starts (GROUP_START)
    integer endToken       // Token index where group ends (GROUP_END)

    // Flag group classification (for inline flag support)
    char isFlagGroup        // Boolean: true if group contains flags (?i), (?i:...), etc.
    char isGlobalFlagGroup  // Boolean: true for (?i), (?-i), (?im) - flags apply globally from this point
    char isScopedFlagGroup  // Boolean: true for (?i:...), (?-i:...) - flags scoped to group content only
    char hasColon           // Boolean: true if ':' found after flags - lexer observation for validation
}


// ============================================================================
// TOKEN
// ============================================================================
/**
 * @struct _NAVRegexToken
 * @description A single token produced by the lexer.
 *
 * Tokens represent the atomic elements of a regex pattern after lexical
 * analysis. Each token has a type and may have associated data depending
 * on the type (e.g., character value, quantifier bounds, group info).
 *
 * The lexer's job is to identify and classify tokens. The parser will
 * handle structural analysis (like matching quantifiers to their targets).
 */
struct _NAVRegexToken {
    integer type                    // Token type (REGEX_TOKEN_*)

    // Character data
    char value                  // Character value (for CHAR, HEX, OCTAL, NEWLINE, TAB, RETURN tokens)
    _NAVRegexCharClass charclass    // Parsed character class (for CHAR_CLASS/INV_CHAR_CLASS tokens)

    // Quantifier bounds (for QUANTIFIER, QUESTIONMARK, STAR, PLUS tokens)
    sinteger min                    // Minimum repetitions
    sinteger max                    // Maximum repetitions (-1 = unlimited)

    // Quantifier/matching modifiers
    char isLazy                     // Is this a lazy/non-greedy quantifier? (e.g., *?, +?, ??, {n,m}?)
    char isNegated                  // Is this negated? (for char classes [^...], lookahead (?!...), lookbehind (?<!...))

    // Named references (for named backreferences \k<name>)
    // Used only for BACKREF_NAMED tokens - stores the name being referenced
    char name[MAX_REGEX_GROUP_NAME_LENGTH]  // Backreference name: \k<name>

    // Embedded group information (populated for GROUP_START/GROUP_END tokens)
    // Contains complete group metadata including number, name, isCapturing, isNamed, etc.
    _NAVRegexGroupInfo groupInfo    // Complete group metadata embedded in token

    // Numeric escape metadata (for NUMERIC_ESCAPE tokens)
    // The lexer stores the raw digit string without any interpretation or validation.
    // Parser will validate length, interpret as octal/backreference, and handle errors.
    char numericEscapeDigits[10]    // Raw digit string (e.g., "10", "377", "12345678")
    char numericEscapeLeadingZero   // True if escape started with \0 (e.g., \0, \01, \012)

    // Flag state (for FLAG tokens)
    char flagEnabled                // True to enable flag, false to disable (for (?i) vs (?-i) syntax)
}


// ============================================================================
// PATTERN
// ============================================================================
/**
 * @struct _NAVRegexPattern
 * @description The input pattern string being lexed.
 *
 * Stores the regex pattern and tracks the current position during
 * tokenization.
 */
struct _NAVRegexPattern {
    char value[MAX_REGEX_PATTERN_LENGTH]     // The pattern string
    integer length      // Length of pattern
    integer cursor      // Current position in pattern
}


// ============================================================================
// LEXER STATE
// ============================================================================
/**
 * @struct _NAVRegexLexer
 * @description Main lexer structure holding all state during tokenization.
 *
 * This structure contains everything needed to tokenize a regex pattern:
 * - The input pattern
 * - Generated tokens
 * - Group tracking information
 * - Current parsing state
 */
struct _NAVRegexLexer {
    _NAVRegexPattern pattern        // Input pattern

    // Global flags (extracted from /pattern/flags syntax)
    // e.g., /\d+/gi → globalFlags = "gi"
    // Stored as string for parser to interpret
    char globalFlags[10]            // Global flags: i, m, s, g, x

    integer tokenCount              // Number of tokens generated
    _NAVRegexToken tokens[MAX_REGEX_TOKENS]  // Token array

    // Group tracking (internal state during lexing - for validation and nesting)
    integer groupCount              // Total capturing groups (numbered groups)
    integer groupTotal              // Total all groups (capturing + non-capturing)
    integer groupDepth              // Current nesting depth
    integer groupStack[MAX_REGEX_GROUPS]  // Stack of open groups (stores groupTotal indices)

    // Debugging
    char debug                      // Enable debug output
}


#END_IF // __NAV_FOUNDATION_REGEX_LEXER_H__
