PROGRAM_NAME='NAVFileSeek'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileSeek
constant char FILE_SEEK_TEST_PATHS[][255] = {
    '',                                 // Test 1: Invalid handle (0)
    '/user/config.txt',                // Test 2: Seek to beginning
    '/user/config.txt',                // Test 3: Seek to end (get size)
    '/user/data.xml',                  // Test 4: Seek to specific position (byte 10)
    '/user/data.xml',                  // Test 5: Seek to specific position (byte 25)
    '/testseek/test.txt',              // Test 6: Seek on new file
    '/testseek/large.txt',             // Test 7: Seek beyond content on large file
    '/testseek/empty.txt',             // Test 8: Seek on empty file (end = 0)
    '/testseek/binary.dat',            // Test 9: Seek in binary file
    '/testseek/multiline.txt'          // Test 10: Multiple seeks on same file
}

constant slong FILE_SEEK_POSITIONS[] = {
    0,      // Test 1: Seek to start (will fail, invalid handle)
    0,      // Test 2: Seek to beginning
    -1,     // Test 3: Seek to end
    10,     // Test 4: Seek to byte 10
    25,     // Test 5: Seek to byte 25
    0,      // Test 6: Seek to start of new file
    999,    // Test 7: Seek to high position
    -1,     // Test 8: Seek to end of empty file
    50,     // Test 9: Seek to middle of binary file
    0       // Test 10: Initial seek to start
}

constant slong FILE_SEEK_EXPECTED_RESULT[] = {
    -1,     // Test 1: Invalid file handle error
    0,      // Test 2: Position 0
    49,     // Test 3: Position 49 (file size - 1, 0-indexed)
    10,     // Test 4: Position 10
    25,     // Test 5: Position 25
    0,      // Test 6: Position 0
    999,    // Test 7: Position 999 (beyond content)
    0,      // Test 8: Position 0 (empty file, if it could be created)
    50,     // Test 9: Position 50
    0       // Test 10: Position 0
}

constant char FILE_SEEK_NEEDS_CREATION[] = {
    false,  // Test 1: No creation (testing invalid handle)
    true,   // Test 2: Create config.txt with 50 bytes
    false,  // Test 3: Use same file as test 2
    true,   // Test 4: Create data.xml with content
    false,  // Test 5: Use same file as test 4
    true,   // Test 6: Create test.txt
    true,   // Test 7: Create large.txt with 1000 bytes
    false,  // Test 8: Skip creation (cannot create 0-byte file)
    true,   // Test 9: Create binary.dat with binary data
    true    // Test 10: Create multiline.txt for multiple seeks
}

constant char FILE_SEEK_FILE_CONTENTS[][255] = {
    '',                                                                 // Test 1: N/A
    'This is a test file with exactly fifty bytes!!!!!',               // Test 2: Exactly 50 bytes
    '',                                                                 // Test 3: Same as test 2
    '<?xml version="1.0"?><root>XML data here</root>',                // Test 4: XML content
    '',                                                                 // Test 5: Same as test 4
    'New file for seek test',                                          // Test 6: Simple content
    '',                                                                 // Test 7: Will be generated (1000 bytes)
    '',                                                                 // Test 8: Empty
    '',                                                                 // Test 9: Will be binary data
    {'L', 'i', 'n', 'e', '1', $0D, $0A, 'L', 'i', 'n', 'e', '2', $0D, $0A, 'L', 'i', 'n', 'e', '3', $0D, $0A}      // Test 10: Multi-line
}

constant char FILE_SEEK_TEST_MULTIPLE_SEEKS[] = {
    false,  // Test 1: No
    false,  // Test 2: No
    false,  // Test 3: No
    false,  // Test 4: No
    false,  // Test 5: No
    false,  // Test 6: No
    false,  // Test 7: No
    false,  // Test 8: No
    false,  // Test 9: No
    true    // Test 10: Yes - test multiple seeks
}

DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_SEEK_SETUP_REQUIRED = false
volatile char FILE_SEEK_LARGE_DATA[1000]
volatile char FILE_SEEK_BINARY_DATA[100]

/**
 * Initialize global test data arrays at runtime
 */
define_function InitializeFileSeekTestData() {
    stack_var integer i
    stack_var slong result

    // Create parent directories
    result = NAVDirectoryCreate('/testseek')

    // Generate 1000 bytes of data for large file test
    for (i = 1; i <= 1000; i++) {
        FILE_SEEK_LARGE_DATA[i] = type_cast('A' + (i % 26))
    }
    set_length_array(FILE_SEEK_LARGE_DATA, 1000)

    // Generate 100 bytes of binary data
    for (i = 1; i <= 100; i++) {
        FILE_SEEK_BINARY_DATA[i] = type_cast(i % 256)
    }
    set_length_array(FILE_SEEK_BINARY_DATA, 100)

    FILE_SEEK_SETUP_REQUIRED = true
}

