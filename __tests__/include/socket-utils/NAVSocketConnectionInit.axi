PROGRAM_NAME='NAVSocketConnectionInit'

DEFINE_CONSTANT

constant integer SOCKET_CONNECTION_INIT_TEST_COUNT = 12

constant char SOCKET_CONNECTION_INIT_TEST_DESCRIPTIONS[][255] = {
    'Valid TCP_UDP connection with required fields',
    'Valid SSH connection with username and password',
    'Valid TLS connection with TlsMode',
    'Invalid: Device.NUMBER is 0',
    'Invalid: Device.PORT is 0',
    'Invalid: Device.PORT is 1 (system port)',
    'ConnectionType 0 defaults to TCP_UDP',
    'Invalid Protocol defaults to TCP',
    'Invalid: Port is 0',
    'Invalid: TimelineId is 0',
    'Invalid: SSH connection missing username',
    'Invalid TlsMode defaults to TLS_VALIDATE_CERTIFICATE'
}

constant char SOCKET_CONNECTION_INIT_TEST_EXPECTED_RESULT[] = {
    true,   // 1: Valid TCP_UDP
    true,   // 2: Valid SSH
    true,   // 3: Valid TLS
    false,  // 4: Device.NUMBER is 0
    false,  // 5: Device.PORT is 0
    false,  // 6: Device.PORT is 1
    true,   // 7: ConnectionType 0 defaults to TCP_UDP
    true,   // 8: Invalid Protocol defaults to TCP
    false,  // 9: Port is 0
    false,  // 10: TimelineId is 0
    false,  // 11: SSH missing username
    true    // 12: Invalid TlsMode defaults
}


DEFINE_VARIABLE

volatile _NAVSocketConnectionOptions socketConnectionInitTestOptions[SOCKET_CONNECTION_INIT_TEST_COUNT]


