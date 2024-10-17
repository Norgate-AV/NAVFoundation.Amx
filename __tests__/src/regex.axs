PROGRAM_NAME='regex'

#DEFINE __MAIN__
#DEFINE TESTING_REGEX_COMPILE
#DEFINE TESTING_REGEX_MATCH
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_REGEX_COMPILE
#include 'NAVRegexCompile.axi'
#END_IF

#IF_DEFINED TESTING_REGEX_MATCH
#include 'NAVRegexMatch.axi'
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
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
