PROGRAM_NAME='NAVRegexLexerNamedBackreferences'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Named backreferences come in two syntaxes:
// 1. PCRE style: \k<name>  (already implemented)
// 2. Python style: (?P=name)  (to be implemented for consistency with (?P<name>) groups)
//
// Both should tokenize as REGEX_TOKEN_BACKREF_NAMED with the name stored in token.name

constant char REGEX_LEXER_NAMED_BACKREF_PATTERN_TEST[][255] = {
    // === PCRE-style named backreferences: \k<name> ===
    '/\k<word>/',                   // 1: Basic PCRE-style named backref
    '/\k<name>/',                   // 2: Different name
    '/\k<first>/',                  // 3: Common group name
    '/\k<group1>/',                 // 4: Alphanumeric name
    '/\k<_private>/',               // 5: Underscore prefix
    '/\k<test_name>/',              // 6: Underscore in name
    '/\k<CamelCase>/',              // 7: Mixed case
    '/\k<UPPERCASE>/',              // 8: All uppercase

    // === PCRE-style in patterns ===
    '/(?P<word>a)\k<word>/',        // 9: With Python-style group definition
    '/(?<word>a)\k<word>/',         // 10: With PCRE angle bracket group
    '/(?''word''a)\k<word>/',         // 11: With PCRE quote group
    '/test\k<name>test/',           // 12: Backref in middle
    '/(a)\k<word>/',                // 13: With numbered group before
    '/\k<word>(a)/',                // 14: With numbered group after

    // === Multiple PCRE-style backrefs ===
    '/\k<first>\k<second>/',        // 15: Two different backrefs
    '/\k<word>\k<word>/',           // 16: Same backref twice
    '/\k<a>\k<b>\k<c>/',            // 17: Three different backrefs

    // === PCRE-style with quantifiers ===
    '/\k<word>+/',                  // 18: With plus
    '/\k<word>*/',                  // 19: With star
    '/\k<word>?/',                  // 20: With question mark
    '/\k<word>{2}/',                // 21: With bounded quantifier
    '/\k<word>{1,3}/',              // 22: With ranged quantifier

    // === PCRE-style in groups ===
    '/(\k<word>)/',                 // 23: In capturing group
    '/(?:\k<word>)/',               // 24: In non-capturing group
    '/(?=\k<word>)/',               // 25: In positive lookahead
    '/(?!\k<word>)/',               // 26: In negative lookahead

    // === Python-style named backreferences: (?P=name) ===
    '/(?P=word)/',                  // 27: Basic Python-style backref
    '/(?P=name)/',                  // 28: Different name
    '/(?P=first)/',                 // 29: Common group name
    '/(?P=group1)/',                // 30: Alphanumeric name
    '/(?P=_private)/',              // 31: Underscore prefix
    '/(?P=test_name)/',             // 32: Underscore in name
    '/(?P=CamelCase)/',             // 33: Mixed case
    '/(?P=UPPERCASE)/',             // 34: All uppercase

    // === Python-style in patterns ===
    '/(?P<word>a)(?P=word)/',       // 35: With matching Python group
    '/(?<word>a)(?P=word)/',        // 36: Python backref to PCRE group
    '/(?''word''a)(?P=word)/',        // 37: Python backref to quote group
    '/test(?P=name)test/',          // 38: Backref in middle
    '/(a)(?P=word)/',               // 39: With numbered group before
    '/(?P=word)(a)/',               // 40: With numbered group after

    // === Multiple Python-style backrefs ===
    '/(?P=first)(?P=second)/',      // 41: Two different backrefs
    '/(?P=word)(?P=word)/',         // 42: Same backref twice
    '/(?P=a)(?P=b)(?P=c)/',         // 43: Three different backrefs

    // === Python-style with quantifiers ===
    '/(?P=word)+/',                 // 44: With plus
    '/(?P=word)*/',                 // 45: With star
    '/(?P=word)?/',                 // 46: With question mark
    '/(?P=word){2}/',               // 47: With bounded quantifier
    '/(?P=word){1,3}/',             // 48: With ranged quantifier

    // === Python-style in groups ===
    '/((?P=word))/',                // 49: In capturing group
    '/(?:(?P=word))/',              // 50: In non-capturing group
    '/(?=(?P=word))/',              // 51: In positive lookahead
    '/(?!(?P=word))/',              // 52: In negative lookahead

    // === Mixed syntax ===
    '/\k<first>(?P=second)/',       // 53: PCRE then Python
    '/(?P=first)\k<second>/',       // 54: Python then PCRE
    '/(?P<name>a)\k<name>(?P=name)/',   // 55: Group with both backref styles

    // === Complex patterns ===
    '/(?P<word>\w+)\s+(?P=word)/',  // 56: Pattern with content
    '/(?P<tag><\w+>).*?(?P=tag)/',  // 57: HTML-like tag matching
    '/(?P<quote>[''"]).*?(?P=quote)/', // 58: Quote matching

    // === Edge cases ===
    '/^(?P=start)/',                // 59: With start anchor
    '/(?P=end)$/',                  // 60: With end anchor
    '/(?P<a>x)(?P=a)|(?P<b>y)(?P=b)/',  // 61: Alternation with backrefs
    '/(?P<outer>(?P<inner>a)(?P=inner))(?P=outer)/'  // 62: Nested groups with backrefs
}

