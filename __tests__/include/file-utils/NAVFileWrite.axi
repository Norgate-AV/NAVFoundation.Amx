PROGRAM_NAME='NAVFileWrite'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileWrite
constant char FILE_WRITE_TESTS[][255] = {
    '',                                 // Test 1: Empty path
    '/testwrite/new.txt',              // Test 2: Create new file
    '/testwrite/overwrite.txt',        // Test 3: Overwrite existing file
    '/testwrite/empty.txt',            // Test 4: Write empty data
    '/testwrite/large.txt',            // Test 5: Write large data
    '/testwrite/special!@#.txt',       // Test 6: Special characters in filename
    '/nonexistent/dir/file.txt',       // Test 7: Non-existent parent directory
    '/testwrite/unicode.txt',          // Test 8: Unicode/special content
    '/testwrite/multiline.txt',        // Test 9: Multi-line content
    '/testwrite/binary.dat'            // Test 10: Binary-like data
}

constant char FILE_WRITE_TEST_DATA[][NAV_MAX_BUFFER] = {
    '',                                // Test 1: Empty path (no data)
    'Hello World',                     // Test 2: Simple text
    'Overwritten Content',             // Test 3: Overwrite data
    '',                                // Test 4: Empty string
    '',                                // Test 5: Large data (populated at runtime)
    'Special characters test',         // Test 6: Normal text with special filename
    'Should fail',                     // Test 7: Data but no valid path
    'Test données spéciales',          // Test 8: Unicode content
    '',                                // Test 9: Multi-line (populated at runtime)
    ''                                 // Test 10: Binary data (populated at runtime)
}

constant slong FILE_WRITE_EXPECTED_RESULT[] = {
    -2,     // Test 1: Empty path - NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    11,     // Test 2: Success - bytes written (length of 'Hello World')
    20,     // Test 3: Success - bytes written (length of 'Overwritten Content')
    0,      // Test 4: Success - 0 bytes written
    0,      // Test 5: Success - large data (check >= 0)
    26,     // Test 6: Success - bytes written
    -2,     // Test 7: Invalid path - parent doesn't exist
    0,      // Test 8: Success - unicode content (check >= 0)
    0,      // Test 9: Success - multiline content (check >= 0)
    0       // Test 10: Success - binary data (check >= 0)
}


DEFINE_VARIABLE

// Global variables for test data
volatile char FILE_WRITE_SETUP_REQUIRED = false
volatile char FILE_WRITE_RUNTIME_DATA[10][NAV_MAX_BUFFER]

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 */
define_function InitializeFileWriteTestData() {
    stack_var integer i

    // Test 5: Large data (1000 characters)
    FILE_WRITE_RUNTIME_DATA[5] = ''
    for (i = 1; i <= 100; i++) {
        FILE_WRITE_RUNTIME_DATA[5] = "FILE_WRITE_RUNTIME_DATA[5], '0123456789'"
    }

    // Test 9: Multi-line content
    FILE_WRITE_RUNTIME_DATA[9] = "'Line 1', NAV_CR, NAV_LF, 'Line 2', NAV_CR, NAV_LF, 'Line 3'"

    // Test 10: Binary-like data (control characters)
    FILE_WRITE_RUNTIME_DATA[10] = "'Binary', $00, $01, $02, $FF, 'Data'"

    FILE_WRITE_SETUP_REQUIRED = true
}

define_function TestNAVFileWrite() {
    stack_var integer x
    stack_var slong result
    stack_var char testPath[255]
    stack_var char testData[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVFileWrite *****************'")

    InitializeFileWriteTestData()

    for (x = 1; x <= length_array(FILE_WRITE_TESTS); x++) {
        stack_var slong expected

        testPath = FILE_WRITE_TESTS[x]

        // Use runtime data if available, otherwise use constant data
        if (x == 5 || x == 9 || x == 10) {
            testData = FILE_WRITE_RUNTIME_DATA[x]
        }
        else {
            testData = FILE_WRITE_TEST_DATA[x]
        }

        result = NAVFileWrite(testPath, testData)
        expected = FILE_WRITE_EXPECTED_RESULT[x]

        // For variable-length tests, just check success (>= 0)
        if (x == 5 || x == 8 || x == 9 || x == 10) {
            if (expected >= 0) {
                if (!NAVAssertTrue('Should write file successfully', result >= 0)) {
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
}
