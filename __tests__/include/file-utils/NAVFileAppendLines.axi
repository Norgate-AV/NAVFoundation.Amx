PROGRAM_NAME='NAVFileAppendLines'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileAppendLines
constant char FILE_APPEND_LINES_TESTS[][255] = {
    '',                                   // Test 1: Empty path
    '/testappendlines/new.txt',           // Test 2: New file (doesn't exist yet)
    '/testappendlines/existing.txt',      // Test 3: Append to existing file
    '/testappendlines/multiple.txt',      // Test 4: Multiple sequential appends
    '/testappendlines/empty-array.txt',   // Test 5: Empty array (no-op)
    '/testappendlines/empty-lines.txt',   // Test 6: Append empty lines
    '/testappendlines/mixed.txt',         // Test 7: Mixed with WriteLine
    '/testappendlines/many.txt',          // Test 8: Append many lines
    '/nonexistent/dir/file.txt'           // Test 9: Invalid path
}

constant slong FILE_APPEND_LINES_EXPECTED_RESULT[] = {
    -2,     // Test 1: NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success (creates new file)
    0,      // Test 3: Success (appends)
    0,      // Test 4: Success (first append)
    0,      // Test 5: Success (no-op)
    0,      // Test 6: Success
    0,      // Test 7: Success
    0,      // Test 8: Success
    -2      // Test 9: NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
}

constant integer FILE_APPEND_LINES_EXPECTED_LINE_COUNT[] = {
    0,      // Test 1: N/A
    2,      // Test 2: 2 lines
    5,      // Test 3: 3 original + 2 appended = 5
    6,      // Test 4: 3 from first append + 3 from second = 6
    0,      // Test 5: 0 lines (empty array, file doesn't exist)
    3,      // Test 6: 3 lines (2 empty + 1 content)
    4,      // Test 7: 2 from WriteLine + 2 from AppendLines = 4
    52,     // Test 8: 2 initial + 50 appended = 52
    0       // Test 9: N/A
}

DEFINE_VARIABLE

volatile char FILE_APPEND_LINES_SETUP_REQUIRED = false
volatile char FILE_APPEND_LINES_RUNTIME_DATA[9][50][NAV_MAX_BUFFER]

/**
 * Initialize test data
 */
define_function InitializeFileAppendLinesTestData() {
    stack_var integer i

    // Create test directory
    NAVDirectoryCreate('/testappendlines')

    // Test 2: New file with 2 lines
    FILE_APPEND_LINES_RUNTIME_DATA[2][1] = 'First line in new file'
    FILE_APPEND_LINES_RUNTIME_DATA[2][2] = 'Second line in new file'
    set_length_array(FILE_APPEND_LINES_RUNTIME_DATA[2], 2)

    // Test 3: Lines to append to existing
    FILE_APPEND_LINES_RUNTIME_DATA[3][1] = 'Appended line 1'
    FILE_APPEND_LINES_RUNTIME_DATA[3][2] = 'Appended line 2'
    set_length_array(FILE_APPEND_LINES_RUNTIME_DATA[3], 2)

    // Test 4: First append
    FILE_APPEND_LINES_RUNTIME_DATA[4][1] = 'Append batch 1 - line 1'
    FILE_APPEND_LINES_RUNTIME_DATA[4][2] = 'Append batch 1 - line 2'
    FILE_APPEND_LINES_RUNTIME_DATA[4][3] = 'Append batch 1 - line 3'
    set_length_array(FILE_APPEND_LINES_RUNTIME_DATA[4], 3)

    // Test 5: Empty array
    set_length_array(FILE_APPEND_LINES_RUNTIME_DATA[5], 0)

    // Test 6: Empty lines
    FILE_APPEND_LINES_RUNTIME_DATA[6][1] = ''
    FILE_APPEND_LINES_RUNTIME_DATA[6][2] = ''
    FILE_APPEND_LINES_RUNTIME_DATA[6][3] = 'Content line'
    set_length_array(FILE_APPEND_LINES_RUNTIME_DATA[6], 3)

    // Test 7: Lines to append after WriteLine
    FILE_APPEND_LINES_RUNTIME_DATA[7][1] = 'AppendLines line 1'
    FILE_APPEND_LINES_RUNTIME_DATA[7][2] = 'AppendLines line 2'
    set_length_array(FILE_APPEND_LINES_RUNTIME_DATA[7], 2)

    // Test 8: Many lines (50)
    for (i = 1; i <= 50; i++) {
        FILE_APPEND_LINES_RUNTIME_DATA[8][i] = "'Appended line ', itoa(i)"
    }
    set_length_array(FILE_APPEND_LINES_RUNTIME_DATA[8], 50)

    // Test 9: Invalid path
    FILE_APPEND_LINES_RUNTIME_DATA[9][1] = 'Should fail'
    set_length_array(FILE_APPEND_LINES_RUNTIME_DATA[9], 1)

    FILE_APPEND_LINES_SETUP_REQUIRED = true
}

