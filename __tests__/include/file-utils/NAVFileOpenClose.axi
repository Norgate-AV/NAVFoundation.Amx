PROGRAM_NAME='NAVFileOpenClose'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileOpen and NAVFileClose
constant char FILE_OPEN_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/user/config.txt',                // Test 2: Open existing file for reading
    '/user/data.xml',                  // Test 3: Open existing file for reading
    '/nonexistent-open.txt',           // Test 4: Open non-existent file for reading (should fail)
    '/testopenclose/new-rw.txt',       // Test 5: Open new file for read-write
    '/testopenclose/new-rwa.txt',      // Test 6: Open new file for read-write-append
    '/testopenclose/exists-rw.txt',    // Test 7: Open existing file for read-write
    '/testopenclose/exists-rwa.txt',   // Test 8: Open existing file for read-write-append
    '/user/config.txt',                // Test 9: Open for read-only (default)
    '/user',                           // Test 10: Try to open directory (should fail)
    '/',                               // Test 11: Try to open root (should fail)
    'relative-open.txt'                // Test 12: Relative path
}

constant char FILE_OPEN_MODES[][3] = {
    'r',                               // Test 1: Read mode (won't matter, error case)
    'r',                               // Test 2: Read-only
    'r',                               // Test 3: Read-only
    'r',                               // Test 4: Read-only (file doesn't exist)
    'rw',                              // Test 5: Read-write (creates new)
    'rwa',                             // Test 6: Read-write-append (creates new)
    'rw',                              // Test 7: Read-write (exists)
    'rwa',                             // Test 8: Read-write-append (exists)
    '',                                // Test 9: Empty mode (defaults to read-only)
    'r',                               // Test 10: Read-only
    'r',                               // Test 11: Read-only
    'r'                                // Test 12: Read-only
}

constant slong FILE_OPEN_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty path - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success - handle >= 0
    0,      // Test 3: Success - handle >= 0
    -2,     // Test 4: Invalid file path (doesn't exist)
    0,      // Test 5: Success - handle >= 0 (creates file)
    0,      // Test 6: Success - handle >= 0 (creates file)
    0,      // Test 7: Success - handle >= 0
    0,      // Test 8: Success - handle >= 0
    0,      // Test 9: Success - handle >= 0
    -2,     // Test 10: Invalid file path (directory)
    -2,     // Test 11: Invalid file path (root)
    0       // Test 12: Success - handle >= 0
}

constant char FILE_OPEN_NEEDS_CREATION[] = {
    false,  // Test 1: No creation needed (error case)
    false,  // Test 2: Existing file
    false,  // Test 3: Existing file
    false,  // Test 4: Non-existent (testing error)
    false,  // Test 5: Will be created by open
    false,  // Test 6: Will be created by open
    true,   // Test 7: Create first for read-write test
    true,   // Test 8: Create first for read-write-append test
    false,  // Test 9: Existing file
    false,  // Test 10: Directory exists
    false,  // Test 11: Root exists
    true    // Test 12: Create file for relative path test
}

constant char FILE_OPEN_TEST_CLOSE[] = {
    false,  // Test 1: Don't close (open failed)
    true,   // Test 2: Close after open
    true,   // Test 3: Close after open
    false,  // Test 4: Don't close (open failed)
    true,   // Test 5: Close after open
    true,   // Test 6: Close after open
    true,   // Test 7: Close after open
    true,   // Test 8: Close after open
    true,   // Test 9: Close after open
    false,  // Test 10: Don't close (open failed)
    false,  // Test 11: Don't close (open failed)
    true    // Test 12: Close after open
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_OPEN_CLOSE_SETUP_REQUIRED = false

/**
 * Initialize global test data arrays at runtime
 */
define_function InitializeFileOpenCloseTestData() {
    FILE_OPEN_CLOSE_SETUP_REQUIRED = true
}

/**
 * Setup test files
 */
define_function SetupFileOpenCloseTest(integer testNum, char path[]) {
    stack_var slong result
    stack_var char dirPath[255]

    if (!FILE_OPEN_NEEDS_CREATION[testNum]) {
        return
    }

    // Ensure parent directory exists
    dirPath = NAVPathDirName(path)
    if (!NAVDirectoryExists(dirPath)) {
        result = NAVDirectoryCreate(dirPath)
        if (result < 0) {
            NAVLog("'WARNING: Failed to create test directory: ', dirPath")
            return
        }
    }

    // Create the file
    result = NAVFileWrite(path, "'test content for open/close - test ', itoa(testNum)")

    if (result < 0) {
        NAVLog("'WARNING: Failed to create test file: ', path, ' (', itoa(result), ')'")
    }
}

define_function TestNAVFileOpenClose() {
    stack_var integer x
    stack_var slong openResult
    stack_var slong closeResult
    stack_var char testPath[255]
    stack_var char testMode[3]

    NAVLog("'***************** NAVFileOpen & NAVFileClose *****************'")

    InitializeFileOpenCloseTestData()

    for (x = 1; x <= length_array(FILE_OPEN_TESTS); x++) {
        stack_var slong expected
        stack_var char shouldClose
        stack_var long fileHandle

        testPath = FILE_OPEN_TESTS[x]
        testMode = FILE_OPEN_MODES[x]

        // Setup: Create file if needed for this test
        SetupFileOpenCloseTest(x, testPath)

        openResult = NAVFileOpen(testPath, testMode)
        expected = FILE_OPEN_EXPECTED_RESULT[x]
        shouldClose = FILE_OPEN_TEST_CLOSE[x]

        // For success cases
        if (expected >= 0) {
            if (!NAVAssertTrue('Should open file successfully', openResult >= 0)) {
                NAVLogTestFailed(x, 'handle >= 0', "itoa(openResult)")
                continue
            }

            fileHandle = type_cast(openResult)

            // Test close if we should
            if (shouldClose) {
                closeResult = NAVFileClose(fileHandle)

                if (!NAVAssertTrue('Should close file successfully', closeResult >= 0)) {
                    NAVLogTestFailed(x, 'close success (>= 0)', "itoa(closeResult)")
                    continue
                }
            }
        }
        else {
            if (!NAVAssertSignedLongEqual('Should return error code', expected, openResult)) {
                NAVLogTestFailed(x, "itoa(expected)", "itoa(openResult)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    // Additional test: Try to close invalid handle
    NAVLog("'Testing close with invalid handle...'")
    {
        closeResult = NAVFileClose(0)
        if (closeResult < 0) {
            NAVLog("'  ✓ Close invalid handle returned error as expected'")
        }
        else {
            NAVLog("'  ✗ Close invalid handle should return error'")
        }
    }
}