define_function InitializeSocketConnectionInitTestOptions() {
    // Initialize test options for each test case

    // 1. Valid TCP_UDP connection
    socketConnectionInitTestOptions[1].Id = 'Test TCP Socket'
    socketConnectionInitTestOptions[1].Device = 0:2:0
    socketConnectionInitTestOptions[1].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
    socketConnectionInitTestOptions[1].Protocol = IP_TCP
    socketConnectionInitTestOptions[1].Port = 8080
    socketConnectionInitTestOptions[1].TimelineId = 100

    // 2. Valid SSH connection
    socketConnectionInitTestOptions[2].Id = 'Test SSH Socket'
    socketConnectionInitTestOptions[2].Device = 0:2:0
    socketConnectionInitTestOptions[2].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_SSH
    socketConnectionInitTestOptions[2].Protocol = IP_TCP
    socketConnectionInitTestOptions[2].Port = 22
    socketConnectionInitTestOptions[2].SshUsername = 'testuser'
    socketConnectionInitTestOptions[2].SshPassword = 'testpass'
    socketConnectionInitTestOptions[2].TimelineId = 101

    // 3. Valid TLS connection
    socketConnectionInitTestOptions[3].Id = 'Test TLS Socket'
    socketConnectionInitTestOptions[3].Device = 0:2:0
    socketConnectionInitTestOptions[3].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TLS
    socketConnectionInitTestOptions[3].Protocol = IP_TCP
    socketConnectionInitTestOptions[3].Port = 443
    socketConnectionInitTestOptions[3].TlsMode = TLS_VALIDATE_CERTIFICATE
    socketConnectionInitTestOptions[3].TimelineId = 102

    // 4. Invalid: Device.NUMBER is 0
    socketConnectionInitTestOptions[4].Id = 'Invalid Device Number'
    socketConnectionInitTestOptions[4].Device.NUMBER = 0
    socketConnectionInitTestOptions[4].Device.PORT = 1
    socketConnectionInitTestOptions[4].Device.SYSTEM = 0
    socketConnectionInitTestOptions[4].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
    socketConnectionInitTestOptions[4].Protocol = IP_TCP
    socketConnectionInitTestOptions[4].Port = 8080
    socketConnectionInitTestOptions[4].TimelineId = 103

    // 5. Invalid: Device.PORT is 0
    socketConnectionInitTestOptions[5].Id = 'Invalid Device Port'
    socketConnectionInitTestOptions[5].Device = 0:2:0
    socketConnectionInitTestOptions[5].Device.PORT = 0
    socketConnectionInitTestOptions[5].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
    socketConnectionInitTestOptions[5].Protocol = IP_TCP
    socketConnectionInitTestOptions[5].Port = 8080
    socketConnectionInitTestOptions[5].TimelineId = 104

    // 6. Invalid: Device.PORT is 1
    socketConnectionInitTestOptions[6].Id = 'Invalid Device Port 1'
    socketConnectionInitTestOptions[6].Device = 0:2:0
    socketConnectionInitTestOptions[6].Device.PORT = 1
    socketConnectionInitTestOptions[6].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
    socketConnectionInitTestOptions[6].Protocol = IP_TCP
    socketConnectionInitTestOptions[6].Port = 8080
    socketConnectionInitTestOptions[6].TimelineId = 105

    // 7. Invalid: ConnectionType is 0
    socketConnectionInitTestOptions[7].Id = 'Invalid Connection Type'
    socketConnectionInitTestOptions[7].Device = 0:2:0
    socketConnectionInitTestOptions[7].ConnectionType = 0
    socketConnectionInitTestOptions[7].Protocol = IP_TCP
    socketConnectionInitTestOptions[7].Port = 8080
    socketConnectionInitTestOptions[7].TimelineId = 106

    // 8. Invalid: Protocol for TCP_UDP
    socketConnectionInitTestOptions[8].Id = 'Invalid Protocol'
    socketConnectionInitTestOptions[8].Device = 0:2:0
    socketConnectionInitTestOptions[8].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
    socketConnectionInitTestOptions[8].Protocol = 99 // Invalid protocol
    socketConnectionInitTestOptions[8].Port = 8080
    socketConnectionInitTestOptions[8].TimelineId = 107

    // 9. Invalid: Port is 0
    socketConnectionInitTestOptions[9].Id = 'Invalid Port Zero'
    socketConnectionInitTestOptions[9].Device = 0:2:0
    socketConnectionInitTestOptions[9].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
    socketConnectionInitTestOptions[9].Protocol = IP_TCP
    socketConnectionInitTestOptions[9].Port = 0
    socketConnectionInitTestOptions[9].TimelineId = 108

    // 10. Invalid: TimelineId is 0
    socketConnectionInitTestOptions[10].Id = 'Invalid Timeline Id'
    socketConnectionInitTestOptions[10].Device = 0:2:0
    socketConnectionInitTestOptions[10].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TCP_UDP
    socketConnectionInitTestOptions[10].Protocol = IP_TCP
    socketConnectionInitTestOptions[10].Port = 8080
    socketConnectionInitTestOptions[10].TimelineId = 0

    // 12. Invalid: SSH missing username
    socketConnectionInitTestOptions[12].Id = 'SSH Missing Username'
    // 11. Invalid: SSH missing username
    socketConnectionInitTestOptions[11].Id = 'SSH Missing Username'
    socketConnectionInitTestOptions[11].Device = 0:2:0
    socketConnectionInitTestOptions[11].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_SSH
    socketConnectionInitTestOptions[11].Protocol = IP_TCP
    socketConnectionInitTestOptions[11].Port = 22
    socketConnectionInitTestOptions[11].SshUsername = ''
    socketConnectionInitTestOptions[11].SshPassword = 'testpass'
    socketConnectionInitTestOptions[11].TimelineId = 110

    // 12. Invalid: TLS with invalid TlsMode
    socketConnectionInitTestOptions[12].Id = 'TLS Invalid Mode'
    socketConnectionInitTestOptions[12].Device = 0:2:0
    socketConnectionInitTestOptions[12].ConnectionType = NAV_SOCKET_CONNECTION_TYPE_TLS
    socketConnectionInitTestOptions[12].Protocol = IP_TCP
    socketConnectionInitTestOptions[12].Port = 443
    socketConnectionInitTestOptions[12].TlsMode = 99 // Invalid TLS mode
    socketConnectionInitTestOptions[12].TimelineId = 111
}


define_function TestNAVSocketConnectionInit() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVSocketConnectionInit')

    InitializeSocketConnectionInitTestOptions()

    for (x = 1; x <= SOCKET_CONNECTION_INIT_TEST_COUNT; x++) {
        stack_var _NAVSocketConnection conn
        stack_var char result
        stack_var char shouldPass

        shouldPass = SOCKET_CONNECTION_INIT_TEST_EXPECTED_RESULT[x]
        result = NAVSocketConnectionInit(conn, socketConnectionInitTestOptions[x])

        // Check if result matches expectation
        if (!NAVAssertBooleanEqual(SOCKET_CONNECTION_INIT_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        // If should pass, verify IsInitialized flag is set
        if (shouldPass) {
            if (!NAVAssertBooleanEqual('IsInitialized flag should be set', true, conn.IsInitialized)) {
                NAVLogTestFailed(x, 'true', NAVBooleanToString(conn.IsInitialized))
                continue
            }
        }
        else {
            // If should fail, verify IsInitialized flag is not set
            if (!NAVAssertBooleanEqual('IsInitialized flag should not be set', false, conn.IsInitialized)) {
                NAVLogTestFailed(x, 'false', NAVBooleanToString(conn.IsInitialized))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVSocketConnectionInit')
}
