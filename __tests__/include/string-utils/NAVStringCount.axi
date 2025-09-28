PROGRAM_NAME='NAVStringCount'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char COUNT_TEST_SUBJECTS[][NAV_MAX_BUFFER] = {
    'Hello World',
    'Hello hello HELLO world',
    'The quick brown fox jumps over the lazy dog',
    'aaabbbccc',
    '',
    'Mississippi'
}

constant char COUNT_TEST_SUBSTRINGS[][NAV_MAX_BUFFER] = {
    'l',
    'o',
    'hello',
    'the',
    'a',
    'i',
    '',
    'xyz'
}

// Expected count with CASE_SENSITIVE matching
constant integer COUNT_SENSITIVE_EXPECTED[][8] = {
    { 3, 2, 0, 0, 0, 0, 0, 0 },  // 'Hello World' case-sensitive counts
    { 5, 3, 1, 0, 0, 0, 0, 0 },  // 'Hello hello HELLO world' case-sensitive counts
    { 1, 4, 0, 1, 1, 1, 0, 0 },  // 'The quick brown fox jumps over the lazy dog' case-sensitive counts
    { 0, 0, 0, 0, 3, 0, 0, 0 },  // 'aaabbbccc' case-sensitive counts
    { 0, 0, 0, 0, 0, 0, 0, 0 },  // '' case-sensitive counts
    { 0, 0, 0, 0, 0, 4, 0, 0 }   // 'Mississippi' case-sensitive counts
}

// Expected count with CASE_INSENSITIVE matching
constant integer COUNT_INSENSITIVE_EXPECTED[][8] = {
    { 3, 2, 1, 0, 0, 0, 0, 0 },  // 'Hello World' case-insensitive counts
    { 7, 4, 3, 0, 0, 0, 0, 0 },  // 'Hello hello HELLO world' case-insensitive counts
    { 1, 4, 0, 2, 1, 1, 0, 0 },  // 'The quick brown fox jumps over the lazy dog' case-insensitive counts
    { 0, 0, 0, 0, 3, 0, 0, 0 },  // 'aaabbbccc' case-insensitive counts
    { 0, 0, 0, 0, 0, 0, 0, 0 },  // '' case-insensitive counts
    { 0, 0, 0, 0, 0, 4, 0, 0 }   // 'Mississippi' case-insensitive counts
}

define_function TestNAVStringCount() {
    stack_var integer i, j

    NAVLog("'***************** NAVStringCount - CASE SENSITIVE *****************'")

    for (i = 1; i <= length_array(COUNT_TEST_SUBJECTS); i++) {
        for (j = 1; j <= length_array(COUNT_TEST_SUBSTRINGS); j++) {
            stack_var integer expected
            stack_var integer result

            expected = COUNT_SENSITIVE_EXPECTED[i][j]
            result = NAVStringCount(COUNT_TEST_SUBJECTS[i], COUNT_TEST_SUBSTRINGS[j], NAV_CASE_SENSITIVE)

            if (result != expected) {
                NAVLogTestFailed((i-1)*length_array(COUNT_TEST_SUBSTRINGS)+j, itoa(expected), itoa(result))
                continue
            }

            NAVLogTestPassed((i-1)*length_array(COUNT_TEST_SUBSTRINGS)+j)
        }
    }

    NAVLog("'***************** NAVStringCount - CASE INSENSITIVE *****************'")

    for (i = 1; i <= length_array(COUNT_TEST_SUBJECTS); i++) {
        for (j = 1; j <= length_array(COUNT_TEST_SUBSTRINGS); j++) {
            stack_var integer expected
            stack_var integer result

            expected = COUNT_INSENSITIVE_EXPECTED[i][j]
            result = NAVStringCount(COUNT_TEST_SUBJECTS[i], COUNT_TEST_SUBSTRINGS[j], NAV_CASE_INSENSITIVE)

            if (result != expected) {
                NAVLogTestFailed((i-1)*length_array(COUNT_TEST_SUBSTRINGS)+j, itoa(expected), itoa(result))
                continue
            }

            NAVLogTestPassed((i-1)*length_array(COUNT_TEST_SUBSTRINGS)+j)
        }
    }
}
