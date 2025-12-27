PROGRAM_NAME='NAVFileAppend'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileAppend
constant char FILE_APPEND_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/testappend/new.txt',             // Test 2: Append to new file (creates it)
    '/testappend/existing.txt',        // Test 3: Append to existing file
    '/testappend/existing.txt',        // Test 4: Append again to same file (test multiple appends)
    '/testappend/empty.txt',           // Test 5: Append empty data
    '/testappend/multiappend.txt',     // Test 6: Multiple append operations
    '/testappend/multiappend.txt',     // Test 7: Second append
    '/testappend/multiappend.txt',     // Test 8: Third append
    '/nonexistent/dir/file.txt',       // Test 9: Non-existent parent directory
    '/testappend/special!@#.txt',      // Test 10: Special characters in filename
    '/testappend/unicode.txt',         // Test 11: Unicode content
    '/testappend/binary.dat'           // Test 12: Binary-like data
}

constant char FILE_APPEND_TEST_DATA[][NAV_MAX_BUFFER] = {
    '',                                // Test 1: Empty path (no data)
    'First line',                      // Test 2: Create file with first line
    'Second line',                     // Test 3: Append second line
    'Third line',                      // Test 4: Append third line
    '',                                // Test 5: Empty string
    'Line 1',                          // Test 6: First append
    'Line 2',                          // Test 7: Second append
    'Line 3',                          // Test 8: Third append
    'Should fail',                     // Test 9: Data but no valid path
    'Special append',                  // Test 10: Normal text with special filename
    'Données spéciales',               // Test 11: Unicode content
    ''                                 // Test 12: Binary data (populated at runtime)
}

constant slong FILE_APPEND_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty path - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    10,     // Test 2: Success - bytes written (length of 'First line')
    11,     // Test 3: Success - bytes written (length of 'Second line')
    10,     // Test 4: Success - bytes written (length of 'Third line')
    0,      // Test 5: Success - 0 bytes written
    6,      // Test 6: Success - bytes written (length of 'Line 1')
    6,      // Test 7: Success - bytes written (length of 'Line 2')
    6,      // Test 8: Success - bytes written (length of 'Line 3')
    -2,     // Test 9: Invalid path - parent doesn't exist
    14,     // Test 10: Success - bytes written
    0,      // Test 11: Success - unicode content (check >= 0)
    0       // Test 12: Success - binary data (check >= 0)
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_APPEND_SETUP_REQUIRED = false
volatile char FILE_APPEND_RUNTIME_DATA[12][NAV_MAX_BUFFER]

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 */
define_function InitializeFileAppendTestData() {
    // Test 12: Binary-like data (control characters)
    FILE_APPEND_RUNTIME_DATA[12] = "'Binary', $00, $01, $02, $FF, 'Data'"

    FILE_APPEND_SETUP_REQUIRED = true
}

define_function TestNAVFileAppend() {
    stack_var integer x
    stack_var slong result
    stack_var char testPath[255]
    stack_var char testData[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVFileAppend *****************'")

    InitializeFileAppendTestData()

    for (x = 1; x <= length_array(FILE_APPEND_TESTS); x++) {
        stack_var slong expected

        testPath = FILE_APPEND_TESTS[x]

        // Use runtime data if available, otherwise use constant data
        if (x == 12) {
            testData = FILE_APPEND_RUNTIME_DATA[x]
        }
        else {
            testData = FILE_APPEND_TEST_DATA[x]
        }

        result = NAVFileAppend(testPath, testData)
        expected = FILE_APPEND_EXPECTED_RESULT[x]

        // For variable-length tests, just check success (>= 0)
        if (x == 11 || x == 12) {
            if (expected >= 0) {
                if (!NAVAssertTrue('Should append to file successfully', result >= 0)) {
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
        }
        else {
            if (!NAVAssertSignedLongEqual('Should return correct byte count or error', expected, result)) {
                NAVLogTestFailed(x, "itoa(expected)", "itoa(result)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    // Additional verification: Read appended file and check content
    NAVLog("'Verifying multiple appends...'")
    {
        stack_var char verifyContent[NAV_MAX_BUFFER]
        stack_var slong readResult

        readResult = NAVFileRead('/testappend/multiappend.txt', verifyContent)

        if (readResult >= 0) {
            // Should contain all three lines
            if (NAVContains(verifyContent, 'Line 1') &&
                NAVContains(verifyContent, 'Line 2') &&
                NAVContains(verifyContent, 'Line 3')) {
                NAVLog("'  ✓ Multiple appends verified successfully'")
            }
            else {
                NAVLog("'  ✗ Multiple appends verification failed - content incomplete'")
            }
        }
    }
}
