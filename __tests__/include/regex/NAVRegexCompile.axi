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
    '/(\d)(\w)(\s)/',

    // Test 73: Group with dot wildcard
    '/(.+)/',

    // Test 74: Group with star quantifier
    '/(a*)b/',

    // Test 75: Multiple groups with literals between
    '/(hello)-(world)/',

    // Test 76: Group with word boundary
    '/\b(\w+)\b/',

    // Test 77: Group at beginning with anchor
    '/^(test)/',

    // Test 78: Group at end with anchor
    '/(test)$/',

    // Test 79: Group with escaped dot
    '/(\.)/',

    // Test 80: Group with plus on character class
    '/([0-9]+)/',

    // Test 81: Multiple groups with different quantifiers
    '/(\d+)\.(\d*)/',

    // Test 82: Group with question mark
    '/(https?)/',

    // Test 83: Empty group at start
    '/()abc/',

    // Test 84: Empty group at end
    '/abc()/',

    // Test 85: Group with negated character class
    '/([^a-z]+)/',

    // Test 86: Multiple groups with anchors
    '/^(\w+):(\d+)$/',

    // Test 87: Group with optional quantifier
    '/(\d)?/',

    // Test 88: Complex email-like pattern
    '/([a-zA-Z0-9]+)@([a-zA-Z0-9]+)\.([a-z]{2,})/',

    // Test 89: Group with multiple character classes
    '/([\d\w]+)/',

    // Test 90: Group with escaped parenthesis inside
    '/(\\\()/',

    // Test 91: IPv4-like pattern with groups
    '/(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/',

    // Test 92: URL-like pattern
    '/(https?):\/\/(\w+)/',

    // Test 93: Group with whitespace
    '/(\s+)/',

    // Test 94: Multiple empty groups
    '/()()()/',

    // Test 95: Group with boundaries
    '/\b(\d+)\b/',

    // Test 96: Group with begin and end
    '/^(.*)$/'
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
    },
    {
        // Test 73: /(.+)/ -> GROUP_START, DOT, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DOT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 74: /(a*)b/ -> GROUP_START, CHAR, STAR, GROUP_END, CHAR
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_STAR,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR
    },
    {
        // Test 75: /(hello)-(world)/ -> GROUP_START, 5xCHAR, GROUP_END, CHAR(-), GROUP_START, 5xCHAR, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 76: /\b(\w+)\b/ -> WORD_BOUNDARY, GROUP_START, WORD, PLUS, GROUP_END, WORD_BOUNDARY
        REGEX_TYPE_WORD_BOUNDARY,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_WORD_BOUNDARY
    },
    {
        // Test 77: /^(test)/ -> BEGIN, GROUP_START, 4xCHAR, GROUP_END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 78: /(test)$/ -> GROUP_START, 4xCHAR, GROUP_END, END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_END
    },
    {
        // Test 79: /(\.)/ -> GROUP_START, CHAR(.), GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 80: /([0-9]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 81: /(\d+)\.(\d*)/ -> GROUP_START, DIGIT, PLUS, GROUP_END, CHAR(.), GROUP_START, DIGIT, STAR, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_STAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 82: /(https?)/ -> GROUP_START, 5xCHAR(https), QUESTIONMARK, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 83: /()abc/ -> GROUP_START, GROUP_END, 3xCHAR
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 84: /abc()/ -> 3xCHAR, GROUP_START, GROUP_END
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 85: /([^a-z]+)/ -> GROUP_START, INV_CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_INV_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 86: /^(\w+):(\d+)$/ -> BEGIN, GROUP_START, WORD, PLUS, GROUP_END, CHAR(:), GROUP_START, DIGIT, PLUS, GROUP_END, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_END
    },
    {
        // Test 87: /(\d)?/ -> GROUP_START, DIGIT, GROUP_END, QUESTION
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_QUESTIONMARK
    },
    {
        // Test 88: /([a-zA-Z0-9]+)@([a-zA-Z0-9]+)\.([a-z]{2,})/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END, CHAR(@), GROUP_START, CHAR_CLASS, PLUS, GROUP_END, CHAR(.), GROUP_START, CHAR_CLASS, QUANTIFIER, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 89: /([\d\w]+)/ -> GROUP_START, CHAR_CLASS, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 90: /(\\\()/ -> GROUP_START, CHAR(\\), CHAR(\(), GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 91: /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/ -> 4x(GROUP_START, DIGIT, QUANTIFIER, GROUP_END) + 3xCHAR(.)
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUANTIFIER,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 92: /(https?):\/\/(\w+)/ -> GROUP_START, 5xCHAR(https), QUESTIONMARK, GROUP_END, CHAR(:), 2xCHAR(/), GROUP_START, WORD, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 93: /(\s+)/ -> GROUP_START, WHITESPACE, PLUS, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 94: /()()()/ -> GROUP_START, GROUP_END, GROUP_START, GROUP_END, GROUP_START, GROUP_END
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_GROUP_END
    },
    {
        // Test 95: /\b(\d+)\b/ -> WORD_BOUNDARY, GROUP_START, DIGIT, PLUS, GROUP_END, WORD_BOUNDARY
        REGEX_TYPE_WORD_BOUNDARY,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_WORD_BOUNDARY
    },
    {
        // Test 96: /^(.*)$/ -> BEGIN, GROUP_START, DOT, STAR, GROUP_END, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_GROUP_START,
        REGEX_TYPE_DOT,
        REGEX_TYPE_STAR,
        REGEX_TYPE_GROUP_END,
        REGEX_TYPE_END
    }
}


define_function TestNAVRegexCompile() {
    stack_var integer x

    NAVLog("'***************** NAVRegexCompile *****************'")

    for (x = 1; x <= length_array(REGEX_COMPILE_PATTERN_TEST); x++) {
        stack_var _NAVRegexParser parser
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should compile successfully', NAVRegexCompile(REGEX_COMPILE_PATTERN_TEST[x], parser))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_COMPILE_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should compile to correct amount of tokens', expectedTokenCount, parser.count)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(parser.count))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= parser.count; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_COMPILE_EXPECTED_TOKENS[x][y], parser.state[y].type)) {
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
