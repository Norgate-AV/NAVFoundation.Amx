PROGRAM_NAME='NAVIsSocketDevice'

DEFINE_CONSTANT

constant integer IS_SOCKET_DEVICE_TEST_COUNT = 6

constant dev IS_SOCKET_DEVICE_TEST_VALUES[] = {
    0:2:0,      // 1: Valid socket device (port 2, system 0)
    0:10:0,     // 2: Valid socket device (port 10, system 0)
    0:50:0,     // 3: Valid socket device (port 50, system 0)
    5001:1:0,   // 4: Invalid: device number not 0
    33001:1:0,  // 5: Invalid: device number not 0
    0:0:0       // 6: Invalid: device number 0, port 0 (not a socket)
}

constant char IS_SOCKET_DEVICE_TEST_DESCRIPTIONS[][255] = {
    'Valid socket device: 0:2:0',
    'Valid socket device: 0:10:0',
    'Valid socket device: 0:50:0',
    'Invalid: device 5001:1:0 (device number not 0)',
    'Invalid: device 33001:1:0 (device number not 0)',
    'Invalid: device 0:0:0 (port 0)'
}

constant char IS_SOCKET_DEVICE_TEST_EXPECTED_RESULT[] = {
    true,   // 1: Valid socket device
    true,   // 2: Valid socket device
    true,   // 3: Valid socket device
    false,  // 4: Not a socket device (device number != 0)
    false,  // 5: Not a socket device (device number != 0)
    false   // 6: Port 0 typically not a socket
}


define_function TestNAVIsSocketDevice() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVIsSocketDevice')

    for (x = 1; x <= IS_SOCKET_DEVICE_TEST_COUNT; x++) {
        stack_var char result
        stack_var char shouldPass

        // Test if device is a socket device
        result = NAVIsSocketDevice(IS_SOCKET_DEVICE_TEST_VALUES[x])
        shouldPass = IS_SOCKET_DEVICE_TEST_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual(IS_SOCKET_DEVICE_TEST_DESCRIPTIONS[x], shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVIsSocketDevice')
}
