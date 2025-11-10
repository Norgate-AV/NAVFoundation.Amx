PROGRAM_NAME='NAVIndexOf'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char INDEX_OF_SUBJECT[] = 'Hello World Hello Universe'

constant char INDEX_OF_TEST[][2][NAV_MAX_BUFFER] = {
    // {substring, start position}
    { 'l', '1' },
    { 'l', '4' },
    { 'o', '1' },
    { 'o', '6' },
    { 'World', '1' },
    { 'Hello', '1' },
    { 'Hello', '7' },
    { 'Universe', '1' },
    { 'xyz', '1' },
    { '', '1' }
}

constant integer INDEX_OF_EXPECTED[] = {
    3,   // 'l' from position 1
    4,   // 'l' from position 4
    5,   // 'o' from position 1
    8,   // 'o' from position 6
    7,   // 'World' from position 1
    1,   // 'Hello' from position 1
    13,  // 'Hello' from position 7
    19,  // 'Universe' from position 1
    0,   // 'xyz' from position 1 (not found)
    0    // '' from position 1 (empty string)
}

// Test data for NAVLastIndexOf
constant char LAST_INDEX_TEST[][NAV_MAX_BUFFER] = {
    'l',
    'o',
    'Hello',
    'World',
    'e',
    'xyz',
    ''
}

constant integer LAST_INDEX_EXPECTED[] = {
    16,  // last 'l'
    17,  // last 'o'
    13,  // last 'Hello'
    7,   // 'World' (only one occurrence)
    26,  // last 'e'
    0,   // 'xyz' (not found)
    0    // '' (empty string)
}

// Test data for NAVIndexOfCaseInsensitive
constant char INDEX_OF_CI_SUBJECT[] = 'Hello World HELLO Universe'

constant char INDEX_OF_CI_TEST[][2][NAV_MAX_BUFFER] = {
    // {substring, start position}
    { 'hello', '1' },
    { 'HELLO', '1' },
    { 'HeLLo', '1' },
    { 'hello', '7' },
    { 'WORLD', '1' },
    { 'world', '1' },
    { 'WoRlD', '1' },
    { 'universe', '1' },
    { 'UNIVERSE', '1' },
    { 'L', '1' },
    { 'l', '1' },
    { 'L', '4' },
    { 'xyz', '1' },
    { '', '1' }
}

constant integer INDEX_OF_CI_EXPECTED[] = {
    1,   // 'hello' from position 1 (matches 'Hello')
    1,   // 'HELLO' from position 1 (matches 'Hello')
    1,   // 'HeLLo' from position 1 (matches 'Hello')
    13,  // 'hello' from position 7 (matches 'HELLO')
    7,   // 'WORLD' from position 1 (matches 'World')
    7,   // 'world' from position 1 (matches 'World')
    7,   // 'WoRlD' from position 1 (matches 'World')
    19,  // 'universe' from position 1 (matches 'Universe')
    19,  // 'UNIVERSE' from position 1 (matches 'Universe')
    3,   // 'L' from position 1 (matches 'l' in 'Hello')
    3,   // 'l' from position 1 (matches 'l' in 'Hello')
    4,   // 'L' from position 4 (matches second 'l' in 'Hello')
    0,   // 'xyz' from position 1 (not found)
    0    // '' from position 1 (empty string)
}

// Test data for NAVLastIndexOfCaseInsensitive
constant char LAST_INDEX_CI_TEST[][NAV_MAX_BUFFER] = {
    'hello',
    'HELLO',
    'HeLLo',
    'world',
    'WORLD',
    'universe',
    'L',
    'l',
    'O',
    'o',
    'E',
    'e',
    'xyz',
    ''
}

constant integer LAST_INDEX_CI_EXPECTED[] = {
    13,  // last 'hello' (matches 'HELLO')
    13,  // last 'HELLO' (matches 'HELLO')
    13,  // last 'HeLLo' (matches 'HELLO')
    7,   // 'world' (matches 'World', only occurrence)
    7,   // 'WORLD' (matches 'World', only occurrence)
    19,  // 'universe' (matches 'Universe')
    16,  // last 'L' (matches 'l' in second 'HELLO')
    16,  // last 'l' (matches 'l' in second 'HELLO')
    17,  // last 'O' (matches 'o' in 'World')
    17,  // last 'o' (matches 'o' in 'World')
    26,  // last 'E' (matches 'e' in 'Universe')
    26,  // last 'e' (matches 'e' in 'Universe')
    0,   // 'xyz' (not found)
    0    // '' (empty string)
}

