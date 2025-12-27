PROGRAM_NAME='NAVFileAppendLine'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileAppendLine
constant char FILE_APPEND_LINE_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/testappendline/new.txt',         // Test 2: Append line to new file (creates it)
    '/testappendline/existing.txt',    // Test 3: Append line to existing file
    '/testappendline/existing.txt',    // Test 4: Append another line to same file
    '/testappendline/existing.txt',    // Test 5: Append third line to same file
    '/testappendline/empty.txt',       // Test 6: Append empty line
    '/testappendline/special!@#.txt',  // Test 7: Special characters in filename
    '/testappendline/with spaces.txt', // Test 8: File with spaces in name
    '/testappendline/unicode.txt',     // Test 9: Unicode content
    '/testappendline/multiline.txt',   // Test 10: Multiple appends to same file
    '/testappendline/multiline.txt',   // Test 11: Second append
    '/testappendline/multiline.txt',   // Test 12: Third append
    '/nonexistent/dir/file.txt',       // Test 13: Non-existent parent directory
    'relative-appendline.txt'          // Test 14: Relative path
}

constant char FILE_APPEND_LINE_TEST_DATA[][NAV_MAX_BUFFER] = {
    '',                                // Test 1: Empty path (no data)
    'First line',                      // Test 2: Create file with first line
    'Second line',                     // Test 3: Append second line
    'Third line',                      // Test 4: Append third line
    'Fourth line',                     // Test 5: Append fourth line
    '',                                // Test 6: Empty string
    'Special append line',             // Test 7: Normal text
    'Line with spaces in filename',    // Test 8: Normal text
    'Ligne unicode spéciale',          // Test 9: Unicode content
    'Multi line 1',                    // Test 10: First append
    'Multi line 2',                    // Test 11: Second append
    'Multi line 3',                    // Test 12: Third append
    'Should fail',                     // Test 13: Data but no valid path
    'Relative append line'             // Test 14: Relative path data
}

constant slong FILE_APPEND_LINE_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty path - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success - bytes written (check >= 0)
    0,      // Test 3: Success - bytes written (check >= 0)
    0,      // Test 4: Success - bytes written (check >= 0)
    0,      // Test 5: Success - bytes written (check >= 0)
    2,      // Test 6: Success - 2 bytes (CRLF only)
    0,      // Test 7: Success - bytes written (check >= 0)
    0,      // Test 8: Success - bytes written (check >= 0)
    0,      // Test 9: Success - bytes written (check >= 0)
    0,      // Test 10: Success - bytes written (check >= 0)
    0,      // Test 11: Success - bytes written (check >= 0)
    0,      // Test 12: Success - bytes written (check >= 0)
    -2,     // Test 13: Invalid path - parent doesn't exist
    0       // Test 14: Success - relative path (check >= 0)
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_APPEND_LINE_SETUP_REQUIRED = false

/**
 * Initialize global test data arrays at runtime
 */
define_function InitializeFileAppendLineTestData() {
    FILE_APPEND_LINE_SETUP_REQUIRED = true
}

define_function TestNAVFileAppendLine() {
    stack_var integer x
    stack_var slong result
    stack_var char testPath[255]
    stack_var char testData[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVFileAppendLine *****************'")

    InitializeFileAppendLineTestData()

    for (x = 1; x <= length_array(FILE_APPEND_LINE_TESTS); x++) {
        stack_var slong expected

        testPath = FILE_APPEND_LINE_TESTS[x]
        testData = FILE_APPEND_LINE_TEST_DATA[x]

        result = NAVFileAppendLine(testPath, testData)
        expected = FILE_APPEND_LINE_EXPECTED_RESULT[x]

        // For success cases
        if (expected >= 0) {
            if (!NAVAssertTrue('Should append line successfully', result >= 0)) {
                NAVLogTestFailed(x, 'success (>= 0)', "itoa(result)")
                continue
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

    // Additional verification: Read appended file and check multiple lines
    NAVLog("'Verifying multiple line appends...'")
    {
        stack_var char verifyContent[NAV_MAX_BUFFER]
        stack_var slong readResult
        stack_var integer lineCount

        // Test file with 4 appended lines
        readResult = NAVFileRead('/testappendline/existing.txt', verifyContent)

        if (readResult >= 0) {
            // Count CRLF occurrences
            lineCount = 0
            if (NAVContains(verifyContent, 'First line')) lineCount++
            if (NAVContains(verifyContent, 'Second line')) lineCount++
            if (NAVContains(verifyContent, 'Third line')) lineCount++
            if (NAVContains(verifyContent, 'Fourth line')) lineCount++

            if (lineCount == 4) {
                NAVLog("'  ✓ Multiple line appends verified successfully'")
            }
            else {
                NAVLog("'  ✗ Multiple line appends verification failed - found ', itoa(lineCount), ' lines'")
            }
        }

        // Test file with 3 multi-line appends
        readResult = NAVFileRead('/testappendline/multiline.txt', verifyContent)

        if (readResult >= 0) {
            if (NAVContains(verifyContent, 'Multi line 1') &&
                NAVContains(verifyContent, 'Multi line 2') &&
                NAVContains(verifyContent, 'Multi line 3')) {
                NAVLog("'  ✓ Multi-line appends verified successfully'")
            }
            else {
                NAVLog("'  ✗ Multi-line appends verification failed'")
            }
        }
    }
}
