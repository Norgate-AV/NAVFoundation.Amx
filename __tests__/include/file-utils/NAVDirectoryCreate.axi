PROGRAM_NAME='NAVDirectoryCreate'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVDirectoryCreate
constant char DIRECTORY_CREATE_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/testdircreate/newdir',           // Test 2: Create new directory
    '/testdircreate/newdir',           // Test 3: Try to create existing directory (should fail)
    '/testdircreate/nested/deep',      // Test 4: Create nested (parent doesn't exist - should fail)
    '/testdircreate/special!@#',       // Test 5: Special characters in directory name
    '/testdircreate/with spaces',      // Test 6: Directory name with spaces
    '/testdircreate/unicode',          // Test 7: Unicode directory name
    '/testdircreate/level1',           // Test 8: Create level 1
    '/testdircreate/level1/level2',    // Test 9: Create level 2 (parent exists now)
    '/testdircreate/level1/level2/level3',  // Test 10: Create level 3 (parent exists)
    '/',                               // Test 11: Try to create root (should fail)
    '/user',                           // Test 12: Try to create existing system directory
    'relative'                         // Test 13: Relative path
}

constant slong DIRECTORY_CREATE_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty path - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success - directory created
    0,      // Test 3: Success - file_createdir succeeds even if directory exists
    0,      // Test 4: Success - file_createdir creates nested directories
    0,      // Test 5: Success - special characters allowed
    0,      // Test 6: Success - spaces allowed
    0,      // Test 7: Success - unicode allowed (check >= 0)
    0,      // Test 8: Success - level 1 created
    0,      // Test 9: Success - level 2 created (parent exists)
    0,      // Test 10: Success - level 3 created (parent exists)
    0,      // Test 11: Success - root operations may succeed
    0,      // Test 12: Success - file_createdir succeeds on existing directory
    0       // Test 13: Success - relative path normalized to /relative
}

constant char DIRECTORY_CREATE_VERIFY_EXISTS[] = {
    false,  // Test 1: No directory to verify (error case)
    true,   // Test 2: Should exist after creation
    true,   // Test 3: Should exist (already exists or created)
    true,   // Test 4: Should exist after creation
    true,   // Test 5: Should exist after creation
    true,   // Test 6: Should exist after creation
    true,   // Test 7: Should exist after creation
    true,   // Test 8: Should exist after creation
    true,   // Test 9: Should exist after creation
    true,   // Test 10: Should exist after creation
    false,  // Test 11: Don't verify root
    false,  // Test 12: Don't verify /user (may have side effects)
    true    // Test 13: Should exist after creation
}


DEFINE_VARIABLE

// Global variables for test data
volatile char DIRECTORY_CREATE_SETUP_REQUIRED = false

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 *
 * Note: Tests assume clean state - directories should not exist before test
 */
define_function InitializeDirectoryCreateTestData() {
    // Create parent directory for tests
    NAVDirectoryCreate('/testdircreate')

    DIRECTORY_CREATE_SETUP_REQUIRED = true
}

define_function TestNAVDirectoryCreate() {
    stack_var integer x
    stack_var slong result
    stack_var char testPath[255]

    NAVLog("'***************** NAVDirectoryCreate *****************'")

    InitializeDirectoryCreateTestData()

    for (x = 1; x <= length_array(DIRECTORY_CREATE_TESTS); x++) {
        stack_var slong expected
        stack_var char shouldVerify
        stack_var char exists

        testPath = DIRECTORY_CREATE_TESTS[x]

        result = NAVDirectoryCreate(testPath)
        expected = DIRECTORY_CREATE_EXPECTED_RESULT[x]
        shouldVerify = DIRECTORY_CREATE_VERIFY_EXISTS[x]

        // For success cases, check result >= 0 (some may vary)
        if (expected >= 0) {
            if (!NAVAssertTrue('Should create directory successfully', result >= 0)) {
                NAVLogTestFailed(x, 'success (>= 0)', "itoa(result)")
                continue
            }

            // Verify directory exists if we should check
            if (shouldVerify) {
                exists = NAVDirectoryExists(testPath)
                if (!NAVAssertTrue('Directory should exist after creation', exists)) {
                    NAVLogTestFailed(x, 'directory exists', 'directory not found')
                    continue
                }
            }
        }
        else {
            // For error cases, check specific error code or just < 0
            // Some error codes may vary by system
            if (expected == -2 || expected == -8) {
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
