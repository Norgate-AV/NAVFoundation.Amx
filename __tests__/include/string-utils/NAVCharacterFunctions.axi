PROGRAM_NAME='NAVCharacterFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char CHAR_TEST_WHITESPACE[] = {
    NAV_NULL,
    NAV_TAB,
    NAV_LF,
    NAV_VT,
    NAV_FF,
    NAV_CR,
    ' ',
    'A',
    '1',
    '_',
    '.'
}

constant char WHITESPACE_EXPECTED[] = {
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    false,
    false,
    false
}

constant char CHAR_TEST_ALPHA[] = {
    'a',
    'A',
    'z',
    'Z',
    '0',
    '9',
    ' ',
    '_',
    '.',
    NAV_CR
}

constant char ALPHA_EXPECTED[] = {
    true,
    true,
    true,
    true,
    false,
    false,
    false,
    false,
    false,
    false
}

constant char CHAR_TEST_DIGIT[] = {
    '0',
    '9',
    '5',
    'A',
    'a',
    ' ',
    '_',
    '.',
    NAV_CR
}

constant char DIGIT_EXPECTED[] = {
    true,
    true,
    true,
    false,
    false,
    false,
    false,
    false,
    false
}

constant char CHAR_TEST_ALPHANUMERIC[] = {
    'a',
    'A',
    'z',
    'Z',
    '0',
    '9',
    '_',
    ' ',
    '.',
    NAV_CR
}

constant char ALPHANUMERIC_EXPECTED[] = {
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    false,
    false
}

constant char CHAR_TEST_CASE[] = {
    'a',
    'A',
    'z',
    'Z',
    '0',
    '9',
    '_',
    ' ',
    '.',
    NAV_CR
}

constant char UPPERCASE_EXPECTED[] = {
    false,
    true,
    false,
    true,
    false,
    false,
    false,
    false,
    false,
    false
}

constant char LOWERCASE_EXPECTED[] = {
    true,
    false,
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false
}

constant char CHAR_TEST_CONVERSION[] = {
    'a',
    'A',
    'z',
    'Z',
    '0',
    '9',
    '_',
    ' ',
    '.',
    NAV_CR
}

constant char CHAR_TO_UPPER_EXPECTED[] = {
    'A',
    'A',
    'Z',
    'Z',
    '0',
    '9',
    '_',
    ' ',
    '.',
    NAV_CR
}

constant char CHAR_TO_LOWER_EXPECTED[] = {
    'a',
    'a',
    'z',
    'z',
    '0',
    '9',
    '_',
    ' ',
    '.',
    NAV_CR
}

constant char CHAR_CODE_AT_SUBJECT[] = {
    'H',
    'e',
    'l',
    'l',
    'o',
    ',',
    ' ',
    'W',
    'o',
    'r',
    'l',
    'd',
    '!',
    NAV_NULL
}

constant integer CHAR_CODE_AT_INDEX[] = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14
}

constant char CHAR_CODE_AT_EXPECTED[] = {
    72,
    101,
    108,
    108,
    111,
    44,
    32,
    87,
    111,
    114,
    108,
    100,
    33,
    0
}

