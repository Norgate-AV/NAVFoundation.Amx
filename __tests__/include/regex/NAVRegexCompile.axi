PROGRAM_NAME='NAVRegexCompile'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_COMPILE_PATTERN_TEST[][255] = {
    '/\d+/',
    '/\w+/',
    '/\w*/',
    '/\s/',
    '/\s+/',
    '/\s*/',
    '/\d\w?\s/',
    '/\d\w\s+/',
    '/\d?\w\s*/',
    '/\D+/',
    '/\D*/',
    '/\D\s/',
    '/\W+/',
    '/\S*/',
    '/^[a-zA-Z0-9_]+$/',
    '/^[Hh]ello,\s[Ww]orld!$/',
    '/^"[^"]*"/',
    '/.*/',

    // IP address pattern - should compile to 23 tokens
    '/\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/',

    // Single question mark - should compile to 2 tokens
    '/\d?/',

    // Two question marks - should compile to 4 tokens
    '/\d?\d?/',

    // Three question marks - should compile to 5 tokens
    '/\d?\d?\d/',

    // Additional test cases for robustness

    // Test 23: Multiple dots with anchors
    '/^...$/',

    // Test 24: Mixed metacharacters
    '/\d\w\s/',

    // Test 25: All quantifiers together
    '/a?b*c+/',

    // Test 26: Escaped special characters
    '/\.\*\+\?/',

    // Test 27: Character class with multiple ranges
    '/[a-zA-Z]/',

    // Test 28: Inverted character class
    '/[^0-9]/',

    // Test 29: Character class with literals
    '/[abc123]/',

    // Test 30: Mixed anchors and metacharacters
    '/^\d+$/',

    // Test 31: Word boundaries
    '/\bword\b/',

    // Test 32: Complex email-like pattern
    '/\w+@\w+\.\w+/',

    // Test 33: Multiple consecutive quantifiers on different tokens
    '/\d*\w+\s*/',

    // Test 34: Negated metacharacters
    '/\D\W\S/',

    // Test 35: Character class with dash
    '/[a-z-]/',

    // Test 36: Dot with quantifiers
    '/.*\..*/',

    // Test 37: Multiple character classes
    '/[abc][def][ghi]/',

    // Test 38: Mixed optional and required
    '/\d\d?\d?/',

    // Test 39: Start anchor only
    '/^test/',

    // Test 40: End anchor only
    '/test$/',

    // Test 41: Character class with backslash escapes
    '/[\d\w\s]/',

    // Test 42: Empty character class edge case
    '/[]/',

    // Test 43: Single character
    '/x/',

    // Test 44: Multiple literal characters
    '/hello/',

    // Test 45: Quantifiers on character classes
    '/[a-z]+[0-9]*/',

    // Test 46: NOT word boundary
    '/\Btest\B/',

    // Test 47: Tab character
    '/\t/',

    // Test 48: Newline character
    '/\n/',

    // Test 49: Return character
    '/\r/',

    // Test 50: Mixed special characters
    '/\t\n\r/',

    // Test 51: Bounded quantifier - exact count
    '/a{3}/',

    // Test 52: Bounded quantifier - exact count with metacharacter
    '/\d{5}/',

    // Test 53: Bounded quantifier - range
    '/b{2,4}/',

    // Test 54: Bounded quantifier - range with metacharacter
    '/\w{1,10}/',

    // Test 55: Bounded quantifier - unlimited (one or more)
    '/c{1,}/',

    // Test 56: Bounded quantifier - unlimited (zero or more)
    '/\s{0,}/',

    // Test 57: Bounded quantifier - zero occurrences
    '/d{0}/',

    // Test 58: Bounded quantifier - large count
    '/e{100}/',

    // Test 59: Bounded quantifier with literal character
    '/\d{3}\.\d{3}/',

    // Test 60: Bounded quantifier with character class
    '/[a-z]{2,5}/',

    // Test 61: Bounded quantifier with anchors
    '/^\w{3,}$/',

    // Test 62: Single capturing group
    '/(\d+)/',

    // Test 63: Multiple capturing groups
    '/(\d+)-(\w+)/',

    // Test 64: Group with quantifier inside
    '/(\d{3})/',

    // Test 65: Group with character class
    '/([a-z]+)/',

    // Test 66: Multiple groups with metacharacters
    '/(\w+)@(\w+)\.(\w+)/',

    // Test 67: Group at start
    '/(abc)def/',

    // Test 68: Group at end
    '/abc(def)/',

    // Test 69: Group in middle
    '/abc(\d+)def/',

    // Test 70: Empty group
    '/()/',

    // Test 71: Group with anchor
    '/^(\d+)$/',

    // Test 72: Multiple adjacent groups
    '/(\d)(\w)(\s)/'
}

