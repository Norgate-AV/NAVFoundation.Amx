PROGRAM_NAME='NAVCloudLogValidate'

#include 'NAVFoundation.CloudLog.axi'


DEFINE_VARIABLE

volatile char CLOUDLOG_VALIDATE_TEST_CLIENT_ID[10][128]
volatile char CLOUDLOG_VALIDATE_TEST_ROOM_NAME[10][128]
volatile char CLOUDLOG_VALIDATE_TEST_MESSAGE[10][512]


define_function InitializeCloudLogValidateTestData() {
    stack_var integer x
    stack_var char longString[512]

    // Test 1: All fields within limits
    CLOUDLOG_VALIDATE_TEST_CLIENT_ID[1] = 'MyApp'
    CLOUDLOG_VALIDATE_TEST_ROOM_NAME[1] = 'Conference Room A'
    CLOUDLOG_VALIDATE_TEST_MESSAGE[1] = 'System started successfully'

    // Test 2: Empty fields (valid)
    CLOUDLOG_VALIDATE_TEST_CLIENT_ID[2] = ''
    CLOUDLOG_VALIDATE_TEST_ROOM_NAME[2] = ''
    CLOUDLOG_VALIDATE_TEST_MESSAGE[2] = ''

    // Test 3: Maximum length clientId (127 chars - should pass)
    for (x = 1; x <= 127; x++) {
        CLOUDLOG_VALIDATE_TEST_CLIENT_ID[3] = "CLOUDLOG_VALIDATE_TEST_CLIENT_ID[3], 'A'"
    }
    CLOUDLOG_VALIDATE_TEST_ROOM_NAME[3] = 'Room'
    CLOUDLOG_VALIDATE_TEST_MESSAGE[3] = 'Message'

    // Test 4: Over maximum length clientId (128+ chars - should fail)
    for (x = 1; x <= 128; x++) {
        CLOUDLOG_VALIDATE_TEST_CLIENT_ID[4] = "CLOUDLOG_VALIDATE_TEST_CLIENT_ID[4], 'A'"
    }
    CLOUDLOG_VALIDATE_TEST_ROOM_NAME[4] = 'Room'
    CLOUDLOG_VALIDATE_TEST_MESSAGE[4] = 'Message'

    // Test 5: Maximum length roomName (127 chars - should pass)
    CLOUDLOG_VALIDATE_TEST_CLIENT_ID[5] = 'Client'
    for (x = 1; x <= 127; x++) {
        CLOUDLOG_VALIDATE_TEST_ROOM_NAME[5] = "CLOUDLOG_VALIDATE_TEST_ROOM_NAME[5], 'B'"
    }
    CLOUDLOG_VALIDATE_TEST_MESSAGE[5] = 'Message'

    // Test 6: Over maximum length roomName (128+ chars - should fail)
    CLOUDLOG_VALIDATE_TEST_CLIENT_ID[6] = 'Client'
    for (x = 1; x <= 128; x++) {
        CLOUDLOG_VALIDATE_TEST_ROOM_NAME[6] = "CLOUDLOG_VALIDATE_TEST_ROOM_NAME[6], 'B'"
    }
    CLOUDLOG_VALIDATE_TEST_MESSAGE[6] = 'Message'

    // Test 7: Maximum length message (511 chars - should pass)
    CLOUDLOG_VALIDATE_TEST_CLIENT_ID[7] = 'Client'
    CLOUDLOG_VALIDATE_TEST_ROOM_NAME[7] = 'Room'
    for (x = 1; x <= 511; x++) {
        CLOUDLOG_VALIDATE_TEST_MESSAGE[7] = "CLOUDLOG_VALIDATE_TEST_MESSAGE[7], 'C'"
    }

    // Test 8: Over maximum length message (512+ chars - should fail)
    CLOUDLOG_VALIDATE_TEST_CLIENT_ID[8] = 'Client'
    CLOUDLOG_VALIDATE_TEST_ROOM_NAME[8] = 'Room'
    for (x = 1; x <= 512; x++) {
        CLOUDLOG_VALIDATE_TEST_MESSAGE[8] = "CLOUDLOG_VALIDATE_TEST_MESSAGE[8], 'C'"
    }

    // Test 9: All fields at maximum valid length
    for (x = 1; x <= 127; x++) {
        CLOUDLOG_VALIDATE_TEST_CLIENT_ID[9] = "CLOUDLOG_VALIDATE_TEST_CLIENT_ID[9], 'D'"
    }
    for (x = 1; x <= 127; x++) {
        CLOUDLOG_VALIDATE_TEST_ROOM_NAME[9] = "CLOUDLOG_VALIDATE_TEST_ROOM_NAME[9], 'E'"
    }
    for (x = 1; x <= 511; x++) {
        CLOUDLOG_VALIDATE_TEST_MESSAGE[9] = "CLOUDLOG_VALIDATE_TEST_MESSAGE[9], 'F'"
    }

    // Test 10: Single character fields (valid)
    CLOUDLOG_VALIDATE_TEST_CLIENT_ID[10] = 'A'
    CLOUDLOG_VALIDATE_TEST_ROOM_NAME[10] = 'B'
    CLOUDLOG_VALIDATE_TEST_MESSAGE[10] = 'C'

    set_length_array(CLOUDLOG_VALIDATE_TEST_CLIENT_ID, 10)
    set_length_array(CLOUDLOG_VALIDATE_TEST_ROOM_NAME, 10)
    set_length_array(CLOUDLOG_VALIDATE_TEST_MESSAGE, 10)
}


DEFINE_CONSTANT

constant char CLOUDLOG_VALIDATE_EXPECTED[10] = {
    true,   // Test 1: All valid
    true,   // Test 2: Empty (valid)
    true,   // Test 3: Max clientId (127 chars - valid)
    false,  // Test 4: Over max clientId (128+ chars - invalid)
    true,   // Test 5: Max roomName (127 chars - valid)
    false,  // Test 6: Over max roomName (128+ chars - invalid)
    true,   // Test 7: Max message (511 chars - valid)
    false,  // Test 8: Over max message (512+ chars - invalid)
    true,   // Test 9: All fields at max valid length
    true    // Test 10: Single character fields
}


define_function TestNAVCloudLogValidate() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVCloudLogValidate'")

    InitializeCloudLogValidateTestData()

    for (x = 1; x <= length_array(CLOUDLOG_VALIDATE_TEST_CLIENT_ID); x++) {
        stack_var char result

        result = NAVCloudLogValidate(CLOUDLOG_VALIDATE_TEST_CLIENT_ID[x],
                                     CLOUDLOG_VALIDATE_TEST_ROOM_NAME[x],
                                     CLOUDLOG_VALIDATE_TEST_MESSAGE[x])

        if (!NAVAssertBooleanEqual('NAVCloudLogValidate result',
                                    CLOUDLOG_VALIDATE_EXPECTED[x],
                                    result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(CLOUDLOG_VALIDATE_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVCloudLogValidate'")
}
