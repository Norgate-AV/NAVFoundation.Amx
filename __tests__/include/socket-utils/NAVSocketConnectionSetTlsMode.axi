PROGRAM_NAME='NAVSocketConnectionSetTlsMode'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_SET_TLS_MODE_TEST_COUNT = 5

constant char SOCKET_CONNECTION_SET_TLS_MODE_TEST_VALUES[] = {
    0,      // 1: NAV_SSL_TLS_MODE_CLIENT
    1,      // 2: NAV_SSL_TLS_MODE_SERVER
    2,      // 3: Invalid value
    255,    // 4: Invalid value
    99      // 5: Invalid value
}

constant char SOCKET_CONNECTION_SET_TLS_MODE_TEST_DESCRIPTIONS[][255] = {
    'Valid: NAV_SSL_TLS_MODE_CLIENT (0)',
    'Valid: NAV_SSL_TLS_MODE_SERVER (1)',
    'Invalid: value 2 (out of range)',
    'Invalid: value 255 (out of range)',
    'Invalid: value 99 (out of range)'
}

constant char SOCKET_CONNECTION_SET_TLS_MODE_TEST_EXPECTED_RESULT[] = {
    true,   // 1: Valid CLIENT mode
    true,   // 2: Valid SERVER mode
    false,  // 3: Invalid value
    false,  // 4: Invalid value
    false   // 5: Invalid value
}


define_function TestNAVSocketConnectionSetTlsMode() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionSetTlsMode')

    for (x = 1; x <= SOCKET_CONNECTION_SET_TLS_MODE_TEST_COUNT; x++) {
        stack_var _NAVSocketConnection conn
        stack_var _NAVSocketConnectionOptions options
        stack_var char result
        stack_var char shouldPass

        // Initialize the connection first
        options.Id = 'Test Socket'
        options.Device = 0:2:0
        options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TLS
        options.Protocol = IP_TCP
        options.Port = 8443
        options.TimelineId = 200

        if (!NAVAssertBooleanEqual('Connection should initialize successfully', true, NAVSocketConnectionInit(conn, options))) {
            NAVLogTestFailed(x, NAVBooleanToString(true), NAVBooleanToString(false))
            continue
        }

        // Test setting TLS mode
        result = NAVSocketConnectionSetTlsMode(conn, SOCKET_CONNECTION_SET_TLS_MODE_TEST_VALUES[x])
        shouldPass = SOCKET_CONNECTION_SET_TLS_MODE_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual(SOCKET_CONNECTION_SET_TLS_MODE_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        if (shouldPass) {
            // Verify TLS mode was actually set
            if (!NAVAssertIntegerEqual('TLS mode should be set to expected value',
                                SOCKET_CONNECTION_SET_TLS_MODE_TEST_VALUES[x],
                                conn.TlsMode)) {
                NAVLogTestFailed(x, itoa(SOCKET_CONNECTION_SET_TLS_MODE_TEST_VALUES[x]), itoa(conn.TlsMode))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionSetTlsMode')
}
