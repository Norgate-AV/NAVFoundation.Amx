PROGRAM_NAME='NAVTrimFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_VARIABLE

volatile char TRIM_TEST[12][NAV_MAX_BUFFER]
volatile char TRIM_LEFT_EXPECTED[12][NAV_MAX_BUFFER]
volatile char TRIM_RIGHT_EXPECTED[12][NAV_MAX_BUFFER]
volatile char TRIM_BOTH_EXPECTED[12][NAV_MAX_BUFFER]
volatile char TRIM_ARRAY_TEST[4][4][NAV_MAX_BUFFER]
volatile char TRIM_ARRAY_EXPECTED[4][4][NAV_MAX_BUFFER]

define_function InitializeTrimTestData() {
    // Initialize TRIM_TEST array with mixed ASCII and hex codes
    TRIM_TEST[1] = '   Hello World   '
    TRIM_TEST[2] = 'Hello World   '
    TRIM_TEST[3] = '   Hello World'
    TRIM_TEST[4] = 'Hello World'
    TRIM_TEST[5] = '   '
    TRIM_TEST[6] = ''
    TRIM_TEST[7] = "$09"  // TAB character
    TRIM_TEST[8] = "$0D"  // CR character
    TRIM_TEST[9] = "$0A"  // LF character
    TRIM_TEST[10] = '  Hello  World  '
    TRIM_TEST[11] = "$09, 'Hello', $09"  // Tab + Hello + Tab
    TRIM_TEST[12] = "$09, $0D, $0A, 'Hello', $0D, $0A, $09"  // Mixed whitespace: Tab + CR + LF + Hello + CR + LF + Tab
    set_length_array(TRIM_TEST, 12)

    // Initialize TRIM_LEFT_EXPECTED array
    TRIM_LEFT_EXPECTED[1] = 'Hello World   '
    TRIM_LEFT_EXPECTED[2] = 'Hello World   '
    TRIM_LEFT_EXPECTED[3] = 'Hello World'
    TRIM_LEFT_EXPECTED[4] = 'Hello World'
    TRIM_LEFT_EXPECTED[5] = ''
    TRIM_LEFT_EXPECTED[6] = ''
    TRIM_LEFT_EXPECTED[7] = ''
    TRIM_LEFT_EXPECTED[8] = ''
    TRIM_LEFT_EXPECTED[9] = ''
    TRIM_LEFT_EXPECTED[10] = 'Hello  World  '
    TRIM_LEFT_EXPECTED[11] = "'Hello', $09"  // Hello + Tab
    TRIM_LEFT_EXPECTED[12] = "'Hello', $0D, $0A, $09"  // Hello + CR + LF + Tab
    set_length_array(TRIM_LEFT_EXPECTED, 12)

    // Initialize TRIM_RIGHT_EXPECTED array
    TRIM_RIGHT_EXPECTED[1] = '   Hello World'
    TRIM_RIGHT_EXPECTED[2] = 'Hello World'
    TRIM_RIGHT_EXPECTED[3] = '   Hello World'
    TRIM_RIGHT_EXPECTED[4] = 'Hello World'
    TRIM_RIGHT_EXPECTED[5] = ''
    TRIM_RIGHT_EXPECTED[6] = ''
    TRIM_RIGHT_EXPECTED[7] = ''
    TRIM_RIGHT_EXPECTED[8] = ''
    TRIM_RIGHT_EXPECTED[9] = ''
    TRIM_RIGHT_EXPECTED[10] = '  Hello  World'
    TRIM_RIGHT_EXPECTED[11] = "$09, 'Hello'"  // Tab + Hello
    TRIM_RIGHT_EXPECTED[12] = "$09, $0D, $0A, 'Hello'"  // Tab + CR + LF + Hello
    set_length_array(TRIM_RIGHT_EXPECTED, 12)

    // Initialize TRIM_BOTH_EXPECTED array
    TRIM_BOTH_EXPECTED[1] = 'Hello World'
    TRIM_BOTH_EXPECTED[2] = 'Hello World'
    TRIM_BOTH_EXPECTED[3] = 'Hello World'
    TRIM_BOTH_EXPECTED[4] = 'Hello World'
    TRIM_BOTH_EXPECTED[5] = ''
    TRIM_BOTH_EXPECTED[6] = ''
    TRIM_BOTH_EXPECTED[7] = ''
    TRIM_BOTH_EXPECTED[8] = ''
    TRIM_BOTH_EXPECTED[9] = ''
    TRIM_BOTH_EXPECTED[10] = 'Hello  World'
    TRIM_BOTH_EXPECTED[11] = 'Hello'
    TRIM_BOTH_EXPECTED[12] = 'Hello'
    set_length_array(TRIM_BOTH_EXPECTED, 12)

    TRIM_ARRAY_TEST[1][1] = '  leading spaces'
    TRIM_ARRAY_TEST[1][2] = 'trailing spaces  '
    TRIM_ARRAY_TEST[1][3] = '  both sides  '
    TRIM_ARRAY_TEST[1][4] = 'no spaces'
    set_length_array(TRIM_ARRAY_TEST[1], 4)

    TRIM_ARRAY_EXPECTED[1][1] = 'leading spaces'
    TRIM_ARRAY_EXPECTED[1][2] = 'trailing spaces'
    TRIM_ARRAY_EXPECTED[1][3] = 'both sides'
    TRIM_ARRAY_EXPECTED[1][4] = 'no spaces'
    set_length_array(TRIM_ARRAY_EXPECTED[1], 4)

    TRIM_ARRAY_TEST[2][1] = '   multiple   spaces   '
    TRIM_ARRAY_TEST[2][2] = "$09, ' test'"  // TAB + space + test
    TRIM_ARRAY_TEST[2][3] = "$0D, $0A, ' test'"  // CR + LF + space + test
    TRIM_ARRAY_TEST[2][4] = "$09, $0D, $0A, ' mixed ', $09, $0D, $0A, ' whitespace ', $09, $0D, $0A"
    set_length_array(TRIM_ARRAY_TEST[2], 4)

    TRIM_ARRAY_EXPECTED[2][1] = 'multiple   spaces'
    TRIM_ARRAY_EXPECTED[2][2] = 'test'
    TRIM_ARRAY_EXPECTED[2][3] = 'test'
    TRIM_ARRAY_EXPECTED[2][4] = "'mixed ', $09, $0D, $0A, ' whitespace'"
    set_length_array(TRIM_ARRAY_EXPECTED[2], 4)

    TRIM_ARRAY_TEST[3][1] = ''
    TRIM_ARRAY_TEST[3][2] = "$09, $0D, $0A, '   ', $09, $0D, $0A"  // All whitespace
    TRIM_ARRAY_TEST[3][3] = 'single'
    TRIM_ARRAY_TEST[3][4] = "$09, '  double  ', $0A"  // TAB + spaces + double + spaces + LF
    set_length_array(TRIM_ARRAY_TEST[3], 4)

    TRIM_ARRAY_EXPECTED[3][1] = ''
    TRIM_ARRAY_EXPECTED[3][2] = ''
    TRIM_ARRAY_EXPECTED[3][3] = 'single'
    TRIM_ARRAY_EXPECTED[3][4] = 'double'
    set_length_array(TRIM_ARRAY_EXPECTED[3], 4)

    TRIM_ARRAY_TEST[4][1] = "$09, $0D, $0A, ' leading ', $09, $0D, $0A, ' spaces ', $09, $0D, $0A"
    TRIM_ARRAY_TEST[4][2] = "'trailing ', $09, $0D, $0A, ' spaces ', $09, $0D, $0A"
    TRIM_ARRAY_TEST[4][3] = "$09, $0D, $0A, ' both ', $09, $0D, $0A, ' sides ', $09, $0D, $0A"
    TRIM_ARRAY_TEST[4][4] = "'no', $09, $0D, $0A, ' spaces'"
    set_length_array(TRIM_ARRAY_TEST[4], 4)

    TRIM_ARRAY_EXPECTED[4][1] = "'leading ', $09, $0D, $0A, ' spaces'"
    TRIM_ARRAY_EXPECTED[4][2] = "'trailing ', $09, $0D, $0A, ' spaces'"
    TRIM_ARRAY_EXPECTED[4][3] = "'both ', $09, $0D, $0A, ' sides'"
    TRIM_ARRAY_EXPECTED[4][4] = "'no', $09, $0D, $0A, ' spaces'"
    set_length_array(TRIM_ARRAY_EXPECTED[4], 4)

    set_length_array(TRIM_ARRAY_TEST, 4)
    set_length_array(TRIM_ARRAY_EXPECTED, 4)
}

