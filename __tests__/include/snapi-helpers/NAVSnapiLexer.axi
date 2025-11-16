PROGRAM_NAME='NAVSnapiLexer'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.SnapiLexer.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char SNAPI_LEXER_BASIC_TEST[][255] = {
    'INPUT-HDMI,1',                             // 1: Simple input command
    '?VERSION',                                  // 2: Simple query command
    'FOO-"bar,baz"',                            // 3: Input with quoted string containing comma
    'COMMAND-,ARG2,"""ARG3"""',                 // 4: Mixed arguments with escaped quotes
    'HEADER-Value,ANOTHER,"Complex,Value",'     // 5: Complex input with multiple tokens
}

constant integer SNAPI_LEXER_BASIC_EXPECTED_TOKENS[][] = {
    {
        NAV_SNAPI_TOKEN_TYPE_IDENTIFIER,
        NAV_SNAPI_TOKEN_TYPE_DASH,
        NAV_SNAPI_TOKEN_TYPE_IDENTIFIER,
        NAV_SNAPI_TOKEN_TYPE_COMMA,
        NAV_SNAPI_TOKEN_TYPE_IDENTIFIER,
        NAV_SNAPI_TOKEN_TYPE_EOF
    },
    {
        NAV_SNAPI_TOKEN_TYPE_QUESTIONMARK,
        NAV_SNAPI_TOKEN_TYPE_IDENTIFIER,
        NAV_SNAPI_TOKEN_TYPE_EOF
    },
    {
        NAV_SNAPI_TOKEN_TYPE_IDENTIFIER,
        NAV_SNAPI_TOKEN_TYPE_DASH,
        NAV_SNAPI_TOKEN_TYPE_STRING,
        NAV_SNAPI_TOKEN_TYPE_EOF
    },
    {
        NAV_SNAPI_TOKEN_TYPE_IDENTIFIER,
        NAV_SNAPI_TOKEN_TYPE_DASH,
        NAV_SNAPI_TOKEN_TYPE_COMMA,
        NAV_SNAPI_TOKEN_TYPE_IDENTIFIER,
        NAV_SNAPI_TOKEN_TYPE_COMMA,
        NAV_SNAPI_TOKEN_TYPE_STRING,
        NAV_SNAPI_TOKEN_TYPE_EOF
    },
    {
        NAV_SNAPI_TOKEN_TYPE_IDENTIFIER,
        NAV_SNAPI_TOKEN_TYPE_DASH,
        NAV_SNAPI_TOKEN_TYPE_IDENTIFIER,
        NAV_SNAPI_TOKEN_TYPE_COMMA,
        NAV_SNAPI_TOKEN_TYPE_IDENTIFIER,
        NAV_SNAPI_TOKEN_TYPE_COMMA,
        NAV_SNAPI_TOKEN_TYPE_STRING,
        NAV_SNAPI_TOKEN_TYPE_COMMA,
        NAV_SNAPI_TOKEN_TYPE_EOF
    }
}

constant char SNAPI_LEXER_BASIC_EXPECTED_TOKEN_VALUES[][][50] = {
    {
        'INPUT',
        '-',
        'HDMI',
        ',',
        '1',
        ''
    },
    {
        '?',
        'VERSION',
        ''
    },
    {
        'FOO',
        '-',
        '"bar,baz"',
        ''
    },
    {
        'COMMAND',
        '-',
        ',',
        'ARG2',
        ',',
        '"""ARG3"""',
        ''
    },
    {
        'HEADER',
        '-',
        'Value',
        ',',
        'ANOTHER',
        ',',
        '"Complex,Value"',
        ',',
        ''
    }
}


define_function TestNAVSnapiLexerBasic() {
    stack_var integer x

    NAVLog("'***************** NAVSnapiLexer *******************'")

    for (x = 1; x <= length_array(SNAPI_LEXER_BASIC_TEST); x++) {
        stack_var _NAVSnapiLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVSnapiLexerTokenize(lexer, SNAPI_LEXER_BASIC_TEST[x]))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(SNAPI_LEXER_BASIC_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", SNAPI_LEXER_BASIC_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVSnapiLexerGetTokenType(SNAPI_LEXER_BASIC_EXPECTED_TOKENS[x][y]), NAVSnapiLexerGetTokenType(lexer.tokens[y].type))
                    failed = true
                    break
                }

                if (!NAVAssertStringEqual("'Token ', itoa(y), ' value should be correct'", SNAPI_LEXER_BASIC_EXPECTED_TOKEN_VALUES[x][y], lexer.tokens[y].value)) {
                    NAVLogTestFailed(x, SNAPI_LEXER_BASIC_EXPECTED_TOKEN_VALUES[x][y], lexer.tokens[y].value)
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
