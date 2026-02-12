PROGRAM_NAME='NAVSocketConnectionSetPort'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_SET_PORT_TEST_COUNT = 6

constant integer SOCKET_CONNECTION_SET_PORT_TEST_INPUTS[] = {
    1,          // 1: Minimum valid port
    80,         // 2: HTTP port
    8080,       // 3: Common alternate port
    443,        // 4: HTTPS port
    65535,      // 5: Maximum valid port
    0           // 6: Invalid - zero
}

constant char SOCKET_CONNECTION_SET_PORT_TEST_DESCRIPTIONS[][255] = {
    'Minimum valid port (1)',
    'HTTP port (80)',
    'Common alternate port (8080)',
    'HTTPS port (443)',
    'Maximum valid port (65535)',
    'Invalid: port zero'
}

constant char SOCKET_CONNECTION_SET_PORT_TEST_EXPECTED_RESULT[] = {
    true,   // 1: Port 1
    true,   // 2: Port 80
    true,   // 3: Port 8080
    true,   // 4: Port 443
    true,   // 5: Port 65535
    false   // 6: Port 0
}


define_function TestNAVSocketConnectionSetPort() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionSetPort')

    for (x = 1; x <= SOCKET_CONNECTION_SET_PORT_TEST_COUNT; x++) {
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

        // Test setting the port
        result = NAVSocketConnectionSetPort(conn, SOCKET_CONNECTION_SET_PORT_TEST_INPUTS[x])
        shouldPass = SOCKET_CONNECTION_SET_PORT_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual(SOCKET_CONNECTION_SET_PORT_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        if (shouldPass) {
            // Verify port was actually set
            if (!NAVAssertIntegerEqual('Port should be set to expected value',
                                SOCKET_CONNECTION_SET_PORT_TEST_INPUTS[x],
                                conn.Port)) {
                NAVLogTestFailed(x, itoa(SOCKET_CONNECTION_SET_PORT_TEST_INPUTS[x]), itoa(conn.Port))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionSetPort')
}
