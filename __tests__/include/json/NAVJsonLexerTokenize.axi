PROGRAM_NAME='NAVJsonLexerTokenize'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_VARIABLE

volatile char JSON_LEXER_TOKENIZE_TEST[30][1024]

define_function InitializeJsonLexerTokenizeTestData() {
    // Test 1: Empty object
    JSON_LEXER_TOKENIZE_TEST[1] = '{}'

    // Test 2: Simple object with string
    JSON_LEXER_TOKENIZE_TEST[2] = '{"key":"value"}'

    // Test 3: Object with multiple types
    JSON_LEXER_TOKENIZE_TEST[3] = '{"name":"test","age":25,"active":true}'

    // Test 4: Empty array
    JSON_LEXER_TOKENIZE_TEST[4] = '[]'

    // Test 5: Array with numbers
    JSON_LEXER_TOKENIZE_TEST[5] = '[1,2,3]'

    // Test 6: Nested structures
    JSON_LEXER_TOKENIZE_TEST[6] = '{"items":[1,2],"nested":{"x":true}}'

    // Test 7: Invalid - unterminated string
    JSON_LEXER_TOKENIZE_TEST[7] = '{"key":"unterminated'

    // Test 8: Invalid - unexpected character
    JSON_LEXER_TOKENIZE_TEST[8] = '{@}'

    // Test 9: All literals (true, false, null)
    JSON_LEXER_TOKENIZE_TEST[9] = '[true,false,null]'

    // Test 10: Negative numbers
    JSON_LEXER_TOKENIZE_TEST[10] = '[-1,-42,-999]'

    // Test 11: Decimal numbers
    JSON_LEXER_TOKENIZE_TEST[11] = '[3.14,0.5,123.456]'

    // Test 12: Numbers with exponents
    JSON_LEXER_TOKENIZE_TEST[12] = '[1e10,2.5E-3,1.23e+4]'

    // Test 13: Empty string
    JSON_LEXER_TOKENIZE_TEST[13] = '{"empty":""}'

    // Test 14: String with escape sequences
    JSON_LEXER_TOKENIZE_TEST[14] = '{"text":"Hello\nWorld\t!"}'

    // Test 15: String with unicode escape
    JSON_LEXER_TOKENIZE_TEST[15] = '{"emoji":"\u263A"}'

    // Test 16: Array with mixed types
    JSON_LEXER_TOKENIZE_TEST[16] = '[1,"two",true,null,false]'

    // Test 17: Deeply nested arrays
    JSON_LEXER_TOKENIZE_TEST[17] = '[[[[1]]]]'

    // Test 18: Object with whitespace
    JSON_LEXER_TOKENIZE_TEST[18] = "'{  "key"  :  "value"  }'" // spaces

    // Test 19: Number starting with zero
    JSON_LEXER_TOKENIZE_TEST[19] = '[0,0.5,0.123]'

    // Test 20: Invalid - invalid number format
    JSON_LEXER_TOKENIZE_TEST[20] = '[01]'

    set_length_array(JSON_LEXER_TOKENIZE_TEST, 20)
}


DEFINE_CONSTANT

constant char JSON_LEXER_TOKENIZE_EXPECTED_RESULT[] = {
    true,   // Test 1: Empty object
    true,   // Test 2: Simple object with string
    true,   // Test 3: Object with multiple types
    true,   // Test 4: Empty array
    true,   // Test 5: Array with numbers
    true,   // Test 6: Nested structures
    false,  // Test 7: Invalid - unterminated string
    false,  // Test 8: Invalid - unexpected character
    true,   // Test 9: All literals (true, false, null)
    true,   // Test 10: Negative numbers
    true,   // Test 11: Decimal numbers
    true,   // Test 12: Numbers with exponents
    true,   // Test 13: Empty string
    true,   // Test 14: String with escape sequences
    true,   // Test 15: String with unicode escape
    true,   // Test 16: Array with mixed types
    true,   // Test 17: Deeply nested arrays
    true,   // Test 18: Object with whitespace
    true,   // Test 19: Number starting with zero
    false   // Test 20: Invalid - invalid number format
}