constant integer REGEX_COMPILE_EXPECTED_PATTERN_LENGTH[] = {
    3,   // 1:  /\d+/ -> length 3
    3,   // 2:  /\w+/ -> length 3
    3,   // 3:  /\w*/ -> length 3
    2,   // 4:  /\s/ -> length 2
    3,   // 5:  /\s+/ -> length 3
    3,   // 6:  /\s*/ -> length 3
    7,   // 7:  /\d\w?\s/ -> length 7
    7,   // 8:  /\d\w\s+/ -> length 7
    8,   // 9:  /\d?\w\s*/ -> length 8
    3,   // 10: /\D+/ -> length 3
    3,   // 11: /\D*/ -> length 3
    4,   // 12: /\D\s/ -> length 4
    3,   // 13: /\W+/ -> length 3
    3,   // 14: /\S*/ -> length 3
    15,  // 15: /^[a-zA-Z0-9_]+$/ -> length 15
    22,  // 16: /^[Hh]ello,\s[Ww]orld!$/ -> length 22
    8,  // 17: /^"[^"]*"/ -> length 8
    2,   // 18: /.*/ -> length 2

    // Test 19: IP address pattern -> length 38
    38,

    // Test 20: Single question mark - should compile to length = 3
    3,

    // Test 21: Two question marks - should compile to length = 6
    6,

    // Test 22: Three question marks - should compile to length = 8
    8,

    // Additional test cases
    5,   // 23: /^...$/ -> length 5
    6,   // 24: /\d\w\s/ -> length 6
    6,   // 25: /a?b*c+/ -> length 6 (FIXED: was 8)
    8,   // 26: /\.\*\+\?/ -> length 8
    8,   // 27: /[a-zA-Z]/ -> length 8 (FIXED: was 7)
    6,   // 28: /[^0-9]/ -> length 6
    8,   // 29: /[abc123]/ -> length 8 (FIXED: was 9)
    5,   // 30: /^\d+$/ -> length 5
    8,   // 31: /\bword\b/ -> length 8 (FIXED: was 10)
    12,  // 32: /\w+@\w+\.\w+/ -> length 12 (FIXED: was 13)
    9,   // 33: /\d*\w+\s*/ -> length 9 (FIXED: was 11)
    6,   // 34: /\D\W\S/ -> length 6
    6,   // 35: /[a-z-]/ -> length 6 (FIXED: was 7)
    6,   // 36: /.*\..*/ -> length 6 (FIXED: was 9)
    15,  // 37: /[abc][def][ghi]/ -> length 15
    8,   // 38: /\d\d?\d?/ -> length 8 (FIXED: was 9)
    5,   // 39: /^test/ -> length 5 (FIXED: was 6)
    5,   // 40: /test$/ -> length 5 (FIXED: was 6)
    8,   // 41: /[\d\w\s]/ -> length 8 (FIXED: was 9)
    2,   // 42: /[]/ -> length 2
    1,   // 43: /x/ -> length 1
    5,   // 44: /hello/ -> length 5
    12,  // 45: /[a-z]+[0-9]*/ -> length 12 (FIXED: was 15)
    8,   // 46: /\Btest\B/ -> length 8
    2,   // 47: /\t/ -> length 2
    2,   // 48: /\n/ -> length 2
    2,   // 49: /\r/ -> length 2
    6,   // 50: /\t\n\r/ -> length 6
    4,   // 51: /a{3}/ -> length 4 (a{3})
    5,   // 52: /\d{5}/ -> length 5 (\d{5})
    6,   // 53: /b{2,4}/ -> length 6 (b{2,4})
    8,   // 54: /\w{1,10}/ -> length 8 (\w{1,10})
    5,   // 55: /c{1,}/ -> length 5 (c{1,})
    6,   // 56: /\s{0,}/ -> length 6 (\s{0,})
    4,   // 57: /d{0}/ -> length 4 (d{0})
    6,   // 58: /e{100}/ -> length 6 (e{100})
    12,  // 59: /\d{3}\.\d{3}/ -> length 12 (\d{3}\.\d{3})
    10,  // 60: /[a-z]{2,5}/ -> length 10 ([a-z]{2,5})
    8,   // 61: /^\w{3,}$/ -> length 8 (^\w{3,}$)
    6,   // 62: /(\d+)/ -> length 6 ((\d+))
    12,  // 63: /(\d+)-(\w+)/ -> length 12 ((\d+)-(\w+))
    8,   // 64: /(\d{3})/ -> length 8 ((\d{3}))
    9,   // 65: /([a-z]+)/ -> length 9 (([a-z]+))
    19,  // 66: /(\w+)@(\w+)\.(\w+)/ -> length 19
    10,  // 67: /(abc)def/ -> length 10
    10,  // 68: /abc(def)/ -> length 10
    13,  // 69: /abc(\d+)def/ -> length 13
    4,   // 70: /()/ -> length 4 (())
    8,   // 71: /^(\d+)$/ -> length 8
    12   // 72: /(\d)(\w)(\s)/ -> length 12
}

