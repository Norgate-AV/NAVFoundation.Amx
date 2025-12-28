PROGRAM_NAME='NAVFileRename'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileRename (source, destination)
constant char FILE_RENAME_SOURCE_TESTS[][255] = {
    '',                                 // Test 1: Empty source path
    '/testrename/old.txt',             // Test 2: Rename file
    '/testrename/move.txt',            // Test 3: Move file to different directory
    '/testrename/nonexistent.txt',     // Test 4: Rename non-existent file (should fail)
    '/testrename/special!@#.txt',      // Test 5: Rename file with special characters
    '/testrename/with spaces.txt',     // Test 6: Rename file with spaces
    '/testrename/noext',               // Test 7: Rename file without extension
    '/testrename/nested/file.txt',     // Test 8: Rename nested file
    '/testrename',                     // Test 9: Try to rename directory (should fail)
    '/testrename/exists.txt',          // Test 10: Rename to existing filename (should fail)
    '/testrename/change-ext.txt',      // Test 11: Change extension
    '/testrename/same.txt',            // Test 12: Rename to same name (should work)
    'relative.txt'                     // Test 13: Relative path
}

constant char FILE_RENAME_DEST_TESTS[][255] = {
    '',                                 // Test 1: Empty destination
    '/testrename/new.txt',             // Test 2: New name
    '/testrename/moved/move.txt',      // Test 3: Different directory
    '/testrename/newname.txt',         // Test 4: Destination for non-existent
    '/testrename/special-renamed.txt', // Test 5: Normal name
    '/testrename/no-spaces.txt',       // Test 6: Normal name
    '/testrename/with-ext.txt',        // Test 7: Add extension
    '/testrename/nested/renamed.txt',  // Test 8: New name in same directory
    '/testrename-new',                 // Test 9: Try to rename directory
    '/testrename/target.txt',          // Test 10: Existing target file
    '/testrename/change-ext.dat',      // Test 11: Different extension
    '/testrename/same.txt',            // Test 12: Same name
    '/renamed-relative.txt'            // Test 13: Relative destination
}

constant slong FILE_RENAME_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty source - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success - file renamed
    0,      // Test 3: Success - file moved
    -4,     // Test 4: Invalid file path (doesn't exist)
    0,      // Test 5: Success - renamed
    0,      // Test 6: Success - renamed
    0,      // Test 7: Success - renamed
    0,      // Test 8: Success - renamed
    -5,     // Test 9: Disk I/O error (can't rename directory as file)
    -8,     // Test 10: File name exists (target exists)
    0,      // Test 11: Success - extension changed
    -8,     // Test 12: File name exists (same source and dest returns -8)
    0       // Test 13: Success - relative path rename works
}

constant char FILE_RENAME_NEEDS_CREATION[] = {
    false,  // Test 1: No creation needed (error case)
    true,   // Test 2: Create source file
    true,   // Test 3: Create source file and destination directory
    false,  // Test 4: Don't create (testing non-existent)
    true,   // Test 5: Create source file
    true,   // Test 6: Create source file
    true,   // Test 7: Create source file
    true,   // Test 8: Create source file
    false,  // Test 9: Directory exists (testrename)
    true,   // Test 10: Create both source and target files
    true,   // Test 11: Create source file
    true,   // Test 12: Create source file
    true    // Test 13: Create source file
}

constant char FILE_RENAME_VERIFY_RESULT[] = {
    false,  // Test 1: No verification (error case)
    true,   // Test 2: Verify renamed
    true,   // Test 3: Verify moved
    false,  // Test 4: Nothing to verify (error case)
    true,   // Test 5: Verify renamed
    true,   // Test 6: Verify renamed
    true,   // Test 7: Verify renamed
    true,   // Test 8: Verify renamed
    false,  // Test 9: Nothing to verify (error case)
    false,  // Test 10: Nothing to verify (error case)
    true,   // Test 11: Verify renamed
    true,   // Test 12: Verify exists
    true    // Test 13: Verify renamed
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_RENAME_SETUP_REQUIRED = false

/**
 * Initialize global test data arrays at runtime
 */
define_function InitializeFileRenameTestData() {
    // Create parent directories for tests
    NAVDirectoryCreate('/testrename')
    NAVDirectoryCreate('/testrename/nested')
    NAVDirectoryCreate('/testrename/moved')

    FILE_RENAME_SETUP_REQUIRED = true
}

/**
 * Setup test files
 */
define_function SetupFileRenameTest(integer testNum, char sourcePath[], char destPath[]) {
    stack_var slong result
    stack_var char dirPath[255]

    if (!FILE_RENAME_NEEDS_CREATION[testNum]) {
        return
    }

    // Test 3: Create destination directory
    if (testNum == 3) {
        dirPath = NAVPathDirName(destPath)
        if (!NAVDirectoryExists(dirPath)) {
            result = NAVDirectoryCreate(dirPath)
            if (result < 0) {
                NAVLog("'WARNING: Failed to create destination directory: ', dirPath")
            }
        }
    }

    // Clean up any existing destination file from previous test runs
    // (except for test 10 which specifically tests destination exists)
    if (testNum != 10 && NAVFileExists(destPath)) {
        NAVFileDelete(destPath)
    }

    // Test 10: Create target file (to test failure)
    if (testNum == 10) {
        result = NAVFileWrite(destPath, 'target file exists')
        if (result < 0) {
            NAVLog("'WARNING: Failed to create target file: ', destPath")
        }
    }

    // Create the source file
    result = NAVFileWrite(sourcePath, "'test content for rename - test ', itoa(testNum)")

    if (result < 0) {
        NAVLog("'WARNING: Failed to create source file: ', sourcePath, ' (', itoa(result), ')'")
    }
}

define_function TestNAVFileRename() {
    stack_var integer x
    stack_var slong result
    stack_var char sourcePath[255]
    stack_var char destPath[255]

    NAVLog("'***************** NAVFileRename *****************'")

    InitializeFileRenameTestData()

    for (x = 1; x <= length_array(FILE_RENAME_SOURCE_TESTS); x++) {
        stack_var slong expected
        stack_var char shouldVerify
        stack_var char sourceExists
        stack_var char destExists

        sourcePath = FILE_RENAME_SOURCE_TESTS[x]
        destPath = FILE_RENAME_DEST_TESTS[x]

        // Setup: Create files if needed for this test
        SetupFileRenameTest(x, sourcePath, destPath)

        result = NAVFileRename(sourcePath, destPath)
        expected = FILE_RENAME_EXPECTED_RESULT[x]
        shouldVerify = FILE_RENAME_VERIFY_RESULT[x]

        // For success cases
        if (expected >= 0) {
            if (!NAVAssertTrue('Should rename/move file successfully', result >= 0)) {
                NAVLogTestFailed(x, 'success (>= 0)', "itoa(result)")
                continue
            }

            // Verify file was renamed/moved
            if (shouldVerify) {
                sourceExists = NAVFileExists(sourcePath)
                destExists = NAVFileExists(destPath)

                if (sourcePath != destPath) {
                    if (!NAVAssertFalse('Source file should not exist after rename', sourceExists)) {
                        NAVLogTestFailed(x, 'source deleted', 'source still exists')
                        continue
                    }
                }

                if (!NAVAssertTrue('Destination file should exist after rename', destExists)) {
                    NAVLogTestFailed(x, 'destination exists', 'destination not found')
                    continue
                }
            }
        }
        // For error cases
        else {
            // Some error codes may vary by system
            if (expected == -2 || expected == -13 || expected == -8) {
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
