#DEFINE TESTING_REGEX_COMPILE
// #DEFINE TESTING_REGEX_MATCH
// #DEFINE TESTING_REGEX_MATCH_COMPILED
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_REGEX_COMPILE
#include 'NAVRegexCompile.axi'
#END_IF

#IF_DEFINED TESTING_REGEX_MATCH
#include 'NAVRegexMatchQuantifiers.axi'
#include 'NAVRegexMatchBoundedQuantifiers.axi'
#include 'NAVRegexMatchCharClasses.axi'
#include 'NAVRegexMatchAnchors.axi'
#include 'NAVRegexMatchBoundaries.axi'
#include 'NAVRegexMatchComplex.axi'
#include 'NAVRegexMatchNegative.axi'
#include 'NAVRegexMatchEscapedChars.axi'
#END_IF

#IF_DEFINED TESTING_REGEX_MATCH_COMPILED
#include 'NAVRegexMatchCompiled.axi'
#END_IF


define_function RunRegexTests() {
    #IF_DEFINED TESTING_REGEX_COMPILE
    TestNAVRegexCompile()
    #END_IF

    #IF_DEFINED TESTING_REGEX_MATCH
    TestNAVRegexMatchQuantifiers()
    TestNAVRegexMatchBoundedQuantifiers()
    TestNAVRegexMatchCharClasses()
    TestNAVRegexMatchAnchors()
    TestNAVRegexMatchBoundaries()
    TestNAVRegexMatchComplex()
    TestNAVRegexMatchNegative()
    TestNAVRegexMatchEscapedChars()
    #END_IF

    #IF_DEFINED TESTING_REGEX_MATCH_COMPILED
    TestNAVRegexMatchCompiled()
    #END_IF
}
