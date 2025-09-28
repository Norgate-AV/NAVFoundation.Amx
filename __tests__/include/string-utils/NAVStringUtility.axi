PROGRAM_NAME='NAVStringUtility'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data for NAVStringCapitalize
constant char CAPITALIZE_TEST[][NAV_MAX_BUFFER] = {
    'hello world',
    'HELLO WORLD',
    'Hello World',
    'the quick brown fox',
    'single',
    '',
    'a b c d e',
    'mixed CaSe WoRdS',
    '123 numbers here',
    'special!@#characters here'
}

constant char CAPITALIZE_EXPECTED[][NAV_MAX_BUFFER] = {
    'Hello World',
    'HELLO WORLD',
    'Hello World',
    'The Quick Brown Fox',
    'Single',
    '',
    'A B C D E',
    'Mixed CaSe WoRdS',
    '123 Numbers Here',
    'Special!@#characters Here'
}

// Test data for NAVStringReverse
constant char REVERSE_TEST[][NAV_MAX_BUFFER] = {
    'Hello World',
    'AMX NetLinx',
    'abcdefg',
    'a',
    '',
    '12345',
    'racecar',  // palindrome
    'Testing 123',
    'NAVFoundation'
}

constant char REVERSE_EXPECTED[][NAV_MAX_BUFFER] = {
    'dlroW olleH',
    'xniLteN XMA',
    'gfedcba',
    'a',
    '',
    '54321',
    'racecar',
    '321 gnitseT',
    'noitadnuoFVAN'
}

// Test data for NAVInsertSpacesBeforeUppercase
constant char INSERT_SPACES_TEST[][NAV_MAX_BUFFER] = {
    'HelloWorld',
    'NAVFoundation',
    'XMLHttpRequest',
    'iPhone',
    'alreadyLowercase',
    'ALLUPPERCASE',
    'MixedCASEString',
    '',
    'A',
    'SimpleTest'
}

constant char INSERT_SPACES_EXPECTED[][NAV_MAX_BUFFER] = {
    'hello world',
    'navfoundation',
    'xmlhttp request',
    'i phone',
    'already lowercase',
    'alluppercase',
    'mixed casestring',
    '',
    'a',
    'simple test'
}

define_function TestNAVStringCapitalize() {
    stack_var integer x

    NAVLog("'***************** NAVStringCapitalize *****************'")

    for (x = 1; x <= length_array(CAPITALIZE_TEST); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = CAPITALIZE_EXPECTED[x]
        result = NAVStringCapitalize(CAPITALIZE_TEST[x])

        if (!NAVAssertStringEqual('Capitalize Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVStringReverse() {
    stack_var integer x

    NAVLog("'***************** NAVStringReverse *****************'")

    for (x = 1; x <= length_array(REVERSE_TEST); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = REVERSE_EXPECTED[x]
        result = NAVStringReverse(REVERSE_TEST[x])

        if (!NAVAssertStringEqual('Reverse Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    // Test palindrome verification
    {
        stack_var char palindrome[NAV_MAX_BUFFER]
        stack_var char reversed[NAV_MAX_BUFFER]

        palindrome = 'racecar'
        reversed = NAVStringReverse(palindrome)

        if (!NAVAssertStringEqual('Palindrome Test', palindrome, reversed)) {
            NAVLogTestFailed(1, palindrome, reversed)
        } else {
            NAVLogTestPassed(1)
        }
    }
}

define_function TestNAVInsertSpacesBeforeUppercase() {
    stack_var integer x

    NAVLog("'***************** NAVInsertSpacesBeforeUppercase *****************'")

    for (x = 1; x <= length_array(INSERT_SPACES_TEST); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = INSERT_SPACES_EXPECTED[x]
        result = NAVInsertSpacesBeforeUppercase(INSERT_SPACES_TEST[x])

        if (!NAVAssertStringEqual('Insert Spaces Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }

    // Additional edge cases
    NAVLog("'Testing edge cases...'")

    // Test single character
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVInsertSpacesBeforeUppercase('A')

        if (!NAVAssertStringEqual('Single Char Test', 'a', result)) {
            NAVLogTestFailed(1, 'a', result)
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test consecutive uppercase
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVInsertSpacesBeforeUppercase('HTTPSConnection')

        if (!NAVAssertStringEqual('Consecutive Upper Test', 'httpsconnection', result)) {
            NAVLogTestFailed(2, 'httpsconnection', result)
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test starting with lowercase
    {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVInsertSpacesBeforeUppercase('testHTTPRequest')

        if (!NAVAssertStringEqual('Start Lower Test', 'test httprequest', result)) {
            NAVLogTestFailed(3, 'test httprequest', result)
        } else {
            NAVLogTestPassed(3)
        }
    }
}
