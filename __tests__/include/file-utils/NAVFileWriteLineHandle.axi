PROGRAM_NAME='NAVFileWriteLineHandle'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileWriteLineHandle
constant char FILE_WRITE_LINE_HANDLE_TESTS[][255] = {
    '/testwritelinehandle/single.txt',     // Test 1: Single line
    '/testwritelinehandle/multiple.txt',   // Test 2: Multiple lines
    '/testwritelinehandle/empty.txt',      // Test 3: Empty line
    '/testwritelinehandle/long.txt',       // Test 4: Long line
    '/testwritelinehandle/special.txt',    // Test 5: Special characters
    '/testwritelinehandle/append.txt',     // Test 6: Append mode
    '/testwritelinehandle/mixed.txt'       // Test 7: Mixed with NAVFileWriteHandle
}

constant char FILE_WRITE_LINE_HANDLE_TEST_DATA[][NAV_MAX_BUFFER] = {
    'Single line',                         // Test 1
    'Line 1',                              // Test 2: First line
    '',                                    // Test 3: Empty line
    '',                                    // Test 4: Long line (populated at runtime)
    'Special: !@#$%^&*()',                 // Test 5
    'Appended line',                       // Test 6
    'Line via WriteLine'                   // Test 7
}

constant integer FILE_WRITE_LINE_HANDLE_EXPECTED_LINES[] = {
    1,      // Test 1: Single line
    3,      // Test 2: Three lines
    1,      // Test 3: Empty line (still creates a line with CRLF)
    1,      // Test 4: One long line
    1,      // Test 5: One line with special chars
    2,      // Test 6: Original + appended line
    2       // Test 7: WriteLine + WriteHandle lines
}

DEFINE_VARIABLE

volatile char FILE_WRITE_LINE_HANDLE_SETUP_REQUIRED = false
volatile char FILE_WRITE_LINE_HANDLE_RUNTIME_DATA[7][NAV_MAX_BUFFER]

/**
 * Initialize test data
 */
define_function InitializeFileWriteLineHandleTestData() {
    stack_var integer i

    // Create test directory
    NAVDirectoryCreate('/testwritelinehandle')

    // Test 4: Long line (200 characters)
    FILE_WRITE_LINE_HANDLE_RUNTIME_DATA[4] = ''
    for (i = 1; i <= 20; i++) {
        FILE_WRITE_LINE_HANDLE_RUNTIME_DATA[4] = "FILE_WRITE_LINE_HANDLE_RUNTIME_DATA[4], '0123456789'"
    }

    FILE_WRITE_LINE_HANDLE_SETUP_REQUIRED = true
}

/**
 * Setup function called before each test
 */
define_function SetupFileWriteLineHandleTest(integer testIndex) {
    if (!FILE_WRITE_LINE_HANDLE_SETUP_REQUIRED) {
        InitializeFileWriteLineHandleTestData()
    }

    // Test 6: Create initial file for append test
    if (testIndex == 6) {
        NAVFileWriteLine(FILE_WRITE_LINE_HANDLE_TESTS[testIndex], 'Initial line')
    }
}

/**
 * Count lines in a file
 */
define_function integer CountLinesInFile(char path[]) {
    stack_var slong result
    stack_var long handle
    stack_var char line[NAV_MAX_BUFFER]
    stack_var integer lineCount

    result = NAVFileOpen(path, 'r')
    if (result < 0) {
        return 0
    }

    handle = type_cast(result)
    lineCount = 0

    while (1) {
        line = ''
        result = NAVFileReadLineHandle(handle, line)

        if (result < 0) {
            break
        }

        lineCount++
    }

    NAVFileClose(handle)
    return lineCount
}

/**
 * Main test function
 */
define_function TestNAVFileWriteLineHandle() {
    stack_var integer x
    stack_var slong result
    stack_var long handle
    stack_var char data[NAV_MAX_BUFFER]
    stack_var integer expectedLines
    stack_var integer actualLines
    stack_var char mode[3]

    NAVLog("'***************** NAVFileWriteLineHandle *****************'")

    for (x = 1; x <= length_array(FILE_WRITE_LINE_HANDLE_TESTS); x++) {
        SetupFileWriteLineHandleTest(x)

        expectedLines = FILE_WRITE_LINE_HANDLE_EXPECTED_LINES[x]

        // Get test data
        if (length_array(FILE_WRITE_LINE_HANDLE_RUNTIME_DATA[x]) > 0) {
            data = FILE_WRITE_LINE_HANDLE_RUNTIME_DATA[x]
        }
        else {
            data = FILE_WRITE_LINE_HANDLE_TEST_DATA[x]
        }

        // Test 1: Invalid handle (0)
        if (x == 1) {
            result = NAVFileWriteLineHandle(0, data)

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
        result = NAVFileOpen(FILE_WRITE_LINE_HANDLE_TESTS[x], mode)

        if (result < 0) {
            NAVLogTestFailed(x, 'file opened', "'open failed: ', itoa(result)")
            continue
        }

        handle = type_cast(result)

        // Test 2: Multiple lines
        if (x == 2) {
            NAVFileWriteLineHandle(handle, 'Line 1')
            NAVFileWriteLineHandle(handle, 'Line 2')
            NAVFileWriteLineHandle(handle, 'Line 3')
            NAVFileClose(handle)

            actualLines = CountLinesInFile(FILE_WRITE_LINE_HANDLE_TESTS[x])

            if (!NAVAssertIntegerEqual('Should write three lines', expectedLines, actualLines)) {
                NAVLogTestFailed(x, "itoa(expectedLines)", "itoa(actualLines)")
                continue
            }

            NAVLogTestPassed(x)
            continue
        }

        // Test 7: Mixed WriteLine and Write
        if (x == 7) {
            NAVFileWriteLineHandle(handle, data)
            NAVFileWriteHandle(handle, "'Raw line without CRLF', NAV_CR, NAV_LF")
            NAVFileClose(handle)

            actualLines = CountLinesInFile(FILE_WRITE_LINE_HANDLE_TESTS[x])

            if (!NAVAssertIntegerEqual('Should write two lines', expectedLines, actualLines)) {
                NAVLogTestFailed(x, "itoa(expectedLines)", "itoa(actualLines)")
                continue
            }

            NAVLogTestPassed(x)
            continue
        }

        // Write single line
        result = NAVFileWriteLineHandle(handle, data)

        // Close file
        NAVFileClose(handle)

        // Verify result is success
        if (!NAVAssertTrue('Should write successfully', result >= 0)) {
            NAVLogTestFailed(x, '>= 0', "itoa(result)")
            continue
        }

        // Count lines in file
        actualLines = CountLinesInFile(FILE_WRITE_LINE_HANDLE_TESTS[x])

        if (!NAVAssertIntegerEqual('Should have expected number of lines', expectedLines, actualLines)) {
            NAVLogTestFailed(x, "itoa(expectedLines)", "itoa(actualLines)")
            continue
        }

        NAVLogTestPassed(x)
    }
}
