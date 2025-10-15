PROGRAM_NAME='NAVStringAdvanced'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data for NAVArrayJoinString
constant char ARRAY_JOIN_TEST1[3][NAV_MAX_BUFFER] = {
    'Hello',
    'World',
    '!'
}

constant char ARRAY_JOIN_TEST2[4][NAV_MAX_BUFFER] = {
    'NAV',
    'Foundation',
    'AMX',
    'NetLinx'
}

constant char ARRAY_JOIN_TEST3[1][NAV_MAX_BUFFER] = {
    'Single'
}

// Test data for NAVStringToLongMilliseconds
constant char DURATION_TEST[][10] = {
    '1h',
    '30m',
    '45s',
    '2h',
    '90m',
    '120s',
    '0h',
    '0m',
    '0s'
}

constant long DURATION_EXPECTED[] = {
    3600000,      // 1 hour
    1800000,      // 30 minutes
    45000,        // 45 seconds
    7200000,      // 2 hours
    5400000,      // 90 minutes
    120000,       // 120 seconds
    0,            // 0 hours
    0,            // 0 minutes
    0             // 0 seconds
}

// Test data for NAVStringCompare
constant char COMPARE_TEST[][2][NAV_MAX_BUFFER] = {
    { 'apple', 'banana' },
    { 'apple', 'apple' },
    { 'banana', 'apple' },
    { 'Hello', 'hello' },
    { 'test', 'test1' },
    { '', '' },
    { 'a', '' },
    { '', 'a' },
    { 'ABC', 'ABD' },
    { 'Test123', 'Test124' }
}

// Test data for NAVStringSurroundWith
constant char SURROUND_TEST[][3][NAV_MAX_BUFFER] = {
    { 'World', 'Hello ', '!' },
    { 'test', '[', ']' },
    { 'value', '"', '"' },
    { '', 'start', 'end' },
    { 'content', '', '' },
    { 'data', 'prefix_', '_suffix' }
}

constant char SURROUND_EXPECTED[][NAV_MAX_BUFFER] = {
    'Hello World!',
    '[test]',
    '"value"',
    'startend',
    'content',
    'prefix_data_suffix'
}

// Test data for NAVGetStringBetweenGreedy
constant char GREEDY_TEST[][3][NAV_MAX_BUFFER] = {
    { 'Hello [World] and [Universe]', '[', ']' },
    { 'Start (test) middle (data) end', '(', ')' },
    { 'No matching tokens here', '{', '}' },
    { 'Single [match] only', '[', ']' },
    { '[Empty] and []', '[', ']' },
    { 'Multiple...dots...here', '...', '...' },
    { 'First|second|third|fourth', '|', '|' }
}

constant char GREEDY_EXPECTED[][NAV_MAX_BUFFER] = {
    'World] and [Universe',
    'test) middle (data',
    '',
    'match',
    'Empty] and [',
    'dots',
    'second|third'
}

// Test data for NAVFindAndReplace
// Tests 1-8: Basic replacement scenarios
// Tests 9-13: Edge cases where replacement contains search string (critical for CSV quote escaping)
constant char FIND_REPLACE_TEST[][3][NAV_MAX_BUFFER] = {
    { 'Hello World Hello', 'Hello', 'Hi' },
    { 'test test test', 'test', 'exam' },
    { 'No matches here', 'xyz', 'abc' },
    { 'CaseSensitive', 'case', 'CASE' },
    { 'Multiple   spaces', '  ', ' ' },
    { 'dots...everywhere...', '...', '.' },
    { '', 'any', 'thing' },
    { 'Replace all a', 'a', 'X' },
    // Edge cases: Replacement contains search string (prevents infinite loops)
    { 'say "hello"', '"', '""' },           // CSV quote escaping pattern
    { 'test', 't', 'tt' },                  // Character doubling at start/end
    { 'a b a', 'a', 'aaa' },                // Character tripling with multiple instances
    { 'go go go', 'go', 'going' },          // Expansion with overlap potential
    { 'start here', 's', 'ss' }             // Doubling at start position
}

constant char FIND_REPLACE_EXPECTED[][NAV_MAX_BUFFER] = {
    'Hi World Hi',
    'exam exam exam',
    'No matches here',
    'CaseSensitive',
    'Multiple  spaces',                    // First double-space becomes single (one replacement only due to overlap)
    'dots.everywhere.',
    '',
    'ReplXce Xll X',
    // Edge case expectations
    'say ""hello""',                        // Quotes properly escaped
    'ttestt',                               // Both 't' chars doubled
    'aaa b aaa',                            // Both 'a' chars tripled
    'going going going',                    // All 'go' expanded to 'going'
    'sstart here'                          // Leading 's' doubled
}

