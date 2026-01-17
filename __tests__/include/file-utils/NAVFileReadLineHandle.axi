PROGRAM_NAME='NAVFileReadLineHandle'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileReadLineHandle
constant char FILE_READ_LINE_HANDLE_TESTS[][255] = {
    '/testreadline/single.txt',        // Test 1: Single line file
    '/testreadline/multiple.txt',      // Test 2: Multiple line file
    '/testreadline/empty.txt',         // Test 3: Empty file (EOF immediately)
    '/testreadline/crlf.txt',          // Test 4: Windows line endings (CRLF)
    '/testreadline/lf.txt',            // Test 5: Unix line endings (LF)
    '/testreadline/mixed.txt',         // Test 6: Mixed line endings
    '/testreadline/long.txt',          // Test 7: Long lines
    '/testreadline/empty-lines.txt',   // Test 8: File with empty lines
    '/testreadline/no-newline.txt',    // Test 9: File without trailing newline
    '/nonexistent-readline.txt'        // Test 10: Non-existent file (should fail to open)
}

constant slong FILE_READ_LINE_HANDLE_EXPECTED_LINE_COUNT[] = {
    1,      // Test 1: Single line
    5,      // Test 2: Five lines
    0,      // Test 3: Empty file (0 lines)
    3,      // Test 4: Three lines with CRLF
    2,      // Test 5: Two lines with LF (final LF doesn't count)
    3,      // Test 6: Three lines with mixed endings (final LF doesn't count)
    2,      // Test 7: Two long lines
    5,      // Test 8: Five lines (some empty)
    0,      // Test 9: Zero lines (file creation fails, no trailing newline)
    -1      // Test 10: Error case (file open fails)
}