constant integer JSON_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[] = {
    3,      // Test 1: {, }, EOF
    6,      // Test 2: {, "key", :, "value", }, EOF
    14,     // Test 3: Multiple tokens
    3,      // Test 4: [, ], EOF
    8,      // Test 5: [, 1, ,, 2, ,, 3, ], EOF
    18,     // Test 6: Nested structure tokens
    0,      // Test 7: Error case
    0,      // Test 8: Error case
    8,      // Test 9: [, true, ,, false, ,, null, ], EOF
    8,      // Test 10: [, -1, ,, -42, ,, -999, ], EOF
    8,      // Test 11: [, 3.14, ,, 0.5, ,, 123.456, ], EOF
    8,      // Test 12: [, 1e10, ,, 2.5E-3, ,, 1.23e+4, ], EOF
    6,      // Test 13: {, "empty", :, "", }, EOF
    6,      // Test 14: {, "text", :, "Hello\nWorld\t!", }, EOF
    6,      // Test 15: {, "emoji", :, "\u263A", }, EOF
    12,     // Test 16: [, 1, ,, "two", ,, true, ,, null, ,, false, ], EOF
    10,     // Test 17: [, [, [, [, 1, ], ], ], ], EOF
    6,      // Test 18: {, "key", :, "value", }, EOF
    8,      // Test 19: [, 0, ,, 0.5, ,, 0.123, ], EOF
    0       // Test 20: Error case
}


// Expected token types for each test
constant integer JSON_LEXER_TOKENIZE_EXPECTED_TYPES[][] = {
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACE,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACE,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACE,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACE,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACE,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_TRUE,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACE,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACE,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_LEFT_BRACE,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_TRUE,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACE,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACE,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        // Error case - no tokens expected
        0
    },
    {
        // Error case - no tokens expected
        0
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_TRUE,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_FALSE,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NULL,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACE,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACE,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACE,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACE,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACE,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACE,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_TRUE,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NULL,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_FALSE,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACE,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_COLON,
        NAV_JSON_TOKEN_TYPE_STRING,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACE,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        NAV_JSON_TOKEN_TYPE_LEFT_BRACKET,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_COMMA,
        NAV_JSON_TOKEN_TYPE_NUMBER,
        NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET,
        NAV_JSON_TOKEN_TYPE_EOF
    },
    {
        // Error case - no tokens expected
        0
    }
}

// Expected token values for each test
constant char JSON_LEXER_TOKENIZE_EXPECTED_VALUES[][][NAV_JSON_LEXER_MAX_TOKEN_LENGTH] = {
    {
        '{',
        '}',
        ''
    },
    {
        '{',
        '"key"',
        ':',
        '"value"',
        '}',
        ''
    },
    {
        '{',
        '"name"',
        ':',
        '"test"',
        ',',
        '"age"',
        ':',
        '25',
        ',',
        '"active"',
        ':',
        'true',
        '}',
        ''
    },
    {
        '[',
        ']',
        ''
    },
    {
        '[',
        '1',
        ',',
        '2',
        ',',
        '3',
        ']',
        ''
    },
    {
        '{',
        '"items"',
        ':',
        '[',
        '1',
        ',',
        '2',
        ']',
        ',',
        '"nested"',
        ':',
        '{',
        '"x"',
        ':',
        'true',
        '}',
        '}',
        ''
    },
    {
        // Error case - no values expected
        ''
    },
    {
        // Error case - no values expected
        ''
    },
    {
        '[',
        'true',
        ',',
        'false',
        ',',
        'null',
        ']',
        ''
    },
    {
        '[',
        '-1',
        ',',
        '-42',
        ',',
        '-999',
        ']',
        ''
    },
    {
        '[',
        '3.14',
        ',',
        '0.5',
        ',',
        '123.456',
        ']',
        ''
    },
    {
        '[',
        '1e10',
        ',',
        '2.5E-3',
        ',',
        '1.23e+4',
        ']',
        ''
    },
    {
        '{',
        '"empty"',
        ':',
        '""',
        '}',
        ''
    },
    {
        '{',
        '"text"',
        ':',
        '"Hello\nWorld\t!"',
        '}',
        ''
    },
    {
        '{',
        '"emoji"',
        ':',
        '"\u263A"',
        '}',
        ''
    },
    {
        '[',
        '1',
        ',',
        '"two"',
        ',',
        'true',
        ',',
        'null',
        ',',
        'false',
        ']',
        ''
    },
    {
        '[',
        '[',
        '[',
        '[',
        '1',
        ']',
        ']',
        ']',
        ']',
        ''
    },
    {
        '{',
        '"key"',
        ':',
        '"value"',
        '}',
        ''
    },
    {
        '[',
        '0',
        ',',
        '0.5',
        ',',
        '0.123',
        ']',
        ''
    },
    {
        // Error case - no values expected
        ''
    }
}