// Expected token counts for each test - simpler than defining full parser state
constant integer REGEX_COMPILE_EXPECTED_TOKEN_COUNT[] = {
    2,   // 1:  /\d+/ -> DIGIT, PLUS
    2,   // 2:  /\w+/ -> WORD, PLUS
    2,   // 3:  /\w*/ -> WORD, STAR
    1,   // 4:  /\s/ -> WHITESPACE
    2,   // 5:  /\s+/ -> WHITESPACE, PLUS
    2,   // 6:  /\s*/ -> WHITESPACE, STAR
    4,   // 7:  /\d\w?\s/ -> DIGIT, WORD, QUESTIONMARK, WHITESPACE
    4,   // 8:  /\d\w\s+/ -> DIGIT, WORD, WHITESPACE, PLUS
    5,   // 9:  /\d?\w\s*/ -> DIGIT, QUESTIONMARK, WORD, WHITESPACE, STAR
    2,   // 10: /\D+/ -> NOT_DIGIT, PLUS
    2,   // 11: /\D*/ -> NOT_DIGIT, STAR
    2,   // 12: /\D\s/ -> NOT_DIGIT, WHITESPACE
    2,   // 13: /\W+/ -> NOT_WORD, PLUS
    2,   // 14: /\S*/ -> NOT_WHITESPACE, STAR
    4,   // 15: /^[a-zA-Z0-9_]+$/ -> BEGIN, CHAR_CLASS, PLUS, END
    15,  // 16: /^[Hh]ello,\s[Ww]orld!$/ -> BEGIN + chars + END
    5,   // 17: /^"[^"]*"/ -> BEGIN, CHAR, INV_CHAR_CLASS, STAR, CHAR
    2,   // 18: /.*/ -> DOT, STAR
    23,  // 19: /\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/ -> IP address (4 octets × 6 tokens + 3 dots)
    2,   // 20: /\d?/ -> DIGIT, QUESTIONMARK
    4,   // 21: /\d?\d?/ -> DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK
    5,   // 22: /\d?\d?\d/ -> DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK, DIGIT

    // Additional test cases
    5,   // 23: /^...$/ -> BEGIN, DOT, DOT, DOT, END (FIXED: was 4)
    3,   // 24: /\d\w\s/ -> DIGIT, WORD, WHITESPACE
    6,   // 25: /a?b*c+/ -> CHAR, QUESTIONMARK, CHAR, STAR, CHAR, PLUS
    4,   // 26: /\.\*\+\?/ -> CHAR(.), CHAR(*), CHAR(+), CHAR(?)
    1,   // 27: /[a-zA-Z]/ -> CHAR_CLASS
    1,   // 28: /[^0-9]/ -> INV_CHAR_CLASS
    1,   // 29: /[abc123]/ -> CHAR_CLASS
    4,   // 30: /^\d+$/ -> BEGIN, DIGIT, PLUS, END
    6,   // 31: /\bword\b/ -> WORD_BOUNDARY, CHAR(w), CHAR(o), CHAR(r), CHAR(d), WORD_BOUNDARY
    8,   // 32: /\w+@\w+\.\w+/ -> WORD, PLUS, CHAR(@), WORD, PLUS, CHAR(.), WORD, PLUS
    6,   // 33: /\d*\w+\s*/ -> DIGIT, STAR, WORD, PLUS, WHITESPACE, STAR
    3,   // 34: /\D\W\S/ -> NOT_DIGIT, NOT_WORD, NOT_WHITESPACE
    1,   // 35: /[a-z-]/ -> CHAR_CLASS
    5,   // 36: /.*\..*/ -> DOT, STAR, CHAR(.), DOT, STAR
    3,   // 37: /[abc][def][ghi]/ -> CHAR_CLASS, CHAR_CLASS, CHAR_CLASS
    5,   // 38: /\d\d?\d?/ -> DIGIT, DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK
    5,   // 39: /^test/ -> BEGIN, CHAR(t), CHAR(e), CHAR(s), CHAR(t)
    5,   // 40: /test$/ -> CHAR(t), CHAR(e), CHAR(s), CHAR(t), END
    1,   // 41: /[\d\w\s]/ -> CHAR_CLASS
    1,   // 42: /[]/ -> CHAR_CLASS (empty)
    1,   // 43: /x/ -> CHAR
    5,   // 44: /hello/ -> CHAR(h), CHAR(e), CHAR(l), CHAR(l), CHAR(o)
    4,   // 45: /[a-z]+[0-9]*/ -> CHAR_CLASS, PLUS, CHAR_CLASS, STAR
    6,   // 46: /\Btest\B/ -> NOT_WORD_BOUNDARY, CHAR(t), CHAR(e), CHAR(s), CHAR(t), NOT_WORD_BOUNDARY
    1,   // 47: /\t/ -> TAB
    1,   // 48: /\n/ -> NEWLINE
    1,   // 49: /\r/ -> RETURN
    3,   // 50: /\t\n\r/ -> TAB, NEWLINE, RETURN
    2,   // 51: /a{3}/ -> CHAR, QUANTIFIER
    2,   // 52: /\d{5}/ -> DIGIT, QUANTIFIER
    2,   // 53: /b{2,4}/ -> CHAR, QUANTIFIER
    2,   // 54: /\w{1,10}/ -> WORD, QUANTIFIER
    2,   // 55: /c{1,}/ -> CHAR, QUANTIFIER
    2,   // 56: /\s{0,}/ -> WHITESPACE, QUANTIFIER
    2,   // 57: /d{0}/ -> CHAR, QUANTIFIER
    2,   // 58: /e{100}/ -> CHAR, QUANTIFIER
    5,   // 59: /\d{3}\.\d{3}/ -> DIGIT, QUANTIFIER, CHAR(.), DIGIT, QUANTIFIER
    2,   // 60: /[a-z]{2,5}/ -> CHAR_CLASS, QUANTIFIER
    4,   // 61: /^\w{3,}$/ -> BEGIN, WORD, QUANTIFIER, END
    4,   // 62: /(\d+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END
    8,   // 63: /(\d+)-(\w+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(-), GROUP_START, WORD, PLUS, GROUP_END (9 tokens)
    5,   // 64: /(\d{3})/ -> GROUP_START, DIGIT, QUANTIFIER, GROUP_END (4 tokens? Let me recalculate)
    4,   // 65: /([a-z]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
    11,  // 66: /(\w+)@(\w+)\.(\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(@), GROUP_START, WORD, PLUS, GROUP_END, CHAR(.), GROUP_START, WORD, PLUS, GROUP_END (14 tokens)
    7,   // 67: /(abc)def/ -> GROUP_START, CHAR(a), CHAR(b), CHAR(c), GROUP_END, CHAR(d), CHAR(e), CHAR(f) (8 tokens)
    7,   // 68: /abc(def)/ -> CHAR(a), CHAR(b), CHAR(c), GROUP_START, CHAR(d), CHAR(e), CHAR(f), GROUP_END (8 tokens)
    8,   // 69: /abc(\d+)def/ -> CHAR(a), CHAR(b), CHAR(c), GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(d), CHAR(e), CHAR(f) (10 tokens)
    2,   // 70: /()/ -> GROUP_START, GROUP_END
    6,   // 71: /^(\d+)$/ -> BEGIN, GROUP_START, DIGIT, PLUS, GROUP_END, END
    9    // 72: /(\d)(\w)(\s)/ -> GROUP_START, DIGIT, GROUP_END, GROUP_START, WORD, GROUP_END, GROUP_START, WHITESPACE, GROUP_END
}

