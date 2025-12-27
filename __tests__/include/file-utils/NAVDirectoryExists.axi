PROGRAM_NAME='NAVDirectoryExists'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVDirectoryExists
constant char DIRECTORY_EXISTS_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/',                               // Test 2: Root directory
    '/user',                           // Test 3: Existing directory (created)
    '/user/logs',                      // Test 4: Nested existing directory (created)
    '/testdir',                        // Test 5: Test directory (created)
    '/testdir/nested',                 // Test 6: Nested test directory (created)
    '/empty',                          // Test 7: Empty directory (created)
    '/datafeed',                       // Test 8: Existing datafeed directory
    '/nonexistent',                    // Test 9: Non-existent directory
    '/user/fake/nested',               // Test 10: Non-existent nested directory
    'relative',                        // Test 11: Relative path (doesn't exist)
    '/user/',                          // Test 12: Directory with trailing slash
    'user',                            // Test 13: Relative 'user' → '/user' (exists)
    'testdir',                         // Test 14: Relative 'testdir' → '/testdir' (exists)
    '/user/config.txt',                // Test 15: File path (not a directory)
    '/nonexistent/nested'              // Test 16: Nested path in non-existent dir
}


constant char DIRECTORY_EXISTS_EXPECTED_RESULT[] = {
    false,  // Test 1: Empty path returns false
    true,   // Test 2: Root always exists
    true,   // Test 3: /user EXISTS
    true,   // Test 4: /user/logs EXISTS
    true,   // Test 5: /testdir EXISTS
    true,   // Test 6: /testdir/nested EXISTS
    true,   // Test 7: /empty EXISTS
    true,   // Test 8: /datafeed EXISTS (already present)
    false,  // Test 9: Directory doesn't exist
    false,  // Test 10: Nested directory doesn't exist
    false,  // Test 11: Relative path doesn't exist in root
    true,   // Test 12: Trailing slash, same as /user (EXISTS)
    true,   // Test 13: Relative 'user' normalized to '/user' (EXISTS)
    true,   // Test 14: Relative 'testdir' normalized to '/testdir' (EXISTS)
    false,  // Test 15: File path is not a directory
    false   // Test 16: Parent directory doesn't exist
}


DEFINE_VARIABLE

// Global variables for test data
volatile char DIRECTORY_EXISTS_SETUP_REQUIRED = false

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 *
 * Note: Update expected results based on actual directory structure
 * Expected directories:
 *   - / (root)
 *   - /user (if it exists on the system)
 */
define_function InitializeDirectoryExistsTestData() {
    // Future: Create test directories here if needed
    DIRECTORY_EXISTS_SETUP_REQUIRED = true
}

define_function TestNAVDirectoryExists() {
    stack_var integer x
    stack_var char result

    NAVLog("'***************** NAVDirectoryExists *****************'")

    InitializeDirectoryExistsTestData()

    for (x = 1; x <= length_array(DIRECTORY_EXISTS_TESTS); x++) {
        stack_var char expected
        stack_var char testPath[255]

        testPath = DIRECTORY_EXISTS_TESTS[x]
        result = NAVDirectoryExists(testPath)
        expected = DIRECTORY_EXISTS_EXPECTED_RESULT[x]

        if (!NAVAssertBooleanEqual('Should return the correct boolean result', expected, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(expected), NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