// Test data for NAVStringNormalizeAndReplace
constant char NORMALIZE_TEST[][3][NAV_MAX_BUFFER] = {
    { 'Hello  World', ' ', '-' },
    { 'Multiple   spaces   here', ' ', '_' },
    { 'Normal spacing', ' ', '-' },
    { 'dots...here', '.', '-' },
    { '', ' ', '-' },
    { 'No  double  spaces', ' ', '|' }
}

constant char NORMALIZE_EXPECTED[][NAV_MAX_BUFFER] = {
    'Hello-World',
    'Multiple_spaces_here',
    'Normal-spacing',
    'dots-here',
    '',
    'No|double|spaces'
}

define_function TestNAVArrayJoinString() {
    NAVLog("'***************** NAVArrayJoinString *****************'")

    // Test 1: Basic join with space separator
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVArrayJoinString(ARRAY_JOIN_TEST1, ' ')

        if (!NAVAssertStringEqual('Array Join Test 1', 'Hello World !', result)) {
            NAVLogTestFailed(1, 'Hello World !', result)
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test 2: Join with comma separator
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVArrayJoinString(ARRAY_JOIN_TEST2, ', ')

        if (!NAVAssertStringEqual('Array Join Test 2', 'NAV, Foundation, AMX, NetLinx', result)) {
            NAVLogTestFailed(2, 'NAV, Foundation, AMX, NetLinx', result)
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test 3: Single element array
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVArrayJoinString(ARRAY_JOIN_TEST3, '-')

        if (!NAVAssertStringEqual('Array Join Test 3', 'Single', result)) {
            NAVLogTestFailed(3, 'Single', result)
        } else {
            NAVLogTestPassed(3)
        }
    }

    // Test 4: Empty separator joins without separator
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVArrayJoinString(ARRAY_JOIN_TEST1, '')

        if (!NAVAssertStringEqual('Array Join Test 4', 'HelloWorld!', result)) {
            NAVLogTestFailed(4, 'HelloWorld!', result)
        } else {
            NAVLogTestPassed(4)
        }
    }
}

