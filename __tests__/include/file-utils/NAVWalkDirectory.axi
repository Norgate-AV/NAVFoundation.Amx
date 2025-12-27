PROGRAM_NAME='NAVWalkDirectory'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVWalkDirectory
constant char WALK_DIRECTORY_TESTS[][255] = {
    '',                                 // Test 1: Empty path (becomes '/')
    '/',                               // Test 2: Root directory
    '/user',                           // Test 3: /user directory (recursive)
    '/user/logs',                      // Test 4: /user/logs directory (single file)
    '/testdir',                        // Test 5: /testdir directory (recursive)
    '/testdir/nested',                 // Test 6: /testdir/nested (single file)
    '/empty',                          // Test 7: Empty directory
    '/nonexistent',                    // Test 8: Non-existent directory
    '/user/config.txt',                // Test 9: File path (not a directory)
    'user',                            // Test 10: Relative path 'user'
    '/user/fake'                       // Test 11: Non-existent nested directory
}


constant slong WALK_DIRECTORY_EXPECTED_COUNT[] = {
    0,      // Test 1: Empty path becomes '/', varies by system (check >= 0)
    0,      // Test 2: Root (varies, check >= 0)
    4,      // Test 3: /user has 4 files total (config.txt, data.xml, noextension, logs/error.log)
    1,      // Test 4: /user/logs has 1 file (error.log)
    3,      // Test 5: /testdir has 3 files total (test.txt, file with spaces.txt, nested/deep.txt)
    1,      // Test 6: /testdir/nested has 1 file (deep.txt)
    0,      // Test 7: /empty has 0 files
    0,      // Test 8: Non-existent directory returns 0
    -5,     // Test 9: File path (Disk I/O error)
    4,      // Test 10: Relative 'user' → '/user' (4 files)
    0       // Test 11: Non-existent nested returns 0
}


DEFINE_VARIABLE

// Global variables for test data
volatile char WALK_DIRECTORY_SETUP_REQUIRED = false

// Expected file paths for each test case
volatile char WALK_DIRECTORY_EXPECTED_FILES[11][10][NAV_MAX_BUFFER]  // 11 tests, max 10 files each
volatile integer WALK_DIRECTORY_EXPECTED_FILE_COUNT[11]

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 *
 * Note: Update expected results based on actual directory structure
 * Expected structure based on TEST_FILESYSTEM_SETUP.md
 */
define_function InitializeWalkDirectoryTestData() {
    // Test 3: /user directory - 4 files recursively
    WALK_DIRECTORY_EXPECTED_FILE_COUNT[3] = 4
    WALK_DIRECTORY_EXPECTED_FILES[3][1] = '/user/config.txt'
    WALK_DIRECTORY_EXPECTED_FILES[3][2] = '/user/data.xml'
    WALK_DIRECTORY_EXPECTED_FILES[3][3] = '/user/noextension'
    WALK_DIRECTORY_EXPECTED_FILES[3][4] = '/user/logs/error.log'

    // Test 4: /user/logs directory - 1 file
    WALK_DIRECTORY_EXPECTED_FILE_COUNT[4] = 1
    WALK_DIRECTORY_EXPECTED_FILES[4][1] = '/user/logs/error.log'

    // Test 5: /testdir directory - 3 files recursively
    WALK_DIRECTORY_EXPECTED_FILE_COUNT[5] = 3
    WALK_DIRECTORY_EXPECTED_FILES[5][1] = '/testdir/test.txt'
    WALK_DIRECTORY_EXPECTED_FILES[5][2] = '/testdir/file with spaces.txt'
    WALK_DIRECTORY_EXPECTED_FILES[5][3] = '/testdir/nested/deep.txt'

    // Test 6: /testdir/nested directory - 1 file
    WALK_DIRECTORY_EXPECTED_FILE_COUNT[6] = 1
    WALK_DIRECTORY_EXPECTED_FILES[6][1] = '/testdir/nested/deep.txt'

    // Test 10: 'user' relative (same as test 3)
    WALK_DIRECTORY_EXPECTED_FILE_COUNT[10] = 4
    WALK_DIRECTORY_EXPECTED_FILES[10][1] = '/user/config.txt'
    WALK_DIRECTORY_EXPECTED_FILES[10][2] = '/user/data.xml'
    WALK_DIRECTORY_EXPECTED_FILES[10][3] = '/user/noextension'
    WALK_DIRECTORY_EXPECTED_FILES[10][4] = '/user/logs/error.log'

    WALK_DIRECTORY_SETUP_REQUIRED = true
}

define_function TestNAVWalkDirectory() {
    stack_var integer x
    stack_var integer i
    stack_var integer j
    stack_var char files[1000][NAV_MAX_BUFFER]
    stack_var slong result

    NAVLog("'***************** NAVWalkDirectory *****************'")

    InitializeWalkDirectoryTestData()

    for (x = 1; x <= length_array(WALK_DIRECTORY_TESTS); x++) {
        stack_var slong expectedCount
        stack_var char testPath[255]
        stack_var char found

        // Clear the files array before each test
        set_length_array(files, 0)

        testPath = WALK_DIRECTORY_TESTS[x]
        result = NAVWalkDirectory(testPath, files)
        expectedCount = WALK_DIRECTORY_EXPECTED_COUNT[x]

        // Special cases: empty path and root directory count varies, just check success
        if (x == 1 || x == 2) {
            if (!NAVAssertTrue('Should return non-negative result', result >= 0)) {
                NAVLogTestFailed(x, "'success (>= 0)'", itoa(result))
                continue
            }

            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertSignedLongEqual('Should return the correct file count', expectedCount, result)) {
            // Log all returned files for debugging when count doesn't match
            NAVLog("'  Returned files:'")
            for (i = 1; i <= type_cast(result); i++) {
                NAVLog("'    [', itoa(i), ']: ', files[i]")
            }
            NAVLogTestFailed(x, itoa(expectedCount), itoa(result))
            continue
        }

        // Verify file paths for tests that have expected files defined
        if (WALK_DIRECTORY_EXPECTED_FILE_COUNT[x] > 0) {
            for (i = 1; i <= WALK_DIRECTORY_EXPECTED_FILE_COUNT[x]; i++) {
                found = false

                // Search for this expected file in the actual results
                for (j = 1; j <= type_cast(result); j++) {
                    if (files[j] == WALK_DIRECTORY_EXPECTED_FILES[x][i]) {
                        found = true
                        break
                    }
                }

                if (!found) {
                    NAVLog("'  Missing expected file: ', WALK_DIRECTORY_EXPECTED_FILES[x][i]")
                }

                if (!NAVAssertTrue("'Should contain ', WALK_DIRECTORY_EXPECTED_FILES[x][i]", found)) {
                    NAVLogTestFailed(x, "'file found'", "'file missing'")
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
