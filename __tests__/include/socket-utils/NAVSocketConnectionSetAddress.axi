PROGRAM_NAME='NAVSocketConnectionSetAddress'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_SET_ADDRESS_TEST_COUNT = 12

constant char SOCKET_CONNECTION_SET_ADDRESS_TEST_INPUTS[][255] = {
    '192.168.1.1',              // 1: Valid IPv4
    '10.0.0.1',                 // 2: Valid IPv4 private
    '255.255.255.255',          // 3: Valid IPv4 broadcast
    'example.com',              // 4: Valid hostname
    'subdomain.example.com',    // 5: Valid hostname with subdomain
    'my-device.local',          // 6: Valid hostname with dash
    '',                         // 7: Invalid - empty string
    '   ',                      // 8: Invalid - whitespace only
    '256.1.1.1',                // 9: Invalid - IPv4 octet too large
    '192.168.1',                // 10: Invalid - incomplete IPv4
    '-hostname',                // 11: Invalid - hostname starts with dash
    'host name'                 // 12: Invalid - hostname with space
}

constant char SOCKET_CONNECTION_SET_ADDRESS_TEST_DESCRIPTIONS[][255] = {
    'Valid IPv4 address',
    'Valid private IPv4 address',
    'Valid broadcast IPv4 address',
    'Valid hostname',
    'Valid hostname with subdomain',
    'Valid hostname with dash',
    'Empty string clears address',
    'Invalid: whitespace only',
    'Invalid: IPv4 octet exceeds 255',
    'Invalid: incomplete IPv4 address',
    'Invalid: hostname starts with dash',
    'Invalid: hostname contains space'
}

constant char SOCKET_CONNECTION_SET_ADDRESS_TEST_EXPECTED_RESULT[] = {
    true,   // 1: Valid IPv4
    true,   // 2: Valid IPv4 private
    true,   // 3: Valid IPv4 broadcast
    true,   // 4: Valid hostname
    true,   // 5: Valid hostname with subdomain
    true,   // 6: Valid hostname with dash
    true,   // 7: Empty string clears address
    false,  // 8: Whitespace only
    false,  // 9: IPv4 octet too large
    false,  // 10: Incomplete IPv4
    false,  // 11: Hostname starts with dash
    false   // 12: Hostname with space
}


define_function TestNAVSocketConnectionSetAddress() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionSetAddress')

    for (x = 1; x <= SOCKET_CONNECTION_SET_ADDRESS_TEST_COUNT; x++) {
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

        // For test 7 (empty string to clear), set an initial address first
        if (x == 7) {
            if (!NAVAssertBooleanEqual('Initial address should be set for clear test', true, NAVSocketConnectionSetAddress(conn, '192.168.1.100'))) {
                NAVLogTestFailed(x, NAVBooleanToString(true), NAVBooleanToString(false))
                continue
            }
        }

        shouldPass = SOCKET_CONNECTION_SET_ADDRESS_TEST_EXPECTED_RESULT[x]
        result = NAVSocketConnectionSetAddress(conn, SOCKET_CONNECTION_SET_ADDRESS_TEST_INPUTS[x])

        // Check if result matches expectation
        if (!NAVAssertBooleanEqual(SOCKET_CONNECTION_SET_ADDRESS_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        // If should pass, verify the address was actually set
        if (shouldPass) {
            if (!NAVAssertStringEqual('Address should be set correctly',
                                     SOCKET_CONNECTION_SET_ADDRESS_TEST_INPUTS[x],
                                     conn.Address)) {
                NAVLogTestFailed(x, SOCKET_CONNECTION_SET_ADDRESS_TEST_INPUTS[x], conn.Address)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionSetAddress')
}
