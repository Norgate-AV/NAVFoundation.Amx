PROGRAM_NAME='NAVFileWriteHandle'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileWriteHandle
constant char FILE_WRITE_HANDLE_TESTS[][255] = {
    '/testwritehandle/single.txt',     // Test 1: Single write
    '/testwritehandle/multiple.txt',   // Test 2: Multiple writes
    '/testwritehandle/empty.txt',      // Test 3: Empty data write
    '/testwritehandle/large.txt',      // Test 4: Large data
    '/testwritehandle/binary.dat',     // Test 5: Binary data
    '/testwritehandle/append.txt',     // Test 6: Append mode
    '/testwritehandle/overwrite.txt'   // Test 7: Overwrite existing
}

constant char FILE_WRITE_HANDLE_TEST_DATA[][NAV_MAX_BUFFER] = {
    'Single write test',               // Test 1
    'First write',                     // Test 2: First of multiple
    '',                                // Test 3: Empty
    '',                                // Test 4: Large (populated at runtime)
    '',                                // Test 5: Binary (populated at runtime)
    'Appended data',                   // Test 6
    'New content'                      // Test 7
}

constant slong FILE_WRITE_HANDLE_EXPECTED_RESULT[] = {
    17,     // Test 1: 'Single write test' = 17 bytes
    11,     // Test 2: 'First write' = 11 bytes (first write only)
    -6,     // Test 3: NAV_FILE_ERROR_INVALID_PARAMETER (empty data)
    0,      // Test 4: Success (check >= 0)
    10,     // Test 5: Binary data = 10 bytes
    13,     // Test 6: 'Appended data' = 13 bytes
    11      // Test 7: 'New content' = 11 bytes
}

DEFINE_VARIABLE

volatile char FILE_WRITE_HANDLE_SETUP_REQUIRED = false
volatile char FILE_WRITE_HANDLE_RUNTIME_DATA[7][NAV_MAX_BUFFER]

/**
 * Initialize test data
 */
define_function InitializeFileWriteHandleTestData() {
    stack_var integer i

    // Create test directory
    NAVDirectoryCreate('/testwritehandle')

    // Test 4: Large data (1000 bytes)
    FILE_WRITE_HANDLE_RUNTIME_DATA[4] = ''
    for (i = 1; i <= 100; i++) {
        FILE_WRITE_HANDLE_RUNTIME_DATA[4] = "FILE_WRITE_HANDLE_RUNTIME_DATA[4], '0123456789'"
    }

    // Test 5: Binary data with nulls
    FILE_WRITE_HANDLE_RUNTIME_DATA[5] = "$01, $02, $03, $00, $00, $FF, $FE, $FD, $FC, $FB"

    FILE_WRITE_HANDLE_SETUP_REQUIRED = true
}

/**
 * Setup function called before each test
 */
define_function SetupFileWriteHandleTest(integer testIndex) {
    if (!FILE_WRITE_HANDLE_SETUP_REQUIRED) {
        InitializeFileWriteHandleTestData()
    }

    // Test 6: Create initial file for append test
    if (testIndex == 6) {
        NAVFileWrite(FILE_WRITE_HANDLE_TESTS[testIndex], 'Initial content')
    }

    // Test 7: Create file to overwrite
    if (testIndex == 7) {
        NAVFileWrite(FILE_WRITE_HANDLE_TESTS[testIndex], 'Old content to be replaced')
    }
}

/**
 * Main test function
 */
define_function TestNAVFileWriteHandle() {
    stack_var integer x
    stack_var slong result
    stack_var long handle
    stack_var char data[NAV_MAX_BUFFER]
    stack_var slong expectedResult
    stack_var char mode[3]
    stack_var char readback[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVFileWriteHandle *****************'")

    for (x = 1; x <= length_array(FILE_WRITE_HANDLE_TESTS); x++) {
        SetupFileWriteHandleTest(x)

        expectedResult = type_cast(FILE_WRITE_HANDLE_EXPECTED_RESULT[x])

        // Get test data
        if (length_array(FILE_WRITE_HANDLE_RUNTIME_DATA[x]) > 0) {
            data = FILE_WRITE_HANDLE_RUNTIME_DATA[x]
        }
        else {
            data = FILE_WRITE_HANDLE_TEST_DATA[x]
        }

        // Test 1: Invalid handle (0)
        if (x == 1) {
            result = NAVFileWriteHandle(0, data)

            if (!NAVAssertSignedLongEqual('Should return error for invalid handle', NAV_FILE_ERROR_INVALID_FILE_HANDLE, result)) {
                NAVLogTestFailed(x, 'NAV_FILE_ERROR_INVALID_FILE_HANDLE', itoa(result))
                continue
            }

            NAVLogTestPassed(x)
            continue
        }

        // Determine mode: append for test 6, overwrite for others
        if (x == 6) {
            mode = 'rwa'
        }
        else {
            mode = 'rw'
        }

        // Open file
        result = NAVFileOpen(FILE_WRITE_HANDLE_TESTS[x], mode)

        if (result < 0) {
            NAVLogTestFailed(x, 'file opened', "'open failed: ', itoa(result)")
            continue
        }

        handle = type_cast(result)

        // Test 2: Multiple writes
        if (x == 2) {
            // First write
            result = NAVFileWriteHandle(handle, data)

            if (type_cast(result) != expectedResult) {
                NAVFileClose(handle)
                NAVLogTestFailed(x, "itoa(expectedResult)", "itoa(result)")
                continue
            }

            // Second write
            result = NAVFileWriteHandle(handle, ' Second write')

            NAVFileClose(handle)

            // Verify both writes
            readback = ''
            NAVFileRead(FILE_WRITE_HANDLE_TESTS[x], readback)

            if (!NAVAssertStringEqual('Should contain both writes', 'First write Second write', readback)) {
                NAVLogTestFailed(x, 'First write Second write', readback)
                continue
            }

            NAVLogTestPassed(x)
            continue
        }

        // Write data
        result = NAVFileWriteHandle(handle, data)

        // Close file
        NAVFileClose(handle)

        // Verify result
        if (expectedResult == 0) {
            // Just check success (>= 0)
            if (!NAVAssertTrue('Should write successfully', result >= 0)) {
                NAVLogTestFailed(x, '>= 0', "itoa(result)")
                continue
            }
        }
        else {
            if (!NAVAssertSignedLongEqual('Should write expected number of bytes', expectedResult, result)) {
                NAVLogTestFailed(x, "itoa(expectedResult)", "itoa(result)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
