PROGRAM_NAME='NAVCloudLogInit'

#include 'NAVFoundation.CloudLog.axi'


define_function TestNAVCloudLogInit() {
    stack_var integer x
    stack_var _NAVCloudLog log

    NAVLogTestSuiteStart("'NAVCloudLogInit'")

    // Test 1: Initialize structure
    log.id = 'existing-id'
    log.timestamp = '2024-01-01T00:00:00Z'
    log.clientId = 'test-client'
    log.hostName = 'test-host'
    log.firmwareVersion = 'v1.0'
    log.systemType = 'NetLinx'
    log.ipAddress = '192.168.1.100'
    log.roomName = 'Test Room'
    log.level = 'info'
    log.message = 'Test message'

    NAVCloudLogInit(log)

    // Verify all fields are empty
    if (!NAVAssertStringEqual('id field cleared', '', log.id)) {
        NAVLogTestFailed(1, '', log.id)
        NAVLogTestSuiteEnd("'NAVCloudLogInit'")
        return
    }

    if (!NAVAssertStringEqual('timestamp field cleared', '', log.timestamp)) {
        NAVLogTestFailed(1, '', log.timestamp)
        NAVLogTestSuiteEnd("'NAVCloudLogInit'")
        return
    }

    if (!NAVAssertStringEqual('clientId field cleared', '', log.clientId)) {
        NAVLogTestFailed(1, '', log.clientId)
        NAVLogTestSuiteEnd("'NAVCloudLogInit'")
        return
    }

    if (!NAVAssertStringEqual('hostName field cleared', '', log.hostName)) {
        NAVLogTestFailed(1, '', log.hostName)
        NAVLogTestSuiteEnd("'NAVCloudLogInit'")
        return
    }

    if (!NAVAssertStringEqual('firmwareVersion field cleared', '', log.firmwareVersion)) {
        NAVLogTestFailed(1, '', log.firmwareVersion)
        NAVLogTestSuiteEnd("'NAVCloudLogInit'")
        return
    }

    if (!NAVAssertStringEqual('systemType field cleared', '', log.systemType)) {
        NAVLogTestFailed(1, '', log.systemType)
        NAVLogTestSuiteEnd("'NAVCloudLogInit'")
        return
    }

    if (!NAVAssertStringEqual('ipAddress field cleared', '', log.ipAddress)) {
        NAVLogTestFailed(1, '', log.ipAddress)
        NAVLogTestSuiteEnd("'NAVCloudLogInit'")
        return
    }

    if (!NAVAssertStringEqual('roomName field cleared', '', log.roomName)) {
        NAVLogTestFailed(1, '', log.roomName)
        NAVLogTestSuiteEnd("'NAVCloudLogInit'")
        return
    }

    if (!NAVAssertStringEqual('level field cleared', '', log.level)) {
        NAVLogTestFailed(1, '', log.level)
        NAVLogTestSuiteEnd("'NAVCloudLogInit'")
        return
    }

    if (!NAVAssertStringEqual('message field cleared', '', log.message)) {
        NAVLogTestFailed(1, '', log.message)
        NAVLogTestSuiteEnd("'NAVCloudLogInit'")
        return
    }

    NAVLogTestPassed(1)

    NAVLogTestSuiteEnd("'NAVCloudLogInit'")
}
