PROGRAM_NAME='NAVRegexMatch'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char REGEX_MATCH_TEST[][][255] = {
    // Pattern, Test Text, Expected Length, Expected Start, Expected End, Expected Match Text, Debug

    // Basic quantifiers: + (one or more)
    { '/\d+/', '123', '3', '1', '4', '123', 'false' },
    { '/\w+/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\D+/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\W+/', ' ', '1', '1', '2', ' ', 'false' },

    // Basic quantifiers: * (zero or more)
    { '/\w*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\D*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\S*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\s*/', ' ', '1', '1', '2', ' ', 'false' },
    { '/.*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/.*/', '', '0', '1', '1', '', 'false' },  // Should match epsilon

    // Basic quantifiers: ? (zero or one)
    { '/\d?/', '1', '1', '1', '2', '1', 'false' },
    { '/\w?/', 'x', '1', '1', '2', 'x', 'false' },

    // Mixed quantifiers
    { '/\d\w?\s/', '1a ', '3', '1', '4', '1a ', 'false' },
    { '/\d\w\s+/', '1a ', '3', '1', '4', '1a ', 'false' },
    { '/\d?\w\s*/', 'a ', '2', '1', '3', 'a ', 'false' },
    { '/\s/', ' ', '1', '1', '2', ' ', 'false' },
    { '/\s+/', ' ', '1', '1', '2', ' ', 'false' },
    { '/\D\s/', 'abc ', '2', '3', '5', 'c ', 'false' },

    // Character classes with ranges
    { '/[a-z]+/', 'hello', '5', '1', '6', 'hello', 'false' },
    { '/[A-Z]+/', 'WORLD', '5', '1', '6', 'WORLD', 'false' },
    { '/[0-9]+/', '42', '2', '1', '3', '42', 'false' },
    { '/[a-zA-Z]+/', 'TestCase', '8', '1', '9', 'TestCase', 'false' },
    { '/[a-z0-9]+/', 'test123', '7', '1', '8', 'test123', 'false' },

    // Negated character classes
    { '/[^0-9]+/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/[^a-z]+/', 'ABC123', '6', '1', '7', 'ABC123', 'false' },
    { '/[^\s]+/', 'word', '4', '1', '5', 'word', 'false' },
    { '/[^"]*/', 'test', '4', '1', '5', 'test', 'false' },

    // Anchors: ^ (begin)
    { '/^abc/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/^\d+/', '123abc', '3', '1', '4', '123', 'false' },
    { '/^\w+/', 'test', '4', '1', '5', 'test', 'false' },

    // Anchors: $ (end)
    { '/abc$/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\d+$/', 'abc123', '3', '4', '7', '123', 'false' },

    // Both anchors
    { '/^abc$/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/^[a-zA-Z0-9_]+$/', 'abc123_', '7', '1', '8', 'abc123_', 'false' },
    { '/^[Hh]ello,\s[Ww]orld!$/', 'Hello, World!', '13', '1', '14', 'Hello, World!', 'false' },
    { '/^\d+$/', '12345', '5', '1', '6', '12345', 'false' },

    // Escaped special characters
    { '/\./', '.', '1', '1', '2', '.', 'false' },
    { '/\.\d+/', '.5', '2', '1', '3', '.5', 'false' },
    { '/\d+\.\d+/', '3.14', '4', '1', '5', '3.14', 'false' },
    { '/\\\d+/', '\1', '2', '1', '3', '\1', 'false' },  // Backslash literal

    // Quoted strings
    { '/^"[^"]*"/', '"abc"', '5', '1', '6', '"abc"', 'false' },
    { '/^"[^"]*"$/', '"hello world"', '13', '1', '14', '"hello world"', 'false' },
    { '/"[^"]*"/', 'say "hello"', '7', '5', '12', '"hello"', 'false' },

    // Word boundaries
    { '/\btest\b/', 'test', '4', '1', '5', 'test', 'false' },
    { '/\btest\b/', 'this is a test case', '4', '11', '15', 'test', 'false' },
    { '/\b\w+\b/', 'word', '4', '1', '5', 'word', 'false' },

    // Non-word boundaries
    { '/\Btest/', 'contest', '4', '4', '8', 'test', 'false' },  // Should fail - \B not implemented
    { '/test\B/', 'testing', '4', '1', '5', 'test', 'false' },  // Should fail - \B not implemented

    // Special whitespace characters
    { '/\t/', '	', '1', '1', '2', '	', 'false' },  // Tab character
    // { '/\n/', "$0A", '1', '1', '2', "$0A", 'false' },  // Newline - COMMENTED OUT
    // { '/\r/', "$0D", '1', '1', '2', "$0D", 'false' },  // Carriage return - COMMENTED OUT
    { '/\s+/', "  	", '3', '1', '4', "  	", 'false' },  // Mixed whitespace

    // Complex patterns
    { '/\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/', '192.168.1.10', '12', '1', '13', '192.168.1.10', 'false' },
    { '/[a-z]+@[a-z]+\.[a-z]+/', 'test@example.com', '16', '1', '17', 'test@example.com', 'false' },
    { '/\w+\s\w+/', 'hello world', '11', '1', '12', 'hello world', 'false' },
    { '/[A-Z][a-z]+/', 'Hello', '5', '1', '6', 'Hello', 'false' },
    { '/\d+[a-z]*/', '123abc', '6', '1', '7', '123abc', 'false' },

    // Multiple digit patterns
    { '/\d\d/', '42', '2', '1', '3', '42', 'false' },
    { '/\d\d\d/', '999', '3', '1', '4', '999', 'false' },

    // Character class literals
    { '/[abc]+/', 'abba', '4', '1', '5', 'abba', 'false' },
    { '/[xyz]+/', 'xyz', '3', '1', '4', 'xyz', 'false' },
    { '/[.]+/', '...', '3', '1', '4', '...', 'false' },

    // Edge cases with positioning
    { '/\d+/', 'abc123def', '3', '4', '7', '123', 'false' },  // Not at start
    { '/\w+/', '  test', '4', '3', '7', 'test', 'false' },  // After whitespace
    { '/[a-z]+/', '123abc', '3', '4', '7', 'abc', 'false' },  // After digits

    // ==================== NEGATIVE TEST CASES (Should NOT match) ====================

    // Begin anchor failures
    { '/^abc/', 'xabc', '0', '0', '0', '', 'false' },  // Text doesn't start with pattern
    { '/^\d+/', 'abc123', '0', '0', '0', '', 'false' },  // Text starts with letters not digits
    { '/^[A-Z]/', 'test', '0', '0', '0', '', 'false' },  // Text starts with lowercase

    // End anchor failures
    { '/abc$/', 'abcx', '0', '0', '0', '', 'false' },  // Text doesn't end with pattern
    { '/\d+$/', '123abc', '0', '0', '0', '', 'false' },  // Text ends with letters not digits

    // Full string match failures
    { '/^abc$/', 'abcd', '0', '0', '0', '', 'false' },  // Extra character at end
    { '/^\d+$/', '123abc', '0', '0', '0', '', 'false' },  // Mixed content
    { '/^[a-z]+$/', 'Test', '0', '0', '0', '', 'false' },  // Contains uppercase

    // Required quantifier failures (+ requires at least one)
    { '/\d+/', 'abc', '0', '0', '0', '', 'false' },  // No digits
    { '/[A-Z]+/', 'test', '0', '0', '0', '', 'false' },  // No uppercase

    // Character class mismatch
    { '/[0-9]+/', 'abc', '0', '0', '0', '', 'false' },  // No digits in text
    { '/[a-z]+/', '123', '0', '0', '0', '', 'false' },  // No lowercase in text

    // Word boundary failures
    { '/\btest\b/', 'testing', '0', '0', '0', '', 'false' },  // 'test' is not a complete word
    { '/\btest\b/', 'atest', '0', '0', '0', '', 'false' },  // 'test' not at word boundary

    // Pattern too specific
    { '/\d\d\d/', '12', '0', '0', '0', '', 'false' },  // Need 3 digits, only have 2
    { '/test\s+case/', 'testcase', '0', '0', '0', '', 'false' }  // Missing required space
}

