PROGRAM_NAME='NAVRegexMatchNamedGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char MATCH_NAMED_GROUPS_TEST[][][255] = {
    // Pattern, Test Text, Expected Count, Group 1 Text, Group 2 Text, Group 3 Text, Group 4 Text, Group 5 Text
    { '/(?P<word>\w+)/', 'hello', '2', 'hello', 'hello', '', '', '' },
    { '/(?<word>\w+)/', 'world', '2', 'world', 'world', '', '', '' },
    { '/(?P<user>\w+)@(?P<domain>\w+)/', 'john@example', '3', 'john@example', 'john', 'example', '', '' },
    { '/(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})/', '2025-10-16', '4', '2025-10-16', '2025', '10', '16', '' },
    { '/(?<oct1>\d+)\.(?<oct2>\d+)\.(?<oct3>\d+)\.(?<oct4>\d+)/', '192.168.1.1', '5', '192.168.1.1', '192', '168', '1', '1' },
    { '/(?P<digits>\d+)/', '12345', '2', '12345', '12345', '', '', '' },
    { '/a(?P<middle>bc)?d/', 'ad', '2', 'ad', '', '', '', '' },
    { '/a(?P<middle>bc)?d/', 'abcd', '2', 'abcd', 'bc', '', '', '' },
    { '/(?P<outer>a(?P<inner>b)c)/', 'abc', '3', 'abc', 'abc', 'b', '', '' },
    { '/(?P<letters>[a-z]+)/', 'test', '2', 'test', 'test', '', '', '' }
}


define_function TestNAVRegexMatchNamedGroups() {
    // stack_var integer x

    // NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexMatchNamedGroups *****************'")

    // for (x = 1; x <= length_array(MATCH_NAMED_GROUPS_TEST); x++) {
    //     stack_var char pattern[255]
    //     stack_var char text[255]
    //     stack_var integer expectedCount
    //     stack_var char expectedMatches[5][255]
    //     stack_var char failed
    //     stack_var integer i

    //     stack_var _NAVRegexParser parser
    //     stack_var _NAVRegexMatchResult match

    //     failed = false

    //     pattern = MATCH_NAMED_GROUPS_TEST[x][1]
    //     text = MATCH_NAMED_GROUPS_TEST[x][2]
    //     expectedCount = atoi(MATCH_NAMED_GROUPS_TEST[x][3])

    //     for (i = 1; i <= 5; i++) {
    //         expectedMatches[i] = MATCH_NAMED_GROUPS_TEST[x][3 + i]
    //     }

    //     if (!NAVRegexCompile(pattern, parser)) {
    //         NAVLog("'Test ', itoa(x), ' failed'")
    //         NAVLog("'Failed to compile pattern: "', pattern, '"'")
    //         continue
    //     }

    //     NAVRegexMatchCompiled(parser, text, match)

    //     if (match.count != expectedCount) {
    //         failed = true
    //         NAVLog("'Expected match.count: ', itoa(expectedCount), ' but got ', itoa(match.count)")
    //     }

    //     for (i = 1; i <= expectedCount; i++) {
    //         if (match.matches[i].text != expectedMatches[i]) {
    //             failed = true
    //             NAVLog("'Expected match.matches[', itoa(i), '].text: "', expectedMatches[i], '" but got "', match.matches[i].text, '"'")
    //         }
    //     }

    //     if (failed) {
    //         NAVLog("'Test ', itoa(x), ' failed'")
    //         continue
    //     }

    //     NAVLogTestPassed(x)
    // }
}
