PROGRAM_NAME='NAVSocketConnectionSetSshPrivateKey'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_COUNT = 4

constant char SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_PATH[][255] = {
    '/amx/keys/id_rsa',         // 1: Valid path
    '/home/user/.ssh/id_ed25519',  // 2: Valid path alternate
    '/keys/key_with_passphrase',   // 3: Valid path with passphrase
    ''                          // 4: Invalid - empty path
}

constant char SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_PASSPHRASE[][255] = {
    '',                         // 1: No passphrase
    '',                         // 2: No passphrase
    'my-secure-passphrase',     // 3: With passphrase
    ''                          // 4: No passphrase (but path invalid)
}

constant char SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_DESCRIPTIONS[][255] = {
    'Valid path without passphrase',
    'Valid alternate path without passphrase',
    'Valid path with passphrase',
    'Invalid: empty path'
}

constant char SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_EXPECTED_RESULT[] = {
    true,   // 1: Valid path
    true,   // 2: Valid alternate path
    true,   // 3: Valid with passphrase
    false   // 4: Empty path
}


define_function TestNAVSocketConnectionSetSshPrivateKey() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionSetSshPrivateKey')

    for (x = 1; x <= SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_COUNT; x++) {
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

        // Test setting SSH private key
        result = NAVSocketConnectionSetSshPrivateKey(conn,
                                                    SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_PATH[x],
                                                    SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_PASSPHRASE[x])
        shouldPass = SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual(SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        if (shouldPass) {
            // Verify private key was actually set
            if (!NAVAssertStringEqual('Private key path should be set to expected value',
                               NAVTrimString(SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_PATH[x]),
                               conn.SshPrivateKey)) {
                NAVLogTestFailed(x, NAVTrimString(SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_PATH[x]), conn.SshPrivateKey)
                continue
            }
            if (!NAVAssertStringEqual('Passphrase should be set to expected value',
                               SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_PASSPHRASE[x],
                               conn.SshPrivateKeyPassphrase)) {
                NAVLogTestFailed(x, SOCKET_CONNECTION_SET_SSH_PRIVATE_KEY_TEST_PASSPHRASE[x], conn.SshPrivateKeyPassphrase)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionSetSshPrivateKey')
}