constant char REGEX_MATCH_EXPECTED_RESULT[] = {
    // Tests 1-43: Should all match (true)
    true,  // 1
    true,  // 2
    true,  // 3
    true,  // 4
    true,  // 5
    true,  // 6
    true,  // 7
    true,  // 8
    true,  // 9
    true,  // 10
    true,  // 11
    true,  // 12
    true,  // 13
    true,  // 14
    true,  // 15
    true,  // 16
    true,  // 17
    true,  // 18
    true,  // 19
    true,  // 20
    true,  // 21
    true,  // 22
    true,  // 23
    true,  // 24
    true,  // 25
    true,  // 26
    true,  // 27
    true,  // 28
    true,  // 29
    true,  // 30
    true,  // 31
    true,  // 32
    true,  // 33
    true,  // 34
    true,  // 35
    true,  // 36
    true,  // 37
    true,  // 38
    true,  // 39
    true,  // 40
    true,  // 41
    true,  // 42
    true,  // 43

    // Tests 44-51: Word boundaries work, non-word boundaries work, special whitespace works!
    true,  // 44 - Word boundary \btest\b
    true,  // 45 - Word boundary \btest\b
    true,  // 46 - Word boundary \b\w+\b
    true,  // 47 - Non-word boundary \Btest
    true,  // 48 - Non-word boundary test\B
    true,  // 49 - Tab character \t
    // true,  // 50 - Newline \n - COMMENTED OUT
    // true,  // 51 - Carriage return \r - COMMENTED OUT

    // Tests 50-63: Should match (true)
    true,  // 50
    true,  // 51
    true,  // 52
    true,  // 53
    true,  // 54
    true,  // 55
    true,  // 56
    true,  // 57
    true,  // 58
    true,  // 59
    true,  // 60
    true,  // 61
    true,  // 62
    true,  // 63

    // Tests 64-83: Should NOT match (false) - Negative tests
    false, // 64 - Begin anchor failure (^abc vs xabc)
    false, // 65 - Begin anchor failure (^\d+ vs abc123)
    false, // 66 - Begin anchor failure (^[A-Z] vs test)
    false, // 67 - End anchor failure (abc$ vs abcx)
    false, // 68 - End anchor failure (\d+$ vs 123abc)
    false, // 69 - Full string match failure (^abc$ vs abcd)
    false, // 70 - Full string match failure (^\d+$ vs 123abc)
    false, // 71 - Full string match failure (^[a-z]+$ vs Test)
    false, // 72 - Required quantifier failure (\d+ vs abc)
    false, // 73 - Required quantifier failure ([A-Z]+ vs test)
    false, // 74 - Character class mismatch ([0-9]+ vs abc)
    false, // 75 - Character class mismatch ([a-z]+ vs 123)
    false, // 76 - Word boundary failure (\btest\b vs testing)
    false, // 77 - Word boundary failure (\btest\b vs atest)
    false, // 78 - Pattern too specific (\d\d\d vs 12)
    false  // 79 - Pattern too specific (test\s+case vs testcase)
}

define_function TestNAVRegexMatch() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatch *****************'")

    for (x = 1; x <= length_array(REGEX_MATCH_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char result
        stack_var char failed

        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatch expected

        failed = false

        pattern = REGEX_MATCH_TEST[x][1]
        text = REGEX_MATCH_TEST[x][2]

        expected.length = atoi(REGEX_MATCH_TEST[x][3])
        expected.start = atoi(REGEX_MATCH_TEST[x][4])
        expected.end = atoi(REGEX_MATCH_TEST[x][5])
        expected.text = REGEX_MATCH_TEST[x][6]

        // Set the debug flag
        match.debug = (REGEX_MATCH_TEST[x][7] == 'true')

        result = NAVRegexMatch(pattern, text, match)

        if (!NAVAssertBooleanEqual('Should return the expected result', REGEX_MATCH_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(REGEX_MATCH_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!REGEX_MATCH_EXPECTED_RESULT[x]) {
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
