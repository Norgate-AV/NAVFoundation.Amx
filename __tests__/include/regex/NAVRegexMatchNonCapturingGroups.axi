PROGRAM_NAME='NAVRegexMatchNonCapturingGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char MATCH_NON_CAPTURING_GROUPS_TEST[][][255] = {
    // Pattern, Test Text, Expected Count, Group 1 Text, Group 2 Text, Group 3 Text, Group 4 Text, Group 5 Text, Debug
    { '/(?:abc)/', 'abc', '1', 'abc', '', '', '', '', 'false' },
    { '/x(?:abc)y/', 'xabcy', '1', 'xabcy', '', '', '', '', 'false' },
    { '/(?:abc)(def)/', 'abcdef', '2', 'abcdef', 'def', '', '', '', 'false' },
    { '/(?:abc)(?:def)/', 'abcdef', '1', 'abcdef', '', '', '', '', 'false' },
    { '/(?:ab)+/', 'abab', '1', 'abab', '', '', '', '', 'false' },
    { '/(?:(?:a)b)/', 'ab', '1', 'ab', '', '', '', '', 'false' },
    { '/(?:(abc)def)/', 'abcdef', '2', 'abcdef', 'abc', '', '', '', 'false' },
    { '/((?:abc)def)/', 'abcdef', '2', 'abcdef', 'abcdef', '', '', '', 'false' },
    { '/(a)(?:b)(c)/', 'abc', '3', 'abc', 'a', 'c', '', '', 'false' },
    { '/(?:\d+)\.(\d+)/', '123.456', '2', '123.456', '456', '', '', '', 'false' },
    { '/(?:ab)*c/', 'ababc', '1', 'ababc', '', '', '', '', 'false' },
    { '/a(?:bc)?d/', 'ad', '1', 'ad', '', '', '', '', 'false' },
    { '/(?P<user>\w+)@(?:\w+\.)?([\w]+)/', 'john@mail.example', '3', 'john@mail.example', 'john', 'example', '', '', 'false' }
}


define_function TestNAVRegexMatchNonCapturingGroups() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexMatchNonCapturingGroups *****************'")

    for (x = 1; x <= length_array(MATCH_NON_CAPTURING_GROUPS_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var integer expectedCount
        stack_var char expectedMatches[5][255]
        stack_var char failed
        stack_var integer i

        stack_var _NAVRegexParser parser
        stack_var _NAVRegexMatchResult match

        failed = false

        pattern = MATCH_NON_CAPTURING_GROUPS_TEST[x][1]
        text = MATCH_NON_CAPTURING_GROUPS_TEST[x][2]
        expectedCount = atoi(MATCH_NON_CAPTURING_GROUPS_TEST[x][3])

        parser.debug = (MATCH_NON_CAPTURING_GROUPS_TEST[x][9] == 'true')

        for (i = 1; i <= 5; i++) {
            expectedMatches[i] = MATCH_NON_CAPTURING_GROUPS_TEST[x][3 + i]
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