/**
 * Setup test files
 */
define_function SetupFileSeekTest(integer testNum, char path[]) {
    stack_var slong result
    stack_var char dirPath[255]
    stack_var char content[1000]

    if (!FILE_SEEK_NEEDS_CREATION[testNum]) {
        return
    }

    // Ensure parent directory exists
    dirPath = NAVPathDirName(path)
    if (!NAVDirectoryExists(dirPath)) {
        result = NAVDirectoryCreate(dirPath)
        if (result < 0) {
            NAVLog("'WARNING: Failed to create test directory: ', dirPath")
            return
        }
    }

    // Determine content based on test
    if (testNum == 7) {
        // Test 7: Large file
        content = FILE_SEEK_LARGE_DATA
    }
    else if (testNum == 8) {
        // Test 8: Empty file
        content = ''
    }
    else if (testNum == 9) {
        // Test 9: Binary data
        content = FILE_SEEK_BINARY_DATA
    }
    else {
        content = FILE_SEEK_FILE_CONTENTS[testNum]
    }

    // Create the file
    result = NAVFileWrite(path, content)

    if (result < 0) {
        NAVLog("'WARNING: Failed to create test file: ', path, ' (', itoa(result), ')'")
    }
}

define_function TestNAVFileSeek() {
    stack_var integer x
    stack_var slong seekResult
    stack_var char testPath[255]
    stack_var long handle
    stack_var slong position

    NAVLog("'***************** NAVFileSeek *****************'")

    InitializeFileSeekTestData()

    for (x = 1; x <= length_array(FILE_SEEK_TEST_PATHS); x++) {
        stack_var slong expected
        stack_var char needsMultipleSeeks

        testPath = FILE_SEEK_TEST_PATHS[x]
        position = FILE_SEEK_POSITIONS[x]
        expected = FILE_SEEK_EXPECTED_RESULT[x]
        needsMultipleSeeks = FILE_SEEK_TEST_MULTIPLE_SEEKS[x]

        // Setup: Create file if needed for this test
        SetupFileSeekTest(x, testPath)

        // Special case for test 1: invalid handle
        if (x == 1) {
            seekResult = NAVFileSeek(0, position)

            if (!NAVAssertSignedLongEqual('Should return invalid handle error', expected, seekResult)) {
                NAVLogTestFailed(x, "itoa(expected)", "itoa(seekResult)")
                continue
            }

            NAVLogTestPassed(x)
            continue
        }

        // Open file for seeking
        handle = type_cast(NAVFileOpen(testPath, 'r'))
        if (handle <= 0) {
            NAVLog("'WARNING: Failed to open file for test ', itoa(x), ': ', testPath")
            NAVLogTestFailed(x, 'valid handle', "itoa(handle)")
            continue
        }

        // Test single seek
        if (!needsMultipleSeeks) {
            seekResult = NAVFileSeek(handle, position)

            if (!NAVAssertSignedLongEqual('Should seek to correct position', expected, seekResult)) {
                NAVFileClose(handle)
                NAVLogTestFailed(x, "itoa(expected)", "itoa(seekResult)")
                continue
            }
        }
        else {
            // Test 10: Multiple seeks on same file
            // Seek to start
            seekResult = NAVFileSeek(handle, 0)
            if (seekResult != 0) {
                NAVFileClose(handle)
                NAVLogTestFailed(x, '0 (start)', "itoa(seekResult)")
                continue
            }

            // Seek to end
            seekResult = NAVFileSeek(handle, NAV_FILE_SEEK_END)
            if (seekResult <= 0) {
                NAVFileClose(handle)
                NAVLogTestFailed(x, '> 0 (end)', "itoa(seekResult)")
                continue
            }

            // Seek back to start
            seekResult = NAVFileSeek(handle, 0)
            if (seekResult != 0) {
                NAVFileClose(handle)
                NAVLogTestFailed(x, '0 (back to start)', "itoa(seekResult)")
                continue
            }

            // Seek to middle
            seekResult = NAVFileSeek(handle, 10)
            if (seekResult != 10) {
                NAVFileClose(handle)
                NAVLogTestFailed(x, '10 (middle)', "itoa(seekResult)")
                continue
            }
        }

        NAVFileClose(handle)
        NAVLogTestPassed(x)
    }
}
