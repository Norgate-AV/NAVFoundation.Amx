#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.RegEx.axi'

define_function RunRegexTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running Regular Expression Tests ====='");

    // Test simple pattern matching
    TestSimplePatterns();

    // Test character classes
    TestCharacterClasses();

    // Test quantifiers
    TestQuantifiers();

    // Test capturing groups
    TestCapturingGroups();

    // Test anchors
    TestAnchors();

    // Test complex patterns
    TestComplexPatterns();

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'All RegEx tests completed'");
}

define_function TestSimplePatterns() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing simple patterns'");

    // Test exact match
    TestRegexMatch('abc', 'abc', 'Exact match');
    TestRegexMatch('abc', 'abcd', 'Substring match');
    TestRegexMatch('abc', 'xabc', 'Substring match at end');
    TestRegexMatch('abc', 'ABC', 'Case sensitive match (should fail)');

    // Test alternation
    TestRegexMatch('cat|dog', 'cat', 'Alternation - first option');
    TestRegexMatch('cat|dog', 'dog', 'Alternation - second option');
    TestRegexMatch('cat|dog', 'bird', 'Alternation - no match (should fail)');

    // Test dot character
    TestRegexMatch('a.c', 'abc', 'Dot character - letter');
    TestRegexMatch('a.c', 'a1c', 'Dot character - number');
    TestRegexMatch('a.c', 'a c', 'Dot character - space');
    TestRegexMatch('a.c', 'ac', 'Dot character - missing character (should fail)');
}

define_function TestCharacterClasses() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing character classes'");

    // Test digit character class
    TestRegexMatch('[0-9]+', '123', 'Digit character class');
    TestRegexMatch('[0-9]+', 'abc', 'Digit character class (should fail)');

    // Test letter character class
    TestRegexMatch('[a-zA-Z]+', 'Hello', 'Letter character class');
    TestRegexMatch('[a-zA-Z]+', '123', 'Letter character class (should fail)');

    // Test negated character class
    TestRegexMatch('[^0-9]+', 'abc', 'Negated digit character class');
    TestRegexMatch('[^0-9]+', '123', 'Negated digit character class (should fail)');

    // Test shorthand character classes
    TestRegexMatch('\\d+', '123', 'Shorthand digit class');
    TestRegexMatch('\\w+', 'abc123', 'Shorthand word character class');
    TestRegexMatch('\\s+', '   ', 'Shorthand whitespace class');
}

define_function TestQuantifiers() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing quantifiers'");

    // Test star quantifier (0 or more)
    TestRegexMatch('a*', '', 'Star quantifier - empty string');
    TestRegexMatch('a*', 'a', 'Star quantifier - single occurrence');
    TestRegexMatch('a*', 'aaa', 'Star quantifier - multiple occurrences');

    // Test plus quantifier (1 or more)
    TestRegexMatch('a+', 'a', 'Plus quantifier - single occurrence');
    TestRegexMatch('a+', 'aaa', 'Plus quantifier - multiple occurrences');
    TestRegexMatch('a+', '', 'Plus quantifier - empty string (should fail)');

    // Test question mark quantifier (0 or 1)
    TestRegexMatch('a?', '', 'Question mark quantifier - empty string');
    TestRegexMatch('a?', 'a', 'Question mark quantifier - single occurrence');
    TestRegexMatch('a?', 'aa', 'Question mark quantifier - multiple occurrences (should match first only)');

    // Test specific quantity
    TestRegexMatch('a{3}', 'aaa', 'Exact quantity - correct count');
    TestRegexMatch('a{3}', 'aa', 'Exact quantity - insufficient count (should fail)');
    TestRegexMatch('a{3}', 'aaaa', 'Exact quantity - excess count (should match first three)');

    // Test range quantity
    TestRegexMatch('a{2,4}', 'aa', 'Range quantity - minimum count');
    TestRegexMatch('a{2,4}', 'aaaa', 'Range quantity - maximum count');
    TestRegexMatch('a{2,4}', 'a', 'Range quantity - below minimum (should fail)');
    TestRegexMatch('a{2,4}', 'aaaaa', 'Range quantity - above maximum (should match first four)');
}

define_function TestCapturingGroups() {
    stack_var NAVRegexMatches matches;
    stack_var integer i;

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing capturing groups'");

    // Test simple capturing group
    if (NAVRegexMatch('(abc)', 'abc', matches)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Simple capturing group test passed'");
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Full match: ', matches.match");
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Group 1: ', matches.groups[1]");
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Simple capturing group test failed'");
    }

    // Test multiple capturing groups
    if (NAVRegexMatch('(\\w+)\\s+(\\w+)', 'Hello World', matches)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Multiple capturing groups test passed'");
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Full match: ', matches.match");
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Group 1: ', matches.groups[1]");
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Group 2: ', matches.groups[2]");
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Multiple capturing groups test failed'");
    }

    // Test nested capturing groups
    if (NAVRegexMatch('(a(b(c)))', 'abc', matches)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Nested capturing groups test passed'");
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Full match: ', matches.match");
        for (i = 1; i <= matches.count; i++) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Group ', itoa(i), ': ', matches.groups[i]");
        }
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Nested capturing groups test failed'");
    }
}

define_function TestAnchors() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing anchors'");

    // Test start anchor
    TestRegexMatch('^abc', 'abc', 'Start anchor - at start');
    TestRegexMatch('^abc', 'xabc', 'Start anchor - not at start (should fail)');

    // Test end anchor
    TestRegexMatch('abc$', 'abc', 'End anchor - at end');
    TestRegexMatch('abc$', 'abcx', 'End anchor - not at end (should fail)');

    // Test both anchors
    TestRegexMatch('^abc$', 'abc', 'Both anchors - exact match');
    TestRegexMatch('^abc$', 'abcd', 'Both anchors - longer string (should fail)');
    TestRegexMatch('^abc$', 'xabc', 'Both anchors - prefix (should fail)');
    TestRegexMatch('^abc$', 'xabcy', 'Both anchors - both prefix and suffix (should fail)');
}

define_function TestComplexPatterns() {
    stack_var NAVRegexMatches matches;

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing complex patterns'");

    // Email pattern
    TestRegexMatch('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}', 'user@example.com', 'Email pattern - valid');
    TestRegexMatch('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}', 'user@example', 'Email pattern - missing TLD (should fail)');

    // IP address pattern
    TestRegexMatch('(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)', '192.168.1.1', 'IP address pattern - valid');
    TestRegexMatch('(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)', '192.168.1.256', 'IP address pattern - invalid octet (should fail)');

    // Date pattern (YYYY-MM-DD)
    TestRegexMatch('\\d{4}-\\d{2}-\\d{2}', '2023-05-15', 'Date pattern - valid');
    TestRegexMatch('\\d{4}-\\d{2}-\\d{2}', '23-05-15', 'Date pattern - short year (should fail)');

    // Extract components from URL
    if (NAVRegexMatch('(https?://)([^/]+)(/.*)?', 'https://www.example.com/path', matches)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  URL extraction test passed'");
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Protocol: ', matches.groups[1]");
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Domain: ', matches.groups[2]");
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Path: ', matches.groups[3]");
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  URL extraction test failed'");
    }
}

define_function TestRegexMatch(char pattern[], char input[], char description[]) {
    stack_var integer result;

    result = NAVRegexTest(pattern, input);

    if (result) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  ', description, ': Match found'");
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  ', description, ': No match'");
    }
}
