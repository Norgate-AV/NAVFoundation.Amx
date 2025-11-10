PROGRAM_NAME='NAVRegexLexerInlineFlags'

DEFINE_CONSTANT

/**
 * Test patterns for inline flag tokenization.
 *
 * Inline flags modify matching behavior:
 * - (?i): Case-insensitive matching
 * - (?m): Multiline mode
 * - (?s): Dotall mode
 * - (?x): Extended mode
 *
 * Combined flags: Multiple flags in one group (?im), (?ims), etc.
 * Scoped flags: Flags that apply only within a group (?i:pattern)
 */
constant char REGEX_LEXER_INLINE_FLAGS_PATTERN_TEST[][255] = {
    // Case-insensitive flag
    '/(?i)/',               // 1: Case-insensitive flag alone
    '/(?i)test/',           // 2: Flag with literal text
    '/test(?i)/',           // 3: Flag after literal text
    '/(?i)[a-z]+/',         // 4: Flag with character class
    '/(?i)\d+/',            // 5: Flag with shorthand class

    // Multiline flag
    '/(?m)/',               // 6: Multiline flag alone
    '/(?m)^test/',          // 7: Flag with start anchor
    '/(?m)test$/',          // 8: Flag with end anchor

    // Dotall flag
    '/(?s)/',               // 9: Dotall flag alone
    '/(?s).+/',             // 10: Flag with dot matching

    // Extended flag
    '/(?x)/',               // 11: Extended flag alone
    '/(?x)test/',           // 12: Flag with pattern

    // Multiple separate flag groups
    '/(?i)test(?m)/',       // 13: Two flags
    '/(?i)(?m)(?s)/',       // 14: Three flags
    '/(?i)(?m)(?s)(?x)/',   // 15: All four flags

    // Flags with groups
    '/((?i)test)/',         // 16: Flag inside capturing group
    '/(?:(?i)test)/',       // 17: Flag inside non-capturing group
    '/(?i)(test)/',         // 18: Flag before capturing group

    // Flags with other constructs
    '/(?i)\btest\b/',       // 19: Flag with word boundaries
    '/(?i)\Atest\Z/',       // 20: Flag with string anchors

    // ========== COMBINED FLAGS (Multiple flags in one group) ==========
    '/(?im)/',              // 21: Two flags combined (i+m)
    '/(?is)/',              // 22: Two flags combined (i+s)
    '/(?ix)/',              // 23: Two flags combined (i+x)
    '/(?ms)/',              // 24: Two flags combined (m+s)
    '/(?mx)/',              // 25: Two flags combined (m+x)
    '/(?sx)/',              // 26: Two flags combined (s+x)
    '/(?ims)/',             // 27: Three flags combined (i+m+s)
    '/(?imx)/',             // 28: Three flags combined (i+m+x)
    '/(?isx)/',             // 29: Three flags combined (i+s+x)
    '/(?msx)/',             // 30: Three flags combined (m+s+x)
    '/(?imsx)/',            // 31: All four flags combined
    '/(?im)test/',          // 32: Combined flags with pattern
    '/(?ims)[a-z]+/',       // 33: Combined flags with char class
    '/test(?imsx)/',        // 34: Combined flags after text

    // ========== SCOPED FLAGS (Flags apply only within group) ==========
    '/(?i:test)/',          // 35: Single flag scoped
    '/(?m:^test)/',         // 36: Multiline flag scoped
    '/(?s:.+)/',            // 37: Dotall flag scoped
    '/(?x:test)/',          // 38: Extended flag scoped
    '/(?im:test)/',         // 39: Combined flags scoped (i+m)
    '/(?ims:pattern)/',     // 40: Three flags scoped
    '/(?imsx:abc)/',        // 41: All four flags scoped
    '/(?i:test)rest/',      // 42: Scoped with content after
    '/test(?i:middle)end/', // 43: Scoped in middle
    '/((?i:test))/',        // 44: Scoped inside capturing group
    '/(?:(?i:test))/',      // 45: Scoped inside non-capturing group
    '/(?i:test)(?m:abc)/',  // 46: Multiple scoped groups
    '/(?i)(?m:test)/',      // 47: Global then scoped
    '/(?i:test)(?m)/'       // 48: Scoped then global
}

