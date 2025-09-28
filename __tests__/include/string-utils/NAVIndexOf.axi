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
