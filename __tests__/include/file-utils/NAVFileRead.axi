PROGRAM_NAME='NAVFileRead'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileRead
constant char FILE_READ_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/user/config.txt',                // Test 2: Read existing file
    '/user/data.xml',                  // Test 3: Read existing XML file
    '/user/noextension',               // Test 4: Read file without extension
    '/nonexistent.txt',                // Test 5: Non-existent file
    '/user/logs/error.log',            // Test 6: Read nested file
    '/testdir/test.txt',               // Test 7: Read file from testdir
    '/testdir/file with spaces.txt',   // Test 8: Read file with spaces in name
    '/testdir/nested/deep.txt',        // Test 9: Read deeply nested file
    '/user',                           // Test 10: Try to read directory (should fail)
    '/',                               // Test 11: Try to read root (should fail)
    '/nonexistent/path/file.txt'       // Test 12: Non-existent directory path
}

constant slong FILE_READ_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty path - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success - bytes read (check >= 0)
    0,      // Test 3: Success - bytes read (check >= 0)
    0,      // Test 4: Success - bytes read (check >= 0)
    -2,     // Test 5: Non-existent file
    0,      // Test 6: Success - bytes read (check >= 0)
    0,      // Test 7: Success - bytes read (check >= 0)
    0,      // Test 8: Success - bytes read (check >= 0)
    0,      // Test 9: Success - bytes read (check >= 0)
    -5,     // Test 10: Directory is not a file (Disk I/O error)
    -5,     // Test 11: Root is not a file (Disk I/O error)
    -2      // Test 12: Non-existent path
}

constant char FILE_READ_EXPECTED_CONTENT_CHECK[] = {
    false,  // Test 1: No content check (error case)
    true,   // Test 2: Check content is not empty
    true,   // Test 3: Check content is not empty
    true,   // Test 4: Check content is not empty
    false,  // Test 5: No content check (error case)
    true,   // Test 6: Check content is not empty
    true,   // Test 7: Check content is not empty
    true,   // Test 8: Check content is not empty
    true,   // Test 9: Check content is not empty
    false,  // Test 10: No content check (error case)
    false,  // Test 11: No content check (error case)
    false   // Test 12: No content check (error case)
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_READ_SETUP_REQUIRED = false

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 *
 * Note: Update expected results based on actual test files
 * Expected files should exist:
 *   - /user/config.txt
 *   - /user/data.xml
 *   - /user/noextension
 *   - /user/logs/error.log
 *   - /testdir/test.txt
 *   - /testdir/file with spaces.txt
 *   - /testdir/nested/deep.txt
 */
define_function InitializeFileReadTestData() {
    // Create directories
    NAVDirectoryCreate('/user')
    NAVDirectoryCreate('/user/logs')
    NAVDirectoryCreate('/testdir')
    NAVDirectoryCreate('/testdir/nested')

    // Create test files with content
    NAVFileWrite('/user/config.txt', 'Config data here')
    NAVFileWrite('/user/data.xml', '<?xml version="1.0"?><data>Test</data>')
    NAVFileWrite('/user/noextension', 'File without extension')
    NAVFileWrite('/user/logs/error.log', 'Error log entry 1')
    NAVFileWrite('/testdir/test.txt', 'Simple test file')
    NAVFileWrite('/testdir/file with spaces.txt', 'File with spaces in name')
    NAVFileWrite('/testdir/nested/deep.txt', 'Deeply nested file')

    FILE_READ_SETUP_REQUIRED = true
}

define_function TestNAVFileRead() {
    stack_var integer x
    stack_var slong result
    stack_var char testPath[255]
    stack_var char fileContent[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVFileRead *****************'")

    InitializeFileReadTestData()

    for (x = 1; x <= length_array(FILE_READ_TESTS); x++) {
        stack_var slong expected
        stack_var char shouldCheckContent

        testPath = FILE_READ_TESTS[x]
        fileContent = ''  // Clear buffer before each test

        result = NAVFileRead(testPath, fileContent)
        expected = FILE_READ_EXPECTED_RESULT[x]
        shouldCheckContent = FILE_READ_EXPECTED_CONTENT_CHECK[x]

        // For successful reads, check result >= 0
        if (expected >= 0) {
            if (!NAVAssertTrue('Should read file successfully', result >= 0)) {
                NAVLogTestFailed(x, 'success (>= 0)', "itoa(result)")
                continue
            }

            // Check that content was actually read
            if (shouldCheckContent) {
                if (!NAVAssertTrue('Should read non-empty content', length_array(fileContent) > 0)) {
                    NAVLogTestFailed(x, 'non-empty content', 'empty buffer')
                    continue
                }
            }
        }
        else {
            if (!NAVAssertSignedLongEqual('Should return error code', expected, result)) {
                NAVLogTestFailed(x, "itoa(expected)", "itoa(result)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
