PROGRAM_NAME='regex'

#DEFINE __MAIN__
#DEFINE TESTING_REGEX_COMPILE
#DEFINE TESTING_REGEX_MATCH
#DEFINE TESTING_REGEX_MATCH_COMPILED
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_REGEX_COMPILE
#include 'NAVRegexCompile.axi'
#END_IF

#IF_DEFINED TESTING_REGEX_MATCH
#include 'NAVRegexMatch.axi'
#END_IF

#IF_DEFINED TESTING_REGEX_MATCH_COMPILED
#include 'NAVRegexMatchCompiled.axi'
#END_IF


DEFINE_DEVICE

dvTP    =   10001:1:0


define_function RunTests() {
    #IF_DEFINED TESTING_REGEX_COMPILE
    TestNAVRegexCompile()
    #END_IF

    #IF_DEFINED TESTING_REGEX_MATCH
    TestNAVRegexMatch()
    #END_IF

    #IF_DEFINED TESTING_REGEX_MATCH_COMPILED
    TestNAVRegexMatchCompiled()
    #END_IF
}


DEFINE_EVENT

data_event[0:1:0] {
    command: {
        switch (lower_string(data.text)) {
            case 'test': {
                RunTests()
            }
            default: {
                NAVLog("'Unknown command: "', data.text, '"'")
            }
        }
    }
}


button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
