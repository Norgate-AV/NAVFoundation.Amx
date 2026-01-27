PROGRAM_NAME='NAVCloudLogJsonSerialize'

#include 'NAVFoundation.CloudLog.axi'


DEFINE_VARIABLE

volatile _NAVCloudLog CLOUDLOG_JSON_SERIALIZE_TEST[10]


define_function InitializeCloudLogJsonSerializeTestData() {
    // Test 1: Simple log entry
    CLOUDLOG_JSON_SERIALIZE_TEST[1].id = '12345678-1234-4abc-9abc-123456789012'
    CLOUDLOG_JSON_SERIALIZE_TEST[1].timestamp = '2024-01-15T14:30:00.000Z'
    CLOUDLOG_JSON_SERIALIZE_TEST[1].clientId = 'MyApp'
    CLOUDLOG_JSON_SERIALIZE_TEST[1].hostName = 'CONTROLLER-01'
    CLOUDLOG_JSON_SERIALIZE_TEST[1].systemType = 'NetLinx'
    CLOUDLOG_JSON_SERIALIZE_TEST[1].firmwareVersion = 'v4.9.123'
    CLOUDLOG_JSON_SERIALIZE_TEST[1].ipAddress = '192.168.1.100'
    CLOUDLOG_JSON_SERIALIZE_TEST[1].roomName = 'Conference Room A'
    CLOUDLOG_JSON_SERIALIZE_TEST[1].level = 'info'
    CLOUDLOG_JSON_SERIALIZE_TEST[1].message = 'System started'

    // Test 2: Log entry with special characters in message
    CLOUDLOG_JSON_SERIALIZE_TEST[2].id = 'abcdef01-2345-4678-9abc-def012345678'
    CLOUDLOG_JSON_SERIALIZE_TEST[2].timestamp = '2024-01-15T15:00:00.000Z'
    CLOUDLOG_JSON_SERIALIZE_TEST[2].clientId = 'TestApp'
    CLOUDLOG_JSON_SERIALIZE_TEST[2].hostName = 'CONTROLLER-02'
    CLOUDLOG_JSON_SERIALIZE_TEST[2].systemType = 'NetLinx'
    CLOUDLOG_JSON_SERIALIZE_TEST[2].firmwareVersion = 'v4.9.124'
    CLOUDLOG_JSON_SERIALIZE_TEST[2].ipAddress = '192.168.1.101'
    CLOUDLOG_JSON_SERIALIZE_TEST[2].roomName = 'Lab'
    CLOUDLOG_JSON_SERIALIZE_TEST[2].level = 'error'
    CLOUDLOG_JSON_SERIALIZE_TEST[2].message = 'Error: "Connection failed"'

    // Test 3: Log entry with quotes in clientId and roomName
    CLOUDLOG_JSON_SERIALIZE_TEST[3].id = 'test-id-3'
    CLOUDLOG_JSON_SERIALIZE_TEST[3].timestamp = '2024-01-15T16:00:00.000Z'
    CLOUDLOG_JSON_SERIALIZE_TEST[3].clientId = 'App "Main"'
    CLOUDLOG_JSON_SERIALIZE_TEST[3].hostName = 'HOST'
    CLOUDLOG_JSON_SERIALIZE_TEST[3].systemType = 'NetLinx'
    CLOUDLOG_JSON_SERIALIZE_TEST[3].firmwareVersion = 'v1.0'
    CLOUDLOG_JSON_SERIALIZE_TEST[3].ipAddress = '10.0.0.1'
    CLOUDLOG_JSON_SERIALIZE_TEST[3].roomName = 'Room "Alpha"'
    CLOUDLOG_JSON_SERIALIZE_TEST[3].level = 'warning'
    CLOUDLOG_JSON_SERIALIZE_TEST[3].message = 'Warning message'

    // Test 4: Log entry with backslashes
    CLOUDLOG_JSON_SERIALIZE_TEST[4].id = 'test-id-4'
    CLOUDLOG_JSON_SERIALIZE_TEST[4].timestamp = '2024-01-15T17:00:00.000Z'
    CLOUDLOG_JSON_SERIALIZE_TEST[4].clientId = 'Client'
    CLOUDLOG_JSON_SERIALIZE_TEST[4].hostName = 'SERVER\HOST'
    CLOUDLOG_JSON_SERIALIZE_TEST[4].systemType = 'NetLinx'
    CLOUDLOG_JSON_SERIALIZE_TEST[4].firmwareVersion = 'v2.0\beta'
    CLOUDLOG_JSON_SERIALIZE_TEST[4].ipAddress = '172.16.0.1'
    CLOUDLOG_JSON_SERIALIZE_TEST[4].roomName = 'Path\To\Room'
    CLOUDLOG_JSON_SERIALIZE_TEST[4].level = 'debug'
    CLOUDLOG_JSON_SERIALIZE_TEST[4].message = 'File at C:\temp\file.txt'

    // Test 5: Empty message
    CLOUDLOG_JSON_SERIALIZE_TEST[5].id = 'test-id-5'
    CLOUDLOG_JSON_SERIALIZE_TEST[5].timestamp = '2024-01-15T18:00:00.000Z'
    CLOUDLOG_JSON_SERIALIZE_TEST[5].clientId = 'App'
    CLOUDLOG_JSON_SERIALIZE_TEST[5].hostName = 'HOST'
    CLOUDLOG_JSON_SERIALIZE_TEST[5].systemType = 'NetLinx'
    CLOUDLOG_JSON_SERIALIZE_TEST[5].firmwareVersion = 'v1.0'
    CLOUDLOG_JSON_SERIALIZE_TEST[5].ipAddress = '192.168.1.1'
    CLOUDLOG_JSON_SERIALIZE_TEST[5].roomName = 'Room'
    CLOUDLOG_JSON_SERIALIZE_TEST[5].level = 'info'
    CLOUDLOG_JSON_SERIALIZE_TEST[5].message = ''

    // Test 6: IPv6 address
    CLOUDLOG_JSON_SERIALIZE_TEST[6].id = 'test-id-6'
    CLOUDLOG_JSON_SERIALIZE_TEST[6].timestamp = '2024-01-15T19:00:00.000Z'
    CLOUDLOG_JSON_SERIALIZE_TEST[6].clientId = 'App'
    CLOUDLOG_JSON_SERIALIZE_TEST[6].hostName = 'HOST'
    CLOUDLOG_JSON_SERIALIZE_TEST[6].systemType = 'NetLinx'
    CLOUDLOG_JSON_SERIALIZE_TEST[6].firmwareVersion = 'v1.0'
    CLOUDLOG_JSON_SERIALIZE_TEST[6].ipAddress = '2001:0db8:85a3:0000:0000:8a2e:0370:7334'
    CLOUDLOG_JSON_SERIALIZE_TEST[6].roomName = 'Room'
    CLOUDLOG_JSON_SERIALIZE_TEST[6].level = 'info'
    CLOUDLOG_JSON_SERIALIZE_TEST[6].message = 'IPv6 test'

    // Test 7: Message with newline
    CLOUDLOG_JSON_SERIALIZE_TEST[7].id = 'test-id-7'
    CLOUDLOG_JSON_SERIALIZE_TEST[7].timestamp = '2024-01-15T20:00:00.000Z'
    CLOUDLOG_JSON_SERIALIZE_TEST[7].clientId = 'App'
    CLOUDLOG_JSON_SERIALIZE_TEST[7].hostName = 'HOST'
    CLOUDLOG_JSON_SERIALIZE_TEST[7].systemType = 'NetLinx'
    CLOUDLOG_JSON_SERIALIZE_TEST[7].firmwareVersion = 'v1.0'
    CLOUDLOG_JSON_SERIALIZE_TEST[7].ipAddress = '192.168.1.1'
    CLOUDLOG_JSON_SERIALIZE_TEST[7].roomName = 'Room'
    CLOUDLOG_JSON_SERIALIZE_TEST[7].level = 'error'
    CLOUDLOG_JSON_SERIALIZE_TEST[7].message = "'Line1', $0A, 'Line2'"

    // Test 8: Message with tab
    CLOUDLOG_JSON_SERIALIZE_TEST[8].id = 'test-id-8'
    CLOUDLOG_JSON_SERIALIZE_TEST[8].timestamp = '2024-01-15T21:00:00.000Z'
    CLOUDLOG_JSON_SERIALIZE_TEST[8].clientId = 'App'
    CLOUDLOG_JSON_SERIALIZE_TEST[8].hostName = 'HOST'
    CLOUDLOG_JSON_SERIALIZE_TEST[8].systemType = 'NetLinx'
    CLOUDLOG_JSON_SERIALIZE_TEST[8].firmwareVersion = 'v1.0'
    CLOUDLOG_JSON_SERIALIZE_TEST[8].ipAddress = '192.168.1.1'
    CLOUDLOG_JSON_SERIALIZE_TEST[8].roomName = 'Room'
    CLOUDLOG_JSON_SERIALIZE_TEST[8].level = 'warning'
    CLOUDLOG_JSON_SERIALIZE_TEST[8].message = "'Col1', $09, 'Col2'"

    // Test 9: All levels (debug)
    CLOUDLOG_JSON_SERIALIZE_TEST[9].id = 'test-id-9'
    CLOUDLOG_JSON_SERIALIZE_TEST[9].timestamp = '2024-01-15T22:00:00.000Z'
    CLOUDLOG_JSON_SERIALIZE_TEST[9].clientId = 'App'
    CLOUDLOG_JSON_SERIALIZE_TEST[9].hostName = 'HOST'
    CLOUDLOG_JSON_SERIALIZE_TEST[9].systemType = 'NetLinx'
    CLOUDLOG_JSON_SERIALIZE_TEST[9].firmwareVersion = 'v1.0'
    CLOUDLOG_JSON_SERIALIZE_TEST[9].ipAddress = '192.168.1.1'
    CLOUDLOG_JSON_SERIALIZE_TEST[9].roomName = 'Room'
    CLOUDLOG_JSON_SERIALIZE_TEST[9].level = 'debug'
    CLOUDLOG_JSON_SERIALIZE_TEST[9].message = 'Debug message'

    // Test 10: Complex message with multiple escape sequences
    CLOUDLOG_JSON_SERIALIZE_TEST[10].id = 'test-id-10'
    CLOUDLOG_JSON_SERIALIZE_TEST[10].timestamp = '2024-01-15T23:00:00.000Z'
    CLOUDLOG_JSON_SERIALIZE_TEST[10].clientId = 'App'
    CLOUDLOG_JSON_SERIALIZE_TEST[10].hostName = 'HOST'
    CLOUDLOG_JSON_SERIALIZE_TEST[10].systemType = 'NetLinx'
    CLOUDLOG_JSON_SERIALIZE_TEST[10].firmwareVersion = 'v1.0'
    CLOUDLOG_JSON_SERIALIZE_TEST[10].ipAddress = '192.168.1.1'
    CLOUDLOG_JSON_SERIALIZE_TEST[10].roomName = 'Room'
    CLOUDLOG_JSON_SERIALIZE_TEST[10].level = 'error'
    CLOUDLOG_JSON_SERIALIZE_TEST[10].message = "'Error: "Failed"', $0A, 'Path: \temp\file'"

    set_length_array(CLOUDLOG_JSON_SERIALIZE_TEST, 10)
}


