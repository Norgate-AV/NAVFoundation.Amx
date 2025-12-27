PROGRAM_NAME='NAVFileExists'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileExists
constant char FILE_EXISTS_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/user/config.txt',                // Test 2: Existing file (created)
    '/user/data.xml',                  // Test 3: Existing XML file (created)
    '/user/noextension',               // Test 4: Existing file without extension (created)
    '/user/logs/error.log',            // Test 5: Existing nested file (created)
    '/testdir/test.txt',               // Test 6: File in testdir (created)
    '/testdir/file with spaces.txt',   // Test 7: File with spaces in name (created)
    '/testdir/nested/deep.txt',        // Test 8: Deeply nested file (created)
    '/user/nonexistent.txt',           // Test 9: Non-existent file
    'config.txt',                      // Test 10: Relative path (not in root)
    '/user/',                          // Test 11: Directory path (not a file)
    '/user',                           // Test 12: Directory without trailing slash (not a file)
    '/',                               // Test 13: Root directory (not a file)
    '/nonexistent/file.txt',           // Test 14: File in non-existent directory
    '/user/.hidden'                    // Test 15: Hidden file (doesn't exist)
}


constant char FILE_EXISTS_EXPECTED_RESULT[] = {
    false,  // Test 1: Empty path returns false
    true,   // Test 2: /user/config.txt EXISTS
    true,   // Test 3: /user/data.xml EXISTS
    true,   // Test 4: /user/noextension EXISTS
    true,   // Test 5: /user/logs/error.log EXISTS
    true,   // Test 6: /testdir/test.txt EXISTS
    true,   // Test 7: /testdir/file with spaces.txt EXISTS
    true,   // Test 8: /testdir/nested/deep.txt EXISTS
    false,  // Test 9: File doesn't exist
    false,  // Test 10: Relative path, file not in root
    false,  // Test 11: Directory path is not a file
    false,  // Test 12: Directory is not a file
    false,  // Test 13: Root is a directory, not a file
    false,  // Test 14: Parent directory doesn't exist
    false   // Test 15: Hidden file doesn't exist
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_EXISTS_SETUP_REQUIRED = false

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 *
 * Note: Update expected results based on actual test file setup
 * Create test files before running:
 *   - /user/config.txt
 *   - Other files as needed for positive test cases
 */
define_function InitializeFileExistsTestData() {
    // Future: Create test files here if needed
    FILE_EXISTS_SETUP_REQUIRED = true
}

define_function TestNAVFileExists() {
    stack_var integer x
    stack_var char result

    NAVLog("'***************** NAVFileExists *****************'")

    InitializeFileExistsTestData()

    for (x = 1; x <= length_array(FILE_EXISTS_TESTS); x++) {
        stack_var char expected
        stack_var char testPath[255]

        testPath = FILE_EXISTS_TESTS[x]
        result = NAVFileExists(testPath)
        expected = FILE_EXISTS_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual('Should return the correct boolean result', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
