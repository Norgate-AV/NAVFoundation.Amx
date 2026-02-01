PROGRAM_NAME='NAVSocketConnectionIsInitialized'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_IS_INITIALIZED_TEST_COUNT = 5

constant char SOCKET_CONNECTION_IS_INITIALIZED_TEST_SHOULD_INIT[] = {
    true,   // 1: Initialize properly
    true,   // 2: Initialize properly
    false,  // 3: Don't initialize (test uninitialized state)
    true,   // 4: Initialize properly with device 0:10:0
    false   // 5: Don't initialize (test uninitialized state again)
}

constant char SOCKET_CONNECTION_IS_INITIALIZED_TEST_DESCRIPTIONS[][255] = {
    'Initialized: proper initialization',
    'Initialized: proper initialization (alternate)',
    'Not initialized: no initialization called',
    'Initialized: with device 0:10:0',
    'Not initialized: no initialization (alternate)'
}

constant char SOCKET_CONNECTION_IS_INITIALIZED_TEST_EXPECTED_RESULT[] = {
    true,   // 1: Initialized
    true,   // 2: Initialized
    false,  // 3: Not initialized
    true,   // 4: Initialized
    false   // 5: Not initialized
}


define_function TestNAVSocketConnectionIsInitialized() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionIsInitialized')

    for (x = 1; x <= SOCKET_CONNECTION_IS_INITIALIZED_TEST_COUNT; x++) {
        stack_var _NAVSocketConnection conn
        stack_var _NAVSocketConnectionOptions options
        stack_var char result
        stack_var char shouldPass

        if (SOCKET_CONNECTION_IS_INITIALIZED_TEST_SHOULD_INIT[x]) {
            // Initialize the connection
            options.Id = 'Test Socket'

            if (x == 4) {
                options.Device = 0:10:0
            }
            else {
                options.Device = 0:2:0
            }

            options.ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
            options.Protocol = IP_TCP
            options.Port = 8080
            options.TimelineId = 200

            if (!NAVAssertBooleanEqual('Connection should initialize successfully', true, NAVSocketConnectionInit(conn, options))) {
                NAVLogTestFailed(x, NAVBooleanToString(true), NAVBooleanToString(false))
                continue
            }
        }

        // If should_init is false, conn remains uninitialized (default struct values)

        // Test if connection is initialized
        // Note: This function typically logs an error if not initialized
        result = NAVSocketConnectionIsInitialized(conn, 'TestNAVSocketConnectionIsInitialized')
        shouldPass = SOCKET_CONNECTION_IS_INITIALIZED_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual(SOCKET_CONNECTION_IS_INITIALIZED_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionIsInitialized')
}