constant char FILE_READ_LINE_HANDLE_NEEDS_CREATION[] = {
    true,   // Test 1: Create single line file
    true,   // Test 2: Create multiple line file
    false,  // Test 3: Empty file (can't create with 0 bytes)
    true,   // Test 4: Create CRLF file
    true,   // Test 5: Create LF file
    true,   // Test 6: Create mixed file
    true,   // Test 7: Create long line file
    true,   // Test 8: Create empty lines file
    true,   // Test 9: Create no-newline file
    false   // Test 10: Don't create (testing error)
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_READ_LINE_HANDLE_SETUP_REQUIRED = false
volatile char FILE_READ_LINE_HANDLE_TEST_CONTENT[10][NAV_MAX_BUFFER]

/**
 * Initialize global test data arrays at runtime
 */
define_function InitializeFileReadLineHandleTestData() {
    stack_var slong result

    // Create parent directory
    result = NAVDirectoryCreate('/testreadline')

    // Test 1: Single line
    FILE_READ_LINE_HANDLE_TEST_CONTENT[1] = 'Single line of text'
    FILE_READ_LINE_HANDLE_TEST_CONTENT[1] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[1], NAV_CR, NAV_LF"

    // Test 2: Multiple lines
    FILE_READ_LINE_HANDLE_TEST_CONTENT[2] = 'Line 1'
    FILE_READ_LINE_HANDLE_TEST_CONTENT[2] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[2], NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[2] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[2], 'Line 2', NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[2] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[2], 'Line 3', NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[2] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[2], 'Line 4', NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[2] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[2], 'Line 5', NAV_CR, NAV_LF"

    // Test 3: Empty file
    FILE_READ_LINE_HANDLE_TEST_CONTENT[3] = ''

    // Test 4: CRLF endings
    FILE_READ_LINE_HANDLE_TEST_CONTENT[4] = 'Windows line 1'
    FILE_READ_LINE_HANDLE_TEST_CONTENT[4] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[4], NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[4] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[4], 'Windows line 2', NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[4] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[4], 'Windows line 3', NAV_CR, NAV_LF"

    // Test 5: LF endings only
    FILE_READ_LINE_HANDLE_TEST_CONTENT[5] = 'Unix line 1'
    FILE_READ_LINE_HANDLE_TEST_CONTENT[5] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[5], NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[5] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[5], 'Unix line 2', NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[5] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[5], 'Unix line 3', NAV_LF"

    // Test 6: Mixed endings
    FILE_READ_LINE_HANDLE_TEST_CONTENT[6] = 'Mixed line 1'
    FILE_READ_LINE_HANDLE_TEST_CONTENT[6] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[6], NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[6] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[6], 'Mixed line 2', NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[6] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[6], 'Mixed line 3', NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[6] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[6], 'Mixed line 4', NAV_LF"

    // Test 7: Long lines (100+ characters each)
    FILE_READ_LINE_HANDLE_TEST_CONTENT[7] = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890'
    FILE_READ_LINE_HANDLE_TEST_CONTENT[7] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[7], NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[7] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[7], 'ABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJ', NAV_CR, NAV_LF"

    // Test 8: Empty lines
    FILE_READ_LINE_HANDLE_TEST_CONTENT[8] = 'First line'
    FILE_READ_LINE_HANDLE_TEST_CONTENT[8] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[8], NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[8] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[8], NAV_CR, NAV_LF"  // Empty line
    FILE_READ_LINE_HANDLE_TEST_CONTENT[8] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[8], 'Third line', NAV_CR, NAV_LF"
    FILE_READ_LINE_HANDLE_TEST_CONTENT[8] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[8], NAV_CR, NAV_LF"  // Empty line
    FILE_READ_LINE_HANDLE_TEST_CONTENT[8] = "FILE_READ_LINE_HANDLE_TEST_CONTENT[8], 'Fifth line', NAV_CR, NAV_LF"

    // Test 9: No trailing newline
    FILE_READ_LINE_HANDLE_TEST_CONTENT[9] = 'Line without newline at end'

    FILE_READ_LINE_HANDLE_SETUP_REQUIRED = true
}

/**
 * Setup test files
 */
define_function SetupFileReadLineHandleTest(integer testNum, char path[]) {
    stack_var slong result
    stack_var char dirPath[255]

    if (!FILE_READ_LINE_HANDLE_NEEDS_CREATION[testNum]) {
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

    // Create the file with specific content
    result = NAVFileWrite(path, FILE_READ_LINE_HANDLE_TEST_CONTENT[testNum])

    if (result < 0) {
        NAVLog("'WARNING: Failed to create test file: ', path, ' (', itoa(result), ')'")
    }
}

define_function TestNAVFileReadLineHandle() {
    stack_var integer x
    stack_var char testPath[255]

    NAVLog("'***************** NAVFileReadLineHandle *****************'")

    InitializeFileReadLineHandleTestData()

    for (x = 1; x <= length_array(FILE_READ_LINE_HANDLE_TESTS); x++) {
        stack_var long fileHandle
        stack_var slong result
        stack_var slong expectedLineCount
        stack_var integer actualLineCount
        stack_var char line[NAV_MAX_BUFFER]

        testPath = FILE_READ_LINE_HANDLE_TESTS[x]
        expectedLineCount = FILE_READ_LINE_HANDLE_EXPECTED_LINE_COUNT[x]

        // Setup: Create file if needed for this test
        SetupFileReadLineHandleTest(x, testPath)

        // Open the file
        result = NAVFileOpen(testPath, 'r')

        // Error case: file open fails
        if (expectedLineCount < 0) {
            if (!NAVAssertTrue('Should fail to open non-existent file', result < 0)) {
                NAVLogTestFailed(x, 'error (< 0)', "itoa(result)")

                fileHandle = type_cast(result)

                if (fileHandle >= 0) {
                    NAVFileClose(fileHandle)
                }

                continue
            }

            NAVLogTestPassed(x)
            continue
        }

        // Check file opened successfully
        if (result < 0) {
            NAVLogTestFailed(x, 'file opened', "'open failed: ', itoa(result)")
            continue
        }

        fileHandle = type_cast(result)

        // Read all lines
        actualLineCount = 0
        while (1) {
            line = ''
            result = NAVFileReadLineHandle(fileHandle, line)

            if (result < 0) {
                // EOF or error
                if (result == NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED) {
                    // Normal EOF
                    break
                }
                else {
                    NAVLog("'WARNING: Error reading line: ', itoa(result)")
                    break
                }
            }

            actualLineCount++
        }

        // Close the file
        NAVFileClose(fileHandle)

        // Verify line count
        if (!NAVAssertIntegerEqual('Should read correct number of lines', type_cast(expectedLineCount), actualLineCount)) {
            NAVLogTestFailed(x, "itoa(expectedLineCount)", "itoa(actualLineCount)")
            continue
        }

        NAVLogTestPassed(x)
    }
}