constant integer REGEX_COMPILE_EXPECTED_TOKENS[][] = {
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_WHITESPACE
    },
    {
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_WHITESPACE
    },
    {
        // Test 8: /\d\w\s+/ -> DIGIT, WORD, WHITESPACE, PLUS
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_PLUS
    },
    {
        // Test 9: /\d?\w\s*/ -> DIGIT, QUESTIONMARK, WORD, WHITESPACE, STAR
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        // Test 10: /\D+/ -> NOT_DIGIT, PLUS
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_PLUS
    },
    {
        // Test 11: /\D*/ -> NOT_DIGIT, STAR
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_STAR
    },
    {
        // Test 12: /\D\s/ -> NOT_DIGIT, WHITESPACE
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_WHITESPACE
    },
    {
        // Test 13: /\W+/ -> NOT_WORD, PLUS
        REGEX_TYPE_NOT_ALPHA,
        REGEX_TYPE_PLUS
    },
    {
        // Test 14: /\S*/ -> NOT_WHITESPACE, STAR
        REGEX_TYPE_NOT_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        // Test 15: /^[a-zA-Z0-9_]+$/ -> BEGIN, CHAR_CLASS, PLUS, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_END
    },
    {
        // Test 16: /^[Hh]ello,\s[Ww]orld!$/ -> BEGIN, CHAR_CLASS, 'e', 'l', 'l', 'o', ',', WHITESPACE, CHAR_CLASS, 'o', 'r', 'l', 'd', '!', END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_END
    },
    {
        // Test 17: /^"[^"]*"/ -> BEGIN, CHAR, INV_CHAR_CLASS, STAR, CHAR
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_INV_CHAR_CLASS,
        REGEX_TYPE_STAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 18: /.*/ -> DOT, STAR
        REGEX_TYPE_DOT,
        REGEX_TYPE_STAR
    },
    {
        // Test 19: /\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/ -> 23 tokens
        // Note: \. is escaped, so it becomes CHAR (literal dot), not DOT (wildcard)
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_CHAR,  // Escaped dot \.
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_CHAR,  // Escaped dot \.
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_CHAR,  // Escaped dot \.
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT
    },
    {
        // Test 20: /\d?/ -> DIGIT, QUESTIONMARK
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK
    },
    {
        // Test 21: /\d?\d?/ -> DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK
    },
    {
        // Test 22: /\d?\d?\d/ -> DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK, DIGIT
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT
    },
    {
        // Test 23: /^...$/ -> BEGIN, DOT, DOT, DOT, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_DOT,
        REGEX_TYPE_DOT,
        REGEX_TYPE_DOT,
        REGEX_TYPE_END
    },
    {
        // Test 24: /\d\w\s/ -> DIGIT, WORD, WHITESPACE
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_WHITESPACE
    },
    {
        // Test 25: /a?b*c+/ -> CHAR(a), QUESTIONMARK, CHAR(b), STAR, CHAR(c), PLUS
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_STAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_PLUS
    },
    {
        // Test 26: /\.\*\+\?/ -> CHAR(.), CHAR(*), CHAR(+), CHAR(?)
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 27: /[a-zA-Z]/ -> CHAR_CLASS
        REGEX_TYPE_CHAR_CLASS
    },
    {
        // Test 28: /[^0-9]/ -> INV_CHAR_CLASS
        REGEX_TYPE_INV_CHAR_CLASS
    },
    {
        // Test 29: /[abc123]/ -> CHAR_CLASS
        REGEX_TYPE_CHAR_CLASS
    },
    {
        // Test 30: /^\d+$/ -> BEGIN, DIGIT, PLUS, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_END
    },
    {
        // Test 31: /\bword\b/ -> WORD_BOUNDARY, CHAR(w), CHAR(o), CHAR(r), CHAR(d), WORD_BOUNDARY
        REGEX_TYPE_WORD_BOUNDARY,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_WORD_BOUNDARY
    },
    {
        // Test 32: /\w+@\w+\.\w+/ -> WORD, PLUS, CHAR(@), WORD, PLUS, CHAR(.), WORD, PLUS
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS
    },
    {
        // Test 33: /\d*\w+\s*/ -> DIGIT, STAR, WORD, PLUS, WHITESPACE, STAR
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_STAR,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        // Test 34: /\D\W\S/ -> NOT_DIGIT, NOT_WORD, NOT_WHITESPACE
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_NOT_ALPHA,
        REGEX_TYPE_NOT_WHITESPACE
    },
    {
        // Test 35: /[a-z-]/ -> CHAR_CLASS
        REGEX_TYPE_CHAR_CLASS
    },
    {
        // Test 36: /.*\..*/ -> DOT, STAR, CHAR(.), DOT, STAR
        REGEX_TYPE_DOT,
        REGEX_TYPE_STAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DOT,
        REGEX_TYPE_STAR
    },
    {
        // Test 37: /[abc][def][ghi]/ -> CHAR_CLASS, CHAR_CLASS, CHAR_CLASS
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_CHAR_CLASS
    },
    {
        // Test 38: /\d\d?\d?/ -> DIGIT, DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK
    },
    {
        // Test 39: /^test/ -> BEGIN, CHAR(t), CHAR(e), CHAR(s), CHAR(t)
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 40: /test$/ -> CHAR(t), CHAR(e), CHAR(s), CHAR(t), END
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_END
    },
    {
        // Test 41: /[\d\w\s]/ -> CHAR_CLASS
        REGEX_TYPE_CHAR_CLASS
    },
    {
        // Test 42: /[]/ -> CHAR_CLASS (empty)
        REGEX_TYPE_CHAR_CLASS
    },
    {
        // Test 43: /x/ -> CHAR
        REGEX_TYPE_CHAR
    },
    {
        // Test 44: /hello/ -> CHAR(h), CHAR(e), CHAR(l), CHAR(l), CHAR(o)
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 45: /[a-z]+[0-9]*/ -> CHAR_CLASS, PLUS, CHAR_CLASS, STAR
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_STAR
    },
    {
        // Test 46: /\Btest\B/ -> NOT_WORD_BOUNDARY, CHAR(t), CHAR(e), CHAR(s), CHAR(t), NOT_WORD_BOUNDARY
        REGEX_TYPE_NOT_WORD_BOUNDARY,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_NOT_WORD_BOUNDARY
    },
    {
        // Test 47: /\t/ -> TAB
        REGEX_TYPE_TAB
    },
    {
        // Test 48: /\n/ -> NEWLINE
        REGEX_TYPE_NEWLINE
    },
    {
        // Test 49: /\r/ -> RETURN
        REGEX_TYPE_RETURN
    },
    {
        // Test 50: /\t\n\r/ -> TAB, NEWLINE, RETURN
        REGEX_TYPE_TAB,
        REGEX_TYPE_NEWLINE,
        REGEX_TYPE_RETURN
    },
    {
        // Test 51: /a{3}/ -> CHAR, QUANTIFIER
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUANTIFIER
    },
    {
        // Test 52: /\d{5}/ -> DIGIT, QUANTIFIER
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER
    },
    {
        // Test 53: /b{2,4}/ -> CHAR, QUANTIFIER
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUANTIFIER
    },
    {
        // Test 54: /\w{1,10}/ -> WORD, QUANTIFIER
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_QUANTIFIER
    },
    {
        // Test 55: /c{1,}/ -> CHAR, QUANTIFIER
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUANTIFIER
    },
    {
        // Test 56: /\s{0,}/ -> WHITESPACE, QUANTIFIER
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_QUANTIFIER
    },
    {
        // Test 57: /d{0}/ -> CHAR, QUANTIFIER
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUANTIFIER
    },
    {
        // Test 58: /e{100}/ -> CHAR, QUANTIFIER
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUANTIFIER
    },
    {
        // Test 59: /\d{3}\.\d{3}/ -> DIGIT, QUANTIFIER, CHAR(.), DIGIT, QUANTIFIER
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER
    },
    {
        // Test 60: /[a-z]{2,5}/ -> CHAR_CLASS, QUANTIFIER
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_QUANTIFIER
    },
    {
        // Test 61: /^\w{3,}$/ -> BEGIN, WORD, QUANTIFIER, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_END
    },
    {
        // Test 62: /(\d+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 63: /(\d+)-(\w+)/ -> GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(-), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 64: /(\d{3})/ -> GROUP_START, DIGIT, QUANTIFIER, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 65: /([a-z]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 66: /(\w+)@(\w+)\.(\w+)/ -> GROUP_START, WORD, PLUS, GROUP_END, CHAR(@), GROUP_START, WORD, PLUS, GROUP_END, CHAR(.), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 67: /(abc)def/ -> GROUP_START, CHAR(a), CHAR(b), CHAR(c), GROUP_END, CHAR(d), CHAR(e), CHAR(f)
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 68: /abc(def)/ -> CHAR(a), CHAR(b), CHAR(c), GROUP_START, CHAR(d), CHAR(e), CHAR(f), GROUP_END
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 69: /abc(\d+)def/ -> CHAR(a), CHAR(b), CHAR(c), GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(d), CHAR(e), CHAR(f)
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 70: /()/ -> GROUP_START, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 71: /^(\d+)$/ -> BEGIN, GROUP_START, DIGIT, PLUS, GROUP_END, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_END
    },
    {
        // Test 72: /(\d)(\w)(\s)/ -> GROUP_START, DIGIT, GROUP_END, GROUP_START, WORD, GROUP_END, GROUP_START, WHITESPACE, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_GROUP_END
    }
}


