PROGRAM_NAME='NAVRegexMatchBoundedQuantifiers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char REGEX_MATCH_BOUNDED_QUANTIFIERS_TEST[][][255] = {
    // Pattern, Test Text, Expected Length, Expected Start, Expected End, Expected Match Text, Debug

    // Exact count {n} - should match exactly n occurrences
    { '/a{3}/', 'aaa', '3', '1', '4', 'aaa', 'false' },
    { '/a{3}/', 'aa', '0', '0', '0', '', 'false' },          // Too few
    { '/a{3}/', 'aaaa', '3', '1', '4', 'aaa', 'false' },     // Matches first 3 (greedy)
    { '/\d{5}/', '12345', '5', '1', '6', '12345', 'false' },
    { '/\d{5}/', '1234', '0', '0', '0', '', 'false' },       // Too few digits
    { '/\d{5}/', '123456', '5', '1', '6', '12345', 'false' }, // Matches first 5

    // Exact count with character classes
    { '/[0-9]{3}/', '123', '3', '1', '4', '123', 'false' },
    { '/[a-z]{4}/', 'test', '4', '1', '5', 'test', 'false' },
    { '/[\w]{2}/', 'ab', '2', '1', '3', 'ab', 'false' },

    // Bounded range {n,m} - should match between n and m occurrences (greedy)
    { '/a{2,4}/', 'a', '0', '0', '0', '', 'false' },         // Too few
    { '/a{2,4}/', 'aa', '2', '1', '3', 'aa', 'false' },      // Minimum
    { '/a{2,4}/', 'aaa', '3', '1', '4', 'aaa', 'false' },    // Middle
    { '/a{2,4}/', 'aaaa', '4', '1', '5', 'aaaa', 'false' },  // Maximum (greedy)
    { '/a{2,4}/', 'aaaaa', '4', '1', '5', 'aaaa', 'false' }, // More than max, matches 4 (greedy)

    { '/\d{1,3}/', '1', '1', '1', '2', '1', 'false' },
    { '/\d{1,3}/', '12', '2', '1', '3', '12', 'false' },
    { '/\d{1,3}/', '123', '3', '1', '4', '123', 'false' },
    { '/\d{1,3}/', '1234', '3', '1', '4', '123', 'false' },  // Greedy: takes 3

    // Bounded range with character classes
    { '/[a-z]{2,5}/', 'hello', '5', '1', '6', 'hello', 'false' },  // Greedy: takes max
    { '/[0-9]{2,4}/', '12', '2', '1', '3', '12', 'false' },

    // Unlimited {n,} - should match n or more occurrences (greedy)
    { '/a{1,}/', 'a', '1', '1', '2', 'a', 'false' },
    { '/a{1,}/', 'aaa', '3', '1', '4', 'aaa', 'false' },     // Greedy: takes all
    { '/a{1,}/', 'aaaaa', '5', '1', '6', 'aaaaa', 'false' }, // Greedy: takes all
    { '/a{1,}/', '', '0', '0', '0', '', 'false' },           // No match

    { '/\d{2,}/', '1', '0', '0', '0', '', 'false' },         // Too few
    { '/\d{2,}/', '12', '2', '1', '3', '12', 'false' },
    { '/\d{2,}/', '12345', '5', '1', '6', '12345', 'false' }, // Greedy: takes all

    { '/\w{3,}/', 'ab', '0', '0', '0', '', 'false' },        // Too few
    { '/\w{3,}/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\w{3,}/', 'hello', '5', '1', '6', 'hello', 'false' }, // Greedy: takes all

    // Zero occurrences {0} - should always match with length 0
    { '/a{0}/', 'a', '0', '1', '1', '', 'false' },
    { '/a{0}/', '', '0', '1', '1', '', 'false' },
    { '/\d{0}/', '123', '0', '1', '1', '', 'false' },

    // Zero or more {0,} - equivalent to *
    { '/a{0,}/', '', '0', '1', '1', '', 'false' },
    { '/a{0,}/', 'aaa', '3', '1', '4', 'aaa', 'false' },
    { '/\d{0,}/', '123', '3', '1', '4', '123', 'false' },
    { '/\d{0,}/', 'abc', '0', '1', '1', '', 'false' },

    // Complex patterns with bounded quantifiers
    { '/\d{3}\.\d{3}/', '123.456', '7', '1', '8', '123.456', 'false' },  // Phone pattern
    { '/\d{3}-\d{3}-\d{4}/', '555-123-4567', '12', '1', '13', '555-123-4567', 'false' },  // Full phone

    { '/[a-z]{2,4}\d{1,2}/', 'ab1', '3', '1', '4', 'ab1', 'false' },
    { '/[a-z]{2,4}\d{1,2}/', 'test12', '6', '1', '7', 'test12', 'false' },

    // With anchors
    { '/^a{3}$/', 'aaa', '3', '1', '4', 'aaa', 'false' },
    { '/^a{3}$/', 'aaaa', '0', '0', '0', '', 'false' },      // Must be exactly 3
    { '/^\d{5}$/', '12345', '5', '1', '6', '12345', 'false' },
    { '/^\d{5}$/', '1234', '0', '0', '0', '', 'false' },

    { '/^\w{3,}$/', 'ab', '0', '0', '0', '', 'false' },      // Too short
    { '/^\w{3,}$/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/^\w{3,}$/', 'hello', '5', '1', '6', 'hello', 'false' },

    // Edge cases
    { '/a{1}/', 'a', '1', '1', '2', 'a', 'false' },          // {1} same as no quantifier
    { '/\d{0,1}/', '1', '1', '1', '2', '1', 'false' },       // {0,1} equivalent to ?
    { '/\d{0,1}/', '', '0', '1', '1', '', 'false' },

    // Large counts
    { '/a{10}/', 'aaaaaaaaaa', '10', '1', '11', 'aaaaaaaaaa', 'false' },
    { '/a{10}/', 'aaaaaaaaa', '0', '0', '0', '', 'false' },  // 9 a's - not enough

    // Multiple bounded quantifiers in sequence
    { '/\d{2}\w{3}/', '12abc', '5', '1', '6', '12abc', 'false' },
    { '/[a-z]{2}[0-9]{2}/', 'ab12', '4', '1', '5', 'ab12', 'false' }
}

