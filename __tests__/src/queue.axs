PROGRAM_NAME='queue'

#DEFINE __MAIN__
#DEFINE TESTING_NAVQUEUE
#DEFINE TESTING_NAVDEVICEPRIORITYQUEUE

#IF_DEFINED TESTING_NAVQUEUE
#include 'queue.axi'
#END_IF

#IF_DEFINED TESTING_NAVDEVICEPRIORITYQUEUE
#include 'device-priority-queue.axi'
#END_IF

DEFINE_DEVICE

dvTP    =   10001:1:0

DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        set_log_level(NAV_LOG_LEVEL_DEBUG)

        #IF_DEFINED TESTING_NAVQUEUE
        RunQueueTests()
        #END_IF

        #IF_DEFINED TESTING_NAVDEVICEPRIORITYQUEUE
        RunDevicePriorityQueueTests()
        #END_IF
    }
}
