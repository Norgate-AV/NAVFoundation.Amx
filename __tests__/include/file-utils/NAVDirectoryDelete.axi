PROGRAM_NAME='NAVDirectoryDelete'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVDirectoryDelete
constant char DIRECTORY_DELETE_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/testdirdelete/empty',            // Test 2: Delete empty directory
    '/testdirdelete/nonempty',         // Test 3: Delete non-empty directory (should fail)
    '/testdirdelete/nonexistent',      // Test 4: Delete non-existent directory
    '/testdirdelete/created',          // Test 5: Create then delete
    '/testdirdelete/special!@#',       // Test 6: Delete directory with special characters
    '/testdirdelete/with spaces',      // Test 7: Delete directory with spaces
    '/',                               // Test 8: Try to delete root (should fail)
    '/user',                           // Test 9: Try to delete system directory (should fail)
    '/testdirdelete/nested',           // Test 10: Delete empty nested directory
    'relative'                         // Test 11: Relative path
}

constant slong DIRECTORY_DELETE_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty path - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success - empty directory deleted
    -5,     // Test 3: Disk I/O error (directory not empty)
    -4,     // Test 4: Invalid file path (doesn't exist)
    0,      // Test 5: Success - directory deleted
    0,      // Test 6: Success - deleted
    0,      // Test 7: Success - deleted
    -5,     // Test 8: Disk I/O error (can't delete root)
    -5,     // Test 9: Disk I/O error (directory not empty or system protected)
    0,      // Test 10: Success - deleted
    0       // Test 11: Success - deleted (check >= 0)
}

constant char DIRECTORY_DELETE_NEEDS_CREATION[] = {
    false,  // Test 1: No creation needed (error case)
    true,   // Test 2: Create empty directory first
    true,   // Test 3: Create and populate directory first
    false,  // Test 4: Don't create (testing non-existent)
    true,   // Test 5: Create first, then delete
    true,   // Test 6: Create first
    true,   // Test 7: Create first
    false,  // Test 8: Root always exists
    false,  // Test 9: System directory exists
    true,   // Test 10: Create first
    true    // Test 11: Create first
}

constant char DIRECTORY_DELETE_VERIFY_DELETED[] = {
    false,  // Test 1: No verification (error case)
    true,   // Test 2: Should not exist after deletion
    false,  // Test 3: Should still exist (deletion failed)
    false,  // Test 4: Already doesn't exist
    true,   // Test 5: Should not exist after deletion
    true,   // Test 6: Should not exist after deletion
    true,   // Test 7: Should not exist after deletion
    false,  // Test 8: Root still exists
    false,  // Test 9: System directory still exists
    true,   // Test 10: Should not exist after deletion
    true    // Test 11: Should not exist after deletion
}


DEFINE_VARIABLE

// Global variables for test data
volatile char DIRECTORY_DELETE_SETUP_REQUIRED = false

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 */
define_function InitializeDirectoryDeleteTestData() {
    // Create parent directory for tests
    NAVDirectoryCreate('/testdirdelete')

    DIRECTORY_DELETE_SETUP_REQUIRED = true
}

/**
 * Setup test directories and files
 */
define_function SetupDirectoryDeleteTest(integer testNum, char path[]) {
    stack_var slong result

    if (!DIRECTORY_DELETE_NEEDS_CREATION[testNum]) {
        return
    }

    // Create the directory
    result = NAVDirectoryCreate(path)

    if (result < 0) {
        NAVLog("'WARNING: Failed to create test directory: ', path, ' (', itoa(result), ')'")
        return
    }

    // Special case: Test 3 needs a non-empty directory
    if (testNum == 3) {
        // Create a file inside to make it non-empty
        result = NAVFileWrite("path, '/file.txt'", 'test content')
        if (result < 0) {
            NAVLog("'WARNING: Failed to create file in test directory: ', path")
        }
    }
}

define_function TestNAVDirectoryDelete() {
    stack_var integer x
    stack_var slong result
    stack_var char testPath[255]

    NAVLog("'***************** NAVDirectoryDelete *****************'")

    InitializeDirectoryDeleteTestData()

    for (x = 1; x <= length_array(DIRECTORY_DELETE_TESTS); x++) {
        stack_var slong expected
        stack_var char shouldVerify
        stack_var char exists

        testPath = DIRECTORY_DELETE_TESTS[x]

        // Setup: Create directory if needed for this test
        SetupDirectoryDeleteTest(x, testPath)

        result = NAVDirectoryDelete(testPath)
        expected = DIRECTORY_DELETE_EXPECTED_RESULT[x]
        shouldVerify = DIRECTORY_DELETE_VERIFY_DELETED[x]

        // For success cases, check result >= 0
        if (expected >= 0) {
            if (!NAVAssertTrue('Should delete directory successfully', result >= 0)) {
                NAVLogTestFailed(x, 'success (>= 0)', "itoa(result)")
                continue
            }

            // Verify directory no longer exists if we should check
            if (shouldVerify) {
                exists = NAVDirectoryExists(testPath)
                if (!NAVAssertFalse('Directory should not exist after deletion', exists)) {
                    NAVLogTestFailed(x, 'directory deleted', 'directory still exists')
                    continue
                }
            }
        }
        else {
            // For error cases, check specific error code or just < 0
            // Some error codes may vary by system
            if (expected == -2 || expected == -4) {
                if (!NAVAssertSignedLongEqual('Should return expected error code', expected, result)) {
                    NAVLogTestFailed(x, "itoa(expected)", "itoa(result)")
                    continue
                }
            }
            else {
                if (!NAVAssertTrue('Should return error code', result < 0)) {
                    NAVLogTestFailed(x, 'error (< 0)', "itoa(result)")
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