constant char REGEX_MATCH_BOUNDED_QUANTIFIERS_EXPECTED_RESULT[] = {
    true,   // 1: /a{3}/ matches 'aaa'
    false,  // 2: /a{3}/ doesn't match 'aa'
    true,   // 3: /a{3}/ matches 'aaa' from 'aaaa'
    true,   // 4: /\d{5}/ matches '12345'
    false,  // 5: /\d{5}/ doesn't match '1234'
    true,   // 6: /\d{5}/ matches '12345' from '123456'

    true,   // 7: /[0-9]{3}/ matches '123'
    true,   // 8: /[a-z]{4}/ matches 'test'
    true,   // 9: /[\w]{2}/ matches 'ab'

    false,  // 10: /a{2,4}/ doesn't match 'a'
    true,   // 11: /a{2,4}/ matches 'aa'
    true,   // 12: /a{2,4}/ matches 'aaa'
    true,   // 13: /a{2,4}/ matches 'aaaa'
    true,   // 14: /a{2,4}/ matches 'aaaa' from 'aaaaa'

    true,   // 15: /\d{1,3}/ matches '1'
    true,   // 16: /\d{1,3}/ matches '12'
    true,   // 17: /\d{1,3}/ matches '123'
    true,   // 18: /\d{1,3}/ matches '123' from '1234'

    true,   // 19: /[a-z]{2,5}/ matches 'hello'
    true,   // 20: /[0-9]{2,4}/ matches '12'

    true,   // 21: /a{1,}/ matches 'a'
    true,   // 22: /a{1,}/ matches 'aaa'
    true,   // 23: /a{1,}/ matches 'aaaaa'
    false,  // 24: /a{1,}/ doesn't match ''

    false,  // 25: /\d{2,}/ doesn't match '1'
    true,   // 26: /\d{2,}/ matches '12'
    true,   // 27: /\d{2,}/ matches '12345'

    false,  // 28: /\w{3,}/ doesn't match 'ab'
    true,   // 29: /\w{3,}/ matches 'abc'
    true,   // 30: /\w{3,}/ matches 'hello'

    true,   // 31: /a{0}/ matches (zero-length)
    true,   // 32: /a{0}/ matches (zero-length)
    true,   // 33: /\d{0}/ matches (zero-length)

    true,   // 34: /a{0,}/ matches '' (zero-length)
    true,   // 35: /a{0,}/ matches 'aaa'
    true,   // 36: /\d{0,}/ matches '123'
    true,   // 37: /\d{0,}/ matches (zero-length)

    true,   // 38: /\d{3}\.\d{3}/ matches '123.456'
    true,   // 39: /\d{3}-\d{3}-\d{4}/ matches '555-123-4567'

    true,   // 40: /[a-z]{2,4}\d{1,2}/ matches 'ab1'
    true,   // 41: /[a-z]{2,4}\d{1,2}/ matches 'test12'

    true,   // 42: /^a{3}$/ matches 'aaa'
    false,  // 43: /^a{3}$/ doesn't match 'aaaa'
    true,   // 44: /^\d{5}$/ matches '12345'
    false,  // 45: /^\d{5}$/ doesn't match '1234'

    false,  // 46: /^\w{3,}$/ doesn't match 'ab'
    true,   // 47: /^\w{3,}$/ matches 'abc'
    true,   // 48: /^\w{3,}$/ matches 'hello'

    true,   // 49: /a{1}/ matches 'a'
    true,   // 50: /\d{0,1}/ matches '1'
    true,   // 51: /\d{0,1}/ matches (zero-length)

    true,   // 52: /a{10}/ matches 'aaaaaaaaaa'
    false,  // 53: /a{10}/ doesn't match 'aaaaaaaaa'

    true,   // 54: /\d{2}\w{3}/ matches '12abc'
    true    // 55: /[a-z]{2}[0-9]{2}/ matches 'ab12'
}

