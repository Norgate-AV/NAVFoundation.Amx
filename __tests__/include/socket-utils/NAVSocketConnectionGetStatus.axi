PROGRAM_NAME='NAVSocketConnectionGetStatus'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_GET_STATUS_TEST_COUNT = 7

constant char SOCKET_CONNECTION_GET_STATUS_TEST_IS_CONNECTED[] = {
    false,  // 1: Not connected, not retrying
    true,   // 2: Connected
    false,  // 3: Not connected, retrying (count 1)
    false,  // 4: Not connected, retrying (count 5)
    true,   // 5: Connected, with retry count
    false,  // 6: Not connected, no retry
    false   // 7: Not connected, retrying (count 10)
}

constant integer SOCKET_CONNECTION_GET_STATUS_TEST_RETRY_COUNT[] = {
    0,      // 1: No retries
    0,      // 2: Connected, no retries
    1,      // 3: First retry
    5,      // 4: Multiple retries
    3,      // 5: Connected with retry history
    0,      // 6: No retries
    10      // 7: Many retries
}

constant char SOCKET_CONNECTION_GET_STATUS_TEST_DESCRIPTIONS[][255] = {
    'Not connected, no retries',
    'Connected',
    'Not connected, retrying (attempt 1)',
    'Not connected, retrying (attempt 5)',
    'Connected after 3 retries',
    'Not connected, no retry attempts',
    'Not connected, retrying (attempt 10)'
}

constant char SOCKET_CONNECTION_GET_STATUS_TEST_EXPECTED_RESULT[][50] = {
    'Disconnected',           // 1
    'Connected',              // 2
    'Connecting (attempt 1)', // 3
    'Connecting (attempt 5)', // 4
    'Connected',              // 5
    'Disconnected',           // 6
    'Connecting (attempt 10)' // 7
}


define_function TestNAVSocketConnectionGetStatus() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionGetStatus')

    for (x = 1; x <= SOCKET_CONNECTION_GET_STATUS_TEST_COUNT; x++) {
        stack_var _NAVSocketConnection conn
        stack_var _NAVSocketConnectionOptions options
        stack_var char result[50]
        stack_var char expected[50]

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

        // Configure the connection with address so it's not 'Not Configured'
        NAVSocketConnectionSetAddress(conn, '192.168.1.100')

        // Set up connection state
        conn.IsConnected = SOCKET_CONNECTION_GET_STATUS_TEST_IS_CONNECTED[x]
        conn.RetryCount = SOCKET_CONNECTION_GET_STATUS_TEST_RETRY_COUNT[x]
        conn.AutoReconnect = true  // Required for retry status

        // Get the status string
        result = NAVSocketConnectionGetStatus(conn)
        expected = SOCKET_CONNECTION_GET_STATUS_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertStringEqual(SOCKET_CONNECTION_GET_STATUS_TEST_DESCRIPTIONS[x], expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionGetStatus')
}
