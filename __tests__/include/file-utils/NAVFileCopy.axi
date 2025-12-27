PROGRAM_NAME='NAVFileCopy'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileCopy (source, destination)
constant char FILE_COPY_SOURCE_TESTS[][255] = {
    '',                                 // Test 1: Empty source path
    '/testcopy/source.txt',            // Test 2: Copy file
    '/testcopy/move-copy.txt',         // Test 3: Copy to different directory
    '/testcopy/nonexistent.txt',       // Test 4: Copy non-existent file (should fail)
    '/testcopy/special!@#.txt',        // Test 5: Copy file with special characters
    '/testcopy/with spaces.txt',       // Test 6: Copy file with spaces
    '/testcopy/noext',                 // Test 7: Copy file without extension
    '/testcopy/nested/file.txt',       // Test 8: Copy nested file
    '/testcopy',                       // Test 9: Try to copy directory (should fail)
    '/testcopy/overwrite-src.txt',     // Test 10: Copy to existing filename (overwrite)
    '/testcopy/large.txt',             // Test 11: Copy larger file
    '/testcopy/empty.txt',             // Test 12: Copy empty file
    'relative-src.txt'                 // Test 13: Relative source path
}

constant char FILE_COPY_DEST_TESTS[][255] = {
    '',                                 // Test 1: Empty destination
    '/testcopy/copy.txt',              // Test 2: New name
    '/testcopy/copied/move-copy.txt',  // Test 3: Different directory
    '/testcopy/copy-ne.txt',           // Test 4: Destination for non-existent
    '/testcopy/special-copied.txt',    // Test 5: Normal name
    '/testcopy/no-spaces-copy.txt',    // Test 6: Normal name
    '/testcopy/with-ext-copy.txt',     // Test 7: Add extension
    '/testcopy/nested/copied.txt',     // Test 8: New name in same directory
    '/testcopy-new',                   // Test 9: Try to copy directory
    '/testcopy/overwrite-dst.txt',     // Test 10: Existing target file (overwrite)
    '/testcopy/large-copy.txt',        // Test 11: Copy large file
    '/testcopy/empty-copy.txt',        // Test 12: Copy empty file
    '/relative-dst.txt'                // Test 13: Relative destination
}

constant slong FILE_COPY_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty source - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success - file copied
    0,      // Test 3: Success - file copied to different directory
    -2,     // Test 4: Invalid file path (doesn't exist)
    0,      // Test 5: Success - copied
    0,      // Test 6: Success - copied
    0,      // Test 7: Success - copied
    0,      // Test 8: Success - copied
    -2,     // Test 9: Invalid (can't copy directory as file)
    0,      // Test 10: Success - overwrites existing
    0,      // Test 11: Success - large file copied
    0,      // Test 12: Success - empty file copied
    0       // Test 13: Success - relative paths
}

constant char FILE_COPY_NEEDS_CREATION[] = {
    false,  // Test 1: No creation needed (error case)
    true,   // Test 2: Create source file
    true,   // Test 3: Create source file and destination directory
    false,  // Test 4: Don't create (testing non-existent)
    true,   // Test 5: Create source file
    true,   // Test 6: Create source file
    true,   // Test 7: Create source file
    true,   // Test 8: Create source file
    false,  // Test 9: Directory exists (testcopy)
    true,   // Test 10: Create both source and target files
    true,   // Test 11: Create source file (large)
    true,   // Test 12: Create source file (empty)
    true    // Test 13: Create source file
}