define_function TestNAVRegexMatchBoundedQuantifiers() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatch - Bounded Quantifiers *****************'")

    for (x = 1; x <= length_array(REGEX_MATCH_BOUNDED_QUANTIFIERS_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char result
        stack_var char failed
        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatch expected

        failed = false

        pattern = REGEX_MATCH_BOUNDED_QUANTIFIERS_TEST[x][1]
        text = REGEX_MATCH_BOUNDED_QUANTIFIERS_TEST[x][2]

        expected.length = atoi(REGEX_MATCH_BOUNDED_QUANTIFIERS_TEST[x][3])
        expected.start = atoi(REGEX_MATCH_BOUNDED_QUANTIFIERS_TEST[x][4])
        expected.end = atoi(REGEX_MATCH_BOUNDED_QUANTIFIERS_TEST[x][5])
        expected.text = REGEX_MATCH_BOUNDED_QUANTIFIERS_TEST[x][6]

        // Set the debug flag
        match.debug = (REGEX_MATCH_BOUNDED_QUANTIFIERS_TEST[x][7] == 'true')

        result = NAVRegexMatch(pattern, text, match)

        if (!NAVAssertBooleanEqual('Should return the expected result', REGEX_MATCH_BOUNDED_QUANTIFIERS_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(REGEX_MATCH_BOUNDED_QUANTIFIERS_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!REGEX_MATCH_BOUNDED_QUANTIFIERS_EXPECTED_RESULT[x]) {
            // If no match expected, skip further checks
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertIntegerEqual('Should match the correct length', match.matches[1].length, expected.length)) {
            NAVLogTestFailed(x, itoa(expected.length), itoa(match.matches[1].length))
            failed = true
        }

        if (!NAVAssertIntegerEqual('Should have the correct start position', match.matches[1].start, expected.start)) {
            NAVLogTestFailed(x, itoa(expected.start), itoa(match.matches[1].start))
            failed = true
        }

        if (!NAVAssertIntegerEqual('Should have the correct end position', match.matches[1].end, expected.end)) {
            NAVLogTestFailed(x, itoa(expected.end), itoa(match.matches[1].end))
            failed = true
        }

        if (!NAVAssertStringEqual('Should match the correct text', match.matches[1].text, expected.text)) {
            NAVLogTestFailed(x, expected.text, match.matches[1].text)
            failed = true
        }

        if (failed) {
            NAVLogTestFailed(x, '', '')
            continue
        }

        NAVLogTestPassed(x)
    }
}
