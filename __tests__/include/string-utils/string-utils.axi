#DEFINE TESTING_NAVGETSTRINGBETWEEN
#DEFINE TESTING_NAVSTRINGSUBSTRING
#DEFINE TESTING_NAVSTRINGSLICE
#DEFINE TESTING_NAVSPLITSTRING
#DEFINE TESTING_NAVSTRINGCASECONVERSION
#DEFINE TESTING_NAVSTRINGREPLACE
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVGETSTRINGBETWEEN
#include 'NAVGetStringBetween.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGSUBSTRING
#include 'NAVStringSubstring.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGSLICE
#include 'NAVStringSlice.axi'
#END_IF

#IF_DEFINED TESTING_NAVSPLITSTRING
#include 'NAVSplitString.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGCASECONVERSION
#include 'NAVStringCaseConversion.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGREPLACE
#include 'NAVStringReplace.axi'
#END_IF

define_function RunStringUtilsTests() {
    #IF_DEFINED TESTING_NAVGETSTRINGBETWEEN
    TestNAVGetStringBetween()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGSUBSTRING
    TestNAVStringSubstring()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGSLICE
    TestNAVStringSlice()
    #END_IF

    #IF_DEFINED TESTING_NAVSPLITSTRING
    TestNAVSplitString()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGCASECONVERSION
    TestNAVStringPascalCase()
    TestNAVStringCamelCase()
    TestNAVStringSnakeCase()
    TestNAVStringKebabCase()
    TestNAVStringTrainCase()
    TestNAVStringScreamKebabCase()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGREPLACE
    TestNAVStringReplace()
    #END_IF
}
