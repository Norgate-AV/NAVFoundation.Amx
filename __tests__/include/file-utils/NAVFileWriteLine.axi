PROGRAM_NAME='NAVFileWriteLine'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileWriteLine
constant char FILE_WRITE_LINE_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/testwriteline/single.txt',       // Test 2: Write single line
    '/testwriteline/overwrite.txt',    // Test 3: Overwrite existing file
    '/testwriteline/empty.txt',        // Test 4: Write empty line
    '/testwriteline/special!@#.txt',   // Test 5: Special characters in filename
    '/testwriteline/with spaces.txt',  // Test 6: File with spaces in name
    '/testwriteline/unicode.txt',      // Test 7: Unicode content
    '/testwriteline/long.txt',         // Test 8: Long line
    '/nonexistent/dir/file.txt',       // Test 9: Non-existent parent directory
    'relative-line.txt'                // Test 10: Relative path
}

constant char FILE_WRITE_LINE_TEST_DATA[][NAV_MAX_BUFFER] = {
    '',                                // Test 1: Empty path (no data)
    'This is a single line',           // Test 2: Normal line
    'Overwritten line content',        // Test 3: Overwrite data
    '',                                // Test 4: Empty string
    'Special line content',            // Test 5: Normal text
    'Line with spaces in filename',    // Test 6: Normal text
    'Données ligne spéciale',          // Test 7: Unicode content
    '',                                // Test 8: Long line (populated at runtime)
    'Should fail',                     // Test 9: Data but no valid path
    'Relative path line'               // Test 10: Relative path data
}

constant slong FILE_WRITE_LINE_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty path - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success - bytes written (check >= 0)
    0,      // Test 3: Success - bytes written (check >= 0)
    2,      // Test 4: Success - 2 bytes (CRLF only)
    0,      // Test 5: Success - bytes written (check >= 0)
    0,      // Test 6: Success - bytes written (check >= 0)
    0,      // Test 7: Success - bytes written (check >= 0)
    0,      // Test 8: Success - long line (check >= 0)
    -2,     // Test 9: Invalid path - parent doesn't exist
    0       // Test 10: Success - relative path (check >= 0)
}

constant char FILE_WRITE_LINE_VERIFY_CRLF[] = {
    false,  // Test 1: No verification (error case)
    true,   // Test 2: Verify CRLF added
    true,   // Test 3: Verify CRLF added
    true,   // Test 4: Verify CRLF added
    true,   // Test 5: Verify CRLF added
    true,   // Test 6: Verify CRLF added
    true,   // Test 7: Verify CRLF added
    true,   // Test 8: Verify CRLF added
    false,  // Test 9: No verification (error case)
    true    // Test 10: Verify CRLF added
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_WRITE_LINE_SETUP_REQUIRED = false
volatile char FILE_WRITE_LINE_RUNTIME_DATA[10][NAV_MAX_BUFFER]

/**
 * Initialize global test data arrays at runtime
 */
define_function InitializeFileWriteLineTestData() {
    stack_var integer i
    stack_var slong result

    // Create parent directory
    result = NAVDirectoryCreate('/testwriteline')

    // Test 8: Long line (200 characters)
    FILE_WRITE_LINE_RUNTIME_DATA[8] = ''
    for (i = 1; i <= 20; i++) {
        FILE_WRITE_LINE_RUNTIME_DATA[8] = "FILE_WRITE_LINE_RUNTIME_DATA[8], '0123456789'"
    }

    FILE_WRITE_LINE_SETUP_REQUIRED = true
}

define_function TestNAVFileWriteLine() {
    stack_var integer x
    stack_var slong result
    stack_var char testPath[255]
    stack_var char testData[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVFileWriteLine *****************'")

    InitializeFileWriteLineTestData()

    for (x = 1; x <= length_array(FILE_WRITE_LINE_TESTS); x++) {
        stack_var slong expected
        stack_var char shouldVerify
        stack_var char fileContent[NAV_MAX_BUFFER]
        stack_var slong readResult

        testPath = FILE_WRITE_LINE_TESTS[x]

        // Use runtime data if available, otherwise use constant data
        if (x == 8) {
            testData = FILE_WRITE_LINE_RUNTIME_DATA[x]
        }
        else {
            testData = FILE_WRITE_LINE_TEST_DATA[x]
        }

        result = NAVFileWriteLine(testPath, testData)
        expected = FILE_WRITE_LINE_EXPECTED_RESULT[x]
        shouldVerify = FILE_WRITE_LINE_VERIFY_CRLF[x]

        // For success cases
        if (expected >= 0) {
            if (!NAVAssertTrue('Should write line successfully', result >= 0)) {
                NAVLogTestFailed(x, 'success (>= 0)', "itoa(result)")
                continue
            }

            // Verify CRLF was added
            if (shouldVerify) {
                readResult = NAVFileRead(testPath, fileContent)
                if (readResult >= 0) {
                    // Check that file ends with CRLF
                    if (!NAVEndsWith(fileContent, "NAV_CR, NAV_LF")) {
                        NAVLogTestFailed(x, 'ends with CRLF', 'missing CRLF')
                        continue
                    }
                }
            }
        }
        else {
            if (!NAVAssertSignedLongEqual('Should return error code', expected, result)) {
                NAVLogTestFailed(x, "itoa(expected)", "itoa(result)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
