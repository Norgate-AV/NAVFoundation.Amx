PROGRAM_NAME='NAVRegexMatchBoundedQuantifierGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_TEST[][][255] = {
    // Pattern, Test Text, Expected Length, Expected Start, Expected End, Expected Match Text, Debug

    // Exact count {n} on capturing groups
    { '/(abc){2}/', 'abcabc', '6', '1', '7', 'abcabc', 'false' },
    { '/(abc){2}/', 'abc', '0', '0', '0', '', 'false' },              // Too few
    { '/(abc){2}/', 'abcabcabc', '6', '1', '7', 'abcabc', 'false' },  // Matches exactly 2
    { '/(ab){3}/', 'ababab', '6', '1', '7', 'ababab', 'false' },
    { '/(\d){4}/', '1234', '4', '1', '5', '1234', 'false' },
    { '/(\d+){3}/', '12-34-56', '8', '1', '9', '12-34-56', 'false' }, // Group with quantifier inside

    // Exact count {n} on non-capturing groups
    { '/(?:abc){2}/', 'abcabc', '6', '1', '7', 'abcabc', 'false' },
    { '/(?:ab){3}/', 'ababab', '6', '1', '7', 'ababab', 'false' },
    { '/(?:\d+){2}/', '123-456', '7', '1', '8', '123-456', 'false' },

    // Bounded range {n,m} on capturing groups
    { '/(ab){2,4}/', 'ab', '0', '0', '0', '', 'false' },              // Too few
    { '/(ab){2,4}/', 'abab', '4', '1', '5', 'abab', 'false' },        // Minimum
    { '/(ab){2,4}/', 'ababab', '6', '1', '7', 'ababab', 'false' },    // Middle
    { '/(ab){2,4}/', 'abababab', '8', '1', '9', 'abababab', 'false' },// Maximum (greedy)
    { '/(ab){2,4}/', 'ababababab', '8', '1', '9', 'abababab', 'false' }, // More than max
    { '/(\d+){1,3}/', '12', '2', '1', '3', '12', 'false' },
    { '/(\d+){1,3}/', '12-34', '5', '1', '6', '12-34', 'false' },
    { '/(\d+){1,3}/', '12-34-56', '8', '1', '9', '12-34-56', 'false' },

    // Bounded range {n,m} on non-capturing groups
    { '/(?:ab){2,4}/', 'abab', '4', '1', '5', 'abab', 'false' },
    { '/(?:ab){2,4}/', 'ababab', '6', '1', '7', 'ababab', 'false' },
    { '/(?:\d+){1,3}/', '12-34-56', '8', '1', '9', '12-34-56', 'false' },

    // Unlimited {n,} on capturing groups
    { '/(ab){1,}/', 'ab', '2', '1', '3', 'ab', 'false' },
    { '/(ab){1,}/', 'ababab', '6', '1', '7', 'ababab', 'false' },     // Greedy: takes all
    { '/(ab){2,}/', 'ab', '0', '0', '0', '', 'false' },                // Too few
    { '/(ab){2,}/', 'abababab', '8', '1', '9', 'abababab', 'false' }, // Greedy: takes all
    { '/(\w+){2,}/', 'hello-world', '11', '1', '12', 'hello-world', 'false' },

    // Unlimited {n,} on non-capturing groups
    { '/(?:ab){1,}/', 'ababab', '6', '1', '7', 'ababab', 'false' },
    { '/(?:ab){2,}/', 'abababab', '8', '1', '9', 'abababab', 'false' },

    // Zero occurrences {0} on groups
    { '/(ab){0}/', 'ab', '0', '1', '1', '', 'false' },
    { '/(?:ab){0}/', 'test', '0', '1', '1', '', 'false' },

    // Zero or more {0,} on groups (equivalent to *)
    { '/(ab){0,}/', '', '0', '1', '1', '', 'false' },
    { '/(ab){0,}/', 'ababab', '6', '1', '7', 'ababab', 'false' },
    { '/(?:ab){0,}/', 'ababab', '6', '1', '7', 'ababab', 'false' },

    // Complex patterns
    { '/(\d{2}){3}/', '123456', '6', '1', '7', '123456', 'false' },   // Group with quantifier inside, group quantified
    { '/([a-z]+){2}/', 'hello-world', '11', '1', '12', 'hello-world', 'false' },
    { '/([a-z]{2,4}){2}/', 'ab-test', '7', '1', '8', 'ab-test', 'false' },

    // With anchors
    { '/^(ab){3}$/', 'ababab', '6', '1', '7', 'ababab', 'false' },
    { '/^(ab){3}$/', 'abab', '0', '0', '0', '', 'false' },            // Too few
    { '/^(\d+){2}$/', '123-456', '7', '1', '8', '123-456', 'false' },

    // Mixed groups and quantifiers
    { '/(ab){2}(cd){2}/', 'ababcdcd', '8', '1', '9', 'ababcdcd', 'false' },
    { '/([a-z]+){2}\d{3}/', 'hello-world123', '15', '1', '16', 'hello-world123', 'false' },
    { '/\d{2}(ab){2}\d{2}/', '12abab34', '8', '1', '9', '12abab34', 'false' },

    // Edge cases
    { '/(a){1}/', 'a', '1', '1', '2', 'a', 'false' },                 // {1} same as no quantifier
    { '/(\d){0,1}/', '1', '1', '1', '2', '1', 'false' },              // {0,1} equivalent to ?
    { '/(\d){0,1}/', '', '0', '1', '1', '', 'false' },

    // Nested groups with bounded quantifiers
    { '/((ab){2}){2}/', 'abababab', '8', '1', '9', 'abababab', 'false' },
    { '/((?:ab){2}){2}/', 'abababab', '8', '1', '9', 'abababab', 'false' }
}

