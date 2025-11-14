PROGRAM_NAME='NAVSnapiParseMessage'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.SnapiHelpers.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

constant char SNAPI_PARSE_MESSAGE_BASIC_TEST[][255] = {
    'INPUT-HDMI,1',                             // 1: Simple input command
    '?VERSION',                                  // 2: Simple query command
    'FOO-"bar,baz"',                            // 3: Input with quoted string containing comma
    'COMMAND-,ARG2,"""ARG3"""',                 // 4: Mixed arguments with escaped quotes
    'HEADER-Value,ANOTHER,"Complex,Value",'     // 5: Complex input with multiple tokens
}

constant char SNAPI_PARSE_MESSAGE_BASIC_EXPECTED_HEADER_VALUES[][50] = {
    'INPUT',
    '?VERSION',
    'FOO',
    'COMMAND',
    'HEADER'
}

constant integer SNAPI_PARSE_MESSAGE_BASIC_EXPECTED_ARG_COUNTS[] = {
    2,
    0,
    1,
    3,
    4
}

constant char SNAPI_PARSE_MESSAGE_BASIC_EXPECTED_ARG_VALUES[][][50] = {
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
    }
}


define_function TestNAVSnapiParseMessage() {
    stack_var integer x

    NAVLog("'***************** NAVSnapiParseMessage *******************'")

    for (x = 1; x <= length_array(SNAPI_PARSE_MESSAGE_BASIC_TEST); x++) {
        stack_var _NAVSnapiMessage message
        stack_var integer expectedArgCount

        NAVStopwatchStart()

        if (!NAVAssertTrue('Should parse successfully', NAVParseSnapiMessage(SNAPI_PARSE_MESSAGE_BASIC_TEST[x], message))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the header was parsed correctly
        if (!NAVAssertStringEqual('Should parse correct header', SNAPI_PARSE_MESSAGE_BASIC_EXPECTED_HEADER_VALUES[x], message.Header)) {
            NAVLogTestFailed(x, SNAPI_PARSE_MESSAGE_BASIC_EXPECTED_HEADER_VALUES[x], message.Header)
            continue
        }

        // Verify the correct number of args were generated
        expectedArgCount = SNAPI_PARSE_MESSAGE_BASIC_EXPECTED_ARG_COUNTS[x]
        if (!NAVAssertIntegerEqual('Should parse to correct amount of args', expectedArgCount, message.ParameterCount)) {
            NAVLogTestFailed(x, itoa(expectedArgCount), itoa(message.ParameterCount))
            continue
        }

        if (expectedArgCount > 0) {
            // Now loop through the args and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= message.ParameterCount; y++) {
                if (!NAVAssertStringEqual("'Arg ', itoa(y), ' value should be correct'", SNAPI_PARSE_MESSAGE_BASIC_EXPECTED_ARG_VALUES[x][y], message.Parameter[y])) {
                    NAVLogTestFailed(x, SNAPI_PARSE_MESSAGE_BASIC_EXPECTED_ARG_VALUES[x][y], message.Parameter[y])
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
