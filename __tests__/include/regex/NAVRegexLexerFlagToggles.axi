DEFINE_CONSTANT

/**
 * Test patterns for flag toggle and unset flag tokenization.
 *
 * Flag toggles modify multiple flags in one group:
 * - (?i-m): Enable case-insensitive, disable multiline
 * - (?im-sx): Enable i+m, disable s+x
 * - (?-i): Disable case-insensitive
 * - (?-im): Disable multiple flags
 *
 * These patterns test the lexer's ability to parse the flag enable/disable
 * syntax and set the flagEnabled field correctly on each flag token.
 */
constant char REGEX_LEXER_FLAG_TOGGLES_PATTERN_TEST[][255] = {
    // Single flag disable (unset)
    '/(?-i)/',              // 1: Disable case-insensitive
    '/(?-m)/',              // 2: Disable multiline
    '/(?-s)/',              // 3: Disable dotall
    '/(?-x)/',              // 4: Disable extended
    '/(?-i)test/',          // 5: Disable flag with pattern
    '/test(?-i)/',          // 6: Disable flag after pattern
    '/(?-i)[a-z]+/',        // 7: Disable flag with char class
    '/(?-i)\d+/',           // 8: Disable flag with shorthand

    // Multiple flags disable
    '/(?-im)/',             // 9: Disable i+m
    '/(?-is)/',             // 10: Disable i+s
    '/(?-ix)/',             // 11: Disable i+x
    '/(?-ms)/',             // 12: Disable m+s
    '/(?-mx)/',             // 13: Disable m+x
    '/(?-sx)/',             // 14: Disable s+x
    '/(?-ims)/',            // 15: Disable i+m+s
    '/(?-imx)/',            // 16: Disable i+m+x
    '/(?-isx)/',            // 17: Disable i+s+x
    '/(?-msx)/',            // 18: Disable m+s+x
    '/(?-imsx)/',           // 19: Disable all four flags
    '/(?-im)test/',         // 20: Disable multiple with pattern

    // Toggle syntax: enable some, disable others
    '/(?i-m)/',             // 21: Enable i, disable m
    '/(?m-i)/',             // 22: Enable m, disable i
    '/(?s-x)/',             // 23: Enable s, disable x
    '/(?x-s)/',             // 24: Enable x, disable s
    '/(?im-sx)/',           // 25: Enable i+m, disable s+x
    '/(?sx-im)/',           // 26: Enable s+x, disable i+m
    '/(?i-msx)/',           // 27: Enable i, disable m+s+x
    '/(?imx-s)/',           // 28: Enable i+m+x, disable s
    '/(?is-mx)/',           // 29: Enable i+s, disable m+x
    '/(?i-m)test/',         // 30: Toggle with pattern

    // Scoped flag toggles
    '/(?i-m:test)/',        // 31: Toggle scoped (enable i, disable m)
    '/(?-i:test)/',         // 32: Disable scoped
    '/(?im-sx:pattern)/',   // 33: Multiple toggle scoped
    '/(?-imsx:pattern)/',   // 34: Disable all scoped

    // Mixed enable and disable in pattern
    '/(?i)(?-m)/',          // 35: Enable then disable different flags
    '/(?-i)(?m)/',          // 36: Disable then enable different flags
    '/(?i-m)(?s-x)/',       // 37: Multiple toggle groups
    '/(?i)test(?-i)/',      // 38: Enable, pattern, disable
    '/(?-i)test(?i)/',      // 39: Disable, pattern, enable

    // Complex toggle combinations
    '/(?im-sx)(?i-m)/',     // 40: Two different toggles
    '/(?i)(?-i)(?i)/',      // 41: Enable, disable, enable same flag
    '/(?i-m)(?m-i)/',       // 42: Swap flags

    // Edge cases
    '/(?i-i)/',             // 43: Enable and disable same flag (i)
    '/(?m-m)/',             // 44: Enable and disable same flag (m)
    '/(?im-im)/',           // 45: Enable and disable same flags
    '/(?i-imsx)/',          // 46: Enable i, disable all (including i)
    '/(?imsx-imsx)/',       // 47: Enable all, disable all

    // With other constructs
    '/(?i-m)\btest\b/',     // 48: Toggle with word boundaries
    '/(?i-m)(test)/',       // 49: Toggle with capturing group
    '/(?i-m)(?:test)/',     // 50: Toggle with non-capturing group

    // All permutations of single enable + single disable
    '/(?i-m)/',             // 51: i enabled, m disabled
    '/(?i-s)/',             // 52: i enabled, s disabled
    '/(?i-x)/',             // 53: i enabled, x disabled
    '/(?m-i)/',             // 54: m enabled, i disabled
    '/(?m-s)/',             // 55: m enabled, s disabled
    '/(?m-x)/',             // 56: m enabled, x disabled
    '/(?s-i)/',             // 57: s enabled, i disabled
    '/(?s-m)/',             // 58: s enabled, m disabled
    '/(?s-x)/',             // 59: s enabled, x disabled
    '/(?x-i)/',             // 60: x enabled, i disabled
    '/(?x-m)/',             // 61: x enabled, m disabled
    '/(?x-s)/'              // 62: x enabled, s disabled
}

