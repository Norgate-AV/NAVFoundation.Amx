PROGRAM_NAME='NAVSocketConnectionGetConnectionTypeString'

DEFINE_CONSTANT

constant integer GET_CONNECTION_TYPE_STRING_TEST_COUNT = 5

constant integer GET_CONNECTION_TYPE_STRING_TEST_VALUES[] = {
    NAV_SOCKET_CONNECTION_TYPE_TCP_UDP,     // 1: TCP/UDP
    NAV_SOCKET_CONNECTION_TYPE_SSH,         // 2: SSH
    NAV_SOCKET_CONNECTION_TYPE_TLS,         // 3: TLS
    99,                                     // 4: Invalid value
    255                                     // 5: Invalid value
}

constant char GET_CONNECTION_TYPE_STRING_TEST_DESCRIPTIONS[][255] = {
    'Valid: NAV_SOCKET_CONNECTION_TYPE_TCP_UDP',
    'Valid: NAV_SOCKET_CONNECTION_TYPE_SSH',
    'Valid: NAV_SOCKET_CONNECTION_TYPE_TLS',
    'Invalid: value 99 (unknown type)',
    'Invalid: value 255 (unknown type)'
}

constant char GET_CONNECTION_TYPE_STRING_TEST_EXPECTED[][50] = {
    'TCP/UDP',          // 1
    'SSH',              // 2
    'TLS',              // 3
    'Unknown (99)',     // 4
    'Unknown (255)'     // 5
}


define_function TestNAVSocketConnectionGetConnectionTypeString() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionGetConnectionTypeString')

    for (x = 1; x <= GET_CONNECTION_TYPE_STRING_TEST_COUNT; x++) {
        stack_var _NAVSocketConnection conn
        stack_var _NAVSocketConnectionOptions options
        stack_var char result[50]
        stack_var char expected[50]

        // Initialize the connection first
        options.Id = 'Test Socket'
        options.Device = 0:2:0
        options.ConnectionType = GET_CONNECTION_TYPE_STRING_TEST_VALUES[x]
        options.Protocol = IP_TCP
        options.Port = 8080
        options.TimelineId = 200

        // Add SSH username and password for SSH connection
        if (GET_CONNECTION_TYPE_STRING_TEST_VALUES[x] == NAV_SOCKET_CONNECTION_TYPE_SSH) {
            options.SshUsername = 'testuser'
            options.SshPassword = 'testpass'
        }

        if (!NAVAssertBooleanEqual('Connection should initialize successfully', true, NAVSocketConnectionInit(conn, options))) {
            NAVLogTestFailed(x, NAVBooleanToString(true), NAVBooleanToString(false))
            continue
        }

        // For invalid connection types (tests 4-5), manually set after initialization
        // because NAVSocketConnectionInit defaults invalid types to TCP/UDP
        if (x >= 4) {
            conn.ConnectionType = GET_CONNECTION_TYPE_STRING_TEST_VALUES[x]
        }

        // Get the connection type string
        result = NAVSocketConnectionGetConnectionTypeString(conn)
        expected = GET_CONNECTION_TYPE_STRING_TEST_EXPECTED[x]

        if (!NAVAssertStringEqual(GET_CONNECTION_TYPE_STRING_TEST_DESCRIPTIONS[x], expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionGetConnectionTypeString')
}