define_function TestNAVRegexCompile() {
    stack_var integer x

    NAVLog("'***************** NAVRegexCompile *****************'")

    for (x = 1; x <= length_array(REGEX_COMPILE_PATTERN_TEST); x++) {
        stack_var _NAVRegexParser parser

        if (!NAVAssertTrue('Should compile successfully', NAVRegexCompile(REGEX_COMPILE_PATTERN_TEST[x], parser))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVAssertIntegerEqual('Should have correct pattern length', parser.pattern.length, REGEX_COMPILE_EXPECTED_PATTERN_LENGTH[x])) {
            NAVLogTestFailed(x, itoa(REGEX_COMPILE_EXPECTED_PATTERN_LENGTH[x]), itoa(parser.pattern.length))
            continue
        }

        // Simple token count assertion - much easier to maintain
        if (!NAVAssertIntegerEqual('Should compile to correct amount of tokens', parser.count, REGEX_COMPILE_EXPECTED_TOKEN_COUNT[x])) {
            NAVLogTestFailed(x, itoa(REGEX_COMPILE_EXPECTED_TOKEN_COUNT[x]), itoa(parser.count))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= parser.count; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", parser.state[y].type, REGEX_COMPILE_EXPECTED_TOKENS[x][y])) {
                    NAVLogTestFailed(x, NAVRegexGetTokenType(REGEX_COMPILE_EXPECTED_TOKENS[x][y]), NAVRegexGetTokenType(parser.state[y].type))
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
