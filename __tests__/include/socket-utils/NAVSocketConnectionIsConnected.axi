PROGRAM_NAME='NAVSocketConnectionIsConnected'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_IS_CONNECTED_TEST_COUNT = 6

constant char SOCKET_CONNECTION_IS_CONNECTED_TEST_VALUES[] = {
    true,   // 1: Connected
    false,  // 2: Not connected
    true,   // 3: Connected
    false,  // 4: Not connected (initially connected, then disconnected)
    true,   // 5: Connected (initially disconnected, then connected)
    false   // 6: Not connected
}

constant char SOCKET_CONNECTION_IS_CONNECTED_TEST_DESCRIPTIONS[][255] = {
    'Connected: IsConnected = true',
    'Not connected: IsConnected = false',
    'Connected: IsConnected = true (alternate)',
    'Not connected: disconnected after initial connection',
    'Connected: connected after initial disconnection',
    'Not connected: IsConnected = false (alternate)'
}

constant char SOCKET_CONNECTION_IS_CONNECTED_TEST_EXPECTED_RESULT[] = {
    true,   // 1
    false,  // 2
    true,   // 3
    false,  // 4
    true,   // 5
    false   // 6
}


define_function TestNAVSocketConnectionIsConnected() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionIsConnected')

    for (x = 1; x <= SOCKET_CONNECTION_IS_CONNECTED_TEST_COUNT; x++) {
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

        // Set the connection state
        conn.IsConnected = SOCKET_CONNECTION_IS_CONNECTED_TEST_VALUES[x]

        // Test if connection is connected
        result = NAVSocketConnectionIsConnected(conn)
        shouldPass = SOCKET_CONNECTION_IS_CONNECTED_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual(SOCKET_CONNECTION_IS_CONNECTED_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionIsConnected')
}