/**
 * Setup function called before each test
 */
define_function SetupFileAppendLinesTest(integer testIndex) {
    if (!FILE_APPEND_LINES_SETUP_REQUIRED) {
        InitializeFileAppendLinesTestData()
    }

    // Test 3: Create existing file with 3 lines
    if (testIndex == 3) {
        NAVFileWriteLine(FILE_APPEND_LINES_TESTS[testIndex], 'Existing line 1')
        NAVFileAppendLine(FILE_APPEND_LINES_TESTS[testIndex], 'Existing line 2')
        NAVFileAppendLine(FILE_APPEND_LINES_TESTS[testIndex], 'Existing line 3')
    }

    // Test 7: Create initial file with WriteLine, then append with AppendLines
    if (testIndex == 7) {
        NAVFileWriteLine(FILE_APPEND_LINES_TESTS[testIndex], 'WriteLine line 1')
        NAVFileAppendLine(FILE_APPEND_LINES_TESTS[testIndex], 'WriteLine line 2')
    }

    // Test 8: Create initial file with 2 lines
    if (testIndex == 8) {
        NAVFileWriteLine(FILE_APPEND_LINES_TESTS[testIndex], 'Initial line 1')
        NAVFileAppendLine(FILE_APPEND_LINES_TESTS[testIndex], 'Initial line 2')
    }
}

/**
 * Main test function
 */
define_function TestNAVFileAppendLines() {
    stack_var integer x
    stack_var slong result
    stack_var integer actualLineCount
    stack_var slong expectedResult
    stack_var char secondBatch[3][NAV_MAX_BUFFER]

    NAVLog("'***************** NAVFileAppendLines *****************'")

    for (x = 1; x <= length_array(FILE_APPEND_LINES_TESTS); x++) {
        // Delete existing file to ensure clean test
        NAVFileDelete(FILE_APPEND_LINES_TESTS[x])

        SetupFileAppendLinesTest(x)

        expectedResult = FILE_APPEND_LINES_EXPECTED_RESULT[x]

        // Execute function
        result = NAVFileAppendLines(FILE_APPEND_LINES_TESTS[x], FILE_APPEND_LINES_RUNTIME_DATA[x])

        // Test 4: Do second append
        if (x == 4 && result == 0) {
            secondBatch[1] = 'Append batch 2 - line 1'
            secondBatch[2] = 'Append batch 2 - line 2'
            secondBatch[3] = 'Append batch 2 - line 3'
            set_length_array(secondBatch, 3)

            result = NAVFileAppendLines(FILE_APPEND_LINES_TESTS[x], secondBatch)
        }

        // Verify result
        if (!NAVAssertSignedLongEqual('Should return expected result', expectedResult, result)) {
            NAVLogTestFailed(x, "itoa(expectedResult)", "itoa(result)")
            continue
        }

        // For successful appends, verify line count
        if (expectedResult == 0 && x != 5) {  // Skip empty array test
            actualLineCount = CountLinesInFile(FILE_APPEND_LINES_TESTS[x])

            if (!NAVAssertIntegerEqual('Should have expected number of lines',
                                       FILE_APPEND_LINES_EXPECTED_LINE_COUNT[x],
                                       actualLineCount)) {
                NAVLogTestFailed(x,
                                "itoa(FILE_APPEND_LINES_EXPECTED_LINE_COUNT[x])",
                                "itoa(actualLineCount)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