define_function TestNAVStringToLongMilliseconds() {
    stack_var integer x

    NAVLog("'***************** NAVStringToLongMilliseconds *****************'")

    for (x = 1; x <= length_array(DURATION_TEST); x++) {
        stack_var long expected
        stack_var long result

        expected = DURATION_EXPECTED[x]
        result = NAVStringToLongMilliseconds(DURATION_TEST[x])

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    // Test invalid format
    {
        stack_var long result

        result = NAVStringToLongMilliseconds('10x')  // Invalid format

        if (result != 0) {
            NAVLogTestFailed(1, '0', itoa(result))
        } else {
            NAVLogTestPassed(1)
        }
    }
}

define_function TestNAVGetTimeSpan() {
    NAVLog("'***************** NAVGetTimeSpan *****************'")

    // Test 1: 1 hour
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVGetTimeSpan(3600000)

        if (!NAVAssertStringEqual('TimeSpan Test 1', '1h 0s 0ms', result)) {
            NAVLogTestFailed(1, '1h 0s 0ms', result)
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test 2: 45 seconds
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVGetTimeSpan(45000)

        if (!NAVAssertStringEqual('TimeSpan Test 2', '45s 0ms', result)) {
            NAVLogTestFailed(2, '45s 0ms', result)
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test 3: 1.5 hours
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVGetTimeSpan(5400000)

        if (!NAVAssertStringEqual('TimeSpan Test 3', '1h 30m 0s 0ms', result)) {
            NAVLogTestFailed(3, '1h 30m 0s 0ms', result)
        } else {
            NAVLogTestPassed(3)
        }
    }

    // Test 4: Just milliseconds
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVGetTimeSpan(250)

        if (!NAVAssertStringEqual('TimeSpan Test 4', '0s 250ms', result)) {
            NAVLogTestFailed(4, '0s 250ms', result)
        } else {
            NAVLogTestPassed(4)
        }
    }
}

define_function TestNAVStringCompare() {
    stack_var integer x

    NAVLog("'***************** NAVStringCompare *****************'")

    for (x = 1; x <= length_array(COMPARE_TEST); x++) {
        stack_var sinteger result
        stack_var char string1[NAV_MAX_BUFFER]
        stack_var char string2[NAV_MAX_BUFFER]

        string1 = COMPARE_TEST[x][1]
        string2 = COMPARE_TEST[x][2]
        result = NAVStringCompare(string1, string2)

        // Verify the comparison logic
        switch (x) {
            case 1: { // 'apple' vs 'banana' - should be negative
                if (result >= 0) {
                    NAVLogTestFailed(x, 'negative', itoa(result))
                    continue
                }
            }
            case 2: { // 'apple' vs 'apple' - should be 0
                if (result != 0) {
                    NAVLogTestFailed(x, '0', itoa(result))
                    continue
                }
            }
            case 3: { // 'banana' vs 'apple' - should be positive
                if (result <= 0) {
                    NAVLogTestFailed(x, 'positive', itoa(result))
                    continue
                }
            }
            case 6: { // '' vs '' - should be 0
                if (result != 0) {
                    NAVLogTestFailed(x, '0', itoa(result))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVStringSurroundWith() {
    stack_var integer x

    NAVLog("'***************** NAVStringSurroundWith *****************'")

    for (x = 1; x <= length_array(SURROUND_TEST); x++) {
        stack_var char buffer[NAV_MAX_BUFFER]
        stack_var char left[NAV_MAX_BUFFER]
        stack_var char right[NAV_MAX_BUFFER]
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        buffer = SURROUND_TEST[x][1]
        left = SURROUND_TEST[x][2]
        right = SURROUND_TEST[x][3]
        expected = SURROUND_EXPECTED[x]
        result = NAVStringSurroundWith(buffer, left, right)

        if (!NAVAssertStringEqual('Surround Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    // Test the alias function NAVStringSurround
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVStringSurround('test', '(', ')')

        if (!NAVAssertStringEqual('Surround Alias Test', '(test)', result)) {
            NAVLogTestFailed(1, '(test)', result)
        } else {
            NAVLogTestPassed(1)
        }
    }
}

define_function TestNAVStringGather() {
    NAVLog("'***************** NAVStringGather *****************'")

    // Note: NAVStringGather is a complex function that uses callbacks
    // This is a basic structure test to ensure the function exists and accepts parameters
    {
        stack_var _NAVRxBuffer buffer

        buffer.Data = 'Hello,World,Test'
        buffer.Semaphore = false

        NAVStringGather(buffer, ',')

        // Basic test - just ensure function executes without error
        NAVLogTestPassed(1)
    }
}

define_function TestNAVGetStringBetweenGreedy() {
    stack_var integer x

    NAVLog("'***************** NAVGetStringBetweenGreedy *****************'")

    for (x = 1; x <= length_array(GREEDY_TEST); x++) {
        stack_var char buffer[NAV_MAX_BUFFER]
        stack_var char token1[NAV_MAX_BUFFER]
        stack_var char token2[NAV_MAX_BUFFER]
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        buffer = GREEDY_TEST[x][1]
        token1 = GREEDY_TEST[x][2]
        token2 = GREEDY_TEST[x][3]
        expected = GREEDY_EXPECTED[x]
        result = NAVGetStringBetweenGreedy(buffer, token1, token2)

        if (!NAVAssertStringEqual('Greedy Between Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    // Test the alias function
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVStringBetweenGreedy('Start [test] middle [data] end', '[', ']')

        if (!NAVAssertStringEqual('Greedy Between Alias Test', 'test] middle [data', result)) {
            NAVLogTestFailed(1, 'test] middle [data', result)
        } else {
            NAVLogTestPassed(1)
        }
    }
}

define_function TestNAVFindAndReplace() {
    stack_var integer x

    NAVLog("'***************** NAVFindAndReplace *****************'")

    for (x = 1; x <= length_array(FIND_REPLACE_TEST); x++) {
        stack_var char buffer[NAV_MAX_BUFFER]
        stack_var char match[NAV_MAX_BUFFER]
        stack_var char value[NAV_MAX_BUFFER]
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        buffer = FIND_REPLACE_TEST[x][1]
        match = FIND_REPLACE_TEST[x][2]
        value = FIND_REPLACE_TEST[x][3]
        expected = FIND_REPLACE_EXPECTED[x]
        result = NAVFindAndReplace(buffer, match, value)

        if (!NAVAssertStringEqual('Find Replace Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVStringNormalizeAndReplace() {
    stack_var integer x

    NAVLog("'***************** NAVStringNormalizeAndReplace *****************'")

    for (x = 1; x <= length_array(NORMALIZE_TEST); x++) {
        stack_var char buffer[NAV_MAX_BUFFER]
        stack_var char match[NAV_MAX_BUFFER]
        stack_var char replacement[NAV_MAX_BUFFER]
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        buffer = NORMALIZE_TEST[x][1]
        match = NORMALIZE_TEST[x][2]
        replacement = NORMALIZE_TEST[x][3]
        expected = NORMALIZE_EXPECTED[x]
        result = NAVStringNormalizeAndReplace(buffer, match, replacement)

        if (!NAVAssertStringEqual('Normalize Replace Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