constant char FILE_COPY_VERIFY_RESULT[] = {
    false,  // Test 1: No verification (error case)
    true,   // Test 2: Verify both exist
    true,   // Test 3: Verify both exist
    false,  // Test 4: Nothing to verify (error case)
    true,   // Test 5: Verify both exist
    true,   // Test 6: Verify both exist
    true,   // Test 7: Verify both exist
    true,   // Test 8: Verify both exist
    false,  // Test 9: Nothing to verify (error case)
    true,   // Test 10: Verify both exist
    true,   // Test 11: Verify both exist (and sizes match)
    true,   // Test 12: Verify both exist
    true    // Test 13: Verify both exist
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_COPY_SETUP_REQUIRED = false
volatile char FILE_COPY_TEST_CONTENT[13][NAV_MAX_BUFFER]

/**
 * Initialize global test data arrays at runtime
 */
define_function InitializeFileCopyTestData() {
    stack_var integer i

    // Test 11: Large file content (500 characters)
    FILE_COPY_TEST_CONTENT[11] = ''
    for (i = 1; i <= 50; i++) {
        FILE_COPY_TEST_CONTENT[11] = "FILE_COPY_TEST_CONTENT[11], '0123456789'"
    }

    // Test 12: Empty file
    FILE_COPY_TEST_CONTENT[12] = ''

    FILE_COPY_SETUP_REQUIRED = true
}

/**
 * Setup test files
 */
define_function SetupFileCopyTest(integer testNum, char sourcePath[], char destPath[]) {
    stack_var slong result
    stack_var char dirPath[255]
    stack_var char content[NAV_MAX_BUFFER]

    if (!FILE_COPY_NEEDS_CREATION[testNum]) {
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

    // Test 10: Create target file (to test overwrite)
    if (testNum == 10) {
        result = NAVFileWrite(destPath, 'old target file content')
        if (result < 0) {
            NAVLog("'WARNING: Failed to create target file: ', destPath")
        }
    }

    // Prepare content
    if (testNum == 11 || testNum == 12) {
        content = FILE_COPY_TEST_CONTENT[testNum]
    }
    else {
        content = "'test content for copy - test ', itoa(testNum)"
    }

    // Create the source file
    result = NAVFileWrite(sourcePath, content)

    if (result < 0) {
        NAVLog("'WARNING: Failed to create source file: ', sourcePath, ' (', itoa(result), ')'")
    }
}

define_function TestNAVFileCopy() {
    stack_var integer x
    stack_var slong result
    stack_var char sourcePath[255]
    stack_var char destPath[255]

    NAVLog("'***************** NAVFileCopy *****************'")

    InitializeFileCopyTestData()

    for (x = 1; x <= length_array(FILE_COPY_SOURCE_TESTS); x++) {
        stack_var slong expected
        stack_var char shouldVerify
        stack_var char sourceExists
        stack_var char destExists
        stack_var slong sourceSize
        stack_var slong destSize

        sourcePath = FILE_COPY_SOURCE_TESTS[x]
        destPath = FILE_COPY_DEST_TESTS[x]

        // Setup: Create files if needed for this test
        SetupFileCopyTest(x, sourcePath, destPath)

        result = NAVFileCopy(sourcePath, destPath)
        expected = FILE_COPY_EXPECTED_RESULT[x]
        shouldVerify = FILE_COPY_VERIFY_RESULT[x]

        // For success cases
        if (expected >= 0) {
            if (!NAVAssertTrue('Should copy file successfully', result >= 0)) {
                NAVLogTestFailed(x, 'success (>= 0)', "itoa(result)")
                continue
            }

            // Verify files exist
            if (shouldVerify) {
                sourceExists = NAVFileExists(sourcePath)
                destExists = NAVFileExists(destPath)

                if (!NAVAssertTrue('Source file should still exist after copy', sourceExists)) {
                    NAVLogTestFailed(x, 'source exists', 'source not found')
                    continue
                }

                if (!NAVAssertTrue('Destination file should exist after copy', destExists)) {
                    NAVLogTestFailed(x, 'destination exists', 'destination not found')
                    continue
                }

                // For large file test, verify sizes match
                if (x == 11) {
                    sourceSize = NAVFileGetSize(sourcePath)
                    destSize = NAVFileGetSize(destPath)

                    if (!NAVAssertSignedLongEqual('Copied file should have same size as source', sourceSize, destSize)) {
                        NAVLogTestFailed(x, "itoa(sourceSize)", "itoa(destSize)")
                        continue
                    }
                }
            }
        }
        // For error cases
        else {
            if (expected == -2) {
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
