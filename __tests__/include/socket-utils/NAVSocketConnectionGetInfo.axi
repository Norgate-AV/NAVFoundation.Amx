PROGRAM_NAME='NAVSocketConnectionGetInfo'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_GET_INFO_TEST_COUNT = 10

constant char SOCKET_CONNECTION_GET_INFO_TEST_ADDRESS[][255] = {
    '192.168.1.100',    // 1: IP + port + connected
    'server.local',     // 2: Hostname + port + connected
    '10.0.0.1',         // 3: IP + port + not connected
    'api.example.com',  // 4: Hostname + port + not connected
    '192.168.0.50',     // 5: IP + port + retrying
    'db.local',         // 6: Hostname + port + retrying (multiple)
    '',                 // 7: No address + port + not connected
    '172.16.0.1',       // 8: IP + port + connected (TCP/UDP)
    'secure.example',   // 9: Hostname + port + connected (TLS)
    'ssh.server.com'    // 10: Hostname + port + connected (SSH)
}

constant integer SOCKET_CONNECTION_GET_INFO_TEST_PORT[] = {
    8080,   // 1
    80,     // 2
    9000,   // 3
    443,    // 4
    3306,   // 5
    5432,   // 6
    8080,   // 7: Port set but no address
    1234,   // 8
    8443,   // 9
    22      // 10
}

constant char SOCKET_CONNECTION_GET_INFO_TEST_IS_CONNECTED[] = {
    true,   // 1: Connected
    true,   // 2: Connected
    false,  // 3: Not connected
    false,  // 4: Not connected
    false,  // 5: Not connected, retrying
    false,  // 6: Not connected, retrying
    false,  // 7: Not connected
    true,   // 8: Connected
    true,   // 9: Connected
    true    // 10: Connected
}

constant integer SOCKET_CONNECTION_GET_INFO_TEST_RETRY_COUNT[] = {
    0,      // 1: No retries
    0,      // 2: No retries
    0,      // 3: No retries
    0,      // 4: No retries
    3,      // 5: Retrying
    10,     // 6: Multiple retries
    0,      // 7: No retries
    0,      // 8: No retries
    0,      // 9: No retries
    0       // 10: No retries
}

constant integer SOCKET_CONNECTION_GET_INFO_TEST_CONNECTION_TYPE[] = {
    NAV_SOCKET_CONNECTION_TYPE_TCP_UDP,     // 1
    NAV_SOCKET_CONNECTION_TYPE_TCP_UDP,     // 2
    NAV_SOCKET_CONNECTION_TYPE_TCP_UDP,     // 3
    NAV_SOCKET_CONNECTION_TYPE_TCP_UDP,     // 4
    NAV_SOCKET_CONNECTION_TYPE_TCP_UDP,     // 5
    NAV_SOCKET_CONNECTION_TYPE_TCP_UDP,     // 6
    NAV_SOCKET_CONNECTION_TYPE_TCP_UDP,     // 7
    NAV_SOCKET_CONNECTION_TYPE_TCP_UDP,     // 8
    NAV_SOCKET_CONNECTION_TYPE_TLS,         // 9
    NAV_SOCKET_CONNECTION_TYPE_SSH          // 10
}

constant char SOCKET_CONNECTION_GET_INFO_TEST_DESCRIPTIONS[][255] = {
    'IP address connected',
    'Hostname connected',
    'IP address not connected',
    'Hostname not connected',
    'IP address retrying (3 attempts)',
    'Hostname retrying (10 attempts)',
    'No address configured',
    'IP address connected (TCP/UDP)',
    'Hostname connected (TLS)',
    'Hostname connected (SSH)'
}

constant char SOCKET_CONNECTION_GET_INFO_TEST_EXPECTED_RESULT[][255] = {
    'Test Socket [TCP/UDP] 192.168.1.100:8080 - Connected',           // 1
    'Test Socket [TCP/UDP] server.local:80 - Connected',              // 2
    'Test Socket [TCP/UDP] 10.0.0.1:9000 - Disconnected',             // 3
    'Test Socket [TCP/UDP] api.example.com:443 - Disconnected',       // 4
    'Test Socket [TCP/UDP] 192.168.0.50:3306 - Connecting (attempt 3)',   // 5
    'Test Socket [TCP/UDP] db.local:5432 - Connecting (attempt 10)',      // 6
    'Test Socket [TCP/UDP] [No Address] - Not Configured',            // 7
    'Test Socket [TCP/UDP] 172.16.0.1:1234 - Connected',              // 8
    'Test Socket [TLS] secure.example:8443 - Connected',              // 9
    'Test Socket [SSH] ssh.server.com:22 - Connected'                 // 10
}


define_function TestNAVSocketConnectionGetInfo() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionGetInfo')

    for (x = 1; x <= SOCKET_CONNECTION_GET_INFO_TEST_COUNT; x++) {
        stack_var _NAVSocketConnection conn
        stack_var _NAVSocketConnectionOptions options
        stack_var char result[255]
        stack_var char expected[255]

        // Initialize the connection first
        options.Id = 'Test Socket'
        options.Device = 0:2:0
        options.ConnectionType = SOCKET_CONNECTION_GET_INFO_TEST_CONNECTION_TYPE[x]
        options.Protocol = IP_TCP
        options.Port = SOCKET_CONNECTION_GET_INFO_TEST_PORT[x]
        options.TimelineId = 200

        // Add SSH username and password for SSH connection (test 10)
        if (SOCKET_CONNECTION_GET_INFO_TEST_CONNECTION_TYPE[x] == NAV_SOCKET_CONNECTION_TYPE_SSH) {
            options.SshUsername = 'sshuser'
            options.SshPassword = 'sshpass'
        }

        if (!NAVAssertBooleanEqual('Connection should initialize successfully', true, NAVSocketConnectionInit(conn, options))) {
            NAVLogTestFailed(x, NAVBooleanToString(true), NAVBooleanToString(false))
            continue
        }

        // Set up connection state
        if (length_array(SOCKET_CONNECTION_GET_INFO_TEST_ADDRESS[x])) {
            NAVSocketConnectionSetAddress(conn, SOCKET_CONNECTION_GET_INFO_TEST_ADDRESS[x])
        }

        conn.IsConnected = SOCKET_CONNECTION_GET_INFO_TEST_IS_CONNECTED[x]
        conn.RetryCount = SOCKET_CONNECTION_GET_INFO_TEST_RETRY_COUNT[x]

        // Enable AutoReconnect for tests with retry count to show 'Connecting (attempt N)'
        if (conn.RetryCount > 0) {
            conn.AutoReconnect = true
        }

        // Get the info string
        result = NAVSocketConnectionGetInfo(conn)
        expected = SOCKET_CONNECTION_GET_INFO_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertStringEqual(SOCKET_CONNECTION_GET_INFO_TEST_DESCRIPTIONS[x], expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionGetInfo')
}
