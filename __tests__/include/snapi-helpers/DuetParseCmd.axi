PROGRAM_NAME='DuetParseCmd'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.SnapiHelpers.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'
#include 'NAVSnapiParseShared.axi'

define_function TestDuetParseCmd() {
    stack_var integer x

    NAVLog("'***************** DuetParseCmd *******************'")

    for (x = 1; x <= length_array(SNAPI_PARSE_BASIC_TEST); x++) {
        stack_var _NAVSnapiMessage message
        stack_var integer expectedArgCount
        stack_var char cmd[DUET_MAX_CMD_LEN]

        NAVStopwatchStart()

        // DuetParseCmdHeader and DuetParseCmdParam are stateful
        // They modify the input string, so we need a copy for each call
        cmd = SNAPI_PARSE_BASIC_TEST[x]
        message.Header = DuetParseCmdHeader(cmd)

        // Verify the header was parsed correctly
        if (!NAVAssertStringEqual('Should parse correct header', SNAPI_PARSE_BASIC_EXPECTED_HEADER_VALUES[x], message.Header)) {
            NAVLogTestFailed(x, SNAPI_PARSE_BASIC_EXPECTED_HEADER_VALUES[x], message.Header)
            continue
        }

        expectedArgCount = SNAPI_PARSE_BASIC_EXPECTED_ARG_COUNTS[x]
        if (expectedArgCount > 0) {
            // Parse parameters sequentially from the same string
            // DuetParseCmdParam advances through the string on each call
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= expectedArgCount; y++) {
                message.Parameter[y] = DuetParseCmdParam(cmd)
                message.ParameterCount++
            }

            // Verify parameter count
            if (!NAVAssertIntegerEqual('Should parse correct amount of args', expectedArgCount, message.ParameterCount)) {
                NAVLogTestFailed(x, itoa(expectedArgCount), itoa(message.ParameterCount))
                continue
            }

            // Verify each parameter value
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
}
