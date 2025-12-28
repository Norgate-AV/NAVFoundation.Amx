PROGRAM_NAME='NAVFileGetSize'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileGetSize
constant char FILE_GET_SIZE_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/user/config.txt',                // Test 2: Existing file
    '/user/data.xml',                  // Test 3: Existing XML file
    '/user/noextension',               // Test 4: File without extension
    '/user/logs/error.log',            // Test 5: Nested file
    '/testdir/test.txt',               // Test 6: File in testdir
    '/testdir/file with spaces.txt',   // Test 7: File with spaces in name
    '/testdir/nested/deep.txt',        // Test 8: Deeply nested file
    '/nonexistent.txt',                // Test 9: Non-existent file
    '/user',                           // Test 10: Directory path (should fail)
    '/',                               // Test 11: Root directory (should fail)
    '/testsize/empty.txt',             // Test 12: Empty file (0 bytes)
    '/testsize/small.txt',             // Test 13: Small file (known size)
    '/testsize/large.txt'              // Test 14: Larger file (known size)
}

constant slong FILE_GET_SIZE_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty path - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success - size >= 0
    0,      // Test 3: Success - size >= 0
    0,      // Test 4: Success - size >= 0
    0,      // Test 5: Success - size >= 0
    0,      // Test 6: Success - size >= 0
    0,      // Test 7: Success - size >= 0
    0,      // Test 8: Success - size >= 0
    -2,     // Test 9: Non-existent file
    $7FFFFFFF,  // Test 10: Directory returns MAX_LONG (2147483647)
    $7FFFFFFF,  // Test 11: Root returns MAX_LONG (2147483647)
    0,      // Test 12: Empty file - 0 bytes
    10,     // Test 13: Small file - 10 bytes ('small file')
    50      // Test 14: Larger file - 50 bytes
}

constant char FILE_GET_SIZE_NEEDS_CREATION[] = {
    false,  // Test 1: No creation needed (error case)
    false,  // Test 2: Existing file
    false,  // Test 3: Existing file
    false,  // Test 4: Existing file
    false,  // Test 5: Existing file
    false,  // Test 6: Existing file
    false,  // Test 7: Existing file
    false,  // Test 8: Existing file
    false,  // Test 9: Non-existent (testing error)
    false,  // Test 10: Directory exists
    false,  // Test 11: Root exists
    false,  // Test 12: Skip - can't create empty file (file_write rejects 0 bytes)
    true,   // Test 13: Create small file
    true    // Test 14: Create larger file
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_GET_SIZE_SETUP_REQUIRED = false
volatile char FILE_GET_SIZE_TEST_CONTENT[14][NAV_MAX_BUFFER]

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 */
define_function InitializeFileGetSizeTestData() {
    // Test 12: Empty file (no content)
    FILE_GET_SIZE_TEST_CONTENT[12] = ''

    // Test 13: Small file (10 bytes)
    FILE_GET_SIZE_TEST_CONTENT[13] = 'small file'

    // Test 14: Larger file (50 bytes - exactly)
    FILE_GET_SIZE_TEST_CONTENT[14] = '12345678901234567890123456789012345678901234567890'

    FILE_GET_SIZE_SETUP_REQUIRED = true
}

/**
 * Setup test files
 */
define_function SetupFileGetSizeTest(integer testNum, char path[]) {
    stack_var slong result
    stack_var char dirPath[255]

    if (!FILE_GET_SIZE_NEEDS_CREATION[testNum]) {
        return
    }

    // Ensure parent directory exists
    dirPath = NAVPathDirName(path)
    if (!NAVDirectoryExists(dirPath)) {
        result = NAVDirectoryCreate(dirPath)
        if (result < 0) {
            NAVLog("'WARNING: Failed to create test directory: ', dirPath, ' (', itoa(result), ')'")
            return
        }
    }

    // Create the file with specific content
    result = NAVFileWrite(path, FILE_GET_SIZE_TEST_CONTENT[testNum])

    if (result < 0) {
        NAVLog("'WARNING: Failed to create test file: ', path, ' (', itoa(result), ')'")
    }
}

define_function TestNAVFileGetSize() {
    stack_var integer x
    stack_var slong result
    stack_var char testPath[255]

    NAVLog("'***************** NAVFileGetSize *****************'")

    InitializeFileGetSizeTestData()

    for (x = 1; x <= length_array(FILE_GET_SIZE_TESTS); x++) {
        stack_var slong expected

        testPath = FILE_GET_SIZE_TESTS[x]

        // Setup: Create file if needed for this test
        SetupFileGetSizeTest(x, testPath)

        result = NAVFileGetSize(testPath)
        expected = FILE_GET_SIZE_EXPECTED_RESULT[x]

        // For success cases with known size
        if (x == 12 || x == 13 || x == 14) {
            if (!NAVAssertSignedLongEqual('Should return exact file size', expected, result)) {
                NAVLogTestFailed(x, "itoa(expected)", "itoa(result)")
                continue
            }
        }
        // For success cases with variable size
        else if (expected >= 0) {
            if (!NAVAssertTrue('Should return file size successfully', result >= 0)) {
                NAVLogTestFailed(x, 'size >= 0', "itoa(result)")
                continue
            }
        }
        // For error cases
        else {
            if (!NAVAssertTrue('Should return error code', result < 0)) {
                NAVLogTestFailed(x, 'error (< 0)', "itoa(result)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
