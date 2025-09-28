PROGRAM_NAME='NAVStripFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char STRIP_TEST[][NAV_MAX_BUFFER] = {
    'Hello World',
    'Testing123',
    'AMX NetLinx',
    '',
    'A',
    'ABCDEFG'
}

constant integer STRIP_COUNTS[] = {
    0,
    1,
    3,
    5,
    10
}

// Expected results for NAVStripCharsFromRight
constant char STRIP_RIGHT_EXPECTED[][][NAV_MAX_BUFFER] = {
    { 'Hello World', 'Hello Worl', 'Hello Wo', 'Hello ', 'H' },            // "Hello World" (11 chars) - count 10 leaves 1 char
    { 'Testing123', 'Testing12', 'Testing', 'Testi', '' },                 // "Testing123" (10 chars) - count 10 >= length returns empty
    { 'AMX NetLinx', 'AMX NetLin', 'AMX NetL', 'AMX Ne', 'A' },            // "AMX NetLinx" (11 chars) - count 10 leaves 1 char
    { '', '', '', '', '' },                                                 // "" with counts 0,1,3,5,10
    { 'A', '', '', '', '' },                                               // "A" - any count >= 1 returns empty
    { 'ABCDEFG', 'ABCDEF', 'ABCD', 'AB', '' }                              // "ABCDEFG" (7 chars) - count 10 >= length returns empty
}

// Expected results for NAVStripCharsFromLeft
constant char STRIP_LEFT_EXPECTED[][][NAV_MAX_BUFFER] = {
    { 'Hello World', 'ello World', 'lo World', ' World', 'd' },             // "Hello World" (11 chars) - count 10 leaves 1 char
    { 'Testing123', 'esting123', 'ting123', 'ng123', '' },                 // "Testing123" (10 chars) - count 10 >= length returns empty
    { 'AMX NetLinx', 'MX NetLinx', ' NetLinx', 'etLinx', 'x' },             // "AMX NetLinx" (11 chars) - count 10 leaves 1 char
    { '', '', '', '', '' },                                                 // "" with counts 0,1,3,5,10
    { 'A', '', '', '', '' },                                               // "A" - any count >= 1 returns empty
    { 'ABCDEFG', 'BCDEFG', 'DEFG', 'FG', '' }                              // "ABCDEFG" (7 chars) - count 10 >= length returns empty
}

// Test data for NAVRemoveStringByLength
constant char REMOVE_BY_LENGTH_TEST[][NAV_MAX_BUFFER] = {
    'Hello World',
    'NAVFoundation',
    'AMX NetLinx',
    '',
    'A'
}

constant integer REMOVE_COUNTS[] = {
    0,
    1,
    3,
    5,
    10,
    20
}

// Expected results for NAVRemoveStringByLength - RETURNS THE REMOVED CHARACTERS
constant char REMOVE_BY_LENGTH_EXPECTED[][][NAV_MAX_BUFFER] = {
    { '', 'H', 'Hel', 'Hello', 'Hello Worl', 'Hello World' },            // "Hello World" - returns removed chars
    { '', 'N', 'NAV', 'NAVFo', 'NAVFoundat', 'NAVFoundation' },          // "NAVFoundation" - returns removed chars
    { '', 'A', 'AMX', 'AMX N', 'AMX NetLin', 'AMX NetLinx' },            // "AMX NetLinx" - returns removed chars
    { '', '', '', '', '', '' },                                         // "" - empty cases
    { '', 'A', 'A', 'A', 'A', 'A' }                                      // "A" - returns removed chars or full string
}

// Expected remaining buffer after NAVRemoveStringByLength mutation
constant char REMOVE_BY_LENGTH_EXPECTED_REMAINING[][][NAV_MAX_BUFFER] = {
    { 'Hello World', 'ello World', 'lo World', ' World', 'd', '' },            // "Hello World" - remaining after removal
    { 'NAVFoundation', 'AVFoundation', 'Foundation', 'undation', 'ion', '' }, // "NAVFoundation" - remaining after removal
    { 'AMX NetLinx', 'MX NetLinx', ' NetLinx', 'etLinx', 'x', '' },            // "AMX NetLinx" - remaining after removal
    { '', '', '', '', '', '' },                                                // "" - empty cases
    { 'A', '', '', '', '', '' }                                                // "A" - remaining after removal
}