constant integer REGEX_LEXER_FLAG_TOGGLES_EXPECTED_TOKENS[][] = {
    // Test 1: /(?-i)/ -> GROUP_START, FLAG_CASE_INSENSITIVE(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 2: /(?-m)/ -> GROUP_START, FLAG_MULTILINE(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 3: /(?-s)/ -> GROUP_START, FLAG_DOTALL(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 4: /(?-x)/ -> GROUP_START, FLAG_EXTENDED(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 5: /(?-i)test/ -> GROUP_START, FLAG_CASE_INSENSITIVE(disabled), GROUP_END, CHAR*4
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_EOF
    },
    // Test 6: /test(?-i)/ -> CHAR*4, GROUP_START, FLAG_CASE_INSENSITIVE(disabled), GROUP_END
    {
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 7: /(?-i)[a-z]+/ -> GROUP_START, FLAG_CASE_INSENSITIVE(disabled), GROUP_END, CHAR_CLASS, PLUS
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    // Test 8: /(?-i)\d+/ -> GROUP_START, FLAG_CASE_INSENSITIVE(disabled), GROUP_END, DIGIT, PLUS
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    // Test 9: /(?-im)/ -> GROUP_START, FLAG_CASE_INSENSITIVE(disabled), FLAG_MULTILINE(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 10: /(?-is)/ -> GROUP_START, FLAG_CASE_INSENSITIVE(disabled), FLAG_DOTALL(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 11: /(?-ix)/ -> GROUP_START, FLAG_CASE_INSENSITIVE(disabled), FLAG_EXTENDED(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 12: /(?-ms)/ -> GROUP_START, FLAG_MULTILINE(disabled), FLAG_DOTALL(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 13: /(?-mx)/ -> GROUP_START, FLAG_MULTILINE(disabled), FLAG_EXTENDED(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 14: /(?-sx)/ -> GROUP_START, FLAG_DOTALL(disabled), FLAG_EXTENDED(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 15: /(?-ims)/ -> GROUP_START, all 3 flags disabled, GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 16: /(?-imx)/ -> GROUP_START, all 3 flags disabled, GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 17: /(?-isx)/ -> GROUP_START, all 3 flags disabled, GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 18: /(?-msx)/ -> GROUP_START, all 3 flags disabled, GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 19: /(?-imsx)/ -> GROUP_START, all 4 flags disabled, GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 20: /(?-im)test/ -> GROUP_START, flags disabled, GROUP_END, CHAR*4
    {
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
    // Test 21: /(?i-m)/ -> GROUP_START, FLAG_CASE_INSENSITIVE(enabled), FLAG_MULTILINE(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 22: /(?m-i)/ -> GROUP_START, FLAG_MULTILINE(enabled), FLAG_CASE_INSENSITIVE(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 23: /(?s-x)/ -> GROUP_START, FLAG_DOTALL(enabled), FLAG_EXTENDED(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 24: /(?x-s)/ -> GROUP_START, FLAG_EXTENDED(enabled), FLAG_DOTALL(disabled), GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 25: /(?im-sx)/ -> GROUP_START, i+m enabled, s+x disabled, GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 26: /(?sx-im)/ -> GROUP_START, s+x enabled, i+m disabled, GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 27: /(?i-msx)/ -> GROUP_START, i enabled, m+s+x disabled, GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 28: /(?imx-s)/ -> GROUP_START, i+m+x enabled, s disabled, GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 29: /(?is-mx)/ -> GROUP_START, i+s enabled, m+x disabled, GROUP_END
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 30: /(?i-m)test/ -> GROUP_START, toggle flags, GROUP_END, CHAR*4
    {
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
    // Test 31: /(?i-m:test)/ -> Scoped toggle
    {
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
    // Test 32: /(?-i:test)/ -> Scoped disable
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 33: /(?im-sx:pattern)/ -> Scoped complex toggle
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
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
    // Test 34: /(?-imsx:pattern)/ -> Disable all scoped
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
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
    // Test 35: /(?i)(?-m)/ -> Two flag groups
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 36: /(?-i)(?m)/ -> Two flag groups
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 37: /(?i-m)(?s-x)/ -> Two toggle groups
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 38: /(?i)test(?-i)/ -> Enable, pattern, disable
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 39: /(?-i)test(?i)/ -> Disable, pattern, enable
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 40: /(?im-sx)(?i-m)/ -> Two toggles
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 41: /(?i)(?-i)(?i)/ -> Enable, disable, enable
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 42: /(?i-m)(?m-i)/ -> Swap flags
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 43: /(?i-i)/ -> Enable and disable same flag
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 44: /(?m-m)/ -> Enable and disable same flag
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 45: /(?im-im)/ -> Enable and disable same flags
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 46: /(?i-imsx)/ -> Enable i, disable all
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 47: /(?imsx-imsx)/ -> Enable all, disable all
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 48: /(?i-m)\btest\b/ -> Toggle with word boundaries
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_WORD_BOUNDARY,
        REGEX_TOKEN_EOF
    },
    // Test 49: /(?i-m)(test)/ -> Toggle with capturing group
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 50: /(?i-m)(?:test)/ -> Toggle with non-capturing
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_CHAR,   // e
        REGEX_TOKEN_CHAR,   // s
        REGEX_TOKEN_CHAR,   // t
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Tests 51-62: All single enable + single disable permutations
    // Test 51: /(?i-m)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 52: /(?i-s)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 53: /(?i-x)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 54: /(?m-i)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 55: /(?m-s)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 56: /(?m-x)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 57: /(?s-i)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 58: /(?s-m)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 59: /(?s-x)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 60: /(?x-i)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_FLAG_CASE_INSENSITIVE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 61: /(?x-m)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_FLAG_MULTILINE,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 62: /(?x-s)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_FLAG_EXTENDED,
        REGEX_TOKEN_FLAG_DOTALL,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    }
}

/**
 * Expected flagEnabled values for flag toggle tests.
 * Each entry is an array of [tokenIndex, expectedFlagEnabled] pairs.
 * Format: { {token_index, flag_enabled_value}, {token_index, flag_enabled_value}, ... }
 */
constant integer REGEX_LEXER_FLAG_TOGGLES_EXPECTED_FLAG_ENABLED[][][] = {
    // Test 1: /(?-i)/ -> token 2: i disabled (0)
    { {2, 0} },
    // Test 2: /(?-m)/ -> token 2: m disabled (0)
    { {2, 0} },
    // Test 3: /(?-s)/ -> token 2: s disabled (0)
    { {2, 0} },
    // Test 4: /(?-x)/ -> token 2: x disabled (0)
    { {2, 0} },
    // Test 5: /(?-i)test/ -> token 2: i disabled (0)
    { {2, 0} },
    // Test 6: /test(?-i)/ -> token 6: i disabled (0)
    { {6, 0} },
    // Test 7: /(?-i)[a-z]+/ -> token 2: i disabled (0)
    { {2, 0} },
    // Test 8: /(?-i)\d+/ -> token 2: i disabled (0)
    { {2, 0} },
    // Test 9: /(?-im)/ -> tokens 2,3: both disabled (0,0)
    { {2, 0}, {3, 0} },
    // Test 10: /(?-is)/ -> tokens 2,3: both disabled (0,0)
    { {2, 0}, {3, 0} },
    // Test 11: /(?-ix)/ -> tokens 2,3: both disabled (0,0)
    { {2, 0}, {3, 0} },
    // Test 12: /(?-ms)/ -> tokens 2,3: both disabled (0,0)
    { {2, 0}, {3, 0} },
    // Test 13: /(?-mx)/ -> tokens 2,3: both disabled (0,0)
    { {2, 0}, {3, 0} },
    // Test 14: /(?-sx)/ -> tokens 2,3: both disabled (0,0)
    { {2, 0}, {3, 0} },
    // Test 15: /(?-ims)/ -> tokens 2,3,4: all disabled (0,0,0)
    { {2, 0}, {3, 0}, {4, 0} },
    // Test 16: /(?-imx)/ -> tokens 2,3,4: all disabled (0,0,0)
    { {2, 0}, {3, 0}, {4, 0} },
    // Test 17: /(?-isx)/ -> tokens 2,3,4: all disabled (0,0,0)
    { {2, 0}, {3, 0}, {4, 0} },
    // Test 18: /(?-msx)/ -> tokens 2,3,4: all disabled (0,0,0)
    { {2, 0}, {3, 0}, {4, 0} },
    // Test 19: /(?-imsx)/ -> tokens 2,3,4,5: all disabled (0,0,0,0)
    { {2, 0}, {3, 0}, {4, 0}, {5, 0} },
    // Test 20: /(?-im)test/ -> tokens 2,3: both disabled (0,0)
    { {2, 0}, {3, 0} },
    // Test 21: /(?i-m)/ -> token 2: i enabled (1), token 3: m disabled (0)
    { {2, 1}, {3, 0} },
    // Test 22: /(?m-i)/ -> token 2: m enabled (1), token 3: i disabled (0)
    { {2, 1}, {3, 0} },
    // Test 23: /(?s-x)/ -> token 2: s enabled (1), token 3: x disabled (0)
    { {2, 1}, {3, 0} },
    // Test 24: /(?x-s)/ -> token 2: x enabled (1), token 3: s disabled (0)
    { {2, 1}, {3, 0} },
    // Test 25: /(?im-sx)/ -> tokens 2,3: enabled (1,1), tokens 4,5: disabled (0,0)
    { {2, 1}, {3, 1}, {4, 0}, {5, 0} },
    // Test 26: /(?sx-im)/ -> tokens 2,3: enabled (1,1), tokens 4,5: disabled (0,0)
    { {2, 1}, {3, 1}, {4, 0}, {5, 0} },
    // Test 27: /(?i-msx)/ -> token 2: enabled (1), tokens 3,4,5: disabled (0,0,0)
    { {2, 1}, {3, 0}, {4, 0}, {5, 0} },
    // Test 28: /(?imx-s)/ -> tokens 2,3,4: enabled (1,1,1), token 5: disabled (0)
    { {2, 1}, {3, 1}, {4, 1}, {5, 0} },
    // Test 29: /(?is-mx)/ -> tokens 2,3: enabled (1,1), tokens 4,5: disabled (0,0)
    { {2, 1}, {3, 1}, {4, 0}, {5, 0} },
    // Test 30: /(?i-m)test/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 31: /(?i-m:test)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 32: /(?-i:test)/ -> token 2: disabled (0)
    { {2, 0} },
    // Test 33: /(?im-sx:pattern)/ -> tokens 2,3: enabled (1,1), tokens 4,5: disabled (0,0)
    { {2, 1}, {3, 1}, {4, 0}, {5, 0} },
    // Test 34: /(?-imsx:pattern)/ -> tokens 2,3,4,5: all disabled (0,0,0,0)
    { {2, 0}, {3, 0}, {4, 0}, {5, 0} },
    // Test 35: /(?i)(?-m)/ -> token 2: i enabled (1), token 5: m disabled (0)
    { {2, 1}, {5, 0} },
    // Test 36: /(?-i)(?m)/ -> token 2: i disabled (0), token 5: m enabled (1)
    { {2, 0}, {5, 1} },
    // Test 37: /(?i-m)(?s-x)/ -> tokens 2,6: enabled (1,1), tokens 3,7: disabled (0,0)
    { {2, 1}, {3, 0}, {6, 1}, {7, 0} },
    // Test 38: /(?i)test(?-i)/ -> token 2: enabled (1), token 8: disabled (0)
    { {2, 1}, {8, 0} },
    // Test 39: /(?-i)test(?i)/ -> token 2: disabled (0), token 9: enabled (1)
    { {2, 0}, {9, 1} },
    // Test 40: /(?im-sx)(?i-m)/ -> tokens 2,3,8: enabled (1,1,1), tokens 4,5,9: disabled (0,0,0)
    { {2, 1}, {3, 1}, {4, 0}, {5, 0}, {8, 1}, {9, 0} },
    // Test 41: /(?i)(?-i)(?i)/ -> tokens 2,8: enabled (1,1), token 5: disabled (0)
    { {2, 1}, {5, 0}, {8, 1} },
    // Test 42: /(?i-m)(?m-i)/ -> tokens 2,6: enabled (1,1), tokens 3,7: disabled (0,0)
    { {2, 1}, {3, 0}, {6, 1}, {7, 0} },
    // Test 43: /(?i-i)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 44: /(?m-m)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 45: /(?im-im)/ -> tokens 2,3: enabled (1,1), tokens 4,5: disabled (0,0)
    { {2, 1}, {3, 1}, {4, 0}, {5, 0} },
    // Test 46: /(?i-imsx)/ -> token 2: enabled (1), tokens 3,4,5,6: disabled (0,0,0,0)
    { {2, 1}, {3, 0}, {4, 0}, {5, 0}, {6, 0} },
    // Test 47: /(?imsx-imsx)/ -> tokens 2,3,4,5: enabled (1,1,1,1), tokens 6,7,8,9: disabled (0,0,0,0)
    { {2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 0}, {7, 0}, {8, 0}, {9, 0} },
    // Test 48: /(?i-m)\btest\b/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 49: /(?i-m)(test)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 50: /(?i-m)(?:test)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 51: /(?i-m)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 52: /(?i-s)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 53: /(?i-x)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 54: /(?m-i)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 55: /(?m-s)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 56: /(?m-x)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 57: /(?s-i)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 58: /(?s-m)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 59: /(?s-x)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 60: /(?x-i)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 61: /(?x-m)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} },
    // Test 62: /(?x-s)/ -> token 2: enabled (1), token 3: disabled (0)
    { {2, 1}, {3, 0} }
}


define_function TestNAVRegexLexerFlagToggles() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Flag Toggles *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_FLAG_TOGGLES_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_FLAG_TOGGLES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_FLAG_TOGGLES_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_FLAG_TOGGLES_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_FLAG_TOGGLES_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
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
                    // Determine expected metadata based on pattern
                    // Tests 31-34: Scoped flag toggle groups (has colon)
                    // All others: Global flag toggle groups (no colon)

                    if (x >= 31 && x <= 34) {
                        // Scoped flag toggle group: (?i-m:...), (?-i:...), etc.
                        if (!NAVAssertScopedFlagGroup(lexer.tokens[y])) {
                            NAVLogTestFailed(x, '[SCOPED_FLAGS]', '[metadata mismatch]')
                            failed = true
                            break
                        }
                    }
                    else {
                        // Check if this is a flag group or a regular group
                        // Flag groups are followed by FLAG tokens
                        if (y + 1 <= lexer.tokenCount &&
                            (lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_CASE_INSENSITIVE ||
                             lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_MULTILINE ||
                             lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_DOTALL ||
                             lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_EXTENDED)) {
                            // Global flag toggle group
                            if (!NAVAssertGlobalFlagGroup(lexer.tokens[y])) {
                                NAVLogTestFailed(x, '[GLOBAL_FLAGS]', '[metadata mismatch]')
                                failed = true
                                break
                            }
                        }
                        else {
                            // Regular group (non-flag)
                            if (!NAVAssertRegularGroup(lexer.tokens[y])) {
                                NAVLogTestFailed(x, '[REGULAR_GROUP]', '[metadata mismatch]')
                                failed = true
                                break
                            }
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


define_function TestNAVRegexLexerFlagTogglesFlagEnabled() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Flag Toggles flagEnabled Field *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_FLAG_TOGGLES_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer y

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_FLAG_TOGGLES_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify flagEnabled field for each flag token specified in the expected array
        {
            stack_var char failed

            for (y = 1; y <= length_array(REGEX_LEXER_FLAG_TOGGLES_EXPECTED_FLAG_ENABLED[x]); y++) {
                stack_var integer tokenIndex
                stack_var integer expectedFlagEnabled

                tokenIndex = REGEX_LEXER_FLAG_TOGGLES_EXPECTED_FLAG_ENABLED[x][y][1]
                expectedFlagEnabled = REGEX_LEXER_FLAG_TOGGLES_EXPECTED_FLAG_ENABLED[x][y][2]

                if (!NAVAssertIntegerEqual("'Token ', itoa(tokenIndex), ' flagEnabled should match expected'", expectedFlagEnabled, lexer.tokens[tokenIndex].flagEnabled)) {
                    NAVLogTestFailed(x, itoa(expectedFlagEnabled), itoa(lexer.tokens[tokenIndex].flagEnabled))
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
