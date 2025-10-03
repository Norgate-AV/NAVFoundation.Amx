PROGRAM_NAME='NAVStringBeforeAfter'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char BEFORE_AFTER_SUBJECT[] = 'The quick brown fox jumps over the lazy dog'

constant char BEFORE_AFTER_TOKENS[][NAV_MAX_BUFFER] = {
    'quick',
    'fox',
    'dog',
    'The',
    'jumps',
    'missing',
    '',
    ' '
}

constant char GET_STRING_BEFORE_EXPECTED[][NAV_MAX_BUFFER] = {
    'The ',                          // before 'quick'
    'The quick brown ',              // before 'fox'
    'The quick brown fox jumps over the lazy ', // before 'dog'
    '',                             // before 'The'
    'The quick brown fox ',          // before 'jumps'
    'The quick brown fox jumps over the lazy dog', // before 'missing'
    'The quick brown fox jumps over the lazy dog', // before ''
    'The'                           // before ' '
}

constant char GET_STRING_AFTER_EXPECTED[][NAV_MAX_BUFFER] = {
    ' brown fox jumps over the lazy dog', // after 'quick'
    ' jumps over the lazy dog',          // after 'fox'
    '',                                 // after 'dog'
    ' quick brown fox jumps over the lazy dog', // after 'The'
    ' over the lazy dog',                // after 'jumps'
    'The quick brown fox jumps over the lazy dog', // after 'missing'
    'The quick brown fox jumps over the lazy dog', // after ''
    'quick brown fox jumps over the lazy dog'  // after ' '
}

define_function TestNAVGetStringBefore() {
    stack_var integer i

    NAVLog("'***************** NAVGetStringBefore *****************'")

    for (i = 1; i <= length_array(BEFORE_AFTER_TOKENS); i++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]
        stack_var char token[NAV_MAX_BUFFER]

        token = BEFORE_AFTER_TOKENS[i]
        expected = GET_STRING_BEFORE_EXPECTED[i]

        result = NAVGetStringBefore(BEFORE_AFTER_SUBJECT, token)

        if (!NAVAssertStringEqual('Get String Before Test', expected, result)) {
            NAVLogTestFailed(i, expected, result)
            continue
        }

        NAVLogTestPassed(i)
    }

    // Test the alias function
    NAVLog("'***************** NAVStringBefore (Alias) *****************'")
    {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = NAVGetStringBefore('Hello World', ' ')
        result = NAVStringBefore('Hello World', ' ')

        if (!NAVAssertStringEqual('String Before Alias Test', expected, result)) {
            NAVLogTestFailed(1, expected, result)
        }
        else {
            NAVLogTestPassed(1)
        }
    }
}

define_function TestNAVGetStringAfter() {
    stack_var integer i

    NAVLog("'***************** NAVGetStringAfter *****************'")

    for (i = 1; i <= length_array(BEFORE_AFTER_TOKENS); i++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]
        stack_var char token[NAV_MAX_BUFFER]

        token = BEFORE_AFTER_TOKENS[i]
        expected = GET_STRING_AFTER_EXPECTED[i]

        result = NAVGetStringAfter(BEFORE_AFTER_SUBJECT, token)

        if (!NAVAssertStringEqual('Get String After Test', expected, result)) {
            NAVLogTestFailed(i, expected, result)
            continue
        }

        NAVLogTestPassed(i)
    }

    // Test the alias function
    NAVLog("'***************** NAVStringAfter (Alias) *****************'")
    {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = NAVGetStringAfter('Hello World', ' ')
        result = NAVStringAfter('Hello World', ' ')

        if (!NAVAssertStringEqual('String After Alias Test', expected, result)) {
            NAVLogTestFailed(1, expected, result)
        }
        else {
            NAVLogTestPassed(1)
        }
    }
}
