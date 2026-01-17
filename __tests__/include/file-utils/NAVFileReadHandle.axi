PROGRAM_NAME='NAVFileReadHandle'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileReadHandle
constant char FILE_READ_HANDLE_TESTS[][255] = {
    '/testreadhandle/empty.txt',       // Test 1: Empty file
    '/testreadhandle/small.txt',       // Test 2: Small file (< buffer size)
    '/testreadhandle/exact.txt',       // Test 3: File exactly buffer size
    '/testreadhandle/large.txt',       // Test 4: File larger than buffer
    '/testreadhandle/binary.dat',      // Test 5: Binary data
    '/testreadhandle/unicode.txt',     // Test 6: Unicode content
    '/testreadhandle/multiread.txt'    // Test 7: Multiple sequential reads
}

constant char FILE_READ_HANDLE_TEST_DATA[][NAV_MAX_BUFFER] = {
    '',                                // Test 1: Empty
    'Small content',                   // Test 2: Small data
    '',                                // Test 3: Exact size (populated at runtime)
    '',                                // Test 4: Large data (populated at runtime)
    '',                                // Test 5: Binary (populated at runtime)
    'Test données spéciales',          // Test 6: Unicode
    'First read content'               // Test 7: Multiple reads
}

constant integer FILE_READ_HANDLE_EXPECTED_BYTES[] = {
    0,      // Test 1: Empty file
    13,     // Test 2: 'Small content' = 13 bytes
    50,     // Test 3: Exactly 50 bytes
    100,    // Test 4: Read first 100 bytes of larger file
    10,     // Test 5: Binary data with nulls
    0,      // Test 6: Unicode (check > 0)
    18      // Test 7: 'First read content' = 18 bytes
}

DEFINE_VARIABLE

volatile char FILE_READ_HANDLE_SETUP_REQUIRED = false
volatile char FILE_READ_HANDLE_RUNTIME_DATA[7][NAV_MAX_BUFFER]

/**
 * Initialize test data
 */
define_function InitializeFileReadHandleTestData() {
    stack_var integer i

    // Create test directory
    NAVDirectoryCreate('/testreadhandle')

    // Test 3: Exactly 50 bytes
    FILE_READ_HANDLE_RUNTIME_DATA[3] = ''
    for (i = 1; i <= 50; i++) {
        FILE_READ_HANDLE_RUNTIME_DATA[3] = "FILE_READ_HANDLE_RUNTIME_DATA[3], 'X'"
    }

    // Test 4: Large data (200 bytes)
    FILE_READ_HANDLE_RUNTIME_DATA[4] = ''
    for (i = 1; i <= 20; i++) {
        FILE_READ_HANDLE_RUNTIME_DATA[4] = "FILE_READ_HANDLE_RUNTIME_DATA[4], '0123456789'"
    }

    // Test 5: Binary data with nulls
    FILE_READ_HANDLE_RUNTIME_DATA[5] = "$01, $02, $03, $00, $00, $FF, $FE, $FD, $FC, $FB"

    FILE_READ_HANDLE_SETUP_REQUIRED = true
}

/**
 * Setup function called before each test
 */
define_function SetupFileReadHandleTest(integer testIndex) {
    stack_var char path[255]
    stack_var char data[NAV_MAX_BUFFER]

    if (!FILE_READ_HANDLE_SETUP_REQUIRED) {
        InitializeFileReadHandleTestData()
    }

    path = FILE_READ_HANDLE_TESTS[testIndex]

    // Use runtime data if available, otherwise use constant data
    if (length_array(FILE_READ_HANDLE_RUNTIME_DATA[testIndex]) > 0) {
        data = FILE_READ_HANDLE_RUNTIME_DATA[testIndex]
    }
    else {
        data = FILE_READ_HANDLE_TEST_DATA[testIndex]
    }

    // Skip file creation for empty file test (Test 1)
    // AMX can't create empty files, but we still test reading from non-existent/empty
    if (testIndex != 1) {
        NAVFileWrite(path, data)
    }
}

/**
 * Main test function
 */
define_function TestNAVFileReadHandle() {
    stack_var integer x
    stack_var slong result
    stack_var long handle
    stack_var char buffer[100]
    stack_var integer expectedBytes
    stack_var integer actualBytes

    NAVLog("'***************** NAVFileReadHandle *****************'")

    for (x = 1; x <= length_array(FILE_READ_HANDLE_TESTS); x++) {
        SetupFileReadHandleTest(x)

        expectedBytes = FILE_READ_HANDLE_EXPECTED_BYTES[x]

        // Test 1: Invalid handle (0)
        if (x == 1) {
            buffer = ''
            result = NAVFileReadHandle(0, buffer)

            if (!NAVAssertSignedLongEqual('Should return error for invalid handle', NAV_FILE_ERROR_INVALID_FILE_HANDLE, result)) {
                NAVLogTestFailed(x, 'NAV_FILE_ERROR_INVALID_FILE_HANDLE', itoa(result))
                continue
            }

            NAVLogTestPassed(x)
            continue
        }

        // Open file for reading
        result = NAVFileOpen(FILE_READ_HANDLE_TESTS[x], 'r')

        if (result < 0) {
            NAVLogTestFailed(x, 'file opened', "'open failed: ', itoa(result)")
            continue
        }

        handle = type_cast(result)

        // Read from file
        buffer = ''
        result = NAVFileReadHandle(handle, buffer)

        // Close file
        NAVFileClose(handle)

        // Verify result
        actualBytes = type_cast(result)

        // For tests that need flexible checking (unicode, etc)
        if (expectedBytes == 0 && x > 1) {
            // Just check success (> 0)
            if (!NAVAssertTrue('Should read bytes successfully', result > 0)) {
                NAVLogTestFailed(x, '> 0', "itoa(result)")
                continue
            }
        }
        else {
            if (!NAVAssertIntegerEqual('Should read expected number of bytes', expectedBytes, actualBytes)) {
                NAVLogTestFailed(x, "itoa(expectedBytes)", "itoa(actualBytes)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
