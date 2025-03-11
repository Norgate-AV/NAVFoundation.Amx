#DEFINE TESTING_REGEX_COMPILE
#DEFINE TESTING_REGEX_MATCH
// #DEFINE TESTING_REGEX_MATCH_COMPILED
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


define_function RunRegexTests() {
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
