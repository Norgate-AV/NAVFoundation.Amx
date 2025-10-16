#DEFINE TESTING_REGEX_COMPILE
#DEFINE TESTING_REGEX_MATCH
#DEFINE TESTING_REGEX_MATCH_GROUPS
// #DEFINE TESTING_REGEX_MATCH_COMPILED
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_REGEX_COMPILE
#include 'NAVRegexCompileBasic.axi'
#include 'NAVRegexCompileCharClasses.axi'
#include 'NAVRegexCompileBoundedQuantifiers.axi'
#include 'NAVRegexCompileGroups.axi'
#include 'NAVRegexCompileNamedGroups.axi'
#include 'NAVRegexCompileNonCapturingGroups.axi'
#include 'NAVRegexCompileErrors.axi'
#include 'NAVRegexCompileGroupErrors.axi'
#END_IF

#IF_DEFINED TESTING_REGEX_MATCH_GROUPS
#include 'NAVRegexMatchCapturingGroups.axi'
#include 'NAVRegexMatchNamedGroups.axi'
#include 'NAVRegexMatchNonCapturingGroups.axi'
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
    TestNAVRegexCompileBasic()
    TestNAVRegexCompileCharClasses()
    TestNAVRegexCompileBoundedQuantifiers()
    TestNAVRegexCompileGroups()
    TestNAVRegexCompileNamedGroups()
    TestNAVRegexCompileNonCapturingGroups()
    TestNAVRegexCompileErrors()
    TestNAVRegexCompileGroupErrors()
    #END_IF

    #IF_DEFINED TESTING_REGEX_MATCH_GROUPS
    TestNAVRegexMatchCapturingGroups()
    TestNAVRegexMatchNamedGroups()
    TestNAVRegexMatchNonCapturingGroups()
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
