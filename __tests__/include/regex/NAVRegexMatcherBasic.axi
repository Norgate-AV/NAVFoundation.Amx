PROGRAM_NAME='NAVRegexMatcherBasic'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns and inputs for basic matcher functionality
constant char REGEX_MATCHER_BASIC_PATTERN_TEST[][255] = {
    // Simple literals
    '/a/',              // 1: Single character
    '/abc/',            // 2: Multiple characters
    '/hello/',          // 3: Word

    // Predefined classes
    '/\d/',             // 4: Digit
    '/\w/',             // 5: Word character
    '/\s/',             // 6: Whitespace
    '/\D/',             // 7: Not digit
    '/\W/',             // 8: Not word
    '/\S/',             // 9: Not whitespace

    // Dot metacharacter
    '/./',              // 10: Single dot
    '/.../',            // 11: Three dots

    // Anchors
    '/^a/',             // 12: Start anchor
    '/a$/',             // 13: End anchor
    '/^abc$/',          // 14: Both anchors (exact match)
    '/\ba/',            // 15: Word boundary at start
    '/a\b/',            // 16: Word boundary at end

    // Quantifiers
    '/a*/',             // 17: Zero or more
    '/a+/',             // 18: One or more
    '/a?/',             // 19: Zero or one
    '/ab*c/',           // 20: Zero or more in middle
    '/ab+c/',           // 21: One or more in middle

    // Character classes
    '/[abc]/',          // 22: Simple class
    '/[a-z]/',          // 23: Range
    '/[^abc]/',         // 24: Negated class
    '/[0-9]+/',         // 25: Digit range with quantifier

    // Simple combinations
    '/\d+/',            // 26: One or more digits
    '/\w+/',            // 27: One or more word chars
    '/\s+/',            // 28: One or more whitespace
    '/[a-z]+/',         // 29: One or more lowercase
    '/[A-Z]+/'          // 30: One or more uppercase
}

constant char REGEX_MATCHER_BASIC_INPUT_TEST[][255] = {
    // Inputs corresponding to patterns above
    'abc',              // 1: Contains 'a'
    'xyzabcdef',        // 2: Contains 'abc'
    'say hello world',  // 3: Contains 'hello'

    '123',              // 4: Contains digit
    'word',             // 5: Contains word char
    ' $HT ',            // 6: Contains whitespace
    'abc',              // 7: Contains non-digit
    '***',              // 8: Contains non-word
    'x',                // 9: Contains non-whitespace

    'x',                // 10: Single char for dot
    'xyz',              // 11: Three chars for dots

    'abc',              // 12: Starts with 'a'
    'xa',               // 13: Ends with 'a'
    'abc',              // 14: Exactly 'abc'
    'abc',              // 15: Word boundary before 'a'
    'a ',               // 16: Word boundary after 'a'

    'bbb',              // 17: Zero 'a' (matches empty at start)
    'aaa',              // 18: One or more 'a'
    'bbb',              // 19: Zero 'a' (matches empty at start)
    'ac',               // 20: Zero 'b' between a and c
    'abc',              // 21: One 'b' between a and c

    'a',                // 22: Matches 'a' from class
    'x',                // 23: Matches 'x' from range
    'd',                // 24: Matches 'd' (not in [abc])
    '123',              // 25: Matches '123'

    '42',               // 26: Matches '42'
    'test',             // 27: Matches 'test'
    '  $HT ',           // 28: Matches whitespace
    'hello',            // 29: Matches 'hello'
    'WORLD'             // 30: Matches 'WORLD'
}

constant char REGEX_MATCHER_BASIC_EXPECTED_MATCH[][255] = {
    // Expected matched text for each test
    'a',                // 1
    'abc',              // 2
    'hello',            // 3

    '1',                // 4
    'w',                // 5
    ' ',                // 6
    'a',                // 7
    '*',                // 8
    'x',                // 9

    'x',                // 10
    'xyz',              // 11

    'a',                // 12
    'a',                // 13
    'abc',              // 14
    'a',                // 15
    'a',                // 16

    '',                 // 17: Empty match
    'aaa',              // 18
    '',                 // 19: Empty match
    'ac',               // 20
    'abc',              // 21

    'a',                // 22
    'x',                // 23
    'd',                // 24
    '123',              // 25

    '42',               // 26
    'test',             // 27
    '  ',               // 28: Two spaces (greedy match)
    'hello',            // 29
    'WORLD'             // 30
}

constant integer REGEX_MATCHER_BASIC_EXPECTED_MATCH_START[] = {
    1,                  // 1: 'a' at position 1
    4,                  // 2: 'abc' at position 4
    5,                  // 3: 'hello' at position 5

    1,                  // 4: '1' at position 1
    1,                  // 5: 'w' at position 1
    1,                  // 6: space at position 1
    1,                  // 7: 'a' at position 1
    1,                  // 8: '*' at position 1
    1,                  // 9: 'x' at position 1

    1,                  // 10: 'x' at position 1
    1,                  // 11: 'xyz' at position 1

    1,                  // 12: 'a' at position 1
    2,                  // 13: 'a' at position 2
    1,                  // 14: 'abc' at position 1
    1,                  // 15: 'a' at position 1
    1,                  // 16: 'a' at position 1

    1,                  // 17: Empty at position 1
    1,                  // 18: 'aaa' at position 1
    1,                  // 19: Empty at position 1
    1,                  // 20: 'ac' at position 1
    1,                  // 21: 'abc' at position 1

    1,                  // 22: 'a' at position 1
    1,                  // 23: 'x' at position 1
    1,                  // 24: 'd' at position 1
    1,                  // 25: '123' at position 1

    1,                  // 26: '42' at position 1
    1,                  // 27: 'test' at position 1
    1,                  // 28: '  ' at position 1
    1,                  // 29: 'hello' at position 1
    1                   // 30: 'WORLD' at position 1
}


/**
 * @function TestNAVRegexMatcherBasic
 * @public
 * @description Tests basic matcher functionality with simple patterns.
 *
 * Validates:
 * - Single character and literal string matching
 * - Predefined character classes (\d, \w, \s and negated)
 * - Dot metacharacter matching
 * - Basic anchors (^, $, \b)
 * - Basic quantifiers (\*, +, ?)
 * - Simple character classes
 * - Match position and text extraction
 */
define_function TestNAVRegexMatcherBasic() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Basic *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_BASIC_PATTERN_TEST); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match using simple API
        if (!NAVAssertTrue('Should match pattern', NAVRegexMatch(REGEX_MATCHER_BASIC_PATTERN_TEST[x], REGEX_MATCHER_BASIC_INPUT_TEST[x], collection))) {
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

        // Verify match count (should be 1 for simple match)
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
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_BASIC_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_MATCHER_BASIC_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_BASIC_EXPECTED_MATCH_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_BASIC_EXPECTED_MATCH_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
            NAVStopwatchStop()
            continue
        }

        // Verify match length
        if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_BASIC_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_BASIC_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