// Expected tokens for each pattern
// We'll verify the token sequence is correct
constant integer REGEX_LEXER_NAMED_BACKREF_EXPECTED_TOKENS[][] = {
    // Test 1: /\k<word>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 2: /\k<name>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 3: /\k<first>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 4: /\k<group1>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 5: /\k<_private>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 6: /\k<test_name>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 7: /\k<CamelCase>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 8: /\k<UPPERCASE>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 9: /(?P<word>a)\k<word>/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 10: /(?<word>a)\k<word>/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 11: /(?'word'a)\k<word>/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 12: /test\k<name>test/
    {
        REGEX_TOKEN_CHAR,           // t
        REGEX_TOKEN_CHAR,           // e
        REGEX_TOKEN_CHAR,           // s
        REGEX_TOKEN_CHAR,           // t
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_CHAR,           // t
        REGEX_TOKEN_CHAR,           // e
        REGEX_TOKEN_CHAR,           // s
        REGEX_TOKEN_CHAR,           // t
        REGEX_TOKEN_EOF
    },
    // Test 13: /(a)\k<word>/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 14: /\k<word>(a)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 15: /\k<first>\k<second>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 16: /\k<word>\k<word>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 17: /\k<a>\k<b>\k<c>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 18: /\k<word>+/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    // Test 19: /\k<word>*/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    // Test 20: /\k<word>?/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    // Test 21: /\k<word>{2}/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    // Test 22: /\k<word>{1,3}/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    // Test 23: /(\k<word>)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 24: /(?:\k<word>)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 25: /(?=\k<word>)/
    {
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 26: /(?!\k<word>)/
    {
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 27: /(?P=word)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 28: /(?P=name)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 29: /(?P=first)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 30: /(?P=group1)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 31: /(?P=_private)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 32: /(?P=test_name)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 33: /(?P=CamelCase)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 34: /(?P=UPPERCASE)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 35: /(?P<word>a)(?P=word)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 36: /(?<word>a)(?P=word)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 37: /(?'word'a)(?P=word)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 38: /test(?P=name)test/
    {
        REGEX_TOKEN_CHAR,           // t
        REGEX_TOKEN_CHAR,           // e
        REGEX_TOKEN_CHAR,           // s
        REGEX_TOKEN_CHAR,           // t
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_CHAR,           // t
        REGEX_TOKEN_CHAR,           // e
        REGEX_TOKEN_CHAR,           // s
        REGEX_TOKEN_CHAR,           // t
        REGEX_TOKEN_EOF
    },
    // Test 39: /(a)(?P=word)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 40: /(?P=word)(a)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 41: /(?P=first)(?P=second)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 42: /(?P=word)(?P=word)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 43: /(?P=a)(?P=b)(?P=c)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 44: /(?P=word)+/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_EOF
    },
    // Test 45: /(?P=word)*/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_STAR,
        REGEX_TOKEN_EOF
    },
    // Test 46: /(?P=word)?/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_QUESTIONMARK,
        REGEX_TOKEN_EOF
    },
    // Test 47: /(?P=word){2}/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    // Test 48: /(?P=word){1,3}/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    // Test 49: /((?P=word))/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 50: /(?:(?P=word))/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 51: /(?=(?P=word))/
    {
        REGEX_TOKEN_LOOKAHEAD_POSITIVE,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 52: /(?!(?P=word))/
    {
        REGEX_TOKEN_LOOKAHEAD_NEGATIVE,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_EOF
    },
    // Test 53: /\k<first>(?P=second)/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 54: /(?P=first)\k<second>/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 55: /(?P<name>a)\k<name>(?P=name)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // a
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 56: /(?P<word>\w+)\s+(?P=word)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_ALPHA,      // \w
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_WHITESPACE,     // \s
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 57: /(?P<tag><\w+>).*?(?P=tag)/
    // Note: Lazy quantifier *? is tokenized as STAR with lazy flag, not separate QUESTIONMARK
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,           // <
        REGEX_TOKEN_ALPHA,      // \w
        REGEX_TOKEN_PLUS,
        REGEX_TOKEN_CHAR,           // >
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_DOT,            // .
        REGEX_TOKEN_STAR,           // .* (lazy flag set internally)
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 58: /(?P<quote>['"]).*?(?P=quote)/
    // Note: Lazy quantifier *? is tokenized as STAR with lazy flag, not separate QUESTIONMARK
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR_CLASS,         // ['"]
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_DOT,                // .
        REGEX_TOKEN_STAR,               // .* (lazy flag set internally)
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 59: /^(?P=start)/
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 60: /(?P=end)$/
    {
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    },
    // Test 61: /(?P<a>x)(?P=a)|(?P<b>y)(?P=b)/
    {
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,               // x
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_ALTERNATION,
        REGEX_TOKEN_GROUP_START,
        REGEX_TOKEN_CHAR,               // y
        REGEX_TOKEN_GROUP_END,
        REGEX_TOKEN_BACKREF_NAMED,
        REGEX_TOKEN_EOF
    },
    // Test 62: /(?P<outer>(?P<inner>a)(?P=inner))(?P=outer)/
    {
        REGEX_TOKEN_GROUP_START,        // outer start
        REGEX_TOKEN_GROUP_START,        // inner start
        REGEX_TOKEN_CHAR,               // a
        REGEX_TOKEN_GROUP_END,          // inner end
        REGEX_TOKEN_BACKREF_NAMED,      // (?P=inner)
        REGEX_TOKEN_GROUP_END,          // outer end
        REGEX_TOKEN_BACKREF_NAMED,      // (?P=outer)
        REGEX_TOKEN_EOF
    }
}

// Expected backref names for validation
constant char REGEX_LEXER_NAMED_BACKREF_EXPECTED_NAMES[][][3][MAX_REGEX_GROUP_NAME_LENGTH] = {
    // Tests 1-8: Single PCRE-style backrefs
    { {'1', 'word'} },          // Test 1
    { {'1', 'name'} },          // Test 2
    { {'1', 'first'} },         // Test 3
    { {'1', 'group1'} },        // Test 4
    { {'1', '_private'} },      // Test 5
    { {'1', 'test_name'} },     // Test 6
    { {'1', 'CamelCase'} },     // Test 7
    { {'1', 'UPPERCASE'} },     // Test 8

    // Tests 9-14: PCRE-style in context
    { {'4', 'word'} },          // Test 9: token 4 is the backref
    { {'4', 'word'} },          // Test 10
    { {'4', 'word'} },          // Test 11
    { {'5', 'name'} },          // Test 12: token 5 (after "test")
    { {'4', 'word'} },          // Test 13
    { {'1', 'word'} },          // Test 14

    // Tests 15-17: Multiple PCRE-style backrefs
    { {'1', 'first'}, {'2', 'second'} },    // Test 15
    { {'1', 'word'}, {'2', 'word'} },       // Test 16
    { {'1', 'a'}, {'2', 'b'}, {'3', 'c'} }, // Test 17

    // Tests 18-22: PCRE-style with quantifiers
    { {'1', 'word'} },          // Test 18
    { {'1', 'word'} },          // Test 19
    { {'1', 'word'} },          // Test 20
    { {'1', 'word'} },          // Test 21
    { {'1', 'word'} },          // Test 22

    // Tests 23-26: PCRE-style in groups
    { {'2', 'word'} },          // Test 23
    { {'2', 'word'} },          // Test 24
    { {'2', 'word'} },          // Test 25
    { {'2', 'word'} },          // Test 26

    // Tests 27-34: Single Python-style backrefs
    { {'1', 'word'} },          // Test 27
    { {'1', 'name'} },          // Test 28
    { {'1', 'first'} },         // Test 29
    { {'1', 'group1'} },        // Test 30
    { {'1', '_private'} },      // Test 31
    { {'1', 'test_name'} },     // Test 32
    { {'1', 'CamelCase'} },     // Test 33
    { {'1', 'UPPERCASE'} },     // Test 34

    // Tests 35-40: Python-style in context
    { {'4', 'word'} },          // Test 35
    { {'4', 'word'} },          // Test 36
    { {'4', 'word'} },          // Test 37
    { {'5', 'name'} },          // Test 38: token 5 (after "test")
    { {'4', 'word'} },          // Test 39
    { {'1', 'word'} },          // Test 40

    // Tests 41-43: Multiple Python-style backrefs
    { {'1', 'first'}, {'2', 'second'} },    // Test 41
    { {'1', 'word'}, {'2', 'word'} },       // Test 42
    { {'1', 'a'}, {'2', 'b'}, {'3', 'c'} }, // Test 43

    // Tests 44-48: Python-style with quantifiers
    { {'1', 'word'} },          // Test 44
    { {'1', 'word'} },          // Test 45
    { {'1', 'word'} },          // Test 46
    { {'1', 'word'} },          // Test 47
    { {'1', 'word'} },          // Test 48

    // Tests 49-52: Python-style in groups
    { {'2', 'word'} },          // Test 49
    { {'2', 'word'} },          // Test 50
    { {'2', 'word'} },          // Test 51
    { {'2', 'word'} },          // Test 52

    // Tests 53-55: Mixed syntax
    { {'1', 'first'}, {'2', 'second'} },    // Test 53
    { {'1', 'first'}, {'2', 'second'} },    // Test 54
    { {'4', 'name'}, {'5', 'name'} },       // Test 55 - has 2 backrefs (PCRE + Python)

    // Tests 56-58: Complex patterns
    { {'7', 'word'} },          // Test 56
    { {'9', 'tag'} },           // Test 57 - BACKREF_NAMED at position 9 (lazy flag on STAR, not separate token)
    { {'6', 'quote'} },         // Test 58 - BACKREF_NAMED at position 6 - index adjusted for lazy quantifier

    // Tests 59-62: Edge cases
    { {'2', 'start'} },         // Test 59
    { {'1', 'end'} },           // Test 60
    { {'4', 'a'}, {'9', 'b'} }, // Test 61
    { {'5', 'inner'}, {'7', 'outer'} }  // Test 62
}


/**
 * Test NAVRegexLexer named backreference tokenization
 * Verifies both PCRE-style (\k<name>) and Python-style ((?P=name))
 */
define_function TestNAVRegexLexerNamedBackreferences() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Named Backreferences *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_NAMED_BACKREF_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer y

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_NAMED_BACKREF_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify token count matches expected
        if (!NAVAssertIntegerEqual('Token count should match expected',
                                     length_array(REGEX_LEXER_NAMED_BACKREF_EXPECTED_TOKENS[x]),
                                     lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_LEXER_NAMED_BACKREF_EXPECTED_TOKENS[x])), itoa(lexer.tokenCount))
            continue
        }

        // Verify each token type
        for (y = 1; y <= length_array(REGEX_LEXER_NAMED_BACKREF_EXPECTED_TOKENS[x]); y++) {
            if (!NAVAssertIntegerEqual('Token type should match expected at position',
                                        REGEX_LEXER_NAMED_BACKREF_EXPECTED_TOKENS[x][y],
                                        lexer.tokens[y].type)) {
                NAVLogTestFailed(x,
                                NAVRegexLexerGetTokenType(REGEX_LEXER_NAMED_BACKREF_EXPECTED_TOKENS[x][y]),
                                NAVRegexLexerGetTokenType(lexer.tokens[y].type))
                break
            }
        }

        if (y <= length_array(REGEX_LEXER_NAMED_BACKREF_EXPECTED_TOKENS[x])) {
            continue
        }

        // Test 57 & 58: Verify lazy quantifier flag is set on STAR token
        if (x == 57) {
            // Test 57: /(?P<tag><\w+>).*?(?P=tag)/ - STAR token at position 8
            if (!NAVAssertTrue('STAR token should have isLazy flag set',
                               lexer.tokens[8].isLazy)) {
                NAVLogTestFailed(x, 'isLazy=true', 'isLazy=false')
                continue
            }
        }
        else if (x == 58) {
            // Test 58: /(?P<quote>['"]).*?(?P=quote)/ - STAR token at position 5
            if (!NAVAssertTrue('STAR token should have isLazy flag set',
                               lexer.tokens[5].isLazy)) {
                NAVLogTestFailed(x, 'isLazy=true', 'isLazy=false')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}


/**
 * Test NAVRegexLexer named backreference name extraction
 * Verifies that the name field is correctly populated for both syntaxes
 */
define_function TestNAVRegexLexerNamedBackreferencesNames() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Named Backreferences Names *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_NAMED_BACKREF_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer y
        stack_var char testPassed

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_NAMED_BACKREF_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        testPassed = true

        // For each expected backref name
        for (y = 1; y <= length_array(REGEX_LEXER_NAMED_BACKREF_EXPECTED_NAMES[x]); y++) {
            stack_var integer tokenIndex
            stack_var char expectedName[MAX_REGEX_GROUP_NAME_LENGTH]

            if (REGEX_LEXER_NAMED_BACKREF_EXPECTED_NAMES[x][y][1] == '') {
                break  // No more expected names
            }

            tokenIndex = atoi(REGEX_LEXER_NAMED_BACKREF_EXPECTED_NAMES[x][y][1])
            expectedName = REGEX_LEXER_NAMED_BACKREF_EXPECTED_NAMES[x][y][2]

            // Verify token at this index is a named backref
            if (!NAVAssertIntegerEqual('Token should be a named backreference',
                                        REGEX_TOKEN_BACKREF_NAMED,
                                        lexer.tokens[tokenIndex].type)) {
                NAVLogTestFailed(x,
                                NAVRegexLexerGetTokenType(REGEX_TOKEN_BACKREF_NAMED),
                                NAVRegexLexerGetTokenType(lexer.tokens[tokenIndex].type))
                testPassed = false
                break
            }

            // Verify the name matches
            if (!NAVAssertStringEqual('Named backref should have correct name',
                                       expectedName,
                                       lexer.tokens[tokenIndex].name)) {
                NAVLogTestFailed(x, expectedName, lexer.tokens[tokenIndex].name)
                testPassed = false
                break
            }
        }

        if (testPassed) {
            NAVLogTestPassed(x)
        }
    }
}