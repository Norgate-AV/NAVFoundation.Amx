#DEFINE TESTING_NAVGETSTRINGBETWEEN
#DEFINE TESTING_NAVSTRINGSUBSTRING
#DEFINE TESTING_NAVSTRINGSLICE
#DEFINE TESTING_NAVSPLITSTRING
#DEFINE TESTING_NAVSTRINGCASECONVERSION
#DEFINE TESTING_NAVSTRINGREPLACE
#DEFINE TESTING_NAVSTRIPFUNCTIONS
#DEFINE TESTING_NAVTRIMFUNCTIONS
#DEFINE TESTING_NAVCHARACTERFUNCTIONS
#DEFINE TESTING_NAVSTRINGBEFOREAFTER
#DEFINE TESTING_NAVSTRINGSTARTSENDSWITH
#DEFINE TESTING_NAVINDEXOF
#DEFINE TESTING_NAVSTRINGCOUNT
#DEFINE TESTING_NAVSTRINGADVANCED
#DEFINE TESTING_NAVSTRINGUTILITY
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

#IF_DEFINED TESTING_NAVSTRIPFUNCTIONS
#include 'NAVStripFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVTRIMFUNCTIONS
#include 'NAVTrimFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVCHARACTERFUNCTIONS
#include 'NAVCharacterFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGBEFOREAFTER
#include 'NAVStringBeforeAfter.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGSTARTSENDSWITH
#include 'NAVStringStartsEndsWith.axi'
#END_IF

#IF_DEFINED TESTING_NAVINDEXOF
#include 'NAVIndexOf.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGCOUNT
#include 'NAVStringCount.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGADVANCED
#include 'NAVStringAdvanced.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGUTILITY
#include 'NAVStringUtility.axi'
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

    #IF_DEFINED TESTING_NAVSTRIPFUNCTIONS
    TestNAVStripCharsFromRight()
    TestNAVStripCharsFromLeft()
    TestNAVRemoveStringByLength()
    #END_IF

    #IF_DEFINED TESTING_NAVTRIMFUNCTIONS
    TestNAVTrimStringLeft()
    TestNAVTrimStringRight()
    TestNAVTrimString()
    TestNAVTrimStringArray()
    #END_IF

    #IF_DEFINED TESTING_NAVCHARACTERFUNCTIONS
    TestNAVIsWhitespace()
    TestNAVIsAlpha()
    TestNAVIsDigit()
    TestNAVIsAlphaNumeric()
    TestNAVIsUpperCase()
    TestNAVIsLowerCase()
    TestNAVCharToLower()
    TestNAVCharToUpper()
    TestNAVCharCodeAt()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGBEFOREAFTER
    TestNAVGetStringBefore()
    TestNAVGetStringAfter()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGSTARTSENDSWITH
    TestNAVStartsWith()
    TestNAVEndsWith()
    TestNAVContains()
    TestNAVContainsCaseInsensitive()
    #END_IF

    #IF_DEFINED TESTING_NAVINDEXOF
    TestNAVIndexOf()
    TestNAVLastIndexOf()
    TestNAVIndexOfCaseInsensitive()
    TestNAVLastIndexOfCaseInsensitive()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGCOUNT
    TestNAVStringCount()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGADVANCED
    TestNAVArrayJoinString()
    TestNAVStringToLongMilliseconds()
    TestNAVGetTimeSpan()
    TestNAVStringCompare()
    TestNAVStringSurroundWith()
    TestNAVStringGather()
    TestNAVGetStringBetweenGreedy()
    TestNAVFindAndReplace()
    TestNAVStringNormalizeAndReplace()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGUTILITY
    TestNAVStringCapitalize()
    TestNAVStringReverse()
    TestNAVInsertSpacesBeforeUppercase()
    #END_IF
}