define_function TestNAVTrimStringLeft() {
    stack_var integer i

    NAVLog("'***************** NAVTrimStringLeft *****************'")
    InitializeTrimTestData()

    for (i = 1; i <= length_array(TRIM_TEST); i++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = TRIM_LEFT_EXPECTED[i]
        result = NAVTrimStringLeft(TRIM_TEST[i])

        if (!NAVAssertStringEqual('Trim Left Test', expected, result)) {
            NAVLogTestFailed(i, expected, result)
            continue
        }

        NAVLogTestPassed(i)
    }
}

define_function TestNAVTrimStringRight() {
    stack_var integer i

    NAVLog("'***************** NAVTrimStringRight *****************'")
    InitializeTrimTestData()

    for (i = 1; i <= length_array(TRIM_TEST); i++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = TRIM_RIGHT_EXPECTED[i]
        result = NAVTrimStringRight(TRIM_TEST[i])

        if (!NAVAssertStringEqual('Trim Right Test', expected, result)) {
            NAVLogTestFailed(i, expected, result)
            continue
        }

        NAVLogTestPassed(i)
    }
}

define_function TestNAVTrimString() {
    stack_var integer i

    NAVLog("'***************** NAVTrimString *****************'")
    InitializeTrimTestData()

    for (i = 1; i <= length_array(TRIM_TEST); i++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = TRIM_BOTH_EXPECTED[i]
        result = NAVTrimString(TRIM_TEST[i])

        if (!NAVAssertStringEqual('Trim String Test', expected, result)) {
            NAVLogTestFailed(i, expected, result)
            continue
        }

        NAVLogTestPassed(i)
    }
}

define_function TestNAVTrimStringArray() {
    stack_var integer i
    stack_var integer j

    NAVLog("'***************** NAVTrimStringArray *****************'")
    InitializeTrimTestData()

    for (i = 1; i <= length_array(TRIM_ARRAY_TEST); i++) {
        NAVTrimStringArray(TRIM_ARRAY_TEST[i])

        for (j = 1; j <= length_array(TRIM_ARRAY_TEST[i]); j++) {
            if (!NAVAssertStringEqual('Trim Array Test', TRIM_ARRAY_EXPECTED[i][j], TRIM_ARRAY_TEST[i][j])) {
                NAVLogTestFailed((i-1)*length_array(TRIM_ARRAY_TEST[i])+j, TRIM_ARRAY_EXPECTED[i][j], TRIM_ARRAY_TEST[i][j])
            } else {
                NAVLogTestPassed((i-1)*length_array(TRIM_ARRAY_TEST[i])+j)
            }
        }
    }
}