define_function TestNAVIndexOf() {
    stack_var integer x

    NAVLog("'***************** NAVIndexOf *****************'")

    for (x = 1; x <= length_array(INDEX_OF_TEST); x++) {
        stack_var char substring[NAV_MAX_BUFFER]
        stack_var integer startPos
        stack_var integer expected
        stack_var integer result

        substring = INDEX_OF_TEST[x][1]
        startPos = atoi(INDEX_OF_TEST[x][2])
        expected = INDEX_OF_EXPECTED[x]
        result = NAVIndexOf(INDEX_OF_SUBJECT, substring, startPos)

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    // Test edge cases
    NAVLog("'Testing edge cases...'")

    // Test with start position out of bounds
    {
        stack_var integer result

        result = NAVIndexOf(INDEX_OF_SUBJECT, 'Hello', 100)

        if (result != 0) {
            NAVLogTestFailed(1, '0', itoa(result))
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test with start position 0
    {
        stack_var integer result

        result = NAVIndexOf(INDEX_OF_SUBJECT, 'Hello', 0)

        if (result != 0) {
            NAVLogTestFailed(2, '0', itoa(result))
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test with negative start position
    // {
    //     stack_var integer result

    //     result = NAVIndexOf(INDEX_OF_SUBJECT, 'Hello', -1)

    //     if (result != 0) {
    //         NAVLog("'Edge case test 3 failed: Negative start position'")
    //     } else {
    //         NAVLog("'Edge case test 3 passed'")
    //     }
    // }
}

define_function TestNAVLastIndexOf() {
    stack_var integer x

    NAVLog("'***************** NAVLastIndexOf *****************'")

    for (x = 1; x <= length_array(LAST_INDEX_TEST); x++) {
        stack_var char substring[NAV_MAX_BUFFER]
        stack_var integer expected
        stack_var integer result

        substring = LAST_INDEX_TEST[x]
        expected = LAST_INDEX_EXPECTED[x]
        result = NAVLastIndexOf(INDEX_OF_SUBJECT, substring)

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    // Test edge cases
    NAVLog("'Testing edge cases...'")

    // Test with empty string
    {
        stack_var integer result

        result = NAVLastIndexOf('', 'test')

        if (result != 0) {
            NAVLogTestFailed(1, '0', itoa(result))
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test single character string
    {
        stack_var integer result

        result = NAVLastIndexOf('A', 'A')

        if (result != 1) {
            NAVLogTestFailed(2, '1', itoa(result))
        } else {
            NAVLogTestPassed(2)
        }
    }
}

define_function TestNAVIndexOfCaseInsensitive() {
    stack_var integer x

    NAVLog("'***************** NAVIndexOfCaseInsensitive *****************'")

    for (x = 1; x <= length_array(INDEX_OF_CI_TEST); x++) {
        stack_var char substring[NAV_MAX_BUFFER]
        stack_var integer startPos
        stack_var integer expected
        stack_var integer result

        substring = INDEX_OF_CI_TEST[x][1]
        startPos = atoi(INDEX_OF_CI_TEST[x][2])
        expected = INDEX_OF_CI_EXPECTED[x]
        result = NAVIndexOfCaseInsensitive(INDEX_OF_CI_SUBJECT, substring, startPos)

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    // Test edge cases
    NAVLog("'Testing edge cases...'")

    // Test with start position out of bounds
    {
        stack_var integer result

        result = NAVIndexOfCaseInsensitive(INDEX_OF_CI_SUBJECT, 'HELLO', 100)

        if (result != 0) {
            NAVLogTestFailed(1, '0', itoa(result))
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test with start position 0
    {
        stack_var integer result

        result = NAVIndexOfCaseInsensitive(INDEX_OF_CI_SUBJECT, 'HELLO', 0)

        if (result != 0) {
            NAVLogTestFailed(2, '0', itoa(result))
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test mixed case matching
    {
        stack_var integer result

        result = NAVIndexOfCaseInsensitive('The Quick Brown Fox', 'QUICK', 1)

        if (result != 5) {
            NAVLogTestFailed(3, '5', itoa(result))
        } else {
            NAVLogTestPassed(3)
        }
    }
}

define_function TestNAVLastIndexOfCaseInsensitive() {
    stack_var integer x

    NAVLog("'***************** NAVLastIndexOfCaseInsensitive *****************'")

    for (x = 1; x <= length_array(LAST_INDEX_CI_TEST); x++) {
        stack_var char substring[NAV_MAX_BUFFER]
        stack_var integer expected
        stack_var integer result

        substring = LAST_INDEX_CI_TEST[x]
        expected = LAST_INDEX_CI_EXPECTED[x]
        result = NAVLastIndexOfCaseInsensitive(INDEX_OF_CI_SUBJECT, substring)

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    // Test edge cases
    NAVLog("'Testing edge cases...'")

    // Test with empty string
    {
        stack_var integer result

        result = NAVLastIndexOfCaseInsensitive('', 'TEST')

        if (result != 0) {
            NAVLogTestFailed(1, '0', itoa(result))
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test single character string
    {
        stack_var integer result

        result = NAVLastIndexOfCaseInsensitive('A', 'a')

        if (result != 1) {
            NAVLogTestFailed(2, '1', itoa(result))
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test multiple occurrences with different cases
    {
        stack_var integer result

        result = NAVLastIndexOfCaseInsensitive('Test test TEST', 'test')

        if (result != 11) {
            NAVLogTestFailed(3, '11', itoa(result))
        } else {
            NAVLogTestPassed(3)
        }
    }
}
