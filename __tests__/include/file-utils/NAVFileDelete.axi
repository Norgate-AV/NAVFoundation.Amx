PROGRAM_NAME='NAVFileDelete'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileDelete
constant char FILE_DELETE_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/testfiledelete/file1.txt',       // Test 2: Delete existing file
    '/testfiledelete/file2.txt',       // Test 3: Delete another existing file
    '/testfiledelete/nonexistent.txt', // Test 4: Delete non-existent file
    '/testfiledelete/special!@#.txt',  // Test 5: Delete file with special characters
    '/testfiledelete/with spaces.txt', // Test 6: Delete file with spaces in name
    '/testfiledelete/noext',           // Test 7: Delete file without extension
    '/testfiledelete/nested/file.txt', // Test 8: Delete file in nested directory
    '/testdir',                        // Test 9: Try to delete directory (should fail)
    '/testfiledelete',                 // Test 10: Try to delete directory (should fail)
    '/',                               // Test 11: Try to delete root (should fail)
    'relative.txt',                    // Test 12: Relative path
    '/nonexistent/path/file.txt'       // Test 13: File in non-existent directory
}

constant slong FILE_DELETE_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty path - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success - file deleted
    0,      // Test 3: Success - file deleted
    -13,    // Test 4: File path not loaded (doesn't exist)
    0,      // Test 5: Success - deleted
    0,      // Test 6: Success - deleted
    0,      // Test 7: Success - deleted
    0,      // Test 8: Success - deleted
    -5,     // Test 9: Disk I/O error (can't delete directory as file)
    -5,     // Test 10: Disk I/O error (can't delete directory as file)
    -5,     // Test 11: Disk I/O error (can't delete root)
    0,      // Test 12: Success - deleted (check >= 0)
    -13     // Test 13: File path not loaded (parent doesn't exist)
}

constant char FILE_DELETE_NEEDS_CREATION[] = {
    false,  // Test 1: No creation needed (error case)
    true,   // Test 2: Create file first
    true,   // Test 3: Create file first
    false,  // Test 4: Don't create (testing non-existent)
    true,   // Test 5: Create file first
    true,   // Test 6: Create file first
    true,   // Test 7: Create file first
    true,   // Test 8: Create file and directory first
    false,  // Test 9: Directory exists (testdir)
    false,  // Test 10: Directory exists (testfiledelete)
    false,  // Test 11: Root always exists
    true,   // Test 12: Create file first
    false   // Test 13: Parent doesn't exist
}

constant char FILE_DELETE_VERIFY_DELETED[] = {
    false,  // Test 1: No verification (error case)
    true,   // Test 2: Should not exist after deletion
    true,   // Test 3: Should not exist after deletion
    false,  // Test 4: Already doesn't exist
    true,   // Test 5: Should not exist after deletion
    true,   // Test 6: Should not exist after deletion
    true,   // Test 7: Should not exist after deletion
    true,   // Test 8: Should not exist after deletion
    false,  // Test 9: Directory still exists (deletion failed)
    false,  // Test 10: Directory still exists (deletion failed)
    false,  // Test 11: Root still exists
    true,   // Test 12: Should not exist after deletion
    false   // Test 13: Doesn't exist
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_DELETE_SETUP_REQUIRED = false

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 */
define_function InitializeFileDeleteTestData() {
    // Future: Setup here if needed
    FILE_DELETE_SETUP_REQUIRED = true
}

/**
 * Setup test files
 */
define_function SetupFileDeleteTest(integer testNum, char path[]) {
    stack_var slong result
    stack_var char dirPath[255]

    if (!FILE_DELETE_NEEDS_CREATION[testNum]) {
        return
    }

    // Special case: Test 8 needs nested directory
    if (testNum == 8) {
        dirPath = NAVPathDirName(path)
        result = NAVDirectoryCreate(dirPath)
        if (result < 0) {
            NAVLog("'WARNING: Failed to create test directory: ', dirPath, ' (', itoa(result), ')'")
            return
        }
    }

    // Create the file
    result = NAVFileWrite(path, 'test content for deletion')

    if (result < 0) {
        NAVLog("'WARNING: Failed to create test file: ', path, ' (', itoa(result), ')'")
    }
}

define_function TestNAVFileDelete() {
    stack_var integer x
    stack_var slong result
    stack_var char testPath[255]

    NAVLog("'***************** NAVFileDelete *****************'")

    InitializeFileDeleteTestData()

    for (x = 1; x <= length_array(FILE_DELETE_TESTS); x++) {
        stack_var slong expected
        stack_var char shouldVerify
        stack_var char exists

        testPath = FILE_DELETE_TESTS[x]

        // Setup: Create file if needed for this test
        SetupFileDeleteTest(x, testPath)

        result = NAVFileDelete(testPath)
        expected = FILE_DELETE_EXPECTED_RESULT[x]
        shouldVerify = FILE_DELETE_VERIFY_DELETED[x]

        // For success cases, check result >= 0
        if (expected >= 0) {
            if (!NAVAssertTrue('Should delete file successfully', result >= 0)) {
                NAVLogTestFailed(x, 'success (>= 0)', "itoa(result)")
                continue
            }

            // Verify file no longer exists if we should check
            if (shouldVerify) {
                exists = NAVFileExists(testPath)
                if (!NAVAssertFalse('File should not exist after deletion', exists)) {
                    NAVLogTestFailed(x, 'file deleted', 'file still exists')
                    continue
                }
            }
        }
        else {
            // For error cases, check specific error code or just < 0
            // Some error codes may vary by system
            if (expected == -2 || expected == -13) {
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