constant integer REGEX_LEXER_INLINE_FLAGS_EXPECTED_TOKENS[][] = {
    {
        // Test 1: /(?i)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 2: /(?i)test/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, CHAR(t), CHAR(e), CHAR(s), CHAR(t)
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        // Test 3: /test(?i)/ -> CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 4: /(?i)[a-z]+/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, CHAR_CLASS, PLUS
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        // Test 5: /(?i)\d+/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, DIGIT, PLUS
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        // Test 6: /(?m)/ -> GROUP_START, FLAG_MULTILINE, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 7: /(?m)^test/ -> GROUP_START, FLAG_MULTILINE, GROUP_END, BEGIN, CHAR(t), CHAR(e), CHAR(s), CHAR(t)
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        // Test 8: /(?m)test$/ -> GROUP_START, FLAG_MULTILINE, GROUP_END, CHAR(t), CHAR(e), CHAR(s), CHAR(t), END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 9: /(?s)/ -> GROUP_START, FLAG_DOTALL, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 10: /(?s).+/ -> GROUP_START, FLAG_DOTALL, GROUP_END, DOT, PLUS
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        // Test 11: /(?x)/ -> GROUP_START, FLAG_EXTENDED, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 12: /(?x)test/ -> GROUP_START, FLAG_EXTENDED, GROUP_END, CHAR(t), CHAR(e), CHAR(s), CHAR(t)
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        // Test 13: /(?i)test(?m)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_START, FLAG_MULTILINE, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 14: /(?i)(?m)(?s)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, GROUP_START, FLAG_MULTILINE, GROUP_END, GROUP_START, FLAG_DOTALL, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 15: /(?i)(?m)(?s)(?x)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, GROUP_START, FLAG_MULTILINE, GROUP_END, GROUP_START, FLAG_DOTALL, GROUP_END, GROUP_START, FLAG_EXTENDED, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 16: /((?i)test)/ -> GROUP_START, GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 17: /(?:(?i)test)/ -> GROUP_START, GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 18: /(?i)(test)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, GROUP_START, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 19: /(?i)\btest\b/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, WORD_BOUNDARY, CHAR(t), CHAR(e), CHAR(s), CHAR(t), WORD_BOUNDARY
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    {
        // Test 20: /(?i)\Atest\Z/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, STRING_START, CHAR(t), CHAR(e), CHAR(s), CHAR(t), STRING_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_STRING_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_STRING_END,
        REGEX_TOKEN_EOF
    },
    // ========== COMBINED FLAGS ==========
    {
        // Test 21: /(?im)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_MULTILINE, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 22: /(?is)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_DOTALL, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 23: /(?ix)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_EXTENDED, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 24: /(?ms)/ -> GROUP_START, FLAG_MULTILINE, FLAG_DOTALL, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 25: /(?mx)/ -> GROUP_START, FLAG_MULTILINE, FLAG_EXTENDED, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 26: /(?sx)/ -> GROUP_START, FLAG_DOTALL, FLAG_EXTENDED, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 27: /(?ims)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_MULTILINE, FLAG_DOTALL, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 28: /(?imx)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_MULTILINE, FLAG_EXTENDED, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 29: /(?isx)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_DOTALL, FLAG_EXTENDED, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 30: /(?msx)/ -> GROUP_START, FLAG_MULTILINE, FLAG_DOTALL, FLAG_EXTENDED, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 31: /(?imsx)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_MULTILINE, FLAG_DOTALL, FLAG_EXTENDED, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 32: /(?im)test/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_MULTILINE, GROUP_END, CHAR(t), CHAR(e), CHAR(s), CHAR(t)
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        // Test 33: /(?ims)[a-z]+/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_MULTILINE, FLAG_DOTALL, GROUP_END, CHAR_CLASS, PLUS
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    {
        // Test 34: /test(?imsx)/ -> CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_MULTILINE, FLAG_DOTALL, FLAG_EXTENDED, GROUP_END
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // ========== SCOPED FLAGS ==========
    {
        // Test 35: /(?i:test)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 36: /(?m:^test)/ -> GROUP_START, FLAG_MULTILINE, BEGIN, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 37: /(?s:.+)/ -> GROUP_START, FLAG_DOTALL, DOT, PLUS, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_DOT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 38: /(?x:test)/ -> GROUP_START, FLAG_EXTENDED, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 39: /(?im:test)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_MULTILINE, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 40: /(?ims:pattern)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_MULTILINE, FLAG_DOTALL, CHAR(p), CHAR(a), CHAR(t), CHAR(t), CHAR(e), CHAR(r), CHAR(n), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_CHAR,   // p
        REGEX_TOKEN_CHAR,   // a
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // n
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 41: /(?imsx:abc)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, FLAG_MULTILINE, FLAG_DOTALL, FLAG_EXTENDED, CHAR(a), CHAR(b), CHAR(c), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_CHAR,   // a
        REGEX_TOKEN_CHAR,   // b
        REGEX_TOKEN_CHAR,   // c
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 42: /(?i:test)rest/ -> GROUP_START, FLAG_CASE_INSENSITIVE, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END, CHAR(r), CHAR(e), CHAR(s), CHAR(t)
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // r
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    {
        // Test 43: /test(?i:middle)end/ -> CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_START, FLAG_CASE_INSENSITIVE, CHAR(m), CHAR(i), CHAR(d), CHAR(d), CHAR(l), CHAR(e), GROUP_END, CHAR(e), CHAR(n), CHAR(d)
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_CHAR,   // m
        REGEX_TOKEN_CHAR,   // i
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_CHAR,   // l
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // n
        REGEX_TOKEN_CHAR,   // d
        REGEX_TOKEN_EOF
    },
    {
        // Test 44: /((?i:test))/ -> GROUP_START, GROUP_START, FLAG_CASE_INSENSITIVE, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 45: /(?:(?i:test))/ -> GROUP_START, GROUP_START, FLAG_CASE_INSENSITIVE, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 46: /(?i:test)(?m:abc)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END, GROUP_START, FLAG_MULTILINE, CHAR(a), CHAR(b), CHAR(c), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_CHAR,   // a
        REGEX_TOKEN_CHAR,   // b
        REGEX_TOKEN_CHAR,   // c
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 47: /(?i)(?m:test)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, GROUP_END, GROUP_START, FLAG_MULTILINE, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    {
        // Test 48: /(?i:test)(?m)/ -> GROUP_START, FLAG_CASE_INSENSITIVE, CHAR(t), CHAR(e), CHAR(s), CHAR(t), GROUP_END, GROUP_START, FLAG_MULTILINE, GROUP_END
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    }
}


define_function TestNAVRegexLexerInlineFlags() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Inline Flags *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_INLINE_FLAGS_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_INLINE_FLAGS_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_INLINE_FLAGS_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_INLINE_FLAGS_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_INLINE_FLAGS_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        // NEW: Validate flag group metadata for GROUP_START tokens
        {
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (lexer.tokens[y].type == REGEX_TOKEN_GROUP_START) {
                    // Determine expected metadata based on token position and next token
                    // We need to identify:
                    // - Global flag groups: GROUP_START followed by FLAG_* tokens
                    // - Scoped flag groups: GROUP_START followed by FLAG_* then more content (no immediate GROUP_END)
                    // - Regular groups: GROUP_START not followed by FLAG_* tokens

                    // Check if the GROUP_START is followed by a FLAG token
                    if (y + 1 <= lexer.tokenCount &&
                        (lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_CASE_INSENSITIVE ||
                         lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_MULTILINE ||
                         lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_DOTALL ||
                         lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_EXTENDED)) {

                        // This is a flag group - but is it global or scoped?
                        // We determine this from the metadata (which the lexer should have set)
                        if (lexer.tokens[y].groupInfo.isScopedFlagGroup) {
                            // Scoped flag group: (?i:...), (?im:...), etc.
                            if (!NAVAssertScopedFlagGroup(lexer.tokens[y])) {
                                NAVLogTestFailed(x, '[SCOPED_FLAGS]', '[metadata mismatch]')
                                failed = true
                                break
                            }
                        }
                        else if (lexer.tokens[y].groupInfo.isGlobalFlagGroup) {
                            // Global flag group: (?i), (?im), etc.
                            if (!NAVAssertGlobalFlagGroup(lexer.tokens[y])) {
                                NAVLogTestFailed(x, '[GLOBAL_FLAGS]', '[metadata mismatch]')
                                failed = true
                                break
                            }
                        }
                        else {
                            // Flag group but neither global nor scoped - this is an error
                            NAVLogTestFailed(x, '[FLAG_GROUP]', '[neither global nor scoped]')
                            failed = true
                            break
                        }
                    }
                    else {
                        // This is a regular capturing or non-capturing group (not a flag group)
                        if (!NAVAssertRegularGroup(lexer.tokens[y])) {
                            NAVLogTestFailed(x, '[REGULAR_GROUP]', '[metadata mismatch]')
                            failed = true
                            break
                        }
                    }
                }
            }

            if (failed) {
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