define_function TestNAVIsWhitespace() {
    stack_var integer x

    NAVLog("'***************** NAVIsWhitespace *****************'")

    for (x = 1; x <= length_array(CHAR_TEST_WHITESPACE); x++) {
        stack_var char expected
        stack_var char result
        stack_var char c

        c = CHAR_TEST_WHITESPACE[x]
        expected = WHITESPACE_EXPECTED[x]
        result = NAVIsWhitespace(c)

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    // Test the alias function
    NAVLog("'***************** NAVIsSpace (Alias) *****************'")
    {
        stack_var char expected
        stack_var char result

        expected = NAVIsWhitespace(' ')
        result = NAVIsSpace(' ')

        if (result != expected) {
            NAVLogTestFailed(1, itoa(expected), itoa(result))
        }
        else {
            NAVLogTestPassed(1)
        }
    }
}

define_function TestNAVIsAlpha() {
    stack_var integer x

    NAVLog("'***************** NAVIsAlpha *****************'")

    for (x = 1; x <= length_array(CHAR_TEST_ALPHA); x++) {
        stack_var char expected
        stack_var char result
        stack_var char c

        c = CHAR_TEST_ALPHA[x]
        expected = ALPHA_EXPECTED[x]
        result = NAVIsAlpha(c)

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVIsDigit() {
    stack_var integer x

    NAVLog("'***************** NAVIsDigit *****************'")

    for (x = 1; x <= length_array(CHAR_TEST_DIGIT); x++) {
        stack_var char expected
        stack_var char result
        stack_var char c

        c = CHAR_TEST_DIGIT[x]
        expected = DIGIT_EXPECTED[x]
        result = NAVIsDigit(c)

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVIsAlphaNumeric() {
    stack_var integer x

    NAVLog("'***************** NAVIsAlphaNumeric *****************'")

    for (x = 1; x <= length_array(CHAR_TEST_ALPHANUMERIC); x++) {
        stack_var char expected
        stack_var char result
        stack_var char c

        c = CHAR_TEST_ALPHANUMERIC[x]
        expected = ALPHANUMERIC_EXPECTED[x]
        result = NAVIsAlphaNumeric(c)

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVIsUpperCase() {
    stack_var integer x

    NAVLog("'***************** NAVIsUpperCase *****************'")

    for (x = 1; x <= length_array(CHAR_TEST_CASE); x++) {
        stack_var char expected
        stack_var char result
        stack_var char c

        c = CHAR_TEST_CASE[x]
        expected = UPPERCASE_EXPECTED[x]
        result = NAVIsUpperCase(c)

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVIsLowerCase() {
    stack_var integer x

    NAVLog("'***************** NAVIsLowerCase *****************'")

    for (x = 1; x <= length_array(CHAR_TEST_CASE); x++) {
        stack_var char expected
        stack_var char result
        stack_var char c

        c = CHAR_TEST_CASE[x]
        expected = LOWERCASE_EXPECTED[x]
        result = NAVIsLowerCase(c)

        if (result != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVCharToUpper() {
    stack_var integer x

    NAVLog("'***************** NAVCharToUpper *****************'")

    for (x = 1; x <= length_array(CHAR_TEST_CONVERSION); x++) {
        stack_var char expected
        stack_var char result
        stack_var char c

        c = CHAR_TEST_CONVERSION[x]
        expected = CHAR_TO_UPPER_EXPECTED[x]
        result = NAVCharToUpper(c)

        if (result != expected) {
            NAVLogTestFailed(x, format('%d', expected), format('%d', result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVCharToLower() {
    stack_var integer x

    NAVLog("'***************** NAVCharToLower *****************'")

    for (x = 1; x <= length_array(CHAR_TEST_CONVERSION); x++) {
        stack_var char expected
        stack_var char result
        stack_var char c

        c = CHAR_TEST_CONVERSION[x]
        expected = CHAR_TO_LOWER_EXPECTED[x]
        result = NAVCharToLower(c)

        if (result != expected) {
            NAVLogTestFailed(x, format('%d', expected), format('%d', result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVCharCodeAt() {
    stack_var integer x

    NAVLog("'***************** NAVCharCodeAt *****************'")

    for (x = 1; x <= length_array(CHAR_CODE_AT_INDEX); x++) {
        stack_var integer index
        stack_var char expected
        stack_var char result

        index = CHAR_CODE_AT_INDEX[x]
        expected = CHAR_CODE_AT_EXPECTED[x]
        result = NAVCharCodeAt(CHAR_CODE_AT_SUBJECT, index)

        if (result != expected) {
            NAVLogTestFailed(x, format('%d', expected), format('%d', result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