constant char REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_RESULT[] = {
    true,   // 1: /(abc){2}/ matches 'abcabc'
    false,  // 2: /(abc){2}/ doesn't match 'abc' (too few)
    true,   // 3: /(abc){2}/ matches 'abcabc' from 'abcabcabc'
    true,   // 4: /(ab){3}/ matches 'ababab'
    true,   // 5: /(\d){4}/ matches '1234'
    true,   // 6: /(\d+){3}/ matches '12-34-56'

    true,   // 7: /(?:abc){2}/ matches 'abcabc'
    true,   // 8: /(?:ab){3}/ matches 'ababab'
    true,   // 9: /(?:\d+){2}/ matches '123-456'

    false,  // 10: /(ab){2,4}/ doesn't match 'ab' (too few)
    true,   // 11: /(ab){2,4}/ matches 'abab'
    true,   // 12: /(ab){2,4}/ matches 'ababab'
    true,   // 13: /(ab){2,4}/ matches 'abababab' (max 4)
    true,   // 14: /(ab){2,4}/ matches 'abababab' from 'ababababab'
    true,   // 15: /(\d+){1,3}/ matches '12'
    true,   // 16: /(\d+){1,3}/ matches '12-34'
    true,   // 17: /(\d+){1,3}/ matches '12-34-56'

    true,   // 18: /(?:ab){2,4}/ matches 'abab'
    true,   // 19: /(?:ab){2,4}/ matches 'ababab'
    true,   // 20: /(?:\d+){1,3}/ matches '12-34-56'

    true,   // 21: /(ab){1,}/ matches 'ab'
    true,   // 22: /(ab){1,}/ matches 'ababab'
    false,  // 23: /(ab){2,}/ doesn't match 'ab' (too few)
    true,   // 24: /(ab){2,}/ matches 'abababab'
    true,   // 25: /(\w+){2,}/ matches 'hello-world'

    true,   // 26: /(?:ab){1,}/ matches 'ababab'
    true,   // 27: /(?:ab){2,}/ matches 'abababab'

    true,   // 28: /(ab){0}/ matches (zero-length)
    true,   // 29: /(?:ab){0}/ matches (zero-length)

    true,   // 30: /(ab){0,}/ matches '' (zero-length)
    true,   // 31: /(ab){0,}/ matches 'ababab'
    true,   // 32: /(?:ab){0,}/ matches 'ababab'

    true,   // 33: /(\d{2}){3}/ matches '123456'
    true,   // 34: /([a-z]+){2}/ matches 'hello-world'
    true,   // 35: /([a-z]{2,4}){2}/ matches 'ab-test'

    true,   // 36: /^(ab){3}$/ matches 'ababab'
    false,  // 37: /^(ab){3}$/ doesn't match 'abab' (too few)
    true,   // 38: /^(\d+){2}$/ matches '123-456'

    true,   // 39: /(ab){2}(cd){2}/ matches 'ababcdcd'
    true,   // 40: /([a-z]+){2}\d{3}/ matches 'hello-world123'
    true,   // 41: /\d{2}(ab){2}\d{2}/ matches '12abab34'

    true,   // 42: /(a){1}/ matches 'a'
    true,   // 43: /(\d){0,1}/ matches '1'
    true,   // 44: /(\d){0,1}/ matches (zero-length)

    true,   // 45: /((ab){2}){2}/ matches 'abababab'
    true    // 46: /((?:ab){2}){2}/ matches 'abababab'
}


define_function char TestNAVRegexMatchBoundedQuantifierGroups() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                "'***************** NAVRegexMatchBoundedQuantifierGroups *****************'")

    for (x = 1; x <= length_array(REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char result
        stack_var char failed
        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatch expected

        failed = false

        pattern = REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_TEST[x][1]
        text = REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_TEST[x][2]

        expected.length = atoi(REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_TEST[x][3])
        expected.start = atoi(REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_TEST[x][4])
        expected.end = atoi(REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_TEST[x][5])
        expected.text = REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_TEST[x][6]

        // Set the debug flag
        match.debug = (REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_TEST[x][7] == 'true')

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    "'Test ', itoa(x), ': pattern=[', pattern, '] text=[', text, ']'")

        result = NAVRegexMatch(pattern, text, match)

        if (!NAVAssertBooleanEqual('Should return the expected result', REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!REGEX_MATCH_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_RESULT[x]) {
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

        if (!NAVAssertStringEqual('Should have the correct match text', match.matches[1].text, expected.text)) {
            NAVLogTestFailed(x, expected.text, match.matches[1].text)
            failed = true
        }

        if (!failed) {
            NAVLogTestPassed(x)
        }
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                "'***************** NAVRegexMatchBoundedQuantifierGroups PASSED *****************'")

    return true
}
