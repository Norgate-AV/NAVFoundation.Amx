PROGRAM_NAME='NAVSnapiParseMessage'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.SnapiHelpers.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'
#include 'NAVSnapiParseShared.axi'

define_function TestNAVSnapiParseMessage() {
    stack_var integer x

    NAVLog("'***************** NAVSnapiParseMessage *******************'")

    for (x = 1; x <= length_array(SNAPI_PARSE_BASIC_TEST); x++) {
        stack_var _NAVSnapiMessage message
        stack_var integer expectedArgCount

        NAVStopwatchStart()

        if (!NAVAssertTrue('Should parse successfully', NAVParseSnapiMessage(SNAPI_PARSE_BASIC_TEST[x], message))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the header was parsed correctly
        if (!NAVAssertStringEqual('Should parse correct header', SNAPI_PARSE_BASIC_EXPECTED_HEADER_VALUES[x], message.Header)) {
            NAVLogTestFailed(x, SNAPI_PARSE_BASIC_EXPECTED_HEADER_VALUES[x], message.Header)
            continue
        }

        // Verify the correct number of args were generated
        expectedArgCount = SNAPI_PARSE_BASIC_EXPECTED_ARG_COUNTS[x]
        if (!NAVAssertIntegerEqual('Should parse to correct amount of args', expectedArgCount, message.ParameterCount)) {
            NAVLogTestFailed(x, itoa(expectedArgCount), itoa(message.ParameterCount))
            continue
        }

        if (expectedArgCount > 0) {
            // Now loop through the args and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= message.ParameterCount; y++) {
                if (!NAVAssertStringEqual("'Arg ', itoa(y), ' value should be correct'", SNAPI_PARSE_BASIC_EXPECTED_ARG_VALUES[x][y], message.Parameter[y])) {
                    NAVLogTestFailed(x, SNAPI_PARSE_BASIC_EXPECTED_ARG_VALUES[x][y], message.Parameter[y])
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
