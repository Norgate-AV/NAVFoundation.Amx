PROGRAM_NAME='NAVSocketConnectionIsConfigured'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_IS_CONFIGURED_TEST_COUNT = 8

constant char SOCKET_CONNECTION_IS_CONFIGURED_TEST_ADDRESS[][255] = {
    '192.168.1.100',    // 1: Valid address with valid port
    'example.com',      // 2: Valid hostname with valid port
    '',                 // 3: Empty address with valid port
    '192.168.1.100',    // 4: Valid address with zero port
    '',                 // 5: Empty address with zero port
    '10.0.0.1',         // 6: Valid address with valid port (alt)
    'server.local',     // 7: Valid hostname with port 443
    '192.168.0.1'       // 8: Valid address, then clear address
}

constant integer SOCKET_CONNECTION_IS_CONFIGURED_TEST_PORT[] = {
    8080,   // 1: Valid port
    80,     // 2: Valid port
    8080,   // 3: Valid port (but address empty)
    0,      // 4: Zero port
    0,      // 5: Zero port
    443,    // 6: Valid port
    443,    // 7: Valid port
    22      // 8: Valid port (but will clear address)
}

constant char SOCKET_CONNECTION_IS_CONFIGURED_TEST_DESCRIPTIONS[][255] = {
    'Valid: IP address and port',
    'Valid: hostname and port',
    'Invalid: empty address with valid port',
    'Invalid: valid address with zero port',
    'Invalid: empty address with zero port',
    'Valid: alternate IP and port',
    'Valid: hostname and HTTPS port',
    'Invalid: valid initially, then address cleared'
}

constant char SOCKET_CONNECTION_IS_CONFIGURED_TEST_EXPECTED_RESULT[] = {
    true,   // 1: Valid address + port
    true,   // 2: Valid hostname + port
    false,  // 3: No address
    false,  // 4: No port
    false,  // 5: No address, no port
    true,   // 6: Valid address + port
    true,   // 7: Valid hostname + port
    false   // 8: Address cleared
}


define_function TestNAVSocketConnectionIsConfigured() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionIsConfigured')

    for (x = 1; x <= SOCKET_CONNECTION_IS_CONFIGURED_TEST_COUNT; x++) {
        stack_var _NAVSocketConnection conn
        stack_var _NAVSocketConnectionOptions options
        stack_var char result
        stack_var char shouldPass

        // Initialize the connection first
        // Note: Do not set port in options for test 4, as it needs zero port
        options.Id = 'Test Socket'
        options.Device = 0:2:0
        options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
        options.Protocol = IP_TCP
        options.Port = 8080  // Will be overridden by test-specific port
        options.TimelineId = 200

        if (!NAVAssertBooleanEqual('Connection should initialize successfully', true, NAVSocketConnectionInit(conn, options))) {
            NAVLogTestFailed(x, NAVBooleanToString(true), NAVBooleanToString(false))
            continue
        }

        // Set address and port according to test case
        if (length_array(SOCKET_CONNECTION_IS_CONFIGURED_TEST_ADDRESS[x])) {
            NAVSocketConnectionSetAddress(conn, SOCKET_CONNECTION_IS_CONFIGURED_TEST_ADDRESS[x])
        }

        // Always set port from test data to handle zero port test (test 4)
        conn.Port = SOCKET_CONNECTION_IS_CONFIGURED_TEST_PORT[x]

        // Special case: test 8 - set address then clear it
        if (x == 8) {
            NAVSocketConnectionSetAddress(conn, '')
        }

        // Test if connection is configured
        result = NAVSocketConnectionIsConfigured(conn)
        shouldPass = SOCKET_CONNECTION_IS_CONFIGURED_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual(SOCKET_CONNECTION_IS_CONFIGURED_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionIsConfigured')
}
