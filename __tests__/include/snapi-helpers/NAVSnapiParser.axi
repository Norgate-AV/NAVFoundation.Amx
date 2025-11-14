PROGRAM_NAME='NAVSnapiParser'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.SnapiParser.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

constant char SNAPI_PARSER_BASIC_TEST[][255] = {
    'INPUT-HDMI,1',                             // 1: Simple input command
    '?VERSION',                                  // 2: Simple query command
    'FOO-"bar,baz"',                            // 3: Input with quoted string containing comma
    'COMMAND-,ARG2,"""ARG3"""',                 // 4: Mixed arguments with escaped quotes
    'HEADER-Value,ANOTHER,"Complex,Value",',     // 5: Complex input with multiple tokens and trailing comma
    'POWER',                                     // 6: Header only, no dash
    'VOLUME-50',                                 // 7: Single parameter
    'TEXT-""',                                   // 8: Empty quoted string parameter
    'DATA-,,,',                                  // 9: Multiple empty parameters
    'CMD-" Leading space"',                     // 10: Leading whitespace in quoted string
    'CMD-"Trailing space "',                    // 11: Trailing whitespace in quoted string
    'CMD-" Both sides "',                       // 12: Both leading and trailing whitespace
    'CMD-ARG1 WITH SPACES,ARG2',                // 13: Whitespace in unquoted parameter
    'SPECIAL-@#$%,~/\\',                         // 14: Special characters in parameters
    'ESCAPE-"Quote""inside"',                  // 15: Escaped quote at end of word
    'MULTI-""""',                               // 16: Double escaped quotes (empty with escaped quote)
    'COMBO-A,"B",C,"D,E",F',                    // 17: Mix of quoted and unquoted
    'NUMBERS-123,456.789,"-10"',                // 18: Numeric parameters (negative must be quoted)
    'LONG-A,B,C,D,E,F,G,H,I,J',                 // 19: Many parameters
    'WHITESPACE- , , '                          // 20: Parameters with just whitespace
}

constant char SNAPI_PARSER_BASIC_EXPECTED_HEADER_VALUES[][50] = {
    'INPUT',
    '?VERSION',
    'FOO',
    'COMMAND',
    'HEADER',
    'POWER',
    'VOLUME',
    'TEXT',
    'DATA',
    'CMD',
    'CMD',
    'CMD',
    'CMD',
    'SPECIAL',
    'ESCAPE',
    'MULTI',
    'COMBO',
    'NUMBERS',
    'LONG',
    'WHITESPACE'
}

constant integer SNAPI_PARSER_BASIC_EXPECTED_ARG_COUNTS[] = {
    2,
    0,
    1,
    3,
    4,
    0,
    1,
    1,
    4,
    1,
    1,
    1,
    2,
    2,
    1,
    1,
    5,
    3,
    10,
    3
}

constant char SNAPI_PARSER_BASIC_EXPECTED_ARG_VALUES[][][50] = {
    {
        'HDMI',
        '1'
    },
    {
        // No args for query
        ''
    },
    {
        'bar,baz'
    },
    {
        '',
        'ARG2',
        '"ARG3"'
    },
    {
        'Value',
        'ANOTHER',
        'Complex,Value',
        ''
    },
    {
        // No args, header only
        ''
    },
    {
        '50'
    },
    {
        ''
    },
    {
        '',
        '',
        '',
        ''
    },
    {
        ' Leading space'
    },
    {
        'Trailing space '
    },
    {
        ' Both sides '
    },
    {
        'ARG1 WITH SPACES',
        'ARG2'
    },
    {
        '@#$%',
        '~/\\'
    },
    {
        'Quote"inside'
    },
    {
        '"'
    },
    {
        'A',
        'B',
        'C',
        'D,E',
        'F'
    },
    {
        '123',
        '456.789',
        '-10'
    },
    {
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J'
    },
    {
        ' ',
        ' ',
        ' '
    }
}


define_function TestNAVSnapiParserBasic() {
    stack_var integer x

    NAVLog("'***************** NAVSnapiParser *******************'")

    for (x = 1; x <= length_array(SNAPI_PARSER_BASIC_TEST); x++) {
        stack_var _NAVSnapiMessage message
        stack_var integer expectedArgCount

        NAVStopwatchStart()

        if (!NAVAssertTrue('Should parse successfully', NAVSnapiParserParse(SNAPI_PARSER_BASIC_TEST[x], message))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the header was parsed correctly
        if (!NAVAssertStringEqual('Should parse correct header', SNAPI_PARSER_BASIC_EXPECTED_HEADER_VALUES[x], message.Header)) {
            NAVLogTestFailed(x, SNAPI_PARSER_BASIC_EXPECTED_HEADER_VALUES[x], message.Header)
            continue
        }

        // Verify the correct number of args were generated
        expectedArgCount = SNAPI_PARSER_BASIC_EXPECTED_ARG_COUNTS[x]
        if (!NAVAssertIntegerEqual('Should parse to correct amount of args', expectedArgCount, message.ParameterCount)) {
            NAVLogTestFailed(x, itoa(expectedArgCount), itoa(message.ParameterCount))
            continue
        }

        if (expectedArgCount > 0) {
            // Now loop through the args and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= message.ParameterCount; y++) {
                if (!NAVAssertStringEqual("'Arg ', itoa(y), ' value should be correct'", SNAPI_PARSER_BASIC_EXPECTED_ARG_VALUES[x][y], message.Parameter[y])) {
                    NAVLogTestFailed(x, SNAPI_PARSER_BASIC_EXPECTED_ARG_VALUES[x][y], message.Parameter[y])
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }

    NAVStopwatchStop()
}
