PROGRAM_NAME='NAVRegexMatcherCharClasses'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for character class matching
constant char REGEX_MATCHER_CHAR_CLASSES_PATTERN[][255] = {
    '/[abc]/',                      // 1: Simple character class
    '/[a-z]/',                      // 2: Lowercase range
    '/[A-Z]/',                      // 3: Uppercase range
    '/[0-9]/',                      // 4: Digit range
    '/[a-zA-Z]/',                   // 5: Mixed case letters
    '/[a-z0-9]/',                   // 6: Alphanumeric lowercase
    '/[A-Z0-9]/',                   // 7: Alphanumeric uppercase
    '/[^abc]/',                     // 8: Negated class - not abc
    '/[^a-z]/',                     // 9: Negated - not lowercase
    '/[^0-9]/',                     // 10: Negated - not digit
    '/[a-z]+/',                     // 11: One or more lowercase
    '/[A-Z]+/',                     // 12: One or more uppercase
    '/[0-9]+/',                     // 13: One or more digits
    '/[a-zA-Z]+/',                  // 14: One or more letters
    '/[a-z0-9]+/',                  // 15: One or more alphanumeric
    '/[^a-z]+/',                    // 16: One or more non-lowercase
    '/[aeiou]/',                    // 17: Vowels
    '/[^aeiou]/',                   // 18: Consonants
    '/[a-fA-F0-9]/',                // 19: Hex digit
    '/[a-z]{3}/',                   // 20: Exactly 3 lowercase
    '/[0-9]{2,4}/',                 // 21: 2-4 digits
    '/[A-Z][a-z]+/',                // 22: Capitalized word
    '/[a-z]+@[a-z]+\.[a-z]+/',      // 23: Email pattern with char classes
    '/[\d]/',                       // 24: Digit predefined class
    '/[\w]/',                       // 25: Word char predefined class
    '/[\s]/',                       // 26: Whitespace predefined class
    '/[a-z\d]/',                    // 27: Lowercase or digit
    '/[a-z\s]/',                    // 28: Lowercase or whitespace
    '/[\w\-]/',                     // 29: Word char or hyphen
    '/[.?!]/'                       // 30: Punctuation
}

constant char REGEX_MATCHER_CHAR_CLASSES_INPUT[][255] = {
    'a',                            // 1: Contains 'a'
    'x',                            // 2: Lowercase letter
    'X',                            // 3: Uppercase letter
    '5',                            // 4: Digit
    'T',                            // 5: Uppercase letter
    'a5',                           // 6: Lowercase and digit
    'A5',                           // 7: Uppercase and digit
    'd',                            // 8: Not in [abc]
    'X',                            // 9: Not lowercase
    'X',                            // 10: Not digit
    'hello',                        // 11: All lowercase
    'WORLD',                        // 12: All uppercase
    '12345',                        // 13: All digits
    'Test',                         // 14: Mixed case
    'test123',                      // 15: Alphanumeric
    '123-XYZ',                      // 16: Non-lowercase
    'e',                            // 17: Vowel
    't',                            // 18: Consonant
    'A',                            // 19: Hex digit
    'cat',                          // 20: 3 lowercase letters
    '2025',                         // 21: 4 digits
    'Hello',                        // 22: Capitalized
    'user@example.com',             // 23: Email
    '7',                            // 24: Digit
    'w',                            // 25: Word char
    ' ',                            // 26: Space
    'a',                            // 27: Lowercase
    'a',                            // 28: Lowercase
    'w',                            // 29: Word char
    '.'                             // 30: Period
}

constant char REGEX_MATCHER_CHAR_CLASSES_EXPECTED_MATCH[][255] = {
    'a',                            // 1
    'x',                            // 2
    'X',                            // 3
    '5',                            // 4
    'T',                            // 5
    'a',                            // 6
    'A',                            // 7
    'd',                            // 8
    'X',                            // 9
    'X',                            // 10
    'hello',                        // 11
    'WORLD',                        // 12
    '12345',                        // 13
    'Test',                         // 14
    'test123',                      // 15
    '123-XYZ',                      // 16: Greedy - matches all non-lowercase
    'e',                            // 17
    't',                            // 18
    'A',                            // 19
    'cat',                          // 20
    '2025',                         // 21
    'Hello',                        // 22
    'user@example.com',             // 23
    '7',                            // 24
    'w',                            // 25
    ' ',                            // 26
    'a',                            // 27
    'a',                            // 28
    'w',                            // 29
    '.'                             // 30
}

constant integer REGEX_MATCHER_CHAR_CLASSES_EXPECTED_START[] = {
    1,                              // 1
    1,                              // 2
    1,                              // 3
    1,                              // 4
    1,                              // 5
    1,                              // 6
    1,                              // 7
    1,                              // 8
    1,                              // 9
    1,                              // 10
    1,                              // 11
    1,                              // 12
    1,                              // 13
    1,                              // 14
    1,                              // 15
    1,                              // 16
    1,                              // 17
    1,                              // 18
    1,                              // 19
    1,                              // 20
    1,                              // 21
    1,                              // 22
    1,                              // 23
    1,                              // 24
    1,                              // 25
    1,                              // 26
    1,                              // 27
    1,                              // 28
    1,                              // 29
    1                               // 30
}


/**
 * @function TestNAVRegexMatcherCharClasses
 * @public
 * @description Tests character class matching [abc], [a-z], [^abc].
 *
 * Validates:
 * - Simple character classes [abc]
 * - Range-based classes [a-z], [A-Z], [0-9]
 * - Combined ranges [a-zA-Z], [a-z0-9]
 * - Negated classes [^abc], [^a-z]
 * - Character classes with quantifiers
 * - Predefined classes within brackets [\d], [\w], [\s]
 * - Mixed character types in classes [a-z\d]
 * - Special characters in classes [.?!]
 * - Escaped characters in classes [\-]
 * - Complex patterns using multiple classes
 */
define_function TestNAVRegexMatcherCharClasses() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Character Classes *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_CHAR_CLASSES_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match
        if (!NAVAssertTrue('Should match pattern', NAVRegexMatch(REGEX_MATCHER_CHAR_CLASSES_PATTERN[x], REGEX_MATCHER_CHAR_CLASSES_INPUT[x], collection))) {
            NAVLogTestFailed(x, 'match success', 'match failed')
            NAVStopwatchStop()
            continue
        }

        // Verify match status
        if (!NAVAssertIntegerEqual('Match status should be SUCCESS', MATCH_STATUS_SUCCESS, collection.status)) {
            NAVLogTestFailed(x, 'SUCCESS', itoa(collection.status))
            NAVStopwatchStop()
            continue
        }

        // Verify match count
        if (!NAVAssertIntegerEqual('Match count should be 1', 1, collection.count)) {
            NAVLogTestFailed(x, '1', itoa(collection.count))
            NAVStopwatchStop()
            continue
        }

        // Verify hasMatch flag
        if (!NAVAssertTrue('Result should have match', collection.matches[1].hasMatch)) {
            NAVLogTestFailed(x, 'hasMatch=true', 'hasMatch=false')
            NAVStopwatchStop()
            continue
        }

        // Verify matched text
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_CHAR_CLASSES_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_MATCHER_CHAR_CLASSES_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_CHAR_CLASSES_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_CHAR_CLASSES_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
            NAVStopwatchStop()
            continue
        }

        // Verify match length
        if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_CHAR_CLASSES_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_CHAR_CLASSES_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
