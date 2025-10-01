#DEFINE TESTING_NAVSETARRAYFUNCTIONS
#DEFINE TESTING_NAVFINDINARRAYFUNCTIONS
#DEFINE TESTING_NAVARRAYSORTFUNCTIONS
#DEFINE TESTING_NAVARRAYUTILITYFUNCTIONS
#DEFINE TESTING_NAVARRAYMATHFUNCTIONS
#DEFINE TESTING_NAVARRAYSLICEFUNCTIONS
#DEFINE TESTING_NAVARRAYSETFUNCTIONS
#DEFINE TESTING_NAVARRAYFORMATFUNCTIONS
#DEFINE TESTING_NAVARRAYSEARCHFUNCTIONS
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ArrayUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVSETARRAYFUNCTIONS
#include 'NAVSetArrayFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVFINDINARRAYFUNCTIONS
#include 'NAVFindInArrayFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVARRAYSORTFUNCTIONS
#include 'NAVArraySortFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVARRAYUTILITYFUNCTIONS
#include 'NAVArrayUtilityFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVARRAYMATHFUNCTIONS
#include 'NAVArrayMathFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVARRAYSLICEFUNCTIONS
#include 'NAVArraySliceFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVARRAYSETFUNCTIONS
#include 'NAVArraySetFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVARRAYFORMATFUNCTIONS
#include 'NAVArrayFormatFunctions.axi'
#END_IF

#IF_DEFINED TESTING_NAVARRAYSEARCHFUNCTIONS
#include 'NAVArraySearchFunctions.axi'
#END_IF

define_function RunArrayUtilsTests() {
    #IF_DEFINED TESTING_NAVSETARRAYFUNCTIONS
    TestNAVSetArrayChar()
    TestNAVSetArrayInteger()
    TestNAVSetArraySignedInteger()
    TestNAVSetArrayLong()
    TestNAVSetArraySignedLong()
    TestNAVSetArrayFloat()
    TestNAVSetArrayDouble()
    TestNAVSetArrayString()
    #END_IF

    #IF_DEFINED TESTING_NAVFINDINARRAYFUNCTIONS
    TestNAVFindInArrayINTEGER()
    TestNAVFindInArrayCHAR()
    TestNAVFindInArraySTRING()
    TestNAVFindInArrayLONG()
    TestNAVFindInArrayFLOAT()
    #END_IF

    #IF_DEFINED TESTING_NAVARRAYSORTFUNCTIONS
    TestNAVArrayBubbleSortInteger()
    TestNAVArraySelectionSortInteger()
    TestNAVArraySelectionSortString()
    TestNAVArrayInsertionSortInteger()
    TestNAVArrayQuickSortInteger()
    TestNAVArrayMergeSortInteger()
    TestNAVArrayCountingSortInteger()
    #END_IF

    #IF_DEFINED TESTING_NAVARRAYUTILITYFUNCTIONS
    TestNAVArrayReverseInteger()
    TestNAVArrayReverseString()
    TestNAVArrayCopyInteger()
    TestNAVArrayCopyString()
    TestNAVArrayIsSortedInteger()
    TestNAVArrayIsSortedString()
    TestNAVArrayToLowerString()
    TestNAVArrayToUpperString()
    TestNAVArrayTrimString()
    #END_IF

    #IF_DEFINED TESTING_NAVARRAYMATHFUNCTIONS
    TestNAVArraySumInteger()
    TestNAVArraySumSignedInteger()
    TestNAVArraySumLong()
    TestNAVArraySumFloat()
    TestNAVArraySumDouble()
    TestNAVArrayAverageInteger()
    TestNAVArrayAverageSignedInteger()
    TestNAVArrayAverageLong()
    TestNAVArrayAverageFloat()
    TestNAVArrayAverageDouble()
    #END_IF

    #IF_DEFINED TESTING_NAVARRAYSLICEFUNCTIONS
    TestNAVArraySliceInteger()
    TestNAVArraySliceString()
    #END_IF

    #IF_DEFINED TESTING_NAVARRAYSETFUNCTIONS
    TestNAVArrayCharSetInit()
    TestNAVArrayCharSetAdd()
    TestNAVArrayCharSetContains()
    TestNAVArrayCharSetRemove()
    TestNAVArrayIntegerSetInit()
    TestNAVArrayIntegerSetAdd()
    TestNAVArrayIntegerSetContains()
    TestNAVArrayIntegerSetRemove()
    #END_IF

    #IF_DEFINED TESTING_NAVARRAYFORMATFUNCTIONS
    TestNAVFormatArrayInteger()
    TestNAVFormatArrayString()
    #END_IF

    #IF_DEFINED TESTING_NAVARRAYSEARCHFUNCTIONS
    TestNAVArrayBinarySearchIntegerRecursive()
    TestNAVArrayBinarySearchIntegerIterative()
    TestNAVArrayTernarySearchInteger()
    TestNAVArrayJumpSearchInteger()
    TestNAVArrayExponentialSearchInteger()
    #END_IF
}
