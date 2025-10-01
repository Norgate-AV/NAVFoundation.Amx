#DEFINE TESTING_NAVDEVICEPRIORITYQUEUEBASIC
#DEFINE TESTING_NAVDEVICEPRIORITYQUEUEPRIORITY
#DEFINE TESTING_NAVDEVICEPRIORITYQUEUESTATE
#DEFINE TESTING_NAVDEVICEPRIORITYQUEUERESPONSE
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Queue.axi'
#include 'NAVFoundation.DevicePriorityQueue.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVDEVICEPRIORITYQUEUEBASIC
#include 'NAVDevicePriorityQueueBasic.axi'
#END_IF

#IF_DEFINED TESTING_NAVDEVICEPRIORITYQUEUEPRIORITY
#include 'NAVDevicePriorityQueuePriority.axi'
#END_IF

#IF_DEFINED TESTING_NAVDEVICEPRIORITYQUEUESTATE
#include 'NAVDevicePriorityQueueState.axi'
#END_IF

#IF_DEFINED TESTING_NAVDEVICEPRIORITYQUEUERESPONSE
#include 'NAVDevicePriorityQueueResponse.axi'
#END_IF


define_function RunDevicePriorityQueueTests() {
    #IF_DEFINED TESTING_NAVDEVICEPRIORITYQUEUEBASIC
    TestNAVDevicePriorityQueueInit()
    TestNAVDevicePriorityQueueEmptyState()
    TestNAVDevicePriorityQueueGetLastMessage()
    #END_IF

    #IF_DEFINED TESTING_NAVDEVICEPRIORITYQUEUEPRIORITY
    TestNAVDevicePriorityQueueEnqueueCommands()
    TestNAVDevicePriorityQueueEnqueueQueries()
    TestNAVDevicePriorityQueuePriorityOrdering()
    TestNAVDevicePriorityQueueMixedOperations()
    #END_IF

    #IF_DEFINED TESTING_NAVDEVICEPRIORITYQUEUESTATE
    TestNAVDevicePriorityQueueDequeueBusyFlag()
    TestNAVDevicePriorityQueueDequeueWhenBusy()
    TestNAVDevicePriorityQueueDequeueWhenEmpty()
    #END_IF

    #IF_DEFINED TESTING_NAVDEVICEPRIORITYQUEUERESPONSE
    TestNAVDevicePriorityQueueGoodResponse()
    TestNAVDevicePriorityQueueFailedResponse()
    TestNAVDevicePriorityQueueMaxFailures()
    TestNAVDevicePriorityQueueFailedResponseWhenNotBusy()
    TestNAVDevicePriorityQueueResend()
    #END_IF
}


