PROGRAM_NAME='NAVSocketConnectionSetCredential'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_SET_CREDENTIAL_TEST_COUNT = 5

constant char SOCKET_CONNECTION_SET_CREDENTIAL_TEST_USERNAME[][255] = {
    'admin',            // 1: Valid username
    'root',             // 2: Valid username
    'user@domain.com',  // 3: Valid username with special chars
    '',                 // 4: Invalid - empty username
    '   '               // 5: Invalid - whitespace only
}

constant char SOCKET_CONNECTION_SET_CREDENTIAL_TEST_PASSWORD[][255] = {
    'password123',      // 1: Valid password
    'P@ssw0rd!',        // 2: Valid password with special chars
    '',                 // 3: Valid - empty password (allowed)
    'password',         // 4: Password (but username invalid)
    'password'          // 5: Password (but username invalid)
}

constant char SOCKET_CONNECTION_SET_CREDENTIAL_TEST_DESCRIPTIONS[][255] = {
    'Valid username and password',
    'Valid username with complex password',
    'Valid username with empty password',
    'Invalid: empty username',
    'Invalid: whitespace username'
}

constant char SOCKET_CONNECTION_SET_CREDENTIAL_TEST_EXPECTED_RESULT[] = {
    true,   // 1: Valid credentials
    true,   // 2: Valid credentials with special chars
    true,   // 3: Empty password is allowed
    false,  // 4: Empty username
    false   // 5: Whitespace username (should be trimmed to empty and rejected)
}


define_function TestNAVSocketConnectionSetCredential() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionSetCredential')

    for (x = 1; x <= SOCKET_CONNECTION_SET_CREDENTIAL_TEST_COUNT; x++) {
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

        // Test setting credentials
        result = NAVSocketConnectionSetCredential(conn,
                                                 SOCKET_CONNECTION_SET_CREDENTIAL_TEST_USERNAME[x],
                                                 SOCKET_CONNECTION_SET_CREDENTIAL_TEST_PASSWORD[x])
        shouldPass = SOCKET_CONNECTION_SET_CREDENTIAL_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual(SOCKET_CONNECTION_SET_CREDENTIAL_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        if (shouldPass) {
            // Verify credentials were actually set
            if (!NAVAssertStringEqual('Username should be set to expected value',
                               NAVTrimString(SOCKET_CONNECTION_SET_CREDENTIAL_TEST_USERNAME[x]),
                               conn.Credential.Username)) {
                NAVLogTestFailed(x, NAVTrimString(SOCKET_CONNECTION_SET_CREDENTIAL_TEST_USERNAME[x]), conn.Credential.Username)
                continue
            }
            if (!NAVAssertStringEqual('Password should be set to expected value',
                               SOCKET_CONNECTION_SET_CREDENTIAL_TEST_PASSWORD[x],
                               conn.Credential.Password)) {
                NAVLogTestFailed(x, SOCKET_CONNECTION_SET_CREDENTIAL_TEST_PASSWORD[x], conn.Credential.Password)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionSetCredential')
}
