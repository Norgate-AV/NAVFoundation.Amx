#DEFINE TESTING_NAVSTACKBASIC
#DEFINE TESTING_NAVSTACKSTATE
#DEFINE TESTING_NAVSTACKBOUNDARY
#DEFINE TESTING_NAVSTACKINTEGRITY
#DEFINE TESTING_NAVSTACKREGRESSION
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Stack.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVSTACKBASIC
#include 'NAVStackBasic.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTACKSTATE
#include 'NAVStackState.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTACKBOUNDARY
#include 'NAVStackBoundary.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTACKINTEGRITY
#include 'NAVStackIntegrity.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTACKREGRESSION
#include 'NAVStackRegression.axi'
#END_IF

define_function RunStackTests() {
    #IF_DEFINED TESTING_NAVSTACKBASIC
    TestNAVStackStringInit()
    TestNAVStackIntegerInit()
    TestNAVStackStringPush()
    TestNAVStackIntegerPush()
    TestNAVStackStringPop()
    TestNAVStackIntegerPop()
    TestNAVStackStringPeek()
    TestNAVStackIntegerPeek()
    #END_IF

    #IF_DEFINED TESTING_NAVSTACKSTATE
    TestNAVStackStringIsEmpty()
    TestNAVStackIntegerIsEmpty()
    TestNAVStackStringIsFull()
    TestNAVStackIntegerIsFull()
    TestNAVStackStringGetCount()
    TestNAVStackIntegerGetCount()
    TestNAVStackStringGetCapacity()
    TestNAVStackIntegerGetCapacity()
    #END_IF

    #IF_DEFINED TESTING_NAVSTACKBOUNDARY
    TestNAVStackStringPopEmpty()
    TestNAVStackIntegerPopEmpty()
    TestNAVStackStringPeekEmpty()
    TestNAVStackIntegerPeekEmpty()
    TestNAVStackStringPushFull()
    TestNAVStackIntegerPushFull()
    TestNAVStackStringInitCapacityOne()
    TestNAVStackIntegerInitCapacityOne()
    TestNAVStackStringInitCapacityZero()
    TestNAVStackIntegerInitCapacityZero()
    TestNAVStackStringInitCapacityExceedsMax()
    TestNAVStackIntegerInitCapacityExceedsMax()
    TestNAVStackStringPushEmptyString()
    TestNAVStackStringLongStrings()
    TestNAVStackIntegerZeroValues()
    // TestNAVStackIntegerNegativeValues()
    #END_IF

    #IF_DEFINED TESTING_NAVSTACKINTEGRITY
    TestNAVStackStringLIFOOrdering()
    TestNAVStackIntegerLIFOOrdering()
    TestNAVStackStringDataPersistence()
    TestNAVStackIntegerDataPersistence()
    TestNAVStackStringInterleavedOperations()
    TestNAVStackIntegerInterleavedOperations()
    TestNAVStackStringStateConsistency()
    TestNAVStackIntegerStateConsistency()
    #END_IF

    #IF_DEFINED TESTING_NAVSTACKREGRESSION
    TestNAVStackStringErrorRecovery()
    TestNAVStackIntegerErrorRecovery()
    TestNAVStackStringRapidOperations()
    TestNAVStackIntegerRapidOperations()
    TestNAVStackStringFullEmptyCycles()
    TestNAVStackIntegerFullEmptyCycles()
    TestNAVStackStringReinitialization()
    TestNAVStackIntegerReinitialization()
    TestNAVStackStringSpecialCharacters()
    TestNAVStackIntegerBoundaryValues()
    TestNAVStackStringMultiplePeeks()
    TestNAVStackIntegerMultiplePeeks()
    #END_IF
}
