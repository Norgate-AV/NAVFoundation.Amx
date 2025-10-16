PROGRAM_NAME='NAVRegexMatchCapturingGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char MATCH_CAPTURING_GROUPS_TEST[][][255] = {
    // Pattern, Test Text, Expected Count, Group 1 Text, Group 2 Text, Group 3 Text, Group 4 Text, Group 5 Text
    { '/(abc)/', 'abc', '2', 'abc', 'abc', '', '', '' },
    { '/x(abc)y/', 'xabcy', '2', 'xabcy', 'abc', '', '', '' },
    { '/(abc)(def)/', 'abcdef', '3', 'abcdef', 'abc', 'def', '', '' },
    { '/(a(b)c)/', 'abc', '3', 'abc', 'abc', 'b', '', '' },
    { '/(a+)/', 'aaa', '2', 'aaa', 'aaa', '', '', '' },
    { '/(\d+)/', '123', '2', '123', '123', '', '', '' },
    { '/(\d+)\.(\d+)/', '123.456', '3', '123.456', '123', '456', '', '' },
    { '/(\w+)@(\w+)/', 'user@domain', '3', 'user@domain', 'user', 'domain', '', '' },
    { '/a(bc)?d/', 'ad', '2', 'ad', '', '', '', '' },
    { '/a(bc)?d/', 'abcd', '2', 'abcd', 'bc', '', '', '' },
    { '/([a-z]+)/', 'hello', '2', 'hello', 'hello', '', '', '' },
    { '/(a)(b)(c)/', 'abc', '4', 'abc', 'a', 'b', 'c', '' },
    { '/(abc)+/', 'abc', '2', 'abc', 'abc', '', '', '' },
    { '/(abc)+/', 'abcabcabc', '2', 'abcabcabc', 'abc', '', '', '' },
    { '/(ab)*c/', 'ababc', '2', 'ababc', 'ab', '', '', '' }
}


define_function TestNAVRegexMatchCapturingGroups() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexMatchCapturingGroups *****************'")

    for (x = 1; x <= length_array(MATCH_CAPTURING_GROUPS_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var integer expectedCount
        stack_var char expectedMatches[5][255]
        stack_var char failed
        stack_var integer i

        stack_var _NAVRegexParser parser
        stack_var _NAVRegexMatchResult match

        failed = false

        pattern = MATCH_CAPTURING_GROUPS_TEST[x][1]
        text = MATCH_CAPTURING_GROUPS_TEST[x][2]
        expectedCount = atoi(MATCH_CAPTURING_GROUPS_TEST[x][3])

        for (i = 1; i <= 5; i++) {
            expectedMatches[i] = MATCH_CAPTURING_GROUPS_TEST[x][3 + i]
        }

        if (!NAVRegexCompile(pattern, parser)) {
            NAVLog("'Test ', itoa(x), ' failed'")
            NAVLog("'Failed to compile pattern: "', pattern, '"'")
            continue
        }

        NAVRegexMatchCompiled(parser, text, match)

        if (match.count != expectedCount) {
            failed = true
            NAVLog("'Expected match.count: ', itoa(expectedCount), ' but got ', itoa(match.count)")
        }

        for (i = 1; i <= expectedCount; i++) {
            if (match.matches[i].text != expectedMatches[i]) {
                failed = true
                NAVLog("'Expected match.matches[', itoa(i), '].text: "', expectedMatches[i], '" but got "', match.matches[i].text, '"'")
            }
        }

        if (failed) {
            NAVLog("'Test ', itoa(x), ' failed'")
            continue
        }

        NAVLogTestPassed(x)
    }
}
