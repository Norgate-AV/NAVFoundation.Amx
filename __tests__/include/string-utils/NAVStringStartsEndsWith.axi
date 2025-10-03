PROGRAM_NAME='NAVStringStartsEndsWith'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char STARTS_ENDS_TEST_SUBJECTS[][NAV_MAX_BUFFER] = {
    'Hello World',
    'AMX NetLinx',
    'NAVFoundation',
    '',
    'A'
}

constant char STARTS_TEST_PREFIXES[][NAV_MAX_BUFFER] = {
    'Hello',
    'Hell',
    'Hello ',
    'World',
    '',
    'A',
    'AMX',
    'NAV'
}

constant char STARTS_WITH_EXPECTED[][8] = {
    { true,  true,  true,  false, true, false, false, false }, // 'Hello World' starts with prefixes
    { false, false, false, false, true, true,  true,  false }, // 'AMX NetLinx' starts with prefixes
    { false, false, false, false, true, false, false, true  }, // 'NAVFoundation' starts with prefixes
    { false, false, false, false, true, false, false, false }, // '' starts with prefixes
    { false, false, false, false, true, true,  false, false }  // 'A' starts with prefixes
}

constant char ENDS_TEST_SUFFIXES[][NAV_MAX_BUFFER] = {
    'World',
    'orld',
    ' World',
    'Hello',
    '',
    'A',
    'NetLinx',
    'Foundation'
}

constant char ENDS_WITH_EXPECTED[][8] = {
    { true,  true,  true,  false, true, false, false, false }, // 'Hello World' ends with suffixes
    { false, false, false, false, true, false, true,  false }, // 'AMX NetLinx' ends with suffixes
    { false, false, false, false, true, false, false, true  }, // 'NAVFoundation' ends with suffixes
    { false, false, false, false, true, false, false, false }, // '' ends with suffixes
    { false, false, false, false, true, true,  false, false }  // 'A' ends with suffixes
}

constant char CONTAINS_TEST_SUBSTRINGS[][NAV_MAX_BUFFER] = {
    'Hello',
    'World',
    ' ',
    'AMX',
    'NetLinx',
    'NAV',
    'Foundation',
    'x',
    '',
    'XYZ'
}

constant char CONTAINS_EXPECTED[][10] = {
    { true,  true,  true,  false, false, false, false, false, true, false }, // 'Hello World' contains substrings
    { false, false, true,  true,  true,  false, false, true,  true, false }, // 'AMX NetLinx' contains substrings
    { false, false, false, false, false, true,  true,  false, true, false }, // 'NAVFoundation' contains substrings
    { false, false, false, false, false, false, false, false, true, false }, // '' contains substrings
    { false, false, false, false, false, false, false, false, true, false }  // 'A' contains substrings
}

define_function TestNAVStartsWith() {
    stack_var integer i, j

    NAVLog("'***************** NAVStartsWith *****************'")

    for (i = 1; i <= length_array(STARTS_ENDS_TEST_SUBJECTS); i++) {
        for (j = 1; j <= length_array(STARTS_TEST_PREFIXES); j++) {
            stack_var char expected
            stack_var char result

            expected = STARTS_WITH_EXPECTED[i][j]
            result = NAVStartsWith(STARTS_ENDS_TEST_SUBJECTS[i], STARTS_TEST_PREFIXES[j])

            if (result != expected) {
                NAVLogTestFailed((i-1)*length_array(STARTS_TEST_PREFIXES)+j, itoa(expected), itoa(result))
                continue
            }

            NAVLogTestPassed((i-1)*length_array(STARTS_TEST_PREFIXES)+j)
        }
    }

    // Test the alias function
    NAVLog("'***************** NAVStringStartsWith (Alias) *****************'")
    {
        stack_var char expected
        stack_var char result

        expected = NAVStartsWith('Hello', 'He')
        result = NAVStringStartsWith('Hello', 'He')

        if (result != expected) {
            NAVLogTestFailed(1, itoa(expected), itoa(result))
        }
        else {
            NAVLogTestPassed(1)
        }
    }
}

define_function TestNAVEndsWith() {
    stack_var integer i, j

    NAVLog("'***************** NAVEndsWith *****************'")

    for (i = 1; i <= length_array(STARTS_ENDS_TEST_SUBJECTS); i++) {
        for (j = 1; j <= length_array(ENDS_TEST_SUFFIXES); j++) {
            stack_var char expected
            stack_var char result

            expected = ENDS_WITH_EXPECTED[i][j]
            result = NAVEndsWith(STARTS_ENDS_TEST_SUBJECTS[i], ENDS_TEST_SUFFIXES[j])

            if (result != expected) {
                NAVLogTestFailed((i-1)*length_array(ENDS_TEST_SUFFIXES)+j, itoa(expected), itoa(result))
                continue
            }

            NAVLogTestPassed((i-1)*length_array(ENDS_TEST_SUFFIXES)+j)
        }
    }

    // Test the alias function
    NAVLog("'***************** NAVStringEndsWith (Alias) *****************'")
    {
        stack_var char expected
        stack_var char result

        expected = NAVEndsWith('Hello', 'lo')
        result = NAVStringEndsWith('Hello', 'lo')

        if (result != expected) {
            NAVLogTestFailed(1, itoa(expected), itoa(result))
        }
        else {
            NAVLogTestPassed(1)
        }
    }
}

define_function TestNAVContains() {
    stack_var integer i, j

    NAVLog("'***************** NAVContains *****************'")

    for (i = 1; i <= length_array(STARTS_ENDS_TEST_SUBJECTS); i++) {
        for (j = 1; j <= length_array(CONTAINS_TEST_SUBSTRINGS); j++) {
            stack_var char expected
            stack_var char result

            expected = CONTAINS_EXPECTED[i][j]
            result = NAVContains(STARTS_ENDS_TEST_SUBJECTS[i], CONTAINS_TEST_SUBSTRINGS[j])

            if (result != expected) {
                NAVLogTestFailed((i-1)*length_array(CONTAINS_TEST_SUBSTRINGS)+j, itoa(expected), itoa(result))
                continue
            }

            NAVLogTestPassed((i-1)*length_array(CONTAINS_TEST_SUBSTRINGS)+j)
        }
    }

    // Test the alias function
    NAVLog("'***************** NAVStringContains (Alias) *****************'")
    {
        stack_var char expected
        stack_var char result

        expected = NAVContains('Hello World', 'lo Wo')
        result = NAVStringContains('Hello World', 'lo Wo')

        if (result != expected) {
            NAVLogTestFailed(1, itoa(expected), itoa(result))
        }
        else {
            NAVLogTestPassed(1)
        }
    }
}
