PROGRAM_NAME='NAVRegexLexerGroupErrors'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_GROUP_ERRORS_PATTERN_TEST[][255] = {
    '/(?P<>test)/',                                      // 1: Empty group name (Python-style)
    '/(?<>test)/',                                       // 2: Empty group name (.NET-style)
    '/(?P<123>test)/',                                   // 3: Group name starting with digit (Python)
    '/(?<456>test)/',                                    // 4: Group name starting with digit (.NET)
    '/(?P<test-name>abc)/',                             // 5: Group name with hyphen (invalid)
    '/(?<test.name>abc)/',                              // 6: Group name with dot (invalid)
    '/(?P<test name>abc)/',                             // 7: Group name with space (invalid)
    '/(?P<name>test)(?P<name>test)/',                   // 8: Duplicate group names (Python)
    '/(?<user>test)(?<user>test)/',                     // 9: Duplicate group names (.NET)
    '/(?P<test',                                         // 10: Unclosed named group (Python)
    '/(?<test',                                          // 11: Unclosed named group (.NET)
    '/(?P<test>',                                        // 12: Missing closing parenthesis (Python)
    '/(?<test>',                                         // 13: Missing closing parenthesis (.NET)
    '/(?Ptest>abc)/',                                    // 14: Missing < in Python-style
    '/(?test>abc)/',                                     // 15: Missing < in .NET-style
    '/(?P<test)abc)/',                                   // 16: Missing > in Python-style
    '/(?<test)abc)/',                                    // 17: Missing > in .NET-style
    '/(?:',                                              // 18: Unclosed non-capturing group
    '/(?P<a_very_long_name_that_exceeds_maximum_length_limit_for_group_names_in_regex>test)/', // 19: Group name too long
    '/(?<$invalid>test)/',                               // 20: Group name with invalid character
    '/(?P<test@name>abc)/',                             // 21: Group name with @ symbol
    '/(?<test#name>abc)/',                              // 22: Group name with # symbol
    '/(?P<>)/',                                          // 23: Empty named group with empty name
    '/(?P<name)/',                                       // 24: Named group missing > and content
    '/(?<name)/'                                         // 25: .NET named group missing > and content
}

DEFINE_FUNCTION TestNAVRegexLexerGroupErrors() {
    stack_var integer i

    NAVLog("'***************** NAVRegexLexer - Group Error Cases *****************'")

    for (i = 1; i <= length_array(REGEX_LEXER_GROUP_ERRORS_PATTERN_TEST); i++) {
        stack_var _NAVRegexLexer lexer
        stack_var char result

        result = NAVRegexLexerTokenize(REGEX_LEXER_GROUP_ERRORS_PATTERN_TEST[i], lexer)

        if (!NAVAssertFalse('Should fail to tokenize', result)) {
            NAVLogTestFailed(i, 'false', 'true')
            continue
        }

        NAVLogTestPassed(i)
    }
}


