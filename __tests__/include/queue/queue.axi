#DEFINE TESTING_NAVQUEUEBASIC
#DEFINE TESTING_NAVQUEUESTATE
#DEFINE TESTING_NAVQUEUEOPERATIONS
#DEFINE TESTING_NAVQUEUEBOUNDARY
#DEFINE TESTING_NAVQUEUEINTEGRITY
#DEFINE TESTING_NAVQUEUEREGRESSION
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Queue.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVQUEUEBASIC
#include 'NAVQueueBasic.axi'
#END_IF

#IF_DEFINED TESTING_NAVQUEUESTATE
#include 'NAVQueueState.axi'
#END_IF

#IF_DEFINED TESTING_NAVQUEUEOPERATIONS
#include 'NAVQueueOperations.axi'
#END_IF

#IF_DEFINED TESTING_NAVQUEUEBOUNDARY
#include 'NAVQueueBoundary.axi'
#END_IF

#IF_DEFINED TESTING_NAVQUEUEINTEGRITY
#include 'NAVQueueIntegrity.axi'
#END_IF

#IF_DEFINED TESTING_NAVQUEUEREGRESSION
#include 'NAVQueueRegression.axi'
#END_IF

define_function RunQueueTests() {
    #IF_DEFINED TESTING_NAVQUEUEBASIC
    TestNAVQueueInit()
    TestNAVQueueEnqueue()
    TestNAVQueueDequeue()
    #END_IF

    #IF_DEFINED TESTING_NAVQUEUESTATE
    TestNAVQueueIsEmpty()
    TestNAVQueueHasItems()
    TestNAVQueueIsFull()
    TestNAVQueueGetCount()
    TestNAVQueueGetCapacity()
    #END_IF

    #IF_DEFINED TESTING_NAVQUEUEOPERATIONS
    TestNAVQueuePeek()
    TestNAVQueueClear()
    TestNAVQueueContains()
    TestNAVQueueToString()
    #END_IF

    #IF_DEFINED TESTING_NAVQUEUEBOUNDARY
    TestNAVQueueDequeueEmpty()
    TestNAVQueuePeekEmpty()
    TestNAVQueueEnqueueFull()
    TestNAVQueueContainsEmpty()
    TestNAVQueueInitCapacityOne()
    TestNAVQueueInitCapacityZero()
    // TestNAVQueueInitCapacityNegative()
    TestNAVQueueInitCapacityExceedsMax()
    TestNAVQueueLongStrings()
    TestNAVQueueSpecialCharacters()
    TestNAVQueueClearAndReuse()
    #END_IF

    #IF_DEFINED TESTING_NAVQUEUEINTEGRITY
    TestNAVQueueFIFOOrdering()
    TestNAVQueueDataPersistence()
    TestNAVQueueCircularWrapAround()
    TestNAVQueueInterleavedOperations()
    TestNAVQueueHeadTailState()
    TestNAVQueuePeekAfterWrap()
    TestNAVQueueContainsAfterWrap()
    #END_IF

    #IF_DEFINED TESTING_NAVQUEUEREGRESSION
    TestNAVQueueErrorRecovery()
    TestNAVQueuePartialOperations()
    TestNAVQueueMultipleClear()
    TestNAVQueueFullEmptyCycles()
    TestNAVQueueRapidOperations()
    TestNAVQueueContainsWithEmptySlots()
    TestNAVQueueToStringWrapped()
    TestNAVQueueReinitialization()
    #END_IF
}