define_function TestNAVJsonLexerTokenize() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonLexerTokenize'")

    InitializeJsonLexerTokenizeTestData()

    for (x = 1; x <= length_array(JSON_LEXER_TOKENIZE_TEST); x++) {
        stack_var char result
        stack_var integer j
        stack_var char failed
        stack_var _NAVJsonLexer lexer

        result = NAVJsonLexerTokenize(lexer, JSON_LEXER_TOKENIZE_TEST[x])

        if (!NAVAssertBooleanEqual('Should match expected result',
                                   JSON_LEXER_TOKENIZE_EXPECTED_RESULT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_LEXER_TOKENIZE_EXPECTED_RESULT[x]),
                            NAVBooleanToString(result))
            continue
        }

        if (!JSON_LEXER_TOKENIZE_EXPECTED_RESULT[x]) {
            // Expected failure case, no further checks
            NAVLogTestPassed(x)
            continue
        }

        // Assert token count
        if (!NAVAssertIntegerEqual('Token count should match',
                                   JSON_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[x],
                                   lexer.tokenCount)) {
            NAVLogTestFailed(x,
                            itoa(JSON_LEXER_TOKENIZE_EXPECTED_TOKEN_COUNT[x]),
                            itoa(lexer.tokenCount))
            continue
        }

        // Assert each token type and value
        for (j = 1; j <= lexer.tokenCount; j++) {
            if (!NAVAssertIntegerEqual('Token type should match',
                                       JSON_LEXER_TOKENIZE_EXPECTED_TYPES[x][j],
                                       lexer.tokens[j].type)) {
                NAVLogTestFailed(x,
                                NAVJsonLexerGetTokenType(JSON_LEXER_TOKENIZE_EXPECTED_TYPES[x][j]),
                                NAVJsonLexerGetTokenType(lexer.tokens[j].type))
                failed = true
                break
            }

            // Assert line number (all current tests are single-line, so line should be 1)
            if (!NAVAssertIntegerEqual('Token line should be 1',
                                       1,
                                       lexer.tokens[j].line)) {
                NAVLogTestFailed(x, '1', itoa(lexer.tokens[j].line))
                failed = true
                break
            }

            // Assert column number is positive
            if (!NAVAssertIntegerGreaterThan('Token column should be positive',
                                             0,
                                             lexer.tokens[j].column)) {
                NAVLogTestFailed(x, '> 0', itoa(lexer.tokens[j].column))
                failed = true
                break
            }

            // Assert start position is valid
            if (!NAVAssertIntegerGreaterThan('Token start should be positive',
                                             0,
                                             lexer.tokens[j].start)) {
                NAVLogTestFailed(x, '> 0', itoa(lexer.tokens[j].start))
                failed = true
                break
            }

            // Assert end position is valid and >= start (skip for EOF tokens)
            if (lexer.tokens[j].type != NAV_JSON_TOKEN_TYPE_EOF) {
                if (!NAVAssertIntegerGreaterThanOrEqual('Token end should be >= start',
                                                        lexer.tokens[j].start,
                                                        lexer.tokens[j].end)) {
                    NAVLogTestFailed(x, "'>= ', itoa(lexer.tokens[j].start)", itoa(lexer.tokens[j].end))
                    failed = true
                    break
                }
            }

            // Skip value check for EOF token
            if (lexer.tokens[j].type == NAV_JSON_TOKEN_TYPE_EOF) {
                continue
            }

            if (!NAVAssertStringEqual('Token value should match',
                                      JSON_LEXER_TOKENIZE_EXPECTED_VALUES[x][j],
                                      lexer.tokens[j].value)) {
                NAVLogTestFailed(x,
                                JSON_LEXER_TOKENIZE_EXPECTED_VALUES[x][j],
                                lexer.tokens[j].value)
                failed = true
                break
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonLexerTokenize'")
}