define_function TestNAVStripCharsFromRight() {
    stack_var integer i, j

    NAVLog("'***************** NAVStripCharsFromRight *****************'")

    for (i = 1; i <= length_array(STRIP_TEST); i++) {
        for (j = 1; j <= length_array(STRIP_COUNTS); j++) {
            stack_var char expected[NAV_MAX_BUFFER]
            stack_var char result[NAV_MAX_BUFFER]

            expected = STRIP_RIGHT_EXPECTED[i][j]
            result = NAVStripCharsFromRight(STRIP_TEST[i], STRIP_COUNTS[j])

            if (!NAVAssertStringEqual('Strip Right Test', expected, result)) {
                NAVLogTestFailed((i-1)*length_array(STRIP_COUNTS)+j, expected, result)
                continue
            }

            NAVLogTestPassed((i-1)*length_array(STRIP_COUNTS)+j)
        }
    }

    // Test the alias function
    NAVLog("'***************** NAVStripRight (Alias) *****************'")
    {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = NAVStripCharsFromRight('Test Alias', 2)
        result = NAVStripRight('Test Alias', 2)

        if (!NAVAssertStringEqual('Strip Right Alias Test', expected, result)) {
            NAVLogTestFailed(1, expected, result)
        }
        else {
            NAVLogTestPassed(1)
        }
    }
}

define_function TestNAVStripCharsFromLeft() {
    stack_var integer i, j

    NAVLog("'***************** NAVStripCharsFromLeft *****************'")

    for (i = 1; i <= length_array(STRIP_TEST); i++) {
        for (j = 1; j <= length_array(STRIP_COUNTS); j++) {
            stack_var char expected[NAV_MAX_BUFFER]
            stack_var char result[NAV_MAX_BUFFER]

            expected = STRIP_LEFT_EXPECTED[i][j]
            result = NAVStripCharsFromLeft(STRIP_TEST[i], STRIP_COUNTS[j])

            if (!NAVAssertStringEqual('Strip Left Test', expected, result)) {
                NAVLogTestFailed((i-1)*length_array(STRIP_COUNTS)+j, expected, result)
                continue
            }

            NAVLogTestPassed((i-1)*length_array(STRIP_COUNTS)+j)
        }
    }

    // Test the alias function
    NAVLog("'***************** NAVStripLeft (Alias) *****************'")
    {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = NAVStripCharsFromLeft('Test Alias', 2)
        result = NAVStripLeft('Test Alias', 2)

        if (!NAVAssertStringEqual('Strip Left Alias Test', expected, result)) {
            NAVLogTestFailed(1, expected, result)
        }
        else {
            NAVLogTestPassed(1)
        }
    }
}

define_function TestNAVRemoveStringByLength() {
    stack_var integer i, j

    NAVLog("'***************** NAVRemoveStringByLength *****************'")

    for (i = 1; i <= length_array(REMOVE_BY_LENGTH_TEST); i++) {
        for (j = 1; j <= length_array(REMOVE_COUNTS); j++) {
            stack_var char buffer[NAV_MAX_BUFFER]
            stack_var char result[NAV_MAX_BUFFER]
            stack_var integer testNumber
            stack_var integer originalLength
            stack_var integer expectedResultLength
            stack_var integer expectedBufferLength

            testNumber = (i-1)*length_array(REMOVE_COUNTS)+j

            // Use a code copy of the test string to avoid mutating the original
            buffer = REMOVE_BY_LENGTH_TEST[i]
            originalLength = length_array(buffer)
            result = NAVRemoveStringByLength(buffer, REMOVE_COUNTS[j])

            // Calculate expected lengths
            if (REMOVE_COUNTS[j] <= originalLength) {
                expectedResultLength = REMOVE_COUNTS[j]
            }
            else {
                expectedResultLength = originalLength
            }

            if (REMOVE_COUNTS[j] < originalLength) {
                expectedBufferLength = originalLength - REMOVE_COUNTS[j]
            }
            else {
                expectedBufferLength = 0
            }

            // Check return value (removed characters)
            if (!NAVAssertStringEqual('Remove By Length Test Return', REMOVE_BY_LENGTH_EXPECTED[i][j], result)) {
                NAVLogTestFailed(testNumber, REMOVE_BY_LENGTH_EXPECTED[i][j], result)
                continue
            }

            // Check return value length
            if (length_array(result) != expectedResultLength) {
                NAVLogTestFailed(testNumber, "'Expected result length ', itoa(expectedResultLength)", "'Got result length ', itoa(length_array(result))")
                continue
            }

            // Check mutated buffer (remaining characters)
            if (!NAVAssertStringEqual('Remove By Length Test Buffer', REMOVE_BY_LENGTH_EXPECTED_REMAINING[i][j], buffer)) {
                NAVLogTestFailed(testNumber, REMOVE_BY_LENGTH_EXPECTED_REMAINING[i][j], buffer)
                continue
            }

            // Check mutated buffer length
            if (length_array(buffer) != expectedBufferLength) {
                NAVLogTestFailed(testNumber, "'Expected buffer length ', itoa(expectedBufferLength)", "'Got buffer length ', itoa(length_array(buffer))")
                continue
            }

            NAVLogTestPassed(testNumber)
        }
    }
}