DEFINE_CONSTANT

constant char CLOUDLOG_JSON_SERIALIZE_EXPECTED[10][2048] = {
    // Test 1: Simple entry
    '{"id":"12345678-1234-4abc-9abc-123456789012","timestamp":"2024-01-15T14:30:00.000Z","clientId":"MyApp","hostName":"CONTROLLER-01","systemType":"NetLinx","firmwareVersion":"v4.9.123","ipAddress":"192.168.1.100","roomName":"Conference Room A","level":"info","message":"System started"}',

    // Test 2: Special characters in message
    '{"id":"abcdef01-2345-4678-9abc-def012345678","timestamp":"2024-01-15T15:00:00.000Z","clientId":"TestApp","hostName":"CONTROLLER-02","systemType":"NetLinx","firmwareVersion":"v4.9.124","ipAddress":"192.168.1.101","roomName":"Lab","level":"error","message":"Error: \"Connection failed\""}',

    // Test 3: Quotes in clientId and roomName
    '{"id":"test-id-3","timestamp":"2024-01-15T16:00:00.000Z","clientId":"App \"Main\"","hostName":"HOST","systemType":"NetLinx","firmwareVersion":"v1.0","ipAddress":"10.0.0.1","roomName":"Room \"Alpha\"","level":"warning","message":"Warning message"}',

    // Test 4: Backslashes
    '{"id":"test-id-4","timestamp":"2024-01-15T17:00:00.000Z","clientId":"Client","hostName":"SERVER\\HOST","systemType":"NetLinx","firmwareVersion":"v2.0\\beta","ipAddress":"172.16.0.1","roomName":"Path\\To\\Room","level":"debug","message":"File at C:\\temp\\file.txt"}',

    // Test 5: Empty message
    '{"id":"test-id-5","timestamp":"2024-01-15T18:00:00.000Z","clientId":"App","hostName":"HOST","systemType":"NetLinx","firmwareVersion":"v1.0","ipAddress":"192.168.1.1","roomName":"Room","level":"info","message":""}',

    // Test 6: IPv6 address
    '{"id":"test-id-6","timestamp":"2024-01-15T19:00:00.000Z","clientId":"App","hostName":"HOST","systemType":"NetLinx","firmwareVersion":"v1.0","ipAddress":"2001:0db8:85a3:0000:0000:8a2e:0370:7334","roomName":"Room","level":"info","message":"IPv6 test"}',

    // Test 7: Newline in message
    '{"id":"test-id-7","timestamp":"2024-01-15T20:00:00.000Z","clientId":"App","hostName":"HOST","systemType":"NetLinx","firmwareVersion":"v1.0","ipAddress":"192.168.1.1","roomName":"Room","level":"error","message":"Line1\nLine2"}',

    // Test 8: Tab in message
    '{"id":"test-id-8","timestamp":"2024-01-15T21:00:00.000Z","clientId":"App","hostName":"HOST","systemType":"NetLinx","firmwareVersion":"v1.0","ipAddress":"192.168.1.1","roomName":"Room","level":"warning","message":"Col1\tCol2"}',

    // Test 9: Debug level
    '{"id":"test-id-9","timestamp":"2024-01-15T22:00:00.000Z","clientId":"App","hostName":"HOST","systemType":"NetLinx","firmwareVersion":"v1.0","ipAddress":"192.168.1.1","roomName":"Room","level":"debug","message":"Debug message"}',

    // Test 10: Complex message
    '{"id":"test-id-10","timestamp":"2024-01-15T23:00:00.000Z","clientId":"App","hostName":"HOST","systemType":"NetLinx","firmwareVersion":"v1.0","ipAddress":"192.168.1.1","roomName":"Room","level":"error","message":"Error: \"Failed\"\nPath: \\temp\\file"}'
}


define_function TestNAVCloudLogJsonSerialize() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVCloudLogJsonSerialize'")

    InitializeCloudLogJsonSerializeTestData()

    for (x = 1; x <= length_array(CLOUDLOG_JSON_SERIALIZE_TEST); x++) {
        stack_var char result[NAV_CLOUDLOG_JSON_BUFFER_SIZE]

        result = NAVCloudLogJsonSerialize(CLOUDLOG_JSON_SERIALIZE_TEST[x])

        if (!NAVAssertStringEqual('NAVCloudLogJsonSerialize result',
                                  CLOUDLOG_JSON_SERIALIZE_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            CLOUDLOG_JSON_SERIALIZE_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVCloudLogJsonSerialize'")
}
