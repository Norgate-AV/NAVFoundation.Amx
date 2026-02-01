PROGRAM_NAME='NAVSocketConnectionIsRetrying'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_IS_RETRYING_TEST_COUNT = 6

constant integer SOCKET_CONNECTION_IS_RETRYING_TEST_RETRY_COUNT[] = {
    0,      // 1: No retries
    1,      // 2: First retry
    5,      // 3: Multiple retries
    10,     // 4: Many retries
    0,      // 5: No retries (reset after success)
    100     // 6: Excessive retries
}

constant char SOCKET_CONNECTION_IS_RETRYING_TEST_DESCRIPTIONS[][255] = {
    'Not retrying: retry count 0',
    'Retrying: retry count 1',
    'Retrying: retry count 5',
    'Retrying: retry count 10',
    'Not retrying: retry count 0 (reset)',
    'Retrying: retry count 100'
}

constant char SOCKET_CONNECTION_IS_RETRYING_TEST_EXPECTED_RESULT[] = {
    false,  // 1: RetryCount 0 -> not retrying
    true,   // 2: RetryCount > 0 -> retrying
    true,   // 3: RetryCount > 0 -> retrying
    true,   // 4: RetryCount > 0 -> retrying
    false,  // 5: RetryCount 0 -> not retrying
    true    // 6: RetryCount > 0 -> retrying
}


define_function TestNAVSocketConnectionIsRetrying() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionIsRetrying')

    for (x = 1; x <= SOCKET_CONNECTION_IS_RETRYING_TEST_COUNT; x++) {
        stack_var _NAVSocketConnection conn
        stack_var _NAVSocketConnectionOptions options
        stack_var char result
        stack_var char shouldPass

        // Initialize the connection first
        options.Id = 'Test Socket'
        options.Device = 0:2:0
        options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
        options.Protocol = IP_TCP
        options.Port = 8080
        options.TimelineId = 200

        if (!NAVAssertBooleanEqual('Connection should initialize successfully', true, NAVSocketConnectionInit(conn, options))) {
            NAVLogTestFailed(x, NAVBooleanToString(true), NAVBooleanToString(false))
            continue
        }

        // Set the retry count
        conn.RetryCount = SOCKET_CONNECTION_IS_RETRYING_TEST_RETRY_COUNT[x]

        // Test if connection is retrying
        result = NAVSocketConnectionIsRetrying(conn)
        shouldPass = SOCKET_CONNECTION_IS_RETRYING_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual(SOCKET_CONNECTION_IS_RETRYING_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionIsRetrying')
}
